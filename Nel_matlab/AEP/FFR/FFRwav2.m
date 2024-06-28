function h_fig = FFRwav2(command_str,eventdata)

global RP PROG FIG Stimuli FFR_Gating root_dir prog_dir Display NelData PROTOCOL filttype invfiltdata

PROTOCOL = 'FFRwav2';
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
    %[FIG, h_fig]=get_FFR_FIG(); % Initialize FIG
    
 
    [FIG, h_fig]=get_FFRwav2_FIG();
    
    [misc, Stimuli, RunLevels_params, Display, interface_type]=FFRwav2_ins(NelData);
    
    [FIG, FFR_Gating, Display]=FFRwav2_loop_plot(FIG,Display,Stimuli,interface_type);
    
    %     if ~(double(invoke(RP1,'GetTagVal', 'Stage')) == 2)
    %         FFR_set_attns(-120,-120,Stimuli.channel,Stimuli.KHosc,RP1,RP2); %% Check with MH
    %     end
    
    FFRwav2('calibInit'); % Initialize RP2_4 with InvFilter
% check how to do with 2 stim
    FFRwav2('right'); %default to right ear first
    FFRwav2('right2'); %default to right ear first
% check how to do with 2 stim
    FFRwav2('update_stim', 'spl');
    FFRwav2('update_stim', 'spl2');
    FFRwav2_loop; % Working
    
elseif strcmp(command_str,'update_stim')
    update_gating_flag= false;
    resetAttn = false;
    
    switch eventdata
        case 'spl'
            FIG.NewStim = 2;
            if get(FIG.bg.spl.dB65, 'value')
                Stimuli.atten_dB = Stimuli.calib_dBSPLout-65;
                Stimuli.atten_dB = round(Stimuli.atten_dB,1);
            elseif get(FIG.bg.spl.dB80, 'value')
                Stimuli.atten_dB = Stimuli.calib_dBSPLout-80;
                Stimuli.atten_dB = round(Stimuli.atten_dB,1);
            end
            set(FIG.asldr.val,'string',num2str(-Stimuli.atten_dB));
            %             set_RP_tagvals(RP1, RP2, FFR_SNRenv_Gating, Stimuli);
            
            Stimuli.calib_levelSPL = Stimuli.calib_dBSPLout-Stimuli.atten_dB;           

        case 'spl2'
            FIG.NewStim = 2;
            if get(FIG.bg2.spl.dB65, 'value')
                Stimuli.atten2_dB = Stimuli.calib_dBSPLout2-65;
                Stimuli.atten2_dB = round(Stimuli.atten2_dB,1);
            elseif get(FIG.bg2.spl.dB80, 'value')
                Stimuli.atten2_dB = Stimuli.calib_dBSPLout2-80;
                Stimuli.atten2_dB = round(Stimuli.atten2_dB,1);
            end
            set(FIG.asldr2.val,'string',num2str(-Stimuli.atten2_dB));
            %             set_RP_tagvals(RP1, RP2, FFR_SNRenv_Gating, Stimuli);
            
            Stimuli.calib_levelSPL2 = Stimuli.calib_dBSPLout2-Stimuli.atten2_dB;

        case 'list'
            FIG.NewStim = 2;
            fName.FFRwav_stimlist=dir([Stimuli.OLDDir '*.wav']);
                      
            if ~get(FIG.bg.stim.stimDir,'value')
                Stimuli.list=fName.FFRwav_stimlist;
                FIG.popup.stims = uicontrol(FIG.handle,'callback', 'FFRwav2(''update_stim'',0);','style', ...
                    'popup','Units' ,'normalized', 'Userdata',Stimuli.filename,'position',[.4 .175 .425 .04], ...
                    'string',struct2cell(Stimuli.list),'fontsize',12);
            else
                Stimuli.list= repmat(struct('name', ''), length(fName.FFRwav_stimlist), 1);
                for stimVar= 1:length(Stimuli.list)
                    Stimuli.list(stimVar).name= fName.FFRwav_stimlist(stimVar).name;
                end
                %             Stimuli.filename= Stimuli.list(end).name;
                %             FIG.popup.stims = uicontrol(FIG.handle,'callback', 'FFRwav2(''update_stim'',0);','style', ...
                %                 'popup','Units' ,'normalized', 'Userdata',Stimuli.filename,'position',[.4 .175 .425 .04], ...
                %                 'string',({fName.FFRwav_stimlist.name}),'fontsize',12);
                update_gating_flag= true;
            end

            if ~get(FIG.bg2.stim.stimDir,'value')
                Stimuli.list2=fName.FFRwav_stimlist;
                FIG.popup2.stims = uicontrol(FIG.handle,'callback', 'FFRwav2(''update_stim'',0);','style', ...
                    'popup','Units' ,'normalized', 'Userdata',Stimuli.filename,'position',[.4 .175 .425 .04], ...
                    'string',struct2cell(Stimuli.list2),'fontsize',12);
            else
                Stimuli.list2= repmat(struct('name', ''), length(fName.FFRwav_stimlist), 1);
                for stimVar= 1:length(Stimuli.list2)
                    Stimuli.list2(stimVar).name= fName.FFRwav_stimlist(stimVar).name;
                end
                %             Stimuli.filename= Stimuli.list(end).name;
                %             FIG.popup.stims = uicontrol(FIG.handle,'callback', 'FFRwav2(''update_stim'',0);','style', ...
                %                 'popup','Units' ,'normalized', 'Userdata',Stimuli.filename,'position',[.4 .175 .425 .04], ...
                %                 'string',({fName.FFRwav_stimlist.name}),'fontsize',12);
                update_gating_flag= true;
            end
            
        case 'list2'
            FIG.NewStim = 2;
            fName.FFRwav_stimlist=dir([Stimuli.OLDDir '*.wav']);
            
            if ~get(FIG.bg2.stim.stimDir,'value')
                Stimuli.list2=fName.FFRwav_stimlist;
                FIG.popup2.stims = uicontrol(FIG.handle,'callback', 'FFRwav2(''update_stim'',0);','style', ...
                    'popup','Units' ,'normalized', 'Userdata',Stimuli.filename,'position',[.4 .175 .425 .04], ...
                    'string',struct2cell(Stimuli.list2),'fontsize',12);
            else
                Stimuli.list2= repmat(struct('name', ''), length(fName.FFRwav_stimlist), 1);
                for stimVar= 1:length(Stimuli.list2)
                    Stimuli.list2(stimVar).name= fName.FFRwav_stimlist(stimVar).name;
                end
                %             Stimuli.filename= Stimuli.list(end).name;
                %             FIG.popup.stims = uicontrol(FIG.handle,'callback', 'FFRwav2(''update_stim'',0);','style', ...
                %                 'popup','Units' ,'normalized', 'Userdata',Stimuli.filename,'position',[.4 .175 .425 .04], ...
                %                 'string',({fName.FFRwav_stimlist.name}),'fontsize',12);
                update_gating_flag= true;
            end

%         case 'noise_type' % not functional -- remove??
%             FIG.NewStim = 2;
%             if get(FIG.bg.nt.nt_ssn,'value')
%                 Stimuli.OLDDir= [NelData.General.RootDir 'Users\SP\SNRenv_stimuli\stimSetStationary\'];
%                 Stimuli.NoiseType=0;
%             elseif get(FIG.bg.nt.nt_f,'value')
%                 Stimuli.OLDDir= [NelData.General.RootDir 'Users\SP\SNRenv_stimuli\stimSetFluctuating\'];
%                 Stimuli.NoiseType=1;
%             end
%             
%             %         case 0
%             %             FIG.NewStim = 2;
%             %             StimInd= get(FIG.popup.stims, 'value');
%             %             Stimuli.filename=Stimuli.list(StimInd).name;
%             %             set(FIG.popup.stims, 'value', StimInd);
            
        case 'newStim'
            FIG.NewStim = 2;
%             fName.FFRwav_stimlist=dir([Stimuli.OLDDir '*.wav']);
%             Stimuli.list=fName.FFRwav_stimlist;
            StimInd= get(FIG.popup.stims, 'value');
            Stimuli.filename=Stimuli.list(StimInd).name;
            resetAttn = true;
            
        case 'newStim2'
            FIG.NewStim = 2;
            StimInd= get(FIG.popup2.stims, 'value');
            Stimuli.filename2=Stimuli.list2(StimInd).name;
            resetAttn = true;
            
        case 'prevStim'
            FIG.NewStim = 2;
            StimInd= get(FIG.popup.stims, 'value');
            if StimInd~=1
                StimInd=StimInd-1;
            end
            Stimuli.filename=Stimuli.list(StimInd).name;
            set(FIG.popup.stims, 'value', StimInd);
            
        case 'prevStim2'
            FIG.NewStim = 2;
            StimInd= get(FIG.popup2.stims, 'value');
            if StimInd~=1
                StimInd=StimInd-1;
            end
            Stimuli.filename2=Stimuli.list2(StimInd).name;
            set(FIG.popup2.stims, 'value', StimInd);
            
        case 'nextStim'
            FIG.NewStim = 2;
            StimInd= get(FIG.popup.stims, 'value');
            if StimInd~=length(Stimuli.list)
                StimInd=StimInd+1;
            end
            Stimuli.filename=Stimuli.list(StimInd).name;
            set(FIG.popup.stims, 'value', StimInd);

        case 'nextStim2'
            FIG.NewStim = 2;
            StimInd= get(FIG.popup2.stims, 'value');
            if StimInd~=length(Stimuli.list2)
                StimInd=StimInd+1;
            end
            Stimuli.filename2=Stimuli.list2(StimInd).name;
            set(FIG.popup2.stims, 'value', StimInd);
    end
    
    [xp,fsp]=audioread([Stimuli.OLDDir Stimuli.filename]);
    xpr=resample(xp,round(Stimuli.RPsamprate_Hz), fsp);
    audiowrite([Stimuli.UPDdir Stimuli.filename], xpr, round(Stimuli.RPsamprate_Hz));
    copyfile([Stimuli.UPDdir Stimuli.filename],Stimuli.STIMfile,'f');

    [xp2,fsp2]=audioread([Stimuli.OLDDir Stimuli.filename2]);
    xpr2=resample(xp2,round(Stimuli.RPsamprate_Hz), fsp2);
    audiowrite([Stimuli.UPDdir Stimuli.filename2], xpr2, round(Stimuli.RPsamprate_Hz));
    copyfile([Stimuli.UPDdir Stimuli.filename2],Stimuli.STIMfile2,'f');
    
    FFRwav2('attenCalib'); % Initialize RP2_4 with InvFilter
    
    %default new stim to 80 dB unless changed by user
    if resetAttn
        set(FIG.bg.spl.dB80, 'value',1);
        FFRwav2('update_stim','spl');
        set(FIG.bg2.spl.dB80, 'value',1);
        FFRwav2('update_stim','spl2');
    end
    
    if update_gating_flag % right now, this will update only for dir based, later for all stims
        Stimuli.fast.duration_ms= round(length(xp)/fsp*1e3);
        Stimuli.fast.XendPlot_ms= Stimuli.fast.duration_ms+300;
        Stimuli.fast.FFRlength_ms= Stimuli.fast.duration_ms+300;
        
        Stimuli.slow.duration_ms= round(length(xp)/fsp*1e3);
        Stimuli.slow.XendPlot_ms= Stimuli.fast.duration_ms+200;
        Stimuli.slow.FFRlength_ms= Stimuli.fast.duration_ms+200;
        
        if get(FIG.radio.fast, 'value') % Fast
            Stimuli.fast.period_ms= Stimuli.fast.duration_ms+501;
            FFRwav2('fast');
        elseif get(FIG.radio.slow, 'value') == 1 % Slow
            Stimuli.slow.period_ms= Stimuli.fast.duration_ms+1000;
            FFRwav2('slow');
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

    FFRwav2('update_stim', 'spl');
    FFRwav2('calibInit');
    
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
    
    FFRwav2('update_stim', 'spl');
    FFRwav2('calibInit');
    
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
    
    FFRwav2('update_stim', 'spl');
    FFRwav2('calibInit');

elseif strcmp(command_str,'left2')
    if get(FIG.radio.left2, 'value') == 1
        FIG.NewStim = 0;
        Stimuli.channel2 = 2;
        Stimuli.ear2='left';
        set(FIG.radio.right2,'value',0);
        set(FIG.radio.both2,'value',0);
        set(FIG.radio.no_audio2,'value',0);
        
        set(FIG.asldr2.slider, 'Visible','on');
        set(FIG.asldr2.min, 'Visible','on');
        set(FIG.asldr2.max, 'Visible','on');
        set(FIG.asldr2.val, 'Visible','on');
        set(FIG.asldr2.SPL, 'Visible','on');
        set(FIG.popup2.siglabel, 'Visible','on');
        set(FIG.popup2.stims, 'Visible','on');
        set(FIG.push2.prev_stim2, 'Visible','on');
        set(FIG.push2.next_stim2, 'Visible','on');
        set(FIG.bg2.spl.parent, 'Visible','on');
        
        
    else
        set(FIG.radio.left2,'value',1);
    end

    FFRwav2('update_stim', 'spl');
    FFRwav2('calibInit');
    
elseif strcmp(command_str,'right2')
    if get(FIG.radio.right2, 'value') == 1
        FIG.NewStim = 0;
        Stimuli.channel2 = 1;
        Stimuli.ear2='right';
        set(FIG.radio.left2,'value',0);
        set(FIG.radio.both2,'value',0);
        set(FIG.radio.no_audio2,'value',0);
        
        set(FIG.asldr2.slider, 'Visible','on');
        set(FIG.asldr2.min, 'Visible','on');
        set(FIG.asldr2.max, 'Visible','on');
        set(FIG.asldr2.val, 'Visible','on');
        set(FIG.asldr2.SPL, 'Visible','on');
        set(FIG.popup2.siglabel, 'Visible','on');
        set(FIG.popup2.stims, 'Visible','on');
        set(FIG.push2.prev_stim2, 'Visible','on');
        set(FIG.push2.next_stim2, 'Visible','on');
        set(FIG.bg2.spl.parent, 'Visible','on');
        
        
    else
        set(FIG.radio.right2,'value',1);
    end
    
    FFRwav2('update_stim', 'spl');
    FFRwav2('calibInit');
    
elseif strcmp(command_str,'both2')
    if get(FIG.radio.both2, 'value') == 1
        FIG.NewStim = 0;
        Stimuli.channel2 = 3;
        Stimuli.ear2='both';
        set(FIG.radio.left2,'value',0);
        set(FIG.radio.right2,'value',0);
        set(FIG.radio.no_audio2,'value',0);
        
        set(FIG.asldr2.slider, 'Visible','on');
        set(FIG.asldr2.min, 'Visible','on');
        set(FIG.asldr2.max, 'Visible','on');
        set(FIG.asldr2.val, 'Visible','on');
        set(FIG.asldr2.SPL, 'Visible','on');
        set(FIG.popup2.siglabel, 'Visible','on');
        set(FIG.popup2.stims, 'Visible','on');
        set(FIG.push2.prev_stim2, 'Visible','on');
        set(FIG.push2.next_stim2, 'Visible','on');
        set(FIG.bg2.spl.parent, 'Visible','on');
        
        
    else
        set(FIG.radio.both2,'value',1);
    end
    
    FFRwav2('update_stim', 'spl');
    FFRwav2('calibInit');
    %%% AF add this March 18
    
elseif strcmp(command_str,'no_audio2')
    if get(FIG.radio.no_audio2, 'value') == 1
        FIG.NewStim = 0;
        
        Stimuli.channel2 = NaN;
        Stimuli.ear2=NaN;
        
        set(FIG.radio.left2,'value',0);
        set(FIG.radio.right2,'value',0);
        set(FIG.radio.both2,'value',0);
        
        %hide everything related to signal 2
        set(FIG.asldr2.slider, 'Visible','off');
        set(FIG.asldr2.min, 'Visible','off');
        set(FIG.asldr2.max, 'Visible','off');
        set(FIG.asldr2.val, 'Visible','off');
        set(FIG.asldr2.SPL, 'Visible','off');
        set(FIG.popup2.siglabel, 'Visible','off');
        set(FIG.popup2.stims, 'Visible','off');
        set(FIG.push2.prev_stim2, 'Visible','off');
        set(FIG.push2.next_stim2, 'Visible','off');
        set(FIG.bg2.spl.parent, 'Visible','off');
        
    else
        set(FIG.radio.no_audio2,'value',1);
    end
    
    FFRwav2('update_stim', 'spl');
    FFRwav2('calibInit');    

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
    
    set(FIG.bg.spl.dB65, 'value',0);
    set(FIG.bg.spl.dB80, 'value',0);
    
    Stimuli.atten_dB = floor(-get(FIG.asldr.slider,'value'));
    set(FIG.asldr.val,'string',num2str(-Stimuli.atten_dB));
    %     set_RP_tagvals(RP1, RP2, FFR_SNRenv_Gating, Stimuli);
%     FFR_set_attns(Stimuli.atten_dB,-120,Stimuli.channel,Stimuli.KHosc,RP1,RP2);
    
    Stimuli.calib_levelSPL = Stimuli.calib_dBSPLout-Stimuli.atten_dB;

    set(FIG.asldr.SPL,'string',sprintf('%.1f dB SPL',Stimuli.calib_dBSPLout-abs(get(FIG.asldr.slider,'val'))));
    FFRwav2('attenCalib');

elseif strcmp(command_str,'slide_atten2')
    FIG.NewStim = 2;
    
    set(FIG.bg2.spl.dB65, 'value',0);
    set(FIG.bg2.spl.dB80, 'value',0);
    
    Stimuli.atten2_dB = floor(-get(FIG.asldr2.slider,'value'));
    set(FIG.asldr2.val,'string',num2str(-Stimuli.atten2_dB));
    %     set_RP_tagvals(RP1, RP2, FFR_SNRenv_Gating, Stimuli);
    %     FFR_set_attns(Stimuli.atten_dB,-120,Stimuli.channel,Stimuli.KHosc,RP1,RP2);
    
    Stimuli.calib_levelSPL2 = Stimuli.calib_dBSPLout2-Stimuli.atten2_dB;

    set(FIG.asldr2.SPL,'string',sprintf('%.1f dB SPL',Stimuli.calib_dBSPLout2-abs(get(FIG.asldr2.slider,'val'))));
    FFRwav2('attenCalib');
    
    % LQ 01/31/05
elseif strcmp(command_str, 'slide_atten_text')
    FIG.NewStim = 2;
    
    set(FIG.bg.spl.dB65, 'value',0);
    set(FIG.bg.spl.dB80, 'value',0);
    
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
    Stimuli.calib_levelSPL = Stimuli.calib_dBSPLout-Stimuli.atten_dB;
    
    set(FIG.asldr.SPL,'string',sprintf('%.1f dB SPL',Stimuli.calib_dBSPLout-abs(get(FIG.asldr.slider,'val'))));
    FFRwav2('attenCalib');
 
elseif strcmp(command_str, 'slide_atten_text2')
    FIG.NewStim = 2;
    
    set(FIG.bg2.spl.dB65, 'value',0);
    set(FIG.bg2.spl.dB80, 'value',0);
    
    new_atten = get(FIG.asldr2.val, 'string');
    if new_atten(1) ~= '-'
        new_atten = ['-' new_atten];
        set(FIG.asldr2.val,'string', new_atten);
    end
    new_atten = str2double(new_atten);
    if new_atten < get(FIG.asldr2.slider,'min') || new_atten > get(FIG.asldr2.slider,'max')
        set( FIG.asldr2.val, 'string', num2str(-Stimuli.atten2_dB));
    else
        Stimuli.atten2_dB = -new_atten;
        set(FIG.asldr2.slider, 'value', new_atten);
    end
    
    %     FFR_set_attns(Stimuli.atten_dB,-120,Stimuli.channel,Stimuli.KHosc,RP1,RP2);
    %     set_RP_tagvals(RP1, RP2, FFR_SNRenv_Gating, Stimuli);
    Stimuli.calib_levelSPL2 = Stimuli.calib_dBSPLout2-Stimuli.atten2_dB;
    
    set(FIG.asldr2.SPL,'string',sprintf('%.1f dB SPL',Stimuli.calib_dBSPLout2-abs(get(FIG.asldr2.slider,'val'))));
    FFRwav2('attenCalib');
    
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
        calib_type=questdlg('Select which Calib','Calibration','FPL','SPL','SPL');
        NelData.
        cdd;
        switch calib_type
            case 'SPL'
                allCalibFiles= dir('*calib_raw*');
            case 'FPL'
                allCalibFiles= dir('*calib_FPL_raw*');
        end
        
        Stimuli.calibPicNum= getPicNum(allCalibFiles(end).name);
        Stimuli.calibPicNum= str2double(inputdlg('Enter RAW Calibration File Number (default = last raw calib)','Load Calib File', 1,{num2str(Stimuli.calibPicNum)}));
        rdd;
    end
    
    Stimuli.invCalib=get(FIG.radio.invCalib,'value');
    %INV FILTER WILL ALWAYS BE ON. DISABLING ABILITY TO TOGGLE FOR NOW.
    if get(FIG.radio.invCalib,'value')    
        if Stimuli.channel == 1 & Stimuli.channel2 == 1  % both ONLY right side
            TEMPchannel=1;
        elseif Stimuli.channel == 2 & Stimuli.channel2 == 2  % both ONLY left side
            TEMPchannel=2;
        else   % all other options mean inv calib needs torun on both
            TEMPchannel=3;
        end 
        
        switch TEMPchannel
            case 1 %right side
                if strcmp(calib_type,'SPL')
                    filttype = {'allstop','inversefilt'};
                elseif strcmp(calib_type,'FPL')
                    filttype = {'allstop','inversefilt_FPL'};
                end
            case 2 %left side
                if strcmp(calib_type,'SPL')
                    filttype = {'inversefilt','allstop'}; 
                elseif strcmp(calib_type,'FPL')
                    filttype = {'inversefilt_FPL','allstop'};
                end
            case 3 %both sides
                if strcmp(calib_type,'SPL')
                    filttype = {'inversefilt','inversefilt'};
                elseif strcmp(calib_type,'FPL') 
                    filttype = {'inversefilt_FPL','inversefilt_FPL'};
                end
                
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
        FFRwav2('close');
    end
    
    if r_present && ~l_present
        FIG.NewStim = 5;
        Stimuli.channel = 1;
        Stimuli.ear='right';
        set(FIG.radio.right,'value',1);
        set(FIG.radio.left,'value',0);
        set(FIG.radio.both,'value',0);
        Stimuli.channel2 = 1;
        Stimuli.ear2='right';
        set(FIG.radio.right2,'value',1);
        set(FIG.radio.left2,'value',0);
        set(FIG.radio.both2,'value',0);
        
    elseif l_present && ~r_present
        FIG.NewStim = 5;
        Stimuli.channel = 2;
        Stimuli.ear='left';
        set(FIG.radio.left,'value',1);
        set(FIG.radio.right,'value',0);
        set(FIG.radio.both,'value',0);
        Stimuli.channel2 = 2;
        Stimuli.ear2='left';
        set(FIG.radio.left2,'value',1);
        set(FIG.radio.right2,'value',0);
        set(FIG.radio.both2,'value',0);
    end
    
    if ~r_present
        set(FIG.radio.right,'Enable','off');
        set(FIG.radio.right2,'Enable','off');
    end
    
    if ~l_present
        set(FIG.radio.left,'Enable','off')
        set(FIG.radio.left2,'Enable','off')
    end
    
    if ~(l_present && r_present)
        set(FIG.radio.both,'Enable','off')
        set(FIG.radio.both2,'Enable','off')
    end
    
    set(FIG.radio.invCalib,'UserData',invfiltdata); 
    FFRwav2('attenCalib');

    
    
    
    
    
    
    
    
    %% STILL NEED TO DO
 elseif strcmp(command_str,'attenCalib') %AS/MH/MP | Sprint 2023 Update
    cdd;
    invfiltdata = get(FIG.radio.invCalib,'UserData'); 
    cal = loadpic(invfiltdata.CalibPICnum2use);  % use INVERSE calib to compute MAX dB SPL
    rdd;
    
    [sig, fs] =audioread([Stimuli.UPDdir Stimuli.filename]);
    [sig2, fs2] =audioread([Stimuli.UPDdir Stimuli.filename2]);
    curDir= pwd;
    cdd;
    cd(curDir);

    
    %RIGHT NOW ONLY USING ONE CALIB CURVE TO CALIBRATE OTHER.....
    
    if ~strcmpi(Stimuli.ear,'both')
        
        %find and choose the appropriate left or right calib
        calib_to_use = contains(cal.ear_ord,string(Stimuli.ear),'IgnoreCase',true);
        calib_to_use = find(calib_to_use);
        
        if calib_to_use == 2
            CalibData=cal.CalibData2(:,1:2);
        else
            CalibData = cal.CalibData(:,1:2);
        end
    else %both ears
        %use mean of the inv calib curves
        CalibData(:,1) = cal.CalibData(:,1);
        CalibData(:,2) = (cal.CalibData(:,2)+cal.CalibData2(:,2))/2;
    end
    
    Stimuli.calib_dBSPLout= get_SPL_from_calib(sig, fs, CalibData, false);
    set(FIG.asldr.SPL,'string',sprintf('%.1f dB SPL',Stimuli.calib_dBSPLout-abs(str2double(get(FIG.asldr.val, 'string'))))); 
   
%     set(FIG.asldr.SPL, 'string', sprintf('%.1f dB SPL', Stimuli.MaxdBSPLCalib-Stimuli.atten_dB));    
    
    if ~strcmpi(Stimuli.ear2,'both')
        
        %find and choose the appropriate left or right calib
        calib_to_use = contains(cal.ear_ord,string(Stimuli.ear2),'IgnoreCase',true);
        calib_to_use = find(calib_to_use);
        
        if calib_to_use == 2
            CalibData=cal.CalibData2(:,1:2);
        else
            CalibData = cal.CalibData(:,1:2);
        end
    else %both ears
        %use mean of the inv calib curves
        CalibData(:,1) = cal.CalibData(:,1);
        CalibData(:,2) = (cal.CalibData(:,2)+cal.CalibData2(:,2))/2;
    end
    
    Stimuli.calib_dBSPLout2= get_SPL_from_calib(sig2, fs2, CalibData, false);
    set(FIG.asldr2.SPL,'string',sprintf('%.1f dB SPL',Stimuli.calib_dBSPLout2-abs(str2double(get(FIG.asldr2.val, 'string'))))); 


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
