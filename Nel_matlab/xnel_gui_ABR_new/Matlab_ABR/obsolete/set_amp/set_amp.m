function set_amp(command_str,param_num)

%This program is used to set the voltage on free-field amplifiers.

global PROG FIG Stimuli NelData root_dir prog_dir

if nargin == 0
    prog_dir = fullfile(root_dir,'set_amp');
    
    %CREATING STRUCTURES HERE
    PROG = struct('name','RP2volts.m','date',date);
    
    push = cell2struct(cell(1,2),{'save','edit'},2);
    ax1  = struct('axes',[],'ParamHeader',[],'ParamData',[]);
    FIG  = struct('handle',[],'push',push,'ax1',ax1);
    
    get_amp_ins;    %Stimuli structure created by this script
    FIG.handle = figure('NumberTitle','off','Name','Amp Interface','Units','normalized','Visible','off','position',[.25 .25 .5 .5],'CloseRequestFcn','set_amp(''close'')');
    colordef none;
    whitebg('w');
    
    FIG.ax1.axes = axes('position',[0 0 1 1]);
    axis off;
    box on;
    
    FIG.push.save    = uicontrol(FIG.handle,'callback','set_amp(''save'');','style','pushbutton','Enable','on','Units','normalized','position',[.3 .8 .4 .075],'string','Save','Userdata',0,'fontsize',12);
    FIG.push.edit    = uicontrol(FIG.handle,'style','edit','Units','normalized','position',[.525 .125 .2 .075],'string',[],'FontSize',14);								
    
    
    if Stimuli.freq_hz
        StmStr = num2str(Stimuli.freq_hz);
        fontcolor1 = [.8 .8 .8];
        fontcolor2 = [.8 .8 .8];
    else
        StmStr = 'noise';
        fontcolor1 = [0 0 0];
        fontcolor2 = [.1 .1 .6];
    end
    
    text(.5,.7,{PROG.name PROG.date},'fontsize',14,'verticalalignment','top','horizontalalignment','center');
    text(.335,.50,'Frequency (Hz):','fontsize',12,'fontangle','normal','fontweight','normal','verticalalignment','top','horizontalalignment','left');
    text(.335,.45,'Attenuation (dB):','fontsize',12,'fontangle','normal','fontweight','normal','verticalalignment','top','horizontalalignment','left');
    text(.335,.40,'Channel:','fontsize',12,'fontangle','normal','fontweight','normal','verticalalignment','top','horizontalalignment','left');
    FIG.ax1.ParamHeader(1) = text(.335,.35,'Low Cutoff (Hz):','fontsize',12,'color',fontcolor1,'verticalalignment','top','horizontalalignment','left');
    FIG.ax1.ParamHeader(2) = text(.335,.30,'High Cutoff (Hz):','fontsize',12,'color',fontcolor1,'verticalalignment','top','horizontalalignment','left');
    text(.475,.195,'Change:','fontsize',14,'color',[.6 .1 .1],'verticalalignment','top','horizontalalignment','right');
    
    FIG.ax1.ParamData(1) = text(.675,.50,StmStr,                    'fontsize',12,'fontangle','italic','color',[.6 .1 .1],'verticalalignment','top','horizontalalignment','right','EraseMode','back','buttondownfcn','set_amp(''stimulus'',1);');
    FIG.ax1.ParamData(2) = text(.675,.45,num2str(Stimuli.atten),    'fontsize',12,'fontangle','italic','color',[.6 .1 .1],'verticalalignment','top','horizontalalignment','right','EraseMode','back','buttondownfcn','set_amp(''stimulus'',2);');
    FIG.ax1.ParamData(3) = text(.675,.40,num2str(Stimuli.chan),     'fontsize',12,'fontangle','italic','color',[.6 .1 .1],'verticalalignment','top','horizontalalignment','right','EraseMode','back','buttondownfcn','set_amp(''stimulus'',3);');
    FIG.ax1.ParamData(4) = text(.675,.35,num2str(Stimuli.low),      'fontsize',12,'fontangle','italic','color',fontcolor2,'verticalalignment','top','horizontalalignment','right','EraseMode','back','buttondownfcn','set_amp(''stimulus'',4);');
    FIG.ax1.ParamData(5) = text(.675,.30,num2str(Stimuli.high),     'fontsize',12,'fontangle','italic','color',fontcolor2,'verticalalignment','top','horizontalalignment','right','EraseMode','back','buttondownfcn','set_amp(''stimulus'',5);');
    
    FIG.ax1.ProgMess = text(.5,.575,'rms = 0','fontsize',14,'color',[.1 .1 .6],'verticalalignment','top','horizontalalignment','center');
    
    set(FIG.handle,'Userdata',struct('handles',FIG));
    set(FIG.handle,'Visible','on');
    drawnow;
    
    run_volts;
    delete(FIG.handle);
    
elseif strcmp(command_str,'stimulus');
    set(FIG.ax1.ParamData(param_num),'String',get(FIG.push.edit,'string'));
    set(FIG.push.save,'Userdata',1);
    switch param_num
    case 1,
        input = lower(get(FIG.push.edit,'string'));
        if input == '0' | input == 'n'
            Stimuli.freq_hz = 0;
            set(FIG.ax1.ParamData(1),'String','Noise');
            set(FIG.ax1.ParamData(4),'Color',[.6 .1 .1]);
            set(FIG.ax1.ParamData(5),'Color',[.6 .1 .1]);
            set(FIG.ax1.ParamHeader(1),'Color','k');
            set(FIG.ax1.ParamHeader(2),'Color','k');
        else
            Stimuli.freq_hz = str2num(input);
            set(FIG.ax1.ParamData(4),'Color',[.8 .8 .8]);
            set(FIG.ax1.ParamData(5),'Color',[.8 .8 .8]);
            set(FIG.ax1.ParamHeader(1),'Color',[.8 .8 .8]);
            set(FIG.ax1.ParamHeader(2),'Color',[.8 .8 .8]);
        end
    case 2,
        Stimuli.atten = str2num(get(FIG.push.edit,'string'));
        set(FIG.push.save,'Userdata',2);
    case 3,    
        Stimuli.chan = str2num(get(FIG.push.edit,'string'));
    case {4, 5}
        set(FIG.ax1.ParamData(4),'Color',[.6 .1 .1]);
        set(FIG.ax1.ParamData(5),'Color',[.6 .1 .1]);
        set(FIG.ax1.ParamHeader(1),'Color','k');
        set(FIG.ax1.ParamHeader(2),'Color','k');
        Stimuli.freq_hz = 0;
        set(FIG.ax1.ParamData(1),'String','Noise');
        if param_num == 4
            Stimuli.low = str2num(get(FIG.push.edit,'string'));
        elseif param_num == 5
            Stimuli.high = str2num(get(FIG.push.edit,'string'));
        end
    end
    set(FIG.push.edit,'String','');
    
elseif strcmp(command_str,'save');
    UpdateVolts(get(FIG.ax1.ProgMess,'String'));
    set(FIG.push.edit,'Userdata',1);
    
elseif strcmp(command_str,'close');
    set(FIG.push.edit,'Userdata',1);
end