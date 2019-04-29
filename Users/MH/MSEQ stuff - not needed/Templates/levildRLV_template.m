function [tmplt,DAL,stimulus_vals,units,errstr] = levildRLV_template(fieldname,stimulus_vals,units)
%
% Template for RLV using levild.wav
%
% SMC 4/1/04
persistent   prev_playdur  prev_min_period  prev_maxlen
% We use the persistent variables to detect a change that requires some fields update.
% For example, of the play duration is changed we would like to update the gating information.
% We restict the automatic updates to allow the user the overide them.

used_devices.File         = 'RP1.1';
tmplt = template_definition(fieldname);
if (exist('stimulus_vals','var') == 1)  
   
   [data fs]=wavread(stimulus_vals.Inloop.File);
   playback_rate = 97656.25/(round(97656.25/fs)); % 97656.25 is the rco's sampling rate
   playdur = round(length(data)/playback_rate*1000);	%compute file duration based on sampling rate
   min_period = playdur + length(data)/97.656 * 0.55 + 250;
   min_period = ceil(min_period/100)*100;
   
   if (isequal(fieldname,'Inloop') | ~isequal(playdur,prev_playdur) | ~isequal(min_period,prev_min_period))
      tmplt.IO_def.Gating.Duration{1}  = playdur;
      tmplt.IO_def.Gating.Period{1}    = ['max(' num2str(min_period) ',1000)'];
      [stimulus_vals.Gating units.Gating] = structdlg(tmplt.IO_def.Gating,'',[],'off');
      prev_playdur = playdur;
      prev_min_period = min_period;
   end
   
   
   Inloop.Name                         = 'DALinloop_wavfiles_compressed';
   Inloop.params.list                  = {stimulus_vals.Inloop.File};
   Inloop.params.attens                = stimulus_vals.Inloop.High_Attenuation :-1:stimulus_vals.Inloop.Low_Attenuation;
%    Inloop.params.Rlist                 = {stimulus_vals.Inloop.File};
%    Inloop.params.Rattens               = stimulus_vals.Inloop.High_Attenuation :-1:stimulus_vals.Inloop.Low_Attenuation;
   Inloop.params.Rlist                 = [];
   Inloop.params.Rattens               = [];
   Inloop.params.repetitions           = 1;
   Inloop.params.resample_ratio        = NaN;
   Inloop.params.playback_slowdown     = 1;
   
   DAL.Inloop = Inloop;
   DAL.Gating = stimulus_vals.Gating;
   DAL.Mix         = mix_params2devs(stimulus_vals.Mix,used_devices);
   DAL.short_description   = 'levildRLV';
   DAL.description = build_description(DAL,stimulus_vals);
   errstr = check_DAL_params(DAL,fieldname);
   
   %%%%%%%
   % If parameters are NOT correct for this template, Take away this template name
   [Xdir,Xfile,Xext]=fileparts(stimulus_vals.Inloop.File);
   if((~isequal(fullfile('',[Xfile Xext]),'levild.wav'))| ...
           (length(DAL.Inloop.params.attens) == 1))
      DAL.short_description   = '';
   end
end

%----------------------------------------------------------------------------------------
function str = build_description(DAL,stimulus_vals)
p = DAL.Inloop.params;
[fpath,file] = fileparts(stimulus_vals.Inloop.File);
str{1} = sprintf('File ''%s'' ', file);
if (length(p.attens) > 1)
   str{1} = sprintf('%s @ %1.1f - %1.1f dB Attn.', str{1}, p.attens(1), p.attens(end));
else
   if (~isempty(p.attens))
      str{1} = sprintf('%s @ %1.1f dB Attn.', str{1}, p.attens(1));
   end
end
str{1} = sprintf('%s (%s)', str{1}, stimulus_vals.Mix.File);

%----------------------------------------------------------------------------------------
function errstr = check_DAL_params(DAL,fieldname)
% Some extra error checks
errstr = '';
if (isequal(fieldname,'Inloop'))
   if (isempty(DAL.Inloop.params.attens))
      errstr = 'Attenuations are not set correctly! (high vs. low mismatch?)';
   end
end

%----------------------------------------------------------------------------------------
function tmplt = template_definition(fieldname)
global signals_dir
persistent prev_unit_thresh
%%%%%%%%%%%%%%%%%%%%
%% Inloop Section 
%%%%%%%%%%%%%%%%%%%%
IO_def.Inloop.File              = { fullfile(signals_dir,'schase\levild.wav') '' [] 1 };
IO_def.Inloop.Low_Attenuation   = { 1             'dB'    [0    120]      };
IO_def.Inloop.High_Attenuation  = { 100           'dB'    [0    120]  0  0 };

if (~isequal(current_unit_thresh, prev_unit_thresh) & (isempty(fieldname) | isequal(fieldname,'Inloop')))
   IO_def.Inloop.High_Attenuation{5}            = 1;
   prev_unit_thresh = current_unit_thresh;
end

%%%%%%%%%%%%%%%%%%%%
%% Gating Section 
%%%%%%%%%%%%%%%%%%%%
IO_def.Gating.Duration             = {300       'ms'    [20 2000] 0};
IO_def.Gating.Period               = {'default_period(this.Duration)'    'ms'   [50 5000] 1};


%%%%%%%%%%%%%%%%%%%%
%% Mix Section 
%%%%%%%%%%%%%%%%%%%%
IO_def.Mix.File         = {'Left|{Both}|Right' '' [] 0};
% IO_def.Mix.Llist        =  {'{Left}|Both|Right'};
% IO_def.Mix.Rlist        =  {'Left|Both|{Right}'};

tmplt.tag               = 'levildRLV_tmplt';
tmplt.IO_def = IO_def;
