function [fighandle] = view_params(command_str,txt_num)

global Stimuli View root_dir fighandle

if nargin < 1	
    
    curr_dir = cd(fullfile(root_dir,'calibrate','private'));
    %CREATING STRUCTURES HERE
    push = cell2struct(cell(1,3),{'default','update','edit'},2);
    View = struct('push',push,'parm_txt',[]);
    
    %MAKING FIGURE AND INTERFACE
    fighandle = figure('NumberTitle','off','Name','Parameters','Units','normalized','position',[.25 .2 .5 .6]);
    axes('Position',[0 0 1 1]);
    axis('off');
    
    text(.445,.70,'Low Frequency:','fontsize',12,'color','k','horizontalalignment','right','VerticalAlignment','middle','EraseMode','none');
    text(.445,.65,'High Frequency:','fontsize',12,'color','k','horizontalalignment','right','VerticalAlignment','middle','EraseMode','none');
    text(.445,.60,'Reference Frequency:','fontsize',12,'color','k','horizontalalignment','right','VerticalAlignment','middle','EraseMode','none');
    text(.445,.55,'Attenuation:','fontsize',12,'color','k','horizontalalignment','right','VerticalAlignment','middle','EraseMode','none');
    text(.445,.50,'Microphone:','fontsize',12,'color','k','horizontalalignment','right','VerticalAlignment','middle','EraseMode','none');
    
    View.parm_txt(1)  = text(.6,.70,num2str(Stimuli.frqlo),   'fontsize',12,'color',[.1 .1 .6],'horizontalalignment','right','VerticalAlignment','middle','EraseMode','normal','buttondownfcn','view_params(''Stimuli'',1);');
    View.parm_txt(2)  = text(.6,.65,num2str(Stimuli.frqhi),   'fontsize',12,'color',[.1 .1 .6],'horizontalalignment','right','VerticalAlignment','middle','EraseMode','normal','buttondownfcn','view_params(''Stimuli'',2);');
    View.parm_txt(3)  = text(.6,.60,num2str(Stimuli.frqcal),  'fontsize',12,'color',[.1 .1 .6],'horizontalalignment','right','VerticalAlignment','middle','EraseMode','normal','buttondownfcn','view_params(''Stimuli'',3);');
    View.parm_txt(4)  = text(.6,.55,num2str(Stimuli.attencal),'fontsize',12,'color',[.1 .1 .6],'horizontalalignment','right','VerticalAlignment','middle','EraseMode','normal','buttondownfcn','view_params(''Stimuli'',4);');
    View.parm_txt(5)  = text(.6,.50,Stimuli.nmic,             'fontsize',12,'color',[.1 .1 .6],'horizontalalignment','right','VerticalAlignment','middle','EraseMode','normal','buttondownfcn','view_params(''Stimuli'',5);');
    
    
    View.push.default = uicontrol(fighandle,'callback','view_params(''defs'',0);','style','pushbutton','Units','normalized','position',[.1 .85 .3 .075],'string','Defaults');
    View.push.update  = uicontrol(fighandle,'callback','view_params(''update'',0);','style','pushbutton','Units','normalized','position',[.6 .85 .3 .075],'Enable','off','ForegroundColor','r','string','Update');
    View.push.edit    = uicontrol(fighandle,'style','edit','Units','normalized','position',[.4 .375 .2 .075],'string',[],'FontSize',12);															
    
    set(fighandle,'Userdata',struct('handles',View));    
    
elseif strcmp(command_str,'Stimuli')
    if length(get(View.push.edit,'string'))
        set(View.push.update,'Enable','on');
        new_value = get(View.push.edit,'string');
        set(View.parm_txt(txt_num),'String',new_value);
        set(View.push.edit,'String',[]);
        switch txt_num
            case 1,
                Stimuli.frqlo = str2num(new_value);
            case 2,
                Stimuli.frqhi = str2num(new_value);
            case 3,
                Stimuli.frqcal = str2num(new_value);
            case 4,
                Stimuli.attencal = str2num(new_value);
            case 5,
                Stimuli.nmic = new_value;
        end
    else
        set(View.push.edit,'String','ERROR');
    end
    
elseif strcmp(command_str,'defs')
    set(View.push.update,'Enable','on');
    Stimuli = struct('frqlo', 4.0, ...
        'frqhi',  40.0, ...
        'frqcal', 16.0, ...
        'attencal',0.0, ...
        'nmic',  '168');
    
    set(View.parm_txt(1),'String',num2str(Stimuli.frqlo));
    set(View.parm_txt(2),'String',num2str(Stimuli.frqhi));
    set(View.parm_txt(3),'String',num2str(Stimuli.frqcal));
    set(View.parm_txt(4),'String',num2str(Stimuli.attencal));
    
elseif strcmp(command_str,'update')	
    update_params;
    delete(gcf);
end
