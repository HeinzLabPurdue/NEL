/****************************************************************************
 *
 *	  		 PCI-6602 Double-buffered Counter Driver for Matlab
 *
 * File: msd.c  (same as msd14.c)
 *
 * Abstract:
 *      Device driver for the double-buffered counter of
 *      the National Instruments PCI-6602 Counter/Timer boards.
 * 
 *      Add SEQ restoration block on 2/26/01
 *		Add MC buffer on 4/10/01
 *      Merge msd11 & msd12 on 4/24/01
 *		Last modified on 5/4/01
 *
 * Library: nidex32.lib and nidaq32.lib
 *
 * Programed by Kimmy on Dec. 27, 2000
 *				last modified on 6/7/01
 *
 * Copyright (c) 2000 by Johns Hopkins University. All Rights Reserved.
 *
 *****************************************************************************/

 
#include "mex.h"
#include <stdlib.h>     /* malloc(), free(), strtoul() */
#include <math.h>
#include "pci6602.h"

# define DMA_CH	(6)
# define MAX_BUF (200)

/* the gateway function */
void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[])
{
	long double	 *z1,*z2;
	double		 *buf,tSeq;
	int			 i,j,k = 2;
	int			 nCh,nRd,nSeq,Set,max_iLoop=0;
	int			 iLoop[DMA_CH] = {0};
    i16			 iDevice = 1;
    i16			 iGateFasterThanSource = 0;
    i16			 iPort = 0;
    i16			 iMode = 0;
    i16			 iDir_in  = 0;
	i16			 iDir_out  = 1;
	static int	 cSeq = 0;
	bool		 multi_channel = false;
    u32			 ulGpctrNum[DMA_CH] = {ND_COUNTER_0,ND_COUNTER_1,ND_COUNTER_2,ND_COUNTER_3,ND_COUNTER_4,ND_COUNTER_5};
	u32			 ulGpctrGt[DMA_CH] = {ND_PFI_38, ND_PFI_34, ND_PFI_30,ND_PFI_26, ND_PFI_22, ND_PFI_18};
    u32			 ulCount[DMA_CH] = {10000,10000,10000,10000,10000,10000};
    u32			 ulNumPtsRead[DMA_CH] = {0};   
    u32			 ulInitCount = 0;
    u32			 ulReadOffset = 0;
    u32			 ulTimeOut = 0;
    u32			 ulNumPtsToRead = 1;
    // u32			 ulCountSt = {1000};
    u32			 ulCountTr = {1000};
    u32			 ulNumPtsReadSt = {0};
    u32			 ulNumPtsReadTr = {0};	
	static u32	 pulBuffer[DMA_CH][100000] = {0};
    static u32	 pulReadBuf[DMA_CH][50000] = {0};
    static u32	 cmpReadBuf[DMA_CH] = {0};  // Mike: The last read spike-time for each channel
    static u32	 cmpSeqBuf[DMA_CH] = {0};   // Mike: The sequence of the last read spike-time for each channel
    static float pulTmpBuf[DMA_CH][5000] = {0};
	static u32	 pulTmpSeq[DMA_CH][5000] = {0};
	// static u32	 pulBufferSt[1000] = {0};
    // static u32	 pulReadBufSt[500] = {0};
	static u32	 pulBufferTr[1000] = {0}; // Used as the Buffer for the Trigger (and currently, for getting returned vals)
    // static u32	 cmpTrigBuf = {0};
	static u32	 pulSeq[100] = {0};       // TODO: Remvoe the 100 limit


	/*  check for proper number of arguments */
	if(nrhs!=4) 
		mexErrMsgTxt("Four inputs required.");
	if(nlhs!=2) 
		mexErrMsgTxt("Two outputs required.");
  
	/* check to make sure input arguments are scalar */
	if( !mxIsNumeric(prhs[0]) || mxIsEmpty(prhs[0])   || 
		mxIsComplex(prhs[0])  ||  
        mxGetN(prhs[0])*mxGetM(prhs[0])!=1 ) {
		mexErrMsgTxt("Input nCh must be a scalar.");
	}	

	if( !mxIsNumeric(prhs[1]) || mxIsEmpty(prhs[1])   ||
		mxIsComplex(prhs[1])  || 
        mxGetN(prhs[1])*mxGetM(prhs[1])!=1 ) {
		mexErrMsgTxt("Input Set must be a scalar.");
	}	

	if( !mxIsNumeric(prhs[2]) || mxIsEmpty(prhs[2])   ||
		mxIsComplex(prhs[2])  || 
        mxGetN(prhs[2])*mxGetM(prhs[2])!=1 ) {
		mexErrMsgTxt("Input Set must be a scalar.");
	}	

	if( !mxIsNumeric(prhs[3]) || mxIsEmpty(prhs[3])   ||
		mxIsComplex(prhs[3])  || 
        mxGetN(prhs[3])*mxGetM(prhs[3])!=1 ) {
		mexErrMsgTxt("Input Set must be a scalar.");
	}	

	/*  get the scalar input x & y */
	nCh  = mxGetScalar(prhs[0]);
	tSeq = mxGetScalar(prhs[1]);
	nSeq = mxGetScalar(prhs[2]);
	Set  = mxGetScalar(prhs[3]);

	if ((nCh <= 0) || (nCh > 6)) {
		mexErrMsgTxt("Number of Channel is upto 6");
	}

	if ((tSeq <= 0) || (tSeq > 10)) {
		mexErrMsgTxt("Maximum time span is upto 10 seconds.");
	}
	
	if ((nSeq <= 0) || (nSeq > 1000)) {
		mexErrMsgTxt("Maximum # of sequence is 1000.");
	}
	
	if ((Set != 0) && (Set != 1) && (Set != 2) && (Set != 3)) {
		mexErrMsgTxt("Setting bit must be 0(reset), 1(reset and arm the counter), 2(read) or 3(digi_out) only");
	}

	/*  set the output pointer to the output matrix */
	plhs[0] = mxCreateDoubleMatrix(nCh,1, mxREAL);
	plhs[1] = mxCreateDoubleMatrix(nCh,1, mxREAL);

	/*  create a C pointer to a copy of the output matrix */
	z1 = mxGetPr(plhs[0]);
 	z2 = mxGetPr(plhs[1]);


	if (Set == 0) { // Reset Mode


		DIG_Prt_Config(iDevice, iPort, iMode, iDir_in);
		
		for (i = 0; i < nCh; i++) {
		
			/* Restore buffer mode to SINGLE. */

			GPCTR_Change_Parameter(iDevice, ulGpctrNum[i], ND_BUFFER_MODE, ND_SINGLE);

			/* Reset GPCTR. */

			GPCTR_Control(iDevice, ulGpctrNum[i], ND_RESET);
			GPCTR_Change_Parameter(iDevice, ulGpctrNum[i], ND_INITIAL_COUNT, ulInitCount);

			pulSeq[100] = 0;


		}

		GPCTR_Control(iDevice, ND_COUNTER_7, ND_RESET);

		cSeq  = 0;
		*z1	  = 0;
		*z2   = 0;
		// free(pulTmpSeq);
		// free(pulSeq);
		

	} else if (Set == 1) { // Initialize Mode

		cSeq  = 0;
		*z1	  = 0;
		*z2   = 0;
		for (i = 0; i < nCh; i++) {
			cmpSeqBuf[i] = 0;
			cmpReadBuf[i] = 0;
			// pulBufferTr[i] = 0; // Ha????!!!!! Was declared as int[1000]
		}
		
		// TODO: put the following lines in a loop (with the parameters in an array).
		Set_DAQ_Device_Info(iDevice, ND_DATA_XFER_MODE_GPCTR0, ND_UP_TO_2_DMA_CHANNELS);
		Set_DAQ_Device_Info(iDevice, ND_DATA_XFER_MODE_GPCTR1, ND_UP_TO_2_DMA_CHANNELS);
		Set_DAQ_Device_Info(iDevice, ND_DATA_XFER_MODE_GPCTR7, ND_UP_TO_2_DMA_CHANNELS);
		Set_DAQ_Device_Info(iDevice, ND_DATA_XFER_MODE_GPCTR2, ND_INTERRUPTS);
		Set_DAQ_Device_Info(iDevice, ND_DATA_XFER_MODE_GPCTR3, ND_INTERRUPTS);
		Set_DAQ_Device_Info(iDevice, ND_DATA_XFER_MODE_GPCTR4, ND_INTERRUPTS);
		Set_DAQ_Device_Info(iDevice, ND_DATA_XFER_MODE_GPCTR5, ND_INTERRUPTS);
		//

		DIG_Prt_Config(iDevice, iPort, iMode, iDir_in);

		/* for trigger */

		GPCTR_Control(iDevice, ND_COUNTER_7, ND_RESET);
		GPCTR_Set_Application(iDevice, ND_COUNTER_7, ND_BUFFERED_EVENT_CNT);
		GPCTR_Change_Parameter(iDevice, ND_COUNTER_7, ND_GATE, ND_PFI_10);
		GPCTR_Change_Parameter(iDevice, ND_COUNTER_7, ND_SOURCE, ND_INTERNAL_100_KHZ);
		GPCTR_Change_Parameter(iDevice, ND_COUNTER_7, ND_INITIAL_COUNT, ulInitCount);

		/* Using Hardware Trigger */
		GPCTR_Change_Parameter(iDevice, ND_COUNTER_7, ND_START_TRIGGER,ND_ENABLED);
		// GPCTR_Change_Parameter(iDevice, ND_COUNTER_7, ND_START_TRIGGER_POLARITY,ND_LOW_TO_HIGH); // This is the default.
		// GPCTR_Change_Parameter(iDevice, ND_COUNTER_7, ND_BUFFER_MODE, ND_CONTINUOUS);
		GPCTR_Config_Buffer(iDevice, ND_COUNTER_7, 0, ulCountTr, pulBufferTr);
		

		for (i = 0; i < nCh; i++) {
			
			/* Reset Counter */

			GPCTR_Control(iDevice, ulGpctrNum[i], ND_RESET);

			/* Set up for a buffered event counting application. */

			GPCTR_Set_Application(iDevice, ulGpctrNum[i], ND_BUFFERED_EVENT_CNT);

			/* Using 100kHz internal source clock */

			GPCTR_Change_Parameter(iDevice, ulGpctrNum[i], ND_SOURCE, ND_INTERNAL_100_KHZ);

			/* Each time a pulse arrives in the gate, a new value will be
     			latched into the counter and sent to the data buffer. */

			GPCTR_Change_Parameter(iDevice, ulGpctrNum[i], ND_GATE, ulGpctrGt[i]);
		}

		for (i = 0; i < nCh; i++) {
			/* Load initial count. */
			GPCTR_Change_Parameter(iDevice, ulGpctrNum[i], ND_INITIAL_COUNT, ulInitCount);

			/* Enable double-buffer mode. */

			GPCTR_Change_Parameter(iDevice, ulGpctrNum[i], ND_BUFFER_MODE, ND_DOUBLE);

			/* Using Hardware Trigger */
			GPCTR_Change_Parameter(iDevice, ulGpctrNum[i], ND_START_TRIGGER,ND_ENABLED);
			GPCTR_Change_Parameter(iDevice, ulGpctrNum[i], ND_START_TRIGGER_POLARITY,ND_LOW_TO_HIGH);
			Select_Signal(iDevice, ND_START_TRIGGER, ND_PFI_0,ND_LOW_TO_HIGH);
			 
			pulReadBuf[i][0] = 0;
		}

		/* WE DON'T REALLY NEED IT: Turn on synchronous counting mode if gate is faster than source. */
		//if (iGateFasterThanSource == 1) {
		//
		//	for (i = 0; i < nCh; i++) {
		//		GPCTR_Change_Parameter(iDevice, ulGpctrNum[i], ND_COUNTING_SYNCHRONOUS, ND_YES);
		//	}
		//}

		/* Arm the Counter */

        for (i = 0; i < nCh; i++) {
			GPCTR_Config_Buffer(iDevice, ulGpctrNum[i], 0, ulCount[i], pulBuffer[i]);
		}

        for (i = 0; i < nCh; i++) {
			GPCTR_Control(iDevice, ulGpctrNum[i], ND_PROGRAM);
		}

		GPCTR_Control(iDevice, ND_COUNTER_7, ND_PROGRAM);



	} else if (Set == 2) { // Run Mode
		
		 __asm int 3h 
		/* Sequence Monitoring : Rising Edge Trigger on Gate of Counter7*/
		GPCTR_Read_Buffer(iDevice, ND_COUNTER_7, ND_READ_MARK, ulReadOffset,
			ulNumPtsToRead, ulTimeOut, &ulNumPtsReadTr, pulBufferTr);

		if (*pulBufferTr > cmpSeqBuf[0]) {

SEQ_LOOP:	pulSeq[cSeq] = *pulBufferTr;

			if (cSeq > nSeq) {
				*z1 = nSeq+100; // for debugging
				goto END_DATA;
			}
			++cSeq;

			GPCTR_Read_Buffer(iDevice, ND_COUNTER_7, ND_READ_MARK, ulReadOffset,
				ulNumPtsToRead, ulTimeOut, &ulNumPtsReadTr, pulBufferTr);
			if (*pulBufferTr != pulSeq[cSeq-1]) {
				goto SEQ_LOOP;
			}
		}
		cmpSeqBuf[0] = *pulBufferTr;


		/* Spikes Return main routin */
		for (i = 0; i < nCh; i++) {

			/* Read Spike Time on the Buffer */
			GPCTR_Read_Buffer(iDevice, ulGpctrNum[i], ND_READ_MARK, ulReadOffset,
				ulNumPtsToRead, ulTimeOut, &ulNumPtsRead[i], pulReadBuf[i]);
			
			if (*pulReadBuf[i] > tSeq*100000*(nSeq+1)) {
				*(z1 + i) = nSeq+200; // for debugging
				*(z2 + i) = 0;
				goto END_DATA;
			}
		}

		for (i = 0; i < nCh; i++) {

			if (*pulReadBuf[i] > cmpReadBuf[i]) {
				if (*pulReadBuf[i] >= *pulBufferTr) {

					*(z1 + i) = floor(*pulBufferTr * 0.00001 / tSeq)+1;
					*(z2 + i) = (*pulReadBuf[i] - *pulBufferTr)* 0.00001;

				} else {

					// data buffering
					while (*pulReadBuf[i]  < pulSeq[cSeq - 1]) {

BUF_LOOP:				if (*pulReadBuf[i] >= pulSeq[cSeq - k]) {
							pulTmpSeq[i][iLoop[i]] = floor(pulSeq[cSeq - k] * 0.00001 / tSeq)+1;
							pulTmpBuf[i][iLoop[i]] = (*pulReadBuf[i] - pulSeq[cSeq - k])* 0.00001;
						} else {		
							k++;
							if ((cSeq < k) || (k > 100)) {
								goto END_DATA;
							}
							goto BUF_LOOP;
						}
						iLoop[i]++;
						k = 2;

						GPCTR_Read_Buffer(iDevice, ulGpctrNum[i], ND_READ_MARK, ulReadOffset,
							ulNumPtsToRead, ulTimeOut, &ulNumPtsRead[i], pulReadBuf[i]);
						if (*pulReadBuf[i] == cmpReadBuf[i]) { 
							iLoop[i] = 0; //?
							break;
						}
						cmpReadBuf[i] = *pulReadBuf[i];
					}

					pulTmpSeq[i][iLoop[i]] = floor(*pulBufferTr * 0.00001 / tSeq)+1;
					pulTmpBuf[i][iLoop[i]] = (*pulReadBuf[i] - *pulBufferTr)* 0.00001;

					if (nCh == 1) {
						/*  set the output pointer to the output matrix */
						plhs[0] = mxCreateDoubleMatrix(nCh,iLoop[i]+1, mxREAL);
						plhs[1] = mxCreateDoubleMatrix(nCh,iLoop[i]+1, mxREAL);

						/*  create a C pointer to a copy of the output matrix */
						z1 = mxGetPr(plhs[0]);
						z2 = mxGetPr(plhs[1]);

							for (j = 0; j < iLoop[0]+1; j++) {
								*(z1 + 0 + j*nCh) = pulTmpSeq[0][j];
								*(z2 + 0 + j*nCh) = pulTmpBuf[0][j];
								if (pulTmpBuf[0][j] > tSeq) {
									goto END_DATA;
								}
							}

					} else { // for multichannel
						multi_channel = true;
						if (iLoop[i] > max_iLoop) {
							max_iLoop = iLoop[i];
						}
					}
				}
			} else { // return sequence when no new data in buffer
				*(z1 + i) = floor(*pulBufferTr * 0.00001 / tSeq)+1;
				*(z2 + i) = 0;
			}
		}


		if (multi_channel == true) { // for multi-channel remake array and return data to Matlab

			/*  set the output pointer to the output matrix */
			plhs[0] = mxCreateDoubleMatrix(nCh,max_iLoop+1, mxREAL);
			plhs[1] = mxCreateDoubleMatrix(nCh,max_iLoop+1, mxREAL);
			/*  create a C pointer to a copy of the output matrix */
			z1 = mxGetPr(plhs[0]);
			z2 = mxGetPr(plhs[1]);

			for (i = 0; i < nCh; i++) {
				for (j = 0; j < max_iLoop+1; j++) {
					if (pulTmpBuf[i][j] > tSeq) {
						goto END_DATA;
					}
					if (max_iLoop <= iLoop[i]) {
						*(z1 + i + j*nCh) = pulTmpSeq[i][j];
						*(z2 + i + j*nCh) = pulTmpBuf[i][j];
					} else {
						*(z1 + i + j*nCh) = cSeq;
						*(z2 + i + j*nCh) = 0;
					}
				}
			}
		}

END_DATA:
		for (i = 0; i < nCh; i++) {
			cmpReadBuf[i] = *pulReadBuf[i];
			iLoop[i] = 0;
		}



	} else if (Set == 3) { // Digital Out

		/* Configure port as output, no handshaking. */

		DIG_Prt_Config(iDevice, iPort, iMode, iDir_out);
		DIG_Out_Prt(iDevice, iPort, nCh);

	}


}


/* EOF: msd.c */
