%CAP Instruction Block

% interface_type = 'CAP'; % ge debug ABR
% interface_type = 'ABR';
global RunThroughABRFlag
RunThroughABRFlag=0;
interface_type=questdlg('Select interface type:','','CAP','ABR','FFR','CAP'); %SP 30Jun2016
if strcmp(interface_type,'FFR')
    command_str='close';
end

if strcmp(interface_type,'ABR')
    interface_type=questdlg('Which ABR:','','ABR','ABR New','ABR New'); %SP 30Jun2016
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
                  'period_ms',  50, ...
                  'XstartPlot_ms',0, ...
                  'XendPlot_ms',25, ...
                  'CAPlength_ms',25), ...
           'slow', struct( ...
                  'duration_ms', 10, ...
                  'rftime_ms',  1, ...
                  'period_ms',  250, ...
                  'XstartPlot_ms',0, ...
                  'XendPlot_ms',25, ...
                  'CAPlength_ms',25), ...
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
           'nPairs', 1500, ...
           'stepdB', 5, ...
           'attenMask', [0:-1:0], ...
           'audiogramFreqs', [500 1000 2000 4000 8000], ... %KH 10Jan2012
           'decimateFact', 1, ...
           'saveRepsYes', 1, ... %added by KH 6
           'bMultiOutputFiles', 0 ...  % added by GE 26Apr2004.
          ); 
   
      Display = struct( ... 
         'Gain', 50000, ...  
         'YLim_atAD', 0.8, ...
         'Voltage', 'atELEC' ...
         ); 
      
   case 'ABR'

		misc = struct( ... 
         'fileExtension', 'ABR' ...
          ); 
       
		Stimuli = struct( ...
         'freq_hz',2000, ...
         'atten_dB',    35, ...
         'fast', struct( ...
                'duration_ms', 5, ...
                'rftime_ms',  0.5, ...
                'period_ms',  51, ...
                'XstartPlot_ms',0, ...
                'XendPlot_ms',31, ...
                'CAPlength_ms',31), ...
         'slow', struct( ...
                'duration_ms', 1000, ...  %was 250
                'rftime_ms',  10, ...
                'period_ms',  2000, ...   % was 2000
                'XstartPlot_ms',0, ...
                'XendPlot_ms',500, ...
                'CAPlength_ms',300), ...
         'fixedPhase', 0,  ...
         'channel',   1, ...
         'KHosc',     0, ...
         'fmult',    10, ...
         'CAPmem_reps',  100, ...
         'threshV', 0.2, ... %for artifact rejection KH 2011 Jun 08
         'clickYes', 0, ... % added by KH 06Jan2012
          'clickLength_ms', 0.05, ... %KH 10Jan2012
          ... %not cleaned up yet
         'ear', 'right' ...  % set in CAP.m
         );

      RunLevels_params = struct( ... 
         'nPairs', 500, ...
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
 case 'ABR New'
     RunThroughABRFlag=1;
end

Stimuli.RPsamprate_Hz=12207.03125;  % Hard coded for now, eventually get from RP
% MH/GE 11/03/03: eventually add a param for AD channel