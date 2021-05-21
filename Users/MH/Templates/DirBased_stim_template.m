function [tmplt,DAL,stimulus_vals,units,errstr] = DirBased_stim_template(fieldname,stimulus_vals,units)
%  Written by GE, adapted from 'nel_rot_wavefile_template' written by AF (11/26/01).
%   For implementation NI 6052e board, rather than TDT analog outputs.
%  Modification dates: 06oct2003.
% Modifed by MHeinz Aug3_2007 from nel_rot_NI_wavfile_template

global NelData 
% persistent   prev_playdur  prev_min_period  prev_maxlen
% We use the persistent variables to detect a change that requires some fields update.
% For example, of the play duration is changed we would like to update the gating information.
% We restict the automatic updates to allow the user the overide them.

% used_devices.Llist         = 'RP1.1';   % removed by GE 26Jul2002
% used_devices.Rlist         = 'RP2.1';   % removed by GE 26Jul2002
used_devices.Llist         = 'L3';   % added by GE 26Jul2002
tmplt = template_definition(NelData);
if (exist('stimulus_vals','var') == 1)
    
    if isdir(stimulus_vals.Inloop.List_Folder)
        [Llist,Rlist] = read_rotate_list_folder(stimulus_vals); %#ok<ASGLU>
        
        
        [stimulus_vals.Mix, units.Mix] = structdlg(tmplt.IO_def.Mix,'',stimulus_vals.Mix,'off');
        
    else
        Llist = [];
        %         Rlist = [];
        %         prev_maxlen = 0;
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
    Inloop.params.Level_dBSPL          = stimulus_vals.Inloop.Level;
    Inloop.params.CalibPicNum          = stimulus_vals.Inloop.CalibPicNum;
    
    %% updating to use calib filter at all freqs instead of just at CF calib: (Nov 28, 2018) [SP]
    audio_fName=Llist{1};
    cdd;
    plotYes=0 ;
    verbose=0;
    
    % SP: Should use this 
    %       |
    %       V
    % [filteredSPL, ~]=CalibFilter_outSPL(audio_fName, stimulus_vals.Inloop.CalibPicNum, plotYes, verbose);

    calibFiles= dir('*calib*');
    calib_picNum= getPicNum(calibFiles(end).name);

    [filteredSPL, ~]=CalibFilter_outSPL(audio_fName, calib_picNum, plotYes, verbose);
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
    DAL.short_description   = 'DirBased'; % added by GE 26Jul2002
    DAL.description = build_description(DAL,stimulus_vals);
    errstr = check_DAL_params(DAL,fieldname);
end
end
%----------------------------------------------------------------------------------------
function str = build_description(DAL,stimulus_vals)
p = DAL.Inloop.params;
% [~, listfile] = fileparts(stimulus_vals.Inloop.List_Folder);
folder_with_stims= stimulus_vals.Inloop.List_Folder(strfind(stimulus_vals.Inloop.List_Folder, 'Signals\')+numel('Signals\'):end);
str{1} = sprintf('Dir ''%s'' (%d files) ', folder_with_stims, length(p.list));
if (~isempty(p.attens))
    str{1} = sprintf('%s @ %1.1f dB Attn.', str{1}, p.attens(1));
end
if (isfield(stimulus_vals.Mix,'Llist'))
    str{1} = sprintf('%s (L->%s)', str{1}, stimulus_vals.Mix.Llist);
end
str{1} = sprintf('%s   Update rate: %.0f Hz', str{1}, stimulus_vals.Inloop.UpdateRate);
end
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
end

%----------------------------------------------------------------------------------------
% function tmplt = template_definition(NelData, signals_dir)
function tmplt = template_definition(NelData, ~)
if strcmp(NelData.File_Manager.dirname(end), filesep)
    [~, curDataDir] = fileparts(NelData.File_Manager.dirname(1:end-1));
else
    [~, curDataDir] = fileparts(NelData.File_Manager.dirname);
end
if contains(curDataDir, {'NH', 'setup'})
    spl2use= 65;
else
    spl2use= 80;
end

OutFolder= 'C:\NEL1_2\Users\MH\DirBasedStimuli\';
if ~isdir(OutFolder) % means files have not been created for this track/unit
    error('What''s the point if no directory? Create directory and add wav-files at 100k sampling rate. Need to add this sampling frequency check somewhere.');
end

cdd;
calibFiles= dir('*calib*');
calib_picNum= getPicNum(calibFiles(end).name);
rdd;

%%%%%%%%%%%%%%%%%%%%
%% Inloop Section
%%%%%%%%%%%%%%%%%%%%

IO_def.Inloop.List_Folder             = {OutFolder};
IO_def.Inloop.CalibPicNum  =  {calib_picNum   ''       [0 6000]};
IO_def.Inloop.Level  =  {spl2use 'dB SPL'       [-50    150]   0  0};
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

tmplt.tag               = 'DirBased';
tmplt.IO_def = IO_def;

%% SP: Updating default vars here because every unit has a different IO_def.Inloop.List_Folder
user_profile_set(tmplt.tag, structdlg(tmplt.IO_def,'', [],'off'));
end