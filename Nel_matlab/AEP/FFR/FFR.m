function h_fig = FFR(command_str)

% ge debug ABR 26Apr2004: replace "FFR" with more generalized nomenclature, throughout entire system.

%% Calib not happening in this FFR script 7/19/23

global PROG FIG Stimuli FFR_Gating root_dir prog_dir NelData devices_names_vector Display
global data_dir
% global fc fm pol dur
prog_dir = [root_dir 'AEP\FFR\']; %Changed from FFR to AEP\FFR, VMA (7/17/23)

% fm = 200;
% fc = 20;
% dur = 1;
% pol = 1;
% amtone(fc,fm,dur,pol);

h_fig = findobj('Tag','FFR_Main_Fig');    %% Finds handle for TC-Figure

if nargin < 1
    
    
    PROG = struct('name','FFR(v1.ge_mh.1).m');  % modified by GE 26Apr2004.
    
    radio = cell2struct(cell(1,5),{'fast','slow','left','right','both'},2);
    checkbox = cell2struct(cell(1,1), {'fixedPhase'},2);
    statText  = cell2struct(cell(1,2),{'memReps','status'},2);
    
    %     push  = cell2struct(cell(1,4),{'close','x1','x10','x100'},2);
    %     push  = cell2struct(cell(1,6),{'run_levels','close','x1','x10','x100', 'forget_now'},2);
    %     radio = cell2struct(cell(1,8),{'noise','tone','khite','fast','slow','left','right','both'},2);
    %     ge debug ABR 26Apr2004: need to add buttons to select between tone/noise/click
    %     popup = cell2struct(cell(1,1),{'spike_channel'},2);   % added by GE 17Jan2003.
    %     fsldr = cell2struct(cell(1,4),{'popupmenu','min','max','val'},2);
    %     fsldr = cell2struct(
    %     wavfle = cell2struct(cell(1,3),{'popup','in','wavfile'},2);
    
    wavfile = cell2struct(cell(1,1),{'func'},2);
    push = cell2struct(cell(1,1),{'amtone'},2);
    
    asldr = cell2struct(cell(1,4),{'slider','min','max','val'},2);
    ax = cell2struct(cell(1,2),{'axis','line'},2);
    
    FIG   = struct('handle',[],'edit',[],'push',push,'radio',radio,'checkbox',checkbox,'statText', statText,'wavfile',wavfile,'asldr',asldr,'NewStim',0,'ax',ax);
    
    FFR_ins;
    
    FIG.handle = figure('NumberTitle','off','Name','FFR Interface','Units','normalized','position',[0.045  0.013  0.9502  0.7474],'Visible','off','MenuBar','none','Tag','FFR_Main_Fig');
    set(FIG.handle,'CloseRequestFcn','FFR(''close'');')
    
    colordef none;
    whitebg('w');
    
    FFR_loop_plot;
    FFR('amtone');
    FFR_loop;
    
    
    %  elseif strcmp(command_str,'tone')
    %      FIG.NewStim = 1;
    %      Stimuli.KHosc = 0;
    %      set(FIG.fsldr.val,'string',num2str(Stimuli.freq_hz));
    %     set(FIG.radio.khite,'value',0);
    %      set(FIG.radio.noise,'value',0);
    %
    %  elseif strcmp(command_str,'noise')
    %      FIG.NewStim = 2;
    %      Stimuli.KHosc = 0;
    %      set(FIG.fsldr.val,'string','noise');
    %      set(FIG.radio.khite,'value',0);
    %      set(FIG.radio.tone,'value',0);
    %
    %  elseif strcmp(command_str,'khite')
    %      FIG.NewStim = 3;
    %      Stimuli.KHosc = 2;
    %      set(FIG.fsldr.val,'string','Osc');
    %      set(FIG.radio.tone,'value',0);
    % %         set(FIG.radio.noise,'value',0);
    
    % AM tone generator using function amtone, and copies file over to
    % default location - zz 31oct11
elseif strcmp(command_str,'fmtone') %%% added by Dave Axe 9/7/16
    FIG.NewStim = 6;
    
    prompt  = {'Enter the modulation frequency (frequency of modulator in Hz)',...
        'Enter the carrier frequency (Hz)',...
        'Polarized? (0 = no, 1 = yes)',...
        'Modulation range (FN sweep range in Hz)'};
    title   =  'FM Tone Generator';
    lines = 1;
    def     = {num2str(Stimuli.fm),num2str(Stimuli.fc),num2str(Stimuli.pol),num2str(Stimuli.mod)};
    %    def     = {num2str(Stimuli.fm),num2str(Stimuli.fc),num2str(FFR_Gating.duration_ms/1000),num2str(Stimuli.pol)};
    answer  = inputdlg(prompt,title,lines,def);
    
    Stimuli.fm = str2num(cell2str(answer(1)));
    Stimuli.fc = str2num(cell2str(answer(2)));
    Stimuli.pol = str2num(cell2str(answer(3)));
    %    FFR_Gating.duration_ms = str2num(cell2str(answer(4)));
    Stimuli.mod = str2num(cell2str(answer(4)));
    
    
    [Stimuli.filename, fn_inv]=make_FM_tone(Stimuli.fc,Stimuli.RPsamprate_Hz,FFR_Gating.duration_ms/1000,5e-3,60,Stimuli.fm,Stimuli.mod,Stimuli.pol);
    %    [Stimuli.filename, fn_inv] = amtoneFFR(Stimuli.fc,Stimuli.fm,FFR_Gating.duration_ms/1000,Stimuli.pol,Stimuli.mod,Stimuli.RPsamprate_Hz);
    set(FIG.wavfile.func,'string',Stimuli.filename);
    copyfile(Stimuli.filename, [NelData.General.RootDir 'Nel_matlab\AEP\FFR\Signals\AMwav\tone_org.wav'],'f');
    copyfile(fn_inv, [NelData.General.RootDir 'Nel_matlab\AEP\FFR\Signals\AMwav\tone_inv.wav'],'f');
    
    
    % WAV file loader, copies file from original location to default locaton
    % zz 31oct11
    
elseif strcmp(command_str,'amtone')
    FIG.NewStim = 6;
    
    prompt  = {'Enter the modulation frequency (Hz)',...
        'Enter the carrier frequency (Hz)',...
        'Polarized? (0 = no, 1 = yes)',...
        'Modulation Depth (0-1)'};
    title   =  'AM Tone Generator';
    lines = 1;
    def     = {num2str(Stimuli.fm),num2str(Stimuli.fc),num2str(Stimuli.pol),num2str(Stimuli.mod)};
    %    def     = {num2str(Stimuli.fm),num2str(Stimuli.fc),num2str(FFR_Gating.duration_ms/1000),num2str(Stimuli.pol)};
    answer  = inputdlg(prompt,title,lines,def);
    
    Stimuli.fm = str2num(cell2str(answer(1)));
    Stimuli.fc = str2num(cell2str(answer(2)));
    Stimuli.pol = str2num(cell2str(answer(3)));
    Stimuli.mod = str2num(cell2str(answer(4)));
    
    
    % 12/7/11: MH&KH: changed to pass Sampling rate as param - defined once in FFR_ins - needs to match RPvds code
    [Stimuli.filename, fn_inv] = make_amtoneFFR(Stimuli.fc,Stimuli.fm,FFR_Gating.duration_ms/1000,Stimuli.pol,Stimuli.mod,Stimuli.RPsamprate_Hz);
    set(FIG.wavfile.func,'string',Stimuli.filename);
    copyfile(Stimuli.filename, [NelData.General.RootDir 'Nel_matlab\AEP\FFR\Signals\AMwav\tone_org.wav'],'f');
    copyfile(fn_inv, [NelData.General.RootDir 'Nel_matlab\AEP\FFR\Signals\AMwav\tone_inv.wav'],'f');
    
    
    % WAV file loader, copies file from original location to default locaton
    % zz 31oct11
elseif strcmp(command_str,'logSwept_amtone')
    FIG.NewStim = 6;
    
    prompt  = {'Enter the minimum modulation frequency (Hz)',...
        'Enter the carrier frequency (Hz)',...
        'Polarized? (0 = no, 1 = yes)',...
        'Modulation Depth (0-1)'};
    title   =  'AM Tone Generator';
    lines = 1;
    def     = {num2str(Stimuli.fm),num2str(Stimuli.fc),num2str(Stimuli.pol),num2str(Stimuli.mod)};
    %    def     = {num2str(Stimuli.fm),num2str(Stimuli.fc),num2str(FFR_Gating.duration_ms/1000),num2str(Stimuli.pol)};
    answer  = inputdlg(prompt,title,lines,def);
    
    Stimuli.fm = str2num(cell2str(answer(1)));
    Stimuli.fc = str2num(cell2str(answer(2)));
    Stimuli.pol = str2num(cell2str(answer(3)));
    Stimuli.mod = str2num(cell2str(answer(4)));
    
    
    % 12/7/11: MH&KH: changed to pass Sampling rate as param - defined once in FFR_ins - needs to match RPvds code
    [Stimuli.filename, fn_inv] = make_logSwept_amtoneFFR(Stimuli.fc,Stimuli.fm,FFR_Gating.duration_ms/1000,Stimuli.pol,Stimuli.mod,Stimuli.RPsamprate_Hz);
    set(FIG.wavfile.func,'string',Stimuli.filename);
    copyfile(Stimuli.filename, [NelData.General.RootDir 'Nel_matlab\AEP\FFR\Signals\AMwav\tone_org.wav'],'f');
    copyfile(fn_inv,[NelData.General.RootDir 'Nel_matlab\AEP\FFR\Signals\AMwav\tone_inv.wav'],'f');
    
    
    % WAV file loader, copies file from original location to default locaton
    % zz 31oct11
elseif strcmp(command_str,'wavfile')
    FIG.NewStim = 6;
    
    name = get(FIG.wavfile.func, 'string')
    cellname = cellstr(name);
    Stimuli.filename = cell2str(cellname);
    
    % copies file to both "original" and "polarized" locations
    copyfile(Stimuli.filename, [NelData.General.RootDir 'Nel_matlab\AEP\FFR\Signals\AMwav\tone_org.wav'],'f');
    copyfile(Stimuli.filename, [NelData.General.RootDir 'Nel_matlab\AEP\FFR\Signals\AMwav\tone_inv.wav'],'f');
    
    
elseif strcmp(command_str,'fast')
    if get(FIG.radio.fast, 'value') == 1
        FIG.NewStim = 4;
        set(FIG.radio.slow,'value',0);
        FFR_Gating=Stimuli.fast;
    else
        set(FIG.radio.fast,'value',1);
    end
    
elseif strcmp(command_str,'slow')
    if get(FIG.radio.slow, 'value') == 1
        FIG.NewStim = 4;
        set(FIG.radio.fast,'value',0);
        FFR_Gating=Stimuli.slow;
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
    
elseif strcmp(command_str,'slide_atten')
    FIG.NewStim = 7;
    Stimuli.atten_dB = floor(-get(FIG.asldr.slider,'value'));
    set(FIG.asldr.val,'string',num2str(-Stimuli.atten_dB));
    
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
    
    % zz 7feb12
elseif strcmp(command_str,'noise_atten')
    FIG.NewStim = 13;
    Stimuli.noiseLevel = floor(get(FIG.nsldr.slider,'value'));
    set(FIG.nsldr.val,'string',num2str(-Stimuli.noiseLevel));
    
    % zz 7feb12
elseif strcmp(command_str, 'noise_atten_text')
    FIG.NewStim = 13;
    new_atten = get(FIG.nsldr.val, 'string');
    if new_atten(1) ~= '-'
        new_atten = [new_atten];
        set(FIG.nsldr.val,'string', new_atten);
    end
    new_atten = str2num(new_atten);
    if new_atten < get(FIG.nsldr.slider,'min') || new_atten > get(FIG.nsldr.slider,'max')
        set( FIG.nsldr.val, 'string', num2str(-Stimuli.noiseLevel));
    else
        Stimuli.noiseLevel = new_atten;
        set(FIG.nsldr.slider, 'value', new_atten);
    end
    
elseif strcmp(command_str, 'noNoise')
    FIG.NewStim = 14;
    Stimuli.noNoise = get(FIG.checkbox.noNoise,'value');
    %Stimuli.noNoise = str2num(get(FIG.checkbox.noNoise,'value'));
    
elseif strcmp(command_str,'memReps')
    FIG.NewStim = 9;
    oldMemReps = Stimuli.FFRmem_reps;
    Stimuli.FFRmem_reps = str2num(get(FIG.edit.memReps,'string'));
    if (isempty(Stimuli.FFRmem_reps))  % check is empty
        Stimuli.FFRmem_reps = oldMemReps;
    elseif ( Stimuli.FFRmem_reps<0 )  % check range
        Stimuli.FFRmem_reps = oldMemReps;
    end
    
    set(FIG.edit.memReps,'string', num2str(Stimuli.FFRmem_reps));
    
    %KHZZ 2011 Nov 4
elseif strcmp(command_str,'threshV')
    FIG.NewStim = 13;
    oldThreshV = Stimuli.threshV;
    Stimuli.threshV = str2num(get(FIG.edit.threshV,'string'));
    if (isempty(Stimuli.threshV))  % check is empty
        Stimuli.threshV = oldThreshV;
    elseif ( Stimuli.threshV<0 )  % check range
        Stimuli.threshV = oldThreshV;
    end
    set(FIG.edit.threshV,'string', num2str(Stimuli.threshV));
    set(FIG.ax.line4,'YData',[Stimuli.threshV Stimuli.threshV]);
    
    % No need for fixed phase checkbox;
    % removed by zz 31oct11
    
    %elseif strcmp(command_str,'fixedPhase')
    %   Stimuli.fixedPhase = get(FIG.checkbox.fixedPhase,'value');
    %      Stimuli.fixedPhase = str2num(get(FIG.checkbox.fixedPhase,'value'));
    %   FIG.NewStim = 8;
    
elseif strcmp(command_str,'run_levels')
    FIG.NewStim = 10;
    if (strcmp(get(FIG.push.run_levels,'string'), 'Abort'))  % In Run-levels mode, go back to free-run
        set(FIG.push.run_levels,'Userdata','abort');  % so that "FFR_loop" knows an abort was requested.
        set(FIG.push.close,'Enable','on');
        %       set(FIG.push.forget_now,'Enable','on');
    else
        set(FIG.push.close,'Enable','off');
        %       set(FIG.push.forget_now,'Enable','off');
    end
    
elseif strcmp(command_str,'forget_now')
    if (strcmp(get(FIG.push.forget_now,'string'), 'Forget NOW'))
        FIG.NewStim = 11;
    else
        set(FIG.push.forget_now,'Userdata','save');
    end
    
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
    
elseif strcmp(command_str,'close')
    set(FIG.push.close,'Userdata',1);
end