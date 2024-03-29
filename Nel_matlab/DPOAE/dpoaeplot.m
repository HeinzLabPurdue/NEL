
% Script to create gain vs freq plot for srcal

%pushbuttons switch control to test, simulate, tuning_curve and analyses functions
h_push_start    = uicontrol(h_fig,'callback','distortion_product(''start'');','style','pushbutton','Units','normalized', ...
   'position',[.625 .18 .25 .062],'string','Push to begin','Userdata',[],'fontsize',14,'fontangle','normal', ...
   'fontweight','normal');

h_push_params  = uicontrol(h_fig,'callback','distortion_product(''params'');','style','pushbutton','Units','normalized', ...
   'position',[.125 .18 .25 .062],'string','Parameters','fontsize',14,'fontangle','normal','fontweight','normal');

h_push_saveNquit  = uicontrol(h_fig,'callback','distortion_product(''saveNquit'');','style','pushbutton','Units','normalized', ...
    'position',[.41 .08 .08 .075],'string','Save','fontsize',12,'fontangle','normal','fontweight','normal', ...
    'enable','on','Visible','on');

h_push_restart  = uicontrol(h_fig,'callback','distortion_product(''restart'');','style','pushbutton','Units','normalized', ...
    'position',[.51 .16 .08 .075],'string','Restart','fontsize',12,'fontangle','normal','fontweight','normal', ...
    'enable','on','Visible','on');

h_push_abort  = uicontrol(h_fig,'callback','distortion_product(''abort'');','style','pushbutton','Units','normalized', ...
    'position',[.51 .08 .08 .075],'string','Abort','fontsize',12,'fontangle','normal','fontweight','normal', ...
    'enable','on','Visible','on');

h_push_stop = uicontrol(h_fig,'callback','distortion_product(''stop'');','style','pushbutton','Enable','off','Units','normalized', ...
   'position',[.41 .16 .08 .075],'string','Stop','Userdata',[],'fontsize',12,'fontangle','normal','fontweight','normal');

% h_push_close = uicontrol(h_fig,'callback','distortion_product(''close'');','style','pushbutton','Units','normalized', ...
%    'position',[.44 .0 .12 .075],'string','Close','fontsize',12,'fontangle','normal','fontweight','normal');


h_ax1 = axes('position',[.1 .415-0.08 .8 .56+0.08]);	%se3 axis size to accommodate dimensions of image file
h_line1 = plot(-1,-1,'-o');
set(h_line1,'color','y');
axis([0 1 0 1]);
set(h_ax1,'XTick',[]);
set(h_ax1,'YTick',[]);
box on;

h_ax2 = axes('position',[.6 .005 .3 .25]);	%set axis size to accommodate dimensions of image file
axis([0 1 0 1]);
set(h_ax2,'XTick',[]);
set(h_ax2,'YTick',[]);
box on;
filename = fliplr(strtok(fliplr(current_data_file),filesep));
h_text1 = text(-.6,2.5,{'Program:' 'Date:'},'fontsize',12,'verticalalignment','top','horizontalalignment','left');
h_text2 = text(-.0,2.5,{PROG DATE },'fontsize',12,'color',[.1 .1 .6],'verticalalignment','top','horizontalalignment','right');
h_text7 = text(.5,.35,'','fontsize',12,'fontangle','normal','fontweight','normal','color',[.8 .1 .1],'verticalalignment','middle','horizontalalignment','center');

h_ax3 = axes('position',[ .1 .005 .3 .25]);	%set axis size to accommodate dimensions of image file
axis([0 1 0 1]);
set(h_ax3,'XTick',[]);
set(h_ax3,'YTick',[]);
box on;
h_text3 = text(.1,.65,{'Low Freq:' 'High Freq:'},'fontsize',9,'verticalalignment','top','horizontalalignment','left');
h_text4 = text(.45,.65,{PARAMS(1); PARAMS(2)},'fontsize',9,'color',[.1 .1 .6],'verticalalignment','top','horizontalalignment','right');
h_text3b = text(.1,.44,{'# Steps:' ' ' 'Log Steps:'},'fontsize',9,'verticalalignment','top','horizontalalignment','left');
h_text4b = text(.45,.44,{step_txt; ' '; log_txt},'fontsize',9,'color',[.1 .1 .6],'verticalalignment','top','horizontalalignment','right');
h_text5 = text(.55,.65,{'Num Reps:' 'F2 Level:'},'fontsize',9,'verticalalignment','top','horizontalalignment','left');
h_text6 = text(.9,.65,{PARAMS(10);PARAMS(12)},'fontsize',9,'color',[.1 .1 .6],'verticalalignment','top','horizontalalignment','right');
h_text5b = text(.55,.44,{'F1 Level:' 'Ear'},'fontsize',9,'verticalalignment','top','horizontalalignment','left');
h_text6b = text(.9,.44,{PARAMS(13);ear_txt},'fontsize',9,'color',[.1 .1 .6],'verticalalignment','top','horizontalalignment','right');
