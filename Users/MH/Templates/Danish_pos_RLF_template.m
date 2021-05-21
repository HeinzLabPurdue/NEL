function [tmplt,DAL,stimulus_vals,units,errstr] = Danish_pos_RLF_template(fieldname,stimulus_vals,units)
% MH 11Apr2005: for R03 project
% Rate-level data with 20 reps for SAC analysis
% Steps through several levels
%
% From EHrlv_template
%    Rate-level function for features at BF for a BASELINE EH with F2 at BF and F0=75 Hz
%
% From EH_reBF_template and EH_template (CNexps)
%   - kept same params as for EH_reBF, but hardwired OCTshift to 0
%
% Template for EH-vowel RLFs, using NI board to allow resampling
%
% MH 07Nov2003, modified from 'nel_NI_wavefile_template'
%
%  Written by GE, adapted from 'nel_wavefile_template' written by AF (11/26/01).
%  Modification dates: 03oct2003, 04oct2003.

% persistent   prev_playdur  prev_min_period  % GE debug: not really necessary???
% We use the persistent variables to detect a change that requires some fields update.
% For example, if the play duration is changed we would like to update the gating information.
% We restict the automatic updates to allow the user the overide them.

used_devices.File         = 'L3';    % ge debug: what if R3 is used also?
tmplt = template_definition(fieldname);
if (exist('stimulus_vals','var') == 1)
    
    PolarityFact=(strcmp(stimulus_vals.Inloop.InvertPolarity, 'yes') - .5)*-2;  % For inverting waveform if necessary
    list = {stimulus_vals.Inloop.File};
    [noise, BASELINE_Fs] = audioread(stimulus_vals.Inloop.File);
    noise=noise*PolarityFact;  % Invert if necessary
    [stimulus_vals, units] = NI_check_gating_params(stimulus_vals, units);
    dBreTONE=20*log10(sqrt(mean(noise.^2))/.707);
    
    if (BASELINE_Fs> NI6052UsableRate_Hz(Inf))
        stimulus_vals.Inloop.Used_UpdateRate_Hz=NI6052UsableRate_Hz(Inf);
        nelerror('In SACrlv_template: Requested sampling rate greater than MAX rate allowed by NI board!!');
    end
    stimulus_vals.Inloop.Used_UpdateRate_Hz = NI6052UsableRate_Hz(BASELINE_Fs); % GE/MH 04Nov2003:
    
    Inloop.Name                         = 'DALinloop_NI_SCC_wavfiles';
    Inloop.params.list                  = list;
    
    Inloop.params.Condition.InvertPolarity              = stimulus_vals.Inloop.InvertPolarity;
    Inloop.params.Condition.High_dBSPL            = stimulus_vals.Inloop.High_dBSPL;
    Inloop.params.Condition.Low_dBSPL             = stimulus_vals.Inloop.Low_dBSPL;
    Inloop.params.Condition.dBstep                = stimulus_vals.Inloop.dBstep;
    
    Inloop.params.BASELINE.FileName           = stimulus_vals.Inloop.File;
    Inloop.params.BASELINE.dBreTONE           = dBreTONE;
    Inloop.params.BASELINE.Fs_Hz              = BASELINE_Fs;
    Inloop.params.Used_UpdateRate_Hz   = stimulus_vals.Inloop.Used_UpdateRate_Hz;
    
    
    Inloop.params.Rlist                 = []; % GE debug: will need to implement 2 channels eventually.
    Inloop.params.Rattens               = []; %      "
    Inloop.params.repetitions           = stimulus_vals.Inloop.Repetitions;
    Inloop.params.CalibPicNum          = stimulus_vals.Inloop.CalibPicNum;
    
    Inloop.params.origstimUpdateRate_Hz = BASELINE_Fs;
    Inloop.params.updateRate_Hz         = stimulus_vals.Inloop.Used_UpdateRate_Hz;
    
    %% updating to use calib filter at all freqs instead of just at CF calib: (Nov 28, 2018) [SP]
    audio_fName=stimulus_vals.Inloop.File;
    cdd;
    plotYes=0 ;
    verbose=0;
    
    % SP: Should use this
    %       |
    %       V
    % [filteredSPL, ~]=CalibFilter_outSPL(audio_fName, stimulus_vals.Inloop.CalibPicNum, plotYes, verbose);
    
    calibFiles= dir('*calib*');
    calib_picNum= getPicNum(calibFiles(end).name);
    
    [filteredSPL, ~]=CalibFilter_outSPL(audio_fName, calib_picNum, plotYes, verbose);
    tempAtten= round((filteredSPL - (stimulus_vals.Inloop.Low_dBSPL : stimulus_vals.Inloop.dBstep: stimulus_vals.Inloop.High_dBSPL)));
    if min(tempAtten)<0
        warning('Max dB SPL = %.1f. Cannot go up to 80 dB SPL\n', filteredSPL);
        tempAtten= tempAtten(tempAtten>=0);
    end
    Inloop.params.attens= tempAtten;
    Inloop.params.attens= Inloop.params.attens(randsample(numel(Inloop.params.attens), numel(Inloop.params.attens)));

    rdd;
    
    if Inloop.params.attens<0
        CalibOFFSET=Inloop.params.attens;
        ding   % can't make it loud enough - setup as REAL error, to log in NEL file.
        warndlg(sprintf('ATTEN set to 0 - UNABLE TO get loud enough (by %.1f dB)',CalibOFFSET))
        pause(1)
        ding
        pause(1)
        ding
        Inloop.params.attens=0;
    end
    
    DAL.funcName = 'data_acquisition_loop_NI_marker'; % added by GE 30oct2003.
    DAL.Inloop = Inloop;
    DAL.Gating = stimulus_vals.Gating;
    DAL.Mix         = mix_params2devs(stimulus_vals.Mix,used_devices); % GE debug: see 'used_devices.File' line at beginning of function
    DAL.short_description   = 'Danish_pos_rlf';
    
    %   DAL.endLinePlotParams                  = nel_plot_pst_params(DAL.Gating.Period/1000, DAL.Gating.Duration/1000);  % GE 04Nov2003.
    
    DAL.description = build_description(DAL,stimulus_vals);
    errstr = check_DAL_params(DAL,fieldname);
end

%----------------------------------------------------------------------------------------
function str = build_description(DAL,stimulus_vals)
p = DAL.Inloop.params;
[fpath,file] = fileparts(stimulus_vals.Inloop.File);
str{1} = sprintf('RLF %dreps:', p.repetitions);
str{1} = sprintf('%s ''%s''', str{1},file);
str{1} = sprintf('%s (%s),', str{1}, stimulus_vals.Mix.File(1));
if (length(p.attens) > 1)
    str{1} = sprintf('%s %1.f-%1.f dBatt (%1.1f step)', str{1}, p.attens(1), p.attens(end), diff(p.attens(1:2)));
else
    str{1} = sprintf('%s %1.1f dB Attn.', str{1}, p.attens);
end
str{1} = sprintf('%s Urate: %.0f Hz,', str{1}, stimulus_vals.Inloop.Used_UpdateRate_Hz);
if strcmp(stimulus_vals.Inloop.InvertPolarity,'yes')
    str{1} = sprintf('%s (Pol:-)', str{1});
else
    str{1} = sprintf('%s (Pol:+)', str{1});
end

%----------------------------------------------------------------------------------------
function errstr = check_DAL_params(DAL,fieldname)
% Some extra error checks
errstr = '';
if (isequal(fieldname,'Inloop'))
    if (isempty(DAL.Inloop.params.attens))
        errstr = 'Attenuations are not set correctly! (high vs. low mismatch?)';
    elseif (DAL.Inloop.params.attens<0)
        errstr = sprintf('Negative Attenuation of %.1f dB cannot be set, Level must be lowered',DAL.Inloop.params.attens);
    elseif (DAL.Inloop.params.attens>120)
        errstr = sprintf('Attenuation of %.1f dB cannot be set, Level must be raised',DAL.Inloop.params.attens);
    end
end

%----------------------------------------------------------------------------------------
function tmplt = template_definition(~)
global signals_dir

cdd;
calibFiles= dir('*calib*');
calib_picNum= getPicNum(calibFiles(end).name);
rdd;

%%%%%%%%%%%%%%%%%%%%
%% Inloop Section
%%%%%%%%%%%%%%%%%%%%
IO_def.Inloop.File           = { fullfile(signals_dir,'MH','Env_Level_Coding','Danish_Speech_HRTFed_S_P.wav') '' [] 1 };
IO_def.Inloop.CalibPicNum    =  {calib_picNum   ''       [0 6000]};
IO_def.Inloop.Low_dBSPL      = { 0             'dB'    [0    120]      };
IO_def.Inloop.High_dBSPL     = { 75           'dB'    [0    120]      };
IO_def.Inloop.dBstep         = { 1           'dB'    [1    120]      };
IO_def.Inloop.Repetitions    =  {1   ''       [1 600]};
IO_def.Inloop.InvertPolarity =  {'{no}|yes'};

%%%%%%%%%%%%%%%%%%%%
%% Gating Section
%%%%%%%%%%%%%%%%%%%%
IO_def.Gating.Duration             = {1300       'ms'    [20 4000]};
IO_def.Gating.Period               = {1800    'ms'   [50 5000]};
% IO_def.Gating.Period               = {'default_period(this.Duration)'    'ms'   [50 5000]};
IO_def.Gating.Rise_fall_time       = {'default_rise_time(this.Duration)' 'ms'   [0  1000]};

%%%%%%%%%%%%%%%%%%%%
%% Mix Section
%%%%%%%%%%%%%%%%%%%%
IO_def.Mix.File        =  {'Left|Both|{Right}'};

tmplt.tag               = 'Danish_pos_rlf';
tmplt.IO_def = IO_def;
