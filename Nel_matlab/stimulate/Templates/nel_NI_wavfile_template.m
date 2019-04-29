function [tmplt,DAL,stimulus_vals,units,errstr] = nel_NI_wavfile_template(fieldname,stimulus_vals,units)
%  Written by GE, adapted from 'nel_wavefile_template' written by AF (11/26/01).
%  Modification dates: 03oct2003, 04oct2003.

% persistent   prev_playdur  prev_min_period  % GE debug: not really necessary???
% We use the persistent variables to detect a change that requires some fields update.
% For example, if the play duration is changed we would like to update the gating information.
% We restict the automatic updates to allow the user the overide them.

used_devices.File         = 'L3';    % ge debug: what if R3 is used also?
tmplt = template_definition;
if (exist('stimulus_vals','var') == 1)
   if (exist(stimulus_vals.Inloop.File,'file') ~= 0)
      list = {stimulus_vals.Inloop.File};
      [data fs] = wavread(stimulus_vals.Inloop.File);
   else
      list = {};
   end
  
   [stimulus_vals units] = NI_check_gating_params(stimulus_vals, units);
   
   Inloop.Name                         = 'DALinloop_NI_wavfiles';
   Inloop.params.list                  = list;
   Inloop.params.attens                = stimulus_vals.Inloop.High_Attenuation :-1:stimulus_vals.Inloop.Low_Attenuation;
   Inloop.params.Rlist                 = []; % GE debug: will need to implement 2 channels eventually.
   Inloop.params.Rattens               = []; %      "
   Inloop.params.repetitions           = stimulus_vals.Inloop.Repetitions;
   stimulus_vals.Inloop.UpdateRate = NI6052UsableRate_Hz(stimulus_vals.Inloop.UpdateRate); % GE/MH 04Nov2003:
                                       % Template forces use of a rate that is valid for the NI6052e board in the
                                       %  mode in which it is called (see 'd2a.c').
   Inloop.params.updateRate_Hz         = stimulus_vals.Inloop.UpdateRate;
   
   DAL.funcName = 'data_acquisition_loop_NI'; % added by GE 30oct2003.
   DAL.Inloop = Inloop;
   DAL.Gating = stimulus_vals.Gating;
   DAL.Mix         = mix_params2devs(stimulus_vals.Mix,used_devices); % GE debug: see 'used_devices.File' line at beginning of function
   DAL.short_description   = 'Wav_NIboard';
   DAL.description = build_description(DAL,stimulus_vals);
   errstr = check_DAL_params(DAL,fieldname);
end

%----------------------------------------------------------------------------------------
function str = build_description(DAL,stimulus_vals)
p = DAL.Inloop.params;
[fpath,file] = fileparts(stimulus_vals.Inloop.File);
str{1} = sprintf('File ''%s'' ', file);
if (length(p.attens) > 1)
   str{1} = sprintf('%s @ %1.1f - %1.1f dB Attn.', str{1}, p.attens(1), p.attens(end));
else
   str{1} = sprintf('%s @ %1.1f dB Attn.', str{1}, p.attens(1));
end
str{1} = sprintf('%s (%s)', str{1}, stimulus_vals.Mix.File);
str{1} = sprintf('%s   Update rate: %.0f Hz', str{1}, stimulus_vals.Inloop.UpdateRate);
%----------------------------------------------------------------------------------------
function errstr = check_DAL_params(DAL,fieldname)
% Some extra error checks
errstr = '';
if (isequal(fieldname,'Inloop'))
   if (isempty(DAL.Inloop.params.attens))
      errstr = 'Attenuations are not set correctly! (high vs. low mismatch?)';
   end
end

%----------------------------------------------------------------------------------------
function tmplt = template_definition
global signals_dir
%%%%%%%%%%%%%%%%%%%%
%% Inloop Section 
%%%%%%%%%%%%%%%%%%%%
IO_def.Inloop.File              = { {['uigetfile(''' signals_dir '*.wav'')']} };
IO_def.Inloop.Low_Attenuation   = { 1             'dB'    [0    120]      };
IO_def.Inloop.High_Attenuation  = { 100           'dB'    [0    120]      };
IO_def.Inloop.Repetitions       = { 1             ''      [1    Inf]      };
IO_def.Inloop.UpdateRate     = {100e3        'Hz'   [1 NI6052UsableRate_Hz(Inf)]  };

%%%%%%%%%%%%%%%%%%%%
%% Gating Section 
%%%%%%%%%%%%%%%%%%%%
IO_def.Gating.Duration             = {300       'ms'    [20 2000]};
IO_def.Gating.Period               = {'default_period(this.Duration)'    'ms'   [50 5000]};
IO_def.Gating.Rise_fall_time       = {'default_rise_time(this.Duration)' 'ms'   [0  1000]};

%%%%%%%%%%%%%%%%%%%%
%% Mix Section 
%%%%%%%%%%%%%%%%%%%%
IO_def.Mix.File        =  {'Left|Both|{Right}'};

tmplt.tag               = 'NELwavfile_NI_tmplt';
tmplt.IO_def = IO_def;
