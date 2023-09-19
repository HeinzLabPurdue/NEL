function default_plot_EP(i_ep, aveX, aveY, currX, currY)
%

% GE 27Feb2002
% will need to implement channel number i_ep...


global NelData ep_fig_handles
persistent fig_handles;

if (nargin == 1) % open figure (or bring to front) and initialize
    
    newFig = EP_fig(i_ep);
    fig_handles{i_ep} = guiData(ep_fig_handles{i_ep});

    axes(fig_handles{i_ep}.currPlot);
    delete(findobj(fig_handles{i_ep}.currPlot,'Type','line'));
    fig_handles{i_ep}.currPlotLine = line(NaN,NaN);
    set(fig_handles{i_ep}.currPlotLine, 'Color', 'g');
    
    axes(fig_handles{i_ep}.avePlot);
    delete(findobj(fig_handles{i_ep}.avePlot,'Type','line'));
    fig_handles{i_ep}.avePlotLine = line(NaN,NaN);
    set(fig_handles{i_ep}.avePlotLine, 'Color', 'y');
      
else   % update figure

    set(fig_handles{i_ep}.avePlotLine, 'XData', aveX, 'YData', aveY);
    set(fig_handles{i_ep}.currPlotLine, 'XData', currX, 'YData', currY);
    figure(fig_handles{i_ep}.EPfig);
  
end