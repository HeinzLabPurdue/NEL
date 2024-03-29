/*********************************************************************
 *
 * d2av_2.c
 *
 * Created by BaoAgudemu on 2/5/17
 * mex file for D/A output from PCIe-6341, playing out sound files and changing their sampling rate.
 *
 * Pin Connection Information:
 *   The analog output signal(s) will be available at AO channel 0 and/or 1.
 *	 Trigger signal should be connected to PFI6.
 *
 *
 * INPUT ARGUMENT(S), depending on call mode:
 *	(iMode=0)
 *	(iMode=1, dRequestedUpdateRate_Hz, <samples matrix>)
 *
 *********************************************************************/

#include <stdio.h>
#include "mex.h"
#include <stdlib.h>     /* malloc(), free(), strtoul() */
#include <math.h>
#include <NIDAQmx.h>
#include <time.h>

/***********************************************************************
 * Global declaritions
//  ***********************************************************************/
#define PI	3.1415926535

/***********************************************************************
 * Function declaritions
 ***********************************************************************/


/***********************************************************************
 * Main Function
 ***********************************************************************/

void mexFunction( int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]){
    /***********************************************************************
     * Local declaritions
     ***********************************************************************/
    TaskHandle  taskAO;
    float64     data[5000];
    int         i;
    int         Mode;
    int32       error=0;
    char        errBuff[2048]={'\0'};
    double      *inMatrix0, *inMatrix1;               /* Nx1 input matrix */
    int32         nrows = 0;                   /* size of matrix */
    int16         iNumChans;
    double *   wavBuffer0, *wavBuffer1, *commonBuffer;
    float64    RequestedUpdateRate_Hz;
    double *status;
    double *retVals;
    static double actualSamplingRate;
    /******************** Setting up MATLAB mex array *********************/
    /**********************************************************************/
    // Setup a matrix for outputting error codes:
    plhs[0] = mxCreateDoubleMatrix(16,1, mxREAL);  // used for statCodes (MH/GE)
    plhs[1] = mxCreateDoubleMatrix(12,1, mxREAL);  // used for retVals (MH/GE)
    status = mxGetPr(plhs[0]);
    retVals = mxGetPr(plhs[1]);
    
     
    
    /* get the value of scalar input for mode */
    Mode = (int) mxGetScalar(prhs[0]);
    
    if ((Mode < 0) || (Mode > 4)) {
        mexErrMsgTxt ("Mode should be in the range of 0 to 4");
    }
    
    /*********************************************
     * Halt and reset mode
     *********************************************/
    if (Mode == 0) {
        //reset the DAQ device/
        status[0] = DAQmxClearTask(taskAO);
        retVals[0] = DAQmxFailed(status[0]);
        status[1] = DAQmxResetDevice("DAQ");
        retVals[1] = DAQmxFailed(status[1]);
        
    } else if (Mode == 1){
        double *retSamplingRate;
        
        RequestedUpdateRate_Hz = (float64) mxGetScalar(prhs[1]);   // input argument
        inMatrix0 = mxGetPr(prhs[2]);

        nrows = (int32)mxGetM(prhs[2]);// row number
        inMatrix1 = &(inMatrix0[nrows]);
        iNumChans = (int16) mxGetN(prhs[2]);//number of columns, channels
        
        
        
        wavBuffer0 = mxCalloc(nrows, sizeof(double));
        wavBuffer1 = mxCalloc(nrows, sizeof(double));
        commonBuffer = mxCalloc(2*nrows, sizeof(double));
        
        if (iNumChans == 1){
            for (i=0;i<nrows;i++){
                wavBuffer0[i]=inMatrix0[i];
            }
        } else if (iNumChans==2){
            for (i=0;i<nrows;i++){
                wavBuffer0[i]=inMatrix0[i];
            }
            for (i=0;i<nrows;i++){
                wavBuffer1[i]=inMatrix1[i];
            }
            
            for (i = 0; i < nrows; i++) {
                
                commonBuffer[2*i] = wavBuffer0[i];
                commonBuffer[2*i + 1] = wavBuffer1[i];
            }
        }
        
        /*********************************************/
        // DAQmx Configure Code
        /*********************************************/
        status[0] = DAQmxCreateTask("",&taskAO);
        retVals[0] = DAQmxFailed(status[0]);
        status[1] = DAQmxCreateAOVoltageChan(taskAO,"/DAQ/ao0","",-5.0,5.0,DAQmx_Val_Volts,NULL);//is the reference of the daq board "DAQ"? A list of physical channels can be added, that is, a task can be configured to have multiple AO channels
        retVals[1] = DAQmxFailed(status[1]);
        if (iNumChans == 2){
            status[2] = DAQmxCreateAOVoltageChan(taskAO,"/DAQ/ao1","",-5.0,5.0,DAQmx_Val_Volts,NULL);//is the reference of the daq board "DAQ"? A list of physical channels can be added, that is, a task can be configured to have multiple AO channels
            retVals[2] = DAQmxFailed(status[2]); 
        }
        status[3] = DAQmxSetSampClkTimebaseSrc(taskAO,"/DAQ/100MHzTimebase");
        retVals[3] = DAQmxFailed(status[3]);
        status[4] = DAQmxCfgSampClkTiming(taskAO,"",RequestedUpdateRate_Hz,DAQmx_Val_Rising,DAQmx_Val_FiniteSamps,nrows);
        retVals[4] = DAQmxFailed(status[4]);
        status[5] = DAQmxCfgDigEdgeStartTrig(taskAO,"/DAQ/PFI6",DAQmx_Val_Rising);
        retVals[5] = DAQmxFailed(status[5]);
        status[6] = DAQmxSetStartTrigRetriggerable(taskAO,1);
        retVals[6] = DAQmxFailed(status[6]);
        
        /*********************************************/
        // DAQmx Write Code
        /*********************************************/
        if (iNumChans == 1){
            status[7] = DAQmxWriteAnalogF64(taskAO,nrows,0,0,DAQmx_Val_GroupByChannel, wavBuffer0,NULL,NULL);// data: the array of 64-bit samples to write to the task
            retVals[7] = DAQmxFailed(status[7]); 
        }else if (iNumChans == 2){
            status[8] = DAQmxWriteAnalogF64(taskAO,nrows,0,0,DAQmx_Val_GroupByScanNumber, commonBuffer,NULL,NULL);
            retVals[8] = DAQmxFailed(status[8]); 
        }
        /*********************************************/
        // DAQmx Start Code
        /*********************************************/
        status[9] = DAQmxStartTask(taskAO);
        retVals[9] = DAQmxFailed(status[9]);
        
        // return the actual sampling rate too
        
        status[10] = DAQmxGetSampClkRate(taskAO, &actualSamplingRate);
        retVals[10] = DAQmxFailed(status[10]);
        
        plhs[2] = mxCreateDoubleMatrix(1,1, mxREAL);
        retSamplingRate = mxGetPr(plhs[2]);
        retSamplingRate[0] = actualSamplingRate;
        
        
    } else if (Mode == 2) {
        //reset the DAQ device
        status[0] = DAQmxClearTask(taskAO);
        retVals[0] = DAQmxFailed(status[0]);
        status[1] = DAQmxResetDevice("DAQ");
        retVals[1] = DAQmxFailed(status[1]);
    } else if (Mode == 3){
        double *retSamplingRate;
        RequestedUpdateRate_Hz = (float64) mxGetScalar(prhs[1]);   // input argument
        
        status[0] = DAQmxCreateTask("",&taskAO);
        retVals[0] = DAQmxFailed(status[0]);
        status[1] = DAQmxCreateAOVoltageChan(taskAO,"/DAQ/ao0","",-5.0,5.0,DAQmx_Val_Volts,NULL);
        retVals[1] = DAQmxFailed(status[1]);
        status[2] = DAQmxSetSampClkTimebaseSrc(taskAO,"/DAQ/100MHzTimebase");
        retVals[2] = DAQmxFailed(status[2]);
        status[3] = DAQmxCfgSampClkTiming(taskAO,"",RequestedUpdateRate_Hz,DAQmx_Val_Rising,DAQmx_Val_FiniteSamps,nrows);
        retVals[3] = DAQmxFailed(status[3]);
        status[4] = DAQmxGetSampClkRate(taskAO, &actualSamplingRate);
        retVals[4] = DAQmxFailed(status[4]);
        
        plhs[2] = mxCreateDoubleMatrix(1,1, mxREAL);
        retSamplingRate = mxGetPr(plhs[2]);
        retSamplingRate[0] = actualSamplingRate;
        
        status[5] =  DAQmxClearTask(taskAO);
        retVals[5] = DAQmxFailed(status[5]);
//         status[6] = DAQmxResetDevice("DAQ");
//         retVals[6] = DAQmxFailed(status[6]);
    }
}

