function [tmplt,DAL,stimulus_vals,units,errstr] = notch_rlv_template(fieldname,stimulus_vals,units)
% this function generates notch noise RLVs using TDT

% AF 11/26/01

used_devices.Main       = 'RP1.1';
used_devices.Background = 'RP2.1';

tmplt = template_definition;
if (exist('stimulus_vals','var') == 1)
   Inloop.Name                               = 'DALinloop_general_TN';
   Inloop.params.main.source                 = 'Noise';
   Inloop.params.main.tone.freq              = [];
   Inloop.params.main.tone.bw                = [];
   Inloop.params.main.noise.low_cutoff       = 0;
%    Inloop.params.main.noise.high_cutoff      = stimulus_vals.Inloop.Low_notch_freq*1000;
   hbw=str2num(stimulus_vals.Inloop.Half_Band_Width);
   Inloop.params.main.noise.high_cutoff      = stimulus_vals.Inloop.Notch_center_freq*2^(-hbw)*1000;
   Inloop.params.main.attens                 = stimulus_vals.Inloop.High_Attenuation :-1:stimulus_vals.Inloop.Low_Attenuation;
   Inloop.params.secondary.source            = 'Noise';
   Inloop.params.secondary.tone.freq         = 0;
%    Inloop.params.secondary.noise.low_cutoff  = stimulus_vals.Inloop.High_notch_freq*1000;
   Inloop.params.secondary.noise.low_cutoff      = stimulus_vals.Inloop.Notch_center_freq*2^(hbw)*1000;
   Inloop.params.secondary.noise.high_cutoff = 50*1000;
   Inloop.params.secondary.noise.gating      = 'Positive';
   Inloop.params.secondary.noise.adaptation  = 0;
   Inloop.params.secondary.atten             = Inloop.params.main.attens;
   Inloop.params.rise_fall                   = stimulus_vals.Gating.Rise_fall_time;
   
   DAL.Inloop = Inloop;
   DAL.Gating = stimulus_vals.Gating;
   DAL.short_description   = 'NN';

   stimulus_vals.Mix.Background = stimulus_vals.Mix.Main;   
   tmplt.IO_def.Mix.Background  = tmplt.IO_def.Mix.Main;
   
   %% change the Mix parameters according to the main and background settings.
   tmplt.IO_def.Mix.Main{2} = 'Main'; %update unit 
   tmplt.IO_def.Mix.Background{2} = 'Background';
   [stimulus_vals.Mix units.Mix] = structdlg(tmplt.IO_def.Mix,'',stimulus_vals.Mix,'off');
   DAL.Mix         = mix_params2devs(stimulus_vals.Mix,used_devices);

   DAL.description = build_description(DAL,stimulus_vals);
   errstr = check_DAL_params(DAL,fieldname);
end

%----------------------------------------------------------------------------------------
function str = build_description(DAL,stimulus_vals)
p = DAL.Inloop.params;
str{1} = sprintf('%1.2f - %1.2f kHz Notch Noise ', p.main.noise.high_cutoff/1000, p.secondary.noise.low_cutoff/1000);
if (length(p.main.attens) > 1)
   str{1} = sprintf('%s @ %1.1f - %1.1f dB Attn.', str{1}, p.main.attens(1), p.main.attens(end));
else
   str{1} = sprintf('%s @ %1.1f dB Attn.', str{1}, p.main.attens(1));
end
str{1} = sprintf('%s (%s)', str{1}, stimulus_vals.Mix.Main);
%----------------------------------------------------------------------------------------
function errstr = check_DAL_params(DAL,fieldname)
% Some extra error checks
errstr = '';
if (isequal(fieldname,'Inloop'))
   if (isempty(DAL.Inloop.params.main.attens))
      errstr = 'Attenuations are not set correctly! (high vs. low mismatch?)';
   end
   if (~(DAL.Inloop.params.main.noise.high_cutoff < DAL.Inloop.params.secondary.noise.low_cutoff)) % Catches empty cutoffs as well
      errstr = 'Cutoff frequencies are not set correctly! (high vs. low mismatch?)';
   end   
end

%----------------------------------------------------------------------------------------
function tmplt = template_definition
%%%%%%%%%%%%%%%%%%%%
%% Inloop Section 
%%%%%%%%%%%%%%%%%%%%

IO_def.Inloop.Notch_center_freq =  { 'current_unit_bf'    'kHz'      [0    50]};
IO_def.Inloop.Half_Band_Width     =  { {'1/64' '1/32' '1/16' '1/8' '1/4' '1/2' '1/1'} 'oct'}; 
% IO_def.Inloop.Low_notch_freq =  { 'current_unit_bf'    'kHz'      [0    50]};
% IO_def.Inloop.High_notch_freq  =  { 'current_unit_bf'  'kHz'      [0     50]      };
IO_def.Inloop.Low_Attenuation   =  { 1                  'dB'       [0    120]};
IO_def.Inloop.High_Attenuation  =  { 100                'dB'       [0    120]};

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

tmplt.tag         = 'notch_rlv_tmplt';
tmplt.IO_def = IO_def;

