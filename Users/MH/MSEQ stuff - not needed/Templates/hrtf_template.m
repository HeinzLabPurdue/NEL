function [tmplt,DAL,stimulus_vals,units,errstr] = hrtf_template(fieldname,stimulus_vals,units)
%

% AF 11/26/01
global signals_dir schase_monaural
persistent   prev_playdur  prev_min_period  prev_maxlen
% We use the persistent variables to detect a change that requires some fields update.
% For example, of the play duration is changed we would like to update the gating information.
% We restict the automatic updates to allow the user the overide them.

used_devices.Llist         = 'RP1.1';
used_devices.Rlist         = 'RP2.1';
tmplt = template_definition(fieldname);
if (exist('stimulus_vals','var') == 1)
   schase_monaural.ear=stimulus_vals.Inloop.Monaural_Const_Ear;
   schase_monaural.stim=stimulus_vals.Inloop.Monaural_Const_Stim;
   List_File = [signals_dir 'Lists\schase\' stimulus_vals.Inloop.List_File '.m'];
   if (exist(List_File,'file') ~= 0)
      [Llist,Rlist] = read_rotate_list_file(List_File);
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
         % tmplt.IO_def.Gating.Period{1}    = ['max(' num2str(min_period) ',default_period(this.Duration))'];
         tmplt.IO_def.Gating.Period{1}    = [num2str(min_period)];
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
      prev_maxlen = 0;
   end
   
   Inloop.Name                         = 'DALinloop_wavfiles_compressed';
   % Inloop.Name                         = 'DALinloop_wavfiles';
   Inloop.params.list                  = Llist;
   Inloop.params.Rlist                 = Rlist;
   Inloop.params.attens                = stimulus_vals.Inloop.Attenuation;
   Inloop.params.Rattens               = stimulus_vals.Inloop.Attenuation;
   Inloop.params.repetitions           = stimulus_vals.Inloop.Repetitions;
   Inloop.params.resample_ratio        = NaN;
   
   
   DAL.Inloop = Inloop;
   DAL.Gating = stimulus_vals.Gating;
   DAL.Mix         = mix_params2devs(stimulus_vals.Mix,used_devices);
   DAL.short_description   = stimulus_vals.Inloop.List_File;
   DAL.description = build_description(DAL,stimulus_vals);
   errstr = check_DAL_params(DAL,fieldname);
end

%----------------------------------------------------------------------------------------
function str = build_description(DAL,stimulus_vals)
global schase_monaural
p = DAL.Inloop.params;
[listpath,listfile] = fileparts(stimulus_vals.Inloop.List_File);
str{1} = sprintf('hrtf stim  ''%s'' (%d,%d files) ', listfile, length(p.list), length(p.Rlist));
if isequal(listfile,'monaural')
   str{1}= sprintf('%s (%s ear const with hrtf stim %d) ', str{1}, schase_monaural.ear, schase_monaural.stim);
end
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
function tmplt = template_definition(fieldname)
global signals_dir schase_monaural
persistent prev_unit_bf 
%%%%%%%%%%%%%%%%%%%%
%% Inloop Section 
%%%%%%%%%%%%%%%%%%%%
IO_def.Inloop.List_File             = { '{hrtf}|noitdhrtf|monaural' };
IO_def.Inloop.Attenuation           = {'max(0,current_unit_thresh-20)'  'dB'    [0    120]      };
IO_def.Inloop.Repetitions           = { 1                                ''     [1    Inf]      };
IO_def.Inloop.Monaural_Const_Stim   = {95                                ''     [0    100]      };
IO_def.Inloop.Monaural_Const_Ear    = {'{Left}|Right' };
if (isequal(fieldname,'Inloop'))
   if (~isequal(current_unit_bf, prev_unit_bf))
      prev_unit_bf = current_unit_bf;
   end
end

%%%%%%%%%%%%%%%%%%%%
%% Gating Section 
%%%%%%%%%%%%%%%%%%%%
IO_def.Gating.Duration             = {200       'ms'    [20 2000]};
IO_def.Gating.Period               = {'default_period(this.Duration)'    'ms'   [50 5000]};
% IO_def.Gating.Rise_fall_time       = {'default_rise_time(this.Duration)' 'ms'   [0  1000]}; 

%%%%%%%%%%%%%%%%%%%%
%% Mix Section 
%%%%%%%%%%%%%%%%%%%%
IO_def.Mix.Llist        =  {'{Left}|Both|Right'};
IO_def.Mix.Rlist        =  {'Left|Both|{Right}'};

tmplt.tag               = 'hrtf_tmplt';
tmplt.IO_def = IO_def;

