% CAP Instruction Block
global CAP_interface_type

CAP_interface_type = questdlg('Select CAP Measure:','','CAP (RW)','ECochG (EarCanal)','CAP (fMask)','CAP (RW)'); %SP 30Jun2016

switch CAP_interface_type
    
    %% CAP at Round Window
    case 'CAP (RW)'
        
        misc = struct( ...
            'fileExtension', 'CAP1f' ...
            );
        
        Stimuli = struct( ...
            'calibPicNum', nan, ... 
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
            'threshV', 1.2, ... %for artifact rejection KH 2012 Jan 05
            'clickYes', 1, ... % added by KH 06Jan2012
            'clickLength_ms', 0.04, ... %KH 10Jan2012
            ... %not cleaned up yet
            'ear', 'both' ...  % set in CAP.m
            );
        
        RunLevels_params = struct( ...
            'nPairs', 20, ...
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
        
        
        %% Ear Canal ECochG (more reps)
    case 'ECochG (EarCanal)'
        
        misc = struct( ...
            'fileExtension', 'CAP1f' ...
            );
        
        Stimuli = struct( ...
            'calibPicNum', nan, ... 
            'freq_hz',2000, ...
            'atten_dB', 20, ...
            'fast', struct( ...
            'duration_ms', 10, ...
            'rftime_ms',  1, ...
            'period_ms',  43, ...
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
            'CAPmem_reps',  50, ...
            'threshV', 6, ... %for artifact rejection KH 2012 Jan 05
            'clickYes', 1, ... % added by KH 06Jan2012
            'clickLength_ms', 0.04, ... %KH 10Jan2012
            ... %not cleaned up yet
            'ear', 'both' ...  % set in CAP.m
            );
        RunLevels_params = struct( ...
            'nPairs', 1000, ...
            'stepdB', 5, ...
            'attenMask', 0, ...     %[3:-1:-9], ...
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
        
    case 'CAP (fMask)'
       return
end
