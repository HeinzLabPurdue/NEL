function h_fig = wideband_memr(command_str)

%command_string: 'initialize','start','close'
%AS/MH 06/13/2023: From distortion_product.m, purposely stripped down just
%to get memr running, while maintaining GUI start/stop properties
%if you need more inspiration, see the DPOAE folder (distortion_product.m
%and dpoae.m)

global PARAMS PROG VERSION VOLTS
global root_dir NelData


h_fig = findobj('Tag','WBMEMR_Main_Fig');    %% Finds handle for TC-Figure

if nargin<1
    disp('no command string!');
    PARAMS = zeros(1,18);				%initialize before opening parameter files
    PROG = 'wbmemr.m';						%program name is recorded in the data file
    DATE = date;
    
    if NelData.General.RP2_3and4 
        VERSION = 'NEL1';
    elseif NelData.General.RX8
        VERSION = 'NEL2';
    end
    
    %this starts the initialize process similar to that in
    %distortion_product.m
    
    if (ishandle(h_fig))
        delete(h_fig);
    end
    
    colordef none;
    whitebg('w');
    
    h_fig = figure('NumberTitle','off','Name','Wideband Middle Ear Muscle Reflex','Units','normalized',...
    'Visible','on', 'position',[0.045  0.045  0.17  0.14],'MenuBar','none','Tag','WBMEMR_Main_Fig');
    
    eval('memrplot');
    
    handles = [h_push_stop, h_push_saveNquit, h_push_restart, h_push_abort];
    set(h_fig,'Userdata',handles);
    %save the workspace so you can return to this point on callback from other functions
%     feval('save',fullfile(root_dir,'DPOAE','workspace','dpoaebjm'),'PARAMS','PROG','VERSION');
%     set(h_fig,'Visible','on');

    wideband_memr('start'); % Auto start
    command_str = 'initialize'; %set command string to initialize graphic interface    
else
    handles = get(h_fig,'Userdata');
    h_push_stop = handles(1);
    h_push_saveNquit = handles(2);
    h_push_restart = handles(3);
    h_push_abort = handles(4);
    
    disp(command_str)
end

if strcmp(command_str,'start')
    
    set(h_push_stop,'Enable','off'); %Functionally unused, but userdata holds command stringss
    set(h_push_abort,'Enable','on');
    set(h_push_restart,'Enable','on');
    set(h_push_saveNquit,'Enable','on');
    
    error = 0;
    
      set(h_push_stop,'Userdata',[]);
%     set(h_push_start,'Userdata',dpoaedata);
     wbmemr;
    
    if strcmp(NelData.WBMEMR.rc,'restart')
        wideband_memr('start');
    end    
    wideband_memr('close');

elseif strcmp(command_str,'stop')
    set(h_push_stop,'Userdata','stop');
    
    
elseif strcmp(command_str,'restart')
    set(h_push_stop,'Userdata','restart');
    
elseif strcmp(command_str,'abort')
    set(h_push_stop,'Userdata','abort');
    
elseif strcmp(command_str, 'close')
%     if NelData.General.RP2_3and4 || NelData.General.RX8
%         run_invCalib(false);
%     end
    close('Wideband Middle Ear Muscle Reflex');

elseif strcmp(command_str,'saveNquit')
    set(h_push_stop,'Userdata','saveNquit');
    
end

