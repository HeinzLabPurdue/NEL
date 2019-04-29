function [tmplt,DAL,stimulus_vals,units,errstr] = Speach_template(fieldname,stimulus_vals,units)
%

% AF 11/26/01
global signals_dir 
persistent   prev_playdur  prev_min_period  prev_maxlen
% We use the persistent variables to detect a change that requires some fields update.
% For example, of the play duration is changed we would like to update the gating information.
% We restict the automatic updates to allow the user the overide them.

used_devices.Llist         = 'RP1.1';
tmplt = template_definition(fieldname);
if (exist('stimulus_vals','var') == 1)
   List_File = [signals_dir 'Lists\LR_AF\' stimulus_vals.Inloop.List_File '.m'];
   if (exist(List_File,'file') ~= 0)
      Llist = read_rotate_list_file(List_File);
      if (~isempty(Llist))
         [data fs] = wavread(Llist{1});
      end
      playback_rate = 97656.25/(round(97656.25/fs)); % 97656.25 is the rco's sampling rate
      playdur = round(length(data)/playback_rate*1000);	%compute file duration based on sampling rate
      min_period = max(1000,ceil((100+1.7*playdur)/100)*100);

      %
      if (isequal(fieldname,'Inloop') |~isequal(playdur,prev_playdur) | ~isequal(min_period,prev_min_period))
         tmplt.IO_def.Gating.Duration{1}  = playdur;
         tmplt.IO_def.Gating.Period{1}    = [num2str(min_period)];
         [stimulus_vals.Gating units.Gating] = structdlg(tmplt.IO_def.Gating,'',[],'off');
         prev_playdur = playdur;
         prev_min_period = min_period;
      end
      %
      if (~isequal(prev_maxlen, length(Llist)))
         tmplt.IO_def.Inloop.Repetitions{1}  = round(100/length(Llist));
         new_stimulus_vals.Inloop  = structdlg(tmplt.IO_def.Inloop,'',[],'off'); % change only the repetitions!!
         stimulus_vals.Inloop.Repetitions = new_stimulus_vals.Inloop.Repetitions;
         prev_maxlen = length(Llist);
      end
   else
      Llist = [];
      prev_maxlen = 0;
   end
   
   Inloop.Name                         = 'DALinloop_wavfiles';
   Inloop.params.list                  = Llist;
   Inloop.params.Rlist                 = [];
   Inloop.params.attens                = stimulus_vals.Inloop.Attenuation;
   Inloop.params.Rattens               = [];
   Inloop.params.repetitions           = stimulus_vals.Inloop.Repetitions;
   Inloop.params.resample_ratio        = NaN;
   Inloop.params.playback_slowdown     = 1;
   
   DAL.Inloop = Inloop;
   DAL.Gating = stimulus_vals.Gating;
   DAL.Mix         = mix_params2devs(stimulus_vals.Mix,used_devices);
   DAL.short_description   = 'SP';
   DAL.description = build_description(DAL,stimulus_vals);
   errstr = check_DAL_params(DAL,fieldname);
end

%----------------------------------------------------------------------------------------
function str = build_description(DAL,stimulus_vals,lraf_TF_flag__)
p = DAL.Inloop.params;
[listpath,listfile] = fileparts(stimulus_vals.Inloop.List_File);
str{1} = sprintf('Speach ''%s'' (%d files) ', listfile, length(p.list));
if (~isempty(p.attens));
   str{1} = sprintf('%s @ %1.1f dB Attn.', str{1}, p.attens(1));
end
if (isfield(stimulus_vals.Mix,'Llist'))
   str{1} = sprintf('%s (L->%s)', str{1}, stimulus_vals.Mix.Llist);
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
global signals_dir
persistent prev_unit_bf 
%%%%%%%%%%%%%%%%%%%%
%% Inloop Section 
%%%%%%%%%%%%%%%%%%%%
IO_def.Inloop.List_File             = { {'a' 'b'  'c' 'd'  'e' 'f'  'g' 'h'} '' [] 0 0};
IO_def.Inloop.Attenuation           = {'max(0,current_unit_thresh-20)'  'dB'    [0    120]      };
IO_def.Inloop.Repetitions           = { 1                                ''     [1    Inf]      };
if (isequal(fieldname,'Inloop'))
   if (~isequal(current_unit_bf, prev_unit_bf))
      cur_bf = current_unit_bf;
      if (cur_bf <=1.2)
         IO_def.Inloop.List_File{1}{1} = '{a}';
      elseif (cur_bf <=1.7)
         IO_def.Inloop.List_File{1}{2} = '{b}';
      elseif (cur_bf <=2.4)
         IO_def.Inloop.List_File{1}{3} = '{c}';
      elseif (cur_bf <=3.3)
         IO_def.Inloop.List_File{1}{4} = '{d}';
      elseif (cur_bf <=4.7)
         IO_def.Inloop.List_File{1}{5} = '{e}';
      elseif (cur_bf <=6.4)
         IO_def.Inloop.List_File{1}{6} = '{f}';
      elseif (cur_bf <=9.4)
         IO_def.Inloop.List_File{1}{7} = '{g}';
      else
         IO_def.Inloop.List_File{1}{8} = '{h}';
      end
      IO_def.Inloop.List_File{5}    = 1; 
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

tmplt.tag               = 'LRAFSpeach_tmplt';
tmplt.IO_def = IO_def;
