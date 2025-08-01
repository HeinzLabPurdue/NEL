% ABR Instruction Block
% May be able to delete case where type=CAP, so that ABR only

global RunThroughABRFlag
if ~RunThroughABRFlag
    interface_type=questdlg('Select interface type:','','CAP','ABR','FFR','CAP'); %KH 10Jan2012
else 
    interface_type='ABR';
end

if strcmp(interface_type,'FFR')
    command_str='close';
end

switch interface_type
   
	case 'CAP'
   
		misc = struct( ... 
           'fileExtension', 'CAP1f' ...
          ); 
      
		Stimuli = struct( ...
           'freq_hz',2000, ...
           'atten_dB', 40, ...
           'fast', struct( ...
                  'duration_ms', 10, ...
                  'rftime_ms',  1, ...
                  'period_ms',  80, ...
                  'XstartPlot_ms',0, ...
                  'XendPlot_ms',25, ...
                  'CAPlength_ms',25), ...
           'slow', struct( ...
                  'duration_ms', 250, ...
                  'rftime_ms',  1, ...
                  'period_ms',  500, ...
                  'XstartPlot_ms',0, ...
                  'XendPlot_ms',500, ...
                  'CAPlength_ms',500), ...
           'fixedPhase', 0,  ...
           'channel',   3, ...
           'KHosc',     0, ...
           'fmult',    10, ...
           'CAPmem_reps',  30, ...
           'threshV', 2, ... %for artifact rejection KH 2012 Jan 05
           'clickYes', 0, ... % added by KH 06Jan2012
           'clickLength_ms', 0.04, ... %KH 10Jan2012
           ... %not cleaned up yet
           'ear', 'both' ...  % set in CAP.m
           );
	
		RunLevels_params = struct( ... 
           'nPairs', 300, ...
           'stepdB', 5, ...
           'attenMask', [12:-1:0], ...
           'audiogramFreqs', [500 1000 2000 4000 8000], ... %KH 10Jan2012
           'decimateFact', 1, ...
           'saveRepsYes', 1, ... %added by KH 6
           'bMultiOutputFiles', 0 ...  % added by GE 26Apr2004.
          ); 
   
      Display = struct( ... 
         'Gain', 1000, ...  
         'YLim_atAD', 0.8, ...
         'Voltage', 'atELEC' ...
         ); 
      
   case 'ABR'

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
         'nPairs', 1000,...
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
         'nPairs', 500, ... 
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
     
 end

Stimuli.RPsamprate_Hz=12207.03125;  % Hard coded for now, eventually get from RP
              
% MH/GE 11/03/03: eventually add a param for AD channel
