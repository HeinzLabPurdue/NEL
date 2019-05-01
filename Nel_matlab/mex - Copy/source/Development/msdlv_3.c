//
//  msdl_v3.0.c
//
//  Function: count buffered digital events on 2 Counter Input Channels
//  A MEX file lets you call a C function from MATLAB.
//  Created by BaoAgudemu on 2/1/17.
//
//  MSD Usage:
//	HALT/RESET:		msld(0);
//	INIT:			msdl(1,Nch);
//	RUN:			[spk index msdl_status] = msdl(2);
//	TRIG_INCREMENT:	index_increment=msdl(4);
//  To test the program, build binary MEX file first, and then use mexFunction as a MATLAB function to assign the output to variables you defined in script or command window

#include <stdio.h>
#include <NIDAQmx.h>
#include "mex.h"
#define DAQmxErrChk(functionCall) if( DAQmxFailed(error=(functionCall)) ) goto Error; else

/************  Headers of other functions ***********/

/*************************************************/

void mexFunction ( int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    int         error=0;
    int         Mode;
    int         i;
    TaskHandle  taskTrigger=0, taskSpike=0;
    int32       readSpike, readTrigger;
    uInt32      dataSpike[10000], dataTrigger[1000];
    char        errBuff[2048]={'\0'};
    
    double      *outMatrixTrigger;              /* output matrix */
    double      *outMatrixSpike;                /* output matrix */
    
    // mex input checking
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
    // DAQmx Configure Code
    // A task can contain only one counter input channel.
    // To read from multiple counters simultaneously, use a separate task for each counter.
    /*********************************************/
    /* Creat task for trigger signals*/
    DAQmxErrChk (DAQmxCreateTask("",&taskTrigger));
    /* Counter channel configuration*/
    DAQmxErrChk (DAQmxCreateCICountEdgesChan(taskTrigger,"Counter/ctr7","",DAQmx_Val_Rising,0,DAQmx_Val_CountUp));
    /* Sample source (trigger signals)*/
    DAQmxErrChk (DAQmxCfgSampClkTiming(taskTrigger,"/Counter/PFI10",1000.0,DAQmx_Val_Rising,DAQmx_Val_ContSamps,1000));//Shortest possible period for trigger: 1 mS
    
    /* Creat task for spike signals*/
    DAQmxErrChk (DAQmxCreateTask("",&taskSpike));
    /* Counter channel configuration*/
    DAQmxErrChk (DAQmxCreateCICountEdgesChan(taskSpike,"Counter/ctr0","",DAQmx_Val_Rising,0,DAQmx_Val_CountUp));
    /* Sample source (spike signals)*/
    DAQmxErrChk (DAQmxCfgSampClkTiming(taskSpike,"/Counter/PFI38",10000.0,DAQmx_Val_Rising,DAQmx_Val_ContSamps,10000));//Shortest possible period for spike: 0.1 mS, taking hyperexcitability into consideration 
    
    /*********************************************/
    // DAQmx Start Code
    /*********************************************/
    DAQmxErrChk (DAQmxStartTask(taskTrigger));
    DAQmxErrChk (DAQmxStartTask(taskSpike));
    printf("Continuously reading. Press Ctrl+C to interrupt\n");
    
//     while( 1 ) {
        /*******************************************************/
        // DAQmx Read Code
        // Values for spike signals are stored into dataSpike
        // Values for trigger signals are stored into dataTrigger
        /********************************************************/
        DAQmxErrChk (DAQmxReadCounterU32(taskTrigger,-1,0.0,dataTrigger,1000,&readTrigger,NULL));
        DAQmxErrChk (DAQmxReadCounterU32(taskSpike,-1,0.0,dataSpike,10000,&readSpike,NULL));
        
        /*****************************************************/
        // storing values to the output argument of mexFunction
        /*****************************************************/
        /* create the output matrix */
        plhs[0] = mxCreateDoubleMatrix(1,readTrigger,mxREAL);
        plhs[1] = mxCreateDoubleMatrix(1,readSpike,mxREAL);
        /* get a pointer to the real data in the output matrix */
        outMatrixTrigger = mxGetPr(plhs[0]);
        outMatrixSpike = mxGetPr(plhs[1]);
        /* assign the data read to the output matrix*/
        outMatrixTrigger = dataTrigger;
        outMatrixSpike = dataSpike;
        
        // printing values for testing purposes
        printf("\rAcquired %d spike samples",(int)readSpike);
        printf("\rSpike data:");
        for (i=0; i<(int)readSpike; i++) {
            printf("|",(int) dataSpike[i]);
        }
        
        printf("\rAcquired %d trigger samples",(int)readTrigger);
        printf("\rSpike data:");
        for (i=0; i<(int)readTrigger; i++) {
            printf("|",(int) dataTrigger[i]);
        }
        
        //fflush(stdout);//override function for transfering the user's buffer to kernel even when the user's buffer hasn't filled up
//     }
    
Error:
    puts("");
    if( DAQmxFailed(error) )
        DAQmxGetExtendedErrorInfo(errBuff,2048);
    if( taskSpike!=0 || taskTrigger!=0) {
        /*********************************************/
        // DAQmx Stop Code
        /*********************************************/
        DAQmxStopTask(taskTrigger);
        DAQmxClearTask(taskTrigger);
        DAQmxStopTask(taskSpike);
        DAQmxClearTask(taskSpike);
    }
    if( DAQmxFailed(error) )
        printf("DAQmx Error: %s\n",errBuff);
    printf("End of program, press Enter key to quit\n");
    getchar();
}






