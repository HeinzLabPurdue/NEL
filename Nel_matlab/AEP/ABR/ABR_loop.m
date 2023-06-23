%global root_dir NelData

if Stimuli.clickYes==1  %KH 06Jan2012
    clickAmp=5; toneAmp=0;
    CAP_Gating.duration_ms=Stimuli.clickLength_ms;
else
    clickAmp=0; toneAmp=5;
    if get(FIG.radio.fast, 'value') == 1
        CAP_Gating.duration_ms=Stimuli.fast.duration_ms;
    else
        CAP_Gating.duration_ms=Stimuli.slow.duration_ms;
    end
end


%% For stimulus
% RP1=actxcontrol('RPco.x',[0 0 1 1]);
% invoke(RP1,'ConnectRP2',NelData.General.TDTcommMode,1);
RP1= connect_tdt('RP2', 1);
invoke(RP1,'ClearCOF');
invoke(RP1,'LoadCOF',[prog_dir '\object\CAP_left.rcx']);

% if get(FIG.radio.tone,'value')
invoke(RP1,'SetTagVal','freq',Stimuli.freq_hz);
invoke(RP1,'SetTagVal','FixedPhase',Stimuli.fixedPhase);
invoke(RP1,'SetTagVal','toneAmp',toneAmp); %KH 06Jan2012
invoke(RP1,'SetTagVal','clickAmp',clickAmp); %KH 06Jan2012

% elseif get(FIG.radio.noise,'value')
%     invoke(RP1,'SetTagVal','tone',0);
% elseif get(FIG.radio.khite,'value')
%     invoke(RP1,'SetTagVal','tone',2);
% end

invoke(RP1,'SetTagVal','StmOn',CAP_Gating.duration_ms);
invoke(RP1,'SetTagVal','StmOff',CAP_Gating.period_ms-CAP_Gating.duration_ms);
invoke(RP1,'SetTagVal','RiseFall',CAP_Gating.rftime_ms);
invoke(RP1,'Run');


if NelData.General.RP2_3and4 && (~NelData.General.RX8) % NEL1 with RP2 #3 & #4
    %% For bit select (RP2#3 is not connected to Mix/Sel). So have to use RP2#2. May use RP2#1?
    %     RP2=actxcontrol('RPco.x',[0 0 1 1]);
    %     invoke(RP2,'ConnectRP2',NelData.General.TDTcommMode,2);
    RP2= connect_tdt('RP2', 2);
    invoke(RP2,'LoadCOF',[prog_dir '\object\CAP_BitSet.rcx']);
    invoke(RP2,'Run');
    
    %% For ADC (data in)
    %     RP3=actxcontrol('RPco.x',[0 0 1 1]);
    %     invoke(RP3,'ConnectRP2',NelData.General.TDTcommMode,3);
    RP3= connect_tdt('RP2', 3);
    invoke(RP3,'ClearCOF');
    invoke(RP3,'LoadCOF',[prog_dir '\object\ABR_right.rcx']);

elseif ~(NelData.General.RP2_3and4) && (~NelData.General.RX8) % NEL1 without (RP2 #3 & #4), and not NEL2 because no RX8
    %     RP2=actxcontrol('RPco.x',[0 0 1 1]);
    %     invoke(RP2,'ConnectRP2',NelData.General.TDTcommMode,2);
    RP2= connect_tdt('RP2', 2);
    
    RP3= RP2;
    invoke(RP3,'ClearCOF');
    invoke(RP3,'LoadCOF',[prog_dir '\object\CAP_right.rcx']);

elseif NelData.General.RX8  %NEL2 with RX8
    %     RP2=actxcontrol('RPco.x',[0 0 1 1]);
    %     invoke(RP2,'ConnectRP2',NelData.General.TDTcommMode,2);
    RP2= connect_tdt('RP2', 2);
    invoke(RP2,'LoadCOF',[prog_dir '\object\CAP_BitSet.rcx']);
    invoke(RP2,'Run');
    
    RP3= connect_tdt('RX8', 1);
    invoke(RP3,'ClearCOF');
    %invoke(RP3,'LoadCOF',[prog_dir '\object\ABR_RX8_ADC_invCalib.rcx']);
    invoke(RP3,'LoadCOF',[prog_dir '\object\ABR_RX8_ADC_invCalib_2chan.rcx']); %JMR 2 channel setup
    %     [~, ~, b_invCalib_coef]= run_invCalib(-2);
    b_invCalib_coef= [1 zeros(1, 255)];
    e_invCalib_status= RP3.WriteTagV('FIR_Coefs', 0, b_invCalib_coef);
else
    nelerror('Cannot figure out whether NEL1 or NEL2')
end

invoke(RP3,'SetTagVal','ADdur', CAP_Gating.CAPlength_ms);
invoke(RP3,'Run');
Stimuli.RPsamprate_Hz= RP3.GetSFreq; % 12207.03125;  % Hard coded for now, eventually get from RP

AEP_set_attns(Stimuli.atten_dB,Stimuli.channel,Stimuli.KHosc,RP1,RP2);  %% debug deal with later Khite
CAPnpts=floor(CAP_Gating.CAPlength_ms/1000*Stimuli.RPsamprate_Hz); % SP: Changed from ceil to floor on 21Aug19: one extra point was collected in ABR serial buffer
if Stimuli.CAPmem_reps>0
    CAP_memFact=exp(-1/Stimuli.CAPmem_reps);
else
    CAP_memFact=0;
end
firstSTIM=1;
veryfirstSTIM=1;  % The very first CAPdata when program starts is all zeros, so skip this, debug later MH 18Nov2003

while isempty(get(FIG.push.close,'Userdata'))
    if (ishandle(FIG.ax.axis))
        delete(FIG.ax.axis);
    end
    FIG.ax.axis = axes('position',[.35 .34 .525 .62]);
    if Stimuli.rec_channel>2 %simultaneous recording
        FIG.ax.line = plot(0,0,'-',0,0,'-',0,0,'-',0,0,'-'); %ADDING INVERSE LINE + ECochG: JMR 2021
        set(FIG.ax.line(1),'MarkerSize',2,'Color','k');
        set(FIG.ax.line(2),'MarkerSize',2,'Color',[0.6 0.6 0.6]);
        set(FIG.ax.line(3),'MarkerSize',2,'Color','b');
        set(FIG.ax.line(4),'MarkerSize',2,'Color',[0.9 .1 1]);
    else % standard 1 channel recording
        FIG.ax.line = plot(0,0,'-',0,0,'-'); %ADDING INVERSE LINE + ECochG: JMR 2021
        set(FIG.ax.line(1),'MarkerSize',2,'Color','k');
        set(FIG.ax.line(2),'MarkerSize',2,'Color',[0.6 0.6 0.6]);
        clear FIG.ax.line(3) FIG.ax.line(4)
        %set(FIG.ax.line(3),'MarkerSize',2,'Color','b');
        %set(FIG.ax.line(4),'MarkerSize',2,'Color',[0.9 .1 1]);
    end
    
    xlim([CAP_Gating.XstartPlot_ms/1000 CAP_Gating.XendPlot_ms/1000]);
    ylim([-Display.YLim Display.YLim]);  % ge debug: set large enough for A/D input range
    %   axis([CAP_Gating.XstartPlot_ms/1000 .010 -1 1]);  % ge debug: set large enough for A/D input range
    %    set(FIG.ax.axis,'XTick',[0:.25:1]);
    %    set(FIG.ax.axis,'YTick',[-5:1:5]);
    set(FIG.ax.axis,'XTickMode','auto');
    set(FIG.ax.axis,'YTickMode','auto');
    %    ylim('auto');
    xlabel('Time (sec)','fontsize',12,'FontWeight','Bold');
    if Stimuli.rec_channel>2
        legend('Chan 1','Chan 1 invert','Chan 2','Chan 2 invert','location','northeast');
    elseif Stimuli.rec_channel==2
        legend('Chan 2','Chan 2 invert','location','northeast');
    else
        legend('Chan 1','Chan 1 invert','location','northeast');
    end
    if strcmp(Display.Voltage,'atELEC')
        FIG.ax.ylabel=ylabel('Voltage at Electrode (V)','fontsize',12,'FontWeight','Bold');
    else
        FIG.ax.ylabel=ylabel('Voltage at AD (V)','fontsize',12,'FontWeight','Bold');
    end
    text(CAP_Gating.period_ms/2000,-33,'Frequency (Hz)','fontsize',12,'horizontalalignment','center');
    text(CAP_Gating.period_ms/2000,-49,'Attenuation (dB)','fontsize',12,'horizontalalignment','center');
    box on;
    
    %New axes for showing maximum of each input waveform - KH 2011 Jun 08
    FIG.ax.axis2 = axes('position',[.925 .34 .025 .62]);
    if Stimuli.rec_channel>2 % simultaneous
        FIG.ax.line2 = plot(0.4,0,'r*',[0 1],[Stimuli.threshV Stimuli.threshV],':r',0.6,0,'b*',[0 1],[Stimuli.threshV2 Stimuli.threshV2],':b');
    else
        FIG.ax.line2 = plot(0.5,0,'r*',[0 1],[Stimuli.threshV Stimuli.threshV],':r');
        clear FIG.ax.line2(3) FIG.ax.line2(4)
    end
    xlim([0 1]); ylim([0 10]);
    set(FIG.ax.axis2,'XTickMode','auto');
    set(FIG.ax.axis2,'YTickMode','auto');
    ylabel('Max AD Voltage (1 rep)','fontsize',12,'FontWeight','Bold');
    box on;
    
    demean_flag= 1; % set 0 to not demean
    
    
    invoke(RP1,'SoftTrg',1);
    %    tspan = CAP_Gating.period_ms/1000;
    bAbort = 0;
    while(1)  % loop until "close" request
        %%
        % ---------------------------------------------------------------------------------------------------------------------------------------
        % Start: Main body. excluding interrupt for FIG.push.close or FIG.NewStim
        % ---------------------------------------------------------------------------------------------------------------------------------------
        if(invoke(RP3,'GetTagVal','BufFlag') == 1)
            CAPdata = invoke(RP3,'ReadTagV','ADbuf',0,CAPnpts);   % ABR | Chan1
            CAPdata2 = invoke(RP3,'ReadTagV','ADbuf2',0,CAPnpts); % ECochG Added JMR Sept 2021 | Chan2
            %           CAPdata = ones(size(CAPdata)); % ge debug
            
            CAPobs=max(abs(CAPdata(1:end-2)-demean_flag*mean(CAPdata(1:end-2)))); %KH 08Jun2011
            CAPobs2=max(abs(CAPdata2(1:end-2)-demean_flag*mean(CAPdata2(1:end-2)))); %ECochG artefact
            
            %CAPobs2=max(abs(CAPdata2(1:end-2)-demean_flag*mean(CAPdata2(1:end-2)))); 
            % ^^ added SP (because there is a dc shift probably affects the whole signal except the last point)
            
            if ~veryfirstSTIM  % MH 18Nov2003 Skip very first, all zeros
                % Forgetting AVG - on first rep, set AVG=REP, otherwise, add with exponential weighting
                if ~firstSTIM
                    
                    if CAPobs <= Stimuli.threshV  %KH 2011 June 08 - artifact rejection
                        CAPdataAvg_freerun = CAP_memFact * CAPdataAvg_freerun ...
                            + (1 - CAP_memFact)*CAPdata;
                        CAPdataAvg_freerun=CAPdataAvg_freerun-demean_flag*mean(CAPdataAvg_freerun); %added demean SP Aug 21 2018
                        
                        %ECochG channel
                        CAPdataAvg_freerun2 = CAP_memFact * CAPdataAvg_freerun2 ...
                            + (1 - CAP_memFact)*CAPdata2;
                        CAPdataAvg_freerun2=CAPdataAvg_freerun2-demean_flag*mean(CAPdataAvg_freerun2); %added demean SP Aug 21 2018
                    end
                    
                else
                    CAPdataAvg_freerun = CAPdata;
                    CAPdataAvg_freerun2 = CAPdata2; %ECochG channel JMR
                    firstSTIM=0;
                end
                %                 set(FIG.ax.line,'xdata',[0:(1/Stimuli.RPsamprate_Hz):CAP_Gating.CAPlength_ms/1000], ...
                %                     'ydata',CAPdataAvg_freerun*Display.PlotFactor);
                %set(FIG.ax.line(2),'xdata',(1:length(CAPdataAvg_freerun))/Stimuli.RPsamprate_Hz, ...
                %    'ydata',CAPdataAvg_freerun*Display.PlotFactor);
                if Stimuli.rec_channel>2
                set(FIG.ax.line(1),'xdata',(1:length(CAPdataAvg_freerun))/Stimuli.RPsamprate_Hz, ...
                    'ydata',CAPdataAvg_freerun*Display.PlotFactor);
                set(FIG.ax.line(3),'xdata',(1:length(CAPdataAvg_freerun2))/Stimuli.RPsamprate_Hz, ...
                    'ydata',CAPdataAvg_freerun2*Display.PlotFactor);
                set(FIG.ax.line(2),'xdata',[], ...
                    'ydata',[]);                
                set(FIG.ax.line(4),'xdata',[], ...
                    'ydata',[]);   
                
                
                set(FIG.ax.line2(1),'ydata',CAPobs-demean_flag*mean(CAPobs)); %KH 10Jan2012 % added demean SP (Aug 21 2018)
                set(FIG.ax.line2(3),'ydata',CAPobs2-demean_flag*mean(CAPobs2));
                elseif Stimuli.rec_channel==2 % only channel 2
                    set(FIG.ax.line(1),'xdata',(1:length(CAPdataAvg_freerun2))/Stimuli.RPsamprate_Hz, ...
                        'ydata',CAPdataAvg_freerun2*Display.PlotFactor);
                    set(FIG.ax.line(3),'xdata',[], ...
                        'ydata',[]);
                    set(FIG.ax.line(2),'xdata',[], ...
                        'ydata',[]);
                    set(FIG.ax.line(4),'xdata',[], ...
                        'ydata',[]);
                    
                    
                    set(FIG.ax.line2(1),'ydata',CAPobs2-demean_flag*mean(CAPobs2)); %KH 10Jan2012 % added demean SP (Aug 21 2018)
                    %set(FIG.ax.line2(3),'ydata',CAPobs2-demean_flag*mean(CAPobs2));
                else  % only channel 1
                    set(FIG.ax.line(1),'xdata',(1:length(CAPdataAvg_freerun))/Stimuli.RPsamprate_Hz, ...
                        'ydata',CAPdataAvg_freerun*Display.PlotFactor);
                    set(FIG.ax.line(3),'xdata',[], ...
                        'ydata',[]);
                    set(FIG.ax.line(2),'xdata',[], ...
                        'ydata',[]);
                    set(FIG.ax.line(4),'xdata',[], ...
                        'ydata',[]);
                    
                    set(FIG.ax.line2(1),'ydata',CAPobs-demean_flag*mean(CAPobs)); %KH 10Jan2012 % added demean SP (Aug 21 2018)
                    %set(FIG.ax.line2(3),'xdata',[],'ydata',[]);
                    %set(FIG.ax.line2(4),'xdata',[],'ydata',[]);
                    
                end
                % legend update
                if Stimuli.rec_channel>2
                    legend(FIG.ax.line,'Chan 1','Chan 1 invert','Chan 2','Chan 2 invert','location','northeast');
                elseif Stimuli.rec_channel==2
                    legend(FIG.ax.line,'Chan 2','Chan 2 invert','location','northeast');
                else
                    legend(FIG.ax.line,'Chan 1','Chan 1 invert','location','northeast');
                end
                
                drawnow;
            else
                veryfirstSTIM=0;
            end
            invoke(RP3,'SoftTrg',2);
        end
        % ---------------------------------------------------------------------------------------------------------------------------------------
        % END: Main body. Excluding interrupt for FIG.push.close or FIG.NewStim
        % ---------------------------------------------------------------------------------------------------------------------------------------
        
        %% Interrupts during freerun
        if get(FIG.push.close,'Userdata')
            break;
        elseif FIG.NewStim
            switch FIG.NewStim
                
                case 1
                    invoke(RP1,'SetTagVal','freq',Stimuli.freq_hz);
                    invoke(RP1,'SetTagVal','tone',1);
                    AEP_set_attns(Stimuli.atten_dB,Stimuli.channel,Stimuli.KHosc,RP1,RP2);
                case 2
                    invoke(RP1,'SetTagVal','tone',0);
                    AEP_set_attns(Stimuli.atten_dB,Stimuli.channel,Stimuli.KHosc,RP1,RP2);
                case 3
                    AEP_set_attns(Stimuli.atten_dB,Stimuli.channel,Stimuli.KHosc,RP1,RP2);
                case 4
                    invoke(RP1,'SetTagVal','StmOn',CAP_Gating.duration_ms);
                    invoke(RP1,'SetTagVal','StmOff',CAP_Gating.period_ms-CAP_Gating.duration_ms);
                    invoke(RP3,'SetTagVal','ADdur',CAP_Gating.CAPlength_ms);
                    CAPnpts=floor((CAP_Gating.CAPlength_ms/1000)*Stimuli.RPsamprate_Hz);
                    firstSTIM = 1;
                    FIG.NewStim = 0;
                    break
                case 5
                    AEP_set_attns(Stimuli.atten_dB,Stimuli.channel,Stimuli.KHosc,RP1,RP2);
                case 6
                    invoke(RP1,'SetTagVal','freq',Stimuli.freq_hz);
                case 7
                    AEP_set_attns(Stimuli.atten_dB,Stimuli.channel,Stimuli.KHosc,RP1,RP2);
                case 8
                    invoke(RP1,'SetTagVal','FixedPhase',Stimuli.fixedPhase);
                case 9
                    if Stimuli.CAPmem_reps>0
                        CAP_memFact=exp(-1/Stimuli.CAPmem_reps);
                    else
                        CAP_memFact=0;
                    end
                case 10 % Stimulate and acquire CAP curves at levels based on AttenMask around the current freq/atten combo.
                    
                    runAudiogram=0; %KH 10Jan2012
                    
                    ABR_RunLevels;
                    veryfirstSTIM=1;
                    
                    if AutoLevel_params.dB5Flag
                        FIG.NewStim = 17;
                        break;
                    end
                    
                case 11 % Make "free-run" forget previous averages.
                    firstSTIM = 1;
                case 12 % Change Voltage Display
                    if strcmp(Display.Voltage,'atELEC')
                        set(FIG.ax.ylabel,'String','Voltage at Electrode (V)')
                        Display.PlotFactor=1/Display.Gain;
                        Display.YLim=Display.YLim_atAD/Display.Gain;
                    else
                        set(FIG.ax.ylabel,'String','Voltage at AD (V)')
                        Display.PlotFactor=1;
                        Display.YLim=Display.YLim_atAD;
                    end
                    set(FIG.ax.axis,'Ylim',[-Display.YLim Display.YLim])
                    
                case 13 %KH 08Jun2011
                    if Stimuli.rec_channel>2
                    set(FIG.ax.line2(2),'ydata',[Stimuli.threshV Stimuli.threshV]);
                    set(FIG.ax.line2(4),'ydata',[Stimuli.threshV2 Stimuli.threshV2]);
                    elseif Stimuli.rec_channel==2
                        set(FIG.ax.line2(1),'xdata',0.5)
                        set(FIG.ax.line2(2),'ydata',[Stimuli.threshV2 Stimuli.threshV2]);
                        set(FIG.ax.line2(4),'xdata',[],'ydata',[]);
                    else
                        set(FIG.ax.line2(2),'ydata',[Stimuli.threshV Stimuli.threshV]);
                        set(FIG.ax.line2(4),'xdata',[],'ydata',[]);   
                    end
                    drawnow;
                    
                case 15 % Runs through Stimuli.audiogramFreqs at levels specified, KH 10Jan2012
                    runAudiogram=1;
                    ABR_RunLevels;
                    veryfirstSTIM=1;
                    
                case 16 % KH 10Jan2012, switch between click and tone
                    if Stimuli.clickYes==1
                        clickAmp=5; toneAmp=0;
                        CAP_Gating.duration_ms=Stimuli.clickLength_ms;
                    else
                        clickAmp=0; toneAmp=5;
                        if get(FIG.radio.fast, 'value') == 1
                            CAP_Gating.duration_ms=Stimuli.fast.duration_ms;
                        else
                            CAP_Gating.duration_ms=Stimuli.slow.duration_ms;
                        end
                    end
                    invoke(RP1,'SetTagVal','toneAmp',toneAmp);
                    invoke(RP1,'SetTagVal','clickAmp',clickAmp);
                    invoke(RP1,'SetTagVal','StmOn',CAP_Gating.duration_ms);
                    invoke(RP1,'SetTagVal','StmOff',CAP_Gating.period_ms-CAP_Gating.duration_ms);
                case 18
                    if Stimuli.rec_channel>2
                        FIG.ax.line2 = plot(0.4,0,'r*',[0 1],[Stimuli.threshV Stimuli.threshV],':r',0.6,0,'b*',[0 1],[Stimuli.threshV2 Stimuli.threshV2],':b');
                        set(FIG.ax.line2(1),'xdata',0.4)
                        set(FIG.ax.line2(3),'xdata',0.6)
                        set(FIG.ax.line2(2),'ydata',[Stimuli.threshV Stimuli.threshV]);
                        set(FIG.ax.line2(4),'ydata',[Stimuli.threshV2 Stimuli.threshV2]);
                    elseif Stimuli.rec_channel==2
                        FIG.ax.line2 = plot(0.5,0,'r*',[0 1],[Stimuli.threshV Stimuli.threshV],':r');
                        if length(FIG.ax.line2)>2
                        clear FIG.ax.line2(3) FIG.ax.line2(4)
                        end
                        set(FIG.ax.line2(1),'xdata',0.5)
                        set(FIG.ax.line2(2),'ydata',[Stimuli.threshV2 Stimuli.threshV2]);

                    else
                        FIG.ax.line2 = plot(0.5,0,'r*',[0 1],[Stimuli.threshV Stimuli.threshV],':r');
                        if length(FIG.ax.line2)>2
                        clear FIG.ax.line2(3) FIG.ax.line2(4)
                        end
                        set(FIG.ax.line2(2),'ydata',[Stimuli.threshV Stimuli.threshV]);

                    end
                    
                    xlim([0 1]); ylim([0 10]);
                    
                    set(FIG.ax.axis2,'XTickMode','auto');
                    set(FIG.ax.axis2,'YTickMode','auto');
                    ylabel('Max AD Voltage (1 rep)','fontsize',12,'FontWeight','Bold');
                    box on;

                    drawnow;
                case 17 % SP 24Jan2016, Automatic Levels Run
                    if ~AutoLevel_params.dB5Flag
                        runAudiogram=0; %KH 10Jan2012  % Don't know why it should be here
                        ABR_AutoLevels;
                        veryfirstSTIM=1;
                        
                        if (bAbort == 1)
                            FIG.NewStim = 0;
                            break;
                        end
                        
                        if (SaveFlag == 0)
                            FIG.NewStim = 0;
                            PAset([120;120;120;120]);
                            break;
                        end
                       
                            
                        %COMMENTED BY JMR Sept 21
%                         if ~AutoLevel_params.ReRunFlag  % <1> Case when runs for the first time afrer MANthresh-20:MANthresh+50
%                             % calculates autoThresh silently, runs the 5 dB step around autoThresh
%                             %% Change to min(90,thresh+50) <to-do SP>
%                             picNUMlist=NelData.File_Manager.picture-fliplr((1:AutoLevel_params.numAttens_1)-1);
%                             dBSPLlist=fliplr(AutoLevel_params.maxdBSPLtoRUN -((1:AutoLevel_params.numAttens_1)-1)*AutoLevel_params.stepdB);
%                             lastdBSPL=60; %AutoLevel_params.ManThresh_dBSPL+AutoLevel_params.dBaboveTHRman_for_autoTHRcorr;
%                             % Added SP (Sep 10, 2018) % May have to change depending on PTS/ NH
%                             [xx,lastdBindex]=min(abs(dBSPLlist-lastdBSPL));
%                             picstoSEND=picNUMlist(1:lastdBindex);  % list of PICS to send to Ken's code to avoid usinig too high an SPL for template
%                             
%                             CalibPIC= Stimuli.calibPicNum;
%                             dataDIR=NelData.File_Manager.dirname;
%                                                         
%                             AutoLevel_params.AutoThresh1=main_abr_bb(dataDIR,CalibPIC,picstoSEND);
%                             
%                             if isnan(AutoLevel_params.AutoThresh1)
%                                 AutoLevel_params.AutoThresh1=25;
%                                 disp('You must be debuggin, else something is wrong!');
%                                 ding;
%                             elseif AutoLevel_params.AutoThresh1<0
%                                 AutoLevel_params.AutoThresh1=25;
%                                 disp('You must be debuggin, else something is wrong!');
%                                 ding;
%                             elseif AutoLevel_params.AutoThresh1>80
%                                 AutoLevel_params.AutoThresh1=25;
%                                 disp('You must be debuggin, else something is wrong!');
%                                 ding;
%                             end
%                             
%                             Stimuli.atten_dB= Stimuli.MaxdBSPLCalib-(5+10*floor(AutoLevel_params.AutoThresh1/10));
%                             
%                             FIG.NewStim = 10;
%                             AutoLevel_params.dB5Flag=1;
%                             break;
%                             % It goes to run_level and runs the 5dB step
%                         else % <3> To run the user defined levels
%                             FIG.NewStim = 17;
%                             AutoLevel_params.dB5Flag=1;
%                             break;
%                         end

                    else
                        AutoLevel_params.dB5Flag=0;
                        
                        if (SaveFlag == 0)
                            FIG.NewStim = 0;
                            AutoLevel_params.dB5Flag=0;
                            rc = PAset([120;120;120;120]);
                            break;
                        end
                        
                        if AutoLevel_params.ReRunFlag % After rerun
                            AutoLevel_params.ReRunFlag=0;
                            global FLAG_RERUN_FOR_ABR_ANALYSIS % Need to remove these global-vars
                            FLAG_RERUN_FOR_ABR_ANALYSIS=1;
                            
                            picNUMlist=[picNUMlist NelData.File_Manager.picture-fliplr((1:AutoLevel_params.numAttens_1)-1)];
                            dBSPLlist=[dBSPLlist rerunSPLs];
                            lastdBSPL=AutoLevel_params.AutoThresh1+AutoLevel_params.dBaboveTHRman_for_autoTHRcorr;
                            %% CHANGE MANthre
                            %                         [xx,lastdBindex]=min(abs(dBSPLlist-lastdBSPL));
                            %                         picstoSEND=[picstoSEND picNUMlist(1:lastdBindex)];  % list of PICS to send to Ken's code to avoid usinig too high an SPL for template
                            picstoSEND=picNUMlist;%(dBSPLlist<lastdBSPL);
                            %% on;y send less 65 - non monotonic
                            
                        else % <2> After 5dB step is run
                            
                            picstoSEND=[picstoSEND,NelData.File_Manager.picture]; % Check
                            picNUMlist=[picNUMlist,NelData.File_Manager.picture];
                            %                         dBSPLlist=[dBSPLlist,(Stimuli.MaxdBSPLCalib-Stimuli.atten_dB+Stimuli.cur_freq_calib_dbshift)];
                            %                         Commented SP on 9/25/19
                            dBSPLlist=[dBSPLlist,(Stimuli.MaxdBSPLCalib-Stimuli.atten_dB)];
                            
                        end
                        
                        global FLAG_ABR_ENTER_SP
                        FLAG_ABR_ENTER_SP=1;
                        
                        cur_dir=pwd;
                        abr_analysis_dir= [NelData.General.RootDir 'Users\SP\'];
                        cd(abr_analysis_dir);
                        abr_setup_SP;
                        abr_analysis_SP('process');
                        FLAG_ABR_ENTER_SP=0;
                        
                        rc = PAset([120;120;120;120]); % added by GE/MH, 17Jan2003.  To force all attens to 120
                        Stimuli.atten_dB = 120;
                        set(FIG.asldr.val,'string',num2str(-Stimuli.atten_dB));
                        set(FIG.asldr.SPL,'string',sprintf('%.1f dB SPL',Stimuli.MaxdBSPLCalib-Stimuli.atten_dB));
                        set(FIG.asldr.slider, 'value', -Stimuli.atten_dB);
                        
                        ButtonName=questdlg('Are you satisfied?', ...
                            'Close Prompt', ...
                            'Yes','No','Yes');
                        switch ButtonName
                            case 'Yes'
                                global data;
                                AutoLevel_params.AutoThresh2=data.threshold;
                                Stimuli.atten_dB = 120;
                                set(FIG.asldr.val,'string',num2str(-Stimuli.atten_dB));
                                set(FIG.asldr.SPL,'string',sprintf('%.1f dB SPL',Stimuli.MaxdBSPLCalib-Stimuli.atten_dB));
                                set(FIG.asldr.slider, 'value', -Stimuli.atten_dB);
                                set(FIG.asldr.SPL,'string',sprintf('%.1f dB SPL',Stimuli.MaxdBSPLCalib-Stimuli.atten_dB));
                            case 'No'
                                global rerunSPLs;
                                rerunSPLs=[];
                                h_checkbox=abr_checkbox;
                                uiwait(h_checkbox);
                                
                                [picstoSEND,picNUMlist,dBSPLlist]=update_pic_num_list_ABR(picstoSEND,picNUMlist,dBSPLlist,rerunSPLs);
                                
                                AutoLevel_params.ReRun_dBSPL=sort(rerunSPLs);
                                
                                FIG.NewStim = 17;
                                delete(findobj( 'Type', 'Figure', 'Name', 'ABR peaks' )); % Delete the ABR analysis plot
                                cd (cur_dir);
                                AutoLevel_params.ReRunFlag=1;
                                break;
                                
                        end
                        delete(findobj( 'Type', 'Figure', 'Name', 'ABR peaks' )); % Delete the ABR analysis plot
                        cd (cur_dir);
                    end
                case 18 % rec channel set
                    % don't know if we need this
                    
            end
            FIG.NewStim = 0;
        end
    end
end

Stimuli.KHosc = 0;    % added by GE/MH, 17Jan2003.  To force Krohn-Hite to disconnect.
AEP_set_attns(120,Stimuli.channel,Stimuli.KHosc,RP1,RP2);
rc = PAset([120;120;120;120]); % added by GE/MH, 17Jan2003.  To force all attens to 120

invoke(RP1,'Halt');
invoke(RP2,'Halt');
invoke(RP3,'Halt');

delete(FIG.handle);
clear FIG;