set(FIG.ax1.axes,'XLim',[Stimuli.frqlo Stimuli.frqhi]);
set(FIG.ax1.axes,'XTick',[Stimuli.frqlo Stimuli.frqhi]);
set(FIG.ax1.line1,'XData',-1,'YData',-1);
set(FIG.ax2.ProgData,'Color',[.1 .1 .6],'String',{PROG.name PROG.date NelData.General.fnum+1});
set(FIG.ax3.ParamData1,'Color',[.6 .1 .1],'string', {Stimuli.nmic});
set(FIG.ax3.ParamData2,'Color',[.1 .1 .6],'string', {Stimuli.frqlo; Stimuli.frqhi; Stimuli.frqcal; Stimuli.attencal});
