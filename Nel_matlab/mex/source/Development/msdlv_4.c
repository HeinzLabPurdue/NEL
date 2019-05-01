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
#define DAQmxErrChk(functionCall) if( DAQmxFailed(error=(functionCall)) ) goto Error; else
#define MAX_CH					6
#define SourceClockPeriod	    0.00001
TaskHandle  taskTrigger = 0, taskSpike1 = 0, taskSpike2 = 0; taskSpike3 = 0; taskSpike4 = 0; taskSpike5 = 0; taskSpike6 = 0;

/************  Headers of other functions ***********/

/*************************************************/

void mexFunction ( int nlhs, mxArray *plhs[], 
        int nrhs, const mxArray *prhs[])
{
    int         error=0;
    int         Mode;
    int         i;
    int32       readSpike1, readSpike2,readTrigger;
    uInt32      dataSpike1[10000], dataSpike2[10000],dataTrigger[1000];
    char        errBuff[2048]={'\0'};
    
    mxArray      *outMatrixTrigger;              /* output matrix */
    mxArray      *outMatrixSpike;                /* output matrix */
    
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
        
        
        /* Create task for spike signals*/
        DAQmxErrChk (DAQmxCreateTask("",&taskSpike1));
        /* Counter channel configuration*/
        DAQmxErrChk (DAQmxCreateCICountEdgesChan(taskSpike1,"/Counter/Ctr0","",DAQmx_Val_Rising,0,DAQmx_Val_CountUp));
        /* Sample source (spike signals)*/
        DAQmxErrChk (DAQmxCfgSampClkTiming(taskSpike1,"/Counter/PFI38",100000.0,DAQmx_Val_Rising,DAQmx_Val_ContSamps,100000));//Shortest possible period between spikes: 10 microS
        
        DAQmxSetCICountEdgesTerm(taskSpike1, "/Counter/Ctr0", "/Counter/100kHzTimebase");
        // DAQmxCfgDigEdgeStartTrig (taskSpike1, "/Counter/PFI0", DAQmx_Val_Rising);
        
        
        DAQmxErrChk (DAQmxCreateTask("",&taskSpike2));
        /* Counter channel configuration*/
        DAQmxErrChk (DAQmxCreateCICountEdgesChan(taskSpike2,"/Counter/Ctr1","",DAQmx_Val_Rising,0,DAQmx_Val_CountUp));
        /* Sample source (spike signals)*/
        DAQmxErrChk (DAQmxCfgSampClkTiming(taskSpike2,"/Counter/PFI34",100000.0,DAQmx_Val_Rising,DAQmx_Val_ContSamps,100000));//Shortest possible period between spikes: 10 microS
        
        DAQmxSetCICountEdgesTerm(taskSpike2, "/Counter/Ctr1", "/Counter/100kHzTimebase");
        // DAQmxCfgDigEdgeStartTrig (taskSpike2, "/Counter/PFI0", DAQmx_Val_Rising);

        
        /*********************************************/
        // DAQmx Start Code
        /*********************************************/
        DAQmxErrChk (DAQmxStartTask(taskTrigger));
        DAQmxErrChk (DAQmxStartTask(taskSpike1));
        DAQmxErrChk (DAQmxStartTask(taskSpike2));
        
        printf("Continuously reading. Press Ctrl+C to interrupt\n");
        printf("It's in Mode 1!\r");
    
    } else if (Mode == 2){
    /***********************************************************/
    // Run mode
    /***********************************************************/
    
        /*******************************************************/
        // DAQmx Read Code
        // Values for spike signals are stored into dataSpike
        // Values for trigger signals are stored into dataTrigger
        /********************************************************/
        DAQmxErrChk (DAQmxReadCounterU32(taskTrigger,-1,0.0,&dataTrigger,1000,&readTrigger,NULL));
        DAQmxErrChk (DAQmxReadCounterU32(taskSpike1,-1,0.0,&dataSpike1,10000,&readSpike1,NULL));
        DAQmxErrChk (DAQmxReadCounterU32(taskSpike2,-1,0.0,&dataSpike2,10000,&readSpike2,NULL));
        

        /*****************************************************/
        // storing values to the output argument of mexFunction
        /*****************************************************/
        /* create the output matrix */
        plhs[0] = mxCreateDoubleMatrix(readTrigger,1,mxREAL);
        plhs[1] = mxCreateDoubleMatrix(readSpike1,1,mxREAL);
        /* get a pointer to the real data in the output matrix */
        outMatrixTrigger = mxGetPr(plhs[0]);
        outMatrixSpike = mxGetPr(plhs[1]);
        /* assign the data read to the output matrix*/
        outMatrixTrigger = dataTrigger;
        outMatrixSpike = dataSpike1;
        
        // printing values for testing purposes
        printf("\rAcquired %d spike samples on channel 1",(int)readSpike1);
        printf("\rSpike data:");
        for (i=0; i<(int)readSpike1; i++) {
            printf("|%d",(int) dataSpike1[i]);
        }
        
        // printing values for testing purposes
        printf("\rAcquired %d spike samples on channel 2",(int)readSpike2);
        printf("\rSpike data:");
        for (i=0; i<(int)readSpike2; i++) {
            printf("|%d",(int) dataSpike2[i]);
        }
        
        printf("\rAcquired %d trigger samples",(int)readTrigger);
        printf("\rSpike data:");
        for (i=0; i<(int)readTrigger; i++) {
            printf("|%d",(int) dataTrigger[i]);
        }
        printf("It's in Mode 2!\r");
    }
    
Error:
    puts("");
	if (DAQmxFailed(error)) {
		DAQmxGetExtendedErrorInfo(errBuff, 2048);
		if (taskSpike1 != 0 || taskTrigger != 0) {
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






