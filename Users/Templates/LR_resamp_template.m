function [tmplt,DAL,stimulus_vals,units,errstr] = LR_resamp_template(fieldname,stimulus_vals,units)
%

% AF 11/26/01
global signals_dir lr_list_bf_str lraf_RESAMP_flag__   LR_AF_EXP_TYPE
persistent   prev_playdur  prev_min_period  prev_maxlen
% We use the persistent variables to detect a change that requires some fields update.
% For example, of the play duration is changed we would like to update the gating information.
% We restict the automatic updates to allow the user the overide them.

if (isempty(lraf_RESAMP_flag__))
   lraf_RESAMP_flag__ = 0;
end
% used_devices.Llist         = 'RP1.1';
% used_devices.Rlist         = 'RP2.1';

switch (LR_AF_EXP_TYPE)
case 'CN'
   used_devices.Llist         = 'RP1.1';
case 'IC'
   used_devices.Llist         = 'RP1.1';
   used_devices.Rlist         = 'RP2.1';
end
switch (lraf_RESAMP_flag__)
case 'STD_RESAMP'
   tmplt = STDtemplate_definition(fieldname);
case 'COMP'
   tmplt = COMPtemplate_definition(fieldname);
end
%tmplt = template_definition(fieldname);
if (exist('stimulus_vals','var') == 1)
   lr_list_bf_str = num2str(stimulus_vals.Inloop.Frequency);
%    switch (stimulus_vals.Inloop.List_File)
%    case 'comp1'
%       lr_list_bf_str{1} = ['K_' bf_str];
%       jy_list_bf_str{2} = ['L_' bf_str];
%    case 'MN'
%       jy_list_bf_str{1} = ['M_' bf_str];
%       jy_list_bf_str{2} = ['N_' bf_str];
%    case 'OP'
%       jy_list_bf_str{1} = ['O_' bf_str];
%       jy_list_bf_str{2} = ['P_' bf_str];
%    end
   List_File = [signals_dir 'Lists\LR_AF\' stimulus_vals.Inloop.List_File '.m'];
   if (exist(List_File,'file') ~= 0)
      [Llist,Rlist] = read_rotate_list_file(List_File);
      if (~isempty(Llist) | ~isempty(Rlist)) 
         if (~isempty(Llist))
            [data fs] = audioread(Llist{1});
         elseif (~isempty(Rlist))
            [data fs] = audioread(Rlist{1});
         end
         playback_rate = 97656.25/(round(97656.25/fs)); % 97656.25 is the rco's sampling rate
         playdur = round(length(data)/playback_rate*1000);	%compute file duration based on sampling rate
         min_period = playdur + length(data)/97.656 * 0.55 + 250;
         % min_period = max(1000,ceil(1.7*playdur/100)*100);
         if (~isempty(Rlist))
            min_period = min_period + length(data)/97.656 * 0.55;
         end
         min_period = ceil(min_period/100)*100;
         %% In this template we have to change the Gating and Mix parameters according to 
         %% the Llist, Rlist and the playback duration of the wav files.
         %% We do this by first, updating the relevant template definitions, and second,
         %% by calling 'structdlg' in its non-interactive invisible mode, to recalculated 'stimulus_vals' fields.
         if (isempty(Llist))
            tmplt.IO_def.Mix = rmfield(tmplt.IO_def.Mix,'Llist');
         end
         if (isempty(Rlist))
            tmplt.IO_def.Mix = rmfield(tmplt.IO_def.Mix,'Rlist');
         end
         [stimulus_vals.Mix units.Mix] = structdlg(tmplt.IO_def.Mix,'',stimulus_vals.Mix,'off');
         %
         if (isequal(fieldname,'Inloop') | ~isequal(playdur,prev_playdur) | ~isequal(min_period,prev_min_period))
            tmplt.IO_def.Gating.Duration{1}  = playdur;
            % tmplt.IO_def.Gating.Period{1}    = [num2str(min_period)];
            tmplt.IO_def.Gating.Period{1}    = ['max(' num2str(min_period) ',1000)'];
            [stimulus_vals.Gating units.Gating] = structdlg(tmplt.IO_def.Gating,'',[],'off');
            prev_playdur = playdur;
            prev_min_period = min_period;
         end
         %
         if (~isequal(prev_maxlen, max(length(Llist),length(Rlist))))
            tmplt.IO_def.Inloop.Repetitions{1}  = round(100/max(length(Llist),length(Rlist)));
            new_stimulus_vals.Inloop  = structdlg(tmplt.IO_def.Inloop,'',[],'off'); % change only the repetitions!!
            stimulus_vals.Inloop.Repetitions = new_stimulus_vals.Inloop.Repetitions;
            prev_maxlen = max(length(Llist),length(Rlist));
         end
      else
         Llist = [];
         Rlist = [];
         stimulus_vals.Mix = struct([]);
         prev_maxlen = 0;
      end
   else
      Llist = [];
      Rlist = [];
      stimulus_vals.Mix = struct([]);
      prev_maxlen = 0;
   end
   Inloop.Name                         = 'DALinloop_wavfiles_compressed';
   % Inloop.Name                         = 'DALinloop_wavfiles';
   start_from                          = max(1, min(length(Llist),stimulus_vals.Inloop.Start_File_Number));
   Inloop.params.list                  = Llist(start_from:end);
   start_from                          = max(1, min(length(Rlist),stimulus_vals.Inloop.Start_File_Number));
   Inloop.params.Rlist                 = Rlist(start_from:end);
   Inloop.params.attens                = stimulus_vals.Inloop.Attenuation;
   Inloop.params.Rattens               = stimulus_vals.Inloop.Attenuation;
   Inloop.params.repetitions           = stimulus_vals.Inloop.Repetitions;
   Inloop.params.resample_ratio        = NaN;
   Inloop.params.playback_slowdown     = 1;

   DAL.Inloop = Inloop;
   DAL.Gating = stimulus_vals.Gating;
   DAL.Mix         = mix_params2devs(stimulus_vals.Mix,used_devices);
   DAL.short_description   = lraf_RESAMP_flag__;
   DAL.description = build_description(DAL,stimulus_vals,lraf_RESAMP_flag__);
   errstr = check_DAL_params(DAL,fieldname);
end

%----------------------------------------------------------------------------------------
function str = build_description(DAL,stimulus_vals,lraf_RESAMP_flag__)
global lr_list_bf_str
p = DAL.Inloop.params;
[listpath,listfile] = fileparts(stimulus_vals.Inloop.List_File);
tmpbf = sscanf(lr_list_bf_str,'%g');
str{1} = sprintf('LR RSS stim  ''%s'' resampled to %2.2g (%d,%d files) ', listfile, tmpbf, ...
   length(p.list), length(p.Rlist));
if (~isempty(p.attens));
   str{1} = sprintf('%s @ %1.1f dB Attn.', str{1}, p.attens(1));
end
if (isfield(stimulus_vals.Mix,'Llist'))
   str{1} = sprintf('%s (L->%s)', str{1}, stimulus_vals.Mix.Llist);
end
if (isfield(stimulus_vals.Mix,'Rlist'))
   str{1} = sprintf('%s (R->%s)', str{1}, stimulus_vals.Mix.Rlist);
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

%----------------------------------------------------------------------------------------
function tmplt = STDtemplate_definition(fieldname)
global signals_dir LR_AF_EXP_TYPE
persistent prev_unit_bf 
%%%%%%%%%%%%%%%%%%%%
%% Inloop Section 
%%%%%%%%%%%%%%%%%%%%
%IO_def.Inloop.List_File             = { {'rss_std12a' 'rss_std12b' 'rss_std6a' 'rss_std6b' 'rss_std3a' 'rss_std3b' 'rss_std1_5a' 'rss_std1_5b'} };
%bf_str = num2str(stimulus_vals.Inloop.Frequency);
IO_def.Inloop.List_File             = { {'std12_resamp' 'std6_resamp' 'std3_resamp' 'std1_5_resamp' 'std12r_resamp' 'std6r_resamp' 'std3r_resamp' 'std1_5r_resamp'} };
IO_def.Inloop.Frequency             =  {'current_unit_bf'   'kHz'      [0.04  50]   0  0}; 
IO_def.Inloop.Attenuation           = {'max(0,current_unit_thresh-60)'  'dB'    [0    120]      };
IO_def.Inloop.Repetitions           = { 1                                ''     [1    Inf]      };
IO_def.Inloop.Start_File_Number     = { 1                                ''     [1    Inf]      };
% IO_def.Inloop.Playback_Speed        = { '{Normal}|Half'                  ''        []    0  0   };    
% IO_def.Inloop.Resample_Ratio        = { 1                        ''      [0.05    4]      };
if (isequal(fieldname,'Inloop'))
   if (~isequal(current_unit_bf, prev_unit_bf))
      if (current_unit_bf < 0)
         IO_def.Inloop.Playback_Speed{1}         = 'Normal|{Half}'; 
         IO_def.Inloop.Playback_Speed{5}         = 1; 
      end
      prev_unit_bf = current_unit_bf;
   end
end

%%%%%%%%%%%%%%%%%%%%
%% Gating Section 
%%%%%%%%%%%%%%%%%%%%
IO_def.Gating.Duration             = {'420*12/current_unit_bf'       'ms'    [20 2000]};
IO_def.Gating.Period               = {'default_period(this.Duration)'    'ms'   [50 5000]};
% IO_def.Gating.Rise_fall_time       = {'default_rise_time(this.Duration)' 'ms'   [0  1000]}; 

%%%%%%%%%%%%%%%%%%%%
%% Mix Section 
%%%%%%%%%%%%%%%%%%%%
switch (LR_AF_EXP_TYPE)
case 'CN'
%    IO_def.Mix.Llist        =  {'{Left}|Both|Right'};
   IO_def.Mix.Rlist        =  {'Left|Both|{Right}'};
   IO_def.Mix.Llist        =  {'Left|Both|{Right}'};
case 'IC'
   IO_def.Mix.Llist        =  {'{Left}|Both|Right'};
   IO_def.Mix.Rlist        =  {'Left|Both|{Right}'};
end

tmplt.tag               = 'LR_StdResamp_tmplt';
tmplt.IO_def = IO_def;
%----------------------------------------------------------------------------------------

function tmplt = COMPtemplate_definition(fieldname)
global signals_dir LR_AF_EXP_TYPE
persistent prev_unit_bf 
%%%%%%%%%%%%%%%%%%%%
%% Inloop Section 
%%%%%%%%%%%%%%%%%%%%
%IO_def.Inloop.List_File             = { {'rss_std12a' 'rss_std12b' 'rss_std6a' 'rss_std6b' 'rss_std3a' 'rss_std3b' 'rss_std1_5a' 'rss_std1_5b'} };
%bf_str = num2str(stimulus_vals.Inloop.Frequency);
IO_def.Inloop.List_File             = { { 'comp56' 'comp40' 'comp24' 'comp8' 'comp4' 'comp2' 'comp1'} };
IO_def.Inloop.Frequency             =  {'current_unit_bf'   'kHz'      [0.04  50]   0  0}; 
IO_def.Inloop.Attenuation           = {'max(0,current_unit_thresh-60)'  'dB'    [0    120]      };
IO_def.Inloop.Repetitions           = { 1                                ''     [1    Inf]      };
IO_def.Inloop.Start_File_Number     = { 1                                ''     [1    Inf]      };
% IO_def.Inloop.Playback_Speed        = { '{Normal}|Half'                  ''        []    0  0   };    
% IO_def.Inloop.Resample_Ratio        = { 1                        ''      [0.05    4]      };
if (isequal(fieldname,'Inloop'))
   if (~isequal(current_unit_bf, prev_unit_bf))
      if (current_unit_bf < 0)
         IO_def.Inloop.Playback_Speed{1}         = 'Normal|{Half}'; 
         IO_def.Inloop.Playback_Speed{5}         = 1; 
      end
      IO_def.Inloop.Frequency{5}         = 1; 
      prev_unit_bf = current_unit_bf;
   end
end

%%%%%%%%%%%%%%%%%%%%
%% Gating Section 
%%%%%%%%%%%%%%%%%%%%
IO_def.Gating.Duration             = {420       'ms'    [20 2000]};
IO_def.Gating.Period               = {'default_period(this.Duration)'    'ms'   [50 5000]};
% IO_def.Gating.Rise_fall_time       = {'default_rise_time(this.Duration)' 'ms'   [0  1000]}; 

%%%%%%%%%%%%%%%%%%%%
%% Mix Section 
%%%%%%%%%%%%%%%%%%%%
switch (LR_AF_EXP_TYPE)
case 'CN'
%    IO_def.Mix.Llist        =  {'{Left}|Both|Right'};
   IO_def.Mix.Rlist        =  {'Left|Both|{Right}'};
   IO_def.Mix.Llist        =  {'Left|Both|{Right}'};
case 'IC'
   IO_def.Mix.Llist        =  {'{Left}|Both|Right'};
   IO_def.Mix.Rlist        =  {'Left|Both|{Right}'};
end

tmplt.tag               = 'LR_CompResamp_tmplt';
tmplt.IO_def = IO_def;
%----------------------------------------------------------------------------------------
