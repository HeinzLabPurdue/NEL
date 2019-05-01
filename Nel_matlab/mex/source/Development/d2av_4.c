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
***********************************************************************/
#define DAQmxErrChk(functionCall) if( DAQmxFailed(error=(functionCall)) ) goto Error; else
#define PI	3.1415926535
/***********************************************************************
* Function declaritions
***********************************************************************/
// int32 CVICALLBACK DoneCallback(TaskHandle taskHandle, int32 status, void *callbackData);
/***********************************************************************
* Main Function
***********************************************************************/

void mexFunction( int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]){
    /***********************************************************************
     * Local declaritions
     ***********************************************************************/
    TaskHandle  taskAO=0;
    float64     data[5000];
    int         i;
    int         Mode;
    
    int       sr = 100000;
    int32       error=0;
    char        errBuff[2048]={'\0'};
    double      *inMatrix;               /* Nx1 input matrix */
    size_t      nrows = 0;                   /* size of matrix */
    double dataWav[10];
    
    for(i=0;i<5000;i++)
        data[i] = sin(2.0*(double)PI*1000*((double)i/(double)sr));
    
    inMatrix = mxGetPr(prhs[1]);
    nrows = mxGetM(prhs[1]);
    
    
    
    for (i=0;i<10;i++){
        dataWav[i]=inMatrix[i];
    }
    
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
        DAQmxStopTask(taskAO);
        DAQmxClearTask(taskAO);
        DAQmxResetDevice("DAQ");
        printf("It's in Mode 0!\r");
        
    } else if (Mode == 1){
    /*********************************************/
    // DAQmx Configure Code
    /*********************************************/
    DAQmxErrChk (DAQmxCreateTask("",&taskAO));
    DAQmxErrChk (DAQmxCreateAOVoltageChan(taskAO,"/DAQ/ao0","",-5.0,5.0,DAQmx_Val_Volts,NULL));//is the reference of the daq board "DAQ"? A list of physical channels can be added, that is, a task can be configured to have multiple AO channels
    DAQmxErrChk (DAQmxCfgSampClkTiming(taskAO,"",sr,DAQmx_Val_Rising,DAQmx_Val_FiniteSamps,5000));// Internal clock
    DAQmxErrChk (DAQmxCfgDigEdgeStartTrig(taskAO,"/DAQ/PFI6",DAQmx_Val_Rising));
    DAQmxErrChk (DAQmxSetStartTrigRetriggerable(taskAO,1));
//     DAQmxErrChk (DAQmxCfgSampClkTiming(taskAO,"",sr,DAQmx_Val_Rising,DAQmx_Val_ContSamps,sr));// To use the internal clock of the device, use NULL or use OnboardClock for second parameter
    //DAQmxSetCICountEdgesTerm(taskAO, "/DAQ/ao0", "/Counter/100kHzTimebase");
//     DAQmxErrChk (DAQmxRegisterDoneEvent(taskAO,0,DoneCallback,NULL));//Registers a callback function to receive an eventwhen a finite generation task completes execution. Write the waveform to the output buffer.
    /*********************************************/
    // DAQmx Write Code
    /*********************************************/
    DAQmxErrChk (DAQmxWriteAnalogF64(taskAO,5000,0,0,DAQmx_Val_GroupByChannel,data,NULL,NULL));// data: the array of 64-bit samples to write to the task
    /*********************************************/
    // DAQmx Start Code
    /*********************************************/
    DAQmxErrChk (DAQmxStartTask(taskAO));
    
    printf("Generating voltage continuously. Press Enter to interrupt\n");
    }
    //fflush(stdin);
//     getchar();
    
    Error:
        if( DAQmxFailed(error) ){
            DAQmxGetExtendedErrorInfo(errBuff,2048);
            if( taskAO!=0 ) {
                /*********************************************/
                // DAQmx Stop Code
                /*********************************************/
                DAQmxStopTask(taskAO);
                DAQmxClearTask(taskAO);
            }
//     if( DAQmxFailed(error) )
            printf("DAQmx Error: %s\n",errBuff);
            printf("End of program..... Error!\n");
//             getchar();
//             return 0;
        }
}

// int32 CVICALLBACK DoneCallback(TaskHandle taskHandle, int32 status, void *callbackData)
// {
//     int32   error=0;
//     char    errBuff[2048]={'\0'};
//     
//     // Check to see if an error stopped the task.
//     DAQmxErrChk (status);
    
// Error:
//     if( DAQmxFailed(error) ) {
//         DAQmxGetExtendedErrorInfo(errBuff,2048);
//         DAQmxClearTask(taskHandle);
//         printf("DAQmx Error: %s\n",errBuff);
//     }
//     return 0;
// }
