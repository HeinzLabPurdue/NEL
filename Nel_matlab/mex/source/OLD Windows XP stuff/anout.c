/******************************************************************************************
 *
 *	  		 PCI-6052e I/O card.
 *
 *
 * File: anout.c -- Analog Waveform Output
 *
 *
 * Library: nidex32.lib and nidaq32.lib
 *
 *****************************************************************************/

 
#include "mex.h"
#include <stdlib.h>     /* malloc(), free(), strtoul() */
#include <math.h>
#include "pci6052.h"

#define MAX_CH					6
#define SpkBuffLen			10000
#define TrgBuffLen			 1000
#define SourceClockPeriod	    0.00001

/************  Headers of our functions ***********/
void normalize_spikes(u32 *trg,int trg_len, double *spk, int spk_len, int base_trig_count,double *seq);
void Usage();
/*************************************************/

void mexFunction( int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
	int			 Mode;
    i16			 iDevice = 1;
	u32			 ulGpctrNum[MAX_CH] = {ND_COUNTER_0,ND_COUNTER_1,ND_COUNTER_2,ND_COUNTER_3,ND_COUNTER_4,ND_COUNTER_5};
	u32			 ulGpctrGt [MAX_CH] = {ND_PFI_38,   ND_PFI_34,   ND_PFI_30,   ND_PFI_26,   ND_PFI_22,   ND_PFI_18};
    
	static int	 cSeq = 0;
	static int	 nCh = 1;
	static u32	 pulBuffer[MAX_CH][2*SpkBuffLen] = {0};
	static u32	 pulBufferTr[TrgBuffLen] = {0}; // Used as the Buffer for the Trigger (and currently, for getting returned vals)
	int			 i;

	
	/*  check for proper number of arguments */
	if(nrhs<1) 
		Usage();
  
	/* check to make sure input arguments are scalar */
	for (i=0; i<nrhs; i++)
		if ( !mxIsNumeric(prhs[i]) || mxIsEmpty(prhs[i]) ||
			mxIsComplex(prhs[i])  || mxGetN(prhs[i])*mxGetM(prhs[i])!=1 )
			mexErrMsgTxt("Inputs must be scalars.");

	/*  get the scalar input x & y */
	Mode = (int) mxGetScalar(prhs[0]);

	if ((Mode < 0) || (Mode > 3)) {
		mexErrMsgTxt("Mode should be in the range of 0 to 3");
	}

	//////////////////////
	// Halt and Reset Mode
	//////////////////////
	if (Mode == 0) { 
		for (i = 0; i < nCh; i++) {
			GPCTR_Control(iDevice, ulGpctrNum[i], ND_RESET);
		}
		GPCTR_Control(iDevice, ND_COUNTER_7, ND_RESET);

	///////////////////	
	// Initialize Mode
	///////////////////	
	} else if (Mode == 1) { 
		if (nrhs < 2)
			mexErrMsgTxt("Number of channels must be specified when using initialize (#1) mode");

		nCh = (int) mxGetScalar(prhs[1]);
		if ((nCh <= 0) || (nCh > 6)) {
			mexErrMsgTxt("Number of Channel is upto 6");
		}
		// 10/25/01 COPIED FROM MSDS - AF
		for (i = 0; i < nCh; i++) {
			/* Restore buffer mode to SINGLE. */
			// GPCTR_Change_Parameter(iDevice, ulGpctrNum[i], ND_BUFFER_MODE, ND_SINGLE); // Commented out 10/29/01
			/* Reset GPCTR. */
			GPCTR_Control(iDevice, ulGpctrNum[i], ND_RESET);
			// GPCTR_Change_Parameter(iDevice, ulGpctrNum[i], ND_INITIAL_COUNT, 0); // Commented out 10/29/01
		}
		GPCTR_Control(iDevice, ND_COUNTER_7, ND_RESET);
		//

		Set_DAQ_Device_Info(iDevice, ND_DATA_XFER_MODE_GPCTR0, ND_UP_TO_2_DMA_CHANNELS);
		Set_DAQ_Device_Info(iDevice, ND_DATA_XFER_MODE_GPCTR1, ND_UP_TO_2_DMA_CHANNELS);
		Set_DAQ_Device_Info(iDevice, ND_DATA_XFER_MODE_GPCTR7, ND_UP_TO_2_DMA_CHANNELS);
		//Set_DAQ_Device_Info(iDevice, ND_DATA_XFER_MODE_GPCTR0, ND_INTERRUPTS);
		//Set_DAQ_Device_Info(iDevice, ND_DATA_XFER_MODE_GPCTR1, ND_INTERRUPTS);
		//Set_DAQ_Device_Info(iDevice, ND_DATA_XFER_MODE_GPCTR7, ND_INTERRUPTS);
		Set_DAQ_Device_Info(iDevice, ND_DATA_XFER_MODE_GPCTR2, ND_INTERRUPTS);
		Set_DAQ_Device_Info(iDevice, ND_DATA_XFER_MODE_GPCTR3, ND_INTERRUPTS);
		Set_DAQ_Device_Info(iDevice, ND_DATA_XFER_MODE_GPCTR4, ND_INTERRUPTS);
		Set_DAQ_Device_Info(iDevice, ND_DATA_XFER_MODE_GPCTR5, ND_INTERRUPTS);

		/* for trigger */
		GPCTR_Set_Application(iDevice, ND_COUNTER_7, ND_BUFFERED_EVENT_CNT);
		GPCTR_Change_Parameter(iDevice, ND_COUNTER_7, ND_GATE, ND_PFI_10);
		GPCTR_Change_Parameter(iDevice, ND_COUNTER_7, ND_SOURCE, ND_INTERNAL_100_KHZ);
		GPCTR_Change_Parameter(iDevice, ND_COUNTER_7, ND_INITIAL_COUNT, 0);
		GPCTR_Change_Parameter(iDevice, ND_COUNTER_7, ND_BUFFER_MODE, ND_CONTINUOUS); // AF 10/29/01

		/* Using Hardware Trigger - looks by default at pin PFI_10, which is wired to PFI_0 and
		   receives the experimental system's trigger */
		GPCTR_Change_Parameter(iDevice, ND_COUNTER_7, ND_START_TRIGGER,ND_ENABLED);
		GPCTR_Change_Parameter(iDevice, ND_COUNTER_7, ND_START_TRIGGER_POLARITY,ND_LOW_TO_HIGH);
		GPCTR_Config_Buffer(iDevice, ND_COUNTER_7, 0, TrgBuffLen, pulBufferTr);
		

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

			/* Our spike-discriminator produces down pulses!!! */
			GPCTR_Change_Parameter(iDevice, ulGpctrNum[i], ND_GATE_POLARITY, ND_HIGH_TO_LOW); // AF 10/29/01
			GPCTR_Change_Parameter(iDevice, ulGpctrNum[i], ND_COUNTING_SYNCHRONOUS, ND_YES); // AF 10/29/01

			/* Load initial count. */
			GPCTR_Change_Parameter(iDevice, ulGpctrNum[i], ND_INITIAL_COUNT, 0);

			/* Enable double-buffer mode. */
			GPCTR_Change_Parameter(iDevice, ulGpctrNum[i], ND_BUFFER_MODE, ND_DOUBLE);
			//GPCTR_Change_Parameter(iDevice, ulGpctrNum[i], ND_BUFFER_MODE, ND_CONTINUOUS); // AF 10/29/01
			

			/* Using Hardware Trigger for arming the channels */
			GPCTR_Change_Parameter(iDevice, ulGpctrNum[i], ND_START_TRIGGER,ND_ENABLED);
			GPCTR_Change_Parameter(iDevice, ulGpctrNum[i], ND_START_TRIGGER_POLARITY,ND_LOW_TO_HIGH);
			Select_Signal(iDevice, ND_START_TRIGGER, ND_PFI_0,ND_LOW_TO_HIGH);
		
			/* Allocate memory buffer */
			GPCTR_Config_Buffer(iDevice, ulGpctrNum[i], 0, SpkBuffLen, pulBuffer[i]);
		}

        for (i = 0; i < nCh; i++) {
			GPCTR_Control(iDevice, ulGpctrNum[i], ND_PROGRAM);
		}
		GPCTR_Control(iDevice, ND_COUNTER_7, ND_PROGRAM);

		cSeq  = 0;

	///////////////////	
	// Run Mode
	///////////////////	
	} else if (Mode == 2) { 
		static  u32		ret_spk[SpkBuffLen];
		static  u32		ret_trg[TrgBuffLen+2];  // +2 because we wrap it with '0' and MAX_INT
		u32			    ret_spk_len[MAX_CH];
		u32				ret_trg_len;
		int				trg_offset;
		mxArray			*seq_times[MAX_CH];
		double			*seq[MAX_CH], *times[MAX_CH], *ret_status;
	    u32				ulTimeOut = 0;
		u32				new_trg_len, j, watch_val;
		i16				status;

		 // __asm int 3h ; // Setting a breakpoint for debuging (compile with the -g flag!)
		if (nrhs > 1)
			mexWarnMsgTxt("Number of channels argument has no effect in Run (#2) mode.\n");
		plhs[0] = mxCreateCellMatrix(1, nCh);
		if (nlhs > 2) {
			plhs[2] = mxCreateDoubleMatrix(1,nCh+1, mxREAL);
			ret_status = mxGetPr(plhs[2]);
		}
		for (i = 0; i < nCh; i++) {
			/* Read Spike Time on the Buffer */
			/* NOTE: status check removed for spikes, because if 10920 error occurs 
			         spikes are not returned! (AF 10/29/01).
					 Use Mode=3 to extract error info.
			*/
			status = 0; 
			GPCTR_Read_Buffer(iDevice, ulGpctrNum[i], ND_READ_MARK, 0,
				SpkBuffLen, ulTimeOut, &ret_spk_len[i], ret_spk);
			if (status < 0) {
				mexPrintf("ReadBuffer status = %d (attempt to read channel %d)\n", status, i+1);
				if (nlhs > 2)
					ret_status[i] = status;
				ret_spk_len[i] = 0;
			}


			seq_times[i] = mxCreateDoubleMatrix(ret_spk_len[i],2, mxREAL);
			if (ret_spk_len[i] == 0) {
				seq[i] = NULL;
				times[i] = NULL;
			}
			else {
				seq[i]	= mxGetPr(seq_times[i]);
				times[i] = seq[i]+ret_spk_len[i];
				// Copy returned spikes to the second column of the matrix
				for (j=0; j<ret_spk_len[i]; j++)
					times[i][j] = ret_spk[j];
			}
		 }

		/* Read Trigger Times */
		trg_offset = min(cSeq,2);
		ret_trg[0] = 0;
		status = GPCTR_Read_Buffer(iDevice, ND_COUNTER_7, ND_READ_MARK, -1*trg_offset,
			TrgBuffLen, ulTimeOut, &ret_trg_len, ret_trg+1);
		if (status < 0) {
			mexPrintf("ReadBuffer status = %d (attempt to read trigger info)\n", status);
				if (nlhs > 2)
					ret_status[nCh] = status;
		}
		
		ret_trg[ret_trg_len+1] = ULONG_MAX;

		// Normalize spikes and set the returned cell array
		for (i = 0; i < nCh; i++) {
			if (ret_spk_len[i] > 0)
				normalize_spikes(ret_trg, ret_trg_len+2, times[i], ret_spk_len[i], cSeq+1-trg_offset, seq[i]);
			mxSetCell(plhs[0], i, seq_times[i]);
		}

		// Update the value of the current sequence and return it
		new_trg_len = ret_trg_len - trg_offset;
		cSeq += new_trg_len;
		plhs[1] = mxCreateDoubleMatrix(1,1, mxREAL);
		*(mxGetPr(plhs[1])) = cSeq+1;
	

	///////////////////	
	// Test Mode
	///////////////////	
	} else if (Mode == 3) { 
		i16				status;
		u32				watch_val;
		double			*ret_status;
	
		plhs[0] = mxCreateDoubleMatrix(1,nCh+1, mxREAL);
		ret_status = mxGetPr(plhs[0]);
		for (i = 0; i < nCh; i++) {
			status = GPCTR_Watch (iDevice, ulGpctrNum[i], ND_AVAILABLE_POINTS , &watch_val);
			if (status < 0) 
				mexPrintf("ReadBuffer status = %d (channel %d)\n", status, i+1);
			ret_status[i] = status;
		}
		status = GPCTR_Watch (iDevice, ND_COUNTER_7, ND_AVAILABLE_POINTS , &watch_val);
		if (status < 0) 
			mexPrintf("ReadBuffer status = %d (trigger)\n", status);
		ret_status[nCh] = status;
	}
}


void normalize_spikes(u32 *trg,int trg_len, double *spk, int spk_len, int base_trig_count, double *seq)
{
	int trg_pos = 0;
	int spk_pos = 0;

	for (spk_pos = 0; spk_pos < spk_len; spk_pos++) {
	   while (spk[spk_pos] >= trg[trg_pos])
		  trg_pos++;
	   
	   trg_pos--;
	   spk[spk_pos] = (spk[spk_pos] - trg[trg_pos]) * SourceClockPeriod;
	   seq[spk_pos] = base_trig_count + trg_pos;  // -1 +1;
	}
}


void Usage()
{
	mexErrMsgTxt("MSD Usage: Ask Mike Heinz");
}


