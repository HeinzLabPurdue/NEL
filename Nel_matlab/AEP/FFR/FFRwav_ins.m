% FFR Instruction Block
function [misc,Stimuli, RunLevels_params, Display, interface_type]=FFRwav_ins(NelData)

usr = NelData.General.User;

if exist([NelData.General.RootDir 'Signals\' usr filesep 'FFR\'],'dir') >= 1
    FFRwavStimDir=[NelData.General.RootDir 'Signals\',usr,'\FFR\'];
    fName=dir(FFRwavStimDir);
    
else
    FFRwavStimDir=[NelData.General.RootDir '\Nel_matlab\AEP\FFR\Signals\FFRwav\'];
    fName=dir(FFRwavStimDir);
    
end

fName=cell2struct({fName(3:end).name},'name'); 

interface_type = 'FFRwav'; 

% interface_type = 'SPIKES';
%            'filename','C:\NEL_debug\Nel_matlab\FFR\object\tone.wav',...

switch interface_type
    case 'FFRwav'
        misc = struct( ...
            'fileExtension', 'FFR_', ...
            'n',0 ...%zz oct2011
            );
        
        Stimuli = struct( ...
            'pol',1,...%zz 31oct2011
            'list',fName, ...
            'filename',fName(1).name,...
            ...%'freq_hz',2000, ...
            'atten_dB', 10, ...
            'calibPicNum', nan, ... % Calib pic number: will populated before free-run loop
            'calib_dBSPLout', nan, ... % Ouptut in dB SPL after calibration filtering 
            'NoiseType',0,... % 0 for stationary, 1 for fluctuating
            'maxSPL', 90, ...
            'STIMfile', [NelData.General.RootDir 'Nel_matlab\AEP\FFR\Signals\tone_org.wav'], ...
            'UPDdir', [NelData.General.RootDir 'Nel_matlab\AEP\FFR\Signals\FFRwav_resamp\'], ... (copy resampled files here)
            'OLDDir', FFRwavStimDir, ... (from here)
            'rec_channel', 1, ... 
            ...
            ...
            'fast', struct( ...
            ... %zz 17jan12
            'duration_ms', 1300, ... % 1728 for pilot
            'rftime_ms',  10, ...
            'period_ms',  1801, ... 
            'XstartPlot_ms',0, ...
            'XendPlot_ms',1500, ... % 2000 for pilot, 1800 for short 
            'FFRlength_ms',1500), ... % 2000 for pilot, 1800 for short 
            ...
            ...
            'slow', struct( ...
            ...% ZZ 18nov11
            'duration_ms', 1300, ... % AEH 1/27/14 500 ms 
            'rftime_ms',  10, ...
            'period_ms',  2728, ... % AEH 1/27/14 750 ms 
            'XstartPlot_ms',0, ...
            'XendPlot_ms', 2728, ...
            'FFRlength_ms',1750), ...
            ...%'fixedPhase', 1,  ...
            ...
            'channel',   3, ...
            'KHosc',     0, ...
            'fmult',    10, ...
            'FFRmem_reps',  20, ... %Temporary change by VMA 7/17/23 from 100
            'threshV', 10, ... (.4) %for artifact rejection KH 2011 Jun 08
            ... %not cleaned up yet
            'threshV2', 10,...
            'ear', 'right' ...  % needs to match default in loop_plot
            );
        
        RunLevels_params = struct( ...
            'nPairs', 5, ...
            'nPairs_actual', 1, ... %gets saved as how many were actually run if quitting and saving early
            'doneStims', zeros(length(fName),1), ...
            'stepdB', 0, ...
            'attenMask', 0, ...
            'decimateFact', 1, ...
            'bMultiOutputFiles', 0 ...  % added by GE 26Apr2004.
            );
        
        Display = struct( ...
            'Gain', 2e4,... 20000, ...
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
            'filename', [NelData.General.RootDir 'Nel_matlab\AEP\FFR\Signals\tone_org.wav'],...%zz 31oct2011
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

