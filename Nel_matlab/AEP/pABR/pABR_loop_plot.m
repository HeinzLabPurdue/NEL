global COMM prog_dir PROG data_dir NelData Stimuli filttype invfiltdata pABRstim ...
       RunLevels_params interface_type Display misc FFR_Gating

pABR_flag = 1;

stimRCXfName = [prog_dir '\object\pABRwav2_polIN.rcx'];

critVal  = Stimuli.threshV;
critVal2 = Stimuli.threshV2;

pABR_Lstim = pABRstim.leftEpochs;
pABR_Rstim = pABRstim.rightEpochs;

%FFRnpts = pABRstim.FFRnpts;
FFRnpts = floor(FFR_Gating.FFRlength_ms/1000 * Stimuli.RPsamprate_Hz);

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
    invoke(RP3,'SetTagVal','ADdur',FFR_Gating.FFRlength_ms);
    invoke(RP3,'Run');

elseif (~NelData.General.RP2_3and4) && (~NelData.General.RX8)

    invoke(RP1,'ClearCOF');
    invoke(RP1,'LoadCOF',stimRCXfName);

    invoke(RP2,'ClearCOF');
    invoke(RP2,'LoadCOF',[prog_dir '\object\FFR_right2.rcx']);
    invoke(RP2,'SetTagVal','ADdur',FFR_Gating.FFRlength_ms);
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

    invoke(RP3,'SetTagVal','ADdur',FFR_Gating.FFRlength_ms);
    invoke(RP3,'Run');
end

%% Set pABR timing

invoke(RP1,'SetTagVal','StmOn',FFR_Gating.duration_ms);
invoke(RP1,'SetTagVal','StmOff',FFR_Gating.period_ms - FFR_Gating.duration_ms);
invoke(RP1,'SetTagVal','RiseFall',FFR_Gating.rftime_ms);

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

if isfield(FIG.ax,'axis') && ishandle(FIG.ax.axis)
    delete(FIG.ax.axis);
end

FIG.ax.axis = axes('position',[.35 .34 .525 .62]);
hold on;

pABR_time = (0:FFRnpts-1)/Stimuli.RPsamprate_Hz;

FIG.ax.line = plot( ...
    0,0,'-',0,0,'-',0,0,'-',0,0,'-',0,0,'-', ...
    0,0,'-',0,0,'-',0,0,'-',0,0,'-',0,0,'-');

for ii = 1:5
    set(FIG.ax.line(ii),'Color',[0 0.25 1],'LineWidth',1.6);
    set(FIG.ax.line(ii+5),'Color',[0 0 0],'LineWidth',1.6);
end

set(FIG.ax.axis, ...
    'YTick',[], ...
    'XLim',[0 max(pABR_time)], ...
    'YLim',[-0.9 10.3], ...
    'Box','off', ...
    'TickDir','out', ...
    'FontSize',12, ...
    'FontWeight','bold', ...
    'LineWidth',1.5);

xlabel('Time (sec)','FontWeight','bold','FontSize',13);

dividerY = 4.65;

plot([0 max(pABR_time)],[dividerY dividerY],'--', ...
    'Color',[0.55 0.55 0.55], ...
    'LineWidth',1.5);

text(max(pABR_time)/2,10.0,'RIGHT EAR', ...
    'HorizontalAlignment','center', ...
    'FontWeight','bold', ...
    'FontSize',13, ...
    'Color',[0 0.25 1]);

text(max(pABR_time)/2,4.15,'LEFT EAR', ...
    'HorizontalAlignment','center', ...
    'FontWeight','bold', ...
    'FontSize',13, ...
    'Color',[0 0 0]);

labelX = -0.00022;

for ii = 1:5
    text(labelX,rightY(ii),freqLabels{ii}, ...
        'HorizontalAlignment','right', ...
        'FontWeight','bold', ...
        'FontSize',12, ...
        'Clipping','off');

    text(labelX,leftY(ii),freqLabels{ii}, ...
        'HorizontalAlignment','right', ...
        'FontWeight','bold', ...
        'FontSize',12, ...
        'Clipping','off');
end

title('Free-running pABR Responses','FontWeight','bold','FontSize',15);

%% Artifact monitor

if isfield(FIG.ax,'axis2') && ishandle(FIG.ax.axis2)
    delete(FIG.ax.axis2);
end

FIG.ax.axis2 = axes('position',[.925 .34 .025 .62]);
hold on;

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

ylabel('Max AD Voltage','fontsize',12,'FontWeight','Bold');

axes(FIG.ax.axis);

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

            pABRdata1 = invoke(RP3,'ReadTagV','ADbuf',0,FFRnpts);
            pABRdata2 = invoke(RP3,'ReadTagV','ADbuf2',0,FFRnpts);

            maxpABRobs1 = max(abs(pABRdata1));
            maxpABRobs2 = max(abs(pABRdata2));

            set(FIG.ax.line2(1),'ydata',maxpABRobs1);
            set(FIG.ax.line2(2),'ydata',maxpABRobs2);

            if ~isempty(pABRdata1) && ~isempty(pABRdata2) && ...
                    length(pABRdata1)==FFRnpts && ...
                    length(pABRdata2)==FFRnpts

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

                        respLen = length(rightResp{1});
                        pABR_plot_time = (0:respLen-1)/Stimuli.RPsamprate_Hz;

                        for ff = 1:5
                            set(FIG.ax.line(ff), ...
                                'xdata',pABR_plot_time, ...
                                'ydata',rightResp{ff}*Display.PlotFactor + rightY(ff));

                            set(FIG.ax.line(ff+5), ...
                                'xdata',pABR_plot_time, ...
                                'ydata',leftResp{ff}*Display.PlotFactor + leftY(ff));
                        end

                        title(FIG.ax.axis, ...
                            sprintf('Free-running pABR Responses — Fixed Epoch %d',activeStim), ...
                            'FontWeight','bold', ...
                            'FontSize',15);

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

                invoke(RP1,'SetTagVal','StmOn',FFR_Gating.duration_ms);
                invoke(RP1,'SetTagVal','StmOff',FFR_Gating.period_ms - FFR_Gating.duration_ms);
                invoke(RP1,'SetTagVal','RiseFall',FFR_Gating.rftime_ms);

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

                invoke(RP1,'SetTagVal','StmOn',FFR_Gating.duration_ms);
                invoke(RP1,'SetTagVal','StmOff',FFR_Gating.period_ms - FFR_Gating.duration_ms);
                invoke(RP1,'SetTagVal','RiseFall',FFR_Gating.rftime_ms);

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
                invoke(RP3,'SetTagVal','ADdur',FFR_Gating.FFRlength_ms);
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
                    FFRnpts,interface_type,Display,NelData,data_dir,RP1,RP2,RP3,PROG,prog_dir,pABRstim);

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

                FFRwav2_RunLevels_pABR(FIG,Stimuli,invfiltdata,RunLevels_params,misc,FFR_Gating, ...
                    FFRnpts,interface_type,Display,NelData,data_dir,RP1,RP2,RP3,PROG,prog_dir,pABRstim);

                currStim = 0;
        end

        FIG.NewStim = 0;
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