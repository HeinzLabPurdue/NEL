function h_fig = wideband_memr(command_str)

%command_string: 'initialize','start','close'
%AS/MH 06/13/2023: From distortion_product.m, purposely stripped down just
%to get memr running, while maintaining GUI start/stop properties
%if you need more inspiration, see the DPOAE folder (distortion_product.m
%and dpoae.m)

global PARAMS PROG VERSION VOLTS
global root_dir NelData
%%             ud = get(handles.Nel_Main,'Userdata');
%% change_fig_height(app, handles, -44);   use bigger # 



h_fig = findobj('Tag','WBMEMR_Main_Fig');    %% Finds handle for TC-Figure

if nargin<1
    
    disp('no command string!');
    PARAMS = zeros(1,18);				%initialize before opening parameter files
    PROG = 'wbmemr.m';						%program name is recorded in the data file
    DATE = date;
    VOLTS = 5;   % NEL TDT is based on 5V peak as max voltage
    
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
    
    h_fig = figure('NumberTitle','off','Name','Wideband Middle Ear Muscle Reflex','Units','normalized',...
    'Visible','on', 'position',[0.045  0.045  0.17  0.14],'MenuBar','none','Tag','WBMEMR_Main_Fig');
    
    eval('memrplot');
    
    handles = [h_push_stop, h_push_saveNquit, h_push_restart, h_push_abort];
    set(h_fig,'Userdata',handles);
    %save the workspace so you can return to this point on callback from other functions
%     feval('save',fullfile(root_dir,'DPOAE','workspace','dpoaebjm'),'PARAMS','PROG','VERSION');
%     set(h_fig,'Visible','on');

    wideband_memr('start'); % Auto start
    command_str = 'initialize'; %set command string to initialize (not used anymore, but needs tobe non-empty to exit gracefully)
else
    handles = get(h_fig,'Userdata');
    h_push_stop = handles(1);
    h_push_saveNquit = handles(2);
    h_push_restart = handles(3);
    h_push_abort = handles(4);
    
    disp(command_str) % debugging
end

if strcmp(command_str,'start')
    
    set(h_push_stop,'Enable','off'); % Functionally unused, but userdata holds command stringss
    set(h_push_abort,'Enable','on');
    set(h_push_restart,'Enable','on');
    set(h_push_saveNquit,'Enable','on');
    
    error = 0;  % ? needed  
    
      set(h_push_stop,'Userdata',[]);
%     set(h_push_start,'Userdata',dpoaedata);
     wbmemr;
    
    if strcmp(NelData.WBMEMR.rc,'restart')
        wideband_memr('start');
    else  % saveNquit, or abort - need to close fig, otherwise don't close
        wideband_memr('close');
    end

elseif strcmp(command_str,'stop')
    set(h_push_stop,'Userdata','stop');
    
    
elseif strcmp(command_str,'restart')
    set(h_push_stop,'Userdata','restart');
    
elseif strcmp(command_str,'abort')
    set(h_push_stop,'Userdata','abort');
    
elseif strcmp(command_str, 'close')
    close('Wideband Middle Ear Muscle Reflex');  % MEMR GUI (buttons)
    
% % % %     %% close all figs, except GUI (?
% % % %     set(handleToYourMainGUI, 'HandleVisibility', 'off');
% % % %     close all;
% % % %     set(handleToYourMainGUI, 'HandleVisibility', 'on');

elseif strcmp(command_str,'saveNquit')
    set(h_push_stop,'Userdata','saveNquit');
    
end

