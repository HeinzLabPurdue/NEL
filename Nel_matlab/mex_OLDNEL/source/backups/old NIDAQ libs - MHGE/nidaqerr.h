#if !defined (___nidaqerr_h___)
#define ___nidaqerr_h___

/*
   nidaqerr.h
       header file for platform-independent ni-daq errors and warnings

   Note:
       Always use symbolic names and not explicit values when referring to
       specific error codes in your program.

       Warnings are returned as positive numbers. For example overWriteError
       may be returned as a warning and its value would be -(overWriteError).

   THIS FILE IS AUTOMATICALLY GENERATED FROM A DATABASE: DO NOT EDIT
*/

#ifdef NIERROR_DATABASE
struct sNIDAQErrorStruct
{
    long  lStatus;
    char  *pcMessage;
};

/* TOTAL ERROR CODES */
#define kTotalNIDAQCodes               304
#endif /* #ifdef NIERROR_DATABASE */


#define noError                        0

#define syntaxError                     -10001   /* An error was detected in the input string; the arrangement or ordering ... */
#define semanticsError                  -10002   /* An error was detected in the input string; the syntax of the string is ... */
#define invalidValueError               -10003   /* The value of a numeric parameter is invalid. */
#define valueConflictError              -10004   /* The value of a numeric parameter is inconsistent with another one, and ... */
#define badDeviceError                  -10005   /* The device is invalid. */
#define badLineError                    -10006   /* The line is invalid. */
#define badChanError                    -10007   /* A channel, port, or counter is out of range for the device type or device ... */
#define badGroupError                   -10008   /* The group is invalid. */
#define badCounterError                 -10009   /* The counter is invalid. */
#define badCountError                   -10010   /* The count is too small or too large for the specified counter, or the ... */
#define badIntervalError                -10011   /* The analog input scan rate is too fast for the number of channels and ... */
#define badRangeError                   -10012   /* The analog input or analog output voltage or current range is invalid ... */
#define badErrorCodeError               -10013   /* The driver returned an unrecognized or unlisted error code. */
#define groupTooLargeError              -10014   /* The group size is too large for the board. */
#define badTimeLimitError               -10015   /* The time limit is invalid. */
#define badReadCountError               -10016   /* The read count is invalid. */
#define badReadModeError                -10017   /* The read mode is invalid. */
#define badReadOffsetError              -10018   /* The offset is unreachable. */
#define badClkFrequencyError            -10019   /* The frequency is invalid. */
#define badTimebaseError                -10020   /* The timebase is invalid. */
#define badLimitsError                  -10021   /* The limits are beyond the range of the board. */
#define badWriteCountError              -10022   /* Your data array contains an incomplete update, or you are trying to write ... */
#define badWriteModeError               -10023   /* The write mode is out of range or is disallowed. */
#define badWriteOffsetError             -10024   /* Adding the write offset to the write mark places the write mark outside ... */
#define limitsOutOfRangeError           -10025   /* The requested input limits exceed the board's capability or configuration. ... */
#define badBufferSpecificationError     -10026   /* The requested number of buffers or the buffer size is not allowed. For ... */
#define badDAQEventError                -10027   /* For DAQEvents 0 and 1 general value A must be greater than 0 and less ... */
#define badFilterCutoffError            -10028   /* The cutoff frequency specified is not valid for this device. */
#define obsoleteFunctionError           -10029   /* The function you are calling is no longer supported in this version of ... */
#define badBaudRateError                -10030   /* The specified baud rate for communicating with the serial port is not ... */
#define badChassisIDError               -10031   /* The specified baud rate for communicating with the serial port is not ... */
#define badModuleSlotError              -10032   /* The SCXI module slot that was specified is invalid or corresponds to an ... */
#define invalidWinHandleError           -10033   /* The window handle passed to the function is invalid. */
#define noSuchMessageError              -10034   /* No configured message matches the one you tried to delete. */
#define irrelevantAttributeError        -10035   /* The specified attribute is not relevant. */
#define badYearError                    -10036   /* The specified year is invalid. */
#define badMonthError                   -10037   /* The specified month is invalid. */
#define badDayError                     -10038   /* The specified day is invalid. */
#define stringTooLongError              -10039   /* The specified input string is too long.  For instance, DAQScope 5102 devices ... */
#define badGroupSizeError               -10040   /* The group size is invalid.  */
#define badTaskIDError                  -10041   /* The specified task ID is invalid. For instance, you may have connected ... */
#define inappropriateControlCodeError   -10042   /* The specified control code is inappropriate for the current configuration ... */
#define badDivisorError                 -10043   /* The specified divisor is invalid. */
#define badPolarityError                -10044   /* The specified polarity is invalid.  */
#define badInputModeError               -10045   /* The specified input mode is invalid.  */
#define badExcitationError              -10046   /* The excitation value specified is not valid for this device. */
#define badConnectionTypeError          -10047   /* The excitation value specified is not valid for this device. */
#define badExcitationTypeError          -10048   /* The excitation type specified is not valid for this device. */
#define badChanListError                -10050   /* There is more than one channel name in the channel list that corresponds ... */
#define badTrigSkipCountError           -10079   /* The trigger skip count is invalid. */
#define badGainError                    -10080   /* The gain or gain adjust is invalid. */
#define badPretrigCountError            -10081   /* The pretrigger sample count is invalid. */
#define badPosttrigCountError           -10082   /* The posttrigger sample count is invalid. */
#define badTrigModeError                -10083   /* The trigger mode is invalid. */
#define badTrigCountError               -10084   /* The trigger count is invalid. */
#define badTrigRangeError               -10085   /* The trigger range or trigger hysteresis window is invalid. */
#define badExtRefError                  -10086   /* The external reference  is invalid. */
#define badTrigTypeError                -10087   /* The trigger type is invalid. */
#define badTrigLevelError               -10088   /* The trigger level is invalid. */
#define badTotalCountError              -10089   /* The total count is inconsistent with the buffer size and pretrigger scan ... */
#define badRPGError                     -10090   /* The individual range, polarity, and gain settings are valid but the combination ... */
#define badIterationsError              -10091   /* You have attempted to use an invalid setting for the iterations parameter. ... */
#define lowScanIntervalError            -10092   /* Some devices require a time gap between the last sample in a scan and ... */
#define fifoModeError                   -10093   /* FIFO mode waveform generation cannot be used because at least one condition ... */
#define badCalDACconstError             -10094   /* The calDAC constant passed to the function is invalid. */
#define badCalStimulusError             -10095   /* The calibration stimulus passed to the function is invalid. */
#define badCalibrationConstantError     -10096   /* The specified calibration constant is invalid. */
#define badCalOpError                   -10097   /* The specified calibration operation is invalid. */
#define badCalConstAreaError            -10098   /* The specified calibration constant area is invalid.  For instance, the ... */
#define badPortWidthError               -10100   /* The requested digital port width is not a multiple of the hardware port ... */
#define gpctrBadApplicationError        -10120   /* Invalid application used. */
#define gpctrBadCtrNumberError          -10121   /* Invalid counterNumber used. */
#define gpctrBadParamValueError         -10122   /* Invalid paramValue used. */
#define gpctrBadParamIDError            -10123   /* Invalid paramID used. */
#define gpctrBadEntityIDError           -10124   /* Invalid entityID used. */
#define gpctrBadActionError             -10125   /* Invalid action used. */
#define gpctrSourceSelectError          -10126   /* Invalid source selected. */
#define badCountDirError                -10127   /* The specified counter does not support the specified count direction.  */
#define badGateOptionError              -10128   /* The specified gating option is invalid.  */
#define badGateModeError                -10129   /* The specified gate mode is invalid. */
#define badGateSourceError              -10130   /* The specified gate source is invalid. */
#define badGateSignalError              -10131   /* The specified gate signal is invalid. */
#define badSourceEdgeError              -10132   /* The specified source edge is invalid. */
#define badOutputTypeError              -10133   /* The specified output type is invalid. */
#define badOutputPolarityError          -10134   /* The specified output polarity is invalid. */
#define badPulseModeError               -10135   /* The specified pulse mode is invalid. */
#define badDutyCycleError               -10136   /* The specified duty cycle is invalid. */
#define badPulsePeriodError             -10137   /* The specified pulse period is invalid. */
#define badPulseDelayError              -10138   /* The specified pulse delay is invalid. */
#define badPulseWidthError              -10139   /* The specified pulse width is invalid. */
#define badFOUTportError                -10140   /* The specified frequency output (FOUT or FREQ_OUT) port is invalid. */
#define badAutoIncrementModeError       -10141   /* The specified autoincrement mode is invalid.  */
#define badNotchFilterError             -10180   /* The specified notch filter is invalid. */
#define badMeasModeError                -10181   /* The specified measurement mode is invalid. */
#define EEPROMreadError                 -10200   /* Unable to read data from EEPROM. */
#define EEPROMwriteError                -10201   /* Unable to write data to EEPROM. */
#define EEPROMwriteProtectionError      -10202   /* You cannot write into this location or area of your EEPROM because it ... */
#define EEPROMinvalidLocationError      -10203   /* The specified EEPROM location is invalid. */
#define EEPROMinvalidPasswordError      -10204   /* The password for accessing the EEPROM is incorrect. */
#define noDriverError                   -10240   /* The driver interface could not locate or open the driver.. */
#define oldDriverError                  -10241   /* One of the driver files or the configuration utility is out of date, or ... */
#define functionNotFoundError           -10242   /* The specified function is not located in the driver. */
#define configFileError                 -10243   /* The driver could not locate or open the configuration file, or the format ... */
#define deviceInitError                 -10244   /* The driver encountered a hardware-initialization error while attempting ... */
#define osInitError                     -10245   /* The driver encountered an operating-system error while attempting to perform ... */
#define communicationsError             -10246   /* The driver encountered an operating-system error while attempting to perform ... */
#define cmosConfigError                 -10247   /* The CMOS configuration-memory for the device is empty or invalid, or the ... */
#define dupAddressError                 -10248   /* The base addresses for two or more devices are the same; consequently, ... */
#define intConfigError                  -10249   /* The interrupt configuration is incorrect given the capabilities of the ... */
#define dupIntError                     -10250   /* The interrupt levels for two or more devices are the same. */
#define dmaConfigError                  -10251   /* The DMA configuration is incorrect given the capabilities of the computer/DMA ... */
#define dupDMAError                     -10252   /* The DMA channels for two or more devices are the same. */
#define jumperlessBoardError            -10253   /* Unable to find one or more jumperless boards you have configured using ... */
#define DAQCardConfError                -10254   /* Cannot configure the DAQCard because 1) the correct version of the card ... */
#define remoteChassisDriverInitError    -10255   /* There was an error in initializing the driver for Remote SCXI. */
#define comPortOpenError                -10256   /* There was an error in opening the specified COM port. */
#define baseAddressError                -10257   /* Bad base address specified in the configuration utility. */
#define dmaChannel1Error                -10258   /* Bad DMA channel 1 specified in the configuration utility or by the operating ... */
#define dmaChannel2Error                -10259   /* Bad DMA channel 2 specified in the configuration utility or by the operating ... */
#define dmaChannel3Error                -10260   /* Bad DMA channel 3 specified in the configuration utility or by the operating ... */
#define userModeToKernelModeCallError   -10261   /* The user mode code failed when calling the kernel mode code. */
#define noConnectError                  -10340   /* No RTSI or PFI signal/line is connected, or the specified signal and the ... */
#define badConnectError                 -10341   /* The RTSI or PFI signal/line cannot be connected as specified. */
#define multConnectError                -10342   /* The specified RTSI signal is already being driven by a RTSI line, or the ... */
#define SCXIConfigError                 -10343   /* The specified SCXI configuration parameters are invalid, or the function ... */
#define chassisSynchedError             -10344   /* The Remote SCXI unit is not synchronized with the host. Reset the chassis ... */
#define chassisMemAllocError            -10345   /* The required amount of memory cannot be allocated on the Remote SCXI unit ... */
#define badPacketError                  -10346   /* The packet received by the Remote SCXI unit is invalid.  Check your serial ... */
#define chassisCommunicationError       -10347   /* There was an error in sending a packet to the remote chassis.  Check your ... */
#define waitingForReprogError           -10348   /* The Remote SCXI unit is in reprogramming mode and is waiting for reprogramming ... */
#define SCXIModuleTypeConflictError     -10349   /* The module ID read from the SCXI module conflicts with the configured ... */
#define CannotDetermineEntryModuleError -10350   /* Neither an SCXI entry module (i.e.: the SCXI module cabled to the measurement ... */
#define DSPInitError                    -10360   /* The DSP driver was unable to load the kernel for its operating system. */
#define badScanListError                -10370   /* The scan list is invalid; for example, you are mixing AMUX-64T channels ... */
#define invalidSignalSrcError           -10380   /* The specified signal source is invalid for the selected signal name. */
#define invalidSignalNameError          -10381   /* The specified signal name is invalid. */
#define invalidSrcSpecError             -10382   /* The specified source specification is invalid for the signal source or ... */
#define invalidSignalDestError          -10383   /* The specified signal destination is invalid. */
#define userOwnedRsrcError              -10400   /* The specified resource is owned by the user and cannot be accessed or ... */
#define unknownDeviceError              -10401   /* The specified device is not a National Instruments product, the driver ... */
#define deviceNotFoundError             -10402   /* The specified device is not a National Instruments product, the driver ... */
#define deviceSupportError              -10403   /* The specified device does not support the requested action (the driver ... */
#define noLineAvailError                -10404   /* No line is available. */
#define noChanAvailError                -10405   /* No channel is available. */
#define noGroupAvailError               -10406   /* No group is available. */
#define lineBusyError                   -10407   /* The specified line is in use. */
#define chanBusyError                   -10408   /* The specified channel is in use. */
#define groupBusyError                  -10409   /* The specified group is in use. */
#define relatedLCGBusyError             -10410   /* A related line, channel, or group is in use; if the driver configures ... */
#define counterBusyError                -10411   /* The specified counter is in use. */
#define noGroupAssignError              -10412   /* No group is assigned, or the specified line or channel cannot be assigned ... */
#define groupAssignError                -10413   /* A group is already assigned, or the specified line or channel is already ... */
#define reservedPinError                -10414   /* The selected signal requires a pin that is reserved and configured only ... */
#define externalMuxSupportError         -10415   /* This function does not support your DAQ device when an external multiplexer ... */
#define sysOwnedRsrcError               -10440   /* The specified resource is owned by the driver and cannot be accessed or ... */
#define memConfigError                  -10441   /* No memory is configured to support the current data-transfer mode, or ... */
#define memDisabledError                -10442   /* The specified memory is disabled or is unavailable given the current addressing ... */
#define memAlignmentError               -10443   /* The transfer buffer is not aligned properly for the current data-transfer ... */
#define memFullError                    -10444   /* No more system memory is available on the heap, or no more memory is available ... */
#define memLockError                    -10445   /* The transfer buffer cannot be locked into physical memory. On PC AT machines, ... */
#define memPageError                    -10446   /* The transfer buffer contains a page break; system resources may require ... */
#define memPageLockError                -10447   /* The operating environment is unable to grant a page lock. */
#define stackMemError                   -10448   /* The operating environment is unable to grant a page lock. */
#define cacheMemError                   -10449   /* A cache-related error occurred, or caching is not supported in the current ... */
#define physicalMemError                -10450   /* A hardware error occurred in physical memory, or no memory is located ... */
#define virtualMemError                 -10451   /* The driver is unable to make the transfer buffer contiguous in virtual ... */
#define noIntAvailError                 -10452   /* No interrupt level is available for use. */
#define intInUseError                   -10453   /* The specified interrupt level is already in use by another device. */
#define noDMACError                     -10454   /* No DMA controller is available in the system. */
#define noDMAAvailError                 -10455   /* No DMA channel is available for use. */
#define DMAInUseError                   -10456   /* The specified DMA channel is already in use by another device. */
#define badDMAGroupError                -10457   /* DMA cannot be configured for the specified group because it is too small, ... */
#define diskFullError                   -10458   /* The storage disk you specified is full. */
#define DLLInterfaceError               -10459   /* The NI-DAQ DLL could not be called due to an interface error. */
#define interfaceInteractionError       -10460   /* You have mixed VIs from the DAQ library and the _DAQ compatibility library ... */
#define resourceReservedError           -10461   /* The specified resource is unavailable because it has already been reserved ... */
#define resourceNotReservedError        -10462   /* The specified resource is unavailable because it has already been reserved ... */
#define mdResourceAlreadyReservedError  -10463   /* Another entity has already reserved the requested resource.  */
#define mdResourceReservedError         -10464   /* Another entity has already reserved the requested resource.  */
#define mdResourceNotReservedError      -10465   /* Attempting to lift a reservation off a resouce that previously had no ... */
#define mdResourceAccessKeyError        -10466   /* The requested operation cannot be performed because the key supplied is ... */
#define mdResourceNotRegisteredError    -10467   /* The resource requested is not registered with the minidriver. */
#define muxMemFullError                 -10480   /* The resource requested is not registered with the minidriver. */
#define bufferNotInterleavedError       -10481   /* You must provide a single buffer of interleaved data, and the channels ... */
#define SCXIModuleNotSupportedError     -10540   /* You must provide a single buffer of interleaved data, and the channels ... */
#define TRIG1ResourceConflict           -10541   /* CTRB1 will drive COUTB1, however CTRB1 will also drive TRIG1.  This may ... */
#define matrixTerminalBlockError        -10542   /* This function requires that no Matrix terminal block is configured with ... */
#define noMatrixTerminalBlockError      -10543   /* This function requires that some matrix terminal block is configured with ... */
#define invalidMatrixTerminalBlockError -10544   /* The type of matrix terminal block configured will not allow proper operation ... */
#define invalidDSPHandleError           -10560   /* The DSP handle input is not valid . */
#define DSPDataPathBusyError            -10561   /* Either DAQ or WFM can use a PC memory buffer, but not both at the same ... */
#define noSetupError                    -10600   /* No setup operation has been performed for the specified resources. Or, ... */
#define multSetupError                  -10601   /* No setup operation has been performed for the specified resources. Or, ... */
#define noWriteError                    -10602   /* No output data has been written into the transfer buffer. */
#define groupWriteError                 -10603   /* The output data associated with a group must be for a single channel or ... */
#define activeWriteError                -10604   /* Once data generation has started, only the transfer buffers originally ... */
#define endWriteError                   -10605   /* No data was written to the transfer buffer because the final data block ... */
#define notArmedError                   -10606   /* The specified resource is not armed. */
#define armedError                      -10607   /* The specified resource is already armed. */
#define noTransferInProgError           -10608   /* No transfer is in progress for the specified resource. */
#define transferInProgError             -10609   /* A transfer is already in progress for the specified resource, or the operation ... */
#define transferPauseError              -10610   /* A single output channel in a group may not be paused if the output data ... */
#define badDirOnSomeLinesError          -10611   /* Some of the lines in the specified channel are not configured for the ... */
#define badLineDirError                 -10612   /* The specified line does not support the specified transfer direction. */
#define badChanDirError                 -10613   /* The specified channel does not support the specified transfer direction, ... */
#define badGroupDirError                -10614   /* The specified group does not support the specified transfer direction. */
#define masterClkError                  -10615   /* The clock configuration for the clock master is invalid. */
#define slaveClkError                   -10616   /* The clock configuration for the clock slave is invalid. */
#define noClkSrcError                   -10617   /* No source signal has been assigned to the clock resource. */
#define badClkSrcError                  -10618   /* The specified source signal cannot be assigned to the clock resource. */
#define multClkSrcError                 -10619   /* A source signal has already been assigned to the clock resource. */
#define noTrigError                     -10620   /* No trigger signal has been assigned to the trigger resource. */
#define badTrigError                    -10621   /* No trigger signal has been assigned to the trigger resource. */
#define preTrigError                    -10622   /* The pretrigger mode is not supported or is not available in the current ... */
#define postTrigError                   -10623   /* No posttrigger source has been assigned. */
#define delayTrigError                  -10624   /* The delayed trigger mode is not supported or is not available in the current ... */
#define masterTrigError                 -10625   /* The trigger configuration for the trigger master is invalid. */
#define slaveTrigError                  -10626   /* The trigger configuration for the trigger slave is invalid. */
#define noTrigDrvError                  -10627   /* No signal has been assigned to the trigger resource. */
#define multTrigDrvError                -10628   /* A signal has already been assigned to the trigger resource. */
#define invalidOpModeError              -10629   /* The specified operating mode is invalid, or the resources have not been ... */
#define invalidReadError                -10630   /* The parameters specified to read data were invalid in the context of the ... */
#define noInfiniteModeError             -10631   /* Continuous input or output transfers are not allowed in the current operating ... */
#define someInputsIgnoredError          -10632   /* Certain inputs were ignored because they are not relevant in the current ... */
#define invalidRegenModeError           -10633   /* The specified analog output regeneration mode is not allowed for this ... */
#define noContTransferInProgressError   -10634   /* No continuous (double buffered) transfer is in progress for the specified ... */
#define invalidSCXIOpModeError          -10635   /* Either the SCXI operating mode specified in a configuration call is invalid, ... */
#define noContWithSynchError            -10636   /* You cannot start a continuous (double-buffered) operation with a synchronous ... */
#define bufferAlreadyConfigError        -10637   /* Attempted to configure a buffer after the buffer had already been configured. ... */
#define badClkDestError                 -10638   /* The clock cannot be assigned to the specified destination.  */
#define rangeBadForMeasModeError        -10670   /* The input range is invalid for the configured measurement mode. */
#define autozeroModeConflictError       -10671   /* Autozero cannot be enabled for the configured measurement mode. */
#define badChanGainError                -10680   /* All channels of this board must have the same gain. */
#define badChanRangeError               -10681   /* All channels of this board must have the same range. */
#define badChanPolarityError            -10682   /* All channels of this board must be the same polarity. */
#define badChanCouplingError            -10683   /* All channels of this board must have the same coupling. */
#define badChanInputModeError           -10684   /* All channels of this board must have the same input mode. */
#define clkExceedsBrdsMaxConvRateError  -10685   /* The clock rate exceeds the board's recommended maximum rate. */
#define scanListInvalidError            -10686   /* A configuration change has invalidated the scan list. */
#define bufferInvalidError              -10687   /* A configuration change has invalidated the acquisition buffer, or an acquisition ... */
#define noTrigEnabledError              -10688   /* The number of total scans and pretrigger scans implies that a triggered ... */
#define digitalTrigBError               -10689   /* Digital trigger B is illegal for the number of total scans and pretrigger ... */
#define digitalTrigAandBError           -10690   /* This board does not allow digital triggers A and B to be enabled at the ... */
#define extConvRestrictionError         -10691   /* This board does not allow an external sample clock with an external scan ... */
#define chanClockDisabledError          -10692   /* This board does not allow an external sample clock with an external scan ... */
#define extScanClockError               -10693   /* You cannot use an external scan clock when doing a single scan of a single ... */
#define unsafeSamplingFreqError         -10694   /* The scan rate is above the maximum or below the minimum for the hardware, ... */
#define DMAnotAllowedError              -10695   /* You have set up an operation that requires the use of interrupts.  DMA ... */
#define multiRateModeError              -10696   /* Multi-rate scanning cannot be used with the AMUX-64, SCXI, or pretriggered ... */
#define rateNotSupportedError           -10697   /* Unable to convert your timebase/interval pair to match the actual hardware ... */
#define timebaseConflictError           -10698   /* You cannot use this combination of scan and sample clock timebases for ... */
#define polarityConflictError           -10699   /* You cannot use this combination of scan and sample clock source polarities ... */
#define signalConflictError             -10700   /* You cannot use this combination of scan and convert clock signal sources ... */
#define noLaterUpdateError              -10701   /* The call had no effect because the specified channel had not been set ... */
#define prePostTriggerError             -10702   /* Pretriggering and posttriggering cannot be used simultaneously on the ... */
#define noHandshakeModeError            -10710   /* The specified port has not been configured for handshaking. */
#define noEventCtrError                 -10720   /* The specified counter is not configured for event-counting operation. */
#define SCXITrackHoldError              -10740   /* A signal has already been assigned to the SCXI track-and-hold trigger ... */
#define sc2040InputModeError            -10780   /* When you have an SC2040 attached to your device, all analog input channels ... */
#define outputTypeMustBeVoltageError    -10781   /* When you have an SC2040 attached to your device, all analog input channels ... */
#define sc2040HoldModeError             -10782   /* The specified operation cannot be performed with the SC-2040 configured ... */
#define calConstPolarityConflictError   -10783   /* Calibration constants in the load area have a different polarity from ... */
#define timeOutError                    -10800   /* The operation could not complete within the time limit. */
#define calibrationError                -10801   /* An error occurred during the calibration process.  Possible reasons for ... */
#define dataNotAvailError               -10802   /* The requested amount of data has not yet been acquired. */
#define transferStoppedError            -10803   /* The on-going transfer has been stopped.   This is to prevent regeneration ... */
#define earlyStopError                  -10804   /* The transfer stopped prior to reaching the end of the transfer buffer. */
#define overRunError                    -10805   /* The clock rate is faster than the hardware can support.  An attempt to ... */
#define noTrigFoundError                -10806   /* No trigger value was found in the input transfer buffer. */
#define earlyTrigError                  -10807   /* The trigger occurred before sufficient pretrigger data was acquired. */
#define LPTcommunicationError           -10808   /* The trigger occurred before sufficient pretrigger data was acquired. */
#define gateSignalError                 -10809   /* Attempted to start a pulse width measurement with the pulse in the phase ... */
#define internalDriverError             -10810   /* An unexpected error occurred inside the driver when performing this given ... */
#define softwareError                   -10840   /* The contents or the location of the driver file was changed between accesses ... */
#define firmwareError                   -10841   /* The firmware does not support the specified operation, or the firmware ... */
#define hardwareError                   -10842   /* The hardware is not responding to the specified operation, or the response ... */
#define underFlowError                  -10843   /* Because of system and/or bus-bandwidth limitations, the driver could not ... */
#define underWriteError                 -10844   /* Your application was unable to deliver data to the background generation ... */
#define overFlowError                   -10845   /* Because of system and/or bus-bandwidth limitations, the driver could not ... */
#define overWriteError                  -10846   /* Your application was unable to retrieve data from the background acquisition ... */
#define dmaChainingError                -10847   /* New buffer information was not available at the time of the DMA chaining ... */
#define noDMACountAvailError            -10848   /* The driver could not obtain a valid reading from the transfer-count register ... */
#define OpenFileError                   -10849   /* The configuration file or DSP kernel file could not be opened. */
#define closeFileError                  -10850   /* Unable to close a file. */
#define fileSeekError                   -10851   /* Unable to seek within a file. */
#define readFileError                   -10852   /* Unable to read from a file. */
#define writeFileError                  -10853   /* Unable to write to a file. */
#define miscFileError                   -10854   /* An error occurred accessing a file. */
#define osUnsupportedError              -10855   /* NI-DAQ does not support the current operation on this particular version ... */
#define osError                         -10856   /* An unexpected error occurred from the operating system while performing ... */
#define internalKernelError             -10857   /* An unexpected error occurred inside the kernel of the device while performing ... */
#define hardwareConfigChangedError      -10858   /* The system has reconfigured the device and has invalidated the existing ... */
#define updateRateChangeError           -10880   /* A change to the update rate is not possible at this time because 1) when ... */
#define partialTransferCompleteError    -10881   /* You cannot do another transfer after a successful partial transfer. */
#define daqPollDataLossError            -10882   /* The data collected on the Remote SCXI unit was overwritten before it could ... */
#define wfmPollDataLossError            -10883   /* New data could not be transferred to the waveform buffer of the Remote ... */
#define pretrigReorderError             -10884   /* Could not rearrange data after a pretrigger acquisition completed. */
#define overLoadError                   -10885   /* The input signal exceeded the input range of the ADC. */
#define gpctrDataLossError              -10920   /* One or more data points may have been lost during buffered GPCTR operations ... */
#define chassisResponseTimeoutError     -10940   /* No response was received from the Remote SCXI unit within the specified ... */
#define reprogrammingFailedError        -10941   /* Reprogramming the Remote SCXI unit was unsuccessful. Please try again. */
#define invalidResetSignatureError      -10942   /* Reprogramming the Remote SCXI unit was unsuccessful. Please try again. */
#define chassisLockupError              -10943   /* The interrupt service routine on the remote SCXI unit is taking longer ... */

/*
   Please look in olderror.h to find the mapping of old error codes to new
*/
#include "olderror.h" /* Included for backwards compatibility */

#endif /* ___nidaqerr_h___ */
