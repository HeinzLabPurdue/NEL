/************************************************************************
 * TITLE:       PCI6602.h
 *              Header for supporting code module for NI-DAQ Examples
 *
 * DESCR:       This header file is to be used with PCI-6602 only
 *              program that uses the supporting code module, PCI6602.c(pp).
 *
 * PROGRAM:		Kimmy
 * DATE:		9/12/00
 ************************************************************************/

#ifndef  _PCI6602_H_
#define  _PCI6602_H_


#include <windows.h>
#include <stdio.h>
#include <math.h>

#include "nidaqerr.h"   /* for NI-DAQ error codes               */

/*   #ifdef WIN32
      #include <conio.h> // for _kbhit
      #include <mmsystem.h> // for timeGetTime
   #endif */
/*   #ifdef WIN16
      #include <io.h> // for _wyield
   #endif
*/



	/* for test das header */
 
#include "tmwtypes.h"

/* Number of channels */
#define CNT_MAX_CHANNELS            (8)
#define DIO_MAX_CHANNELS            (4)

/* Checking if the S-function parameters are supported by the I/O board */
#define cntIsNumChannelsParamOK(n)  (1 <= n && n <= CNT_MAX_CHANNELS)
#define dioIsNumChannelsParamOK(n)  (1 <= n && n <= DIO_MAX_CHANNELS)

/* #include "drt_comp.h" */

/* Hardware Registers */
#define DIGITAL_IO_REG(bA)         (bA + 0x3)

/* Accessing the Digital Input section of the I/O board */
#define diReadAllInpChannels(bA)   (ReadByteFromHwPort(DIGITAL_IO_REG(bA))&0xf)
#define diGetInputOnChannel(i,v)   ((real_T) ((v >> i) & 0x1))
#define doSetDIORegister(bA, val)  WriteByteToHwPort(DIGITAL_IO_REG(bA), val)


typedef char i8;
typedef unsigned char u8;
typedef short i16;
typedef unsigned short u16;
typedef long i32;
typedef unsigned long u32;
typedef float f32;
typedef double f64;

typedef i16 nidaqExRetType;

#ifndef FAR
#define __locallydefinedFAR
#define FAR
#endif


extern i16 WINAPI DIG_In_Line (
	i16        slot,
	i16        port,
	i16        linenum,
	i16        FAR * state);
extern i16 WINAPI DIG_In_Port (
	i16        slot,
	i16        port,
	i16        FAR * pattern);
extern i16 WINAPI DIG_Line_Config (
	i16        slot,
	i16        port,
	i16        linenum,
	i16        direction);
extern i16 WINAPI DIG_Out_Line (
	i16        slot,
	i16        port,
	i16        linenum,
	i16        state);
extern i16 WINAPI DIG_Out_Port (
	i16        slot,
	i16        port,
	i16        pattern);
extern i16 WINAPI DIG_Prt_Config (
	i16        slot,
	i16        port,
	i16        latch_mode,
	i16        direction);
extern i16 WINAPI DIG_Prt_Status (
	i16        slot,
	i16        port,
	i16        FAR * status);
extern i16 WINAPI GPCTR_Config_Buffer (
	i16        deviceNumber,
	u32        gpCounterNumber,
	u32        reserved,
	u32        numPoints,
	u32        FAR * buffer);
extern i16 WINAPI GPCTR_Read_Buffer (
	i16        deviceNumber,
	u32        gpCounterNumber,
	u32        readMode,
	i32        readOffset,
	u32        numPointsToRead,
	f64        timeOut,
	u32        FAR * numPointsRead,
	u32        FAR * buffer);
extern i16 WINAPI Line_Change_Attribute (
	i16        deviceNumber,
	u32        lineNumber,
	u32        attribID,
	u32        attribValue);
extern i16 WINAPI GPCTR_Control (
	i16        deviceNumber,
	u32        gpCounterNumber,
	u32        action);
extern i16 WINAPI GPCTR_Set_Application (
	i16        deviceNumber,
	u32        gpCounterNumber,
	u32        application);
extern i16 WINAPI GPCTR_Watch (
	i16        deviceNumber,
	u32        gpCounterNumber,
	u32        watchID,
	u32        FAR * watchValue);
extern i16 WINAPI Init_DA_Brds (
	i16        slot,
	i16        FAR * brdCode);
extern i16 WINAPI Select_Signal (
	i16        deviceNumber,
	u32        signal,
	u32        source,
	u32        sourceSpec);
extern i16 WINAPI Set_DAQ_Device_Info (
	i16        deviceNumber,
	u32        infoType,
	u32        infoVal);
extern i16 WINAPI GPCTR_Change_Parameter (
	i16        deviceNumber,
	u32        gpCounterNumber,
	u32        paramID,
	u32        paramValue);
extern i16 WINAPI DIG_Trigger_Config (
	i16        slot,
	i16        grp,
	i16        startTrig,
	i16        startPol,
	i16        stopTrig,
	i16        stopPol,
	u32        ptsAfterStopTrig,
	u32        pattern,
	u32        patternMask);
extern i16 WINAPI DIG_In_Prt (
	i16        slot,
	i16        port,
	i32        FAR * pattern);
extern i16 WINAPI DIG_Out_Prt (
	i16        slot,
	i16        port,
	i32        pattern);
extern i16 WINAPI Calibrate_TIO (
	i16        deviceNumber,
	u32        operation,
	u32        setOfCalConst,
	f64        referenceFreq);
extern i16 WINAPI DIG_Change_Message_Config (
	i16        deviceNumber,
	i16        operation,
	i8         FAR * riseChanStr,
	i8         FAR * fallChanStr,
	HWND       handle,
	i16        msg,
	u32        callBackAddr);
extern i16 WINAPI DIG_Change_Message_Control (
	i16        deviceNumber,
	i16        ctrlCode);
extern i16 WINAPI DIG_Filter_Config (
	i16        deviceNumber,
	i16        mode,
	i8         FAR * chanStr,
	f64        interval);


/* to define constants for NI, DO NOT CHANGE */

#define ND_ARM                        	11100L
#define ND_ARMED                      	11200L
#define ND_ATC_OUT                    	11250L
#define ND_ATTENUATION                	11260L
#define ND_AUTOINCREMENT_COUNT        	11300L
#define ND_AUTOMATIC                  	11400L
#define ND_AVAILABLE_POINTS           	11500L

#define ND_BASE_ADDRESS               	12100L
#define ND_BELOW_LOW_LEVEL            	12130L
#define ND_BOARD_CLOCK                	12170L
#define ND_BUFFERED_EVENT_CNT         	12200L
#define ND_BUFFERED_PERIOD_MSR        	12300L
#define ND_BUFFERED_PULSE_WIDTH_MSR   	12400L
#define ND_BUFFERED_SEMI_PERIOD_MSR   	12500L
#define ND_BURST                      	12600L
#define ND_BURST_INTERVAL             	12700L

#define ND_CAL_CONST_AUTO_LOAD        	13050L
#define ND_CALIBRATION_ENABLE         	13055L
#define ND_CALIBRATION_FRAME_SIZE     	13060L
#define ND_CALIBRATION_FRAME_PTR      	13065L
#define ND_CJ_TEMP                    	((short)(0x8000))
#define ND_CALGND                     	((short)(0x8001))
#define ND_CLEAN_UP                   	13100L
#define ND_CLOCK_REVERSE_MODE_GR1     	13120L
#define ND_CLOCK_REVERSE_MODE_GR2     	13130L
#define ND_CONFIG_MEMORY_SIZE         	13150L
#define ND_CONTINUOUS                 	13160L
#define ND_COUNT                      	13200L

#define ND_COUNTER_0                  	13300L
#define ND_COUNTER_1                  	13400L
#define ND_COUNTER_2                  	13310L
#define ND_COUNTER_3                  	13320L
#define ND_COUNTER_4                  	13330L
#define ND_COUNTER_5                  	13340L
#define ND_COUNTER_6                  	13350L
#define ND_COUNTER_7                  	13360L

#define ND_COUNTER_1_SOURCE           	13430L
#define ND_COUNT_AVAILABLE            	13450L
#define ND_COUNT_DOWN                 	13465L
#define ND_COUNT_UP                   	13485L
#define ND_COUNT_1                    	13500L
#define ND_COUNT_2                    	13600L
#define ND_COUNT_3                    	13700L
#define ND_COUNT_4                    	13800L
#define ND_CURRENT_OUTPUT             	40200L

#define ND_DATA_TRANSFER_CONDITION    	13960L
#define ND_DATA_XFER_MODE_AI          	14000L
#define ND_DATA_XFER_MODE_AO_GR1      	14100L
#define ND_DATA_XFER_MODE_AO_GR2      	14200L
#define ND_DATA_XFER_MODE_DIO_GR1     	14300L
#define ND_DATA_XFER_MODE_DIO_GR2     	14400L
#define ND_DATA_XFER_MODE_DIO_GR3     	14500L
#define ND_DATA_XFER_MODE_DIO_GR4     	14600L
#define ND_DATA_XFER_MODE_DIO_GR5     	14700L
#define ND_DATA_XFER_MODE_DIO_GR6     	14800L
#define ND_DATA_XFER_MODE_DIO_GR7     	14900L
#define ND_DATA_XFER_MODE_DIO_GR8     	15000L

#define ND_DATA_XFER_MODE_GPCTR0      	15100L
#define ND_DATA_XFER_MODE_GPCTR1      	15200L
#define ND_DATA_XFER_MODE_GPCTR2      	15110L
#define ND_DATA_XFER_MODE_GPCTR3      	15120L
#define ND_DATA_XFER_MODE_GPCTR4      	15130L
#define ND_DATA_XFER_MODE_GPCTR5      	15140L
#define ND_DATA_XFER_MODE_GPCTR6      	15150L
#define ND_DATA_XFER_MODE_GPCTR7      	15160L
#define ND_DATA_XFER_MODE_GPCTR8      	15165L
#define ND_DATA_XFER_MODE_GPCTR9      	15170L
#define ND_DATA_XFER_MODE_GPCTR10     	15175L
#define ND_DATA_XFER_MODE_GPCTR11     	15180L

#define ND_DC                         	15250L
#define ND_DDS_BUFFER_SIZE            	15255L
#define ND_DEVICE_NAME                	15260L
#define ND_DEVICE_POWER               	15270L
#define ND_DEVICE_SERIAL_NUMBER       	15280L
#define ND_DEVICE_STATE_DURING_SUSPEND_MODE	15290L
#define ND_DEVICE_TYPE_CODE           	15300L
#define ND_DIGITAL_FILTER             	15350L
#define ND_DIGITAL_RESTART            	15375L
#define ND_DIO128_GET_PORT_THRESHOLD  	41200L
#define ND_DIO128_SELECT_INPUT_PORT   	41100L
#define ND_DIO128_SET_PORT_THRESHOLD  	41300L
#define ND_DISABLED                   	15400L
#define ND_DISARM                     	15450L
#define ND_DIVIDE_DOWN_SAMPLING_SUPPORTED	15475L
#define ND_DMA_A_LEVEL                	15500L
#define ND_DMA_B_LEVEL                	15600L
#define ND_DMA_C_LEVEL                	15700L
#define ND_DONE                       	15800L
#define ND_DONT_CARE                  	15900L
#define ND_DONT_KNOW                  	15950L

#define ND_EDGE_SENSITIVE             	16000L
#define ND_ENABLED                    	16050L
#define ND_END                        	16055L
#define ND_EXTERNAL                   	16060L
#define ND_EXTERNAL_CALIBRATE         	16100L

#define ND_FACTORY_CALIBRATION_EQUIP  	16210L
#define ND_FACTORY_EEPROM_AREA        	16220L
#define ND_FIFO_EMPTY                 	16230L
#define ND_FIFO_HALF_FULL_OR_LESS     	16240L
#define ND_FIFO_HALF_FULL_OR_LESS_UNTIL_FULL	16245L
#define ND_FIFO_NOT_FULL              	16250L
#define ND_FIFO_TRANSFER_COUNT        	16260L
#define ND_FILTER_CORRECTION_FREQ     	16300L
#define ND_FOREGROUND                 	16350L
#define ND_FREQ_OUT                   	16400L
#define ND_FSK                        	16500L
#define ND_EDGE_BASED_FSK             	16500L

#define ND_GATE                       	17100L
#define ND_GATE_POLARITY              	17200L

#define ND_GPCTR0_GATE                	17300L
#define ND_GPCTR0_OUTPUT              	17400L
#define ND_GPCTR0_SOURCE              	17500L

#define ND_GPCTR1_GATE                	17600L
#define ND_GPCTR1_OUTPUT              	17700L
#define ND_GPCTR1_SOURCE              	17800L

#define ND_GPCTR2_GATE                	17320L
#define ND_GPCTR2_OUTPUT              	17420L
#define ND_GPCTR2_SOURCE              	17520L

#define ND_GPCTR3_GATE                	17330L
#define ND_GPCTR3_OUTPUT              	17430L
#define ND_GPCTR3_SOURCE              	17530L

#define ND_GPCTR4_GATE                	17340L
#define ND_GPCTR4_OUTPUT              	17440L
#define ND_GPCTR4_SOURCE              	17540L

#define ND_GPCTR5_GATE                	17350L
#define ND_GPCTR5_OUTPUT              	17450L
#define ND_GPCTR5_SOURCE              	17550L

#define ND_GPCTR6_GATE                	17360L
#define ND_GPCTR6_OUTPUT              	17460L
#define ND_GPCTR6_SOURCE              	17660L

#define ND_GPCTR7_GATE                	17370L
#define ND_GPCTR7_OUTPUT              	17470L
#define ND_GPCTR7_SOURCE              	17570L

#define ND_HARDWARE                   	18000L
#define ND_HI_RES_SAMPLING            	18020L
#define ND_HIGH                       	18050L
#define ND_HIGH_HYSTERESIS            	18080L
#define ND_HIGH_TO_LOW                	18100L
#define ND_HW_ANALOG_TRIGGER          	18900L

#define ND_IMPEDANCE                  	19000L
#define ND_INACTIVE                   	19010L
#define ND_INITIAL_COUNT              	19100L
#define ND_INIT_PLUGPLAY_DEVICES      	19110L
#define ND_INSIDE_REGION              	19150L
#define ND_INTERNAL                   	19160L
#define ND_INTERNAL_100_KHZ           	19200L
#define ND_INTERNAL_10_MHZ            	19300L
#define ND_INTERNAL_1250_KHZ          	19320L
#define ND_INTERNAL_20_MHZ            	19400L
#define ND_INTERNAL_25_MHZ            	19410L
#define ND_INTERNAL_2500_KHZ          	19420L
#define ND_INTERNAL_5_MHZ             	19450L
#define ND_INTERNAL_7160_KHZ          	19460L
#define ND_INTERNAL_TIMER             	19500L
#define ND_INTERRUPTS                 	19600L
#define ND_INTERRUPT_A_LEVEL          	19700L
#define ND_INTERRUPT_B_LEVEL          	19800L
#define ND_INTERRUPT_TRIGGER_MODE     	19850L
#define ND_IN_CHANNEL_CLOCK_TIMEBASE  	19900L
#define ND_IN_CHANNEL_CLOCK_TB_POL    	20000L
#define ND_IN_CONVERT                 	20100L
#define ND_IN_CONVERT_POL             	20200L
#define ND_IN_DATA_FIFO_SIZE          	20250L
#define ND_IN_EXTERNAL_GATE           	20300L
#define ND_IN_EXTERNAL_GATE_POL       	20400L
#define ND_IN_SCAN_CLOCK_TIMEBASE     	20500L
#define ND_IN_SCAN_CLOCK_TB_POL       	20600L
#define ND_IN_SCAN_IN_PROG            	20650L
#define ND_IN_SCAN_START              	20700L
#define ND_IN_SCAN_START_POL          	20800L
#define ND_IN_START_TRIGGER           	20900L
#define ND_IN_START_TRIGGER_POL       	21000L
#define ND_IN_STOP_TRIGGER            	21100L
#define ND_IN_STOP_TRIGGER_POL        	21200L
#define ND_INT_CM_REF_5V              	21270L
#define ND_INT_DEV_TEMP               	21280L
#define ND_INT_REF_5V                 	21290L
#define ND_INT_REF_EXTERN             	21296L
#define ND_INT_CAL_BUS                	21295L
#define ND_INT_MUX_BUS                	21305L

#define ND_INT_REF_AMP_0              	21291L
#define ND_INT_REF_AMP_1              	21292L
#define ND_INT_REF_AMP_2              	21293L
#define ND_INT_REF_AMP_3              	21294L

#define ND_INTERRUPT_EVERY_SAMPLE     	11700L
#define ND_INTERRUPT_HALF_FIFO        	11800L
#define ND_IO_CONNECTOR               	21300L

#define ND_LEVEL_SENSITIVE            	24000L
#define ND_LINK_COMPLETE_INTERRUPTS   	24010L
#define ND_LOW                        	24050L
#define ND_LOW_HYSTERESIS             	24080L
#define ND_LOW_TO_HIGH                	24100L
#define ND_LPT_DEVICE_MODE            	24200L

#define ND_MARKER                     	24500L
#define ND_MARKER_QUANTUM             	24550L
#define ND_MAX_ARB_SEQUENCE_LENGTH    	24600L
#define ND_MAX_FUNC_SEQUENCE_LENGTH   	24610L
#define ND_MAX_LOOP_COUNT             	24620L
#define ND_MAX_NUM_WAVEFORMS          	24630L
#define ND_MAX_SAMPLE_RATE            	24640L
#define ND_MAX_WFM_SIZE               	24650L
#define ND_MEMORY_TRANSFER_WIDTH      	24700L
#define ND_MIN_SAMPLE_RATE            	24800L
#define ND_MIN_WFM_SIZE               	24810L

#define ND_NEGATIVE                   	26100L
#define ND_NEW                        	26190L
#define ND_NI_DAQ_SW_AREA             	26195L
#define ND_NO                         	26200L
#define ND_NO_STRAIN_GAUGE            	26225L
#define ND_NO_TRACK_AND_HOLD          	26250L
#define ND_NONE                       	26300L
#define ND_NOT_APPLICABLE             	26400L
#define ND_NUMBER_DIG_PORTS           	26500L

#define ND_OFF                        	27010L
#define ND_OFFSET                     	27020L
#define ND_ON                         	27050L
#define ND_OTHER                      	27060L
#define ND_OTHER_GPCTR_OUTPUT         	27300L
#define ND_OTHER_GPCTR_TC             	27400L
#define ND_OUT_DATA_FIFO_SIZE         	27070L
#define ND_OUT_EXTERNAL_GATE          	27080L
#define ND_OUT_EXTERNAL_GATE_POL      	27082L
#define ND_OUT_START_TRIGGER          	27100L
#define ND_OUT_START_TRIGGER_POL      	27102L
#define ND_OUT_UPDATE                 	27200L
#define ND_OUT_UPDATE_POL             	27202L
#define ND_OUT_UPDATE_CLOCK_TIMEBASE  	27210L
#define ND_OUT_UPDATE_CLOCK_TB_POL    	27212L
#define ND_OUTPUT_ENABLE              	27220L
#define ND_OUTPUT_MODE                	27230L
#define ND_OUTPUT_POLARITY            	27240L
#define ND_OUTPUT_STATE               	27250L
#define ND_OUTPUT_TYPE                	40000L

#define ND_DIGITAL_PATTERN_GENERATION 	28030L
#define ND_PAUSE                      	28040L
#define ND_PAUSE_ON_HIGH              	28045L
#define ND_PAUSE_ON_LOW               	28050L
#define ND_PFI_0                      	28100L
#define ND_PFI_1                      	28200L
#define ND_PFI_2                      	28300L
#define ND_PFI_3                      	28400L
#define ND_PFI_4                      	28500L
#define ND_PFI_5                      	28600L
#define ND_PFI_6                      	28700L
#define ND_PFI_7                      	28800L
#define ND_PFI_8                      	28900L
#define ND_PFI_9                      	29000L
#define ND_PFI_10                     	50280L
#define ND_PFI_11                     	50290L
#define ND_PFI_12                     	50300L
#define ND_PFI_13                     	50310L
#define ND_PFI_14                     	50320L
#define ND_PFI_15                     	50330L
#define ND_PFI_16                     	50340L
#define ND_PFI_17                     	50350L
#define ND_PFI_18                     	50360L
#define ND_PFI_19                     	50370L
#define ND_PFI_20                     	50380L
#define ND_PFI_21                     	50390L
#define ND_PFI_22                     	50400L
#define ND_PFI_23                     	50410L
#define ND_PFI_24                     	50420L
#define ND_PFI_25                     	50430L
#define ND_PFI_26                     	50440L
#define ND_PFI_27                     	50450L
#define ND_PFI_28                     	50460L
#define ND_PFI_29                     	50470L
#define ND_PFI_30                     	50480L
#define ND_PFI_31                     	50490L
#define ND_PFI_32                     	50500L
#define ND_PFI_33                     	50510L
#define ND_PFI_34                     	50520L
#define ND_PFI_35                     	50530L
#define ND_PFI_36                     	50540L
#define ND_PFI_37                     	50550L
#define ND_PFI_38                     	50560L
#define ND_PFI_39                     	50570L

#define ND_PLL_REF_FREQ               	29010L
#define ND_PLL_REF_SOURCE             	29020L
#define ND_PRE_ARM                    	29050L
#define ND_POSITIVE                   	29100L
#define ND_PREPARE                    	29200L
#define ND_PROGRAM                    	29300L
#define ND_PULSE                      	29350L
#define ND_PULSE_SOURCE               	29500L
#define ND_PULSE_TRAIN_GNR            	29600L
#define ND_PXI_BACKPLANE_CLOCK        	29900L

#define ND_REGLITCH                   	31000L
#define ND_RESERVED                   	31100L
#define ND_RESET                      	31200L
#define ND_RESUME                     	31250L
#define ND_RETRIG_PULSE_GNR           	31300L
#define ND_REVISION                   	31350L
#define ND_RTSI_0                     	31400L
#define ND_RTSI_1                     	31500L
#define ND_RTSI_2                     	31600L
#define ND_RTSI_3                     	31700L
#define ND_RTSI_4                     	31800L
#define ND_RTSI_5                     	31900L
#define ND_RTSI_6                     	32000L
#define ND_RTSI_CLOCK                 	32100L

#define ND_SCANCLK                    	32400L
#define ND_SCANCLK_LINE               	32420L
#define ND_SC_2040_MODE               	32500L
#define ND_SC_2043_MODE               	32600L
#define ND_SELF_CALIBRATE             	32700L
#define ND_SET_DEFAULT_LOAD_AREA      	32800L
#define ND_RESTORE_FACTORY_CALIBRATION	32810L
#define ND_SET_POWERUP_STATE          	42100L
#define ND_SIMPLE_EVENT_CNT           	33100L
#define ND_SINGLE                     	33150L
#define ND_SINGLE_PERIOD_MSR          	33200L
#define ND_SINGLE_PULSE_GNR           	33300L
#define ND_SINGLE_PULSE_WIDTH_MSR     	33400L
#define ND_SINGLE_TRIG_PULSE_GNR      	33500L
#define ND_SOURCE                     	33700L
#define ND_SOURCE_POLARITY            	33800L
#define ND_STABLE_10_MHZ              	33810L
#define ND_STEPPED                    	33825L
#define ND_STRAIN_GAUGE               	33850L
#define ND_STRAIN_GAUGE_EX0           	33875L
#define ND_SUB_REVISION               	33900L
#define ND_SYNC_DUTY_CYCLE_HIGH       	33930L
#define ND_SYNC_OUT                   	33970L

#define ND_TC_REACHED                 	34100L
#define ND_THE_AI_CHANNEL             	34400L
#define ND_TOGGLE                     	34700L
#define ND_TOGGLE_GATE                	34800L
#define ND_TRACK_AND_HOLD             	34850L
#define ND_TRIG_PULSE_WIDTH_MSR       	34900L
#define ND_TRIGGER_SOURCE             	34930L
#define ND_TRIGGER_MODE               	34970L

#define ND_UI2_TC                     	35100L
#define ND_UP_DOWN                    	35150L
#define ND_UP_TO_1_DMA_CHANNEL        	35200L
#define ND_UP_TO_2_DMA_CHANNELS       	35300L
#define ND_USE_CAL_CHAN               	36000L
#define ND_USE_AUX_CHAN               	36100L
#define ND_USER_EEPROM_AREA           	37000L
#define ND_USER_EEPROM_AREA_2         	37010L
#define ND_USER_EEPROM_AREA_3         	37020L
#define ND_USER_EEPROM_AREA_4         	37030L
#define ND_USER_EEPROM_AREA_5         	37040L

#define ND_VOLTAGE_OUTPUT             	40100L
#define ND_VOLTAGE_REFERENCE          	38000L

#define ND_WFM_QUANTUM                	45000L

#define ND_YES                        	39100L
#define ND_3V_LEVEL                   	43450L

#define ND_WRITE_MARK                 	50000L
#define ND_READ_MARK                  	50010L
#define ND_BUFFER_START               	50020L
#define ND_TRIGGER_POINT              	50025L
#define ND_BUFFER_MODE                	50030L
#define ND_DOUBLE                     	50050L
#define ND_QUADRATURE_ENCODER_X1      	50070L
#define ND_QUADRATURE_ENCODER_X2      	50080L
#define ND_QUADRATURE_ENCODER_X4      	50090L
#define ND_TWO_PULSE_COUNTING         	50100L
#define ND_LINE_FILTER                	50110L
#define ND_SYNCHRONIZATION            	50120L
#define ND_5_MICROSECONDS             	50130L
#define ND_1_MICROSECOND              	50140L
#define ND_500_NANOSECONDS            	50150L
#define ND_100_NANOSECONDS            	50160L
#define ND_1_MILLISECOND              	50170L
#define ND_10_MILLISECONDS            	50180L
#define ND_100_MILLISECONDS           	50190L

#define ND_OTHER_GPCTR_SOURCE         	50580L
#define ND_OTHER_GPCTR_GATE           	50590L
#define ND_AUX_LINE                   	50600L
#define ND_AUX_LINE_POLARITY          	50610L
#define ND_TWO_SIGNAL_EDGE_SEPARATION_MSR	50630L
#define ND_BUFFERED_TWO_SIGNAL_EDGE_SEPARATION_MSR	50640L
#define ND_SWITCH_CYCLE               	50650L
#define ND_INTERNAL_MAX_TIMEBASE      	50660L
#define ND_PRESCALE_VALUE             	50670L
#define ND_MAX_PRESCALE               	50690L
#define ND_INTERNAL_LINE_0            	50710L
#define ND_INTERNAL_LINE_1            	50720L
#define ND_INTERNAL_LINE_2            	50730L
#define ND_INTERNAL_LINE_3            	50740L
#define ND_INTERNAL_LINE_4            	50750L
#define ND_INTERNAL_LINE_5            	50760L
#define ND_INTERNAL_LINE_6            	50770L
#define ND_INTERNAL_LINE_7            	50780L
#define ND_INTERNAL_LINE_8            	50790L
#define ND_INTERNAL_LINE_9            	50800L
#define ND_INTERNAL_LINE_10           	50810L
#define ND_INTERNAL_LINE_11           	50820L
#define ND_INTERNAL_LINE_12           	50830L
#define ND_INTERNAL_LINE_13           	50840L
#define ND_INTERNAL_LINE_14           	50850L
#define ND_INTERNAL_LINE_15           	50860L
#define ND_INTERNAL_LINE_16           	50862L
#define ND_INTERNAL_LINE_17           	50864L
#define ND_INTERNAL_LINE_18           	50866L
#define ND_INTERNAL_LINE_19           	50868L
#define ND_INTERNAL_LINE_20           	50870L
#define ND_INTERNAL_LINE_21           	50872L
#define ND_INTERNAL_LINE_22           	50874L
#define ND_INTERNAL_LINE_23           	50876L

#define ND_START_TRIGGER              	51150L
#define ND_START_TRIGGER_POLARITY     	51151L

#define ND_COUNTING_SYNCHRONOUS       	51200L
#define ND_SYNCHRONOUS                	51210L
#define ND_ASYNCHRONOUS               	51220L
#define ND_CONFIGURABLE_FILTER        	51230L
#define ND_ENCODER_TYPE               	51240L
#define ND_Z_INDEX_ACTIVE             	51250L
#define ND_Z_INDEX_VALUE              	51260L
#define ND_SNAPSHOT                   	51270L
#define ND_POSITION_MSR               	51280L
#define ND_BUFFERED_POSITION_MSR      	51290L
#define ND_SAVED_COUNT                	51300L
#define ND_READ_MARK_H_SNAPSHOT       	51310L
#define ND_READ_MARK_L_SNAPSHOT       	51320L
#define ND_WRITE_MARK_H_SNAPSHOT      	51330L
#define ND_WRITE_MARK_L_SNAPSHOT      	51340L
#define ND_BACKLOG_H_SNAPSHOT         	51350L
#define ND_BACKLOG_L_SNAPSHOT         	51360L
#define ND_ARMED_SNAPSHOT             	51370L
#define ND_EDGE_GATED_FSK             	51371L
#define ND_SIMPLE_GATED_EVENT_CNT     	51372L

#define ND_COUNTER_TYPE               	51470L
#define ND_NI_TIO                     	51480L
#define ND_STC                        	51500L
#define ND_8253                       	51510L
#define ND_A_HIGH_B_HIGH              	51520L
#define ND_A_HIGH_B_LOW               	51530L
#define ND_A_LOW_B_HIGH               	51540L
#define ND_A_LOW_B_LOW                	51550L
#define ND_Z_INDEX_RELOAD_PHASE       	51560L
#define ND_UPDOWN_LINE                	51570L
#define ND_DEFAULT_PFI_LINE           	51580L
#define ND_BUFFER_SIZE                	51590L
#define ND_ELEMENT_SIZE               	51600L
#define ND_NUMBER_GP_COUNTERS         	51610L
#define ND_BUFFERED_TIME_STAMPING     	51620L
#define ND_TIME_0_DATA_32             	51630L
#define ND_TIME_8_DATA_24             	51640L
#define ND_TIME_16_DATA_16            	51650L
#define ND_TIME_24_DATA_8             	51660L
#define ND_TIME_32_DATA_32            	51670L
#define ND_TIME_48_DATA_16            	51680L
#define ND_ABSOLUTE                   	51690L
#define ND_RELATIVE                   	51700L
#define ND_TIME_DATA_SIZE             	51710L
#define ND_TIME_FORMAT                	51720L
#define ND_HALT_ON_OVERFLOW           	51730L
#define ND_OVERLAY_RTSI_ON_PFI_LINES  	51740L
#define ND_STOP_TRIGGER               	51750L
#define ND_TS_INPUT_MODE              	51760L
#define ND_BOTH_EDGES                 	51770L

#define ND_CLOCK_0                    	51780L
#define ND_CLOCK_1                    	51790L
#define ND_CLOCK_2                    	51800L
#define ND_CLOCK_3                    	51810L
#define ND_SYNCHRONIZATION_LINE       	51820L
#define ND_TRANSFER_METHOD            	51830L
#define ND_SECONDS                    	51840L
#define ND_PRECISION                  	51850L
#define ND_NANO_SECONDS               	51860L
#define ND_SYNCHRONIZATION_METHOD     	51870L
#define ND_PULSE_PER_SECOND           	51880L
#define ND_IRIG_B                     	51890L
#define ND_SIMPLE_TIME_MSR            	51900L
#define ND_SINGLE_TIME_MSR            	51910L
#define ND_BUFFERED_TIME_MSR          	51920L
#define ND_DMA                        	51930L
#endif



/* -------------------------------------------------------------*/

 // EXPORT HEADERS for DLL exporting
 #ifdef _PCI6602_DLL_
//    #ifdef WIN32
//       #define EXPORT
//       #define EXPORT32 __declspec(dllexport)
//    #else
       #define EXPORT   __export
       #define EXPORT32
//    #endif // #ifdef WIN32
 #else
    // for use in examples, these are defined as nothing
    #define EXPORT
    #define EXPORT32
 #endif  // #ifndef _PCI6602_DLL_

//#endif


/* for 'lType' */
#define WFM_DATA_U8             0
#define WFM_DATA_I16            2
#define WFM_DATA_F64            4
#define WFM_DATA_U32            7

/* internal constants */
#define WFM_PERIODS            10
#define WFM_MIN_PTS_IN_PERIOD   2
#define WFM_U8_MODULO         256
#define WFM_I16_AMPL         2047
#define WFM_F64_AMPL         4.99
#define WFM_2PI              6.2831853071796


/* error return codes for NIDAQPlotWaveform and NIDAQMakeBuffer */
#ifndef NoError
   #define NoError 0
#endif

/* these error codes are consistent with CVI error codes */
#define NIDAQEX_INVALID_BUFFER         -12
#define NIDAQEX_INVALID_NUMPTS         -14
#define NIDAQEX_INVALID_TYPE           -53


#define CPPHEADER
#define CPPTRAILER

/*
 * Function prototypes
 */

/*CPPHEADER

EXPORT32 nidaqExRetType EXPORT WINAPI NIDAQPlotWaveform(void* pvBuffer, u32 lNumPts, u32 lType);
EXPORT32 nidaqExRetType EXPORT WINAPI NIDAQMakeBuffer(void* pvBuffer, u32 lNumPts, u32 lType);
EXPORT32 nidaqExRetType EXPORT WINAPI NIDAQDelay(f64 dSec);
EXPORT32 nidaqExRetType EXPORT WINAPI NIDAQErrorHandler(i16 iStatus, char *strFuncName, i16 iIgnoreWarning);
EXPORT32 nidaqExRetType EXPORT WINAPI NIDAQYield(i16 iYieldMode);
EXPORT32 nidaqExRetType EXPORT WINAPI NIDAQMean(void* pvBuffer, u32 lNumPts, u32 lType, f64* dMean);
EXPORT32 nidaqExRetType EXPORT WINAPI NIDAQWaitForKey(f64 dTimeLimit);

CPPTRAILER
*/

#ifdef __locallydefinedFAR
#undef __locallydefinedFAR
#undef FAR
#endif


//#endif  /* _PCI6602_H_ */
