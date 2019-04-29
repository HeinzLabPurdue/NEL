function RM_inloop_status(h,msg,plot_info)
%

% copied from 'default_inloop_status' and modified by GE.  07Apr2003.


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
set(h,'String',str);
drawnow;