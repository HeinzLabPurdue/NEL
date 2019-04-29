/*********************************************************************
*
* d2a.c
* mex file for D/A output from 6052e card.
*
* Written by AF and GE.  26Jun2002.  Modified by MH/GE, oct/nov 2003.
*  - see WFMsingleBufAsynch.c and WFMsingleBufExtTrig_Eseries.c for examples 
*
* Pin Connection Information: 
*    The analog output signal(s) will be available at AO channel 0 and/or 1.
*	 Trigger signal should be connected to PFI6.
*
*
* INPUT ARGUMENT(S), depending on call mode:
*	(iMode=0)
*	(iMode=1, dRequestedUpdateRate_Hz, <samples matrix>)
*  
*********************************************************************/

/*
 * Includes: 
 */

#include "mex.h"
#include <stdlib.h>     /* malloc(), free(), strtoul() */
#include <math.h>
#include "nidaqex.h"
#include <time.h>


/*
 * Main: 
 */

void mexFunction( int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
     /*
     * Local Variable Declarations: 
     */

    i16 iStatus = 0;
    i16 iRetVal = 0;
    i16 iDevice = 2;
	i16 iGroup = 1;		/* hard-coded */
    u32 ulIterations = 1;
    i16 iIgnoreWarning = 0;
    i16 iOpSTART = 1;
    i16 iOpCLEAR = 0;
    i16 iFIFOMode = 0;
	i16 iUnits = 0;			// "pts per sec"
	i16 iWhichClock = 0;	// use the "update clock"
	i16 iDelayMode = 0;		// disable the delay clock
    i16 iUpdateTB = -3; // -3: use 20MHz counter on board (MH/GE 04Nov2003)
    u32 ulUpdateInt; // will be computed 'manually' below (MH/GE 04Nov2003)

	int iMode;
    f64 dRequestedUpdateRate_Hz; 
	f64* dActualUpdateRate_Hz;
    i16 iNumChans;
	u32 ulCount;

    i16 iChan;
    static i16 piChan0Vect[1] = {0};
	static i16 piChanAllVect[2] = {0,1};
	f64* pdBuffer0;
	f64* pdBuffer1;
	i16* piLoadBuffer;  //used for interleaving channels 1&2
	u32 ulBufInd;
	i16* piBuffer0;
	i16* piBuffer1;

	f64 dBASE_CLOCK_RATE_Hz = 20e6; // Based on 'iUpdateTB' set to -3 (line above).

	double *statCodes,*retVals;

//	__asm int 3h ; // Setting a breakpoint for debugging (compile with the -g flag!)
							// For "Nel_matlab", run 'doallmex' with '(0,1)' flags.
							// Run Nel software as usual, and Matlab will automatically
							//  break at this line and open this file in Visual Studio
							//  debugger environment.


	/**********************************************************************/
	// Setup a matrix for outputting error codes:
	plhs[0] = mxCreateDoubleMatrix(12,1, mxREAL);  // used for statCodes (MH/GE)
	plhs[1] = mxCreateDoubleMatrix(12,1, mxREAL);  // used for retVals (MH/GE)
	statCodes = mxGetPr(plhs[0]);
	retVals = mxGetPr(plhs[1]);

	/**********************************************************************/
	// Setup to return ActualUpdateRate_Hz
	plhs[2] = mxCreateDoubleMatrix(1,1, mxREAL);  
	dActualUpdateRate_Hz = mxGetPr(plhs[2]);

//		printf(" nlhs=%i; nrhs=%i.\n", nlhs, nrhs);

	/**********************************************************************/
	// Get function call mode:
	iMode = mxGetScalar(prhs[0]);  // input argument


	/***********************************************/
	/*
	 * MODE 0: Initialization only.
	 */

	if (iMode == 0) {
		/**********************************************************************/
		/* Set both analog output channels back to initial state. */
		iStatus = AO_VWrite(iDevice, 0, 0.0);
		statCodes[1] = iStatus;
		iStatus = AO_VWrite(iDevice, 1, 0.0);
		statCodes[2] = iStatus;
		return;
		}

	/***********************************************/
	/*
	 * MODE 1: Load buffer(s) to board and set up triggering.
	 */

	if (iMode == 1) { 

		/**********************************************************************/
		dRequestedUpdateRate_Hz = (f64) mxGetScalar(prhs[1]);   // input argument 
		iNumChans = (i16) mxGetN(prhs[2]);          // # of columns in samples matrix (input argument)
		ulCount = (u32) mxGetM(prhs[2]);			// # of rows in samples matrix (input argument)
		pdBuffer0 = (f64*) mxGetPr(prhs[2]);		// pointer to data of first column of samples matrix
		pdBuffer1 = &(pdBuffer0[ulCount]);			// pointer to data of second column of samples matrix

    
		// Setup output sample rate:
//		iStatus = WFM_Rate(dRequestedUpdateRate_Hz, iUnits, &iUpdateTB, &ulUpdateInt);  // Don't use WFM_Rate!!! (MH/GE 04Nov2003)
//		iRetVal = NIDAQErrorHandler(iStatus, "WFM_Rate", iIgnoreWarning);
//		statCodes[3] = iStatus;
//		retVals[3] = iRetVal;

		
		// compute clock divisor for requested rate, must be integer. 
		ulUpdateInt = (u32) (dBASE_CLOCK_RATE_Hz / dRequestedUpdateRate_Hz);

//		printf("updateInt = %i     updateTB = %i\n", ulUpdateInt, iUpdateTB);  // ge debug

		// Actual update rate may not equal Requested update rate, so return actual rate
		dActualUpdateRate_Hz[0] = dBASE_CLOCK_RATE_Hz / (f64) ulUpdateInt;
//		printf("Requested = %f     Actual = %f\n", dRequestedUpdateRate_Hz, *dActualUpdateRate_Hz); // ge debug

		// Set Clock using computed ulUpdateInt, and iUpdateTB=-3 (set at init)
		iStatus = WFM_ClockRate(iDevice, iGroup, iWhichClock, iUpdateTB, ulUpdateInt, iDelayMode);
		iRetVal = NIDAQErrorHandler(iStatus, "WFM_ClockRate", iIgnoreWarning);
		statCodes[4] = iStatus;
		retVals[4] = iRetVal;

			
		if (iNumChans == 1)	{	// Channel 0 only
			piLoadBuffer = mxCalloc(ulCount,sizeof(i16));
			iChan = 0;
			iStatus = WFM_Scale(iDevice, iChan, ulCount, 1.0, pdBuffer0, piLoadBuffer);
			iRetVal = NIDAQErrorHandler(iStatus, "WFM_Scale", iIgnoreWarning);
			statCodes[5] = iStatus;
			retVals[5] = iRetVal;
			iStatus = WFM_Load(iDevice, iNumChans, piChan0Vect, piLoadBuffer, ulCount, ulIterations, iFIFOMode);
			iRetVal = NIDAQErrorHandler(iStatus, "WFM_Load", iIgnoreWarning);
			statCodes[6] = iStatus;
			retVals[6] = iRetVal;

		}

		if (iNumChans == 2)	{	// Channels 0 and 1
			piBuffer0 = mxCalloc(ulCount,sizeof(i16));
			piBuffer1 = mxCalloc(ulCount,sizeof(i16));
			iChan = 0;
			iStatus = WFM_Scale(iDevice, iChan, ulCount, 1.0, pdBuffer0, piBuffer0);
			iRetVal = NIDAQErrorHandler(iStatus, "WFM_Scale", iIgnoreWarning);
			statCodes[7] = iStatus;
			retVals[7] = iRetVal;
			iChan = 1;
			iStatus = WFM_Scale(iDevice, iChan, ulCount, 1.0, pdBuffer1, piBuffer1);
			iRetVal = NIDAQErrorHandler(iStatus, "WFM_Scale", iIgnoreWarning);
			statCodes[8] = iStatus;
			retVals[8] = iRetVal;
			// Have to interleave buffers before loading to board:
			piLoadBuffer = mxCalloc(2*ulCount,sizeof(i16));
			for (ulBufInd = 0; ulBufInd < ulCount; ulBufInd+=1) {
				piLoadBuffer[2*ulBufInd] = piBuffer0[ulBufInd];
				piLoadBuffer[2*ulBufInd + 1] = piBuffer1[ulBufInd];
			}
			iStatus = WFM_Load(iDevice, iNumChans, piChanAllVect, piLoadBuffer, 2*ulCount, ulIterations, iFIFOMode);
			iRetVal = NIDAQErrorHandler(iStatus, "WFM_Load", iIgnoreWarning);
			statCodes[9] = iStatus;
			retVals[9] = iRetVal;

		}


		/* Set up triggering and "prime" board for output. */
		// MH/GE 05Nov2003: Can also use rising edge of trigger to start, 
		//					but seems preferable to use pause-on-low, because the logic in NEL's 
		//					data_acquisition_loop_NI.m is based on the up AND down trigger states
//	    iStatus = Select_Signal(iDevice, ND_OUT_START_TRIGGER,  ND_PFI_6, ND_LOW_TO_HIGH);
		iStatus = Select_Signal (iDevice, ND_OUT_EXTERNAL_GATE, ND_PFI_6, ND_PAUSE_ON_LOW);
		iRetVal = NIDAQErrorHandler(iStatus, "WFM_Select_Signal", iIgnoreWarning);
		statCodes[10] = iStatus;
		retVals[10] = iRetVal;

		iStatus = WFM_Group_Control(iDevice, iGroup, iOpSTART);
		iRetVal = NIDAQErrorHandler(iStatus, "WFM_Group_Control/START", iIgnoreWarning);
		statCodes[11] = iStatus;
		retVals[11] = iRetVal;

		return;
	}


	/***********************************************/
	/*
	 * MODE 2: Clean-up after playing waveform
	 */

	if (iMode == 2) {

		/**********************************************************************/
		/* Set both analog output channels back to initial state. */
		iStatus = WFM_Group_Control(iDevice, iGroup, iOpCLEAR);
		statCodes[0] = iStatus;
		iStatus = AO_VWrite(iDevice, 0, 0.0);
		statCodes[1] = iStatus;
		iStatus = AO_VWrite(iDevice, 1, 0.0);
		statCodes[2] = iStatus;

		/* CLEANUP - Intentionally don't check for errors. */
        /* Set PFI line back to initial state. */
        iStatus = Select_Signal(iDevice, ND_OUT_EXTERNAL_GATE, ND_NONE, ND_DONT_CARE);

		return;	
	}

	/***********************************************/
	/*
	 * MODE 3: Just compute and return the valid update rate that would be used,
	 *          based on the requested update rate.
	 */

	if (iMode == 3) {

		/**********************************************************************/
		dRequestedUpdateRate_Hz = (f64) mxGetScalar(prhs[1]);   // input argument 
		
		// compute clock divisor for requested rate, must be integer.   // computation copied from above
		//  in iMode = 2.
		ulUpdateInt = (u32) (dBASE_CLOCK_RATE_Hz / dRequestedUpdateRate_Hz);
		dActualUpdateRate_Hz[0] = dBASE_CLOCK_RATE_Hz / (f64) ulUpdateInt;

		return;	
	}


}
