function rate_params = default_plot_rate_params(line_dur, stim_dur)
%

% AF 10/9/01

if (exist('line_dur','var') ~= 1)
   line_dur = 1;
end
if (exist('stim_dur','var') ~= 1)
   stim_dur = 0.5;
end

rate_params.func = 'default_plot_rate';
rate_params.line_dur = line_dur;
rate_params.stim_dur = stim_dur;
rate_params.props.axes = struct( ...
   'Tag',         'rate' ...
   ,'Box',        'on' ...
   ,'Color',      'k' ...
   ,'Xdir',       'reverse' ...
   ,'XLim',       [0 50] ...
   ,'XTick',      [0 50 100:100:1000] ...
   );

rate_params.props.driven = struct( ...
   'Tag',         'driven' ...
   ,'LineStyle',  '-' ...
   ,'LineWidth',  2 ...
   ,'Marker',     'none' ...
   ,'Color',      'r' ...
   ,'EraseMode',  'back' ...
   );
rate_params.props.spont = struct( ...
   'Tag',         'spont' ...
   ,'LineStyle',   '-' ...
   ,'LineWidth',  1 ...
   ,'Marker',     'none' ...
   ,'Color',      'g' ...
   ,'EraseMode',  'back' ...
   );
rate_params.props.xlabel = struct( ...
   'fontsize',   14 ...
   );
rate_params.props.ylabel = struct( ...
   'fontsize',   14 ...
   );

