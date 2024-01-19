
function h_fig = distortion_product(command_str)

%THE FOLLOWING GLOBAL PARAMETERS ARE SHARED ACROSS FUNCTIONS

global PARAMS PROG VERSION VOLTS
global root_dir NelData raw_pic_file

h_fig = findobj('Tag','DPOAE_Main_Fig');    %% Finds handle for TC-Figure

if nargin < 1						   %program should be called without a command string
    
    if strcmp(computer,'PCWIN')	%set path characters for PC or MAC
        is_enabled = 'on';
    elseif strcmp(computer,'MAC2')
        is_enabled = 'off';
    end
    
    is_enabled = 'on';
    
    PARAMS = zeros(1,18);				%initialize before opening parameter files
    PROG = 'DPOAErp2.m';						%program name is recorded in the data file
    DATE = date;
    VERSION = 'Nel';
    eval('get_dpoae_ins');							   %open stimulus parameters
    
    % Allow user to override default mic pre-amp gain
    MicGain = inputdlg('What is the microphone gain?','Mic Gain',1,{num2str(MicGain)});
    MicGain = str2double(MicGain{1});
    
    
    PARAMS(1) = F2frqlo;   % low frequency (in kHz) bounds for data
    PARAMS(2) = F2frqhi;   % high frequency (in kHz) bounds for data
    PARAMS(3) = fstlin;    % # of linear frequency steps (set = 0 for log steps)
    PARAMS(4) = fstoct;    % # of log freq. steps (per oct. OR per 10-dB BW for Qspaced) (= 0 for lin steps; NEGATIVE for Qspaced)
    PARAMS(5) = ear;       % ear code (lft = 1, rgt = 2, both = 3
    PARAMS(6) = ToneOn;    % duration of tone presentation (ms)
    PARAMS(7) = ToneOff;   % duration of interstim interval (ms)
    PARAMS(8) = Fratio;    % ratio of F2/F1
    PARAMS(9) = ADdur;     % Duration to sample the microphone (add 20ms to allow for delays)
    PARAMS(10)= Nreps;     % Number of reps per condition
    PARAMS(11)= CalibSPL;  % nominative dB SPL corresponding to 0 dB attenuation for ER2
    PARAMS(12)= L2_dBSPL;  % dB SPL presentation level for F2
    PARAMS(13)= L1_dBSPL;  % dB SPL presentation level for F1 (ref from Janssen et al/Kummer et al.)
    PARAMS(14)= MicGain;   % dB gain on microphone signal path
    
    command_str = 'initialize';		%set command string to initialize graphic interface
end

if ~strcmp(command_str,'initialize')		%you're returning via callback, retrieve figure handles
    load(fullfile(root_dir,'DPOAE','workspace','dpoaebjm'));
    handles = get(h_fig,'Userdata');
    h_text1 = handles(1);
    h_text2 = handles(2);
    h_text3 = handles(3);
    h_text4 = handles(4);
    h_text5 = handles(5);
    h_text6 = handles(6);
    h_text7 = handles(7);
    h_ax1   = handles(8);
    h_line1 = handles(9);
    h_ax2   = handles(10);
    h_ax3   = handles(11);
    h_push_stop  = handles(12);
    h_push_start = handles(13);
%     
%     h_push_close = handles(14);
%     h_push_params = handles(15);
%     h_push_saveNquit = handles(16);
%     h_push_restart = handles(17);
%     h_push_abort = handles(18);
%     h_text3b = handles(19);
%     h_text4b = handles(20);
%     h_text5b = handles(21);
%     h_text6b = handles(22);
    
    %removed close button (AS/MH)
    h_push_params = handles(14);
    h_push_saveNquit = handles(15);
    h_push_restart = handles(16);
    h_push_abort = handles(17);
    h_text3b = handles(18);
    h_text4b = handles(19);
    h_text5b = handles(20);
    h_text6b = handles(21);
    
    dpoaedata= get(h_push_start,'Userdata');
    
    %AS/MP calibration done in dpoae.m
%     if NelData.General.RP2_3and4 || NelData.General.RX8 % if NEL1 || NEL2
% %         run_invCalib(false); % DPOAEs play 2 tones: easier to use raw-calib file with an allpass system; % SP on 22Sep19
%         filttype = {'inversefilt','inversefilt'};
%         invfiltdata = set_invFilter(filttype
%         
%     end
    % This means: need to use the last raw calib file
end

if strcmp(command_str,'initialize')		   %initialize and display GUI
    if (ishandle(h_fig))
        delete(h_fig);
    end
    h_fig = figure('NumberTitle','off','Name','Distortion Product Otoacoustic Emissions','Units','normalized',...
        'Visible','off', 'position',[0.045  0.045  0.9502  0.7474],'MenuBar','none','Tag','DPOAE_Main_Fig');
    colordef none;
    whitebg('w');
    
    %the following text handles are used to display parameters
    if PARAMS(4) == 0
        log_txt = 'no';
    elseif PARAMS(4) > 0
        log_txt = 'yes';
    else
        log_txt = 'Q';   % Qsteps: saved in log steps as Negative Value
    end
    
    step_txt = max(PARAMS(3), abs(PARAMS(4)));
    
    switch PARAMS(5)
        case 1
            ear_txt = 'left';
        case 2
            ear_txt = 'right';
        case 3
            ear_txt = 'both';
    end
    
    eval('dpoaeplot');
    
    % put everything in a handle for the call back
%     handles = [h_text1, h_text2, h_text3, h_text4, h_text5, h_text6, h_text7, h_ax1, h_line1, h_ax2, h_ax3, ...
%         h_push_stop, h_push_start, h_push_close, h_push_params, h_push_saveNquit, h_push_restart, h_push_abort, ...
%         h_text3b, h_text4b, h_text5b, h_text6b];

    handles = [h_text1, h_text2, h_text3, h_text4, h_text5, h_text6, h_text7, h_ax1, h_line1, h_ax2, h_ax3, ...
        h_push_stop, h_push_start, h_push_params, h_push_saveNquit, h_push_restart, h_push_abort, ...
        h_text3b, h_text4b, h_text5b, h_text6b];
    set(h_fig,'Userdata',handles);
    %save the workspace so you can return to this point on callback from other functions
    feval('save',fullfile(root_dir,'DPOAE','workspace','dpoaebjm'),'PARAMS','PROG','VERSION');
    set(h_fig,'Visible','on');
    distortion_product('start'); % Auto start
    
elseif strcmp(command_str,'return from parameter change')
    
    if PARAMS(4) == 0
        log_txt = 'no';
    elseif PARAMS(4) > 0
        log_txt = 'yes';
    else
        log_txt = 'Q';
    end
    
    step_txt = max(PARAMS(3), abs(PARAMS(4)));
    
    switch PARAMS(5)
        case 1
            ear_txt = 'left';
        case 2
            ear_txt = 'right';
        case 3
            ear_txt = 'both';
    end
    
    set(h_text2,'String',{PROG date fliplr(strtok(fliplr(current_data_file),filesep))});
    set(h_text4,'string', {PARAMS(1); PARAMS(2)});
    set(h_text4b,'string', {step_txt; ''; log_txt});
    set(h_text6,'string', {PARAMS(10); PARAMS(12)});
    set(h_text6b,'string', {PARAMS(13); ear_txt});
    set(h_push_saveNquit,'Enable','off');
    %set(h_push_close,'Enable','on');
    set(h_push_params,'Enable','on');
    
elseif strcmp(command_str,'start')
    if(isfield(NelData,'DPOAE'))
        distortion_product('return from parameter change');  % This is a RESTART: Reset param list
    end
    set(h_text1,'Visible','off');
    set(h_text2,'Visible','off');
    set(h_push_stop,'Enable','on');
    set(h_push_abort,'Enable','on');
    set(h_push_restart,'Enable','on');
    set(h_push_start,'Enable','off');
    set(h_push_saveNquit,'Enable','off');
    %set(h_push_close,'Enable','off');
    set(h_push_params,'Enable','off');
    set(h_text3,'buttondownfcn','distortion_product(''change_levels/freqs'');');
    set(h_text4,'buttondownfcn','distortion_product(''change_levels/freqs'');');
    set(h_text5,'buttondownfcn','distortion_product(''change_levels/freqs'');');
    set(h_text6,'buttondownfcn','distortion_product(''change_levels/freqs'');');
    
    error = 0;
    
    if PARAMS(3) > 0
        F2frqlst=logspace(log10(PARAMS(1)),log10(PARAMS(2)),log2(PARAMS(2)/PARAMS(1))*PARAMS(4));
    elseif PARAMS(3) < 0
        F2frqlst=Qspace(PARAMS(1),PARAMS(2),-PARAMS(4));
    else
        F2frqlst=linspace(PARAMS(1),PARAMS(2),log2(PARAMS(2)/PARAMS(1))*PARAMS(4));
    end
    frqnum = length(F2frqlst);
    dpoaedata = zeros(frqnum,4);
    
    set(h_push_stop,'Userdata',[]);
    set(h_push_start,'Userdata',dpoaedata);
    
    %****** Data collection loop ******
    %    eval('dpoae','nelerror(lasterr); msdl(0);');   %% 11/30/18: VM/MH/SP: why msdl(0) used??  cut out.
    eval('dpoae','nelerror(lasterr);');
    if strcmp(NelData.DPOAE.rc,'restart')
        distortion_product('start');
    end
    
    
elseif strcmp(command_str,'stop')
    set(h_push_stop,'Userdata','stop');
    
elseif strcmp(command_str,'restart')
    set(h_push_stop,'Userdata','restart');
    
elseif strcmp(command_str,'abort')
    set(h_push_stop,'Userdata','abort');
    
elseif strcmp(command_str,'params')
    set(h_push_stop,'Userdata','params');
    
elseif strcmp(command_str,'change_levels/freqs')
    set(h_push_stop,'Userdata','change_levels/freqs');
    
elseif strcmp(command_str,'saveNquit')
    set(h_push_stop,'Userdata','saveNquit');
    
elseif strcmp(command_str,'close')
    if NelData.General.RP2_3and4 || NelData.General.RX8
%         run_invCalib(false);
        filttype = {'allpass','allpass'};
        dummy = set_invFilter(filttype,raw_pic_file);
    end
    close('Distortion Product Otoacoustic Emissions');
end
