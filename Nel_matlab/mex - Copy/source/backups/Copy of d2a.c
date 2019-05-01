/*********************************************************************
*
* d2a.c
* mex file for D/A output from 6052e card.
*
* Written by LF and GE.  26Jun2002.
*
* Pin Connection Information: 
*    The analog output signal(s) will be available at AO channel 0 and/or 1.
*	 Trigger signal should be connected to PFI6.
*
*
* INPUT ARGUMENT(S), depending on call mode:
*	(iMode=0)
*	(iMode=1, dUpdateRate_Hz, <samples matrix>)
*  
*********************************************************************/

/*
 * Includes: 
 */

#include "mex.h"
#include <stdlib.h>     /* malloc(), free(), strtoul() */
#include <math.h>
#include "nidaqex.h"

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
    i16 iUpdateTB = 0;
    u32 ulUpdateInt = 0;

	int iMode;
    f64 dUpdateRate;
    i16 iNumChans;
	u32 ulCount;

    i16 iChan;
    static i16 piChan0Vect[1] = {0};
	static i16 piChanAllVect[2] = {0,1};
	f64* pdBuffer0;
	f64* pdBuffer1;
	i16* piLoadBuffer;
	u32 ulBufInd;
	i16* piBuffer0;
	i16* piBuffer1;


//	__asm int 3h ; // Setting a breakpoint for debuging (compile with the -g flag!)


	/**********************************************************************/
	// Get function call mode:
	iMode = mxGetScalar(prhs[0]);

	
	/**********************************************************************/
	/* Set both analog output channels back to initial state. */
	iStatus = WFM_Group_Control(iDevice, iGroup, iOpCLEAR);
	iStatus = AO_VWrite(iDevice, 0, 0.0);
	iStatus = AO_VWrite(iDevice, 1, 0.0);


	/***********************************************/
	/*
	 * MODE 0: Initialization only.
	 */

	if (iMode == 0) { 
		return;
	}

	/***********************************************/
	/*
	 * MODE 1: Load buffer(s) to board and set up triggering.
	 */

	if (iMode == 1) { 

		/**********************************************************************/
		dUpdateRate = (f64) mxGetScalar(prhs[1]);
		iNumChans = (i16) mxGetN(prhs[2]);
		ulCount = (u32) mxGetM(prhs[2]);
		pdBuffer0 = (f64*) mxGetPr(prhs[2]);
		pdBuffer1 = &(pdBuffer0[ulCount]);

		// ge debug: do error-checking on the input parameters:

		// Setup output sample rate:
		iStatus = WFM_Rate(dUpdateRate, iUnits, &iUpdateTB, &ulUpdateInt);
		iRetVal = NIDAQErrorHandler(iStatus, "WFM_Rate", iIgnoreWarning);
		iStatus = WFM_ClockRate(iDevice, iGroup, iWhichClock, iUpdateTB, ulUpdateInt, iDelayMode);
		iRetVal = NIDAQErrorHandler(iStatus, "WFM_ClockRate", iIgnoreWarning);
	
		if (iNumChans == 1)	{	// Channel 0 only
			piLoadBuffer = mxCalloc(ulCount,sizeof(i16));
			iChan = 0;
			iStatus = WFM_Scale(iDevice, iChan, ulCount, 1.0, pdBuffer0, piLoadBuffer);
			iRetVal = NIDAQErrorHandler(iStatus, "WFM_Scale", iIgnoreWarning);
			iStatus = WFM_Load(iDevice, iNumChans, piChan0Vect, piLoadBuffer, ulCount, 1, iFIFOMode);
			iRetVal = NIDAQErrorHandler(iStatus, "WFM_Load", iIgnoreWarning);
		}

		if (iNumChans == 2)	{	// Channels 0 and 1
			piBuffer0 = mxCalloc(ulCount,sizeof(i16));
			piBuffer1 = mxCalloc(ulCount,sizeof(i16));
			iChan = 0;
			iStatus = WFM_Scale(iDevice, iChan, ulCount, 1.0, pdBuffer0, piBuffer0);
			iRetVal = NIDAQErrorHandler(iStatus, "WFM_Scale", iIgnoreWarning);
			iChan = 1;
			iStatus = WFM_Scale(iDevice, iChan, ulCount, 1.0, pdBuffer1, piBuffer1);
			iRetVal = NIDAQErrorHandler(iStatus, "WFM_Scale", iIgnoreWarning);
			// Have to interleave buffers before loading to board:
			piLoadBuffer = mxCalloc(2*ulCount,sizeof(i16));
			for (ulBufInd = 0; ulBufInd < ulCount; ulBufInd+=1) {
				piLoadBuffer[2*ulBufInd] = piBuffer0[ulBufInd];
				piLoadBuffer[2*ulBufInd + 1] = piBuffer1[ulBufInd];
			}
			iStatus = WFM_Load(iDevice, iNumChans, piChanAllVect, piLoadBuffer, ulCount, 1, iFIFOMode);
			iRetVal = NIDAQErrorHandler(iStatus, "WFM_Load", iIgnoreWarning);

		}

		
		/* Set up triggering and "prime" board for output. */
		iStatus = Select_Signal (iDevice, ND_OUT_EXTERNAL_GATE, ND_PFI_6, ND_PAUSE_ON_LOW);
		iRetVal = NIDAQErrorHandler(iStatus, "WFM_Select_Signal", iIgnoreWarning);
		iStatus = WFM_Group_Control(iDevice, iGroup, iOpSTART);
		iRetVal = NIDAQErrorHandler(iStatus, "WFM_Group_Control/START", iIgnoreWarning);

        
	}
}
