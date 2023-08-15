function FIG = FPLinv_plot(FIG, Stimuli, textStruct)
%pushbuttons switch control to test, simulate, calibrate and analyses functions
FIG.push.stop = uicontrol(FIG.handle,'callback','FPLinv(''stop'');',...
    'style','pushbutton','Enable','off','Units','normalized','position',[.44 .23 .12 .075],...
    'string','Stop','Userdata',[],'fontsize',12,'fontangle','normal','fontweight','normal');
FIG.push.close = uicontrol(FIG.handle,'callback','FPLinv(''close'');',...
    'style','pushbutton','Units','normalized','position',[.44 .05 .12 .075],'string','Close',...
    'Userdata',[],'fontsize',12,'fontangle','normal','fontweight','normal');
FIG.push.calib = uicontrol(FIG.handle,'callback','FPLinv(''calibrate'');',...
    'style','pushbutton','Interruptible','on','Units','normalized','position',[.625 .238 .25 .062],...
    'string','Calibration','fontsize',14,'fontangle','normal','fontweight','normal');
FIG.push.params = uicontrol(FIG.handle,'callback','view_params;','style','pushbutton',...
    'Units','normalized','position',[.125 .238 .25 .062],'string','Parameters',...
    'fontsize',14,'fontangle','normal','fontweight','normal');
FIG.push.recall = uicontrol(FIG.handle,'callback','FPLinv(''recall'');',...
    'style','pushbutton','Units','normalized','position',[.44 .14 .12 .075],...
    'string','Recall','fontsize',12,'fontangle','normal','fontweight','normal');

FIG.ax1.axes = axes('position',[.1 .42 .8 .56]);

%plotting!
FIG.ax1.line1 = semilogx(0.1,0);
set(FIG.ax1.line1,'Color',[52, 119, 235]/255,'LineWidth',2,'visible','on');

axis([Stimuli.frqlo Stimuli.frqhi 100 120]);
set(FIG.ax1.axes, 'XTick', ...
   unique(min(Stimuli.frqhi,max(Stimuli.frqlo, [Stimuli.frqlo++.000001 0.1 0.2 0.4 1 2 4 7 10 15 20:10:50 100 Stimuli.frqhi]))));
set(FIG.ax1.axes, 'XMinorTick', 'off');
set(FIG.ax1.axes,'YTick',-200:20:200,'FontSize',11);
if Stimuli.cal
   FIG.ax1.ord_text = ylabel('Gain (dB SPL)','fontsize',12,'fontangle','normal','fontweight','bold');	%label y axis
else
   FIG.ax1.ord_text = ylabel('RMS volts, dB re 1V','fontsize',12,'fontangle','normal','fontweight','bold');	%label y axis
   set(FIG.ax1.axes,'YLim',[-40 -20]);
end
hold on;
FIG.ax1.line2 = semilogx(0.1,0);
set(FIG.ax1.line2,'Color',[191, 60, 36]/255,'LineWidth',2,'visible','on');

FIG.ax2.axes = axes('position',[.6 .005 .3 .32]);	%set axis size to accommodate dimensions of image file
axis([0 1 0 1]);
set(FIG.ax2.axes,'XTick',[]);
set(FIG.ax2.axes,'YTick',[]);
box on;
FIG.ax2.ProgMess = text(.5,.5,sprintf('Push calibration button to begin...\n\nNEW CALIB'),...
    'fontsize',12,'fontangle','normal','fontweight','normal', 'color',[.6 .1 .1],...
    'verticalalignment','middle','horizontalalignment','center');
text(-.34,1.12,'Frequency (kHz)','fontsize',18,'fontangle','normal','fontweight','normal','Horiz','center');

FIG.ax3.axes = axes('position',[ .1 .005 .3 .32]);	%set axis size to accommodate dimensions of image file
data1 = [-1000 1000];
data2 = [0 0];
FIG.ax3.line1 = plot(0,0,'o');
set(FIG.ax3.line1,'Color',[.1 .1 .6],'Visible','off');
hold on;
FIG.ax3.line2 = plot(data1,data2,':');
set(FIG.ax3.line2,'Color',[.8 .8 .8],'Visible','off');
FIG.ax3.line3 = plot(data2,data1,':');
set(FIG.ax3.line3,'Color',[.8 .8 .8],'Visible','off');
axis([0 1 0 1]);
set(FIG.ax3.axes,'XTick',[]);
set(FIG.ax3.axes,'YTick',[]);
box on;

FIG.ax3.ParamHead1 = text(.1,.7,{'Low Freq:' 'High Freq:' 'Log Steps:' 'Step Size:' 'Low BP:' 'High BP:' 'Low Notch60:' 'High Notch60:'},...
    'fontsize',9,'verticalalignment','top','horizontalalignment','left');
FIG.ax3.ParamData1 = text(.45,.7,{Stimuli.frqlo; Stimuli.frqhi; textStruct.log; textStruct.step; Stimuli.bplo; Stimuli.bphi; Stimuli.n60lo; Stimuli.n60hi},...
    'fontsize',9,'color',[.1 .1 .6],'verticalalignment','top','horizontalalignment','right');
FIG.ax3.ParamHead2 = text(.55,.7,{'Low Notch120:' 'High Notch120:' 'Channel:' 'Base Atten:' 'Slope:' 'Corner Freq:' 'Plot SPL:' 'Mic:'},...
    'fontsize',9,'verticalalignment','top','horizontalalignment','left');
FIG.ax3.ParamData2 = text(.9,.7,{Stimuli.n120lo; Stimuli.n120hi; textStruct.chan; Stimuli.syslv; Stimuli.lvslp; Stimuli.frqcnr; textStruct.spl; Stimuli.nmic},...
    'fontsize',9,'color',[.1 .1 .6],'verticalalignment','top','horizontalalignment','right');
FIG.ax3.abs_text = xlabel('X value (mV)','fontsize',12,'fontweight','bold','verticalalignment','top','horizontalalignment','center','Visible','off');
FIG.ax3.ord_text = ylabel('Y value (mV)','fontsize',12,'fontweight','bold','verticalalignment','bottom','horizontalalignment','center','Visible','off');

set(FIG.handle,'Userdata',struct('handles',FIG));