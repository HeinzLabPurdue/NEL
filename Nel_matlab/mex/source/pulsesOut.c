/*********************************************************************
 *
 * pulsesOut.c
 *
 * Created by Mark Sayles on 3/26/17
 * Very simple mex file for generating Digital Pulses out from the counter channel of the DAQ card (NI PCIe 6341).
 * These pulses are used as TTL input to the Dagan BVC-700A for controlling the timing of current pulses to the electrode.
 *
 *Inputs (depends on the Mode):
 *pulsesOut(0) - mode 0 stops the task
 *pulsesOut(1,High_Time,Low_Time) - in mode 1, you set the high and low time of the +5V pulses (in seconds)
*
*********************************************************************/

#include <stdio.h>
#include "mex.h"
#include <stdlib.h>
#include <math.h>
#include <NIDAQmx.h>
#include <time.h>

TaskHandle  taskCO = 0;
float64    High_Time;
float64    Low_Time;

void mexFunction( int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    int         Mode;
    
    Mode = (int) mxGetScalar(prhs[0]);
    
    /*********************************************
     * Halt and clear mode
     *********************************************/
    if (Mode == 0) {
        //stop and clear the task
        DAQmxStopTask(taskCO);
        DAQmxClearTask(taskCO);
        
    /*********************************************
    * Initialization and run mode
    *********************************************/
    } else if (Mode == 1){
        High_Time = (float64) mxGetScalar(prhs[1]);   // input argument
        Low_Time  = (float64) mxGetScalar(prhs[2]);   // input argument
   
        DAQmxCreateTask("",&taskCO);
        DAQmxCreateCOPulseChanTime(taskCO,"/DAQ/Ctr0","",DAQmx_Val_Seconds,DAQmx_Val_Low,0.0,Low_Time,High_Time);
        //The digital pulses will be available at pin 2 (PFI 12 on the DAQ - see table of default locations for counter channels on 6341 pinout diagram in NIDAQ Measurement and Automation Explorer)
        DAQmxCfgImplicitTiming(taskCO,DAQmx_Val_ContSamps,10);
        DAQmxStartTask(taskCO);
    }
}