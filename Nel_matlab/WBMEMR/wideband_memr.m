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
    PARAMS = zeros(1,18);				%initialize before opening parameter files
    PROG = 'DPOAErp2.m';						%program name is recorded in the data file
    DATE = date;
    
    if NelData.General.RP2_3and4 
        VERSION = 'NEL1';
    elseif NelData.General.RX8
        VERSION = 'NEL2';
    end
    
    MicGain = 40;
    
    MicGain = inputdlg('What is the microphone gain?','Mic Gain',1,{num2str(MicGain)});
    MicGain = str2double(MicGain{1});
    
    if (ishandle(h_fig))
        delete(h_fig);
    end
    
    colordef none;
    whitebg('w');
    
    h_fig = figure('NumberTitle','off','Name','Wideband Middle Ear Muscle Reflex','Units','normalized',...
    'Visible','on', 'position',[0.045  0.045  0.17  0.14],'MenuBar','none','Tag','WBMEMR_Main_Fig');
    
    eval('memrplot');
    
%     run_invCalib(true); % DPOAEs play 2 tones: easier to use raw-calib file with an allpass system;     
    
    handles = [h_push_stop, h_push_saveNquit, h_push_restart, h_push_abort];
    set(h_fig,'Userdata',handles);
    %save the workspace so you can return to this point on callback from other functions
%     feval('save',fullfile(root_dir,'DPOAE','workspace','dpoaebjm'),'PARAMS','PROG','VERSION');
%     set(h_fig,'Visible','on');
    

    wideband_memr('start'); % Auto start
    command_str = 'initialize'; %set command string to initialize graphic interface    
end

if ~strcmp(command_str,'initialize')
    handles = get(h_fig,'Userdata');
    h_push_stop = handles(1);
    h_push_saveNquit = handles(2);
    h_push_restart = handles(3);
    h_push_abort = handles(4);
end

if strcmp(command_str,'start')
    
    
    set(h_push_stop,'Enable','on');
    set(h_push_abort,'Enable','on');
    set(h_push_restart,'Enable','on');
    set(h_push_saveNquit,'Enable','off');
    
    error = 0;
    
      set(h_push_stop,'Userdata',[]);
%     set(h_push_start,'Userdata',dpoaedata);
    
    %****** Data collection loop ******
    %    eval('dpoae','nelerror(lasterr); msdl(0);');   %% 11/30/18: VM/MH/SP: why msdl(0) used??  cut out.
    eval('wbmemr_dummy','nelerror(lasterr);');
    
%     if strcmp(NelData.WBMEMR.rc,'restart')
        wideband_memr('start');
%     end
    
    
elseif strcmp(command_str,'stop')
    set(h_push_stop,'Userdata','stop');
    
elseif strcmp(command_str,'restart')
    set(h_push_stop,'Userdata','restart');
    
elseif strcmp(command_str,'abort')
    set(h_push_stop,'Userdata','abort');


end

