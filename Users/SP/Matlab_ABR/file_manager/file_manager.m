function file_manager(command_str,button_num)

global PROG FIG EXPS data_dir

if nargin < 1
    
    %CREATING STRUCTURES HERE
    PROG = struct('name','FileManager.m','date',date,'version','rp2 v2.0');

    push  = cell2struct(cell(1,6),{'name','restart','delete','backup','close','edit'},2);
    txt   = cell2struct(cell(1,4),{'owners','dates','files','lastunit'},2);
    FIG = struct('handle',[],'push',push,'txt',txt,'radio',[]);
    
    explist;
    
    %MAKING FIGURE AND USER INTERFACE
    FIG.handle = figure('NumberTitle','off','Name','Experiment List','Units','normalized','position',[.15 .1 .7 .8],'visible','off','CloseRequestFcn','AbortProgram'); %open window for the TDT GUI
    colordef none;
    whitebg('w');
    h_ax = axes('Position',[0 0 1 1]);	%set up axes equal in size to the jpeg
    axis('off');
    
    text(.25,.125,'Name Experiment','fontsize',12,'color',[.6 .1 .1],'horizontalalignment','center','VerticalAlignment','bottom','EraseMode','back');
    
    text(.2,.68,'Owner','fontsize',12,'fontweight','bold','color','k','horizontalalignment','left','VerticalAlignment','bottom','EraseMode','back');
    text(.4,.68,'Date','fontsize',12,'fontweight','bold','color','k','horizontalalignment','center','VerticalAlignment','bottom','EraseMode','back');
    text(.6,.68,'Files','fontsize',12,'fontweight','bold','fontweight','bold','color','k','horizontalalignment','right','VerticalAlignment','bottom','EraseMode','back');
    text(.8,.68,'Last Unit','fontsize',12,'fontweight','bold','fontweight','bold','color','k','horizontalalignment','right','VerticalAlignment','bottom','EraseMode','back');
    FIG.txt.owners   = text(.2,.658,struct2cell(EXPS.owners),'fontsize',12,'color','k','horizontalalignment','left','VerticalAlignment','top','EraseMode','back');
    FIG.txt.dates    = text(.4,.658,struct2cell(EXPS.dates),'fontsize',12,'color','k','horizontalalignment','center','VerticalAlignment','top','EraseMode','back');
    FIG.txt.files    = text(.6,.658,struct2cell(EXPS.files),'fontsize',12,'color','k','horizontalalignment','right','VerticalAlignment','top','EraseMode','back');
    FIG.txt.lastunit = text(.8,.658,struct2cell(EXPS.lastunit),'fontsize',12,'color','k','horizontalalignment','right','VerticalAlignment','top','EraseMode','back');
    
    %the following menus change behavioral parameters held in global PARAMS
    FIG.push.name    = uicontrol(FIG.handle,'callback','file_manager(''name'');','style','pushbutton','Units','normalized','position',[.025 .85 .15 .075],'string','New Exp');
    FIG.push.restart = uicontrol(FIG.handle,'callback','file_manager(''restart'');','style','pushbutton','Units','normalized','position',[.225 .85 .15 .075],'string','Re-activate');
    FIG.push.delete  = uicontrol(FIG.handle,'callback','file_manager(''delete'');','style','pushbutton','Units','normalized','position',[.425 .85 .15 .075],'string','Delete');
    FIG.push.backup  = uicontrol(FIG.handle,'callback','file_manager(''backup'');','style','pushbutton','Units','normalized','position',[.625 .85 .15 .075],'string','Back Up');
    FIG.push.close   = uicontrol(FIG.handle,'callback','file_manager(''save_close'');','style','pushbutton','Units','normalized','position',[.825 .85 .15 .075],'string','Save & Close');
    FIG.push.edit    = uicontrol(FIG.handle,'style','edit','Units','normalized','position',[.175 .05 .15 .05],'string',[],'FontSize',12);								
    
    
    FIG.radio(1)     = uicontrol(FIG.handle,'callback','file_manager(''select'', 1);','style','radio','Units','normalized','position',[.15 .630 .05 .025],'ForegroundColor','k','BackgroundColor','w','string','A:','FontSize',12,'value',0);
    FIG.radio(2)     = uicontrol(FIG.handle,'callback','file_manager(''select'', 2);','style','radio','Units','normalized','position',[.15 .601 .05 .025],'ForegroundColor','k','BackgroundColor','w','string','B:','FontSize',12,'value',0);
    FIG.radio(3)     = uicontrol(FIG.handle,'callback','file_manager(''select'', 3);','style','radio','Units','normalized','position',[.15 .571 .05 .025],'ForegroundColor','k','BackgroundColor','w','string','C:','FontSize',12,'value',0);
    FIG.radio(4)     = uicontrol(FIG.handle,'callback','file_manager(''select'', 4);','style','radio','Units','normalized','position',[.15 .542 .05 .025],'ForegroundColor','k','BackgroundColor','w','string','D:','FontSize',12,'value',0);
    FIG.radio(5)     = uicontrol(FIG.handle,'callback','file_manager(''select'', 5);','style','radio','Units','normalized','position',[.15 .513 .05 .025],'ForegroundColor','k','BackgroundColor','w','string','E:','FontSize',12,'value',0);
    FIG.radio(6)     = uicontrol(FIG.handle,'callback','file_manager(''select'', 6);','style','radio','Units','normalized','position',[.15 .484 .05 .025],'ForegroundColor','k','BackgroundColor','w','string','F:','FontSize',12,'value',0);
    FIG.radio(7)     = uicontrol(FIG.handle,'callback','file_manager(''select'', 7);','style','radio','Units','normalized','position',[.15 .454 .05 .025],'ForegroundColor','k','BackgroundColor','w','string','G:','FontSize',12,'value',0);
    FIG.radio(8)     = uicontrol(FIG.handle,'callback','file_manager(''select'', 8);','style','radio','Units','normalized','position',[.15 .425 .05 .025],'ForegroundColor','k','BackgroundColor','w','string','H:','FontSize',12,'value',0);
    FIG.radio(9)     = uicontrol(FIG.handle,'callback','file_manager(''select'', 9);','style','radio','Units','normalized','position',[.15 .396 .05 .025],'ForegroundColor','k','BackgroundColor','w','string','I:','FontSize',12,'value',0);
    FIG.radio(10)    = uicontrol(FIG.handle,'callback','file_manager(''select'',10);','style','radio','Units','normalized','position',[.15 .366 .05 .025],'ForegroundColor','k','BackgroundColor','w','string','J:','FontSize',12,'value',0);
    FIG.radio(11)    = uicontrol(FIG.handle,'callback','file_manager(''select'',11);','style','radio','Units','normalized','position',[.15 .337 .05 .025],'ForegroundColor','k','BackgroundColor','w','string','K:','FontSize',12,'value',0);
    FIG.radio(12)    = uicontrol(FIG.handle,'callback','file_manager(''select'',12);','style','radio','Units','normalized','position',[.15 .308 .05 .025],'ForegroundColor','k','BackgroundColor','w','string','L:','FontSize',12,'value',0);
    FIG.radio(13)    = uicontrol(FIG.handle,'callback','file_manager(''select'',13);','style','radio','Units','normalized','position',[.15 .279 .05 .025],'ForegroundColor','k','BackgroundColor','w','string','M:','FontSize',12,'value',0);
    FIG.radio(14)    = uicontrol(FIG.handle,'callback','file_manager(''select'',14);','style','radio','Units','normalized','position',[.15 .249 .05 .025],'ForegroundColor','k','BackgroundColor','w','string','N:','FontSize',12,'value',0);
    FIG.radio(15)    = uicontrol(FIG.handle,'callback','file_manager(''select'',15);','style','radio','Units','normalized','position',[.15 .220 .05 .025],'ForegroundColor','k','BackgroundColor','w','string','O:','FontSize',12,'value',0);
    
    set(FIG.radio(double(EXPS.currunit.FilePrefix)-64),'value',1,'ForegroundColor','b');
    
    %set up handles required by callbacks from menus							
    set(FIG.handle,'Userdata',struct('handles',FIG));    
    set(FIG.handle,'visible','on');
    
elseif strcmp(command_str,'select')
    num_buttons = length(FIG.radio);
    if get(FIG.radio(button_num),'value') == 1
        set(FIG.radio([1:(button_num-1),(button_num+1):num_buttons]),'value',0,'ForegroundColor','k');
    else
        set(FIG.radio(button_num),'value',1, 'ForegroundColor','b');
    end
    
elseif strcmp(command_str,'name')
    for i = 1:length(FIG.radio)
        if get(FIG.radio(i),'value')
            prefix = char(64+i);
            eval(sprintf('%s%c%s','EXPS.owners.',prefix,' = get(FIG.push.edit,''string'');'));
            set(FIG.txt.owners,'string',struct2cell(EXPS.owners));
            set(FIG.push.edit,'string',[]);
            eval(sprintf('%s%c%s','EXPS.dates.',prefix,' = date;'));
            set(FIG.txt.dates,'string',struct2cell(EXPS.dates));
            eval(sprintf('%s%c%s','EXPS.files.',prefix,' = ''0'';'));
            set(FIG.txt.files,'string',struct2cell(EXPS.files));
            eval(sprintf('%s%c%s','EXPS.lastunit.',prefix,' = ''1.01'';'));
            set(FIG.txt.lastunit,'string',struct2cell(EXPS.lastunit));
            EXPS.currunit.FilePrefix = char(64+i);
            EXPS.currunit.fnum = 1;
            EXPS.currunit.unit = '1.01';
            set(FIG.radio(i),'value',1, 'ForegroundColor','b');
            if (mkdir(data_dir, EXPS.currunit.FilePrefix) == 0)
                errmsg = sprintf('%s %s%c','Cannot create directory',data_dir,'\',EXPS.currunit.FilePrefix);
                waitfor(errordlg(errmsg,'File Manager'));
            else
                EXPS.currunit.CurrentDataDir= [data_dir EXPS.currunit.FilePrefix '\'];
                if (mkdir(EXPS.currunit.CurrentDataDir, 'Object') == 0)
                    errmsg = sprintf('%s %s%s','Can not create directory',EXPS.currunit.CurrentDataDir,'\Object');
                    waitfor(errordlg(errmsg,'File Manager'));
                end
                if (mkdir(EXPS.currunit.CurrentDataDir, 'Signals') == 0)
                    errmsg = sprintf('%s %s%s','Can not create directory',EXPS.currunit.CurrentDataDir,'\Signals');
                    waitfor(errordlg(errmsg,'File Manager'));
                end
            end
        end
    end
    
    
elseif strcmp(command_str,'restart')
    for i = 1:1:length(FIG.radio)
        if get(FIG.radio(i),'value')
            EXPS.currunit.FilePrefix = char(64+i);
            EXPS.currunit.fnum = str2num(EXPS.FILES{i}) + 1;
            eval(sprintf('%s%c%c','EXPS.currunit.fnum = EXPS.files.',EXPS.currunit.FilePrefix,';'));
            if (isempty(EXPS.currunit.fnum))
                EXPS.currunit.fnum = 0;
            end
            eval(sprintf('%s%c%c','EXPS.currunit.unit = EXPS.lastunit.',EXPS.currunit.FilePrefix,';'));
            set(FIG.radio(i),'value',1, 'ForegroundColor','b');
            EXPS.currunit.CurrentDataDir = [data_dir EXPS.currunit.FilePrefix '\'];
        end
    end
    
    
elseif strcmp(command_str,'delete')
    for i = 1:length(FIG.radio)
        if get(FIG.radio(i),'value')
            prefix = char(64+i);
            set(FIG.radio(i),'ForegroundColor','r');
            answer = questdlg(['Deleting all files in ' data_dir prefix '\. Are you sure?'],'Alert!','No');
            if (strcmp(answer,'Yes'))
                if (strncmp(EXPS.currunit.FilePrefix,prefix,1))
                    errordlg('Can''t delete files of an active experiment', 'File Manager');
                else
                    eval(sprintf('%s%c%s','EXPS.owners.',prefix,' = ''...'';'));
                    set(FIG.txt.owners,'string',struct2cell(EXPS.owners));
                    eval(sprintf('%s%c%s','EXPS.dates.',prefix,' = ''...'';'));
                    set(FIG.txt.dates,'string',struct2cell(EXPS.dates));
                    eval(sprintf('%s%c%s','EXPS.files.',prefix,' = ''...'';'));
                    set(FIG.txt.files,'string',struct2cell(EXPS.files));
                    eval(sprintf('%s%c%s','EXPS.lastunit.',prefix,' = ''...'';'));
                    set(FIG.txt.lastunit,'string',struct2cell(EXPS.lastunit));
                    data_files = [data_dir prefix '\*.m'];
                    delete(data_files);
                    delete([data_dir prefix '\Object\*.rpd']);
                    delete([data_dir prefix '\Signals\*.wav']);
                    set(FIG.radio(i),'ForegroundColor','k');
                    set(FIG.radio(i),'value',0);
                end
            end
        end
    end
    index = double(EXPS.currunit.FilePrefix)-64;
    set(FIG.radio(index), 'value',1);
    
elseif strcmp(command_str,'backup')
    for i = 1:length(FIG.radio)
        if get(FIG.radio(i),'value')
            prefix = char(64+i);
            answer = questdlg('Moving files to zip disk. Are you sure?','Alert!','No');
            if strcmp(answer,'Yes'),
                backup_dir = char(DATES(i));
                command_line = strcat('mkdir d:\',backup_dir);
                dos(command_line);
                command_line = strcat(['copy ' data_dir prefix '\*.m  e:\' backup_dir]);
                dos(command_line);
                set(FIG.radio(i),'value',0);
                index = double(EXPS.currunit.FilePrefix)-64;
                set(FIG.radio(index), 'value',1, 'ForegroundColor','b');
            end
        end
    end
    
elseif strcmp(command_str,'save_close')
    clear explist;
    make_explist;
    delete(FIG.handle);
end
