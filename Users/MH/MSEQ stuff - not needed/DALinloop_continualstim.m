function varargout = DALinloop_continualstim(varargin)
%
%   The input and output arguments are structure with the following fields
%   varargin{1} (common)   : index, left, right
%   varargin{2} (specific) : see list below
%
%   varargout{1} (stim_info)  : attens_devices 
%   varargout{2} (block_info) : nstim, nlines, stm_lst,  list,attens,Rlist,Rattens
%   varargout{3} (plot_info) : var_name, var_unit, var_vals, var_frmt, XYprops
%
%  specific->
%               list: []
%             attens: []
%              Rlist: []
%            Rattens: []
%        repetitions: []

% AF 9/22/01

global static_bi static_pi; % Static variable
global RP root_dir
global cached_resamp my_root_dir

rc = 1;
if (nargin == 0)
   static_bi = [];
   static_pi = [];
   cached_resamp = []; 
   clear static_bi static_pi cached_samples;
   return
elseif (nargin >=1)
   common = varargin{1};
end
if (nargin == 2)
   specific = varargin{2};
end

if (common.index == 0)
   return;
end
if (common.index == 1) 
   %%%% Initialize and set specific values to the static block info structure
   static_bi = specific;
   if (~isfield(specific,'repetitions'))
      specific.repetitions = 1;
   end
   nstim = max(length(static_bi.list),length(static_bi.attens));
   if nstim~=1
      error('DALinloop_continualstim can only handle 1 stimulus');
   end
   nlines = static_bi.repetitions;
   static_pi=inloop_plot_info_contstim(nlines);
   
   %%%%% Load rco to RP
   rconame = [my_root_dir 'object\continualstim.rco'];
      
   if (isempty(static_bi.Rlist))
      rc = RPload_rco(rconame) & (rc==1);
      dev_description = nel_devices_vector('RP1.1','list');
   else
      rc = RPload_rco({rconame, rconame}) & (rc==1);
      dev_description = nel_devices_vector({'RP1.1','RP2.1'},{'list','Rlist'});
   end
   if (rc == 0)
      return;
   end

   short_description = 'cs'; % stands for continual stimulation
   if (isfield(common,'short_description'))
      short_description = common.short_description;
   end
   if (isfield(common,'description'))
      description = common.description;
   end
   %%%%% These fields should be set in ANY inloop function %%%%%%
   static_bi.nstim           = nstim;
   static_bi.nlines          = nlines;
   static_bi.description     = description;
   static_bi.short_description  = short_description;
   static_bi.dev_description = dev_description;
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   
end   

% load new stimuli (if necessary) 
if (common.index == 1)
   [data,sr,rc] = nel_wavread(static_bi.list{1});
   if (rc == 0)
      nelerror(['Can''t read wavfile ''' static_bi.list{1} '''']);
   else
      rc = load_rawsamps_contstim(1,data,sr) & (rc==1);
      % load_rawsamps_contstim(1,data,sr) sets the buff_data and buff_size parameters for RP(1).
      % Still need to set the size_x_reps parameter.
      RP(1).params.size_x_reps=nlines*RP(1).params.buff_size;
   end
   static_bi.playback_sampling_rate(1)  = sr;
else
   RP(1).params = []; % Clear params to avoid sending the same old data again to the RP!
end
if (((common.index == 1) | (length(static_bi.Rlist) > 1)) & (length(static_bi.Rlist) >0))
   [data,sr,rc] = nel_wavread(static_bi.Rlist{1});
   if (rc == 0)
      nelerror(['Can''t read wavfile ''' static_bi.Rlist{1} '''']);
   else
      rc = load_rawsamps_contstim(2,data,sr) & (rc==1);
      % load_rawsamps_contstim(2,data,sr) sets the buff_data and buff_size parameters for RP(2).
      % Still need to set the size_x_reps parameter.
      RP(2).params.size_x_reps=nlines*RP(2).params.buff_size;
   end
   static_bi.playback_sampling_rate(2)  = sr;
else
   RP(2).params = []; % Clear params to avoid sending the same old data again to the RP!
end

% Set attenuations and devices
atten = static_bi.attens(1);
left_dev =  atten * nel_devices_vector('RP1.1');
if (isempty(static_bi.Rlist))
   right_dev = nel_devices_vector([]);
else
   if (~isempty(static_bi.Rattens))
      Ratten = static_bi.Rattens(1);
   else
      Ratten = atten;
   end
   right_dev = Ratten * nel_devices_vector('RP2.1');
end
devs     = max([left_dev right_dev],[],2);
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

