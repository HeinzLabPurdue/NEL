function varargout = DALinloop_wavfiles_compressed(varargin)
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
%     resample_ratio: []
%     playback_slowdown: []
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
   static_pi = default_inloop_plot_info;
   static_bi = specific;
   if (~isfield(specific,'repetitions'))
      specific.repetitions = 1;
   end
   nstim = max(length(static_bi.list),length(static_bi.attens));
   if (min(length(static_bi.list),length(static_bi.attens)) ~= 1 & length(static_bi.list) ~= length(static_bi.attens))
      error(sprintf('Inconsistent number of attenuations (%d) and file names (%d)', ...
         length(static_bi.attens), length(static_bi.list)));
   end
   if (nstim == 1 & static_bi.repetitions == 1)
      nlines = 100;
      static_pi.var_name = 'Presentation number';
   else
      nlines = nstim * static_bi.repetitions;
   end
   if (length(static_bi.attens) > 1)
      if (static_bi.repetitions == 1)
         static_pi.var_name = 'Attenuation';
         static_pi.var_unit = 'dB';
         static_pi.var_vals = static_bi.attens;
         static_pi.var_frmt = '%d';
         static_pi.XYprops.Lim  = [min(static_bi.attens)-1 max(static_bi.attens)+1];
         static_pi.XYprops.Tick = [0:10:120];
         static_pi.XYprops.Dir  = 'reverse';
      else
         var_labels = cell(1,nlines);
         counter = 1;
         for ii = 1:static_bi.repetitions
            for jj = 1:length(static_bi.attens)
               var_labels{counter} = sprintf('%d (Rep. #%d) ', static_bi.attens(jj), ii);
               counter = counter+1;
            end
         end
         static_pi.var_name = 'Attenuation';
         static_pi.var_unit = 'dB';
         static_pi.var_frmt = '%s';
         shift              = repmat([0:static_bi.repetitions-1]/(static_bi.repetitions*2),length(static_bi.attens),1);
         static_pi.var_vals     = repmat(static_bi.attens,1,static_bi.repetitions) + shift(:)';
         static_pi.var_labels   = var_labels;
         static_pi.XYprops.Lim  = [min(static_bi.attens)-1 max(static_bi.attens)+1];
         static_pi.XYprops.Tick = [0:10:120];
         static_pi.XYprops.Dir  = 'reverse';
      end
   else
      if (nstim > 1)
         static_pi.var_name = 'File';
         static_pi.var_unit = '';
         static_pi.var_frmt = '%s';
         var_labels = cell(1,nlines);
         counter = 1;
         for ii = 1:specific.repetitions
            for jj = 1:nstim
               [dummypath fname] = fileparts(static_bi.list{jj});
               var_labels{counter} = fname; 
               if (~isempty(static_bi.Rlist))
                  [dummypath fname] = fileparts(static_bi.Rlist{jj});
                  var_labels{counter} = [var_labels{counter} ' + ' fname]; 
               end
               if (ii > 1)
                  var_labels{counter} = [var_labels{counter} ' (Repetition #' int2str(ii) ')']; 
               end
               counter = counter+1;
            end   
         end
         static_pi.var_labels   = var_labels;
         static_pi.var_vals     = 1:nlines;
         static_pi.XYprops.Lim  = [0 nlines+1];
         % static_pi.XYprops.Tick = [0:10:120];
         static_pi.XYprops.Dir  = 'normal';
      else
         static_pi.var_name = 'Repetition #';
      end
   end
   
   %% Resample (if necessary) 
   if (~isnan(static_bi.resample_ratio))
      [cached_resamp.L.samples cached_resamp.L.actual_ratio cached_resamp.L.playback_sr] = ...
         resample_list(static_bi.list, static_bi.resample_ratio, common.dispStatus);
      if (~isempty(static_bi.Rlist))
         [cached_resamp.R.samples cached_resamp.R.actual_ratio cached_resamp.R.playback_sr] = ...
            resample_list(static_bi.Rlist, static_bi.resample_ratio, common.dispStatus);
      end
   end
   
   %%%%% Load rco to RP
%    switch (round(static_bi.playback_slowdown))
%    case 1
       rconame = [my_root_dir 'object\raw_samples16_100.rco'];
%    case 2
%       rconame = [my_root_dir 'object\raw_samples16_50.rco'];
%    otherwise 
%       rconame = [my_root_dir 'object\raw_samples16_100.rco'];
%       nelerror(sprintf('playback slowdown of %f is not supported', static_bi.playback_slowdown));
%    end
      
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

   short_description = 'wav';
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
if ((common.index == 1) | (length(static_bi.list) > 1))
   ind = mod(common.index-1,length(static_bi.list))+1;
   if (isnan(static_bi.resample_ratio))
      [data,sr,rc] = nel_wavread(static_bi.list{min(ind,end)});
   else
      data = cached_resamp.L.samples{min(ind,end)};
      sr   = cached_resamp.L.playback_sr(min(ind,end));
      rc = 1;
      %Bookkeeping
      stim_info.actual_resamp_ratio(1)     = cached_resamp.L.actual_ratio(min(ind,end));
   end
%    if (static_bi.playback_slowdown == round(static_bi.playback_slowdown) & ...
%          static_bi.playback_slowdown >0 & static_bi.playback_slowdown <= 5)
%       sr = sr / static_bi.playback_slowdown;
%    end
   if (rc == 0)
      nelerror(['Can''t read wavfile ''' static_bi.list{min(ind,end)} '''']);
   else
      rc = load_raw_samples_compressed(1,data,sr) & (rc==1);
   end
   if (length(static_bi.list) > 1)
      stim_info.file{1}                    = static_bi.list{min(ind,end)};
      stim_info.playback_sampling_rate(1)  = sr;
   else
      static_bi.playback_sampling_rate(1)  = sr;
   end
else
   RP(1).params = []; % Clear params to avoid sending the same old data again to the RP!
end
if (((common.index == 1) | (length(static_bi.Rlist) > 1)) & (length(static_bi.Rlist) >0))
   ind = mod(common.index-1,length(static_bi.Rlist))+1;
   if (isnan(static_bi.resample_ratio))
      [data,sr,rc] = nel_wavread(static_bi.Rlist{min(ind,end)});
   else
      data = cached_resamp.R.samples{min(ind,end)};
      sr   = cached_resamp.R.playback_sr(min(ind,end));
      rc = 1;
      %Bookkeeping
      stim_info.actual_resamp_ratio(2)     = cached_resamp.R.actual_ratio(min(ind,end));
   end
%    if (static_bi.playback_slowdown == round(static_bi.playback_slowdown) & ...
%          static_bi.playback_slowdown >0 & static_bi.playback_slowdown <= 5)
%       sr = sr / static_bi.playback_slowdown;
%    end
   if (rc == 0)
      nelerror(['Can''t read wavfile ''' static_bi.Rlist{min(ind,end)} '''']);
   else
      rc = load_raw_samples_compressed(2,data,sr) & (rc==1);
   end
   if (length(static_bi.Rlist) > 1)
      stim_info.file{2}                    = static_bi.Rlist{min(ind,end)};
      stim_info.playback_sampling_rate(2)  = sr;
   else
      static_bi.playback_sampling_rate(2)  = sr;
   end
else
   RP(2).params = []; % Clear params to avoid sending the same old data again to the RP!
end

% Set attenuations and devices
ind = mod(common.index-1,length(static_bi.attens))+1;
atten = static_bi.attens(min(ind,end));
left_dev =  atten * nel_devices_vector('RP1.1');
if (isempty(static_bi.Rlist))
   right_dev = nel_devices_vector([]);
else
   if (~isempty(static_bi.Rattens))
      ind = mod(common.index-1,length(static_bi.Rattens))+1;
      Ratten = static_bi.Rattens(min(ind,end));
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

%----------------------------------------------------------------------
function [new_samps,actual_ratio,playback_sr] = resample_list(list, resamp_ratio, dispStatus)
N = length(list);
new_samps           = cell(1,N);
playback_sr         = zeros(1,N);
actual_ratio        = ones(1,N);
for i = 1:N
   [data,sr] = nel_wavread(list{i});
   playback_sr(i) = sr;
   data = data * 10^(-1/20);
   ratio = resamp_ratio;
   if (ratio ~= 1)
      msg = sprintf('Resampling %s.',list{i});
      call_user_func(dispStatus.func,dispStatus.handle,msg);
      if (ratio < 1)
         ratio = 2*ratio;
         playback_sr(i) = playback_sr(i)*2;
      end
      actual_ratio(i) = round(sr*ratio/100)*100/(round(sr/100)*100);
      data = resample(data,round(sr*actual_ratio(i)/100)*100,round(sr/100)*100);
   end
   new_samps{i} = data;
end
