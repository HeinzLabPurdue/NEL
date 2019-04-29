function [tmplt,DAL,stimulus_vals,units,errstr] = pedestals_template(fieldname,stimulus_vals,units)
%

% AF 11/26/01

used_devices.Tone       = 'RP1.1';
tmplt = template_definition(fieldname);
if (exist('stimulus_vals','var') == 1)
   Inloop.Name                           = 'DALinloop_pedestals';
   Inloop.params.freq                    = stimulus_vals.Inloop.Frequency*1000;
   Inloop.params.ramp_attn               = stimulus_vals.Inloop.Ramp_Attenuation;
   Inloop.params.ramp_dur                = stimulus_vals.Inloop.Ramp_Duration;
   Inloop.params.ped_delay               = stimulus_vals.Inloop.Pedestal_Delay;
   Inloop.params.ped_dur                 = stimulus_vals.Inloop.Ramp_Duration - 2*stimulus_vals.Inloop.Pedestal_Delay;
   Inloop.params.ped_rts                 = stimulus_vals.Inloop.Pedestal_Rise_Times;
   Inloop.params.ped_steps               = stimulus_vals.Inloop.Pedestal_Level_Steps;
   Inloop.params.repetitions             = stimulus_vals.Inloop.Repetitions;

   DAL.Inloop = Inloop;
   DAL.Gating = stimulus_vals.Gating;
   DAL.short_description   = 'Ped';

   tmplt.IO_def.Gating.Duration{1}  = Inloop.params.ramp_dur;
   [stimulus_vals.Gating units.Gating] = structdlg(tmplt.IO_def.Gating,'',[],'off');
   DAL.Mix         = mix_params2devs(stimulus_vals.Mix,used_devices);

   DAL.description = build_description(DAL,stimulus_vals);
   errstr = check_DAL_params(DAL,fieldname);
end

%----------------------------------------------------------------------------------------
function str = build_description(DAL,stimulus_vals)
p = DAL.Inloop.params;
str{1} = sprintf('%1.2f kHz %d ms Ramp @ %1.1f dB', p.freq/1000, p.ramp_dur, p.ramp_attn);
str{1} = sprintf('%s with (%d,%d) ms Ped.', str{1}, p.ped_delay, p.ped_dur);
str{2} = ['steps=[' deblank(sprintf('%1.0f ',p.ped_steps)) ']  RT=[' ...
      deblank(sprintf('%1.0f ',p.ped_rts)) ']'];
str{2} = sprintf('%s (%s)', str{2}, stimulus_vals.Mix.Tone);

%----------------------------------------------------------------------------------------
function errstr = check_DAL_params(DAL,fieldname)
% Some extra error checks
errstr = '';
if (isequal(fieldname,'Inloop'))
   if (isempty(DAL.Inloop.params.freq))
      errstr = 'Tone Frequency is empty!)';
   end
end

%----------------------------------------------------------------------------------------
function tmplt = template_definition(fieldname)
persistent prev_unit_bf prev_unit_thresh
%%%%%%%%%%%%%%%%%%%%
%% Inloop Section 
%%%%%%%%%%%%%%%%%%%%
IO_def.Inloop.Frequency           =  {'current_unit_bf'        'kHz'      [0.04  50]   0  0}; 
IO_def.Inloop.Ramp_Attenuation    =  {'current_unit_thresh-10' 'dB'       [0    120]   0  0};
IO_def.Inloop.Ramp_Duration       =  { 600                     'ms'       [400    2000]};
IO_def.Inloop.Pedestal_Delay      =  { 200                     'ms'       [50     1000]};
IO_def.Inloop.Pedestal_Rise_Times =  { [2 5 10 25 50]          'ms'       [1      100]};
IO_def.Inloop.Pedestal_Level_Steps=  { [6 9 12 16.5 21]      'dB'       [0      80]};
IO_def.Inloop.Repetitions         =  { 4                       ''         [1     100]};

if (isequal(fieldname,'Inloop'))
   if (~isequal(current_unit_bf, prev_unit_bf))
      IO_def.Inloop.Frequency{5}            = 1; % ignore dflt. Always recalculate.
      prev_unit_bf = current_unit_bf;
   end
   if (~isequal(current_unit_thresh, prev_unit_thresh))
      IO_def.Inloop.Ramp_Attenuation{5}            = 1;
      prev_unit_thresh = current_unit_thresh;
   end
end

%%%%%%%%%%%%%%%%%%%%
%% Gating Section 
%%%%%%%%%%%%%%%%%%%%
IO_def.Gating.Duration         = {600       'ms'    [20 2000]};
IO_def.Gating.Period           = {'default_period(this.Duration)'    'ms'   [50 5000]};
IO_def.Gating.Rise_fall_time   = {'default_rise_time(this.Duration)' 'ms'   [0  1000]}; 

%%%%%%%%%%%%%%%%%%%%
%% Mix Section 
%%%%%%%%%%%%%%%%%%%%
IO_def.Mix.Tone      =  {'{Left}|Both|Right'};

tmplt.tag         = 'LRAF_Ped_tmplt';
tmplt.IO_def = IO_def;
