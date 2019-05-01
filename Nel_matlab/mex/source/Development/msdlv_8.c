//
//  msdl_v7.0.c
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
#include <stdlib.h> 
#include <NIDAQmx.h>
#include "mex.h"
#include "matrix.h"
#include <math.h>
#define DAQmxErrChk(functionCall) if( DAQmxFailed(error=(functionCall)) ) goto Error; else
#define MAX_CH					6
// #define SourceClockPeriod	    0.00001
TaskHandle  taskTrigger = 0;
TaskHandle  taskSpike[6] = {0,0,0,0,0,0};
char  *physicalChannel[6] = {"/Counter/PFI38","/Counter/PFI34","/Counter/PFI30","/Counter/PFI26","/Counter/PFI22","/Counter/PFI18"};
char  *channelName[6] = {"/Counter/Ctr0", "/Counter/Ctr1", "/Counter/Ctr2","/Counter/Ctr3","/Counter/Ctr4","/Counter/Ctr5"};
char  *armName[6] = {"/Counter/Ctr0ArmStartTrigger", "/Counter/Ctr1ArmStartTrigger", "/Counter/Ctr2ArmStartTrigger","/Counter/Ctr3ArmStartTrigger","/Counter/Ctr4ArmStartTrigger","/Counter/Ctr5ArmStartTrigger"};
int   nCh = 1;
static double firstTrigger = 0;

/************  Headers of other functions ***********/
void normalize_spikes(double *trg, double *spk, int spk_len, int base_trig_count, double *seq);
/*************************************************/

void mexFunction ( int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    int         error=0;
    int         Mode;
    int         i;
   
    char        errBuff[2048]={'\0'};
    
    static int         cSeq = 0;
    
    char        startTrigger[256];
    
    
    
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
        DAQmxStopTask(taskTrigger);
        DAQmxClearTask(taskTrigger);
        for (i = 0; i<nCh; i++) {
            DAQmxStopTask(taskSpike[i]);
            DAQmxClearTask(taskSpike[i]);
        }
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
        
        //reset the counter device/
        DAQmxStopTask(taskTrigger);
        DAQmxClearTask(taskTrigger);
        for (i = 0; i<nCh; i++) {
            DAQmxStopTask(taskSpike[i]);
            DAQmxClearTask(taskSpike[i]);
        }
        DAQmxResetDevice("Counter");

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
        DAQmxErrChk (DAQmxCfgSampClkTiming(taskTrigger,"/Counter/PFI10",100000.0,DAQmx_Val_Rising,DAQmx_Val_ContSamps,100000));//Shortest possible period for trigger: 1 mS
        DAQmxSetCICountEdgesTerm(taskTrigger, "/Counter/Ctr7", "/Counter/10MHzRefClock");
        
        DAQmxErrChk (DAQmxSetArmStartTrigType(taskTrigger,DAQmx_Val_DigEdge));
        DAQmxErrChk (DAQmxSetDigEdgeArmStartTrigSrc(taskTrigger,"/Counter/PFI0"));
        DAQmxErrChk (DAQmxSetDigEdgeArmStartTrigEdge(taskTrigger,DAQmx_Val_Rising));
        
        
        for (i = 0; i<nCh; i++) {
            /* Create task for spike signals*/
            DAQmxErrChk (DAQmxCreateTask("",&taskSpike[i]));
            /* Counter channel configuration*/
            DAQmxErrChk (DAQmxCreateCICountEdgesChan(taskSpike[i],channelName[i],"",DAQmx_Val_Rising,0,DAQmx_Val_CountUp));
            /* Sample source (spike signals)*/
            DAQmxErrChk (DAQmxCfgSampClkTiming(taskSpike[i],physicalChannel[i],100000.0,DAQmx_Val_Rising,DAQmx_Val_ContSamps,100000));//Shortest possible period between spikes: 10 microS
            DAQmxSetCICountEdgesTerm(taskSpike[i], channelName[i], "/Counter/10MHzRefClock");
            
            DAQmxErrChk (DAQmxSetArmStartTrigType(taskSpike[i],DAQmx_Val_DigEdge));
            DAQmxErrChk (DAQmxSetDigEdgeArmStartTrigSrc(taskSpike[i],"/Counter/PFI0"));
            DAQmxErrChk (DAQmxSetDigEdgeArmStartTrigEdge(taskSpike[i],DAQmx_Val_Rising));
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
        int32       readTrigger;
        int32       readTrigger_new;
        int32       readSpike[6]={0,0,0,0,0,0};
        double      dataTrigger[1000+2];
        double      dataSpike[6][100000];
        int i,j, trg_offset;
        mxArray	     *seq_times[MAX_CH];
        double	     *seq[MAX_CH], *times[MAX_CH];
        
        if (nrhs > 1)
            mexWarnMsgTxt("Number of channels argument has no effect in Run (#2) mode.\n");
        
        plhs[0] = mxCreateCellMatrix(1, nCh);
        
        //reading trigger, and wrap the trigger data array with '0' and 'ULONG_MAX'
        trg_offset = min(cSeq,2);
        dataTrigger[0] = firstTrigger;
        DAQmxReadCounterF64 (taskTrigger, -1, 0.0, &dataTrigger[1], -1, &readTrigger, NULL);///???ULONG_MAX
        dataTrigger[readTrigger+1] = ULONG_MAX;
        
        //storing spike data to the second column of a (# of spikes) by 2 matrix
        for (i=0; i<nCh; i++) {
            DAQmxErrChk (DAQmxReadCounterF64(taskSpike[i],-1,0.0,&dataSpike[i],-1,&readSpike[i],NULL));
            seq_times[i] = mxCreateDoubleMatrix(readSpike[i],2, mxREAL);
            if (readSpike[i] == 0) {
                seq[i] = NULL;
                times[i] = NULL;
            }
            else {
                seq[i] = mxGetPr(seq_times[i]);
                times[i] = seq[i]+readSpike[i];
                for (j=0; j<(int)readSpike[i];j++)
                    times[i][j] = dataSpike[i][j];
            }
        }
        
        // Calculate spike times relative to trigger time and set the returned cell array
        for (i=0; i<nCh; i++){
            if (readSpike[i] > 0)
                normalize_spikes(dataTrigger,times[i],readSpike[i],cSeq+1-trg_offset,seq[i]);
            mxSetCell(plhs[0], i, seq_times[i]);
        }
        
        // Update the value of the current sequence and return it
        firstTrigger+=dataTrigger[readTrigger];
        readTrigger_new = readTrigger - trg_offset;
        cSeq += readTrigger_new;
        plhs[1] = mxCreateDoubleMatrix(1,1, mxREAL);
        *(mxGetPr(plhs[1])) = cSeq+1;
        
        // printing values for testing purposes
//         for (i=0; i<nCh; i++) {
//             printf("\rAcquired %d spike samples on channel %d",(int)readSpike[i],i);
//         }
//         
//         printf("\rAcquired %d trigger samples",(int)readTrigger);
//         printf("It's in Mode 2!\r");
    }
    
    Error:
        puts("");
        if (DAQmxFailed(error)) {
            DAQmxGetExtendedErrorInfo(errBuff, 2048);
            /*********************************************/
            // DAQmx Stop Code
            /*********************************************/
            DAQmxStopTask(taskTrigger);
            DAQmxClearTask(taskTrigger);
            for (i = 0; i<nCh; i++) {
                DAQmxStopTask(taskSpike[i]);
                DAQmxClearTask(taskSpike[i]);
            }
            DAQmxResetDevice("Counter");
            printf("DAQmx Error: %s\n",errBuff);
            printf("End of program, press Enter key to quit\n");
            getchar();
        }
        
}

void normalize_spikes(double *trg, double *spk, int spk_len, int base_trig_count, double *seq)
{
    int trg_pos = 0;
    int spk_pos = 0;
    double SourceClockPeriod = 0.0000001;
    
    for (spk_pos = 0; spk_pos < spk_len; spk_pos++) {
        // Find the closest trigger after the first spike
        while (spk[spk_pos] >= trg[trg_pos])
            trg_pos++;
        // Subtracting one from the position is the trigger corresponding to the current spike
        trg_pos--;
        // Calculating spike time relative to the corresponding trigger  
        spk[spk_pos] = (spk[spk_pos] - trg[trg_pos]) * SourceClockPeriod;
        // "base_trig_count" contains "cSeq+1-trg_offset", where cSeq is the current sequence number, which is reset during initialization. If another "run" mode is executed without "reset" mode, the line number should continue from previous value
        seq[spk_pos] = base_trig_count + trg_pos;  // -1 +1;
    }
}







