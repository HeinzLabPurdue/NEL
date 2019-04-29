function varargout = DALinloop_pedestals(varargin)
%
%   The input and output arguments are structure with the following fields
%   varargin{1} (common)  : index, dispStatus, short_description
%   varargin{2} (specific) : see list below
%
%   varargout{1} (stim_info)  : attens_devices
%   varargout{2} (block_info) : see below
%   varargout{3} (plot_info) : var_name, var_unit, var_vals, var_frmt, XYprops

% AF 12/06/01

% specific:
% freq
% ramp_attn
% ramp_dur
% ped_dur
% ped_delay
% ped_rts
% ped_steps
% repetitions

% rco:
% freq
% RampAttn
% RampDur
% PedRT
% PedDur
% PedDelay
% PedAttn


global static_bi static_pi ; % Static variables
global RP root_dir

rc = 1;
if (nargin == 0)
   static_bi = []; static_pi = []; ;
   clear static_bi static_pi  ;
   return
elseif (nargin >=1)
   common = varargin{1};
end
if (nargin == 2)
   specific = varargin{2};
end

%% Preloop stuff
if (common.index == 0) 
   return;
end

if (common.index == 1) 
   static_pi = default_inloop_plot_info;
   static_pi.dispStatus = common.dispStatus;
   % Initialize and set specific values to the static block info structure
   static_bi = specific;
   nstim = length(specific.ped_rts) * length(specific.ped_steps);
   nlines = nstim * specific.repetitions;
   description = 'Tone Pedestals';
   short_description = 'PD';

   
   %%%%% Load rco to RP
   main_rco = [root_dir 'stimulate\object\pedestal.rco'];
   params.freq  = static_bi.freq;
   params.RampDur = static_bi.ramp_dur;
   params.PedDur  = static_bi.ped_dur;
   params.PedDelay = static_bi.ped_delay;
   
   rc = RPload_rco(main_rco) & (rc==1);
   % RPload_rco clears the RP's params;
   RP(1).params = params;
   dev_description = nel_devices_vector('RP1.1','Pedestal');
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
   static_pi.var_vals           = 1:nlines;
   static_pi.XYprops.Lim    = [0 nlines+1];

end   

if (common.index == 2)
   %remove parameters that do not change to save inloop time
   if (isfield(RP(1).params,'freq'))
      RP(1).params = rmfield(RP(1).params,'freq');
   end
   % TODO: clean up more const params
end

% Update 
ind = mod(common.index-1,static_bi.nstim)+1;
ind_step = floor((ind-1)/length(static_bi.ped_steps))+1;
ind_rt   = mod(ind-1,length(static_bi.ped_rts))+1;
[ramp_amp,ped_amp,main_attn] = pedestal_amps(static_bi.ramp_attn,static_bi.ped_steps(ind_step));
RP(1).params.RampAttn   = ramp_amp;
RP(1).params.PedAttn    = ped_amp;
RP(1).params.PedRT      = static_bi.ped_rts(ind_rt);
stim_info.ramp_amp      = ramp_amp;
stim_info.pedestal_amp  = ped_amp;
stim_info.pedestal_rt   = static_bi.ped_rts(ind_rt);

% Set attenuations and devices
main_dev = main_attn * nel_devices_vector('RP1.1');
stim_info.attens_devices = [main_dev main_dev];

if (nargout >=1)
   varargout{1} = stim_info;
end
if (nargout >=2)
   varargout{2} = static_bi;
end
if (nargout >=3)
   varargout{3} = static_pi;
end

%-------------------------------------------------------------------
function [ramp_amp,ped_amp,attn] = pedestal_amps(ramp_attn,ped_step)
attn = ramp_attn - ped_step;
ramp_amp = 1;
ped_amp = ramp_amp * 10^(ped_step/20) - ramp_amp;
overall = ramp_amp + ped_amp;
ped_amp = ped_amp / overall;
ramp_amp = ramp_amp / overall;