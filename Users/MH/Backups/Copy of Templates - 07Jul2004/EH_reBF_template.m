function [tmplt,DAL,stimulus_vals,units,errstr] = EH_reBF_template(fieldname,stimulus_vals,units)
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
   EHsignals_dir='C:\Signals\MH\EHvowels';
   BASELINE_TargetFreq_Hz=stimulus_vals.Inloop.BaseFrequency*1000;
   BASELINE_F0_Hz=75;
   BASELINE_Feature='F2';
   Fix2Harms=strcmp(stimulus_vals.Inloop.FormsAtHarmonics,'yes'); % Set formants at nearest harmonic: 0:no, 1:yes
   % Get filename and FormFreqs: mode 3 returns empty stim,Fs,dBreTONE
   [Xstim,XFs,filename,XdBreTONE,BASELINE_FormFreqs_Hz]= ...
      synth_BASELINE_eh(BASELINE_TargetFreq_Hz,BASELINE_F0_Hz,BASELINE_Feature,Fix2Harms,3);
   stimulus_vals.Inloop.Compiled_FileName=fullfile(EHsignals_dir,filename);
   % If file does not exist, synthesize the new BASELINE vowel and save as a new wavfile
   if isempty(dir(fullfile(EHsignals_dir,filename)))
      % stim returned is 1 cycle of the vowel
      [stim,Fs,filename,dBreTONE,BASELINE_FormFreqs_Hz]= ...
         synth_BASELINE_eh(BASELINE_TargetFreq_Hz,BASELINE_F0_Hz,BASELINE_Feature,Fix2Harms,2);
      wavwrite(stim,Fs,fullfile(EHsignals_dir,filename))
   end
   
   %% From here, we just read the wavfile and proceed like ORIGINAL EH
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   if (exist(stimulus_vals.Inloop.Compiled_FileName,'file') ~= 0)
      list = {stimulus_vals.Inloop.Compiled_FileName};
      [vowel BASELINE_Fs] = wavread(stimulus_vals.Inloop.Compiled_FileName);
   else
      list = {};
   end
   [stimulus_vals units] = NI_check_gating_params(stimulus_vals, units);

   featureNames = {'T0','F1','T1','F2','T2','F3','T3'};
   featureIND=find(strcmp(featureNames,stimulus_vals.Inloop.Feature));

   viewVowel=0;
   [BASELINE_FeatFreqs_Hz,BASELINE_FeatLevs_dB,dBreTONE]= ...
      getVowelParams(vowel,BASELINE_Fs,stimulus_vals.Gating.Duration/1000,BASELINE_FormFreqs_Hz,viewVowel);

   %%%%%%%%%%%%%%%%%%%%%%%
   %%%% MAKE SURE ALL PARAMS ARE SAVED IN DATA FILE
   %%%%%%%%%%%%%%%%%%%%%%%
   
   % Calculate Target Frequency from Condition Params
   clear Direction
   if strcmp(stimulus_vals.Inloop.Offset_Direction,'above')
      Direction=1;
   elseif strcmp(stimulus_vals.Inloop.Offset_Direction,'below')
      Direction=-1;
   else
      error('stimulus_vals.Inloop.Offset_Direction NOT SET CORRECTLY!');
   end
   if ischar(stimulus_vals.Inloop.FreqOffset)
      FreqOffset=str2num(stimulus_vals.Inloop.FreqOffset);
   else
      FreqOffset=stimulus_vals.Inloop.FreqOffset;
   end
   stimulus_vals.Inloop.Computed_FeatureTarget_Hz=stimulus_vals.Inloop.BaseFrequency*1000*2^(Direction*FreqOffset);
   
   stimulus_vals.Inloop.Computed_UpdateRate_Hz= ...
      BASELINE_Fs*(stimulus_vals.Inloop.Computed_FeatureTarget_Hz/BASELINE_FeatFreqs_Hz(featureIND)); %Shift to feature
   if (stimulus_vals.Inloop.Computed_UpdateRate_Hz> NI6052UsableRate_Hz(Inf))
      stimulus_vals.Inloop.Computed_UpdateRate_Hz=NI6052UsableRate_Hz(Inf);
      nelerror('In EH_template: Requested sampling rate greater than MAX rate allowed by NI board!!');
   end
   stimulus_vals.Inloop.Computed_UpdateRate_Hz = NI6052UsableRate_Hz(stimulus_vals.Inloop.Computed_UpdateRate_Hz); % GE/MH 04Nov2003:
   % Template forces use of a rate that is valid for the NI6052e board in the
   %  mode in which it is called (see 'd2a.c').                       

   Inloop.Name                         = 'DALinloop_NI_wavfiles';
   Inloop.params.list                  = list;

   Inloop.params.BaseFrequency_kHz           = stimulus_vals.Inloop.BaseFrequency;
   Inloop.params.FreqOffset_octs             = stimulus_vals.Inloop.FreqOffset;
   Inloop.params.Offset_Direction            = stimulus_vals.Inloop.Offset_Direction;
   Inloop.params.Level_dBSPL                 = stimulus_vals.Inloop.Level;
   Inloop.params.CalibPicNum                 = stimulus_vals.Inloop.CalibPicNum;

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
            max_dBSPL=CalibInterp(Inloop.params.BaseFrequency_kHz,CalibData);
         else
            max_dBSPL=NaN;
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
   Inloop.params.featureTargetFreq_Hz  = stimulus_vals.Inloop.Computed_FeatureTarget_Hz;
   Inloop.params.updateRate_Hz         = stimulus_vals.Inloop.Computed_UpdateRate_Hz;
     
   DAL.funcName = 'data_acquisition_loop_NI'; % added by GE 30oct2003.
   DAL.Inloop = Inloop;
   DAL.Gating = stimulus_vals.Gating;
   DAL.Mix         = mix_params2devs(stimulus_vals.Mix,used_devices); % GE debug: see 'used_devices.File' line at beginning of function
   DAL.short_description   = 'EHrBF';
   DAL.description = build_description(DAL,stimulus_vals);
   errstr = check_DAL_params(DAL,fieldname);
end

%----------------------------------------------------------------------------------------
function str = build_description(DAL,stimulus_vals)
p = DAL.Inloop.params;
[fpath,file] = fileparts(stimulus_vals.Inloop.Compiled_FileName);
str{1} = sprintf('File ''%s'' ', file);
if (length(p.attens) > 1)
   str{1} = sprintf('%s @ %1.1f - %1.1f dB Attn.', str{1}, p.attens(1), p.attens(end));
else
   str{1} = sprintf('%s @ %1.1f dB Attn.', str{1}, p.attens(1));
end
str{1} = sprintf('%s (%s)', str{1}, stimulus_vals.Mix.File);
str{1} = sprintf('%s   Update rate: %.0f Hz', str{1}, stimulus_vals.Inloop.Computed_UpdateRate_Hz);
str{1} = sprintf('%s   (%s @ %.f Hz)', str{1}, stimulus_vals.Inloop.Feature,stimulus_vals.Inloop.Computed_FeatureTarget_Hz);

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
   end
end

%----------------------------------------------------------------------------------------
function tmplt = template_definition(fieldname)
global signals_dir
persistent prev_unit_bf
%%%%%%%%%%%%%%%%%%%%
%% Inloop Section 
%%%%%%%%%%%%%%%%%%%%
IO_def.Inloop.BaseFrequency     =  {'current_unit_bf'   'kHz'      [0.04  50] 0 0};
IO_def.Inloop.FreqOffset        =  {'{0}|1/4|1/2|3/4|1' 'octaves'};
IO_def.Inloop.Offset_Direction  =  {'{below}|above' 're: BF'};
IO_def.Inloop.Feature           =  {'T0|{F1}|T1|F2|T2|F3|T3'};
IO_def.Inloop.FormsAtHarmonics  =  {'{no}|yes'};
IO_def.Inloop.Level  =  {65 'dB SPL'       [-50    150]   0  0}; 
IO_def.Inloop.Repetitions  =  {100   ''       [1 600]}; 
IO_def.Inloop.CalibPicNum  =  {1   ''       [0 6000]};

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

tmplt.tag               = 'EHrBF_tmplt';
tmplt.IO_def = IO_def;
