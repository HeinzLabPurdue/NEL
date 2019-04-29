function [tmplt,DAL,stimulus_vals,units,errstr] = cmr_trapez_template(fieldname,stimulus_vals,units)
%

% AF 3/22/02

used_devices.Noise   = 'RP2.1';
used_devices.Tone    = 'RP2.2';
tmplt = template_definition(fieldname);
if (exist('stimulus_vals','var') == 1)
   attens = [120 stimulus_vals.Inloop.Attenuation_Start - [0 cumsum(repmat(...
            stimulus_vals.Inloop.Attenuation_Step,1,stimulus_vals.Inloop.Number_of_Steps-2))]];
   freq_bw = stimulus_vals.Inloop.Noise_BW;
   if (isstr(freq_bw))
      freq_bw = str2num(freq_bw);
   end
   
   Inloop.Name                   = 'DALinloop_cmr_trapez';
   Inloop.params.noise_atten     = stimulus_vals.Inloop.Noise_Attenuation;
   Inloop.params.tone_attens     = attens;
   Inloop.params.freq            = stimulus_vals.Inloop.Frequency*1000;
   Inloop.params.low_cutoff      = Inloop.params.freq * 2^(-freq_bw/2);
   Inloop.params.high_cutoff     = Inloop.params.freq * 2^(freq_bw/2);
   if (stimulus_vals.Inloop.Modulated_Noise)
      Inloop.params.noise_high_time = 40;
      Inloop.params.noise_modulation_number = 0;
   else
      Inloop.params.noise_high_time = stimulus_vals.Gating.Duration-10;
      Inloop.params.noise_modulation_number = 1;
   end
   Inloop.params.tone_delay      = stimulus_vals.Inloop.Tone_Delay;
   Inloop.params.tone_dur        = 275;
   Inloop.params.repetitions     = stimulus_vals.Inloop.Repetitions;

   DAL.Inloop = Inloop;
   DAL.Gating = stimulus_vals.Gating;
   DAL.short_description   = 'CMR_TR';

   % [stimulus_vals.Mix units.Mix] = structdlg(tmplt.IO_def.Mix,'',stimulus_vals.Mix,'off');
   DAL.Mix         = mix_params2devs(stimulus_vals.Mix,used_devices);

   DAL.description = build_description(DAL,stimulus_vals);
   errstr = check_DAL_params(DAL,fieldname);
end

%----------------------------------------------------------------------------------------
function str = build_description(DAL,stimulus_vals)
p = DAL.Inloop.params;
str{1} = sprintf('%1.2f-%1.2f kHz Noise', p.low_cutoff/1000, p.high_cutoff/1000);
str{1} = sprintf('%s @ %1.1f dB Attn.', str{1}, p.noise_atten);
str{1} = sprintf('%s (%s)', str{1}, stimulus_vals.Mix.Noise);
if (~isempty(p.tone_attens))
   str{2} = sprintf(' + %1.2f kHz Tone @ [%1.1f %1.1f %1.1f ... %1.1f]', p.freq/1000, p.tone_attens([1:3 end]));
   str{2} = sprintf('%s (%s)', str{2}, stimulus_vals.Mix.Tone);
end
%----------------------------------------------------------------------------------------
function errstr = check_DAL_params(DAL,fieldname)
% Some extra error checks
errstr = '';
if (isequal(fieldname,'Inloop'))
   if (isempty(DAL.Inloop.params.tone_attens))
      errstr = 'Attenuations are not set correctly!';
   end
   if (any(DAL.Inloop.params.tone_attens < 0))
      errstr = 'Negative Tone Attenuations! Change the ''Start'' or the ''Step'' of the tone Attenuation';
   end
   if (~(DAL.Inloop.params.low_cutoff < DAL.Inloop.params.high_cutoff)) % Catches empty cutoffs as well
      errstr = 'Cutoff frequencies are not set correctly!';
   end   
end

%----------------------------------------------------------------------------------------
function tmplt = template_definition(fieldname)
%%%%%%%%%%%%%%%%%%%%
%% Inloop Section 
%%%%%%%%%%%%%%%%%%%%
persistent prev_unit_bf prev_unit_thresh

IO_def.Inloop.Frequency           =  {'current_unit_bf'        'kHz'      [0.04  50]   0  0}; 
IO_def.Inloop.Attenuation_Start   =  {'current_unit_thresh+20' 'dB'       [0    120]   0  0};
IO_def.Inloop.Noise_Attenuation   =  {40                       'dB'       [0    120] };
IO_def.Inloop.Noise_BW            =  { {'1/32' '1/16' '1/8' '1/4' '1/2' '1' '{2}'} 'oct'};
IO_def.Inloop.Noise_Attenuation   =  {40                       'dB'       [0    120] };
IO_def.Inloop.Modulated_Noise     =  { {'0' '{1}'} };

IO_def.Inloop.Tone_Delay          =  {275                      'ms'       [250  300]  };
IO_def.Inloop.Attenuation_Step    =  {3                        'dB'       [1    10]   };
IO_def.Inloop.Number_of_Steps     =  {20                       ''         [2    100]  };
IO_def.Inloop.Repetitions         =  {'ceil(100/this.Number_of_Steps)' ''         [1    100]  };

if (isequal(fieldname,'Inloop'))
   if (~isequal(current_unit_bf, prev_unit_bf))
      IO_def.Inloop.Frequency{5}            = 1; % ignore dflt. recalculate.
      prev_unit_bf = current_unit_bf;
   end
   if (~isequal(current_unit_thresh, prev_unit_thresh))
      IO_def.Inloop.Attenuation_Start{5}            = 1; % ignore dflt. recalculate.
      prev_unit_thresh = current_unit_thresh;
   end
end

%%%%%%%%%%%%%%%%%%%%
%% Gating Section 
%%%%%%%%%%%%%%%%%%%%
IO_def.Gating.Duration         = {700       'ms'    [20 2000]};
IO_def.Gating.Period           = {1500    'ms'   [50 5000]};
IO_def.Gating.Rise_fall_time   = {'default_rise_time(this.Duration)' 'ms'   [0  1000]}; 

%%%%%%%%%%%%%%%%%%%%
%% Mix Section 
%%%%%%%%%%%%%%%%%%%%
IO_def.Mix.Noise      =  {'Left|Both|{Right}'};
IO_def.Mix.Tone       =  {'Left|Both|{Right}'};

tmplt.tag         = 'LR_AF_cmr_tr_tmplt';
tmplt.IO_def = IO_def;
