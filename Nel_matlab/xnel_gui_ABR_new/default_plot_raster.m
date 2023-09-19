function raster_params = default_plot_raster(spk,raster_params,plot_info,nCh,refresh_channels)
%

% AF 10/3/01

% To speed the plot process we don't check raster_params
if (~isempty(spk))
   for i = 1:length(spk)
      if (~isempty(spk{i}))
         set(raster_params.cache(i).hraster,'xdata',spk{i}(:,2),'ydata',raster_params.var_vals(spk{i}(:,1)));
      end
   end
   return;
end

global saved_raster_params

% MGH 7/22/02: Needed to add this for plotting extra stimuli if any repeats
if(isfield(raster_params,'var_vals'))
   saved_raster_params.var_vals = raster_params.var_vals;
end

% the figure can ask for a complete refresh of a channel (e.g. for resize)
if (exist('refresh_channels','var') == 1)
   global spikes
   for ch = refresh_channels(:)'
      last_spike = spikes.last(ch);
      set(saved_raster_params.cache(ch).hraster,'xdata',spikes.times{ch}(1:last_spike,2), ...
         'ydata',saved_raster_params.var_vals(spikes.times{ch}(1:last_spike,1)));
   end
   return
end

% No spikes to plot. Create axes if necessary and set properties.
if ((exist('plot_info','var') ~= 1))
   plot_info = [];
end
if ((exist('raster_params','var') ~= 1))
   raster_params.func = mfilename;
end
if ((exist('nCh','var') ~= 1))
   nCh = 1;
end

spikes_fig(nCh);  %% Not needed to get spikes back
raster_params = spikes_fig('reset_axes',raster_params,[],plot_info);
saved_raster_params = raster_params;
