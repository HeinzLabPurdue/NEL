function [tmplt,DAL,stimulus_vals,units,errstr] = EH_reFF_template(fieldname,stimulus_vals,units)
% Modified by M.Heinz 07July2004, from EH_reBF_template.m
%    Places features at a pre-determined frequency, based on BF (CalcFixedFreq)
% MH 01July2004: for NOHR project
%    places features near BF for a BASELINE EH with F2 at BF and F0=75 Hz
%
% From EH_template (CNexps)
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
   %%% Make sure the needed BASELINE-EH wavfile exists.  If not, create it before proceeding
   %%%  BASELINE-EH has F2 at BaseFreq and F0=75Hz;
   %%%  wavfile is of 1 cycle of the vowel
   global signals_dir
   EHsignals_dir=strcat(signals_dir,'MH\EHvowels');  
   % If this is empty, bf is not in a defined range for this template 
   if ~isempty(stimulus_vals.Inloop.BaseFrequency)
      BASELINE_TargetFreq_Hz                      = stimulus_vals.Inloop.BaseFrequency*1000;
   else
      BASELINE_TargetFreq_Hz                      = 9e3;
   end 

   BASELINE_F0_Hz=75;
   BASELINE_Feature='F2';
   Fix2Harms=strcmp(stimulus_vals.Inloop.FormsAtHarmonics,'yes'); % Set formants at nearest harmonic: 0:no, 1:yes
   PolarityFact=(strcmp(stimulus_vals.Inloop.InvertPolarity,'yes')-.5)*-2;  % For inverting waveform if necessary
   % Get filename and FormFreqs: mode 3 returns empty stim,Fs,dBreTONE
   [Xstim,XFs,filename,XdBreTONE,BASELINE_FormFreqs_Hz]= ...
      synth_BASELINE_eh(BASELINE_TargetFreq_Hz,BASELINE_F0_Hz,BASELINE_Feature,Fix2Harms,3);
   stimulus_vals.Inloop.Compiled_FileName=fullfile(EHsignals_dir,filename);
   % If file does not exist, synthesize the new BASELINE vowel and save as a new wavfile
   if isempty(dir(fullfile(EHsignals_dir,filename)))
      % stim returned is 1 cycle of the vowel (Mode 2: synthesizes vowel, but does not show it)
      [stim,Fs,filename,dBreTONE,BASELINE_FormFreqs_Hz]= ...
         synth_BASELINE_eh(BASELINE_TargetFreq_Hz,BASELINE_F0_Hz,BASELINE_Feature,Fix2Harms,2);
      wavwrite(stim,Fs,fullfile(EHsignals_dir,filename))
   end
   
   %% From here, we just read the wavfile and proceed like ORIGINAL EH
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   if (exist(stimulus_vals.Inloop.Compiled_FileName,'file') ~= 0)
      list = {stimulus_vals.Inloop.Compiled_FileName};
      [vowel BASELINE_Fs] = audioread(stimulus_vals.Inloop.Compiled_FileName);
   else
      list = {};
   end
   vowel=vowel*PolarityFact;  % Invert if necessary
   [stimulus_vals units] = NI_check_gating_params(stimulus_vals, units);

   featureNames = {'T0','F1','T1','F2','T2','F3','T3'};
   featureIND=find(strcmp(featureNames,stimulus_vals.Inloop.Feature));

   % Call here to get params, later call to view vowel is needed
   [BASELINE_FeatFreqs_Hz,BASELINE_FeatLevs_dB,dBreTONE]= ...
      getVowelParams(vowel,BASELINE_Fs,stimulus_vals.Gating.Duration/1000,BASELINE_FormFreqs_Hz,0);

   stimulus_vals.Inloop.Computed_UpdateRate_Hz= ...
      BASELINE_Fs*(BASELINE_TargetFreq_Hz/BASELINE_FeatFreqs_Hz(featureIND)); %Shift to feature
   if (stimulus_vals.Inloop.Computed_UpdateRate_Hz> NI6052UsableRate_Hz(Inf))
      stimulus_vals.Inloop.Used_UpdateRate_Hz=NI6052UsableRate_Hz(Inf);
      nelerror('In EH_template: Requested sampling rate greater than MAX rate allowed by NI board!!');
   end
   stimulus_vals.Inloop.Used_UpdateRate_Hz = NI6052UsableRate_Hz(stimulus_vals.Inloop.Computed_UpdateRate_Hz); % GE/MH 04Nov2003:
   % Template forces use of a rate that is valid for the NI6052e board in the
   %  mode in which it is called (see 'd2a.c').
   stimulus_vals.Inloop.Used_FeatureTarget_Hz=BASELINE_TargetFreq_Hz* ...
      stimulus_vals.Inloop.Used_UpdateRate_Hz/stimulus_vals.Inloop.Computed_UpdateRate_Hz;
   if strcmp(stimulus_vals.Inloop.ViewVowel,'baseline')
      [BASELINE_FeatFreqs_Hz,BASELINE_FeatLevs_dB,dBreTONE]= ...
         getVowelParams(vowel,BASELINE_Fs,stimulus_vals.Gating.Duration/1000,BASELINE_FormFreqs_Hz,1);
   elseif strcmp(stimulus_vals.Inloop.ViewVowel,'shifted')
      [SHIFTED_FeatFreqs_Hz,SHIFTED_FeatLevs_dB,SHIFTED_dBreTONE]= ...
         getVowelParams(vowel,stimulus_vals.Inloop.Used_UpdateRate_Hz, ...
         stimulus_vals.Gating.Duration/1000, ...
         BASELINE_FormFreqs_Hz*stimulus_vals.Inloop.Used_UpdateRate_Hz/BASELINE_Fs,2);
   end
   stimulus_vals.Inloop.ViewVowel='no';  % Reset each time

   
   Inloop.Name                         = 'DALinloop_NI_SCC_wavfiles';
   Inloop.params.list                  = list;

   Inloop.params.Condition.BaseFrequency_kHz           = BASELINE_TargetFreq_Hz/1000;
   Inloop.params.Condition.Feature                     = stimulus_vals.Inloop.Feature; 
   Inloop.params.Condition.FormsAtHarmonics            = stimulus_vals.Inloop.FormsAtHarmonics;
   Inloop.params.Condition.InvertPolarity              = stimulus_vals.Inloop.InvertPolarity;
   Inloop.params.Condition.Level_dBSPL                 = stimulus_vals.Inloop.Level;
   Inloop.params.CalibPicNum                 = stimulus_vals.Inloop.CalibPicNum;
   
   Inloop.params.BASELINE.F0_Hz              = BASELINE_F0_Hz;
   Inloop.params.BASELINE.Feature            = BASELINE_Feature; 
   Inloop.params.BASELINE.TargetFreq_Hz      = BASELINE_TargetFreq_Hz;
   Inloop.params.BASELINE.FormsAtHarmonics   = stimulus_vals.Inloop.FormsAtHarmonics;
   Inloop.params.BASELINE.FileName           = stimulus_vals.Inloop.Compiled_FileName;
   Inloop.params.BASELINE.FormFreqs_Hz       = BASELINE_FormFreqs_Hz;
   Inloop.params.BASELINE.dBreTONE           = dBreTONE;
   Inloop.params.BASELINE.Fs_Hz              = BASELINE_Fs;
   Inloop.params.BASELINE.FeatFreqs_Hz       = BASELINE_FeatFreqs_Hz;
   Inloop.params.BASELINE.FeatLevs_dB        = BASELINE_FeatLevs_dB;
   Inloop.params.featureNames                = featureNames;

   Inloop.params.Computed.UpdateRate_Hz   = stimulus_vals.Inloop.Computed_UpdateRate_Hz;
   
   %%% Account for Calibration to set Level in dB SPL
   if ~isempty(stimulus_vals.Inloop.CalibPicNum)
      if stimulus_vals.Inloop.CalibPicNum==0
         max_dBSPL=-999;
      else
         cdd
         if ~isempty(dir(sprintf('p%04d_calib.m',Inloop.params.CalibPicNum)))
            x=loadpic(stimulus_vals.Inloop.CalibPicNum);
            CalibData=x.CalibData(:,1:2);
            CalibData(:,2)=trifilt(CalibData(:,2)',5)';
            max_dBSPL=CalibInterp(BASELINE_TargetFreq_Hz/1000,CalibData);
         else
            max_dBSPL=[];
            Inloop.params.CalibPicNum=NaN;
         end
         rdd
      end
   else
      max_dBSPL=[];
   end
   Inloop.params.attens                 = max_dBSPL-stimulus_vals.Inloop.Level+dBreTONE;
   stimulus_vals.Inloop.Computed_Attenuation_dB          = Inloop.params.attens;
   
   Inloop.params.Rlist                 = []; % GE debug: will need to implement 2 channels eventually.
   Inloop.params.Rattens               = []; %      "
   Inloop.params.repetitions           = stimulus_vals.Inloop.Repetitions;
                                       
   Inloop.params.origstimUpdateRate_Hz = BASELINE_Fs;
   Inloop.params.feature               = featureNames{featureIND};
   Inloop.params.featureFreq_Hz        = BASELINE_FeatFreqs_Hz(featureIND);
   Inloop.params.featureTargetFreq_Hz  = stimulus_vals.Inloop.Used_FeatureTarget_Hz;
   Inloop.params.updateRate_Hz         = stimulus_vals.Inloop.Used_UpdateRate_Hz;
     
   DAL.funcName = 'data_acquisition_loop_NI'; % added by GE 30oct2003.
   DAL.Inloop = Inloop;
   DAL.Gating = stimulus_vals.Gating;
   DAL.Mix         = mix_params2devs(stimulus_vals.Mix,used_devices); % GE debug: see 'used_devices.File' line at beginning of function
   DAL.short_description   = 'EHrFF';
   
%    DAL.endLinePlotParams                  = nel_plot_pst_params(DAL.Gating.Period/1000, DAL.Gating.Duration/1000);  % GE 04Nov2003.

   DAL.description = build_description(DAL,stimulus_vals);
   errstr = check_DAL_params(DAL,fieldname);

   %%%%%%%
   % If parameters are NOT correct for this template, Take away this template name
   if(BASELINE_TargetFreq_Hz ~= CalcFixedFreq*1000)
      DAL.short_description   = '';
   end
end

%----------------------------------------------------------------------------------------
function str = build_description(DAL,stimulus_vals)
p = DAL.Inloop.params;
[fpath,file] = fileparts(stimulus_vals.Inloop.Compiled_FileName);
str{1} = sprintf('PST %d reps:', p.repetitions);
str{1} = sprintf('%s File ''%s''', str{1},file);
str{1} = sprintf('%s @%1.1f dB Attn.', str{1}, p.attens);
str{1} = sprintf('%s (%s),', str{1}, stimulus_vals.Mix.File);
str{1} = sprintf('%s Update rate: %.0f Hz,', str{1}, stimulus_vals.Inloop.Used_UpdateRate_Hz);
str{1} = sprintf('%s (%s @ %.f Hz)', str{1}, stimulus_vals.Inloop.Feature,stimulus_vals.Inloop.Used_FeatureTarget_Hz);
if strcmp(stimulus_vals.Inloop.InvertPolarity,'yes')
   str{1} = sprintf('%s (Pol: -)', str{1});
else
   str{1} = sprintf('%s (Pol: +)', str{1});
end
   
%----------------------------------------------------------------------------------------
function errstr = check_DAL_params(DAL,fieldname)
% Some extra error checks
errstr = '';
if (isequal(fieldname,'Inloop'))
   if isempty(DAL.Inloop.params.CalibPicNum)
      errstr = 'Need to set Calibration PicNum!';
   elseif isnan(DAL.Inloop.params.CalibPicNum)
      errstr = 'Not a valid Calibration PicNum! (use 0 to escape)';      
   elseif DAL.Inloop.params.CalibPicNum==0
      errstr = '';      % Allows you to escape the structdlg to go find a valid calibration file
   else
      if (isempty(DAL.Inloop.params.attens))
         errstr = 'Attenuations are not set correctly! (high vs. low mismatch?)';
      elseif (DAL.Inloop.params.attens<0)
         errstr = sprintf('Negative Attenuation of %.1f dB cannot be set, Level must be lowered',DAL.Inloop.params.attens);
      elseif (DAL.Inloop.params.attens>120)
         errstr = sprintf('Attenuation of %.1f dB cannot be set, Level must be raised',DAL.Inloop.params.attens);
      end
      if (DAL.Inloop.params.Condition.BaseFrequency_kHz==9)
         errstr = 'UNIT BF is not in a defined range for this template (.25-16 kHz)!';
      end
   end
end

%----------------------------------------------------------------------------------------
function tmplt = template_definition(fieldname)
global signals_dir
persistent prev_unit_bf
%%%%%%%%%%%%%%%%%%%%
%% Inloop Section 
%%%%%%%%%%%%%%%%%%%%
IO_def.Inloop.BaseFrequency     =  {'CalcFixedFreq'   'kHz'      [0.04  50] 0 0};
IO_def.Inloop.Feature           =  {'T0|{F1}|T1|F2|T2|F3|T3'};
IO_def.Inloop.FormsAtHarmonics  =  {'no|{yes}'};
IO_def.Inloop.InvertPolarity  =  {'{no}|yes'};
IO_def.Inloop.Level  =  {65 'dB SPL'       [-50    150]   0  0}; 
IO_def.Inloop.Repetitions  =  {100   ''       [1 600]}; 
IO_def.Inloop.CalibPicNum  =  {[]   ''       [0 6000]};
IO_def.Inloop.ViewVowel  =  {'{no}|baseline|shifted'};

if (~isequal(current_unit_bf, prev_unit_bf) & isequal(fieldname,'Inloop'))
   IO_def.Inloop.BaseFrequency{5}            = 1; % ignore dflt. Always recalculate.
   prev_unit_bf = current_unit_bf;
end


%%%%%%%%%%%%%%%%%%%%
%% Gating Section 
%%%%%%%%%%%%%%%%%%%%
IO_def.Gating.Duration             = {400       'ms'    [20 2000]};
IO_def.Gating.Period               = {'default_period(this.Duration)'    'ms'   [50 5000]};
IO_def.Gating.Rise_fall_time       = {'default_rise_time(this.Duration)' 'ms'   [0  1000]};

%%%%%%%%%%%%%%%%%%%%
%% Mix Section 
%%%%%%%%%%%%%%%%%%%%
IO_def.Mix.File        =  {'Left|Both|{Right}'};

tmplt.tag               = 'EHrFF_tmplt';
tmplt.IO_def = IO_def;
