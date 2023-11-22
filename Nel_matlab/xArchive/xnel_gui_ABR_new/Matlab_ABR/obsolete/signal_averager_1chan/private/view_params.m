function view_params(command_str,txt_num)
global Stimuli View root_dir

if nargin < 1	
    
    curr_dir = cd(fullfile(root_dir,'signal_averager','private'));
    %CREATING STRUCTURES HERE
    push = cell2struct(cell(1,3),{'default','update','edit'},2);
    View = struct('handle',[],'push',push,'parm_txt',[]);
    
    %MAKING FIGURE AND INTERFACE
    View.handle = figure('NumberTitle','off','Name','Parameters','Units','normalized','position',[.25 .2 .5 .6]);
    axes('Position',[0 0 1 1]);
    axis('off');
    
    text(.445,.75,'Playback','fontsize',14,'fontweight','bold','color','k','horizontalalignment','right','VerticalAlignment','middle','EraseMode','none');
    text(.445,.70,'Freq (Hz):','fontsize',12,'color','k','horizontalalignment','right','VerticalAlignment','middle','EraseMode','none');
    text(.445,.65,'Duration (msec):','fontsize',12,'color','k','horizontalalignment','right','VerticalAlignment','middle','EraseMode','none');
    text(.445,.60,'Rise/Fall (msec):','fontsize',12,'color','k','horizontalalignment','right','VerticalAlignment','middle','EraseMode','none');
    text(.6,.60,num2str(Stimuli.rise_fall), 'fontsize',12,'color','k','horizontalalignment','right','VerticalAlignment','middle','EraseMode','none');
    text(.445,.55,'Pulses/sec:','fontsize',12,'color','k','horizontalalignment','right','VerticalAlignment','middle','EraseMode','none');
    text(.445,.50,'Attenuation (dB):','fontsize',12,'color','k','horizontalalignment','right','VerticalAlignment','middle','EraseMode','none');
    text(.445,.35,'Record','fontsize',14,'fontweight','bold','color','k','horizontalalignment','right','VerticalAlignment','middle','EraseMode','none');
    text(.445,.30,'Duration (msec):','fontsize',12,'color','k','horizontalalignment','right','VerticalAlignment','middle','EraseMode','none');
    text(.445,.25,'Samp Rate (kHz):','fontsize',12,'color','k','horizontalalignment','right','VerticalAlignment','middle','EraseMode','none');
    text(.6,.25,num2str(Stimuli.SampRate),'fontsize',12,'color','k','horizontalalignment','right','VerticalAlignment','middle','EraseMode','none');
    text(.445,.20,'Num Averages:','fontsize',12,'color','k','horizontalalignment','right','VerticalAlignment','middle','EraseMode','none');
    text(.445,.15,'Amplifier Gain:','fontsize',12,'color','k','horizontalalignment','right','VerticalAlignment','middle','EraseMode','none');
    
    if Stimuli.freq_hz == 0,
        stim_txt = 'click';
    else
        stim_txt = num2str(Stimuli.freq_hz);
    end
    View.parm_txt(1)  = text(.6,.70,stim_txt, 'fontsize',12,'color',[.1 .1 .6],'horizontalalignment','right','VerticalAlignment','middle','EraseMode','normal','buttondownfcn','view_params(''Stimuli'',1);');
    View.parm_txt(2)  = text(.6,.65,num2str(Stimuli.play_duration), 'fontsize',12,'color',[.1 .1 .6],'horizontalalignment','right','VerticalAlignment','middle','EraseMode','normal','buttondownfcn','view_params(''Stimuli'',2);');
    View.parm_txt(3)  = text(.6,.30,num2str(Stimuli.record_duration),'fontsize',12,'color',[.1 .1 .6],'horizontalalignment','right','VerticalAlignment','middle','EraseMode','normal','buttondownfcn','view_params(''Stimuli'',3);');
    View.parm_txt(4)  = text(.6,.55,num2str(Stimuli.pulses_per_sec), 'fontsize',12,'color',[.1 .1 .6],'horizontalalignment','right','VerticalAlignment','middle','EraseMode','normal','buttondownfcn','view_params(''Stimuli'',4);');
    View.parm_txt(5)  = text(.6,.20,num2str(Stimuli.naves),'fontsize',12,'color',[.1 .1 .6],'horizontalalignment','right','VerticalAlignment','middle','EraseMode','normal','buttondownfcn','view_params(''Stimuli'',5);');
    View.parm_txt(6)  = text(.6,.50,num2str(Stimuli.db_atten), 'fontsize',12,'color',[.8 .1 .1],'horizontalalignment','right','VerticalAlignment','middle','EraseMode','normal','buttondownfcn','view_params(''Stimuli'',6);');
    View.parm_txt(7)  = text(.6,.15,num2str(Stimuli.amp_gain), 'fontsize',12,'color',[.1 .1 .6],'horizontalalignment','right','VerticalAlignment','middle','EraseMode','normal','buttondownfcn','view_params(''Stimuli'',7);');
    
    
    View.push.default = uicontrol(View.handle,'callback','view_params(''defs'',0);','style','pushbutton','Units','normalized','position',[.1 .85 .3 .075],'string','Defaults');
    View.push.update  = uicontrol(View.handle,'callback','view_params(''update'',0);','style','pushbutton','Units','normalized','position',[.6 .85 .3 .075],'Enable','off','ForegroundColor','r','string','Update');
    View.push.edit    = uicontrol(View.handle,'style','edit','Units','normalized','position',[.7 .375 .2 .075],'string',[],'FontSize',12);															
    
    set(View.handle,'Userdata',struct('handles',View));    
    
elseif strcmp(command_str,'Stimuli')
    if length(get(View.push.edit,'string'))
        set(View.push.update,'Enable','on');
        set(View.parm_txt(txt_num),'String',get(View.push.edit,'string'));
        switch txt_num
        case 1,
             new_value = get(View.push.edit,'string');
             if strncmp(new_value,'c',1),
                Stimuli.freq_hz = 0;
                set(View.parm_txt(1),'String','click');
            else
                Stimuli.freq_hz = str2num(new_value);
                set(View.parm_txt(1),'String',new_value);
            end
        case 2,
            Stimuli.play_duration = str2num(get(View.push.edit,'string'));
        case 3,
            Stimuli.record_duration = str2num(get(View.push.edit,'string'));
        case 4,
            Stimuli.pulses_per_sec = str2num(get(View.push.edit,'string'));
        case 5,
            Stimuli.naves = str2num(get(View.push.edit,'string'));
        case 6,
            Stimuli.db_atten = str2num(get(View.push.edit,'string'));
        case 7,
            Stimuli.amp_gain = str2num(get(View.push.edit,'string'));
        end
    else
        set(View.push.edit,'String','ERROR');
    end
    
elseif strcmp(command_str,'defs')
    set(View.push.update,'Enable','on');
    Stimuli = struct('freq_hz', 2000, ...
        'play_duration',  5, ...
        'record_duration',30, ...
        'SampRate',      100, ...
        'pulses_per_sec', 20, ...
        'rise_fall',     0.5, ...
        'naves',         1000, ...
        'db_atten',       20, ...
        'amp_gain',   100000);
    
    set(View.parm_txt(1),'String',num2str(Stimuli.freq_hz));
    set(View.parm_txt(2),'String',num2str(Stimuli.play_duration));
    set(View.parm_txt(3),'String',num2str(Stimuli.record_duration));
    set(View.parm_txt(4),'String',num2str(Stimuli.pulses_per_sec));
    set(View.parm_txt(5),'String',num2str(Stimuli.naves));
    set(View.parm_txt(6),'String',num2str(Stimuli.db_atten));
    set(View.parm_txt(7),'String',num2str(Stimuli.amp_gain));
    
elseif strcmp(command_str,'update')	
    update_params;
    closereq;
end
