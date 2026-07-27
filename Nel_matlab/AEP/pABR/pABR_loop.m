global COMM prog_dir PROG data_dir NelData Stimuli filttype invfiltdata pABRstim ...
    RunLevels_params interface_type Display misc FFR_Gating

pABR_flag = 1;

stimRCXfName = [prog_dir '\object\pABRwav2_polIN.rcx'];

critVal  = Stimuli.threshV;
critVal2 = Stimuli.threshV2;

pABR_Lstim = pABRstim.leftEpochs;
pABR_Rstim = pABRstim.rightEpochs;

%pABRnpts = pABRstim.pABRnpts;
%pABRnpts = floor(pABRstim.Gating.pABRDur_ms/1000 * Stimuli.RPsamprate_Hz);
pABRnpts = size(pABR_Rstim,2);

freqLabels = {'0.5 kHz','1 kHz','2 kHz','4 kHz','8 kHz'};
rightY = [9.5 8.5 7.5 6.5 5.5];
leftY  = [3.7 2.7 1.7 0.7 -0.3];

%% Load circuits

if NelData.General.RP2_3and4 && (~NelData.General.RX8)
    
    invoke(RP1,'ClearCOF');
    invoke(RP1,'LoadCOF',stimRCXfName);
    
    invoke(RP2,'ClearCOF');
    invoke(RP2,'LoadCOF',[prog_dir '\object\FFR_BitSet.rcx']);
    invoke(RP2,'Run');
    
    invoke(RP3,'ClearCOF');
    invoke(RP3,'LoadCOF',[prog_dir '\object\RP2_3_2chan_phys.rcx']);
    invoke(RP3,'SetTagVal','ADdur',pABRstim.Gating.pABRDur_ms);
    invoke(RP3,'Run');
    
elseif (~NelData.General.RP2_3and4) && (~NelData.General.RX8)
    
    invoke(RP1,'ClearCOF');
    invoke(RP1,'LoadCOF',stimRCXfName);
    
    invoke(RP2,'ClearCOF');
    invoke(RP2,'LoadCOF',[prog_dir '\object\FFR_right2.rcx']);
    invoke(RP2,'SetTagVal','ADdur',pABRstim.Gating.pABRDur_ms);
    invoke(RP2,'Run');
    
elseif NelData.General.RX8
    
    invoke(RP1,'ClearCOF');
    invoke(RP1,'LoadCOF',stimRCXfName);
    
    invoke(RP2,'ClearCOF');
    invoke(RP2,'LoadCOF',[prog_dir '\object\FFR_BitSet.rcx']);
    invoke(RP2,'Run');
    
    RP3 = COMM.handle.RX8;
    invoke(RP3,'ClearCOF');
    
    invfilterdata = set_invFilter(filttype,Stimuli.calibPicNum);
    
    invoke(RP3,'SetTagVal','ADdur',pABRstim.Gating.pABRDur_ms);
    invoke(RP3,'Run');
end

%% Set pABR timing

invoke(RP1,'SetTagVal','StmOn',pABRstim.Gating.pABRDur_ms);
invoke(RP1,'SetTagVal','StmOff',pABRstim.Gating.Period_ms - pABRstim.Gating.pABRDur_ms);
invoke(RP1,'SetTagVal','RiseFall',pABRstim.Gating.rftime_ms);

%% Load ONE fixed pABR stimulus for free-run

activeStim = 1;

xpR = double(pABR_Rstim(activeStim,:));
xpL = double(pABR_Lstim(activeStim,:));

tmpR = invoke(RP1,'WriteTagV','STIM_R',0,xpR);
tmpL = invoke(RP1,'WriteTagV','STIM_L',0,xpL);

if tmpR ~= 1 || tmpL ~= 1
    error('Free-run pABR stimulus failed to load');
end

AEP_set_attns2(pABRstim.atten_dB,Stimuli.channel, ...
    pABRstim.atten2_dB,Stimuli.channel2,Stimuli.KHosc,RP1,RP2);

%% pABR plot setup

while isempty(get(FIG.push.close,'Userdata'))
    
    if (ishandle(FIG.ax.axis))
        delete(FIG.ax.axis);
    end
    
    FIG.ax.axis = axes('position',[.4 .34 .525 .62]);
    hold on;
    
    pABR_time = (0:pABRnpts-1)/Stimuli.RPsamprate_Hz;
    
    FIG.ax.line = plot( ...
        0,0,'-',0,0,'-',0,0,'-',0,0,'-',0,0,'-', ...
        0,0,'-',0,0,'-',0,0,'-',0,0,'-',0,0,'-');
    rightColor = [1 0 0];
    leftColor  = [0 0.25 1];
    for ii = 1:5
        set(FIG.ax.line(ii),'Color',rightColor,'LineWidth',1);
        set(FIG.ax.line(ii+5),'Color',leftColor,'LineWidth',1);
    end
    
    set(FIG.ax.axis, ...
        'YTick',[], ...
        'XLim',[0 (2*pABRstim.pad_ms)/1000], ...
        'YLim',[-0.9 10.3], ...
        'Box','off', ...
        'TickDir','out', ...
        'FontSize',12, ...
        'FontWeight','normal', ...
        'LineWidth',1);
    
    xlabel('Time (sec)','FontWeight','normal','FontSize',13);
    xMax = (2*pABRstim.pad_ms)/1000;
    dividerY = 4.65;
    
    plot([0 xMax],[dividerY dividerY],'--', ...
        'Color',[0.55 0.55 0.55], ...
        'LineWidth',1);
    
    text(xMax/2,10.0,'RIGHT EAR', ...
        'HorizontalAlignment','center', ...
        'FontWeight','Bold', ...
        'FontSize',7, ...
        'Color', rightColor);
    
    text(xMax/2,4.15,'LEFT EAR', ...
        'HorizontalAlignment','center', ...
        'FontWeight','Bold', ...
        'FontSize',7, ...
        'Color',leftColor);
    
    labelX = -0.00022;
    
    for ii = 1:5
        text(labelX,rightY(ii),freqLabels{ii}, ...
            'HorizontalAlignment','right', ...
            'FontWeight','normal', ...
            'FontSize',12, ...
            'Clipping','off');
        
        text(labelX,leftY(ii),freqLabels{ii}, ...
            'HorizontalAlignment','right', ...
            'FontWeight','normal', ...
            'FontSize',12, ...
            'Clipping','off');
    end
    
    %% Artifact monitor
    if (ishandle(FIG.ax.axis2))
        delete(FIG.ax.axis2);
    end
    FIG.ax.axis2 = axes('position',[.965 .34 .025 .62]);
    
    hold(FIG.ax.axis2,'on');
    
    FIG.ax.line2 = plot(0.35,0,'r*',0.65,0,'b*');
    
    set(FIG.ax.line2(1),'MarkerSize',7);
    set(FIG.ax.line2(2),'MarkerSize',7);
    
    plot([0 1],[Stimuli.threshV Stimuli.threshV],':r');
    plot([0 1],[Stimuli.threshV2 Stimuli.threshV2],':b');
    
    maxThresh = max([Stimuli.threshV Stimuli.threshV2]);
    
    xlim([0 1]);
    ylim([0 maxThresh+1]);
    
    set(FIG.ax.axis2, ...
        'XTick',[], ...
        'Box','on', ...
        'FontSize',9, ...
        'LineWidth',1);
    
    ylabel('Max AD Voltage','fontsize',12,'FontWeight','normal');
    
    
    %% Free-run variables
    
    currStim = 0;
    rejections = 0;
    
    firstPolResp1 = [];
    firstPolResp2 = [];
    secondPolResp1 = [];
    secondPolResp2 = [];
    
    %% Start pABR pulse train once
    
    invoke(RP1,'Run');
    invoke(RP1,'SoftTrg',1);
    
    %% Main free-run loop
    
    while(1)
        
        dataReadThisOff = false;
        
        while invoke(RP1,'GetTagVal','Stage') == 1
            if get(FIG.push.close,'Userdata')
                break;
            end
        end
        
        if get(FIG.push.close,'Userdata')
            break;
        end
        
        while invoke(RP1,'GetTagVal','Stage') == 2
            
            if get(FIG.push.close,'Userdata')
                break;
            end
            
            if ~dataReadThisOff && invoke(RP3,'GetTagVal','BufFlag') == 1
                
                pABRdata1 = invoke(RP3,'ReadTagV','ADbuf',0,pABRnpts);
                pABRdata2 = invoke(RP3,'ReadTagV','ADbuf2',0,pABRnpts);
                
                maxpABRobs1 = max(abs(pABRdata1));
                maxpABRobs2 = max(abs(pABRdata2));
                
                set(FIG.ax.line2(1),'ydata',maxpABRobs1);
                set(FIG.ax.line2(2),'ydata',maxpABRobs2);
                
                if ~isempty(pABRdata1) && ~isempty(pABRdata2) && ...
                        length(pABRdata1)==pABRnpts && ...
                        length(pABRdata2)==pABRnpts
                    
                    dataReadThisOff = true;
                    nextPresentation = currStim + 1;
                    
                    if invoke(RP1,'GetTagVal','ORG') == mod(nextPresentation,2) && ...
                            maxpABRobs1 <= critVal && maxpABRobs2 <= critVal2
                        
                        currStim = nextPresentation;
                        
                        if mod(currStim,2)
                            
                            firstPolResp1 = pABRdata1;
                            firstPolResp2 = pABRdata2;
                            
                        else
                            
                            secondPolResp1 = pABRdata1;
                            secondPolResp2 = pABRdata2;
                            
                            combinedResp1 = (firstPolResp1 + secondPolResp1)/2;
                            combinedResp2 = (firstPolResp2 + secondPolResp2)/2;
                            
                            combFreq_1 = pABRCC(combinedResp1, ...
                                squeeze(pABRstim.stimTrain(activeStim,1,:)));
                            
                            combFreq_2 = pABRCC(combinedResp2, ...
                                squeeze(pABRstim.stimTrain(activeStim,2,:)));
                            
                            rightResp = {
                                combFreq_1(1).response
                                combFreq_1(2).response
                                combFreq_1(3).response
                                combFreq_1(4).response
                                combFreq_1(5).response
                                };
                            
                            leftResp = {
                                combFreq_2(1).response
                                combFreq_2(2).response
                                combFreq_2(3).response
                                combFreq_2(4).response
                                combFreq_2(5).response
                                };
                            
                            datax = 0:(1/pABRstim.RPsamprate_Hz):(2*pABRstim.pad_ms)/1000;
                            newlen = min([ ...
                                length(datax),...
                                length(rightResp{1}), length(rightResp{2}), length(rightResp{3}), ...
                                length(rightResp{4}), length(rightResp{5}), ...
                                length(leftResp{1}), length(leftResp{2}), length(leftResp{3}), ...
                                length(leftResp{4}), length(leftResp{5})]);
                            datax = datax(1:newlen);
                            currentMax = 0;
                            
                            for kk = 1:5
                                currentMax = max([currentMax, ...
                                    max(abs(rightResp{kk}(1:newlen))), ...
                                    max(abs(leftResp{kk}(1:newlen)))]);
                            end
                            
                            plotHeight = 0.45;
                            Display.PlotFact = plotHeight/max(currentMax, eps);
                            if Stimuli.rec_channel > 2
                                for ff = 1:5
                                    set(FIG.ax.line(ff), ...
                                        'xdata',datax, ...
                                        'ydata',rightResp{ff}(1:newlen)*Display.PlotFact + rightY(ff));
                                    
                                    set(FIG.ax.line(ff+5), ...
                                        'xdata',datax, ...
                                        'ydata',leftResp{ff}(1:newlen)*Display.PlotFact+ leftY(ff));
                                end
                            elseif Stimuli.rec_channel == 1
                                for ff = 1:5
                                    set(FIG.ax.line(ff), ...
                                        'xdata',datax, ...
                                        'ydata',rightResp{ff}(1:newlen)*Display.PlotFact+ rightY(ff));
                                    
                                    set(FIG.ax.line(ff+5), ...
                                        'xdata',[], ...
                                        'ydata',[],'Visible', 'off');
                                end
                            elseif Stimuli.rec_channel == 2
                                for ff = 1:5
                                    set(FIG.ax.line(ff), ...
                                        'xdata',[], ...
                                        'ydata',[],'Visible', 'off');
                                    
                                    set(FIG.ax.line(ff+5), ...
                                        'xdata',datax, ...
                                        'ydata',leftResp{ff}(1:newlen)*Display.PlotFact+ leftY(ff));
                                end
                            end
                            
                            set(FIG.ax.axis,'XLim',[0 max(datax)]);
                            
                            
                            
                            drawnow;
                        end
                        
                    elseif maxpABRobs1 > critVal || maxpABRobs2 > critVal2
                        
                        rejections = rejections + 1;
                        
                    end
                end
                
                invoke(RP3,'SoftTrg',2);
            end
        end
        
        if get(FIG.push.close,'Userdata')
            break;
        end
        
        if FIG.NewStim
            
            switch FIG.NewStim
                
                case 0
                    
                    AEP_set_attns2(pABRstim.atten_dB,Stimuli.channel, ...
                        pABRstim.atten2_dB,Stimuli.channel2,Stimuli.KHosc,RP1,RP2);
                    
                case 1
                    
                    invoke(RP1,'SetTagVal','StmOn',pABRstim.Gating.pABRDur_ms);
                    invoke(RP1,'SetTagVal','StmOff',pABRstim.Gating.Period_ms - pABRstim.Gating.pABRDur_ms);
                    invoke(RP1,'SetTagVal','RiseFall',pABRstim.Gating.rftime_ms);
                    
                    currStim = 0;
                    rejections = 0;
                    
                    firstPolResp1 = [];
                    firstPolResp2 = [];
                    secondPolResp1 = [];
                    secondPolResp2 = [];
                    
                    for ii = 1:5
                        set(FIG.ax.line(ii),'xdata',[],'ydata',[]);
                        set(FIG.ax.line(ii+5),'xdata',[],'ydata',[]);
                    end
                    
                    set(FIG.ax.line2(1),'ydata',0);
                    set(FIG.ax.line2(2),'ydata',0);
                    
                    drawnow;
                    
                case 2
                    
                    invoke(RP1,'Halt');
                    invoke(RP1,'ClearCOF');
                    
                    invoke(RP1,'LoadCOF',stimRCXfName);
                    
                    invoke(RP1,'SetTagVal','StmOn',pABRstim.Gating.pABRDur_ms);
                    invoke(RP1,'SetTagVal','StmOff',pABRstim.Gating.Period_ms - pABRstim.Gating.pABRDur_ms);
                    invoke(RP1,'SetTagVal','RiseFall',pABRstim.Gating.rftime_ms);
                    
                    activeStim = 1;
                    
                    xpR = double(pABR_Rstim(activeStim,:));
                    xpL = double(pABR_Lstim(activeStim,:));
                    
                    tmpR = invoke(RP1,'WriteTagV','STIM_R',0,xpR);
                    tmpL = invoke(RP1,'WriteTagV','STIM_L',0,xpL);
                    
                    if tmpR ~= 1 || tmpL ~= 1
                        warning('Updated fixed pABR stimulus failed to load');
                    end
                    
                    invoke(RP1,'Run');
                    
                    AEP_set_attns2(pABRstim.atten_dB,Stimuli.channel, ...
                        pABRstim.atten2_dB,Stimuli.channel2,Stimuli.KHosc,RP1,RP2);
                    
                    invoke(RP3,'Halt');
                    invoke(RP3,'SetTagVal','ADdur',pABRstim.Gating.pABRDur_ms);
                    invoke(RP3,'Run');
                    
                    currStim = 0;
                    rejections = 0;
                    
                    firstPolResp1 = [];
                    firstPolResp2 = [];
                    secondPolResp1 = [];
                    secondPolResp2 = [];
                    
                    for ii = 1:5
                        set(FIG.ax.line(ii),'xdata',[],'ydata',[]);
                        set(FIG.ax.line(ii+5),'xdata',[],'ydata',[]);
                    end
                    
                    set(FIG.ax.line2(1),'ydata',0);
                    set(FIG.ax.line2(2),'ydata',0);
                    
                    drawnow;
                    
                    invoke(RP1,'SoftTrg',1);
                    
                case 3
                    
                    % Kept for interface compatibility.
                    
                case 4
                    
                    FFRwav2_RunLevels_pABR(FIG,Stimuli,invfiltdata,RunLevels_params,misc,FFR_Gating, ...
                        pABRnpts,interface_type,Display,NelData,data_dir,RP1,RP2,RP3,PROG,prog_dir,pABRstim);
                    
                    currStim = 0;
                    
                case 5
                    
                    currStim = 0;
                    rejections = 0;
                    
                    firstPolResp1 = [];
                    firstPolResp2 = [];
                    secondPolResp1 = [];
                    secondPolResp2 = [];
                    
                    for ii = 1:5
                        set(FIG.ax.line(ii),'xdata',[],'ydata',[]);
                        set(FIG.ax.line(ii+5),'xdata',[],'ydata',[]);
                    end
                    
                    set(FIG.ax.line2(1),'ydata',0);
                    set(FIG.ax.line2(2),'ydata',0);
                    
                    drawnow;
                    
                case 6
                    
                    if strcmp(Display.Voltage,'atELEC')
                        Display.PlotFactor = 1/Display.Gain;
                        Display.YLim = Display.YLim_atAD/Display.Gain;
                    else
                        Display.PlotFactor = 1;
                        Display.YLim = Display.YLim_atAD;
                    end
                    
                case 7
                    
                    maxThresh = max([Stimuli.threshV Stimuli.threshV2]);
                    set(FIG.ax.axis2,'Ylim',[0 maxThresh+1]);
                    
                case 18
                    
                    for ii = 1:5
                        set(FIG.ax.line(ii),'Visible','on');
                        set(FIG.ax.line(ii+5),'Visible','on');
                    end
                    
                    set(FIG.ax.line2(1),'Visible','on');
                    set(FIG.ax.line2(2),'Visible','on');
                    
                    drawnow;
                    
                case 101
                    
                    pABR_RunLevels(FIG,Stimuli,invfiltdata,RunLevels_params,misc,FFR_Gating, ...
                        pABRnpts,interface_type,Display,NelData,data_dir,RP1,RP2,RP3,PROG,prog_dir,pABRstim);
                    
                    currStim = 0;
            end
            
            FIG.NewStim = 0;
        end
    end
end
Stimuli.KHosc = 0;

AEP_set_attns2(120,Stimuli.channel,120,Stimuli.channel2,Stimuli.KHosc,RP1,RP2);
rc = PAset([120;120;120;120]);

invoke(RP1,'Halt');
invoke(RP2,'Halt');
invoke(RP3,'Halt');

delete(FIG.handle);
clear FIG;