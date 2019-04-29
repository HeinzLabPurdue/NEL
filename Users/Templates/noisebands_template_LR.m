function [tmplt,DAL,stimulus_vals,units,errstr] = noisebands_template_LR(fieldname,stimulus_vals,units)
%

% LR 11/06/02

used_devices.Tone       = 'RP1.1'; 

tmplt = template_definition(fieldname);
if (exist('stimulus_vals','var') == 1)
   Inloop.Name                            = 'DALinloop_noisebands_LR';
   Inloop.params.n_type                   = stimulus_vals.Inloop.Noise_Type; 
   Inloop.params.f_start                  = stimulus_vals.Inloop.Frequency_Start;   %center freq sweep start, kHz
   Inloop.params.f_end                    = stimulus_vals.Inloop.Frequency_End;   %center freq sweep end, kHz
   Inloop.params.f_step                   = stimulus_vals.Inloop.Frequency_Step;   %center freq sweep step, octaves
   Inloop.params.band_hbw                 = stimulus_vals.Inloop.Half_Band_Width;   
   Inloop.params.band_ht                  = stimulus_vals.Inloop.Band_Height; 
   Inloop.params.band_slope               = stimulus_vals.Inloop.Band_Slope;   

   Inloop.params.atten                    = stimulus_vals.Inloop.Attenuation;   
   Inloop.params.sr                       = stimulus_vals.Inloop.Sample_Rate;  %sample rate in Hz
   Inloop.params.repetitions              = stimulus_vals.Inloop.Repetitions;
   Inloop.params.dur                       = stimulus_vals.Inloop.Duration;  
   Inloop.params.rt                       = stimulus_vals.Inloop.Rise_time;  
   Inloop.params.calib_file               = stimulus_vals.Inloop.Calibration_File;  
   Inloop.params.symmetry               = stimulus_vals.Inloop.Symmetry  
   
   DAL.Inloop = Inloop;
   DAL.Gating = stimulus_vals.Gating;
   DAL.short_description   = 'NoiseBands';

   DAL.Mix         = mix_params2devs(stimulus_vals.Mix,used_devices);
   DAL.description = build_description(DAL,stimulus_vals);
   errstr = check_DAL_params(DAL,fieldname);
   
end

%----------------------------------------------------------------------------------------
function str = build_description(DAL,stimulus_vals)
p = DAL.Inloop.params;
str{1} = sprintf('%1.2f-%1.2f kHz %s sweep, %s oct HBW @ %1.1f dB', p.f_start, p.f_end, p.n_type, p.band_hbw, p.atten);
str{1} = sprintf('%s with %.4f oct steps, %d dB/oct slope', str{1}, p.f_step, p.band_slope);
% str{2} = ['steps=[' deblank(sprintf('%1.0f ',p.ped_steps)) ']  RT=[' ...
%       deblank(sprintf('%1.0f ',p.ped_rts)) ']'];
% str{2} = sprintf('%s (%s)', str{2}, stimulus_vals.Mix.Tone);

%----------------------------------------------------------------------------------------
function errstr = check_DAL_params(DAL,fieldname)
% Some extra error checks
errstr = '';
if (isequal(fieldname,'Inloop'))
   if (isempty(DAL.Inloop.params.f_start))
      errstr = 'Sweep Start Frequency is empty!)';
   end
   if (isempty(DAL.Inloop.params.f_end))
      errstr = 'Sweep End Frequency is empty!)';
   end
   if (isempty(DAL.Inloop.params.band_hbw))
      errstr = 'Half-Bandwidth is empty!)';
   end
   if (isempty(DAL.Inloop.params.atten))
      errstr = 'Attenuation is empty!)';
   end
   noctrise=DAL.Inloop.params.band_ht/DAL.Inloop.params.band_slope;   %frequency range of band rise or fall, oct
   hbw=str2num(DAL.Inloop.params.band_hbw);
   fbandmin=DAL.Inloop.params.f_start*2^(-hbw);   %low cutoff (top) in kHz              <-
   fmin=fbandmin*2^(-noctrise); %low cutoff (bottom) in kHz     <---
   if fmin<0
      errstr='HBW too large or start frequency too low!';
   end
   fbandmax=DAL.Inloop.params.f_end*2^(hbw);     %high cutoff (top) in kHz               ->
   fmax=fbandmax*2^(noctrise); %high cutoff (bottom) in kHz      --->
   if fmax>DAL.Inloop.params.sr/1e3/2
      errstr=sprintf('HBW too large or end freq too high! Try %.1f kHz',floor(DAL.Inloop.params.sr/1e3/2/(2^noctrise)/(2^hbw)*10)/10);
   end
   
end

%----------------------------------------------------------------------------------------
function tmplt = template_definition(fieldname)
persistent prev_unit_bf prev_unit_thresh
%%%%%%%%%%%%%%%%%%%%
%% Inloop Section 
%%%%%%%%%%%%%%%%%%%%

IO_def.Inloop.Noise_Type            =  { {'BandPass' 'Notch'} 'Noise Type' }; 
IO_def.Inloop.Frequency_Start     =  {'current_unit_bf/2'        'kHz'      [0.04  50]   0  0}; 
IO_def.Inloop.Frequency_End       =  {'current_unit_bf*2'        'kHz'      [0.04  50]   0  0}; 
IO_def.Inloop.Frequency_Step      =  {'(log(this.Frequency_End/this.Frequency_Start)/log(2))/99'    'oct'   [0.001  1]   0  0}; 
IO_def.Inloop.Half_Band_Width     =  { {'1/64' '1/32' '1/16' '1/8' '1/4' '3/8' '1/2' '5/8' '3/4' '7/8' '1/1'} 'oct'}; 
IO_def.Inloop.Band_Height          =  {30        'dB'      [0 120]   0  0}; 
IO_def.Inloop.Band_Slope          =  {inf        'dB/oct'      [0 inf]   0  0}; 
%IO_def.Inloop.Frequency_End       =  {'min(current_unit_bf*2,this.Sample_Rate/1e3/2/(2^(this.Band_Height/this.Band_Slope+str2num(this.Half_Band_Width))))'        'kHz'      [0.04  50]   0  0}; 

IO_def.Inloop.Attenuation         =  {'current_unit_thresh-70'        'dB'      [0 120]   0  0}; 
IO_def.Inloop.Sample_Rate         =  {97656.25        'Hz'      [0 97656.25]   0  0};
IO_def.Inloop.Repetitions         =  { 1                       ''         [1     1000]};
IO_def.Inloop.Duration            =  {'(2^15)/this.Sample_Rate*1e3'       'ms'    [20 2000]};
IO_def.Inloop.Rise_time           =  {10        'ms'     [0 1000]};  
IO_def.Inloop.Calibration_File    =  { {'none' 'p0001_calib' 'p0002_calib' 'p0003_calib'} ''};
IO_def.Inloop.Symmetry            =  { {'log' 'linear'} ''};

if (isequal(fieldname,'Inloop'))
   if (~isequal(current_unit_bf, prev_unit_bf))
      IO_def.Inloop.Frequency_Start{5}            = 1; % ignore dflt. Always recalculate.
      IO_def.Inloop.Frequency_End{5}              = 1; % ignore dflt. Always recalculate.
      IO_def.Inloop.Frequency_Step{5}              = 1; % ignore dflt. Always recalculate.
      prev_unit_bf = current_unit_bf;
   end
   if (~isequal(current_unit_thresh, prev_unit_thresh))
      IO_def.Inloop.Attenuation{5}            = 1;
      prev_unit_thresh = current_unit_thresh;
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

tmplt.tag         = 'LRAF_NoiseBand_tmplt';
tmplt.IO_def = IO_def;




