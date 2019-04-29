function varargout = DALinloop_TN_bothears(varargin)
%
%   The input and output arguments are structure with the following fields
%   varargin{1} (common)  : index, dispStatus, short_description
%   varargin{2} (specific) : see list below
%
%   varargout{1} (stim_info)  : attens_devices
%   varargout{2} (block_info) : nstim, nlines,   freqs, attens, rise_fall, 
%                               noise_atten, noise_low_cutoff, noise_high_cutoff
%   varargout{3} (plot_info) : var_name, var_unit, var_vals, var_frmt, XYprops

% AF 9/22/01

% specific.main.source
% specific.main.tone.freq
% specific.main.tone.bw
% specific.main.noise.low_cutoff
% specific.main.noise.high_cutoff
% specific.main.attens
% 
% specific.secondary.source
% specific.secondary.tone.freq
% specific.secondary.noise.low_cutoff
% specific.secondary.noise.high_cutoff
% specific.secondary.noise.gating
% specific.secondary.noise.adaptation
% specific.secondary.atten
%
% specific.rise_fall;

% TODO: remove the unused noise/tone fields

global static_bi static_pi bkgrnd_dev__; % Static variables
global RP root_dir

rc = 1;
if (nargin == 0)
   static_bi = []; static_pi = []; bkgrnd_dev__ = [];
   clear static_bi static_pi bkgrnd_dev__ ;
   return
elseif (nargin >=1)
   common = varargin{1};
end
if (nargin == 2)
   specific = varargin{2};
end

%% Preloop stuff
if (common.index == 0) 
   if (strcmp(lower(static_bi.main.source),'noise'))
      RPset_params(RP(1),'CalcCoef',1);
      RPset_params(RP(1),'CalcCoef',0);
      % double(invoke(RP(1).activeX,'GetCycUse'))
   end
   if (strcmp(lower(static_bi.secondary.source),'noise'))
      RPset_params(RP(2),'CalcCoef',1);
      RPset_params(RP(2),'CalcCoef',0);
      % double(invoke(RP(2).activeX,'GetCycUse'))
   end
   return;
end

if (common.index == 1) 
   static_pi = default_inloop_plot_info;
   static_pi.dispStatus = common.dispStatus;
   % Initialize and set specific values to the static block info structure
   static_bi = specific;
   
   %Binaural beats
   if strcmp(lower(specific.main.source),'tone')...
           & isfield(specific.main.tone,'startfreq') ...
           & isfield(specific.main.tone,'endfreq')...
           & strcmp(lower(specific.secondary.source),'tone')... 
           & isfield(specific.secondary.tone,'beatfreq')
       description = 'Binaural Beat Freq Sweep';
       short_description = 'BFSweep';
       nstim = length(specific.main.tone.startfreq:specific.main.tone.freqstep:specific.main.tone.endfreq);
       nreps = static_bi.repetitions;
       nlines = nstim*nreps;
       static_bi.main.freqs = zeros(nstim,1);
       static_bi.secondary.tone.freq = zeros(nstim,1);
       
       freqstart = specific.main.tone.startfreq;
       freqend = specific.main.tone.endfreq;
       freqstep = specific.main.tone.freqstep;
       
       static_bi.main.freqs = freqstart:freqstep:freqend;
       static_bi.secondary.tone.freq = static_bi.main.freqs+specific.secondary.tone.beatfreq;
       if nreps==1
           static_pi.var_name = 'Frequency';
           static_pi.var_unit = 'kHz';
           static_pi.var_vals = repmat(static_bi.main.freqs/1000,1,nreps);
           static_pi.var_frmt = '%.2f';
           static_pi.XYprops.Lim    = [freqstart freqend]/1000;
           static_pi.XYprops.Tick   = [static_bi.main.freqs]/1000;
           static_pi.XYprops.Scale  = 'linear';
           static_pi.XYprops.Dir    = 'normal';
       else
           static_pi.var_name = 'Presentation';
           static_pi.var_unit = '#';
           static_pi.var_vals = 1:nlines;
           static_pi.var_frmt = '%.2f';
           static_pi.XYprops.Lim    = [1 nlines];
           static_pi.XYprops.Tick   = [1 round(nlines/2) nlines];
           static_pi.XYprops.Scale  = 'linear';
           static_pi.XYprops.Dir    = 'normal';
       end
   %Static tone ITDs
   elseif strcmp(lower(specific.main.source),'tone')...
           & isfield(specific,'startITD')
       
       description = 'ITD Freq Sweep';
       short_description = 'ITDsweep';
       nstim = length(specific.main.tone.startfreq:specific.main.tone.freqstep:specific.main.tone.endfreq);
       nlines = nstim*static_bi.repetitions;
       static_bi.main.freqs = zeros(nstim,1);
       static_bi.secondary.tone.freq = zeros(nstim,1);
       
       freqstart = specific.main.tone.startfreq;
       freqend = specific.main.tone.endfreq;
       freqstep = specific.main.tone.freqstep;
       
       static_bi.main.freqs = freqstart:freqstep:freqend;
       static_bi.secondary.tone.freq = static_bi.main.freqs+specific.secondary.tone.beatfreq;
       
       
   elseif (strcmp(lower(specific.main.source),'tone') &  (specific.main.tone.bw > 0))
       description = 'Freq Sweep';
       short_description = 'Fsweep';
       nstim = 99;
       nlines = 99;
       static_bi.main.freqs = zeros(nstim,1);
       frqlo = specific.main.tone.freq*(2^(-specific.main.tone.bw/2));
       frqhi = specific.main.tone.freq*(2^( specific.main.tone.bw/2));
       static_bi.main.freqs([1:2:99])   = logspace(log10(specific.main.tone.freq),log10(frqhi),50)';
       static_bi.main.freqs([1 2:2:98]) = logspace(log10(specific.main.tone.freq),log10(frqlo),50)';
       
       static_pi.var_name = 'Frequency';
       static_pi.var_unit = 'kHz';
       static_pi.var_vals = static_bi.main.freqs/1000;
       static_pi.var_frmt = '%.2f';
       static_pi.XYprops.Lim    = [frqlo frqhi]/1000;
       static_pi.XYprops.Tick   = [frqlo specific.main.tone.freq frqhi]/1000;
       static_pi.XYprops.Scale  = 'log';
       static_pi.XYprops.Dir    = 'normal';
      
   elseif (~strcmp(lower(specific.main.source),'none'))    % modified to elseif by GE, 29Mar2002.      
      % Tone and noise rate level
      if (strcmp(lower(specific.main.source),'noise'))
         source = 'Noise';
      else
         source = 'Tone';
      end
      static_bi.main.freqs  = specific.main.tone.freq;
      nstim = length(static_bi.main.attens);
      nlines = nstim*static_bi.repetitions; %KH
%      nlines = nstim;
      description = [source ' Rate Level'];
      short_description = [source '_ralv'];
      if (nstim == 1)
         description = [source ' PST'];
         short_description = source;
         if (isfield(static_bi,'repetitions'))
            nlines = static_bi.repetitions;
         else
            nlines = 100;
         end
         static_pi.var_name = 'Presentation number';
         static_pi.var_vals = 1:nlines;
         static_pi.XYprops.Lim    = [0 nlines+1];
         static_pi.XYprops.Tick   = [0:round(nlines/100)*10:nlines+1];
      else
         static_pi.var_name = 'Attenuation';
         static_pi.var_unit = 'dB';
         static_pi.var_vals = static_bi.main.attens(1:nstim);
         static_pi.var_frmt = '%d';
         static_pi.XYprops.Lim    = [min(static_bi.main.attens(1:nstim))-1 max(static_bi.main.attens(1:nstim))+1];
         static_pi.XYprops.Tick   = [0:10:120];
         static_pi.XYprops.Scale  = 'linear';
         static_pi.XYprops.Dir    = 'reverse';
      end
   else   % else-block added by GE, 29Mar2002
      % source is 'None'
      description = 'No sound';
      short_description = 'None';
      nlines = static_bi.repetitions;
      static_pi.XYprops.Lim = [0 nlines+1];                          % added by GE, 28Jul2003 -- to set proper 
      static_pi.XYprops.Tick   = [0:round(nlines/100)*10:nlines+1];  %  Y limits for display during "PST" template.
                                                                     %  May interfere with other templates????
      static_pi.var_vals = 1:nlines;
      nstim = 1;
   end
   
   %%%%% Load rco to RP
   switch (lower(static_bi.main.source))
   case 'noise'
      params1.lo_cutoff = static_bi.main.noise.low_cutoff;
      params1.hi_cutoff = static_bi.main.noise.high_cutoff;
      main_rco = [root_dir 'stimulate\object\noise_bursts.rco'];
      params1.RiseFall  = static_bi.rise_fall;
   case 'tone'
      params1.freq      = static_bi.main.freqs(1);
      main_rco = [root_dir 'stimulate\object\tone_bursts.rco'];
      params1.RiseFall  = static_bi.rise_fall;
      
%       'stimulate\object\tone_bursts_delay.rco'
   case 'none'     % added by GE, 29Mar2002.
      main_rco = [root_dir 'stimulate\object\control.rco'];
      params1 = [];
   end

   switch (lower(static_bi.secondary.source))
   case 'noise'
      % params2.CalcCoef = 1;
      params2.RiseFall  = static_bi.rise_fall;
      params2.lo_cutoff = static_bi.secondary.noise.low_cutoff;
      params2.hi_cutoff = static_bi.secondary.noise.high_cutoff;
      sec_rco = [root_dir 'stimulate\object\background_noise.rco']; % CHANGE AFTER control part of rco is gone!
   case 'tone'
      params2.RiseFall  = static_bi.rise_fall;
      params2.freq      = static_bi.secondary.tone.freq(1);%(1) added by M.S. 2016 - to deal with binaural beats
      sec_rco = [root_dir 'stimulate\object\tone_bursts.rco'];
   case 'none'
      sec_rco = [];
      params2 = [];  
   end
   
   rc = RPload_rco({main_rco, sec_rco}) & (rc==1);
   % RPload_rco clears the RP's params;
   RP(1).params = params1;
   RP(2).params = params2;
   if (isempty(sec_rco))
      bkgrnd_dev__     = nel_devices_vector([]);
      dev_description = nel_devices_vector('RP1.1',static_bi.main.source);
   else
      if (isempty(specific.secondary.atten))
         nelerror('in DALinloop_general_TN: Background attenuation is not set!');
      end
      bkgrnd_dev__     = nel_devices_vector('RP2.1') * specific.secondary.atten;
      dev_description = nel_devices_vector({'RP1.1','RP2.1'}, ...
         {static_bi.main.source,['background_' static_bi.secondary.source]});
   end
   
   if (isfield(common,'short_description'))
      short_description = common.short_description;
   end
   if (isfield(common,'description'))
      description = common.description;
   end
   %%%%% These fields should be set in ANY inloop function %%%%%%
   static_bi.nstim              = nstim;
   static_bi.nlines             = nlines;
   static_bi.description        = description;
   static_bi.short_description  = short_description;
   static_bi.dev_description    = dev_description;
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end   

if (common.index == 2)
   %remove parameters that do not change to save inloop time
   if (isfield(RP(1).params,'RiseFall'))
       RP(1).params = rmfield(RP(1).params,'RiseFall');
   end
   if (length(static_bi.secondary.tone.freq) == 1)%Added by MS, 2016 - to make an exception for binaural beat stimulus where RP(2) parameters do change on a stim by stim basis
       RP(2).params = [];
   end
end

% Update frequency if necessary
if strcmp(lower(specific.main.source),'tone')   % if-statement added by GE, 29Mar2002.
	if length(static_bi.main.freqs)>1
        n_main_stim = length(static_bi.main.freqs);
       cur_freq = static_bi.main.freqs(mod(common.index-1,n_main_stim)+1);
       RP(1).params.freq = cur_freq;
       stim_info.freq    = cur_freq;
	end
    
    if length(static_bi.secondary.tone.freq)>1 
        n_sec_stim = length(static_bi.secondary.tone.freq);
        cur_freq2 = static_bi.secondary.tone.freq(mod(common.index-1,n_sec_stim)+1);
        RP(2).params.freq = cur_freq2;
    end
    mod(common.index-1,n_main_stim)+1
    fprintf('F1 = %2.1f',cur_freq);
    fprintf('F2 = %2.1f',cur_freq2);
end

% Set attenuations and devices
if length(static_bi.main.attens)>1
    main_dev = static_bi.main.attens(mod(common.index-1,n_main_stim)+1) * nel_devices_vector('RP1.1');
else
    main_dev = static_bi.main.attens(1) * nel_devices_vector('RP1.1');
end
devs     = max([main_dev bkgrnd_dev__],[],2);
stim_info.attens_devices = [devs devs];

if (nargout >=1)
   varargout{1} = stim_info;
end
if (nargout >=2)
   varargout{2} = static_bi;
end
if (nargout >=3)
   varargout{3} = static_pi;
end
