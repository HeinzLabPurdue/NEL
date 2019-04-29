function rate_params = plot_rate_contstim(index,rate_params,plot_info,nCh)
%

% AF 10/10/01
% SMC 7/13/04:  Redid for plotting continuous stimuli, where the period and duration are the same.  
%               Just commented out anything having to do with spont.
global spikes

% To speed the plot process we don't check rate_params
if (index > 0)
   indices = max(1,index-1):index;  % recalculate the last index in case we missed spikes
   for i = 1:length(spikes.times)
      for index = indices
         
         %% GE/MH 06Nov2003.  This "find" line in particular causes conflict problems with the NI6052 board.
         %%    Don't know exactly why, but we suspend activity while the trigger is high (see
         %%    'data_acquisition_loop_NI'.
         ind = find(spikes.times{i}(1:spikes.last(1),1) == index);
         
         driven = length(find(spikes.times{i}(ind,2) <= rate_params.stim_dur));
         %          spont  = length(ind) - driven;
         xd = get(rate_params.cache(i).hdriven,'Ydata');
         yd = get(rate_params.cache(i).hdriven,'Xdata');
         %          xs = get(rate_params.cache(i).hspont,'Ydata');
         %          ys = get(rate_params.cache(i).hspont,'Xdata');
         
         yd(rate_params.plot_order(index)) = driven / rate_params.stim_dur;
         %          ys(rate_params.plot_order(index)) = spont / (rate_params.line_dur-rate_params.stim_dur);
         % fprintf('index=%d, driven=%d\n', index, driven);
      end
      curr_maxy = max(get(rate_params.cache(i).haxes,'XLim'));
      %       maxy = max([max(yd) max(ys)]);
      maxy=max(yd);
      if (maxy > 0.9*curr_maxy)
         set(rate_params.cache(i).haxes,'XLim',[0 maxy/0.9]);
         if (maxy/0.9 > 150)
            set(rate_params.cache(i).haxes,'XTick', [0:100:1000]);
         end
      end
      % fprintf('%f %f\n', [xd ;yd]);
      set(rate_params.cache(i).hdriven,'Ydata',xd,'Xdata',yd);
      %       set(rate_params.cache(i).hspont ,'Ydata',xs,'Xdata',ys);
   end
   drawnow;
   return;
end

% No spikes to plot. Create axes if necessary and set properties.
if ((exist('plot_info','var') ~= 1))
   plot_info = [];
end
if ((exist('rate_params','var') ~= 1))
   rate_params = [];
end
if ((exist('nCh','var') ~= 1))
   nCh = 1;
end

spikes_fig(nCh);
[dummy rate_params] = spikes_fig('reset_axes',[],rate_params,plot_info);
