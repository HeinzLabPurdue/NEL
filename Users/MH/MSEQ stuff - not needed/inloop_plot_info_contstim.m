function plot_info = inloop_plot_info_contstim(nlines)
%

% SMC 7/13/04

plot_info.var_name = 'Repetition';
plot_info.var_unit = '';
plot_info.var_frmt = '%d';
plot_info.var_vals = 1:nlines;
plot_info.XYprops.Lim  = [0 nlines+1];
plot_info.XYprops.Dir  = 'normal';
plot_info.XYprops.Scale  = 'linear';
plot_info.XYprops.Tick = [0:20:nlines];
