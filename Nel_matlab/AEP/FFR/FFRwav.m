function h_fig = FFRwav(command_str,eventdata)

global RP PROG FIG Stimuli FFR_Gating root_dir prog_dir Display NelData PROTOCOL

PROTOCOL = 'FFRwav';
prog_dir = [root_dir 'AEP\FFR\'];
usr = NelData.General.User; % current nel user

% Decide if NEL1 or NEL2
% if strcmp(NelData.General.WindowsHostName, '1353lyl303501d') % means NEL1
RP1= connect_tdt('RP2', 1);
RP2= connect_tdt('RP2', 2);

%RP3 is now connected in set_invFilter for NEL2!

if NelData.General.RP2_3and4 && (~NelData.General.RX8)
    RP3= connect_tdt('RP2', 3);  %#ok<*NASGU>
end
% elseif (~NelData.General.RP2_3and4) && (~NelData.General.RX8)
%     RP3= RP2;
% elseif NelData.General.RX8
% %     RP3= connect_tdt('RX8', 1);
%       
% end


%%
if nargin < 1
    PROG = struct('name','FFR(v1.ge_mh.1).m');  % modified by GE 26Apr2004.
    [FIG, h_fig]=get_FFR_FIG(); % Initialize FIG
    
    [misc, Stimuli, RunLevels_params, Display, interface_type]=FFRwav_ins(NelData);
    
    [FIG, FFR_Gating, Display]=FFRwav_loop_plot(FIG,Display,Stimuli,interface_type);
    
    %     if ~(double(invoke(RP1,'GetTagVal', 'Stage')) == 2)
    %         FFR_set_attns(-120,-120,Stimuli.channel,Stimuli.KHosc,RP1,RP2); %% Check with MH
    %     end
    
    FFRwav('calibInit'); % Initialize RP2_4 with InvFilter
    FFRwav('update_stim', 'spl');
    FFRwav_loop; % Working
    
elseif strcmp(command_str,'update_stim')
    update_gating_flag= false;
    switch eventdata
        case 'spl'
            FIG.NewStim = 2;
            if get(FIG.bg.spl.dB65, 'value')
                Stimuli.atten_dB = Stimuli.maxSPL-65;
            elseif get(FIG.bg.spl.dB85, 'value')
                Stimuli.atten_dB = Stimuli.maxSPL-85;
            end
            set(FIG.asldr.val,'string',num2str(-Stimuli.atten_dB));
            %             set_RP_tagvals(RP1, RP2, FFR_SNRenv_Gating, Stimuli);
            
        case 'list'
            FIG.NewStim = 2;
            fName.FFRwav_stimlist=dir([Stimuli.OLDDir '*.wav']);
            
            %             if get(FIG.bg.stim.stim14,'value')
            %                 fName=load([fileparts(Stimuli.OLDDir(1:end-1)) filesep 'SNRenv_stimlist14.mat']);
            %             elseif get(FIG.bg.stim.stim22,'value')
            %                 fName=load([fileparts(Stimuli.OLDDir(1:end-1)) filesep 'SNRenv_stimlist22.mat']);
            %             elseif get(FIG.bg.stim.stimDir,'value')
            %                 fName.SNRenv_stimlist=dir([Stimuli.OLDDir '*.wav']);
            %             end
            
            if ~get(FIG.bg.stim.stimDir,'value')
                Stimuli.list=fName.FFRwav_stimlist;
                FIG.popup.stims = uicontrol(FIG.handle,'callback', 'FFRwav(''update_stim'',0);','style', ...
                    'popup','Units' ,'normalized', 'Userdata',Stimuli.filename,'position',[.4 .175 .425 .04], ...
                    'string',struct2cell(Stimuli.list),'fontsize',12);
            else
                Stimuli.list= repmat(struct('name', ''), length(fName.FFRwav_stimlist), 1);
                for stimVar= 1:length(Stimuli.list)
                    Stimuli.list(stimVar).name= fName.FFRwav_stimlist(stimVar).name;
                end
                %             Stimuli.filename= Stimuli.list(end).name;
                %             FIG.popup.stims = uicontrol(FIG.handle,'callback', 'FFRwav(''update_stim'',0);','style', ...
                %                 'popup','Units' ,'normalized', 'Userdata',Stimuli.filename,'position',[.4 .175 .425 .04], ...
                %                 'string',({fName.FFRwav_stimlist.name}),'fontsize',12);
                update_gating_flag= true;
            end
            
        case 'noise_type' % not functional -- remove??
            FIG.NewStim = 2;
            if get(FIG.bg.nt.nt_ssn,'value')
                Stimuli.OLDDir= [NelData.General.RootDir 'Users\SP\SNRenv_stimuli\stimSetStationary\'];
                Stimuli.NoiseType=0;
            elseif get(FIG.bg.nt.nt_f,'value')
                Stimuli.OLDDir= [NelData.General.RootDir 'Users\SP\SNRenv_stimuli\stimSetFluctuating\'];
                Stimuli.NoiseType=1;
            end
            
            %         case 0
            %             FIG.NewStim = 2;
            %             StimInd= get(FIG.popup.stims, 'value');
            %             Stimuli.filename=Stimuli.list(StimInd).name;
            %             set(FIG.popup.stims, 'value', StimInd);
            
        case 'newStim'
            FIG.NewStim = 2;
%             fName.FFRwav_stimlist=dir([Stimuli.OLDDir '*.wav']);
%             Stimuli.list=fName.FFRwav_stimlist;
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
    FFRwav('attenCalib'); % Initialize RP2_4 with InvFilter
    
    if update_gating_flag % right now, this will update only for dir based, later for all stims
        Stimuli.fast.duration_ms= round(length(xp)/fsp*1e3);
        Stimuli.fast.XendPlot_ms= Stimuli.fast.duration_ms+300;
        Stimuli.fast.FFRlength_ms= Stimuli.fast.duration_ms+300;
        
        Stimuli.slow.duration_ms= round(length(xp)/fsp*1e3);
        Stimuli.slow.XendPlot_ms= Stimuli.fast.duration_ms+200;
        Stimuli.slow.FFRlength_ms= Stimuli.fast.duration_ms+200;
        
        if get(FIG.radio.fast, 'value') % Fast
            Stimuli.fast.period_ms= Stimuli.fast.duration_ms+501;
            FFRwav('fast');
        elseif get(FIG.radio.slow, 'value') == 1 % Slow
            Stimuli.slow.period_ms= Stimuli.fast.duration_ms+1000;
            FFRwav('slow');
        end
    end
    
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
        FIG.NewStim = 0;
        Stimuli.channel = 2;
        Stimuli.ear='left';
        set(FIG.radio.right,'value',0);
        set(FIG.radio.both,'value',0);
    else
        set(FIG.radio.left,'value',1);
    end
    
    FFRwav('update_stim', 'spl');
    FFRwav('calibInit');
    
    
elseif strcmp(command_str,'right')
    if get(FIG.radio.right, 'value') == 1
        FIG.NewStim = 0;
        Stimuli.channel = 1;
        Stimuli.ear='right';
        set(FIG.radio.left,'value',0);
        set(FIG.radio.both,'value',0);
    else
        set(FIG.radio.right,'value',1);
    end
    
    FFRwav('update_stim', 'spl');
    FFRwav('calibInit');
    
elseif strcmp(command_str,'both')
    if get(FIG.radio.both, 'value') == 1
        FIG.NewStim = 0;
        Stimuli.channel = 3;
        Stimuli.ear='both';
        set(FIG.radio.left,'value',0);
        set(FIG.radio.right,'value',0);
    else
        set(FIG.radio.both,'value',1);
    end
    
    FFRwav('update_stim', 'spl');
    FFRwav('calibInit');
    
elseif strcmp(command_str,'chan_1')
    if get(FIG.radio.chan_1, 'value') == 1
        FIG.NewStim = 18;
        Stimuli.rec_channel = 1;
        set(FIG.radio.chan_2,'value',0);
        set(FIG.radio.Simultaneous,'value',0);
        set(FIG.edit.threshV, 'Enable', 'on')
        set(FIG.edit.threshV2, 'Enable', 'off')
    else
        set(FIG.radio.chan_1,'value',1);
    end
    
elseif strcmp(command_str,'chan_2')
    if get(FIG.radio.chan_2, 'value') == 1
        FIG.NewStim = 18;
        Stimuli.rec_channel = 2;
        set(FIG.radio.chan_1,'value',0);
        set(FIG.radio.Simultaneous,'value',0);
        set(FIG.edit.threshV2, 'Enable', 'on')
        set(FIG.edit.threshV, 'Enable', 'off')
        set(FIG.edit.threshV2, 'Enable', 'on')
    else
        set(FIG.radio.chan_2,'value',1);
    end
    
elseif strcmp(command_str,'Simultaneous')
    if get(FIG.radio.Simultaneous, 'value') == 1
        FIG.NewStim = 18;
        Stimuli.rec_channel = 3;
        set(FIG.radio.chan_1,'value',0);
        set(FIG.radio.chan_2,'value',0);
        set(FIG.edit.threshV, 'Enable', 'on')
        set(FIG.edit.threshV2, 'Enable', 'on')
    else
        set(FIG.radio.Simultaneous,'value',1);
    end
    
elseif strcmp(command_str,'slide_atten')
    FIG.NewStim = 2;
    Stimuli.atten_dB = floor(-get(FIG.asldr.slider,'value'));
    set(FIG.asldr.val,'string',num2str(-Stimuli.atten_dB));
    %     set_RP_tagvals(RP1, RP2, FFR_SNRenv_Gating, Stimuli);
%     FFR_set_attns(Stimuli.atten_dB,-120,Stimuli.channel,Stimuli.KHosc,RP1,RP2);
    set(FIG.asldr.SPL,'string',sprintf('%.1f dB SPL',Stimuli.calib_dBSPLout-abs(get(FIG.asldr.slider,'val'))));
    FFRwav('attenCalib');
    
    % LQ 01/31/05
elseif strcmp(command_str, 'slide_atten_text')
    FIG.NewStim = 2;
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
%     FFR_set_attns(Stimuli.atten_dB,-120,Stimuli.channel,Stimuli.KHosc,RP1,RP2);
    %     set_RP_tagvals(RP1, RP2, FFR_SNRenv_Gating, Stimuli);
    
    set(FIG.asldr.SPL,'string',sprintf('%.1f dB SPL',Stimuli.calib_dBSPLout-abs(get(FIG.asldr.slider,'val'))));
    FFRwav('attenCalib');
    
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
    FIG.NewStim = 7;
    oldThreshV = Stimuli.threshV;
    Stimuli.threshV = str2double(get(FIG.edit.threshV,'string'));
    if (isempty(Stimuli.threshV))  % check is empty
        Stimuli.threshV = oldThreshV;
    elseif ( Stimuli.threshV<0 )  % check range
        Stimuli.threshV = oldThreshV;
    end
    set(FIG.edit.threshV,'string', num2str(Stimuli.threshV));
    
elseif strcmp(command_str,'threshV2')   %JMR nov 21 for artifact rejection channel 2
    FIG.NewStim = 7;
    oldThreshV2 = Stimuli.threshV2;
    Stimuli.threshV2 = str2double(get(FIG.edit.threshV2,'string'));
    if (isempty(Stimuli.threshV2))  % check is empty
        Stimuli.threshV2 = oldThreshV2;
    elseif ( Stimuli.threshV < 0 )  % check range
        Stimuli.threshV2 = oldThreshV2;
    end
    set(FIG.edit.threshV2,'string', num2str(Stimuli.threshV2));
    
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
    
    
%UPDATES
elseif strcmp(command_str,'calibInit')
    
    if isnan(Stimuli.calibPicNum)
         cdd;
        allCalibFiles= dir('*calib*raw*');
        Stimuli.calibPicNum= getPicNum(allCalibFiles(end).name);
        Stimuli.calibPicNum= str2double(inputdlg('Enter RAW Calibration File Number (default = last raw calib)','Load Calib File', 1,{num2str(Stimuli.calibPicNum)}));
        rdd;
    end
    
%     [~, Stimuli.calibPicNum]= run_invCalib(get(FIG.radio.invCalib,'value'));
    Stimuli.invCalib=get(FIG.radio.invCalib,'value');
%     filttype = {'inversefilt','inversefilt'};
    if get(FIG.radio.invCalib,'value')
        if get(FIG.radio.right,'value') == 1
            filttype = {'allstop','inversefilt'};
        elseif get(FIG.radio.left,'value') == 1
            filttype = {'inversefilt','allstop'};
        elseif get(FIG.radio.both,'value') == 1
            filttype = {'inversefilt','inversefilt'};
        end
    else
        filttype = {'allpass','allpass'};
    end
    
    invfiltdata = set_invFilter(filttype,Stimuli.calibPicNum);
    cdd;
    cal = loadpic(invfiltdata.CalibPICnum2use);  % use INVERSE calib to compute MAX dB SPL
    rdd;
    
    ears_calib = cal.ear_ord;
    r_present = sum(strcmp(ears_calib,'Right '));
    l_present = sum(strcmp(ears_calib,'Left '));
    
    %probably better way to do this..
    
    if ~r_present && ~l_present
        warndlg('No calibs present!','No calibs!')
        FFRwav('close');
    end
    
    if r_present && ~l_present
        FIG.NewStim = 5;
        Stimuli.channel = 1;
        Stimuli.ear='right';
        set(FIG.radio.right,'value',1);
        set(FIG.radio.left,'value',0);
        set(FIG.radio.both,'value',0);
        
    elseif l_present && ~r_present
        FIG.NewStim = 5;
        Stimuli.channel = 2;
        Stimuli.ear='left';
        set(FIG.radio.left,'value',1);
        set(FIG.radio.right,'value',0);
        set(FIG.radio.both,'value',0);
    end
    
    if ~r_present
        set(FIG.radio.right,'Enable','off');
    end
    
    if ~l_present
        set(FIG.radio.left,'Enable','off')
    end
    
    if ~(l_present && r_present)
        set(FIG.radio.both,'Enable','off')
    end
    
    set(FIG.radio.invCalib,'UserData',invfiltdata); 
    FFRwav('attenCalib');
    
 elseif strcmp(command_str,'attenCalib') %AS/MH/MP | Sprint 2023 Update
    cdd;
    
    invfiltdata = get(FIG.radio.invCalib,'UserData'); 

    cal = loadpic(invfiltdata.CalibPICnum2use);  % use INVERSE calib to compute MAX dB SPL
    
%     CalibData=cal.CalibData(:,1:2);
%     CalibData(:,2)=trifilt(CalibData(:,2)',5)';
    rdd;
    
%     if get(FIG.radio.clickYes,'value')
%         Stimuli.MaxdBSPLCalib=median(CalibData(:,2));  %use this convention ALWAYS in analysis too!
%         %% LONG-TERM - decide if median is right - it avoids ends with very low values
%     else % tone
%         Stimuli.MaxdBSPLCalib=CalibInterp(Stimuli.freq_hz/1000, CalibData);
%     end


    [sig, fs] =audioread([Stimuli.UPDdir Stimuli.filename]);
    curDir= pwd;
    cdd;

    cd(curDir);
    %calibdata = struct;
    calibdata= cal.CalibData();
    Stimuli.calib_dBSPLout= get_SPL_from_calib(sig, fs, calibdata, false);
    set(FIG.asldr.SPL,'string',sprintf('%.1f dB SPL',Stimuli.calib_dBSPLout-abs(str2double(get(FIG.asldr.val, 'string')))));
    
%     set(FIG.asldr.SPL, 'string', sprintf('%.1f dB SPL', Stimuli.MaxdBSPLCalib-Stimuli.atten_dB));    
    
    
% elseif strcmp(command_str,'invCalib')
%     %% MH/AS Jun 15 2023:  this is really CALIB, not invCALIB
%     %% FIX LATER
%     
%     if NelData.General.RP2_3and4 && (~NelData.General.RX8)
%         [~, Stimuli.calibPicNum]= run_invCalib(get(FIG.radio.invCalib,'value')); %NEL 1
%     elseif isnan(Stimuli.calibPicNum)  % NEL2
%         cdd;
%         allCalibFiles= dir('*calib*raw*');
%         Stimuli.calibPicNum= getPicNum(allCalibFiles(end).name);
%         Stimuli.calibPicNum= str2double(inputdlg('Enter RAW Calibration File Number','Load Calib File', 1,{num2str(Stimuli.calibPicNum)}));
%         rdd;
%         
%         %% FUTURE: have this use CALIB file picked by user, not automated
%         %% SEE HOW TO DO THIS not every time,
%         [~, Stimuli.calibPicNum]= run_invCalib(get(FIG.radio.invCalib,'value'));
%         Stimuli.invCalib=get(FIG.radio.invCalib,'value');
%         if get(FIG.radio.invCalib,'value')
%             Stimuli.calibPicNum=Stimuli.calibPicNum+1;  % FIX THIS LATER to not assume +1
%         end
%         
%         %% FIX LATER - won't handle toggle invCALI on/off
%         %% SET invCALIB always run, then no issue
%         
%         
%     end
%     [sig, fs] =audioread([Stimuli.UPDdir Stimuli.filename]);
%     curDir= pwd;
%     cdd;
%     %xx= Stimuli.calibPicNum();
%     xx= loadpic(Stimuli.calibPicNum);
%     class(xx);
%     cd(curDir);
%     %calibdata = struct;
%     calibdata= xx.CalibData();
%     Stimuli.calib_dBSPLout= get_SPL_from_calib(sig, fs, calibdata, false);
%     set(FIG.asldr.SPL,'string',sprintf('%.1f dB SPL',Stimuli.calib_dBSPLout-abs(str2double(get(FIG.asldr.val, 'string')))));
    
elseif strcmp(command_str,'close')
    %     if NelData.General.RP2_3and4 && (~NelData.General.RX8)
%     run_invCalib(false); % Initialize with allpass RP2_3
    %     end
    
    filttype = {'allpass','allpass'};
    dummy = set_invFilter(filttype,Stimuli.calibPicNum);
    
    set(FIG.push.close,'Userdata',1);
    cd([NelData.General.RootDir 'Nel_matlab\nel_general']);
end
