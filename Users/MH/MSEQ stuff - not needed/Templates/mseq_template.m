function [tmplt,DAL,stimulus_vals,units,errstr] = mseq_template(fieldname,stimulus_vals,units)

% SMC 7/9/04
% USES build_mseq.m

global signals_dir

used_devices.File         = 'RP1.1';
tmplt = template_definition(fieldname);
if (exist('stimulus_vals','var') == 1)
   mseqsigdir=[signals_dir 'dma' filesep 'mseq'];
   [successfulbuild,data,full_dur,act_frame_dur]=build_mseq(stimulus_vals.Inloop.Frequency,...
      stimulus_vals.Inloop.FrameDuration, stimulus_vals.Inloop.Order,mseqsigdir);
   if length(data)>7000000
      nelwarn('Very long stimulus!  Make sure the buffer in .rco is big enough!');
   end
   if successfulbuild
      tempfreqstr=num2str(stimulus_vals.Inloop.Frequency);
      freqstr=strrep(tempfreqstr,'.','pt');
      tempframedurstr=num2str(stimulus_vals.Inloop.FrameDuration);
      framedurstr=strrep(tempframedurstr,'.','pt');
      orderstr=num2str(stimulus_vals.Inloop.Order);
      stimfile=[mseqsigdir filesep 'mseq' freqstr 'kHz_f' framedurstr '_o' orderstr '.wav'];
   else % wasn't a successfulbuild
      error('Couldn''t build m-sequence!');
   end
   
   Inloop.Name                            = 'DALinloop_continualstim';
   Inloop.params.list                     = {stimfile};
   Inloop.params.Rlist                    = {};
   Inloop.params.attens                   = stimulus_vals.Inloop.Attenuation;
   Inloop.params.Rattens                  = [];
   Inloop.params.freq                     = stimulus_vals.Inloop.Frequency;
   Inloop.params.mseq_order               = stimulus_vals.Inloop.Order;
   Inloop.params.repetitions              = stimulus_vals.Inloop.Repetitions;
   Inloop.params.requested_frame_duration = stimulus_vals.Inloop.FrameDuration;
   Inloop.params.actual_frame_duration    = act_frame_dur;
   Inloop.params.stimulus_duration        = full_dur;

   DAL.funcName = 'data_acqloop_contstim';
   DAL.Inloop = Inloop;
   DAL.Gating.Duration = ceil(full_dur);
   DAL.Gating.Period = ceil(full_dur);
   DAL.Mix    = mix_params2devs(stimulus_vals.Mix,used_devices);
   DAL.short_description   = 'MSEQ';
   DAL.description = build_description(DAL,stimulus_vals);
   errstr = check_DAL_params(DAL,fieldname);
end

%----------------------------------------------------------------------------------------
function str = build_description(DAL,stimulus_vals)
p = DAL.Inloop.params; s=stimulus_vals.Inloop;
str{1} = sprintf('M-Sequence tone @ %g kHz, order %d, frame duration %d @ %d dB attn',...
   s.Frequency, s.Order, s.FrameDuration, s.Attenuation);
if (isfield(stimulus_vals.Mix,'Llist'))
   str{1} = sprintf('%s (->%s)', str{1}, s.Mix.File);
end

%----------------------------------------------------------------------------------------
function errstr = check_DAL_params(DAL,fieldname)
% Some extra error checks
errstr = '';
if (isequal(fieldname,'Inloop'))
   if (isempty(DAL.Inloop.params.attens))
      errstr = 'Attenuation is not set';
   end
end

%----------------------------------------------------------------------------------------
function tmplt = template_definition(fieldname)
global signals_dir
%%%%%%%%%%%%%%%%%%%%
%% Inloop Section 
%%%%%%%%%%%%%%%%%%%%
IO_def.Inloop.Frequency             =  {'current_unit_bf'   'kHz'      [0.04  50]   0  0}; 
IO_def.Inloop.Attenuation           = {'max(0,current_unit_thresh-20)'  'dB'    [0    120]      };
IO_def.Inloop.Order                 = { 10                        ''      [2    20]       };
IO_def.Inloop.FrameDuration         = { 3                         'ms'    [.5   50]       };
IO_def.Inloop.Repetitions           = { 1                        ''      [1    Inf]      };


%%%%%%%%%%%%%%%%%%%%
%% Gating Section 
%%%%%%%%%%%%%%%%%%%%

IO_def.Gating.Duration             = {1000       'ms'    [20 2000]};
IO_def.Gating.Period               = {1000       'ms'   [50 5000]};

%%%%%%%%%%%%%%%%%%%%
%% Mix Section 
%%%%%%%%%%%%%%%%%%%%
IO_def.Mix.File                         =  {'Left|{Both}|Right'};

tmplt.tag               = 'mseq_tmplt';
tmplt.IO_def = IO_def;
