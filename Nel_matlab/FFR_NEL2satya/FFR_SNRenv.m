function h_fig = FFR_SNRenv(command_str,eventdata)

% ge debug ABR 26Apr2004: replace "FFR" with more generalized nomenclature, throughout entire system.

global RP PROG FIG Stimuli FFR_Gating root_dir prog_dir Display FFR_SNRenv_Gating
%Stimuli.OLDDir
% global fc fm pol dur
prog_dir = [root_dir 'FFR\'];
% RP1= RP.activeX;        %MW10062016  use global control object rather than reinitialize
% RP2 = RP1;      %MW10062016  only one device with RX8
RP1=actxcontrol('RPco.x',[0 0 1 1]);
invoke(RP1,'ConnectRP2','USB',1);
invoke(RP1,'ClearCOF');
invoke(RP1,'LoadCOF',[prog_dir '\object\FFR_wav_polIN.rcx']);

RP2=actxcontrol('RPco.x',[0 0 1 1]);
invoke(RP2,'ConnectRP2','USB',2);
invoke(RP2,'ClearCOF');
invoke(RP2,'LoadCOF',[prog_dir '\object\FFR_right2.rcx']);


%%
if nargin < 1
    PROG = struct('name','FFR(v1.ge_mh.1).m');  % modified by GE 26Apr2004.
    [FIG, h_fig]=get_FIG_ffr_srnenv(); % Initialize FIG
    [misc, Stimuli, RunLevels_params, Display, interface_type]=FFR_SNRenv_ins(); ...
        %#ok<ASGLU> % should already be populated by CAP_ins
    
    %     FFR_set_attns(-120,-120,Stimuli.channel,Stimuli.KHosc,RP.activeX,RP.activeX);
    %     Gets stuck in an infy loop ^
    
    
    [FIG, FFR_SNRenv_Gating, Display]=FFR_SNRenv_loop_plot(FIG,Display,Stimuli,interface_type); 
    FFR_SNRenv('fast');
    FFR_SNRenv('update_stim', 'spl');
    ffr_snrenv_loop2; % Working
    
elseif strcmp(command_str,'update_stim')
    switch eventdata
        case 'spl'
            FIG.NewStim = 101;
            if get(FIG.bg.spl.dB65, 'value')
                Stimuli.atten_dB = Stimuli.maxSPL-65;
            elseif get(FIG.bg.spl.dB85, 'value')
                Stimuli.atten_dB = Stimuli.maxSPL-85;
            end
            set(FIG.asldr.val,'string',num2str(-Stimuli.atten_dB));
            set_RP_tagvals(RP1, RP2, FFR_SNRenv_Gating, Stimuli);
            
        case 'list'
            FIG.NewStim = 2;
            if get(FIG.bg.stim.stim14,'value')
                fName=load([fileparts(Stimuli.OLDDir(1:end-1)) filesep 'SNRenv_stimlist14.mat']);
            elseif get(FIG.bg.stim.stim22,'value')
                fName=load([fileparts(Stimuli.OLDDir(1:end-1)) filesep 'SNRenv_stimlist22.mat']);
            end
            Stimuli.list=fName.SNRenv_stimlist;
            FIG.popup.stims = uicontrol(FIG.handle,'callback', 'FFR_SNRenv(''update_stim'',0);','style', ...
                'popup','Units' ,'normalized', 'Userdata',Stimuli.filename,'position',[.4 .175 .425 .04], ...
                'string',struct2cell(Stimuli.list),'fontsize',12);
            
        case 'noise_type'
            FIG.NewStim = 2;
            if get(FIG.bg.nt.nt_ssn,'value')
                Stimuli.OLDDir='C:\NEL1_2\Users\SP\SNRenv_stimuli\stimSetStationary\';
                Stimuli.NoiseType=0;
            elseif get(FIG.bg.nt.nt_f,'value')
                Stimuli.OLDDir='C:\NEL1_2\Users\SP\SNRenv_stimuli\stimSetFluctuating\';
                Stimuli.NoiseType=1;
            end
            
        case 'newStim'
            FIG.NewStim = 2;
            StimInd= get(FIG.popup.stims, 'value');
            Stimuli.filename=Stimuli.list(StimInd).name;
            
        case 'prevStim'
            FIG.NewStim = 2;
            StimInd= get(FIG.popup.stims, 'value');
            if StimInd~=1
                StimInd=StimInd-1;
            end
            Stimuli.filename=Stimuli.list(StimInd).name;
            set(FIG.popup.stims, 'value', StimInd);
            
        case 'nextStim'
            FIG.NewStim = 2;
            StimInd= get(FIG.popup.stims, 'value');
            if StimInd~=length(Stimuli.list)
                StimInd=StimInd+1;
            end
            Stimuli.filename=Stimuli.list(StimInd).name;
            set(FIG.popup.stims, 'value', StimInd);
    end
    
    [xp,fsp]=audioread([Stimuli.OLDDir Stimuli.filename]);
    xpr=resample(xp,round(Stimuli.RPsamprate_Hz), fsp);
    audiowrite([Stimuli.UPDdir Stimuli.filename], xpr, round(Stimuli.RPsamprate_Hz));
    copyfile([Stimuli.UPDdir Stimuli.filename],Stimuli.STIMfile,'f');
    
    %% Remove
    % copies file to both "original" and "polarized" locations
    %     [xp,fsp]=wavread([Stimuli.OLDDir Stimuli.filename]);
    %     [xn,fsn]=wavread([Stimuli.OLDDir Stimuli.filename(1:end-5) 'N' Stimuli.filename(end-3:end)]);
    %     if fsp~=fsn
    %         error('sampling frequencies do not match (file: FFRSNRenv, L105)');
    %     else
    %     xpr=resample(xp,round(Stimuli.RPsamprate_Hz), fsp);
    %         xnr=resample(xn,round(Stimuli.RPsamprate_Hz), fsn);
    %
    %     wavwrite(xpr, round(Stimuli.RPsamprate_Hz), [Stimuli.UPDdir Stimuli.filename]);
    %         wavwrite(xnr, round(Stimuli.RPsamprate_Hz), ...
    %             [Stimuli.UPDdir Stimuli.filename(1:end-5) 'N' Stimuli.filename(end-3:end)]);
    %
    %     copyfile([Stimuli.UPDdir Stimuli.filename],Stimuli.STIMfile,'f');
    %         copyfile([Stimuli.UPDdir Stimuli.filename(1:end-5) 'N' Stimuli.filename(end-3:end)],  ...
    %             'C:\NEL1_2\Nel_matlab\FFR\Signals\tone_inv.wav','f');
    %     end
    
elseif strcmp(command_str,'fast')
    if get(FIG.radio.fast, 'value') == 1
        FIG.NewStim = 1;
        set(FIG.radio.slow,'value',0);
        FFR_Gating=Stimuli.fast;
        %       Stimuli.duration_ms =  50;
        %       Stimuli.period_ms   = 250;
    else
        set(FIG.radio.fast,'value',1);
    end
    
elseif strcmp(command_str,'slow')
    if get(FIG.radio.slow, 'value') == 1
        FIG.NewStim = 1;
        set(FIG.radio.fast,'value',0);
        FFR_Gating=Stimuli.slow;
        %       Stimuli.duration_ms =  200;
        %       Stimuli.period_ms   = 1000;
    else
        set(FIG.radio.slow,'value',1);
    end
    
elseif strcmp(command_str,'left')
    if get(FIG.radio.left, 'value') == 1
        FIG.NewStim = 101;
        Stimuli.channel = 2;
        Stimuli.ear='left';
        set(FIG.radio.right,'value',0);
        set(FIG.radio.both,'value',0);
    else
        set(FIG.radio.left,'value',1);
    end
    
elseif strcmp(command_str,'right')
    if get(FIG.radio.right, 'value') == 1
        FIG.NewStim = 101;
        Stimuli.channel = 1;
        Stimuli.ear='right';
        set(FIG.radio.left,'value',0);
        set(FIG.radio.both,'value',0);
    else
        set(FIG.radio.right,'value',1);
    end
    
elseif strcmp(command_str,'both')
    if get(FIG.radio.both, 'value') == 1
        FIG.NewStim = 101;
        Stimuli.channel = 3;
        Stimuli.ear='both';
        set(FIG.radio.left,'value',0);
        set(FIG.radio.right,'value',0);
    else
        set(FIG.radio.both,'value',1);
    end
    
elseif strcmp(command_str,'slide_atten')
    FIG.NewStim = 101;
    Stimuli.atten_dB = floor(-get(FIG.asldr.slider,'value'));
    set(FIG.asldr.val,'string',num2str(-Stimuli.atten_dB));
    
    % LQ 01/31/05
elseif strcmp(command_str, 'slide_atten_text')
    FIG.NewStim = 101;
    new_atten = get(FIG.asldr.val, 'string');
    if new_atten(1) ~= '-'
        new_atten = ['-' new_atten];
        set(FIG.asldr.val,'string', new_atten);
    end
    new_atten = str2double(new_atten);
    if new_atten < get(FIG.asldr.slider,'min') || new_atten > get(FIG.asldr.slider,'max')
        set( FIG.asldr.val, 'string', num2str(-Stimuli.atten_dB));
    else
        Stimuli.atten_dB = -new_atten;
        set(FIG.asldr.slider, 'value', new_atten);
    end
    
    
elseif strcmp(command_str,'memReps')
    FIG.NewStim = 3;
    oldMemReps = Stimuli.FFRmem_reps;
    Stimuli.FFRmem_reps = str2double(get(FIG.edit.memReps,'string'));
    if (isempty(Stimuli.FFRmem_reps))  % check is empty
        Stimuli.FFRmem_reps = oldMemReps;
    elseif ( Stimuli.FFRmem_reps<0 )  % check range
        Stimuli.FFRmem_reps = oldMemReps;
    end
    
    set(FIG.edit.memReps,'string', num2str(Stimuli.FFRmem_reps));
    
    %KHZZ 2011 Nov 4
elseif strcmp(command_str,'threshV')
    FIG.NewStim = 101;
    oldThreshV = Stimuli.threshV;
    Stimuli.threshV = str2double(get(FIG.edit.threshV,'string'));
    if (isempty(Stimuli.threshV))  % check is empty
        Stimuli.threshV = oldThreshV;
    elseif ( Stimuli.threshV<0 )  % check range
        Stimuli.threshV = oldThreshV;
    end
    set(FIG.edit.threshV,'string', num2str(Stimuli.threshV));
    set(FIG.ax.line4,'YData',[Stimuli.threshV Stimuli.threshV]);
    
elseif strcmp(command_str,'run_levels')
    FIG.NewStim = 4;
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
        FIG.NewStim = 5;
    else
        set(FIG.push.forget_now,'Userdata','save');
    end
    
elseif strcmp(command_str,'Gain')
    %     FIG.NewStim = 6;
    oldGain = Display.Gain;
    Display.Gain = str2double(get(FIG.edit.gain,'string'));
    if (isempty(Display.Gain))  % check is empty
        Display.Gain = oldGain;
    elseif (Display.Gain<0)  % check range
        Display.Gain = oldGain;
    end
    set(FIG.edit.gain,'string', num2str(Display.Gain));
    
elseif strcmp(command_str,'atAD')
    if get(FIG.radio.atAD, 'value') == 1
        FIG.NewStim = 6;
        Display.Voltage = 'atAD';
        set(FIG.radio.atELEC,'value',0);
    else
        set(FIG.radio.atAD,'value',1);
    end
    
elseif strcmp(command_str,'atELEC')
    if get(FIG.radio.atELEC, 'value') == 1
        FIG.NewStim = 6;
        Display.Voltage = 'atELEC';
        set(FIG.radio.atAD,'value',0);
    else
        set(FIG.radio.atELEC,'value',1);
    end
    
elseif strcmp(command_str,'YLim')
    FIG.NewStim = 6;
    oldYLim = Display.YLim_atAD;
    Display.YLim_atAD = str2double(get(FIG.edit.yscale,'string'));
    if (isempty(Display.YLim_atAD))  % check is empty
        Display.YLim_atAD = oldYLim;
    elseif (Display.YLim_atAD<0)  % check range
        Display.YLim_atAD = oldYLim;
    end
    set(FIG.edit.yscale,'string', num2str(Display.YLim_atAD));
    
elseif strcmp(command_str,'close')
    set(FIG.push.close,'Userdata',1);
    cd('C:\NEL1_2\Nel_matlab\nel_general');
end
