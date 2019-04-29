function varargout = DALinloop_spiketest(varargin)
%
%   The input and output arguments are structure with the following fields
%   varargin{1} (common)  : index, left, right
%   varargin{2} (specific) : attens, rise_fall, noise_low_cutoff, noise_high_cutoff
%
%   arargout{1} (stim_info)  : attens_devices
%   arargout{2} (block_info) : nstim, nlines, stm_lst, attens, rise_fall, 
%                              noise_low_cutoff, noise_high_cutoff
%   varargout{3} (plot_info) : var_name, var_unit, var_vals, var_frmt, XYprops
%

% AF 9/22/01

global static_bi static_pi; % Static variables
global RP root_dir

rc = 1;
if (nargin == 0)
   static_bi = []; 
   static_pi = [];
   clear static_bi static_pi
   return
elseif (nargin >=1)
   common = varargin{1};
end
if (nargin == 2)
   specific = varargin{2};
end

if (common.index == 1) 
   % Initialize and set specific values to the static block info structure
   static_pi = default_inloop_plot_info;
   description = 'Test Spike';
   short_description = 'bit2-spk';
   nstim = 1;
   nlines = 100;
   stm_lst   = 1:100;
   
   %%%%% Load rco to RP
   rc = RPload_rco([root_dir 'stimulate\object\spike_test.rco']) & (rc==1);
   dev_description = nel_devices_vector('RP1.1','nothing_really');
   
   %%%%% These fields should be set in ANY inloop function %%%%%%
   static_bi.nstim           = nstim;
   static_bi.nlines          = nlines;
   static_bi.description     = description;
   static_bi.short_description  = short_description;
   static_bi.dev_description = dev_description;
   static_bi.stm_lst         = stm_lst;
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   static_bi.count_step = specific.count_step;
   
   RP(1).params.CountStep  = static_bi.count_step;
end   

if (common.index == 2)
   RP(1).params = [];
end

% Set attenuations and devices
dummy_dev = 1 * nel_devices_vector('RP1.1');
left_dev = dummy_dev;
right_dev = nel_devices_vector([]);
stim_info.attens_devices = [left_dev right_dev];

if (nargout >=1)
   varargout{1} = stim_info;
end
if (nargout >=2)
   varargout{2} = static_bi;
end
if (nargout >=3)
   varargout{3} = static_pi;
end
