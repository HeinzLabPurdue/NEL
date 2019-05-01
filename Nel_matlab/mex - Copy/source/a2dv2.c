/*********************************************************************
 *
 * a2dv2.c
 *
 * Created by Agudemu & Mark Sayles on 3/26/17
 * mex file for A/D input to PCIe-6341 from Spike Amplifier, acquiring raw spike-trace data.
 *
 * Pin Connection Information:
 *   The analog input signal connects to AI channel 0.
 *	 Trigger signal should be connected to PFI6.
 *
 *
 *********************************************************************/

#include <stdio.h>
#include "mex.h"
#include <stdlib.h>
#include <math.h>
#include <NIDAQmx.h>
#include <time.h>

TaskHandle  taskAI = 0;
TaskHandle  taskTriggerAI = 0;

double  *status;
double  *retVals;

int     Mode;
double    RequestedUpdateRate_Hz;

int  i = 0;
int j = 0;

static int  totalRead = 0;
static int cSeq = 0;


void mexFunction( int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    // Setup a matrix for outputting error codes:
    plhs[0] = mxCreateDoubleMatrix(10,1, mxREAL);
    plhs[1] = mxCreateDoubleMatrix(10,1, mxREAL);
    status = mxGetPr(plhs[0]);
    retVals = mxGetPr(plhs[1]);
    
    Mode = (int) mxGetScalar(prhs[0]);
    if ((Mode < 0) || (Mode > 4)) {
        mexErrMsgTxt ("Mode should be in the range of 0 to 4");
    }
    
    /*********************************************
     * Halt and Clear mode
     *********************************************/
    if (Mode == 0) {
        //reset the DAQ device/
        status[0] = DAQmxClearTask(taskAI);
        retVals[0] = DAQmxFailed(status[0]);
        status[1] = DAQmxClearTask(taskTriggerAI);
        retVals[1] = DAQmxFailed(status[1]);
        
    /*********************************************
     * Initialization mode
    *********************************************/
    } else if (Mode == 1){
        RequestedUpdateRate_Hz = mxGetScalar(prhs[1]);   // input argument
        /*********************************************/
        // DAQmx AI Configure Code*
        /*********************************************/
        status[0] = DAQmxCreateTask("",&taskAI);
        retVals[0] = DAQmxFailed(status[0]);
        status[1] = DAQmxCreateAIVoltageChan(taskAI,"DAQ/ai0","",DAQmx_Val_RSE,-1.5,1.5,DAQmx_Val_Volts,NULL);
        retVals[1] = DAQmxFailed(status[1]);
        status[2] = DAQmxCfgSampClkTiming(taskAI,"",RequestedUpdateRate_Hz,DAQmx_Val_Rising,DAQmx_Val_ContSamps,RequestedUpdateRate_Hz*100);
        retVals[2] = DAQmxFailed(status[2]);
        status[3] = DAQmxStartTask(taskAI);
        retVals[3] = DAQmxFailed(status[3]);
//     /********************************************/
//     // DAQmx Counter Configure Code
//     /*********************************************/
        status[4] = DAQmxCreateTask("",&taskTriggerAI);
        retVals[4] = DAQmxFailed(status[4]);
        /* Counter channel configuration*/
        status[5] = DAQmxCreateCICountEdgesChan(taskTriggerAI,"/DAQ/Ctr1","",DAQmx_Val_Rising,0,DAQmx_Val_CountUp);
        retVals[5] = DAQmxFailed(status[5]);
        /* Sample source (trigger signals)*/
        status[6] = DAQmxCfgSampClkTiming(taskTriggerAI,"/DAQ/PFI6",100000,DAQmx_Val_Rising,DAQmx_Val_ContSamps,100000);
        retVals[6] = DAQmxFailed(status[6]);
        status[7] = DAQmxSetCICountEdgesTerm(taskTriggerAI, "/DAQ/Ctr1", "/DAQ/ai/SampleClock");//this makes sure the trigger pulses are timed with the same sampling rate as the AI signal
        retVals[7] = DAQmxFailed(status[7]);
                
        /* Start task*/
        status[8] = DAQmxStartTask(taskTriggerAI);
        retVals[8] = DAQmxFailed(status[8]);
        
        cSeq  = 0;//current line number starts at 0;
        totalRead = 0;//total number of samples read starts at 0;
        
    /*********************************************
     * Run mode
    *********************************************/
    }else if (Mode == 2){
        
        double     data[1000000];
        double     dataTrigger[10000];
        int32       read = 0;
        int32       readTrigger = 0;
        double *samples;
        double *lines;
        double *triggerSamples;
        int32       cLine = cSeq;
        /*********************************************/
        // AI start reading continuously
        /*********************************************/
        status[0] = DAQmxReadAnalogF64(taskAI,-1,0,DAQmx_Val_GroupByChannel,data,1000000,&read,NULL);
        retVals[0] = DAQmxFailed(status[0]);
        
        /*********************************************/
        // Counter start reading continuously
        /*********************************************/
        status[1] = DAQmxReadCounterF64 (taskTriggerAI, -1, 0.0, dataTrigger, -1, &readTrigger, NULL);
        retVals[1] = DAQmxFailed(status[1]);
        
        /*********************************************/
        // Mex double matrix output
        /*********************************************/
        plhs[2] = mxCreateDoubleMatrix(read,2,mxREAL);
        lines = mxGetPr(plhs[2]);
        samples = lines+read;
        cLine = cSeq;
        j = 0;
        for (i=0; i<(int)read;i++){
            if ((totalRead+i) == (int)dataTrigger[j]){
                cLine++;
                j++;
            }
            samples[i] = data[i];
            lines[i] = cLine;
        }
        //update current line number
        cSeq += readTrigger;
        
        //update total number of samples read
        totalRead += read;
        
    /*********************************************
     * Device reset mode
    *********************************************/
    } else if (Mode == 3){
//         Reset the DAQ
        status[0] = DAQmxResetDevice("DAQ");
        retVals[0] = DAQmxFailed(status[0]);
    }
}

