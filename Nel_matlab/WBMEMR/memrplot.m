%script to make WBMEMR mini-GUI

h_push_saveNquit  = uicontrol(h_fig,'callback','wideband_memr(''saveNquit'');','style','pushbutton','Units','normalized', ...
    'position',[.15 .15 .25 .25],'string','Save N Quit','fontsize',12,'fontangle','normal','fontweight','normal', ...
    'enable','on','Visible','on');

h_push_stop = uicontrol(h_fig,'callback','wideband_memr(''stop'');','style','pushbutton','Enable','off','Units','normalized', ...
   'position',[.15 .65 .25 .25],'string','Stop','Userdata',[],'fontsize',12,'fontangle','normal','fontweight','normal');

h_push_abort  = uicontrol(h_fig,'callback','wideband_memr(''abort'');','style','pushbutton','Units','normalized', ...
    'position',[.65 .15 .25 .25],'string','Abort','fontsize',12,'fontangle','normal','fontweight','normal', ...
    'enable','on','Visible','on');

h_push_restart  = uicontrol(h_fig,'callback','wideband_memr(''restart'');','style','pushbutton','Units','normalized', ...
    'position',[.65 .65 .25 .25],'string','Restart','fontsize',12,'fontangle','normal','fontweight','normal', ...
    'enable','on','Visible','on');



