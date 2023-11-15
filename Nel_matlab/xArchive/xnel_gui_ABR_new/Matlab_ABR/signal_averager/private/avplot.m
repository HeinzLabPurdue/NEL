% Script to create gain vs freq plot for signal averager

%pushbuttons switch control to test, simulate, calibrate and analyses functions
FIG.push.stop   = uicontrol(FIG.handle,'callback','signal_averager(''stop'');','style','pushbutton','Enable','off','Units','normalized','position',[.44 .23 .125 .075],'string','Stop','Userdata',[],'fontsize',12,'fontangle','normal','fontweight','normal');
FIG.push.print  = uicontrol(FIG.handle,'callback','signal_averager(''print'');','style','pushbutton','Units','normalized','position',[.44 .05 .125 .075],'string','Print','Userdata',[],'fontsize',12,'fontangle','normal','fontweight','normal');
FIG.push.aver   = uicontrol(FIG.handle,'callback','signal_averager(''average'');','style','pushbutton','Interruptible','on','Units','normalized','position',[.625 .238 .25 .062],'string','Average','Userdata',[],'fontsize',14,'fontangle','normal','fontweight','normal');
FIG.push.params = uicontrol(FIG.handle,'callback','signal_averager(''params'');','style','pushbutton','Units','normalized','position',[.125 .238 .25 .062],'string','Parameters','fontsize',14,'fontangle','normal','fontweight','normal');
FIG.push.recall = uicontrol(FIG.handle,'callback','signal_averager(''recall'');','style','pushbutton','Units','normalized','position',[.44 .14 .125 .075],'string','Recall','fontsize',12,'fontangle','normal','fontweight','normal');
FIG.push.edit   = uicontrol(FIG.handle,'style','edit','Units','normalized','position',[.265 .08 .1 .04],'string',[],'FontSize',12);								

FIG.ax1.axes = axes('position',[.1 .4 .8 .5]);
FIG.ax1.line1 = plot(0,0);
set(FIG.ax1.line1,'Color',[.1 .1 .6],'LineWidth',2,'EraseMode','xor');
axis([0 Stimuli.record_duration -3.5 3.5]);
set(FIG.ax1.axes,'XTick',[0:5:100],'FontSize',12);
set(FIG.ax1.axes,'YTick',[-3.5 0 3.5],'FontSize',12);
ylabel('Amplitude (\muVolts)','fontsize',18,'fontangle','normal','fontweight','normal','Interpreter','tex');	%label y axis

FIG.ax2.axes = axes('position',[.6 .048 .3 .27]);
axis([0 1 0 1]);
set(FIG.ax2.axes,'XTick',[]);
set(FIG.ax2.axes,'YTick',[]);
box on;

fnum = NelData.General.fnum +1;
FIG.ax2.ProgHead = text(.45,3.5,{'Program:' 'Date:' 'Pic#:'},'fontsize',12,'verticalalignment','top','horizontalalignment','left');
FIG.ax2.ProgData = text(1,3.5,{PROG.name PROG.date fnum},'fontsize',12,'color',[.1 .1 .6],'verticalalignment','top','horizontalalignment','right');
FIG.ax2.ProgMess = text(.5,.5,'Push to begin averaging...','fontsize',12,'fontangle','normal','fontweight','normal','color',[.6 .1 .1],'verticalalignment','middle','horizontalalignment','center','EraseMode','normal');
text(-.34,1.14,'Time (msec)','fontsize',18,'fontangle','normal','fontweight','normal','Horiz','center');
FIG.ax3.axes = axes('position',[ .1 .048 .3 .27]);
axis([0 1 0 1]);
set(FIG.ax3.axes,'XTick',[]);
set(FIG.ax3.axes,'YTick',[]);
box on;

if Stimuli.freq_hz == 0,
    stim_txt = 'click';
else
    stim_txt = num2str(Stimuli.freq_hz);
end

FIG.ax3.ParamHead1 = text(.1,.65,'Basic','fontsize',12,'fontweight','bold','verticalalignment','top','horizontalalignment','left');
FIG.ax3.ParamHead2 = text(.55,.65,'Test','fontsize',12,'fontweight','bold','verticalalignment','top','horizontalalignment','left');
FIG.ax3.ParamHead3 = text(.1,.55,{'PlayTime (ms):' 'Rise/Fall (ms):' 'Pulses/s:' 'RecTime (ms)' 'Averages:' 'Amp gain:'},'fontsize',9,'verticalalignment','top','horizontalalignment','left');
FIG.ax3.ParamData1 = text(.45,.55,{Stimuli.play_duration; Stimuli.rise_fall; Stimuli.pulses_per_sec; Stimuli.record_duration; Stimuli.naves; Stimuli.amp_gain},'fontsize',9,'color',[.1 .1 .6],'verticalalignment','top','horizontalalignment','right');
FIG.ax3.ParamHead4 = text(.55,.55,{'Freq (Hz):' 'Atten (dB)'},'fontsize',9,'verticalalignment','top','horizontalalignment','left');
FIG.ax3.ParamData2 = text(.9,.55,{stim_txt},'fontsize',9,'color',[.6 .1 .1],'verticalalignment','top','horizontalalignment','right','buttondownfcn','signal_averager(''stimulus'');');
FIG.ax3.ParamData3 = text(.9,.47,{Stimuli.db_atten},'fontsize',9,'color',[.6 .1 .1],'verticalalignment','top','horizontalalignment','right','buttondownfcn','signal_averager(''attenuation'');');

set(FIG.handle,'Userdata',struct('handles',FIG));