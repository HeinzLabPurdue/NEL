%% ABR Parameters
% This file sets all ABR parameters into stimuli, RunLevels, Display, and
% AutoLevels_params structs
% 7/29/22 SH and VMA

misc = struct( ... 
 'fileExtension', 'ABR' ...
  ); 

Stimuli = struct( ...
 'freq_hz',1000, ...
 'calibPicNum', nan, ... % Calib pic number: will populated before free-run loop 
 ... % Note: whether to use invCalib or not will depend on calib pic num. If calib-picname has 
 ... % "raw", do not run inv Calib. If it has "inv", run inverse calib. Should make invCalib default. 
 'atten_dB',    35, ...
 'fast', struct( ...
        'duration_ms', 10, ... % will change to cycles eventually
        'rftime_ms',  1, ... % will also be cycles eventually
        'period_ms',  40,...% = 32.2 31.1 Hz rate
        'XstartPlot_ms',0, ...
        'XendPlot_ms',31, ...
        'CAPlength_ms',31), ...       
 'slow', struct( ...
        'duration_ms', 10, ...
        'rftime_ms',  1, ...
        'period_ms',  100, ... % 19.6, ... % = 51.1 Hz rate
        'XstartPlot_ms',0, ...
        'XendPlot_ms',31, ...
        'CAPlength_ms',31), ...
 'fixedPhase', 0,  ...
 'channel',   1, ...
 'MaxdBSPLCalib',   90, ...
 'KHosc',     0, ...
 'fmult',    10, ...
 'CalibBelow90', 0, ...
 'CAPmem_reps',  20, ...
 'threshV', 1.2, ... %for artifact rejection KH 2011 Jun 08
 'threshV2', 1.2,... % for artifact rejection channel 2 JMR nov 21
 'clickYes', 1, ... % added by KH 06Jan2012
 'clickLength_ms', 0.05, ... %KH 10Jan2012
 ... 
 'ear', 'right', ... 
 'rec_channel',3 ... % set recording channel (1=chan 1, 2= chan 2, 3 = Simultaneous) %JMR nov 21
 );

RunLevels_params = struct( ... 
 'nPairs', 500,...
 'stepdB', 10, ...
... %        'attenMask', [2 1 0 -1 -2 -3], ...
 'attenMask', [0], ...
 'decimateFact', 1, ...
 'saveRepsYes', 0, ... %added by KH 6
 'bMultiOutputFiles', 0 ...
 ); 

Display = struct( ... 
 'Gain', 20000, ...  
 'YLim_atAD', 0.1, ...
 'Voltage', 'atAD' ...
 ); 

AutoLevel_params = struct ( ...  %%added by SP 
 'ManThresh_dBSPL', 35, ...  % fill in with look up table eventually for NormHearing
 'nPairs', 300, ... 
 'stepdB', 10, ... %20, 10 for thresholds
 'attenMask', [], ...
 'decimateFact', 1, ...
 'saveRepsYes', 0, ... %added by KH 6
 'bMultiOutputFiles', 1, ...
 'maxdBSPLtoRUN', 80, ... 
 'ReRunFlag', 0, ...
 'dB5Flag', 0, ...
 'ReRun_dBSPL', [], ...
 'dB_below_thresh', 20, ...         % min number of dB to go below manual threshold in stepdB steps in auto list
 'dBaboveTHRman_for_autoTHRcorr', 30, ... %number of dB above manual threshold estimate to use as template in Ken's corr code
 'dBs2RUN',[] ...%what are the dB values to run based on manThresh, MaxCalibValue
 ); 


