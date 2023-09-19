%pushbuttons switch control to test, simulate, calibrate and analyses functions
FIG.push.calib   = uicontrol(FIG.handle,'callback','QuickCal(''calibrate'');','style','pushbutton','Units','normalized','position',[.44 .22 .12 .05],'string','Calibration','fontsize',12);
FIG.push.recall  = uicontrol(FIG.handle,'callback','QuickCal(''recall'');',   'style','pushbutton','Units','normalized','position',[.44 .16 .12 .05],'string','Recall','fontsize',12);
FIG.push.stop    = uicontrol(FIG.handle,'callback','QuickCal(''stop'');',     'style','pushbutton','Units','normalized','position',[.44 .1 .12 .05],'string','Stop','fontsize',12,'Enable','off');

FIG.ax1.axes = axes('position',[.1 .4 .8 .5]);	%se3 axis size to accommodate dimensions of image file
FIG.ax1.line1 = semilogx(0,0);
set(FIG.ax1.line1,'Color',[.1 .1 .6],'LineWidth',2,'EraseMode','back');
axis([Stimuli.frqlo Stimuli.frqhi 100 120]);
set(FIG.ax1.axes,'XTick',[Stimuli.frqlo Stimuli.frqhi],'FontSize',12);         %note x-axis label bug for log scale in MatLab
set(FIG.ax1.axes,'YTick',[-200:20:200],'FontSize',12);
FIG.ax1.ord_text = ylabel('Gain (dB SPL)','fontsize',18,'fontangle','normal','fontweight','normal');	%label y axis

FIG.ax2.axes = axes('position',[.6 .06 .3 .27]);	%set axis size to accommodate dimensions of image file
axis([0 1 0 1]);
set(FIG.ax2.axes,'XTick',[]);
set(FIG.ax2.axes,'YTick',[]);
box on;
text(.5,.85,'Status','fontsize',18,'verticalalignment','top','horizontalalignment','center');
FIG.ax2.ProgHead = text(.45,3.45,{'Program:' 'Date:' 'Pic#:'},'fontsize',12,'verticalalignment','top','horizontalalignment','left');
FIG.ax2.ProgData = text( 1,3.45,{PROG.name PROG.date NelData.General.fnum+1},'fontsize',12,'color',[.1 .1 .6],'verticalalignment','top','horizontalalignment','right');
FIG.ax2.ProgMess = text(.5,.5,'Push calibration button to begin...','fontsize',12,'fontangle','normal','fontweight','normal','color',[.6 .1 .1],'verticalalignment','middle','horizontalalignment','center','EraseMode','back');
text(-.34,1.14,'Frequency (kHz)','fontsize',18,'fontangle','normal','fontweight','normal','Horiz','center');

FIG.ax3.axes = axes('position',[ .1 .06 .3 .27]);	%set axis size to accommodate dimensions of image file
axis([0 1 0 1]);
set(FIG.ax3.axes,'XTick',[]);
set(FIG.ax3.axes,'YTick',[]);
box on;
text(.5,.85,'Parameters','fontsize',18,'verticalalignment','top','horizontalalignment','center');
text(.2,.65,{'Microphone Number:'},'fontsize',9,'verticalalignment','top','horizontalalignment','left');
FIG.ax3.ParamData1 = text(.8,.65,{Stimuli.nmic},'fontsize',9,'color',[.6 .1 .1],'verticalalignment','top','horizontalalignment','right','buttondownfcn','QuickCal(''mic'');');
text(.2,.45,{'Low Frequency:' 'High Frequency:' 'Reference Frequency:' 'Attenuation:'},'fontsize',9,'verticalalignment','top','horizontalalignment','left');
FIG.ax3.ParamData2 = text(.8,.45,{Stimuli.frqlo; Stimuli.frqhi; Stimuli.frqcal; Stimuli.attencal},'fontsize',9,'color',[.1 .1 .6],'verticalalignment','top','horizontalalignment','right','buttondownfcn','QuickCal(''params'');');

set(FIG.handle,'Userdata',struct('handles',FIG));    
