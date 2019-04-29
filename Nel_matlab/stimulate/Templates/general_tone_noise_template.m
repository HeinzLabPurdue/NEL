function [tmplt,DAL,stimulus_vals,units,errstr] = general_tone_noise_template(fieldname,stimulus_vals,units)
%

% AF 11/26/01

used_devices.Main       = 'RP1.1';
used_devices.Background = 'RP2.1';
tmplt = template_definition(fieldname);
if (exist('stimulus_vals','var') == 1)
   Inloop.Name                               = 'DALinloop_general_TN';
   Inloop.params.main.source                 = stimulus_vals.Inloop.Source;
   Inloop.params.main.tone.freq              = stimulus_vals.Inloop.Tone.Frequency*1000;
   Inloop.params.main.tone.bw                = stimulus_vals.Inloop.Tone.Bandwidth;
   Inloop.params.main.noise.low_cutoff       = stimulus_vals.Inloop.Noise.Low_Cutoff*1000;
   Inloop.params.main.noise.high_cutoff      = stimulus_vals.Inloop.Noise.High_Cutoff*1000;
   Inloop.params.main.attens                 = stimulus_vals.Inloop.High_Attenuation :-1:stimulus_vals.Inloop.Low_Attenuation;
   Inloop.params.secondary.source            = stimulus_vals.Inloop.Background.Source;
   Inloop.params.secondary.tone.freq         = stimulus_vals.Inloop.Background.Tone.Frequency*1000;
   Inloop.params.secondary.noise.low_cutoff  = stimulus_vals.Inloop.Background.Noise.Low_Cutoff*1000;
   Inloop.params.secondary.noise.high_cutoff = stimulus_vals.Inloop.Background.Noise.High_Cutoff*1000;
   Inloop.params.secondary.noise.gating      = stimulus_vals.Inloop.Background.Noise.Gating;
   Inloop.params.secondary.noise.adaptation  = stimulus_vals.Inloop.Background.Noise.Adaptation;
   Inloop.params.secondary.atten             = stimulus_vals.Inloop.Background.Attenuation;
   Inloop.params.rise_fall                   = stimulus_vals.Gating.Rise_fall_time;

   DAL.Inloop = Inloop;
   DAL.Gating = stimulus_vals.Gating;
   DAL.short_description   = '';

   %% In this complex template we have to change the Mix parameters according to 
   %% the main and background settings.
   tmplt.IO_def.Mix.Main{2} = stimulus_vals.Inloop.Source; % Update "unit" name (to display 'tone' or 'noise')
   if (strcmp(stimulus_vals.Inloop.Background.Source,'None'))
      tmplt.IO_def.Mix = rmfield(tmplt.IO_def.Mix,'Background');
   else
      tmplt.IO_def.Mix.Background{2} = stimulus_vals.Inloop.Background.Source; % Update "unit" name
   end
   [stimulus_vals.Mix units.Mix] = structdlg(tmplt.IO_def.Mix,'',stimulus_vals.Mix,'off');
   DAL.Mix         = mix_params2devs(stimulus_vals.Mix,used_devices);

   DAL.description = build_description(DAL,stimulus_vals);
   errstr = check_DAL_params(DAL,fieldname);
end

%----------------------------------------------------------------------------------------
function str = build_description(DAL,stimulus_vals)
p = DAL.Inloop.params;
switch (p.main.source)
case 'Tone'
   if (p.main.tone.bw > 0)
      str{1} = sprintf('%1.1f oct. sweep around %1.2f kHz', p.main.tone.bw, p.main.tone.freq/1000);
   else
      str{1} = sprintf('%1.2f kHz Tone', p.main.tone.freq/1000);
   end
case 'Noise'
   str{1} = sprintf('%1.2f - %1.2f kHz Noise ', p.main.noise.low_cutoff/1000, p.main.noise.high_cutoff/1000);
end

if (length(p.main.attens) > 1)
   str{1} = sprintf('%s @ %1.1f - %1.1f dB Attn.', str{1}, p.main.attens(1), p.main.attens(end));
elseif (length(p.main.attens) == 1)  %LQ 02/07/05 
   str{1} = sprintf('%s @ %1.1f dB Attn.', str{1}, p.main.attens(1));
end
str{1} = sprintf('%s (%s)', str{1}, stimulus_vals.Mix.Main);

switch (p.secondary.source)
case 'None'
   str{2} = '';
   return;
case 'Tone'
   str{2} = sprintf('Background %1.2f kHz Tone @ %1.1 dB Attn.', p.secondary.tone.freq/1000, p.secondary.atten);
case 'Noise'
   str{2} = sprintf('Background Noise (%1.2f-%1.2f kHz) @ %1.1f dB Attn.', p.secondary.noise.low_cutoff/1000, ...
      p.secondary.noise.high_cutoff/1000, p.secondary.atten);
end
str{2} = sprintf('%s (%s)', str{2}, stimulus_vals.Mix.Background);


%----------------------------------------------------------------------------------------
function errstr = check_DAL_params(DAL,fieldname)
% Some extra error checks
errstr = '';
if (isequal(fieldname,'Inloop'))
   if (DAL.Inloop.params.main.tone.bw > 0 & length(DAL.Inloop.params.main.attens) > 1)
      errstr = 'Can''t run frequency sweeps with multiple attenuations!';
   end
   if (isempty(DAL.Inloop.params.main.attens))
      errstr = 'Attenuations are not set correctly! (high vs. low mismatch?)';
   end
   if (isempty(DAL.Inloop.params.main.tone.freq))
      errstr = 'Tone Frequency is empty!';
   end
   if (isequal(DAL.Inloop.params.secondary.source,'Tone') & isempty(DAL.Inloop.params.secondary.tone.freq))
      errstr = 'Background Tone Frequency is empty!';
   end
end

%----------------------------------------------------------------------------------------
function tmplt = template_definition(fieldname)
persistent prev_unit_bf prev_unit_thresh
%%%%%%%%%%%%%%%%%%%%
%% Inloop Section 
%%%%%%%%%%%%%%%%%%%%
IO_def.Inloop.Source            =  {'{Tone}|Noise'};
IO_def.Inloop.Tone.Frequency    =  {'current_unit_bf'   'kHz'      [0.04  50]   0  0}; 
IO_def.Inloop.Tone.Bandwidth    =  { 0                  'oct'      [0    Inf]       };
IO_def.Inloop.Noise.Low_Cutoff  =  { 0                  'kHz'      [0    50]        };
IO_def.Inloop.Noise.High_Cutoff =  { 50                 'kHz'      [0    50]        };
IO_def.Inloop.Low_Attenuation   =  { 1                  'dB'       [0    120]       };
IO_def.Inloop.High_Attenuation  =  { 100                'dB'       [0    120]       };

IO_def.Inloop.Background.Source            =  {'Tone|{Noise}|None'};
IO_def.Inloop.Background.Tone.Frequency    =  {'current_unit_bf'    'kHz'      [0.04  50]  0  0};
IO_def.Inloop.Background.Noise.Low_Cutoff  =  { 0                   'kHz'      [0     50]      };
IO_def.Inloop.Background.Noise.High_Cutoff =  { 50                  'kHz'      [0     50]      };
IO_def.Inloop.Background.Noise.High_Cutoff =  { 50                  'kHz'      [0     50]      };
IO_def.Inloop.Background.Noise.Gating      =  {'{Positive}|Negative|Continuous'                };
IO_def.Inloop.Background.Noise.Adaptation  =  { 0                   'sec'       [0    180]      };
IO_def.Inloop.Background.Attenuation       =  { 'current_unit_thresh-3' 'dB'   [0    120]  0  0};

if (isequal(fieldname,'Inloop'))
   if (~isequal(current_unit_bf, prev_unit_bf))
      IO_def.Inloop.Tone.Frequency{5}            = 1; % ignore dflt. Always recalculate.
      IO_def.Inloop.Background.Tone.Frequency{5} = 1;
      prev_unit_bf = current_unit_bf;
   end
   if (~isequal(current_unit_thresh, prev_unit_thresh))
      IO_def.Inloop.Background.Attenuation{5} = 1;% ignore dflt. Always recalculate.
      prev_unit_thresh = current_unit_thresh;
   end
end

%%%%%%%%%%%%%%%%%%%%
%% Gating Section 
%%%%%%%%%%%%%%%%%%%%
IO_def.Gating.Duration         = {200       'ms'    [20 2000]};
IO_def.Gating.Period           = {'default_period(this.Duration)'    'ms'   [50 5000]};
IO_def.Gating.Rise_fall_time   = {'default_rise_time(this.Duration)' 'ms'   [0  1000]}; 

%%%%%%%%%%%%%%%%%%%%
%% Mix Section 
%%%%%%%%%%%%%%%%%%%%
IO_def.Mix.Main      =  {'Left|Both|{Right}'};
IO_def.Mix.Background = {'Left|Both|{Right}|None'};

tmplt.tag         = 'NELgeneral_TN_tmplt';
tmplt.IO_def = IO_def;
