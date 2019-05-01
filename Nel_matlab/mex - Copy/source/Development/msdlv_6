//
//  msdl_v4.0.c
//
//  Function: count and time-stamp buffered digital events on 2 Counter Input Channels
//  A MEX file lets you call a C function from MATLAB.
//  Created by BaoAgudemu on 2/3/17.
//
//  MSD Usage:
//	HALT/RESET:		msld(0);
//	INIT:			msdl(1,Nch);
//	RUN:			[spk index msdl_status] = msdl(2);
//	TRIG_INCREMENT:	index_increment = msdl(4);
//  To test the program, build binary MEX file first, and then use mexFunction as a MATLAB function to assign the output to variables you defined in script or command window

#include <stdio.h>
#include <NIDAQmx.h>
#include "mex.h"
#include "matrix.h"
#define DAQmxErrChk(functionCall) if( DAQmxFailed(error=(functionCall)) ) goto Error; else
#define MAX_CH					6
#define SourceClockPeriod	    0.00001
TaskHandle  taskTrigger = 0;
TaskHandle  taskSpike[6] = {0,0,0,0,0,0};
char  *physicalChannel[6] = {"/Counter/PFI38","/Counter/PFI34","/Counter/PFI30","/Counter/PFI26","/Counter/PFI22","/Counter/PFI18"};
char  *channelName[6] = {"/Counter/Ctr0", "/Counter/Ctr1", "/Counter/Ctr2","/Counter/Ctr3","/Counter/Ctr4","/Counter/Ctr5"};        
// TaskHandle  taskSpike[6] = {taskSpike1,taskSpike2,taskSpike3,taskSpike4,taskSpike5,taskSpike6};

int         nCh = 1;
int         cSeq = 0;

/************  Headers of other functions ***********/
//void normalize_spikes(double *seq,int32 readSpike, float64 dataSpike);
void normalize_spikes(double *trg,int trg_len, double *spk, int spk_len, int base_trig_count, double *seq);
/*************************************************/

void mexFunction ( int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    int         error=0;
    int         Mode;
    int         i;
    int32       readTrigger;
    int32       readTrigger_new;
    int32       readSpike[6]={0,0,0,0,0,0};
    double      dataTrigger[1000+2];
    double      dataSpike[6][100000];
    char        errBuff[2048]={'\0'};

//  mxArray     *outMatrixTrigger;              /* output matrix */
//  double      *outMatrixSpike;                /* output matrix */
    
    /*********************************************/
    // mex input checking
    /*********************************************/
    
     /*  check for proper number of input arguments */
    if  (nrhs<1)
        mexErrMsgTxt("MSD Usage:: HALT/RESET: msld(0); INIT: msdl(1,Nch); RUN: [spk index msdl_status] = msdl(2); TRIG_INCREMENT: incr=msdl(4)");
    
    /* check to make sure input arguments are scalar */
    for (i=0; i<nrhs; i++)
        if ( !mxIsNumeric(prhs[i]) || mxIsEmpty(prhs[i]) ||
            mxIsComplex(prhs[i])  || mxGetN(prhs[i])*mxGetM(prhs[i])!=1 )
            mexErrMsgTxt("Inputs must be scalars.");
    
    /* get the value of scalar input for mode */
    Mode = (int) mxGetScalar(prhs[0]);
    
    if ((Mode < 0) || (Mode > 4)) {
        mexErrMsgTxt ("Mode should be in the range of 0 to 4");
    }
    /*********************************************/
    // Halt and reset mode
    /*********************************************/
    
    if (Mode == 0) {
        //reset the counter device/
        DAQmxResetDevice("Counter");
        printf("It's in Mode 0!\r");
    } else if (Mode == 1){
    /*************************************************/
    // Initialization mode
    /*************************************************/
        
        /**************************************************************/
        // Make sure the # of channels is passed as 2nd input in mode 1
        /**************************************************************/
        
        if (nrhs < 2)
            mexErrMsgTxt("Number of channels must be specified when using initialize (#1) mode");
        
        nCh = (int) mxGetScalar(prhs[1]);
        if ((nCh <= 0) || (nCh > 6)) {
            mexErrMsgTxt("Number of Channel is upto 6");
        }
        
        /*********************************************/
        // DAQmx Configure Code
        // A task can contain only one counter input channel.
        // To read from multiple counters simultaneously, use a separate task for each counter.
        /*********************************************/
        /* Creat task for trigger signals*/
        DAQmxErrChk (DAQmxCreateTask("",&taskTrigger));
      
        /* Counter channel configuration*/
        DAQmxErrChk (DAQmxCreateCICountEdgesChan(taskTrigger,"/Counter/Ctr7","",DAQmx_Val_Rising,0,DAQmx_Val_CountUp));
        /* Sample source (trigger signals)*/
        DAQmxErrChk (DAQmxCfgSampClkTiming(taskTrigger,"/Counter/PFI10",1000.0,DAQmx_Val_Rising,DAQmx_Val_ContSamps,1000));//Shortest possible period for trigger: 1 mS
        
        DAQmxSetCICountEdgesTerm(taskTrigger, "/Counter/Ctr7", "/Counter/100kHzTimebase");
        
        // DAQmxSetCICountEdgesCountResetActiveEdge(taskTrigger, "/Counter/PFI0", DAQmx_Val_Rising);
        // DAQmxSetStartTrigRetriggerable(taskTrigger, TRUE);
        // DAQmxCfgDigEdgeStartTrig (taskTrigger, "/Counter/PFI0", DAQmx_Val_Rising);
        
        for (i = 0; i<nCh; i++) {
            /* Create task for spike signals*/
            DAQmxErrChk (DAQmxCreateTask("",&taskSpike[i]));
            /* Counter channel configuration*/
            DAQmxErrChk (DAQmxCreateCICountEdgesChan(taskSpike[i],channelName[i],"",DAQmx_Val_Rising,0,DAQmx_Val_CountUp));
            /* Sample source (spike signals)*/
            DAQmxErrChk (DAQmxCfgSampClkTiming(taskSpike[i],physicalChannel[i],100000.0,DAQmx_Val_Rising,DAQmx_Val_ContSamps,100000));//Shortest possible period between spikes: 10 microS
            
            DAQmxSetCICountEdgesTerm(taskSpike[i], channelName[i], "/Counter/100kHzTimebase");
            // DAQmxCfgDigEdgeStartTrig (taskSpike1, "/Counter/PFI0", DAQmx_Val_Rising);
        }
        
        /*********************************************/
        // DAQmx Start Code
        /*********************************************/
        DAQmxErrChk (DAQmxStartTask(taskTrigger));
        for (i=0; i<nCh; i++) {
            DAQmxErrChk (DAQmxStartTask(taskSpike[i]));
        }
        
        cSeq  = 0;
        
        printf("Continuously reading. Press Ctrl+C to interrupt\n");
        printf("It's in Mode 1!\r");
    
    } else if (Mode == 2){
    /***********************************************************/
    // Run mode
        /***********************************************************/
        int i,j, trg_offset;
        mxArray	     *seq_times[MAX_CH];
        double       *outMatrixSpike[MAX_CH]; 
        double       *outMatrixTrigger;
        double	     *seq[MAX_CH], *times[MAX_CH];

        if (nrhs > 1)
            mexWarnMsgTxt("Number of channels argument has no effect in Run (#2) mode.\n");

        plhs[0] = mxCreateCellMatrix(1, nCh);
        
//         //send trigger values to the first output
//         DAQmxReadCounterF64 (taskTrigger, -1, 0.0, &dataTrigger, -1, &readTrigger, NULL);
//         plhs[0] = mxCreateDoubleMatrix(readTrigger,1, mxREAL);
//         outMatrixTrigger = mxGetPr(plhs[0]);
//         for (j=0; j<(int)readTrigger;j++){
//             outMatrixTrigger[j] = dataTrigger[j];
//         }
        
        //reading trigger, and wrap the trigger data array with '0' and 'ULONG_MAX'
        trg_offset = min(cSeq,2);
        dataTrigger[0] = 0;
        DAQmxReadCounterF64 (taskTrigger, -1, 0.0, &dataTrigger[1], -1, &readTrigger, NULL);///???ULONG_MAX
        dataTrigger[readTrigger+1] = ULONG_MAX;
        
        //storing spike data to the second column of a (# of spikes) by 2 matrix
        for (i=0; i<nCh; i++) {
            DAQmxErrChk (DAQmxReadCounterF64(taskSpike[i],-1,0.0,&dataSpike[i],-1,&readSpike[i],NULL));
            seq_times[i] = mxCreateDoubleMatrix(readSpike[i],2, mxREAL);
            seq[i] = mxGetPr(seq_times[i]);
            times[i] = seq[i]+readSpike[i];
            for (j=0; j<(int)readSpike[i];j++)
               times[i][j] = dataSpike[i][j];
        }
        
        // Calculate spike times relative to trigger time and set the returned cell array
        for (i=0; i<nCh; i++){
            normalize_spikes(dataTrigger,readTrigger+2,times[i],readSpike[i],cSeq+1-trg_offset,seq[i]);
            mxSetCell(plhs[0], i, seq_times[i]);
        }
        
        // Update the value of the current sequence and return it
		readTrigger_new = readTrigger - trg_offset;
		cSeq += readTrigger_new;
		plhs[1] = mxCreateDoubleMatrix(1,1, mxREAL);
		*(mxGetPr(plhs[1])) = cSeq+1;
        
        // printing values for testing purposes
        for (i=0; i<nCh; i++) {
            printf("\rAcquired %d spike samples on channel %d",(int)readSpike[i],i);
//             printf("\rSpike data:");
//             for (j=0; j<(int)readSpike[i]; j++) {
//                 printf("|%d",(int) dataSpike[i][j]);
//             }
        }
        
        printf("\rAcquired %d trigger samples",(int)readTrigger);
//         printf("\rSpike data:");
//         for (i=0; i<(int)readTrigger; i++) {
//             printf("|%d",(int) dataTrigger[i]);
//         }
        printf("It's in Mode 2!\r");
    }
    
Error:
    puts("");
	if (DAQmxFailed(error)) {
		DAQmxGetExtendedErrorInfo(errBuff, 2048);
		if (taskSpike[i] != 0 || taskTrigger != 0) {
			/*********************************************/
			// DAQmx Stop Code
			/*********************************************/
// 			DAQmxStopTask(taskTrigger);
// 			DAQmxClearTask(taskTrigger);
// 			DAQmxStopTask(taskSpike1);
// 			DAQmxClearTask(taskSpike1);
            DAQmxResetDevice("Counter");
		}
		printf("DAQmx Error: %s\n",errBuff);
        printf("End of program, press Enter key to quit\n");
        getchar();
	}
        
}

void normalize_spikes(double *trg,int trg_len, double *spk, int spk_len, int base_trig_count, double *seq)
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





