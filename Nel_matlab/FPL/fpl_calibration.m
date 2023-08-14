function h_fig = fpl_calibration(command_str)

%command_string: 'initialize','start','close'
%AS/MH 06/13/2023: From distortion_product.m, purposely stripped down just
%to get memr running, while maintaining GUI start/stop properties
%if you need more inspiration, see the DPOAE folder (distortion_product.m
%and dpoae.m)

global PARAMS PROG VERSION VOLTS
global root_dir NelData

% ud = get(handles.Nel_Main,'Userdata');
% change_fig_height(app, handles, -44);   use bigger #

h_fig = findobj('Tag','FPL_Main_Fig');    %% Finds handle for TC-Figure

if nargin<1
    
    disp('no command string!');
    PARAMS = zeros(1,18);				%initialize before opening parameter files
    
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

    h_fig = figure('NumberTitle','off','Name','FPL Calibration','Units','normalized',...
        'Visible','on', 'position',[0.045  0.045  0.17  0.14],'MenuBar','none',...
        'Tag','FPL_Main_Fig');
    
    % SH changed name to generalize
    eval('FPLplot');
    
    handles = [h_push_stop, h_push_saveNquit, h_push_restart, h_push_abort];
    set(h_fig,'Userdata',handles);
    %save the workspace so you can return to this point on callback from other functions
    %     feval('save',fullfile(root_dir,'DPOAE','workspace','dpoaebjm'),'PARAMS','PROG','VERSION');
    %     set(h_fig,'Visible','on');
    
    fpl_calibration('start'); % Auto start
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
    
    % Run to get stim params and choose which OAE type to use.
    FPL_type = questdlg('What type of Calibration:', 'Set Calib Type','Probe','Ear', 'Ear');
    switch FPL_type
        case 'Probe'
            addpath('C:\NEL\Nel_matlab\FPL\Probe');
            PROG = 'FPLprobe.m';
            FPLprobe;
            rmpath('C:\NEL\Nel_matlab\FPL\Probe');
        case 'Ear'
            addpath('C:\NEL\Nel_matlab\FPL\Ear');
            PROG = 'FPLear.m';	     % program name is recorded in the data file
            FPLear;
            rmpath('C:\NEL\Nel_matlab\FPL\Ear')
    end
    
    if strcmp(NelData.FPL.rc,'restart')
        fpl_calibration('start');
    else  % saveNquit, or abort - need to close fig, otherwise don't close
        fpl_calibration('close');
    end
    
elseif strcmp(command_str,'stop')
    set(h_push_stop,'Userdata','stop');
    
elseif strcmp(command_str,'restart')
    set(h_push_stop,'Userdata','restart');
    
elseif strcmp(command_str,'abort')
    set(h_push_stop,'Userdata','abort');
    
elseif strcmp(command_str, 'close')
    close('FPL Calibration');  % GUI (buttons)
    
% Close all figs except main GUI? 
    
elseif strcmp(command_str,'saveNquit')
    set(h_push_stop,'Userdata','saveNquit');
    
end

