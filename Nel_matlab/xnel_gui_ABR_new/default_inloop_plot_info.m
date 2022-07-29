function plot_info = default_inloop_plot_info
%

% AF 10/9/01

plot_info.var_name = 'Stimulus number';
plot_info.var_unit = '';
plot_info.var_frmt = '%d';
plot_info.var_vals = 1:100;
plot_info.XYprops.Lim  = [0 101];
plot_info.XYprops.Dir  = 'normal';
plot_info.XYprops.Scale  = 'linear';
plot_info.XYprops.Tick = [0:10:120];
