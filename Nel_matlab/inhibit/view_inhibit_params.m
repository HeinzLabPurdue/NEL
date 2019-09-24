function h_fig = view_inhibit_params(command_str,stim_num)		%function to create graphic interface for setting behavior paramsglobal PARAMSh_fig = findobj('Tag','View_inhibit_Params_fig');if nargin < 1										%call from sens.m doesn't have input arguments so set command stsring to initialize    command_str = 'initialize';    stim_num = 0;    txt_num = 0;endif ~strcmp(command_str,'initialize')		%entering the program via callback (command_str is not initialize) so retrieve figure handles    handles        = get(gcf,'userdata');		%	that were created during previous initialization	    h_push_defs   = handles(1);    h_push_update  = handles(2);    h_push_close   = handles(3);    h_push_left    = handles(4);    h_push_right   = handles(5);    h_push_both    = handles(6);    param_name_txt = handles(7:36);    parm_txt       = handles(37:66);    h_edit         = handles(67);    h_push_tuning = handles(68);    h_push_growth = handles(69);    h_push_adapt = handles(70);    h_push_fmask = handles(71);    h_push_smask = handles(72);    h_push_recover = handles(73);endif strcmp(command_str,'initialize')				%the following code generates the image and throws ups pop menus with current params    if (ishandle(h_fig))        delete(h_fig);    end    h_fig = figure('NumberTitle','off','Name','Parameters','Units','pixels', ...        'Tag','View_inhibit_Params_fig', 'position',[100 100 800 560]); %open window for the TDT GUI    h_ax = axes('Position',[0 0 1 1]);	%set up axes equal in size to the jpeg    axis('off');        text(.3,.80,'Parameter','fontsize',16,'color','k','horizontalalignment','center','VerticalAlignment','middle',);    text(.5,.80,'Value','fontsize',16,'color','k','horizontalalignment','center','VerticalAlignment','middle',);    text(.7,.75,'Input','fontsize',16,'color','k','horizontalalignment','center','VerticalAlignment','middle',);    text(.6,.33,'Growth Function Parameter','fontsize',16,'color','k','horizontalalignment','left','VerticalAlignment','middle',);            param_name_txt(1) = text(.37,.75,'Low Freq (kHz):','fontsize',12,'horizontalalignment','right','VerticalAlignment','middle',);    param_name_txt(2) = text(.37,.72,'High Freq (kHz):','fontsize',12,'horizontalalignment','right','VerticalAlignment','middle',);    param_name_txt(3) = text(.37,.69,'# Steps (log&lin: #/oct; Q: # in BW10):','fontsize',12,'horizontalalignment','right','VerticalAlignment','middle',);    param_name_txt(4) = text(.37,.66,'Log Step (yes,no,Q):','fontsize',12,'horizontalalignment','right','VerticalAlignment','middle',);    param_name_txt(5) = text(.37,.61,'Low Atten (dB):','fontsize',12,'horizontalalignment','right','VerticalAlignment','middle',);    param_name_txt(6) = text(.37,.58,'High Atten (dB):','fontsize',12,'horizontalalignment','right','VerticalAlignment','middle',);    param_name_txt(7) = text(.37,.55,'Atten Step (dB):','fontsize',12,'horizontalalignment','right','VerticalAlignment','middle',);    param_name_txt(8) = text(.37,.50,'Match(1 or 2):','fontsize',12,'horizontalalignment','right','VerticalAlignment','middle',);    param_name_txt(9) = text(.37,.47,'Criterion(Sp/s):','fontsize',12,'horizontalalignment','right','VerticalAlignment','middle',);    param_name_txt(10) = text(.1,.1,'','visible','off');%dummy    param_name_txt(11) = text(.37,.42,'Tone On (msec):','fontsize',12,'horizontalalignment','right','VerticalAlignment','middle',);    param_name_txt(12) = text(.37,.39,'Tone Off (msec):','fontsize',12,'horizontalalignment','right','VerticalAlignment','middle',);    param_name_txt(13) = text(.37,.34,'Resp Window (msec):','fontsize',12,'horizontalalignment','right','VerticalAlignment','middle',);    param_name_txt(14) = text(.1,.1,'','visible','off');%dummy    param_name_txt(15) = text(.37,.31,'Fixed tone Atten (dB):','fontsize',12,'horizontalalignment','right','VerticalAlignment','middle',);    param_name_txt(16) = text(.37,.28,'Fixed tone Freq (kHz):','fontsize',12,'horizontalalignment','right','VerticalAlignment','middle',);    param_name_txt(17) = text(.1,.1,'','visible','off');%dummy    param_name_txt(18) = text(.6,.27,'Min Growth Freq (kHz):','fontsize',12,'horizontalalignment','left','VerticalAlignment','middle',);    param_name_txt(19) = text(.6,.23,'Max Growth Freq (kHz):','fontsize',12,'horizontalalignment','left','VerticalAlignment','middle',);    param_name_txt(20) = text(.6,.19,'Growth Freq Step (Oct):','fontsize',12,'horizontalalignment','left','VerticalAlignment','middle',);    param_name_txt(21) = text(.6,.15,'Growth Freq (kHz):','fontsize',12,'horizontalalignment','left','VerticalAlignment','middle',);    param_name_txt(22) = text(.6,.11,'Growth Atten Start (dB):','fontsize',12,'horizontalalignment','left','VerticalAlignment','middle',);    param_name_txt(23) = text(.6,.07,'Growth Atten Step (dB):','fontsize',12,'horizontalalignment','left','VerticalAlignment','middle',);    param_name_txt(24) = text(.6,.03,'Growth Criterion (Sp/s):','fontsize',12,'horizontalalignment','left','VerticalAlignment','middle',);         param_name_txt(25) = text(.37,.23,'Fixed Masker Freq (kHz):','fontsize',12,'horizontalalignment','right','VerticalAlignment','middle',);    param_name_txt(26) = text(.37,.20,'Fixed Masker Lev (dBSPL):','fontsize',12,'horizontalalignment','right','VerticalAlignment','middle',);    param_name_txt(27) = text(.37,.17,'Calibration Pic #:','fontsize',12,'horizontalalignment','right','VerticalAlignment','middle',);    param_name_txt(28) = text(.37,.12,'min Delta t (msec):','fontsize',12,'horizontalalignment','right','VerticalAlignment','middle',);    param_name_txt(29) = text(.37,.09,'max Delta t (msec):','fontsize',12,'horizontalalignment','right','VerticalAlignment','middle',);    param_name_txt(30) = text(.37,.06,'Delta t step (Oct):','fontsize',12,'horizontalalignment','right','VerticalAlignment','middle',);            if PARAMS(4) == 0,        log_txt = 'no';    elseif PARAMS(4) > 0,       log_txt = 'yes';    else       log_txt = 'Q';    end           parm_txt(1)  = text(.535,.75,num2str(PARAMS(1)), 'fontsize',12,'color',[.1 .1 .6],'horizontalalignment','right','VerticalAlignment','middle','buttondownfcn','view_inhibit_params(''stimulus'',1);');    parm_txt(2)  = text(.535,.72,num2str(PARAMS(2)), 'fontsize',12,'color',[.1 .1 .6],'horizontalalignment','right','VerticalAlignment','middle','buttondownfcn','view_inhibit_params(''stimulus'',2);');    parm_txt(3)  = text(.535,.69,num2str(max(PARAMS(3),abs(PARAMS(4)))),'fontsize',12,'color',[.1 .1 .6],'horizontalalignment','right','VerticalAlignment','middle','buttondownfcn','view_inhibit_params(''stimulus'',3);');    parm_txt(4)  = text(.535,.66,log_txt,'fontsize',12,'color',[.1 .1 .6],'horizontalalignment','right','VerticalAlignment','middle','buttondownfcn','view_inhibit_params(''stimulus'',4);');    parm_txt(5)  = text(.535,.61,num2str(PARAMS(5)), 'fontsize',12,'color',[.1 .1 .6],'horizontalalignment','right','VerticalAlignment','middle','buttondownfcn','view_inhibit_params(''stimulus'',5);');    parm_txt(6)  = text(.535,.58,num2str(PARAMS(6)), 'fontsize',12,'color',[.1 .1 .6],'horizontalalignment','right','VerticalAlignment','middle','buttondownfcn','view_inhibit_params(''stimulus'',6);');    parm_txt(7)  = text(.535,.55,num2str(PARAMS(7)), 'fontsize',12,'color',[.1 .1 .6],'horizontalalignment','right','VerticalAlignment','middle','buttondownfcn','view_inhibit_params(''stimulus'',7);');    parm_txt(8)  = text(.535,.50,num2str(PARAMS(8)), 'fontsize',12,'color',[.1 .1 .6],'horizontalalignment','right','VerticalAlignment','middle','buttondownfcn','view_inhibit_params(''stimulus'',8);');    parm_txt(9)  = text(.535,.47,num2str(PARAMS(9)), 'fontsize',12,'color',[.1 .1 .6],'horizontalalignment','right','VerticalAlignment','middle','buttondownfcn','view_inhibit_params(''stimulus'',9);');    parm_txt(10)  = text(.535,.42,num2str(PARAMS(10)), 'visible','off');    parm_txt(11)  = text(.535,.42,num2str(PARAMS(11)), 'fontsize',12,'color',[.1 .1 .6],'horizontalalignment','right','VerticalAlignment','middle','buttondownfcn','view_inhibit_params(''stimulus'',11);');    parm_txt(12)  = text(.535,.39,num2str(PARAMS(12)), 'fontsize',12,'color',[.1 .1 .6],'horizontalalignment','right','VerticalAlignment','middle','buttondownfcn','view_inhibit_params(''stimulus'',12);');    parm_txt(13)  = text(.435,.34,num2str(PARAMS(13)), 'fontsize',12,'color',[.1 .1 .6],'horizontalalignment','right','VerticalAlignment','middle','buttondownfcn','view_inhibit_params(''stimulus'',13);');    parm_txt(14)  = text(.535,.34,num2str(PARAMS(14)), 'fontsize',12,'color',[.1 .1 .6],'horizontalalignment','right','VerticalAlignment','middle','buttondownfcn','view_inhibit_params(''stimulus'',14);');    parm_txt(15)  = text(.535,.31,num2str(PARAMS(15)), 'fontsize',12,'color',[.1 .1 .6],'horizontalalignment','right','VerticalAlignment','middle','buttondownfcn','view_inhibit_params(''stimulus'',15);');    parm_txt(16)  = text(.535,.28,num2str(PARAMS(16)), 'fontsize',12,'color',[.1 .1 .6],'horizontalalignment','right','VerticalAlignment','middle','buttondownfcn','view_inhibit_params(''stimulus'',16);');    parm_txt(17)  = text(.535,.28,num2str(PARAMS(17)), 'visible','off');    parm_txt(18)  = text(.9,.27,num2str(PARAMS(18)), 'fontsize',12,'color',[.1 .1 .6],'horizontalalignment','right','VerticalAlignment','middle','buttondownfcn','view_inhibit_params(''stimulus'',18);');    parm_txt(19)  = text(.9,.23,num2str(PARAMS(19)), 'fontsize',12,'color',[.1 .1 .6],'horizontalalignment','right','VerticalAlignment','middle','buttondownfcn','view_inhibit_params(''stimulus'',19);');    parm_txt(20)  = text(.9,.19,num2str(PARAMS(20)), 'fontsize',12,'color',[.1 .1 .6],'horizontalalignment','right','VerticalAlignment','middle','buttondownfcn','view_inhibit_params(''stimulus'',20);');    parm_txt(21)  = text(.9,.15,num2str(PARAMS(21)), 'fontsize',12,'color',[.1 .1 .6],'horizontalalignment','right','VerticalAlignment','middle','buttondownfcn','view_inhibit_params(''stimulus'',21);');    parm_txt(22)  = text(.9,.11,num2str(PARAMS(22)), 'fontsize',12,'color',[.1 .1 .6],'horizontalalignment','right','VerticalAlignment','middle','buttondownfcn','view_inhibit_params(''stimulus'',22);');    parm_txt(23)  = text(.9,.07,num2str(PARAMS(23)), 'fontsize',12,'color',[.1 .1 .6],'horizontalalignment','right','VerticalAlignment','middle','buttondownfcn','view_inhibit_params(''stimulus'',23);');    parm_txt(24)  = text(.9,.03,num2str(PARAMS(24)), 'fontsize',12,'color',[.1 .1 .6],'horizontalalignment','right','VerticalAlignment','middle','buttondownfcn','view_inhibit_params(''stimulus'',24);');        parm_txt(25)  = text(.535,.23,num2str(PARAMS(25)), 'fontsize',12,'color',[.1 .1 .6],'horizontalalignment','right','VerticalAlignment','middle','buttondownfcn','view_inhibit_params(''stimulus'',25);');    parm_txt(26)  = text(.535,.20,num2str(PARAMS(26)), 'fontsize',12,'color',[.1 .1 .6],'horizontalalignment','right','VerticalAlignment','middle','buttondownfcn','view_inhibit_params(''stimulus'',26);');    parm_txt(27)  = text(.535,.17,num2str(PARAMS(27)), 'fontsize',12,'color',[.1 .1 .6],'horizontalalignment','right','VerticalAlignment','middle','buttondownfcn','view_inhibit_params(''stimulus'',27);');    parm_txt(28)  = text(.535,.12,num2str(PARAMS(28)), 'fontsize',12,'color',[.1 .1 .6],'horizontalalignment','right','VerticalAlignment','middle','buttondownfcn','view_inhibit_params(''stimulus'',28);');    parm_txt(29)  = text(.535,.09,num2str(PARAMS(29)), 'fontsize',12,'color',[.1 .1 .6],'horizontalalignment','right','VerticalAlignment','middle','buttondownfcn','view_inhibit_params(''stimulus'',29);');    parm_txt(30)  = text(.535,.06,num2str(PARAMS(30)), 'fontsize',12,'color',[.1 .1 .6],'horizontalalignment','right','VerticalAlignment','middle','buttondownfcn','view_inhibit_params(''stimulus'',30);');    %the following menus change behavioral parameters held in global PARAMS    h_push_def  = uicontrol(h_fig,'callback','view_inhibit_params(''reset'',0);','style','pushbutton','Units','normalized','position',[.3 .85 .1 .05],'string','Default');    h_push_update = uicontrol(h_fig,'callback','view_inhibit_params(''update'',0);','style','pushbutton','Units','normalized','position',[.45 .85 .1 .05],'string','Update','Enable','off','Foregroundcolor','r');    h_push_close  = uicontrol(h_fig,'callback','view_inhibit_params(''close'',0);','style','pushbutton','Units','normalized','position',[.6 .85 .1 .05],'string','Close');    h_push_left   = uicontrol(h_fig,'callback','view_inhibit_params(''left'',0);','style','radio','Units','normalized','position',[.65 .60 .15 .04],'string','Left Ear','Value',0,'fontname','helvetica','fontsize',12,'BackGroundColor','w');    h_push_right  = uicontrol(h_fig,'callback','view_inhibit_params(''right'',0);','style','radio','Units','normalized','position',[.65 .56 .15 .04],'string','Right Ear','Value',0,'fontname','helvetica','fontsize',12,'BackGroundColor','w');    h_push_both   = uicontrol(h_fig,'callback','view_inhibit_params(''both'',0);','style','radio','Units','normalized','position',[.65 .52 .15 .04],'string','Both Ears','Value',0,'fontname','helvetica','fontsize',12,'BackGroundColor','w');    h_edit        = uicontrol(h_fig,'style','edit','Units','normalized','position',[.63 .66 .15 .05],'string',[],'FontSize',14);    h_push_tuning   = uicontrol(h_fig,'callback','view_inhibit_params(''tuning'',0);','style','radio','Units','normalized','position',[.65 .46 .15 .04],'string','Tuning Curve','Value',0,'fontname','helvetica','fontsize',12,'BackGroundColor','w');    h_push_growth  = uicontrol(h_fig,'callback','view_inhibit_params(''growth'',0);','style','radio','Units','normalized','position',[.65 .42 .15 .04],'string','Sup Growth','Value',0,'fontname','helvetica','fontsize',12,'BackGroundColor','w');    h_push_adapt  = uicontrol(h_fig,'callback','view_inhibit_params(''adapt'',0);','style','radio','Units','normalized','position',[.65 .38 .15 .04],'string','Adap Growth','Value',0,'fontname','helvetica','fontsize',12,'BackGroundColor','w');    h_push_fmask  = uicontrol(h_fig,'callback','view_inhibit_params(''fmask'',0);','style','radio','Units','normalized','position',[.8 .46 .15 .04],'string','Forward Mask','Value',0,'fontname','helvetica','fontsize',12,'BackGroundColor','w');    h_push_smask  = uicontrol(h_fig,'callback','view_inhibit_params(''smask'',0);','style','radio','Units','normalized','position',[.8 .42 .15 .04],'string','Simult Mask','Value',0,'fontname','helvetica','fontsize',12,'BackGroundColor','w');    h_push_recover  = uicontrol(h_fig,'callback','view_inhibit_params(''recover'',0);','style','radio','Units','normalized','position',[.8 .38 .15 .04],'string','Recovery','Value',0,'fontname','helvetica','fontsize',12,'BackGroundColor','w');        switch PARAMS(10)        case 1, set(h_push_left,'value',1);        case 2,  set(h_push_right,'value',1);        case 3,  set(h_push_both,'value',1);    end    switch PARAMS(17)        case 1,            set(h_push_tuning,'value',1);            isVisN = [1:16];            isVis = ismember(1:30,isVisN);            isNotVis = ~ismember(1:30,isVisN);                        set(param_name_txt(isNotVis),'color',[0.7 0.7 0.7]);            set(parm_txt(isNotVis),'color',[0.7 0.7 0.7],'ButtonDownFcn','');            set(param_name_txt(isVis),'color','k');            for i=1:30                if isVis(i)                    set(parm_txt(i),'color',[.1 .1 .6],'ButtonDownFcn',sprintf('view_inhibit_params(''stimulus'',%1d);',i));                end            end        case 2,            set(h_push_growth,'value',1);            isVisN = [5:9,11:16,18:24];            isVis = ismember(1:30,isVisN);            isNotVis = ~ismember(1:30,isVisN);                        set(param_name_txt(isNotVis),'color',[0.7 0.7 0.7]);            set(parm_txt(isNotVis),'color',[0.7 0.7 0.7],'ButtonDownFcn','');            set(param_name_txt(isVis),'color','k');            for i=1:30                if isVis(i)                    set(parm_txt(i),'color',[.1 .1 .6],'ButtonDownFcn',sprintf('view_inhibit_params(''stimulus'',%1d);',i));                end            end        case 3,            set(h_push_adapt,'value',1);            isVisN = [5:9,11:16,18:24];            isVis = ismember(1:30,isVisN);            isNotVis = ~ismember(1:30,isVisN);                        set(param_name_txt(isNotVis),'color',[0.7 0.7 0.7]);            set(parm_txt(isNotVis),'color',[0.7 0.7 0.7],'ButtonDownFcn','');            set(param_name_txt(isVis),'color','k');            for i=1:30                if isVis(i)                    set(parm_txt(i),'color',[.1 .1 .6],'ButtonDownFcn',sprintf('view_inhibit_params(''stimulus'',%1d);',i));                end            end        case 4,            set(h_push_fmask,'value',1);            isVisN = [1:17 25:27];            isVis = ismember(1:30,isVisN);            isNotVis = ~ismember(1:30,isVisN);                        set(param_name_txt(isNotVis),'color',[0.7 0.7 0.7]);            set(parm_txt(isNotVis),'color',[0.7 0.7 0.7],'ButtonDownFcn','');            set(param_name_txt(isVis),'color','k');            for i=1:30                if isVis(i)                    set(parm_txt(i),'color',[.1 .1 .6],'ButtonDownFcn',sprintf('view_inhibit_params(''stimulus'',%1d);',i));                end            end        case 5,            set(h_push_smask,'value',1);            isVisN = [1:17 25:27];            isVis = ismember(1:30,isVisN);            isNotVis = ~ismember(1:30,isVisN);                        set(param_name_txt(isNotVis),'color',[0.7 0.7 0.7]);            set(parm_txt(isNotVis),'color',[0.7 0.7 0.7],'ButtonDownFcn','');            set(param_name_txt(isVis),'color','k');            for i=1:30                if isVis(i)                    set(parm_txt(i),'color',[.1 .1 .6],'ButtonDownFcn',sprintf('view_inhibit_params(''stimulus'',%1d);',i));                end            end        case 6,            set(h_push_recover,'value',1);            isVisN = [5:11 13:17 28:30];            isVis = ismember(1:30,isVisN);            isNotVis = ~ismember(1:30,isVisN);                        set(param_name_txt(isNotVis),'color',[0.7 0.7 0.7]);            set(parm_txt(isNotVis),'color',[0.7 0.7 0.7],'ButtonDownFcn','');            set(param_name_txt(isVis),'color','k');            for i=1:30                if isVis(i)                    set(parm_txt(i),'color',[.1 .1 .6],'ButtonDownFcn',sprintf('view_inhibit_params(''stimulus'',%1d);',i));                end            end    end        %set up handles required by callbacks from menus							    handles = [h_push_def h_push_update h_push_close h_push_left h_push_right h_push_both param_name_txt parm_txt h_edit h_push_tuning h_push_growth h_push_adapt h_push_fmask h_push_smask h_push_recover];    set(h_fig,'userdata',handles);        elseif strcmp(command_str,'reset')						%the reset call allows you to load saved workspace if incorrect settings have been entered    PARAMS(1)  = 0.04;    PARAMS(2)  = 20.0;    PARAMS(3)  =    0;    PARAMS(4)  =   -9;    PARAMS(5)  =   15;    PARAMS(6)  =  120;    PARAMS(7)  =    2;    PARAMS(8)  =    2;    PARAMS(9)  =    0;    PARAMS(10) =    2;    PARAMS(11) =   60;    PARAMS(12) =   60;    PARAMS(13) =   10;    PARAMS(14) =   60;    PARAMS(15) =    feval('current_unit_thresh')-15;     PARAMS(16) =    feval('current_unit_bf');    PARAMS(17) = 1;    PARAMS(18) = 0.100;    PARAMS(19) = 12.0;    PARAMS(20) = 0.333;    PARAMS(21) = 0;    PARAMS(22) = feval('current_unit_thresh')+10;    PARAMS(23) = 5;    PARAMS(24) = 100;    PARAMS(25) = 1.00;    PARAMS(26) = 85;    PARAMS(27) = 1;    PARAMS(28) = 1;    PARAMS(29) = 256*2^0.5;    PARAMS(30) = 0.5;        if PARAMS(4) == 0,       log_txt = 'no';    elseif PARAMS(4) > 0,       log_txt = 'yes';    else       log_txt = 'Q';    end        switch PARAMS(10)    case 1,        set(h_push_left,'value',1);        set(h_push_right,'value',0);        set(h_push_both,'value',0);    case 2,        set(h_push_left,'value',0);        set(h_push_right,'value',1);        set(h_push_both,'value',0);    case 3,        set(h_push_left,'value',0);        set(h_push_right,'value',0);        set(h_push_both,'value',1);    end    switch PARAMS(17)        case 1,            set(h_push_tuning,'value',1);            set(h_push_growth,'value',0);            set(h_push_adapt,'value',0);            set(h_push_fmask,'value',0);            set(h_push_smask,'value',0);            set(h_push_recover,'value',0);            isVisN = [1:16];            isVis = ismember(1:30,isVisN);            isNotVis = ~ismember(1:30,isVisN);                        set(param_name_txt(isNotVis),'color',[0.7 0.7 0.7]);            set(parm_txt(isNotVis),'color',[0.7 0.7 0.7],'ButtonDownFcn','');            set(param_name_txt(isVis),'color','k');            for i=1:30                if isVis(i)                    set(parm_txt(i),'color',[.1 .1 .6],'ButtonDownFcn',sprintf('view_inhibit_params(''stimulus'',%1d);',i));                end            end        case 2,            set(h_push_tuning,'value',0);            set(h_push_growth,'value',1);            set(h_push_adapt,'value',0);            set(h_push_fmask,'value',0);            set(h_push_smask,'value',0);            set(h_push_recover,'value',0);            isVisN = [5:9,11:16,18:24];            isVis = ismember(1:30,isVisN);            isNotVis = ~ismember(1:30,isVisN);                        set(param_name_txt(isNotVis),'color',[0.7 0.7 0.7]);            set(parm_txt(isNotVis),'color',[0.7 0.7 0.7],'ButtonDownFcn','');            set(param_name_txt(isVis),'color','k');            for i=1:30                if isVis(i)                    set(parm_txt(i),'color',[.1 .1 .6],'ButtonDownFcn',sprintf('view_inhibit_params(''stimulus'',%1d);',i));                end            end        case 3,            set(h_push_tuning,'value',0);            set(h_push_growth,'value',0);            set(h_push_adapt,'value',1);            set(h_push_fmask,'value',0);            set(h_push_smask,'value',0);            set(h_push_recover,'value',0);            isVisN = [5:9,11:16,18:24];            isVis = ismember(1:30,isVisN);            isNotVis = ~ismember(1:30,isVisN);                        set(param_name_txt(isNotVis),'color',[0.7 0.7 0.7]);            set(parm_txt(isNotVis),'color',[0.7 0.7 0.7],'ButtonDownFcn','');            set(param_name_txt(isVis),'color','k');            for i=1:30                if isVis(i)                    set(parm_txt(i),'color',[.1 .1 .6],'ButtonDownFcn',sprintf('view_inhibit_params(''stimulus'',%1d);',i));                end            end        case 4,            set(h_push_tuning,'value',0);            set(h_push_growth,'value',0);            set(h_push_adapt,'value',0);            set(h_push_fmask,'value',1);            set(h_push_smask,'value',0);            set(h_push_recover,'value',0);            isVisN = [1:17 25:27];            isVis = ismember(1:30,isVisN);            isNotVis = ~ismember(1:30,isVisN);                        set(param_name_txt(isNotVis),'color',[0.7 0.7 0.7]);            set(parm_txt(isNotVis),'color',[0.7 0.7 0.7],'ButtonDownFcn','');            set(param_name_txt(isVis),'color','k');            for i=1:30                if isVis(i)                    set(parm_txt(i),'color',[.1 .1 .6],'ButtonDownFcn',sprintf('view_inhibit_params(''stimulus'',%1d);',i));                end            end        case 5,            set(h_push_tuning,'value',0);            set(h_push_growth,'value',0);            set(h_push_adapt,'value',0);            set(h_push_fmask,'value',0);            set(h_push_smask,'value',1);            set(h_push_recover,'value',0);            isVisN = [1:17 25:27];            isVis = ismember(1:30,isVisN);            isNotVis = ~ismember(1:30,isVisN);                        set(param_name_txt(isNotVis),'color',[0.7 0.7 0.7]);            set(parm_txt(isNotVis),'color',[0.7 0.7 0.7],'ButtonDownFcn','');            set(param_name_txt(isVis),'color','k');            for i=1:30                if isVis(i)                    set(parm_txt(i),'color',[.1 .1 .6],'ButtonDownFcn',sprintf('view_inhibit_params(''stimulus'',%1d);',i));                end            end        case 6,            set(h_push_tuning,'value',0);            set(h_push_growth,'value',0);            set(h_push_adapt,'value',0);            set(h_push_fmask,'value',0);            set(h_push_smask,'value',0);            set(h_push_recover,'value',1);            isVisN = [5:11 13:17 28:30];            isVis = ismember(1:30,isVisN);            isNotVis = ~ismember(1:30,isVisN);                        set(param_name_txt(isNotVis),'color',[0.7 0.7 0.7]);            set(parm_txt(isNotVis),'color',[0.7 0.7 0.7],'ButtonDownFcn','');            set(param_name_txt(isVis),'color','k');            for i=1:30                if isVis(i)                    set(parm_txt(i),'color',[.1 .1 .6],'ButtonDownFcn',sprintf('view_inhibit_params(''stimulus'',%1d);',i));                end            end    end    for i = [1:2,5:30],        set(parm_txt(i),'String',num2str(PARAMS(i)));    end    set(parm_txt(3),'String',num2str(max(PARAMS(3),abs(PARAMS(4)))));    set(parm_txt(4),'String',log_txt);    set(h_push_update,'Enable','on');     elseif strcmp(command_str,'stimulus')    if length(get(h_edit,'string'))       new_value = get(h_edit,'string');       set(h_edit,'String',[]);       if stim_num == 4,          if strncmp(new_value,'y',1) | str2num(new_value)==1,             set(parm_txt(4),'String','yes');             PARAMS(4) = max(PARAMS(3),abs(PARAMS(4)));             PARAMS(3) = 0;          elseif strncmp(new_value,'Q',1),             set(parm_txt(4),'String','Q');             PARAMS(4) = -max(PARAMS(3),abs(PARAMS(4)));  % Store #steps as NEGATIVE for Qspaced             PARAMS(3) = 0;          else             set(parm_txt(4),'String','no');             PARAMS(3) = max(PARAMS(3),abs(PARAMS(4)));             PARAMS(4) = 0;          end       elseif stim_num == 3,          set(parm_txt(3),'String',new_value);          if PARAMS(3) > abs(PARAMS(4)),             PARAMS(3) = str2num(new_value);          elseif PARAMS(4)>0             PARAMS(4) = str2num(new_value);          else             PARAMS(4) = -str2num(new_value);          end       else          set(parm_txt(stim_num),'String',new_value);          PARAMS(stim_num) = str2num(new_value);       end       set(h_push_update,'Enable','on');    else       set(h_edit,'String','ERROR');    end    elseif strcmp(command_str,'left')    PARAMS(10) = 1;    set(h_push_left,'value',1);    set(h_push_right,'value',0);    set(h_push_both,'value',0);    set(h_push_update,'Enable','on');elseif strcmp(command_str,'right')    PARAMS(10) = 2;    set(h_push_left,'value',0);    set(h_push_right,'value',1);    set(h_push_both,'value',0);    set(h_push_update,'Enable','on');elseif strcmp(command_str,'both')    PARAMS(10) = 3;    set(h_push_left,'value',0);    set(h_push_right,'value',0);    set(h_push_both,'value',1);    set(h_push_update,'Enable','on');elseif strcmp(command_str,'tuning')    PARAMS(17) = 1;    set(h_push_tuning,'value',1);    set(h_push_growth,'value',0);    set(h_push_adapt,'value',0);    set(h_push_fmask,'value',0);    set(h_push_smask,'value',0);    set(h_push_recover,'value',0);    set(h_push_update,'Enable','on');    PARAMS(15) =    feval('current_unit_thresh')-15;    set(parm_txt(15),'string',PARAMS(15));    isVisN = [1:16];    isVis = ismember(1:30,isVisN);    isNotVis = ~ismember(1:30,isVisN);        set(param_name_txt(isNotVis),'color',[0.7 0.7 0.7]);    set(parm_txt(isNotVis),'color',[0.7 0.7 0.7],'ButtonDownFcn','');    set(param_name_txt(isVis),'color','k');    for i=1:30        if isVis(i)            set(parm_txt(i),'color',[.1 .1 .6],'ButtonDownFcn',sprintf('view_inhibit_params(''stimulus'',%1d);',i));        end    endelseif strcmp(command_str,'growth')    PARAMS(17) = 2;    set(h_push_tuning,'value',0);    set(h_push_growth,'value',1);    set(h_push_adapt,'value',0);    set(h_push_fmask,'value',0);    set(h_push_smask,'value',0);    set(h_push_recover,'value',0);    set(h_push_update,'Enable','on');    PARAMS(15) =    feval('current_unit_thresh')-15;    set(parm_txt(15),'string',PARAMS(15));    isVisN = [5:9,11:16,18:24];    isVis = ismember(1:30,isVisN);    isNotVis = ~ismember(1:30,isVisN);        set(param_name_txt(isNotVis),'color',[0.7 0.7 0.7]);    set(parm_txt(isNotVis),'color',[0.7 0.7 0.7],'ButtonDownFcn','');    set(param_name_txt(isVis),'color','k');    for i=1:30        if isVis(i)            set(parm_txt(i),'color',[.1 .1 .6],'ButtonDownFcn',sprintf('view_inhibit_params(''stimulus'',%1d);',i));        end    endelseif strcmp(command_str,'adapt')    PARAMS(17) = 3;    set(h_push_tuning,'value',0);    set(h_push_growth,'value',0);    set(h_push_adapt,'value',1);    set(h_push_fmask,'value',0);    set(h_push_smask,'value',0);    set(h_push_recover,'value',0);    set(h_push_update,'Enable','on');    PARAMS(15) =    feval('current_unit_thresh')-15;    set(parm_txt(15),'string',PARAMS(15));    isVisN = [5:9,11:16,18:24];    isVis = ismember(1:30,isVisN);    isNotVis = ~ismember(1:30,isVisN);        set(param_name_txt(isNotVis),'color',[0.7 0.7 0.7]);    set(parm_txt(isNotVis),'color',[0.7 0.7 0.7],'ButtonDownFcn','');    set(param_name_txt(isVis),'color','k');    for i=1:30        if isVis(i)            set(parm_txt(i),'color',[.1 .1 .6],'ButtonDownFcn',sprintf('view_inhibit_params(''stimulus'',%1d);',i));        end    endelseif strcmp(command_str,'fmask')    PARAMS(17) = 4;    set(h_push_tuning,'value',0);    set(h_push_growth,'value',0);    set(h_push_adapt,'value',0);    set(h_push_fmask,'value',1);    set(h_push_smask,'value',0);    set(h_push_recover,'value',0);    set(h_push_update,'Enable','on');    isVisN = [1:17 25:27];    isVis = ismember(1:30,isVisN);    isNotVis = ~ismember(1:30,isVisN);        set(param_name_txt(isNotVis),'color',[0.7 0.7 0.7]);    set(parm_txt(isNotVis),'color',[0.7 0.7 0.7],'ButtonDownFcn','');    set(param_name_txt(isVis),'color','k');    for i=1:30        if isVis(i)            set(parm_txt(i),'color',[.1 .1 .6],'ButtonDownFcn',sprintf('view_inhibit_params(''stimulus'',%1d);',i));        end    endelseif strcmp(command_str,'smask')    PARAMS(17) = 5;    set(h_push_tuning,'value',0);    set(h_push_growth,'value',0);    set(h_push_adapt,'value',0);    set(h_push_fmask,'value',0);    set(h_push_smask,'value',1);    set(h_push_recover,'value',0);    set(h_push_update,'Enable','on');    isVisN = [1:17 25:27];    isVis = ismember(1:30,isVisN);    isNotVis = ~ismember(1:30,isVisN);        set(param_name_txt(isNotVis),'color',[0.7 0.7 0.7]);    set(parm_txt(isNotVis),'color',[0.7 0.7 0.7],'ButtonDownFcn','');    set(param_name_txt(isVis),'color','k');    for i=1:30        if isVis(i)            set(parm_txt(i),'color',[.1 .1 .6],'ButtonDownFcn',sprintf('view_inhibit_params(''stimulus'',%1d);',i));        end    endelseif strcmp(command_str,'recover')    PARAMS(17) = 6;    set(h_push_tuning,'value',0);    set(h_push_growth,'value',0);    set(h_push_adapt,'value',0);    set(h_push_fmask,'value',0);    set(h_push_smask,'value',0);    set(h_push_recover,'value',1);    set(h_push_update,'Enable','on');    PARAMS(15) =    feval('current_unit_thresh')-30;    set(parm_txt(15),'string',PARAMS(15));    isVisN = [5:11 13:17 28:30];    isVis = ismember(1:30,isVisN);    isNotVis = ~ismember(1:30,isVisN);        set(param_name_txt(isNotVis),'color',[0.7 0.7 0.7]);    set(parm_txt(isNotVis),'color',[0.7 0.7 0.7],'ButtonDownFcn','');    set(param_name_txt(isVis),'color','k');    for i=1:30        if isVis(i)            set(parm_txt(i),'color',[.1 .1 .6],'ButtonDownFcn',sprintf('view_inhibit_params(''stimulus'',%1d);',i));        end    endelseif strcmp(command_str,'update')			% after parameters have been changed they need to be recorded in subject's parameter file    eval('update_inhibit_params');						% use function update_inhibit_params to rewrite the file    set(h_push_update,'Enable','off');    view_inhibit_params('close');elseif strcmp(command_str,'close')			% clear, close and then restart the sens.m program    close('Parameters');    inhibit_curve('return from parameter change');end