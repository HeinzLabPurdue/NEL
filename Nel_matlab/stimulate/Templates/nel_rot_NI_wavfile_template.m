function [tmplt,DAL,stimulus_vals,units,errstr] = nel_rot_NI_wavfile_template(fieldname,stimulus_vals,units)
%  Written by GE, adapted from 'nel_rot_wavefile_template' written by AF (11/26/01).
%   For implementation NI 6052e board, rather than TDT analog outputs.
%  Modification dates: 06oct2003.


% persistent   prev_playdur  prev_min_period  prev_maxlen
persistent prev_maxlen
% We use the persistent variables to detect a change that requires some fields update.
% For example, of the play duration is changed we would like to update the gating information.
% We restict the automatic updates to allow the user the overide them.

% used_devices.Llist         = 'RP1.1';   % removed by GE 26Jul2002
% used_devices.Rlist         = 'RP2.1';   % removed by GE 26Jul2002
used_devices.Llist         = 'L3';   % added by GE 26Jul2002
used_devices.Rlist         = 'R3';   % added by GE 26Jul2002
tmplt = template_definition;
if (exist('stimulus_vals','var') == 1)
   if (exist(stimulus_vals.Inloop.List_File,'file') ~= 0)
      [Llist,Rlist] = read_rotate_list_file(stimulus_vals.Inloop.List_File);
      if (~isempty(Llist))
         [data fs] = audioread(Llist{1});
      elseif (~isempty(Rlist))
         [data fs] = audioread(Rlist{1});
      end
  
      % Not necessary???? GE/MH 06Nov2003.
%       [stimulus_vals units] = NI_check_gating_params(stimulus_vals, units);

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
   Inloop.params.Rlist                 = Rlist;
   Inloop.params.attens                = stimulus_vals.Inloop.Attenuation;
   Inloop.params.Rattens               = stimulus_vals.Inloop.Attenuation;
   Inloop.params.repetitions           = stimulus_vals.Inloop.Repetitions;
   stimulus_vals.Inloop.UpdateRate = NI6052UsableRate_Hz(stimulus_vals.Inloop.UpdateRate); % GE/MH 04Nov2003.
                                       % Template forces use of a rate that is valid for the NI6052e board in the
                                       %  mode in which it is called (see 'd2a.c').
   Inloop.params.updateRate_Hz        = stimulus_vals.Inloop.UpdateRate;
   

   DAL.funcName = 'data_acquisition_loop_NI'; % added by GE 30oct2003.
   DAL.Inloop = Inloop;
   DAL.Gating = stimulus_vals.Gating;
   DAL.Mix         = mix_params2devs(stimulus_vals.Mix,used_devices);
   DAL.short_description   = 'ROT_NIboard'; % added by GE 26Jul2002
   DAL.description = build_description(DAL,stimulus_vals);
   errstr = check_DAL_params(DAL,fieldname);
end

%----------------------------------------------------------------------------------------
function str = build_description(DAL,stimulus_vals)
p = DAL.Inloop.params;
[listpath,listfile] = fileparts(stimulus_vals.Inloop.List_File);
str{1} = sprintf('List ''%s'' (%d,%d files) ', listfile, length(p.list), length(p.Rlist));
if (~isempty(p.attens));
   str{1} = sprintf('%s @ %1.1f dB Attn.', str{1}, p.attens(1));
end
if (isfield(stimulus_vals.Mix,'Llist'))
   str{1} = sprintf('%s (L->%s)', str{1}, stimulus_vals.Mix.Llist);
end
if (isfield(stimulus_vals.Mix,'Rlist'))
   str{1} = sprintf('%s (R->%s)', str{1}, stimulus_vals.Mix.Rlist);
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
global signals_dir
%%%%%%%%%%%%%%%%%%%%
%% Inloop Section 
%%%%%%%%%%%%%%%%%%%%
IO_def.Inloop.List_File             = { {['uigetfile(''' signals_dir 'Lists\*.m'')']} };
IO_def.Inloop.Attenuation           = {'max(0,current_unit_thresh-20)'  'dB'    [0    120]      };
IO_def.Inloop.Repetitions            = { 1                        ''      [1    Inf]      };
IO_def.Inloop.UpdateRate        = { 100000                  'Hz'      [1    NI6052UsableRate_Hz(Inf)]      };

%%%%%%%%%%%%%%%%%%%%
%% Gating Section 
%%%%%%%%%%%%%%%%%%%%
IO_def.Gating.Duration             = {300       'ms'    [20 2000]};
IO_def.Gating.Period               = {'default_period(this.Duration)'    'ms'   [50 5000]};
IO_def.Gating.Rise_fall_time       = {'default_rise_time(this.Duration)' 'ms'   [0  1000]}; 

%%%%%%%%%%%%%%%%%%%%
%% Mix Section 
%%%%%%%%%%%%%%%%%%%%
IO_def.Mix.Llist        =  {'{Left}|Both|Right'};
IO_def.Mix.Rlist        =  {'Left|Both|{Right}'};

tmplt.tag               = 'NELrot_NI_wavfile_tmplt';
tmplt.IO_def = IO_def;
