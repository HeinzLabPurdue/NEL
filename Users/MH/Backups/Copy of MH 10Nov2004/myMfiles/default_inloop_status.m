function default_inloop_status(h,msg,plot_info)
%

% AF 10/10/01
global NumDrivenSpikes % MH 29Jun2004

str = '';
if (isnumeric(msg))
   % msg is the line number
   frmt = ['%s: ' plot_info.var_frmt '%s'];
   if (isfield(plot_info,'var_labels'))
      str = sprintf(frmt, plot_info.var_name, plot_info.var_labels{msg}, plot_info.var_unit);
   else
      str = sprintf(frmt, plot_info.var_name, plot_info.var_vals(msg), plot_info.var_unit);
   end
elseif (isstr(msg))
   str = msg;
end

str=sprintf('%s\nNumber of Driven Spikes: %d',str,NumDrivenSpikes); % MH: 29Jun2004

set(h,'String',str);
drawnow;