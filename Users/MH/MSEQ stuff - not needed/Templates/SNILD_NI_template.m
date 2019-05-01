function [tmplt,DAL,stimulus_vals,units,errstr] = SNILD_NI_template(fieldname,stimulus_vals,units)
%
% Made this template to see if I was getting consistent presenation differences for my SN/ILD stimuli
% by using the NI board rather than the TDT system.  This presents the SN/ILD stimuli (frozen) in the
% normal fashion, but does the resampling on the fly and allows you to extend the stimulus time.

% SMC, 7/14/04

global signals_dir schase_list_bf_str
% schase_list_bf_str is leftover from previous templates, and while no
% longer necessary for this list file, is used in subroutines below.

persistent   prev_playdur  prev_min_period  prev_maxlen
% We use the persistent variables to detect a change that requires some fields update.
% For example, of the play duration is changed we would like to update the gating information.
% We restict the automatic updates to allow the user the overide them.

% Note:  because the maximum rate allowed by the NI board is 333/2 kHz and the max rate I could need
% for my standard sampling rate is much higher, I pre-resampled the stimuli by a factor of 2.  If the 
% BF of the unit is > useupshiftfreq below, I will use the pre-resampled stimuli, and reduce the NI board's
% resampling frequency by a factor of 2.  Should work for BFs up to ~ 38kHz.
useupshiftfreq = 17;


used_devices.Llist         = 'L3';
used_devices.Rlist         = 'R3';
tmplt = template_definition(fieldname);
if (exist('stimulus_vals','var') == 1)
   schase_list_bf_str = num2str(stimulus_vals.Inloop.Frequency);
   if stimulus_vals.Inloop.Frequency > useupshiftfreq
      List_File = [signals_dir 'Lists\schase\snild_ni_frozen_us.m' ];
   else
      List_File = [signals_dir 'Lists\schase\snild_ni_frozen.m' ];
   end
   if (exist(List_File,'file') ~= 0)
      [Llist,Rlist] = read_rotate_list_file(List_File);
      if (~isempty(Llist) & ~isempty(Rlist)) 
         if (~isempty(Llist))
            [data fs] = audioread(Llist{1});
         elseif (~isempty(Rlist))
            [data fs] = audioread(Rlist{1});
         end
         
         % Get sampling rate at which stimuli need to be played to shift SN to BF:
         if stimulus_vals.Inloop.Frequency > useupshiftfreq
            stimulus_vals.Inloop.UpdateRate=fs*(stimulus_vals.Inloop.Frequency/2/11.14); %Shift to feature
         else
            stimulus_vals.Inloop.UpdateRate=fs*(stimulus_vals.Inloop.Frequency/11.14); %Shift to feature
         end
         stimulus_vals.Inloop.UpdateRate = NI6052UsableRate_Hz(stimulus_vals.Inloop.UpdateRate); % GE/MH 04Nov2003:

         % Note:  The division by 2 is a KLUGE I had to put in b/c the maximum rate assumes only 1 channel
         % and I have 2.  When (if) that is fixed in the C-code I will have to correct the lines below.
         % Template forces use of a rate that is valid for the NI6052e board in the
         %  mode in which it is called (see 'd2a.c').                       
         if (stimulus_vals.Inloop.UpdateRate> NI6052UsableRate_Hz(Inf)/2)
            stimulus_vals.Inloop.UpdateRate=NI6052UsableRate_Hz(Inf)/2;
            nelerror('In SNILD_random_template: Requested sampling rate greater than MAX rate allowed by NI board!!');
         end
         
         if isequal(stimulus_vals.Inloop.Expand,'No')  % Then change duration to match file length at our new fs
            playdur = floor(length(data)/stimulus_vals.Inloop.UpdateRate*1000);	%compute file duration based on new fs
            if playdur > 350
               min_period=1100;
            else
               min_period=1000;
            end
            
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
               tmplt.IO_def.Gating.Duration{1}  = ['min(' num2str(playdur) ',400)'];
               tmplt.IO_def.Gating.Period{1}    = ['max(' num2str(min_period) ',1000)'];
               [stimulus_vals.Gating units.Gating] = structdlg(tmplt.IO_def.Gating,'',[],'off');
               prev_playdur = playdur;
               prev_min_period = min_period;
            end
            %
%             if (~isequal(prev_maxlen, max(length(Llist),length(Rlist))))
%                tmplt.IO_def.Inloop.Presentations{1}  = round(100/max(length(Llist),length(Rlist)));
%                new_stimulus_vals.Inloop  = structdlg(tmplt.IO_def.Inloop,'',[],'off'); % change only the repetitions!!
%                stimulus_vals.Inloop.Presentations = new_stimulus_vals.Inloop.Presentations;
%                prev_maxlen = max(length(Llist),length(Rlist));
%             end
         end
      else
         Llist = [];
         Rlist = [];
         prev_maxlen = 0;
      end
   else
      Llist = [];
      Rlist = [];
      prev_maxlen = 0;
   end
   
   Inloop.Name                         = 'DALinloop_NI_wavs_smc';
   % Inloop.Name                         = 'DALinloop_wavfiles';
   Inloop.params.list                  = Llist;
   Inloop.params.Rlist                 = Rlist;
   Inloop.params.attens                = stimulus_vals.Inloop.Attenuation;
   Inloop.params.Rattens               = stimulus_vals.Inloop.Attenuation;
   Inloop.params.repetitions           = stimulus_vals.Inloop.Repetitions;
   % Actual # of repetitions is 1 since they are all unique files
   Inloop.params.resample_ratio        = NaN;
   Inloop.params.playback_slowdown     = 1;
   Inloop.params.updateRate_Hz         = stimulus_vals.Inloop.UpdateRate;
   Inloop.params.Expand                = stimulus_vals.Inloop.Expand;
   DAL.funcName = 'data_acquisition_loop_NI'; % added by GE 30oct2003.
   DAL.Inloop = Inloop;
   DAL.Gating = stimulus_vals.Gating;
   DAL.Mix         = mix_params2devs(stimulus_vals.Mix,used_devices);
   DAL.short_description   = 'SNNI';  % Stands for Spectral Notch, NI board
   DAL.description = build_description(DAL,stimulus_vals);
   errstr = check_DAL_params(DAL,fieldname);
end

%----------------------------------------------------------------------------------------
function str = build_description(DAL,stimulus_vals)
global schase_list_bf_str
p = DAL.Inloop.params;
str{1} = sprintf('NI: ILD/SN resampled to %s ', schase_list_bf_str);
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
global signals_dir
persistent prev_unit_bf 
%%%%%%%%%%%%%%%%%%%%
%% Inloop Section 
%%%%%%%%%%%%%%%%%%%%
IO_def.Inloop.Frequency         =  {'current_unit_bf'   'kHz'      [0.04  50]   0  0}; 
IO_def.Inloop.Attenuation       =  {'max(0,current_unit_thresh-20)'  'dB'    [0    120]      };
IO_def.Inloop.Repetitions     =  { 4                                ''     [1    Inf]      };
IO_def.Inloop.Expand            =  {'Yes|{No}'};
% IO_def.Inloop.Resample_Ratio        = { 1                        ''      [0.05    4]      };
if (isequal(fieldname,'Inloop'))
   if (~isequal(current_unit_bf, prev_unit_bf))
      IO_def.Inloop.Frequency{5}         = 1; 
      prev_unit_bf = current_unit_bf;
   end
end


%%%%%%%%%%%%%%%%%%%%
%% Gating Section 
%%%%%%%%%%%%%%%%%%%%
IO_def.Gating.Duration             = {400       'ms'    [20 2000]};
IO_def.Gating.Period               = {'default_period(this.Duration)'    'ms'   [50 5000]};
IO_def.Gating.Rise_fall_time       = {10        'ms'    [0  1000] 1}; 

%%%%%%%%%%%%%%%%%%%%
%% Mix Section 
%%%%%%%%%%%%%%%%%%%%
IO_def.Mix.Llist        =  {'{Left}|Both|Right'};
IO_def.Mix.Rlist        =  {'Left|Both|{Right}'};

tmplt.tag               = 'SNILD_NI_tmplt';
tmplt.IO_def = IO_def;

