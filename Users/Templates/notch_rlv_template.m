function [tmplt,DAL,stimulus_vals,units,errstr] = noisebands_template(fieldname,stimulus_vals,units)
%

% LR 11/06/02

used_devices.Tone       = 'RP1.1'; 

tmplt = template_definition(fieldname);
if (exist('stimulus_vals','var') == 1)
   Inloop.Name                            = 'DALinloop_notch_RLV';
   Inloop.params.n_type                   = 'Notch'; 
   Inloop.params.f_cen                  = stimulus_vals.Inloop.Frequency_Center;   %center freq sweep start, kHz
   Inloop.params.band_hbw                 = stimulus_vals.Inloop.Half_Band_Width;   
   Inloop.params.band_ht                  = 30; %dB
   Inloop.params.band_slope               = inf;   

   Inloop.params.sr                       = 97656.25;  %sample rate in Hz
   Inloop.params.repetitions              = 1;
   Inloop.params.dur                       = (2^15)/Inloop.params.sr*1e3;  %msec
   Inloop.params.rt                       = 10;  %msec
   Inloop.params.calib_file               = stimulus_vals.Inloop.Calibration_File;  
   Inloop.params.symmetry               = stimulus_vals.Inloop.Symmetry;  
   Inloop.params.attens                 = stimulus_vals.Inloop.High_Attenuation :-1:stimulus_vals.Inloop.Low_Attenuation;
   
   DAL.Inloop = Inloop;
   DAL.Gating = stimulus_vals.Gating;
   DAL.short_description   = 'NN_RLV';

   DAL.Mix         = mix_params2devs(stimulus_vals.Mix,used_devices);
   
   if strcmp(class(Inloop.params.band_hbw),'char')==1
      hbw=str2num(Inloop.params.band_hbw);
   else
      hbw=Inloop.params.band_hbw;
   end
   fcen=Inloop.params.f_cen;
   if strcmp(Inloop.params.symmetry,'log')==1
      low_cutoff=fcen*2^(-hbw);   %low cutoff (top) in Hz               <-
      high_cutoff=fcen*2^(hbw);     %high cutoff (top) in Hz              ->
   elseif strcmp(Inloop.params.symmetry,'linear')==1
      %       hbw_lin=fcen*(2^hbw-2^(-hbw))/2;  %linear half bandwidth
      hbw_lin=hbw;  %linear half bandwidth as specified
      low_cutoff=fcen-hbw_lin;   %low cutoff (top) in Hz               <-
      high_cutoff=fcen+hbw_lin;     %high cutoff (top) in Hz              ->
   end
   DAL.description = build_description(DAL,stimulus_vals,low_cutoff, high_cutoff);
   errstr = check_DAL_params(DAL,fieldname,low_cutoff, high_cutoff);
   
end

%----------------------------------------------------------------------------------------
function str = build_description(DAL,stimulus_vals,low_cutoff, high_cutoff)
p = DAL.Inloop.params;
str{1} = sprintf('%1.2f - %1.2f kHz Notch Noise ', low_cutoff/1000, high_cutoff/1000);
if (length(p.attens) > 1)
   str{1} = sprintf('%s @ %1.1f - %1.1f dB Attn.', str{1}, p.attens(1), p.attens(end));
else
   str{1} = sprintf('%s @ %1.1f dB Attn.', str{1}, p.attens(1));
end
str{1} = sprintf('%s (%s)', str{1}, stimulus_vals.Mix.Tone);

%----------------------------------------------------------------------------------------
function errstr = check_DAL_params(DAL,fieldname,low_cutoff, high_cutoff)
% Some extra error checks
errstr = '';
if (isequal(fieldname,'Inloop'))
   if (isempty(DAL.Inloop.params.f_cen))
      errstr = 'Center Frequency is empty!)';
   end
   if (isempty(DAL.Inloop.params.band_hbw))
      errstr = 'Half-Bandwidth is empty!)';
   end
   if (isempty(DAL.Inloop.params.attens))
      errstr = 'Attenuation is empty!)';
   end
   if low_cutoff<0 | high_cutoff>DAL.Inloop.params.sr/1e3/2 
      errstr='HBW too large!';
   end
end

%----------------------------------------------------------------------------------------
function tmplt = template_definition(fieldname)
persistent prev_unit_bf prev_unit_thresh
%%%%%%%%%%%%%%%%%%%%
%% Inloop Section 
%%%%%%%%%%%%%%%%%%%%

IO_def.Inloop.Frequency_Center     =  {'current_unit_bf'        'kHz'      [0.04  50]   0  0}; 
IO_def.Inloop.Half_Band_Width     =  { {'0.125' '0.25' '0.5' '1' '2' '4' '8' '16' '1/128' '1/64' '1/32' '1/16' '1/8' '1/4' '1/2' '1' '2' '4'} 'kHz or oct'}; 
IO_def.Inloop.High_Attenuation         =  {100        'dB'      [0 120]   0  0}; 
IO_def.Inloop.Low_Attenuation         =  {0        'dB'      [0 120]   0  0}; 
IO_def.Inloop.Calibration_File    =  { {'none' 'p0001_calib' 'p0002_calib' 'p0003_calib'} ''};
IO_def.Inloop.Symmetry            =  { {'linear' 'log'} ''};

if (isequal(fieldname,'Inloop'))
   if (~isequal(current_unit_bf, prev_unit_bf))
      IO_def.Inloop.Frequency_Center{5}            = 1; % ignore dflt. Always recalculate.
      prev_unit_bf = current_unit_bf;
   end
end

%%%%%%%%%%%%%%%%%%%%
%% Gating Section 
%%%%%%%%%%%%%%%%%%%%
IO_def.Gating.Duration         = {400       'ms'    [20 2000]};
IO_def.Gating.Period           = {'default_period(this.Duration)'    'ms'   [50 5000]};
%IO_def.Gating.Rise_fall_time   = {'default_rise_time(this.Duration)' 'ms'   [0  1000]}; 

%%%%%%%%%%%%%%%%%%%%
%% Mix Section 
%%%%%%%%%%%%%%%%%%%%
IO_def.Mix.Tone      =  {'Left|Both|{Right}'};

tmplt.tag         = 'LRAF_NN_RLV_tmplt';
tmplt.IO_def = IO_def;




