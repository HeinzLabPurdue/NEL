function h_fig = CAP(command_str)

% ge debug ABR 26Apr2004: replace "CAP" with more generalized nomenclature, throughout entire system.

global PROG FIG Stimuli CAP_Gating root_dir prog_dir NelData devices_names_vector Display
global data_dir RunThroughABRFlag CAP_interface_type

% h_fig = findobj('Tag','CAP_Main_Fig'); % SP on 22Sep19: Moved to after
% FIG is defined

if nargin < 1
    
    h_fig = findobj('Tag','CAP_Main_Fig'); %% Finds handle for CAP-Figure
    if ishandle(h_fig)
        delete(h_fig);
    end
    
    %     if length(h_fig)>2
    %         h_fig= h_fig(1);
    %     end
    
    
    prog_dir = [root_dir 'AEP\'];
    
    PROG = struct('name','CAP(v1.ge_mh.1).m');  % modified by GE 26Apr2004.
    
    %     push  = cell2struct(cell(1,4),{'close','x1','x10','x100'},2);
    push  = cell2struct(cell(1,6),{'run_levels','close','x1','x10','x100', 'forget_now'},2);
    %     radio = cell2struct(cell(1,8),{'noise','tone','khite','fast','slow','left','right','both'},2);
    % ge debug ABR 26Apr2004: need to add buttons to select between tone/noise/click
    radio = cell2struct(cell(1,5),{'fast','slow','left','right','both'},2);
    checkbox = cell2struct(cell(1,1), {'fixedPhase'},2);
    statText  = cell2struct(cell(1,2),{'memReps','status'},2);
    %     popup = cell2struct(cell(1,1),{'spike_channel'},2);   % added by GE 17Jan2003.
    fsldr = cell2struct(cell(1,4),{'slider','min','max','val'},2);
    asldr = cell2struct(cell(1,4),{'slider','min','max','val'},2);
    ax = cell2struct(cell(1,2),{'axis','line'},2);
    FIG   = struct('handle',[],'edit',[],'push',push,'radio',radio,'checkbox',checkbox,'statText', statText, 'fsldr',fsldr,'asldr',asldr,'NewStim',0,'ax',ax);
    %    FIG   = struct('handle',[],'edit',[],'push',push,'radio',radio,'fsldr',fsldr,'asldr',asldr,'NewStim',0,'ax',ax,'popup',popup, 'statText', statText);  % modified by GE 17Jan2003.
    
    
    h_fig = findobj('Tag','AEP_Main_Fig');    %% Finds handle for TC-Figure
    
    if length(h_fig)>2
        h_fig= h_fig(1);
    end
    
    CAP_ins;
    
    if strcmp(CAP_interface_type, 'CAP (fMask)') % for FD's special version. Freezes NEL right now 6/23/23 SH. Not closing right.
        fMaskCodesDir= [NelData.General.RootDir 'Nel_matlab\AEP\CAP\CAPfmasked'];
        cd(fMaskCodesDir);
        h_fig= fmaskedCAP();
        cd(root_dir);
        
    else
        FIG.handle = figure('NumberTitle','off','Name','CAP Interface','Units','normalized','position',[0.045  0.013  0.9502  0.7474],...
            'Visible','off','MenuBar','none','Tag','AEP_Main_Fig');
        
        colordef none;
        whitebg('w');
        
        CAP_loop_plot;
        CAP('invCalib'); % SH adding to be same as ABR
        CAP('clickYes'); % Start invCalib = true or false based on default clickYes value
        CAP_loop;
    end
    
    %% callback functions:
elseif strcmp(command_str,'fast')
    if get(FIG.radio.fast, 'value') == 1
        FIG.NewStim = 4;
        set(FIG.radio.slow,'value',0);
        CAP_Gating=Stimuli.fast;
        
        if Stimuli.clickYes == 1 %KH 09Jan2012
            CAP_Gating.duration_ms=Stimuli.clickLength_ms;
        end
        
    else
        set(FIG.radio.fast,'value',1);
    end
    
elseif strcmp(command_str,'slow')
    if get(FIG.radio.slow, 'value') == 1
        FIG.NewStim = 4;
        set(FIG.radio.fast,'value',0);
        CAP_Gating=Stimuli.slow;
        
        if Stimuli.clickYes == 1 %KH 09Jan2012
            CAP_Gating.duration_ms=Stimuli.clickLength_ms;
        end
        
    else
        set(FIG.radio.slow,'value',1);
    end
    
elseif strcmp(command_str,'left')
    if get(FIG.radio.left, 'value') == 1
        FIG.NewStim = 5;
        Stimuli.channel = 2;
        Stimuli.ear='left';
        set(FIG.radio.right,'value',0);
        set(FIG.radio.both,'value',0);
    else
        set(FIG.radio.left,'value',1);
    end
    
elseif strcmp(command_str,'right')
    if get(FIG.radio.right, 'value') == 1
        FIG.NewStim = 5;
        Stimuli.channel = 1;
        Stimuli.ear='right';
        set(FIG.radio.left,'value',0);
        set(FIG.radio.both,'value',0);
    else
        set(FIG.radio.right,'value',1);
    end
    
elseif strcmp(command_str,'both')
    if get(FIG.radio.both, 'value') == 1
        FIG.NewStim = 5;
        Stimuli.channel = 3;
        Stimuli.ear='both';
        set(FIG.radio.left,'value',0);
        set(FIG.radio.right,'value',0);
    else
        set(FIG.radio.both,'value',1);
    end
    
elseif strcmp(command_str,'slide_freq')
    FIG.NewStim = 6;
    Stimuli.freq_hz = floor(get(FIG.fsldr.slider,'value')*Stimuli.fmult);
    set(FIG.fsldr.val,'string',num2str(Stimuli.freq_hz));
    CAP('invCalib'); % SH added to match ABR 6/2023
    
    % LQ 01/31/05
elseif strcmp(command_str,'slide_freq_text')
    FIG.NewStim = 6;
    new_freq = str2num(get(FIG.fsldr.val, 'string'));
    if new_freq < get(FIG.fsldr.slider,'min')*Stimuli.fmult | ...
            new_freq > get(FIG.fsldr.slider,'max')*Stimuli.fmult
        set(FIG.fsldr.val,'string',num2str(Stimuli.freq_hz));
    else
        Stimuli.freq_hz = new_freq;
        set(FIG.fsldr.slider, 'value', Stimuli.freq_hz/Stimuli.fmult);
    end
    CAP('invCalib'); % SH added to match ABR 6/2023
    
elseif strcmp(command_str,'mult_1x')
    Stimuli.fmult = 1;
    set(FIG.push.x1,'foregroundcolor',[1 1 1]);
    set(FIG.push.x10,'foregroundcolor',[0 0 0]);
    set(FIG.push.x100,'foregroundcolor',[0 0 0]);
    FIG.NewStim = 6;
    Stimuli.freq_hz = floor(get(FIG.fsldr.slider,'value')*Stimuli.fmult);
    set(FIG.fsldr.val,'string',num2str(Stimuli.freq_hz));
    CAP('invCalib'); % SH added to match ABR 6/2023
    
elseif strcmp(command_str,'mult_10x')
    Stimuli.fmult = 10;
    set(FIG.push.x1,'foregroundcolor',[0 0 0]);
    set(FIG.push.x10,'foregroundcolor',[1 1 1]);
    set(FIG.push.x100,'foregroundcolor',[0 0 0]);
    FIG.NewStim = 6;
    Stimuli.freq_hz = floor(get(FIG.fsldr.slider,'value')*Stimuli.fmult);
    set(FIG.fsldr.val,'string',num2str(Stimuli.freq_hz));
    CAP('invCalib'); % SH added to match ABR 6/2023
    
elseif strcmp(command_str,'mult_100x')
    Stimuli.fmult = 100;
    set(FIG.push.x1,'foregroundcolor',[0 0 0]);
    set(FIG.push.x10,'foregroundcolor',[0 0 0]);
    set(FIG.push.x100,'foregroundcolor',[1 1 1]);
    FIG.NewStim = 6;
    Stimuli.freq_hz = floor(get(FIG.fsldr.slider,'value')*Stimuli.fmult);
    set(FIG.fsldr.val,'string',num2str(Stimuli.freq_hz));
    CAP('invCalib'); % SH added to match ABR 6/2023
    
elseif strcmp(command_str,'slide_atten')
    FIG.NewStim = 7;
    Stimuli.atten_dB = floor(-get(FIG.asldr.slider,'value'));
    set(FIG.asldr.val,'string',num2str(-Stimuli.atten_dB));
    set(FIG.asldr.SPL,'string',sprintf('%.1f dB SPL',Stimuli.MaxdBSPLCalib-Stimuli.atten_dB));
    
    % LQ 01/31/05
elseif strcmp(command_str, 'slide_atten_text')
    FIG.NewStim = 7;
    new_atten = get(FIG.asldr.val, 'string');
    if new_atten(1) ~= '-'
        new_atten = ['-' new_atten];
        set(FIG.asldr.val,'string', new_atten);
    end
    new_atten = str2num(new_atten);
    if new_atten < get(FIG.asldr.slider,'min') | new_atten > get(FIG.asldr.slider,'max')
        set( FIG.asldr.val, 'string', num2str(-Stimuli.atten_dB));
    else
        Stimuli.atten_dB = -new_atten;
        set(FIG.asldr.slider, 'value', new_atten);
    end
    set(FIG.asldr.SPL,'string',sprintf('%.1f dB SPL',Stimuli.MaxdBSPLCalib-Stimuli.atten_dB));
    
    
elseif strcmp(command_str,'memReps')
    FIG.NewStim = 9;
    oldMemReps = Stimuli.CAPmem_reps;
    Stimuli.CAPmem_reps = str2num(get(FIG.edit.memReps,'string'));
    if (isempty(Stimuli.CAPmem_reps))  % check is empty
        Stimuli.CAPmem_reps = oldMemReps;
    elseif ( Stimuli.CAPmem_reps<0 )  % check range
        Stimuli.CAPmem_reps = oldMemReps;
    end
    set(FIG.edit.memReps,'string', num2str(Stimuli.CAPmem_reps));
    
    
elseif strcmp(command_str,'threshV')   %KH 2011 Jun 08, for artifact rejection
    FIG.NewStim = 13;
    oldThreshV = Stimuli.threshV;
    Stimuli.threshV = str2num(get(FIG.edit.threshV,'string'));
    if (isempty(Stimuli.threshV))  % check is empty
        Stimuli.threshV = oldThreshV;
    elseif ( Stimuli.threshV<0 )  % check range
        Stimuli.threshV = oldThreshV;
    end
    set(FIG.edit.threshV,'string', num2str(Stimuli.threshV));
    
elseif strcmp(command_str,'fixedPhase')
    Stimuli.fixedPhase = get(FIG.checkbox.fixedPhase,'value');
    %      Stimuli.fixedPhase = str2num(get(FIG.checkbox.fixedPhase,'value'));
    FIG.NewStim = 8;
    
elseif strcmp(command_str,'run_levels')
    FIG.NewStim = 10;
    if (strcmp(get(FIG.push.run_levels,'string'), 'Abort'))  % In Run-levels mode, go back to free-run
        set(FIG.push.run_levels,'Userdata','abort');  % so that "CAP_loop" knows an abort was requested.
        set(FIG.push.close,'Enable','on');
        set(FIG.push.forget_now,'Enable','on');
    else
        set(FIG.push.close,'Enable','off');
        set(FIG.push.forget_now,'Enable','off');
    end
    
elseif strcmp(command_str,'forget_now')
    FIG.NewStim = 11;
    
elseif strcmp(command_str,'Gain')
    %     FIG.NewStim = 12;
    oldGain = Display.Gain;
    Display.Gain = str2num(get(FIG.edit.gain,'string'));
    if (isempty(Display.Gain))  % check is empty
        Display.Gain = oldGain;
    elseif (Display.Gain<0)  % check range
        Display.Gain = oldGain;
    end
    set(FIG.edit.gain,'string', num2str(Display.Gain));
    
elseif strcmp(command_str,'atAD')
    if get(FIG.radio.atAD, 'value') == 1
        FIG.NewStim = 12;
        Display.Voltage = 'atAD';
        set(FIG.radio.atELEC,'value',0);
    else
        set(FIG.radio.atAD,'value',1);
    end
    
elseif strcmp(command_str,'atELEC')
    if get(FIG.radio.atELEC, 'value') == 1
        FIG.NewStim = 12;
        Display.Voltage = 'atELEC';
        set(FIG.radio.atAD,'value',0);
    else
        set(FIG.radio.atELEC,'value',1);
    end
    
elseif strcmp(command_str,'YLim')
    FIG.NewStim = 12;
    oldYLim = Display.YLim_atAD;
    Display.YLim_atAD = str2num(get(FIG.edit.yscale,'string'));
    if (isempty(Display.YLim_atAD))  % check is empty
        Display.YLim_atAD = oldYLim;
    elseif (Display.YLim_atAD<0)  % check range
        Display.YLim_atAD = oldYLim;
    end
    set(FIG.edit.yscale,'string', num2str(Display.YLim_atAD));
    
elseif strcmp(command_str,'audiogram') %KH 10Jan2012
    FIG.NewStim = 15;
    if (strcmp(get(FIG.push.run_levels,'string'), 'Abort'))  % In Run-levels mode, go back to free-run
        set(FIG.push.run_levels,'Userdata','abort');  % so that "CAP_loop" knows an abort was requested.
        set(FIG.push.close,'Enable','on');
        set(FIG.push.forget_now,'Enable','on');
    else
        set(FIG.push.close,'Enable','off');
        set(FIG.push.forget_now,'Enable','off');
    end
    
elseif strcmp(command_str,'clickYes') %KH 10Jan2012
    Stimuli.clickYes = get(FIG.radio.clickYes,'value');
    FIG.NewStim = 16;
    if NelData.General.RP2_3and4 && (~NelData.General.RX8)
        if Stimuli.clickYes
            run_invCalib(true); % Initialize with allpass RP2_3
        else
            run_invCalib(false); % Initialize with allpass RP2_3
        end
    end
    
elseif strcmp(command_str,'invCalib') %SP 24Jan2016 % SH copied from ABR
    %%% Needs to be called whenever the frequency is changed!!!
    %% ?SP? Should the whole thing be called everytime the frequency is changed or should it be saved?
    
    %%% Account for Calibration to set Level in dB SPL
    
    %     if ~exist('CalibData', 'var')
    if NelData.General.RP2_3and4 && (~NelData.General.RX8)
        [~, Stimuli.calibPicNum]= run_invCalib(get(FIG.radio.invCalib,'value'));
    elseif isnan(Stimuli.calibPicNum)
        cdd;
        allCalibFiles= dir('*calib*raw*');
        Stimuli.calibPicNum= getPicNum(allCalibFiles(end).name);
        Stimuli.calibPicNum= str2double(inputdlg('Enter Calibration File Number','Load Calib File', 1,{num2str(Stimuli.calibPicNum)}));
        rdd;
    end
    
    cdd;
    x=loadpic(Stimuli.calibPicNum);
    CalibData=x.CalibData(:,1:2);
    CalibData(:,2)=trifilt(CalibData(:,2)',5)';
    rdd;
    
    Stimuli.MaxdBSPLCalib=CalibInterp(Stimuli.freq_hz/1000, CalibData);
    set(FIG.asldr.SPL, 'string', sprintf('%.1f dB SPL', Stimuli.MaxdBSPLCalib-Stimuli.atten_dB));
    
    
    
elseif strcmp(command_str,'close')
    if NelData.General.RP2_3and4 && (~NelData.General.RX8)
        run_invCalib(false); % Initialize with allpass RP2_3
    end
    set(FIG.push.close,'Userdata',1);
end

