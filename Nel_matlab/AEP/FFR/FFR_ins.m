%FFR Instruction Block
global interface_type

interface_type = 'FFR';
switch interface_type
    case 'FFR'
        misc = struct( ...
            'fileExtension', 'FFR1f', ...
            'n',0 ...%zz oct2011
            );
        
        Stimuli = struct( ...
            'fc',1000,...%zz 31oct2011
            'fm',140,...%zz 31oct2011
            ...%'dur',1,...%zz 31oct2011
            'pol',1,...%zz 31oct2011
            'mod',1,...
            'filename', [NelData.General.RootDir 'Nel_matlab\AEP\FFR\Signals\AMwav\tone_org.wav'],...%zz 31oct2011
            ...%'freq_hz',2000, ...
            'atten_dB', 40, ...
            'noiseLevel', 10, ...
            'noNoise',1,...
            'fast', struct( ...
            ... %zz 17jan12
            'duration_ms', 150, ...
            'rftime_ms',  10, ...s
            'period_ms',  200, ...
            'XstartPlot_ms',0, ...
            'XendPlot_ms',180, ...
            'FFRlength_ms',180), ...
            'slow', struct( ...
            ...% ZZ 18nov11
            'duration_ms', 150, ... % AEH 1/27/14 500 ms
            'rftime_ms',  10, ...
            'period_ms',  250, ... % AEH 1/27/14 750 ms
            'XstartPlot_ms',0, ...
            'XendPlot_ms', 180, ...
            'FFRlength_ms',180), ...
            ...%'fixedPhase', 1,  ...
            'channel',   3, ...
            'KHosc',     0, ...
            'fmult',    10, ...
            'FFRmem_reps',  100, ...
            'threshV', 0.4, ... %for artifact rejection KH 2011 Jun 08
            ... %not cleaned up yet
            'ear', 'both' ...  % set in FFR.m
            );
        
        RunLevels_params = struct( ...
            'nPairs', 150, ...
            'nPairs_actual', 150, ...
            'stepdB', 5, ...
            'attenMask', [0], ...
            'decimateFact', 1, ...
            'bMultiOutputFiles', 0 ...  % added by GE 26Apr2004.
            );
        
        Display = struct( ...
            'Gain', 20000, ...
            'YLim_atAD', 0.1, ...
            'Voltage', 'atELEC' ...
            );
        
    case 'SPIKES'
        
        misc = struct( ...
            'fileExtension', 'SPIKES', ...
            'n',0 ...%zz oct2011
            );
        
        Stimuli = struct( ...
            'fc',1000,...%zz 31oct2011
            'fm',140,...%zz 31oct2011
            ...%'dur',1,...%zz 31oct2011
            'pol',1,...%zz 31oct2011
            'mod',1,...
            'filename', [NelData.General.RootDir 'Nel_matlab\AEP\FFR\object\tone_org.wav'],...%zz 31oct2011
            ...%'freq_hz',2000, ...
            'atten_dB', 40, ...
            'noNoise', 1, ...
            'noiseLevel', 10, ...
            'fast', struct( ...
            ... %zz 17jan12
            'duration_ms', 500, ...
            'rftime_ms',  10, ...
            'period_ms',  1000, ...
            'XstartPlot_ms',0, ...
            'XendPlot_ms',1000, ...
            'FFRlength_ms',600), ...
            'slow', struct( ...
            ...% ZZ 18nov11
            'duration_ms', 250, ...     % stim duration
            'rftime_ms',  10, ...
            'period_ms',  1000, ...     % repetition period
            'XstartPlot_ms',0, ...
            'XendPlot_ms',500, ...      % plotting duration
            'FFRlength_ms',300), ...    % recording time
            ...%'fixedPhase', 1,  ...
            'channel',   3, ...
            'KHosc',     0, ...
            'fmult',    10, ...
            'FFRmem_reps',  100, ...
            'threshV', 0.4, ... %for artifact rejection KH 2011 Jun 08
            ... %not cleaned up yet
            'ear', 'both' ...  % set in FFR.m
            );
        
        RunLevels_params = struct( ...
            'nPairs', 3, ...
            'nPairs_actual', 3, ...
            'stepdB', 5, ...
            'attenMask', 0, ...
            'decimateFact', 1, ...
            'bMultiOutputFiles', 0 ...  % added by GE 26Apr2004.
            );
        
        Display = struct( ...
            'Gain', 20000, ...
            'YLim_atAD', 0.1, ...
            'Voltage', 'atELEC', ...
            'PlotFactor', 1 ...
            );
end

Stimuli.RPsamprate_Hz=50e6/1024; %48828.125  % Hard coded for now, eventually get from RP

% AEH Fs for HTC stimuli 1/27/14
% Stimuli.RPsamprate_Hz=25e6/1024; %24...

% MH/GE 11/03/03: eventually add a param for AD channel
