% FFR Instruction Block
function [misc,Stimuli, RunLevels_params, Display, interface_type]=FFR_SNRenv_ins(NelData)

% SNRenvStimDir='C:\NEL2\Users\SP\SNRenv_stimuli\stimSetStationary\'; %
% This was the data dir for pilot data before DTU. (Q313 and Q314).

SNRenvStimDir=[NelData.General.RootDir 'Users\SP\SNRenv_stimuli\FFRSNRenv_short_stationary_org\'];
% This is new.


interface_type = 'FFR_SNRenv'; % ge debug ABR
% interface_type = 'SPIKES';
%            'filename','C:\NEL_debug\Nel_matlab\FFR\object\tone.wav',...
switch interface_type
    case 'FFR_SNRenv'
        misc = struct( ...
            'fileExtension', 'FFR_SNRenv', ...
            'n',0 ...%zz oct2011
            );
        
        %         fName=load([fileparts(SNRenvStimDir(1:end-1)) filesep 'SNRenv_stimlist14.mat']); % for Pilot SFR
        fName=load([fileparts(SNRenvStimDir(1:end-1)) filesep 'SNRenv_stimlist_short.mat']);
        fName=fName.SNRenv_stimlist;
        
        Stimuli = struct( ...
            'pol',1,...%zz 31oct2011
            'list',fName, ...
            'filename',fName(1).name,...
            ...%'freq_hz',2000, ...
            'atten_dB', 10, ...
            'NoiseType',0,... % 0 for stationary, 1 for fluctuating
            'maxSPL', 90, ...
            'STIMfile', [NelData.General.RootDir 'Nel_matlab\FFR\Signals\tone_org.wav'], ...
            'UPDdir', [NelData.General.RootDir 'Nel_matlab\FFR\FFRSNRenv_short_stationary_run\'], ... (copy resampled files here)
            'OLDDir', SNRenvStimDir, ... (from here)
            ...
            ...
            'fast', struct( ...
            ... %zz 17jan12
            'duration_ms', 1300, ... % 1728 for pilot, 1300 for short
            'rftime_ms',  10, ...
            'period_ms',  1800, ...
            'XstartPlot_ms',0, ...
            'XendPlot_ms',1600, ... % 2000 for pilot, 1800 for short
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
            'FFRmem_reps',  100, ...
            'threshV', 100, ... (.4) %for artifact rejection KH 2011 Jun 08
            ... %not cleaned up yet
            'ear', 'both' ...  % set in FFR.m
            );
        
        RunLevels_params = struct( ...
            'nPairs', 5, ...
            'nPairs_actual', 5, ...
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
            'filename', [NelData.General.RootDir 'Nel_matlab\FFR\object\tone_org.wav'],...%zz 31oct2011
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
            'nPairs', 5, ...
            'nPairs_actual', 5, ...
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
% Stimuli.RPsamprate_Hz=12207.03125*4;
% Stimuli.RPsamprate_Hz=12207.03125;  % Hard coded for now, eventually get from RP


Stimuli.RPsamprate_Hz=25e6/512; %48828.125  % Hard coded for now, eventually get from RP