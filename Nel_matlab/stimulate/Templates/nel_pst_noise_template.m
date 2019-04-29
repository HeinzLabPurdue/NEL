function [tmplt,DAL,stimulus_vals,units,errstr] = nel_pst_noise_template(fieldname,stimulus_vals,units)
%

% adapted from "nel_pst_template.m", by GE, 29Mar2002.

used_devices.Tone       = 'RP1.1';
tmplt = template_definition(fieldname);
if (exist('stimulus_vals','var') == 1)
   Inloop.Name                               = 'DALinloop_general_TN_delay';  % modified by GE (22Nov2002)
   Inloop.params.repetitions                 = stimulus_vals.Inloop.Repetitions;
   Inloop.params.main.source                 = 'Noise';
   Inloop.params.main.tone.freq              = 0;
   Inloop.params.main.tone.bw                = 0;
   Inloop.params.main.noise.low_cutoff       = stimulus_vals.Inloop.Low_Cutoff*1000;     % modified by GE, 27Mar2002.
   Inloop.params.main.noise.high_cutoff      = stimulus_vals.Inloop.High_Cutoff*1000;     % modified by GE, 27Mar2002.
   Inloop.params.main.attens                 = stimulus_vals.Inloop.Attenuation;
   Inloop.params.secondary.source            = 'None';
   Inloop.params.secondary.tone.freq         = 0;
   Inloop.params.secondary.noise.low_cutoff  = 0;
   Inloop.params.secondary.noise.high_cutoff = 0;
   Inloop.params.secondary.noise.gating      = '';
   Inloop.params.secondary.noise.adaptation  = 0;
   Inloop.params.secondary.atten             = [];
   Inloop.params.rise_fall                   = 0;
%   Inloop.params.noise_delay                 = 0;  

   DAL.Inloop = Inloop;
   DAL.Gating = stimulus_vals.Gating;
   DAL.short_description   = 'PST_noise';
   DAL.endLinePlotParams                  = nel_plot_pst_params(DAL.Gating.Period/1000, DAL.Gating.Duration/1000);  % GE 04Nov2003.

   % [stimulus_vals.Mix units.Mix] = structdlg(tmplt.IO_def.Mix,'',stimulus_vals.Mix,'off');
   DAL.Mix         = mix_params2devs(stimulus_vals.Mix,used_devices);

   DAL.description = build_description(DAL,stimulus_vals);
   errstr = check_DAL_params(DAL,fieldname);
end

%----------------------------------------------------------------------------------------
function str = build_description(DAL,stimulus_vals)
p = DAL.Inloop.params;
str{1} = sprintf('PST %d Repetitions', p.repetitions);
str{1} = sprintf('%s %1.2f - %1.2f kHz Noise ', str{1}, p.main.noise.low_cutoff/1000, p.main.noise.high_cutoff/1000);
str{1} = sprintf('%s @ %1.1f dB Attn.', str{1}, p.main.attens);
str{1} = sprintf('%s (%s)', str{1}, stimulus_vals.Mix.Tone);

%----------------------------------------------------------------------------------------
function errstr = check_DAL_params(DAL,fieldname)
% Some extra error checks
errstr = '';
if (isequal(fieldname,'Inloop'))
   if (isempty(DAL.Inloop.params.main.attens))
      errstr = 'Attenuations are not set correctly! (high vs. low mismatch?)';
   end
end

%----------------------------------------------------------------------------------------
function tmplt = template_definition(fieldname)
persistent prev_unit_bf prev_unit_thresh
%%%%%%%%%%%%%%%%%%%%
%% Inloop Section 
%%%%%%%%%%%%%%%%%%%%

IO_def.Inloop.Low_Cutoff  =  { 0                  'kHz'      [0    50]        };
IO_def.Inloop.High_Cutoff =  { 50                 'kHz'      [0    50]        };
IO_def.Inloop.Attenuation  =  {'current_unit_thresh-20' 'dB'       [0    120]   0  0}; 

IO_def.Inloop.Repetitions  =  {300   ''       [1 600]}; 

if (isequal(fieldname,'Inloop'))
   if (~isequal(current_unit_thresh, prev_unit_thresh))
      IO_def.Inloop.Attenuation{5}     = 1;
      prev_unit_thresh = current_unit_thresh;
   end
end

%%%%%%%%%%%%%%%%%%%%
%% Gating Section 
%%%%%%%%%%%%%%%%%%%%
IO_def.Gating.Duration         = {50       'ms'    [20 2000]};
IO_def.Gating.Period           = {'default_period(this.Duration)'    'ms'   [50 5000]};
%IO_def.Gating.Rise_fall_time   = {'default_rise_time(this.Duration)' 'ms'   [0  1000]};
%IO_def.Gating.Noise_Delay      = {0.02        'ms'    [0.02 10000]}; % added by GE (22Nov2002)

%%%%%%%%%%%%%%%%%%%%
%% Mix Section 
%%%%%%%%%%%%%%%%%%%%
IO_def.Mix.Tone      =  {'{Left}|Both|Right'};

tmplt.tag         = 'NELpstNoise_tmplt';
tmplt.IO_def = IO_def;
