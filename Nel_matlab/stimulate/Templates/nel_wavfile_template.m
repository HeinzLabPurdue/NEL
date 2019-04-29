function [tmplt,DAL,stimulus_vals,units,errstr] = nel_wavfile_template(fieldname,stimulus_vals,units)
%

% AF 11/26/01
persistent   prev_playdur  prev_min_period
% We use the persistent variables to detect a change that requires some fields update.
% For example, of the play duration is changed we would like to update the gating information.
% We restict the automatic updates to allow the user the overide them.

used_devices.File         = 'RP1.1';
tmplt = template_definition;
if (exist('stimulus_vals','var') == 1)
   if (exist(stimulus_vals.Inloop.File,'file') ~= 0)
      list = {stimulus_vals.Inloop.File};
      [data fs] = wavread(stimulus_vals.Inloop.File);
      playback_rate = 97656.25/(round(97656.25/fs)); % 97656.25 is the rco's sampling rate
      if (~isnan(stimulus_vals.Inloop.Resample_Ratio) & ~isempty(stimulus_vals.Inloop.Resample_Ratio))
         playdur = round(stimulus_vals.Inloop.Resample_Ratio*length(data)/playback_rate*1000);	%compute file duration based on sampling rate
      else
         playdur = round(length(data)/playback_rate*1000);	%compute file duration based on sampling rate
      end
      min_period = max(1000,ceil(1.7*playdur/100)*100);
      
      %% In this template we have to change the Gating parameters according to 
      %% the playback duration of the wav files.
      %% We do this by first, updating the relevant template definitions, and second,
      %% by calling 'structdlg' in its non-interactive invisible mode, to recalculated 'stimulus_vals' fields.
      %
      if (isequal(fieldname,'Inloop') | ~isequal(playdur,prev_playdur) | ~isequal(min_period,prev_min_period))
         tmplt.IO_def.Gating.Duration{1}  = playdur;
         tmplt.IO_def.Gating.Period{1}    = ['max(' num2str(min_period) ',default_period(this.Duration))'];
         [stimulus_vals.Gating units.Gating] = structdlg(tmplt.IO_def.Gating,'',[],'off');
         prev_playdur = playdur;
         prev_min_period = min_period;
      end
   else
      list = {};
   end
   
   Inloop.Name                         = 'DALinloop_wavfiles';
   Inloop.params.list                  = list;
   Inloop.params.attens                = stimulus_vals.Inloop.High_Attenuation :-1:stimulus_vals.Inloop.Low_Attenuation;
   Inloop.params.Rlist                 = [];
   Inloop.params.Rattens               = [];
   Inloop.params.repetitions           = stimulus_vals.Inloop.Repetitions;
   Inloop.params.resample_ratio        = stimulus_vals.Inloop.Resample_Ratio;
   Inloop.params.playback_slowdown     = 1;
   
   DAL.Inloop = Inloop;
   DAL.Gating = stimulus_vals.Gating;
   DAL.Mix         = mix_params2devs(stimulus_vals.Mix,used_devices);
   DAL.short_description   = 'Wav';
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
IO_def.Inloop.Resample_Ratio    = { NaN           ''      [0.05    4]      };


%%%%%%%%%%%%%%%%%%%%
%% Gating Section 
%%%%%%%%%%%%%%%%%%%%
IO_def.Gating.Duration             = {200       'ms'    [20 2000]};
IO_def.Gating.Period               = {'default_period(this.Duration)'    'ms'   [50 5000]};
% IO_def.Gating.Rise_fall_time       = {'default_rise_time(this.Duration)' 'ms'   [0  1000]}; 

%%%%%%%%%%%%%%%%%%%%
%% Mix Section 
%%%%%%%%%%%%%%%%%%%%
IO_def.Mix.File        =  {'Left|Both|{Right}'};

tmplt.tag               = 'NELwavfile_tmplt';
tmplt.IO_def = IO_def;
