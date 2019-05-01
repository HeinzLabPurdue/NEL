function [tmplt,DAL,stimulus_vals,units,errstr] = SNRenv_0_template(fieldname,stimulus_vals,units)
%  Written by GE, adapted from 'nel_rot_wavefile_template' written by AF (11/26/01).
%   For implementation NI 6052e board, rather than TDT analog outputs.
%  Modification dates: 06oct2003.
% Modifed by MHeinz Aug3_2007 from nel_rot_NI_wavfile_template

% persistent   prev_playdur  prev_min_period  prev_maxlen
persistent prev_maxlen
% We use the persistent variables to detect a change that requires some fields update.
% For example, of the play duration is changed we would like to update the gating information.
% We restict the automatic updates to allow the user the overide them.

% used_devices.Llist         = 'RP1.1';   % removed by GE 26Jul2002
% used_devices.Rlist         = 'RP2.1';   % removed by GE 26Jul2002
used_devices.Llist         = 'L3';   % added by GE 26Jul2002
tmplt = template_definition;
if (exist('stimulus_vals','var') == 1)
   if (exist(stimulus_vals.Inloop.List_File,'file') ~= 0)
      [Llist,Rlist] = read_rotate_list_file(stimulus_vals.Inloop.List_File);
      %% Rlist always empty here
      [data fs] = audioread(Llist{1});
      
%       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       %%%% Generate CF tone wav files for NOISE FLOOR MEASURES
%       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       %     [x,acx] = Create_Tone(current_unit_bf*1000,stimulus_vals.Gating.Duration/1000);
%       [x,acx] = Create_Tone(current_unit_bf*1000,1680/1000);
%       
%       % Tones are full amplitude -1 to 1
%       % Need to adjust tone level to be 35 dB above TC threshold
%       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       %%% FIX THIS!!!!!  APPLY to vector attens, not WAV file!!!!
%       CHIMatten=stimulus_vals.Inloop.Attenuation;
%       TONEatten=current_unit_thresh-35;
%       if TONEatten>CHIMatten
%           TONEfact=10^((CHIMatten-TONEatten)/20);
%           x=x*TONEfact;
%           acx=acx*TONEfact;
%       end
%       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       wavwrite(x,fs,fullfile(fileparts(Llist{1}),'CFtone.wav'))
%       wavwrite(acx,fs,fullfile(fileparts(Llist{1}),'NCFtone.wav'))
      
      
      % Not necessary???? GE/MH 06Nov2003.
%       [stimulus_vals units] = NI_check_gating_params(stimulus_vals, units);

      %% In this template we have to change the Gating and Mix parameters according to 
      %% the Llist, Rlist and the playback duration of the wav files.
      %% We do this by first, updating the relevant template definitions, and second,
      %% by calling 'structdlg' in its non-interactive invisible mode, to recalculated 'stimulus_vals' fields.
%       if (isempty(Llist))
%          tmplt.IO_def.Mix = rmfield(tmplt.IO_def.Mix,'Llist');
%       end
%       if (isempty(Rlist))
%          tmplt.IO_def.Mix = rmfield(tmplt.IO_def.Mix,'Rlist');
%       end
      [stimulus_vals.Mix units.Mix] = structdlg(tmplt.IO_def.Mix,'',stimulus_vals.Mix,'off');
      %

      % ge debug: why is this following block needed???
% BEGIN: removed by GE 07oct2003.      
%       if (~isequal(prev_maxlen, max(length(Llist),length(Rlist))))
%          tmplt.IO_def.Inloop.Repetitions{1}  = round(100/max(length(Llist),length(Rlist)));
%          new_stimulus_vals.Inloop  = structdlg(tmplt.IO_def.Inloop,'',[],'off'); % change only the repetitions!!
%          stimulus_vals.Inloop.Repetitions = new_stimulus_vals.Inloop.Repetitions;
%          prev_maxlen = max(length(Llist),length(Rlist));
%       end
% END: removed by GE 07oct2003.      

   else
      Llist = [];
      Rlist = [];
      prev_maxlen = 0;
   end
   
   Inloop.Name                         = 'DALinloop_NI_wavfiles';   % added by GE 26Jul2002
   Inloop.params.list                  = Llist;
   Inloop.params.Rlist                 = [];
   
   %    Inloop.params.attens                = stimulus_vals.Inloop.Attenuation;
     
   Inloop.params.Rattens               = [];
   Inloop.params.repetitions           = stimulus_vals.Inloop.Repetitions;
   stimulus_vals.Inloop.UpdateRate = NI6052UsableRate_Hz(stimulus_vals.Inloop.UpdateRate); % GE/MH 04Nov2003.
                                       % Template forces use of a rate that is valid for the NI6052e board in the
                                       %  mode in which it is called (see 'd2a.c').
   Inloop.params.updateRate_Hz        = stimulus_vals.Inloop.UpdateRate;
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
               max_dBSPL=CalibInterp(current_unit_bf,CalibData);
           else
               max_dBSPL=[];
               Inloop.params.CalibPicNum=NaN;
           end
           rdd
       end
   else
       max_dBSPL=[];
   end
   %load file
   %[x,fs]=audioread('C:\NEL\Signals\MH\SNRenv\SNR_0\FLN_Stim_S_P.wav'); 
   %dBreTONE=20*log10(rms(x)/(5*.707));
   %Inloop.params.attens  = max_dBSPL-stimulus_vals.Inloop.Level+dBreTONE;   
   
   % updating to use calib filter at all freqs instead of just at CF calib: (Nov 28, 2018) [SP]
   audio_fName='C:\NEL\Signals\MH\SNRenv\SNR_0\FLN_Stim_S_P.wav';
   cdd;
   calibFiles= dir('*calib*');
   calib_picNum= getPicNum(calibFiles(end).name);
   plotYes=0 ;
   verbose=0;
   [filteredSPL, originalSPL]=CalibFilter_outSPL(audio_fName, calib_picNum, plotYes, verbose)
   Inloop.params.attens= filteredSPL - stimulus_vals.Inloop.Level;
   rdd;

   if Inloop.params.attens<0
       CalibOFFSET=Inloop.params.attens;
       ding   % can't make it loud enough - setup as REAL error, to log in NEL file.
       warndlg(sprintf('ATTEN set to 0 - UNABLE TO get loud enough (by %.1f dB)',CalibOFFSET))
       pause(1)
       ding
       pause(1)
       ding
       Inloop.params.attens=0;
   end
   stimulus_vals.Inloop.Computed_Attenuation_dB          = Inloop.params.attens;

   
   
   DAL.funcName = 'data_acquisition_loop_NI'; % added by GE 30oct2003.
   DAL.Inloop = Inloop;
   DAL.Gating = stimulus_vals.Gating;
   DAL.Mix         = mix_params2devs(stimulus_vals.Mix,used_devices);
   DAL.short_description   = 'SNRenv_0'; % added by GE 26Jul2002
   DAL.description = build_description(DAL,stimulus_vals);
   errstr = check_DAL_params(DAL,fieldname);
end

%----------------------------------------------------------------------------------------
function str = build_description(DAL,stimulus_vals)
p = DAL.Inloop.params;
[listpath,listfile] = fileparts(stimulus_vals.Inloop.List_File);
str{1} = sprintf('List ''%s'' (%d files) ', listfile, length(p.list));
if (~isempty(p.attens));
   str{1} = sprintf('%s @ %1.1f dB Attn.', str{1}, p.attens(1));
end
if (isfield(stimulus_vals.Mix,'Llist'))
   str{1} = sprintf('%s (L->%s)', str{1}, stimulus_vals.Mix.Llist);
end
str{1} = sprintf('%s   Update rate: %.0f Hz', str{1}, stimulus_vals.Inloop.UpdateRate);

%----------------------------------------------------------------------------------------
function errstr = check_DAL_params(DAL,fieldname)
% Some extra error checks
errstr = '';
if (isequal(fieldname,'Inloop'))
   if (isempty(DAL.Inloop.params.attens))
      errstr = 'Attenuation is not set';
   end
   if (length(DAL.Inloop.params.attens) > 1)
      errstr = 'Only one attenuation please';
   end
end

%----------------------------------------------------------------------------------------
function tmplt = template_definition
global signals_dir NelData


%allCalibFiles= dir([NelData.File_Manager.dirname '*calib*']);
%calib_fName= allCalibFiles(end).name;

%%%%%%%%%%%%%%%%%%%%
%% Inloop Section 
%%%%%%%%%%%%%%%%%%%%

IO_def.Inloop.List_File             = {sprintf('%sLists\\MH\\SNRenv\\SNRenv_0.m', signals_dir)  };
% IO_def.Inloop.List_File             = {sprintf('%sLists\\MH\\SNRenv\\SNRenv_18stim_SSN.m', signals_dir)  };
% IO_def.Inloop.List_File             = {sprintf('%sLists\\MH\\SNRenv\\SNRenv_22stim_SSN.m', signals_dir)  };
% IO_def.Inloop.List_File             = { {['uigetfile(''' signals_dir 'Lists\MH\SNRenv\*.m'')']} };
% IO_def.Inloop.Attenuation           = {'max(0,current_unit_thresh-50)'  'dB'    [0    120]      };
IO_def.Inloop.CalibPicNum  =  {1   ''       [0 6000]};
IO_def.Inloop.Level  =  {80 'dB SPL'       [-50    150]   0  0}; 
IO_def.Inloop.Repetitions            = { 25                        ''      [1    Inf]      };
IO_def.Inloop.UpdateRate        = { 100000                  'Hz'      [1    NI6052UsableRate_Hz(Inf)]      };

%%%%%%%%%%%%%%%%%%%%
%% Gating Section 
%%%%%%%%%%%%%%%%%%%%
IO_def.Gating.Duration             = {1300       'ms'    [20 4000]};
IO_def.Gating.Period               = {1800    'ms'   [50 5000]};
IO_def.Gating.Rise_fall_time       = {'default_rise_time(this.Duration)' 'ms'   [0  1000]}; 

%%%%%%%%%%%%%%%%%%%%
%% Mix Section 
%%%%%%%%%%%%%%%%%%%%
IO_def.Mix.Llist        =  {'Left|Both|{Right}'};
% IO_def.Mix.Rlist        =  {'Left|Both|{Right}'};

tmplt.tag               = 'SNRenv_0';
tmplt.IO_def = IO_def;
