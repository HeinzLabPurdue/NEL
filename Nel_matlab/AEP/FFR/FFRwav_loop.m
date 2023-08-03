global COMM prog_dir PROG data_dir NelData Stimuli 

% if ~(double(invoke(RP1,'GetTagVal', 'Stage')) == 2)
%     FFR_set_attns(-120,-120,Stimuli.channel,Stimuli.KHosc,RP1,RP2); %% Check with MH
% end

% adding demean_flag (JMR 2021)
demean_flag=1;


%% For stimulus
stimRCXfName= [prog_dir '\object\FFRwav_polIN.rcx'];

if NelData.General.RP2_3and4 && (~NelData.General.RX8) % NEL1 with RP2 #3 & #4
    invoke(RP1,'ClearCOF');
    invoke(RP1,'LoadCOF', stimRCXfName);
    
    %% For bit-select
    invoke(RP2,'ClearCOF');
    invoke(RP2,'LoadCOF',[prog_dir '\object\FFR_BitSet.rcx']);
    invoke(RP2,'Run');
    
    %% For ADC (data in)
    invoke(RP3,'ClearCOF');
    invoke(RP3,'LoadCOF',[prog_dir '\object\FFR_ADC_2chan.rcx']); %AS should check params work with NEL1 phys circuit then implement.
    invoke(RP3,'SetTagVal','ADdur', FFR_Gating.FFRlength_ms);
    invoke(RP3,'Run');
elseif (~NelData.General.RP2_3and4) && (~NelData.General.RX8) % NEL1 without (RP2 #3 & #4), and not NEL2 because no RX8
    invoke(RP1,'ClearCOF');
    invoke(RP1,'LoadCOF', stimRCXfName);
    invoke(RP2,'ClearCOF');
    invoke(RP2,'LoadCOF',[prog_dir '\object\FFR_right2.rcx']);
    invoke(RP2,'SetTagVal','ADdur', FFR_Gating.FFRlength_ms);
    invoke(RP2,'Run');
    
elseif NelData.General.RX8  %NEL2 with RX8
    invoke(RP1,'ClearCOF');
    invoke(RP1,'LoadCOF', stimRCXfName);
    
    %% For bit-select
    invoke(RP2,'ClearCOF');
    invoke(RP2,'LoadCOF',[prog_dir '\object\FFR_BitSet.rcx']);
    invoke(RP2,'Run');
    
    %% For ADC (data in)
    RP3= COMM.handle.RX8;
    invoke(RP3,'ClearCOF');
    filttype = {'inversefilt','inversefilt'};
    invfilterdata = set_invFilter(filttype, Stimuli.calibPicNum);
%     [~, ~, b_invCalib_coef]= run_invCalib(-2);
    
%     invoke(RP3,'ClearCOF');
%     invoke(RP3,'LoadCOF',[prog_dir '\object\FFR_RX8_ADC_invCalib_2chan.rcx']); %2 channel JMR Sept 21
%     e_invCalib_status= RP3.WriteTagV('FIR_Coefs', 0, b_invCalib_coef);
    invoke(RP3,'SetTagVal','ADdur', FFR_Gating.FFRlength_ms);
    invoke(RP3,'Run');
end
% Avoiding using set_RP_tagvals: somehow set_RP_tagvals doesn't let FFR
% loops run as expected.
% set_RP_tagvals(RP1, RP2, FFR_Gating, Stimuli);

% FFR_set_attns(Stimuli.atten_dB,-120,Stimuli.channel,Stimuli.KHosc,RP1,RP2);
AEP_set_attns(Stimuli.atten_dB,Stimuli.channel,Stimuli.KHosc,RP1,RP2);  %% debug deal with later Khite

FFRnpts=floor(FFR_Gating.FFRlength_ms/1000*Stimuli.RPsamprate_Hz); %Changed from ceil to floor based on ABR, VMA, SH (7/18/23)
if Stimuli.FFRmem_reps>0
    FFR_memFact=exp(-2/Stimuli.FFRmem_reps);
else
    FFR_memFact=0;
end

% firstSTIM will be based on the two pairs of stims zz 03nov11
pair1 = 1;
pair2 = 1;
firstSTIM=or(pair1,pair2);

veryfirstSTIM=1;  ... % The very first FFRdata when program starts is all zeros, so skip this,
    %debug later MH 18Nov2003
%set(FIG.ax.line,'xdata',[],'ydata',[]); drawnow;

% alternating polarities in different matricies zz 04nov11
FFRdataAvg_freerun_np1 = 0;
FFRdataAvg_freerun_po1 = 0;
FFRdataAvg_freerun_np2 = 0;
FFRdataAvg_freerun_po2 = 0;

while isempty(get(FIG.push.close,'Userdata'))
    
    if (ishandle(FIG.ax.axis))
        delete(FIG.ax.axis);
    end
    
    %% Plotting for Response
    FIG.ax.axis = axes('position',[.35 .34 .525 .62]);
    FIG.ax.line = plot(0,0,'-',0,0,'-',0,0,'-',0,0,'-'); hold on;
    xlim([FFR_Gating.XstartPlot_ms/1000 FFR_Gating.XendPlot_ms/1000]);
    ylim([-Display.YLim Display.YLim]);
    
    set(FIG.ax.axis,'XTickMode','auto');
    set(FIG.ax.axis,'YTickMode','auto');
    
    xlabel('Time (sec)','fontsize',12,'FontWeight','Bold');
    % chan 1
    set(FIG.ax.line(1),'MarkerSize',2,'Color','k'); % Ch1 neg.
    set(FIG.ax.line(2),'MarkerSize',2,'Color',[0.6 0.6 0.6]); % Ch1 pos
    % chan 2
    set(FIG.ax.line(3),'MarkerSize',2,'Color','b'); % Ch2 neg
    set(FIG.ax.line(4),'MarkerSize',2,'Color',[0.9 .1 1]); % Ch2 pos
    legend('Chan 1 Neg','Chan 1 Pos','Chan 2 Neg','Chan 2 Pos','location','northeast');
    
    if Stimuli.rec_channel > 2
        set(FIG.ax.line(1),'xdata',[],'ydata',[], 'Visible', 'on')
        set(FIG.ax.line(2),'xdata',[],'ydata',[], 'Visible', 'on')
        set(FIG.ax.line(3),'xdata',[],'ydata',[], 'Visible', 'on')
        set(FIG.ax.line(4),'xdata',[],'ydata',[], 'Visible', 'on')
    elseif Stimuli.rec_channel == 2
        set(FIG.ax.line(1),'xdata',[],'ydata',[], 'Visible', 'off')
        set(FIG.ax.line(2),'xdata',[],'ydata',[], 'Visible', 'off')
        set(FIG.ax.line(3),'xdata',[],'ydata',[], 'Visible', 'on')
        set(FIG.ax.line(4),'xdata',[],'ydata',[], 'Visible', 'on')   
    else
        set(FIG.ax.line(1),'xdata',[],'ydata',[], 'Visible', 'on')
        set(FIG.ax.line(2),'xdata',[],'ydata',[], 'Visible', 'on')
        set(FIG.ax.line(3),'xdata',[],'ydata',[], 'Visible', 'off')
        set(FIG.ax.line(4),'xdata',[],'ydata',[], 'Visible', 'off')
    end
    
    
    if strcmp(Display.Voltage,'atELEC')
        FIG.ax.ylabel=ylabel('Voltage at Electrode (V)','fontsize',12,'FontWeight','Bold');
    else
        FIG.ax.ylabel=ylabel('Voltage at AD (V)','fontsize',12,'FontWeight','Bold');
    end
    box on;
    
    %% Plotting for showing maximum of each input waveform (Artifact rejection) - KHZZ 2011 Nov 4
    FIG.ax.axis2 = axes('position',[.925 .34 .025 .62]);
    
    FIG.ax.line2 = plot(0.25,0,'r*',[0 1],[0 0],':r',0.75,0,'b*',[0 1],[0 0],':b');
    if Stimuli.rec_channel>2 % simultaneous
        set(FIG.ax.line2(1),'xdata',.25,'ydata',0, 'Visible', 'on')
        set(FIG.ax.line2(2),'xdata',[0 1],'ydata',[Stimuli.threshV Stimuli.threshV], 'Visible', 'on')
        set(FIG.ax.line2(3),'xdata',.75,'ydata',0, 'Visible', 'on')
        set(FIG.ax.line2(4),'xdata',[0 1],'ydata',[Stimuli.threshV2 Stimuli.threshV2], 'Visible', 'on')
    elseif Stimuli.rec_channel == 2
        set(FIG.ax.line2(1), 'Visible', 'off')
        set(FIG.ax.line2(2), 'Visible', 'off')
        set(FIG.ax.line2(3),'xdata',.5,'ydata',0, 'Visible', 'on')
        set(FIG.ax.line2(4),'xdata',[0 1],'ydata',[Stimuli.threshV2 Stimuli.threshV2], 'Visible', 'on')
    else % Channel 1 only
        set(FIG.ax.line2(1),'xdata',.5,'ydata',0, 'Visible', 'on')
        set(FIG.ax.line2(2),'xdata',[0 1],'ydata',[Stimuli.threshV Stimuli.threshV], 'Visible', 'on')
        set(FIG.ax.line2(3), 'Visible', 'off')
        set(FIG.ax.line2(4), 'Visible', 'off')
    end
    
    maxThresh = max([Stimuli.threshV, Stimuli.threshV2]); 
    xlim([0 1]);
    ylim([0 (maxThresh+1)]);
    set(FIG.ax.axis2,'XTickMode','auto');
    set(FIG.ax.axis2,'YTickMode','auto');
    ylabel('Max AD Voltage (1 rep)','fontsize',12,'FontWeight','Bold');
    box on;
    
    %% Start Running
    invoke(RP1,'SoftTrg',1);
    
    while(1)  % loop until "close" request
        if (invoke(RP3,'GetTagVal','BufFlag') == 1)
            FFRdata1 = invoke(RP3,'ReadTagV','ADbuf',0,FFRnpts); %ABR input %switch back to1 1
            FFRobs1=max(abs(FFRdata1)); % for artefact rejection
            FFRdata2 = invoke(RP3,'ReadTagV','ADbuf2',0,FFRnpts); %ECochG input
            FFRobs2=max(abs(FFRdata2)); % for artefact rejection
            
            if ~veryfirstSTIM  % MH 18Nov2003 Skip very first, all zeros
                % Forgetting AVG - on first rep, set AVG=REP, otherwise, add with exponential weighting
                if ~firstSTIM
                    
                    %plot max output of the trial for artifact rejection
                    if Stimuli.rec_channel > 2
                        set(FIG.ax.line2(1),'ydata',FFRobs1);
                        set(FIG.ax.line2(3),'ydata',FFRobs2);
                    elseif Stimuli.rec_channel == 2 % Chan 2
                        set(FIG.ax.line2(3),'ydata',FFRobs2);
                    else
                        set(FIG.ax.line2(1),'ydata',FFRobs1);
                    end
                    
                    stim_inv_pol = invoke(RP1,'GetTagVal','ORG');
                    mod(misc.n,2);
                    
                    if ((FFRobs1 <= Stimuli.threshV) && (FFRobs2 <= Stimuli.threshV2)) %&& (stim_inv_pol == mod(misc.n,2))) %artefact and polarity
                        misc.n = mod(misc.n + 1,100);    % counter for stimuli for polarity zz 31oct11
                        if mod(misc.n,2) % NegPol trials
                            % chan 1
                            FFRdataAvg_freerun_np1 = FFR_memFact * FFRdataAvg_freerun_np1 + (1 - FFR_memFact)*FFRdata1;
                            % chan 2
                            FFRdataAvg_freerun_np2 = FFR_memFact * FFRdataAvg_freerun_np2 + (1 - FFR_memFact)*FFRdata2;
                            
                            if demean_flag
                                % chan 1
                                FFRdataAvg_freerun_np1 = FFRdataAvg_freerun_np1-mean(FFRdataAvg_freerun_np1);
                                % chan 2
                                FFRdataAvg_freerun_np2 = FFRdataAvg_freerun_np2-mean(FFRdataAvg_freerun_np2);
                            end
                            
                        else % PosPol trials
                            % chan 1
                            FFRdataAvg_freerun_po1 = FFR_memFact * FFRdataAvg_freerun_po1 + (1 - FFR_memFact)*FFRdata1;
                            % chan 2
                            FFRdataAvg_freerun_po2 = FFR_memFact * FFRdataAvg_freerun_po2 + (1 - FFR_memFact)*FFRdata2;
                            
                            if demean_flag
                                % chan 1
                                FFRdataAvg_freerun_po1 = FFRdataAvg_freerun_po1-mean(FFRdataAvg_freerun_po1);
                                % chan 2
                                FFRdataAvg_freerun_po2 = FFRdataAvg_freerun_po2-mean(FFRdataAvg_freerun_po2);
                            end
                            
                        end
                        
                    end
                    
                else % if is first trial, just save the trial
                    if mod(misc.n,2) % Neg Pol
                        FFRdataAvg_freerun_np1 = FFRdata1; % chan 1
                        FFRdataAvg_freerun_np2 = FFRdata2; % chan 2
                        if demean_flag
                            FFRdataAvg_freerun_np1 = FFRdataAvg_freerun_np1-mean(FFRdataAvg_freerun_np1); % chan 1
                            FFRdataAvg_freerun_np2 = FFRdataAvg_freerun_np2-mean(FFRdataAvg_freerun_np2); % chan 2
                        end
                        pair1 = 0;
                        misc.n = mod(misc.n + 1,100);
                    else % same for positive pol
                        FFRdataAvg_freerun_po1 = FFRdata1; % chan 1
                        FFRdataAvg_freerun_po2 = FFRdata2; % chan 2
                        if demean_flag
                            FFRdataAvg_freerun_po1 = FFRdataAvg_freerun_po1-mean(FFRdataAvg_freerun_po1); %chan 1
                            FFRdataAvg_freerun_po2 = FFRdataAvg_freerun_po2-mean(FFRdataAvg_freerun_po2); %chan 2
                        end
                        pair2 = 0;
                        misc.n = mod(misc.n + 1,100);
                    end
                    firstSTIM=or(pair1,pair2);
                end
                
                b=mod(misc.n,2);
                
                % for plotting, ensure xdata and ydata are same size
                % trim everything to be the same length (# of samples in x
                % and y and for each polarity/channel)
                data_x = 0:(1/Stimuli.RPsamprate_Hz):FFR_Gating.FFRlength_ms/1000;
                newlen = min([length(data_x),length(FFRdataAvg_freerun_np1),length(FFRdataAvg_freerun_np2), length(FFRdataAvg_freerun_po1),length(FFRdataAvg_freerun_po2)]);
                data_x = data_x(1:newlen);
                
                if mod(misc.n,2) % Neg Polarity
                    % Ch 1 neg
                    data_np1 = zeros(1,newlen);
                    data_np1(1:newlen) = FFRdataAvg_freerun_np1(1:newlen);
                    
                    % Ch 2 neg
                    data_np2 = zeros(1,newlen);
                    data_np2(1:newlen) = FFRdataAvg_freerun_np2(1:newlen);
                    
                    if Stimuli.rec_channel>2
                        set(FIG.ax.line(1),'xdata', data_x, ... % ch 1
                            'ydata',data_np1*Display.PlotFactor);
                        set(FIG.ax.line(3),'xdata',data_x,...   % ch 2
                            'ydata',data_np2*Display.PlotFactor);
                        
                    elseif Stimuli.rec_channel==2
                        set(FIG.ax.line(3),'xdata', data_x, ... % ch 2
                            'ydata',data_np2*Display.PlotFactor);
                        
                    else % ch1 only
                        set(FIG.ax.line(1),'xdata', data_x, ... % ch 1
                            'ydata',data_np1*Display.PlotFactor);
                    end
                    
                else % Positive Polarity
                    % Ch 1 pos
                    data_po1 = zeros(1,newlen);
                    data_po1(1:newlen) = FFRdataAvg_freerun_po1(1:newlen);
                    
                    % Ch 2 pos
                    data_po2 = zeros(1,newlen);
                    data_po2(1:newlen) = FFRdataAvg_freerun_po2(1:newlen);
                    
                    % Plot 4 lines
                    if Stimuli.rec_channel>2
                        set(FIG.ax.line(2),'xdata', data_x, ... % ch 1
                            'ydata',data_po1*Display.PlotFactor);
                        set(FIG.ax.line(4),'xdata',data_x,...   % ch 2
                            'ydata',data_po2*Display.PlotFactor);
                        
                    elseif Stimuli.rec_channel==2
                        set(FIG.ax.line(4),'xdata', data_x, ... % ch 2
                            'ydata',data_po2*Display.PlotFactor);
                        
                    else % ch1 only
                        set(FIG.ax.line(2),'xdata', data_x, ... % ch 1
                            'ydata',data_po1*Display.PlotFactor);
                    end

                end
                drawnow;
            else
                veryfirstSTIM=0;
            end
            invoke(RP3,'SoftTrg',2);
        end
        
        if get(FIG.push.close,'Userdata')
            break;
            
        elseif FIG.NewStim
            switch FIG.NewStim
                
                case 0 % Do nothing (SP)
%                     FFR_set_attns(Stimuli.atten_dB,-120,Stimuli.channel,Stimuli.KHosc,RP1,RP2);
                      AEP_set_attns(Stimuli.atten_dB,Stimuli.channel,Stimuli.KHosc,RP1,RP2);
                      
                case 1 % case: fast or slow
                    % set_RP_tagvals(RP1, RP2, FFR_Gating, Stimuli);
                    invoke(RP1, 'SetTagVal', 'StmOn', FFR_Gating.duration_ms);
                    invoke(RP1, 'SetTagVal', 'StmOff', FFR_Gating.period_ms-FFR_Gating.duration_ms);
                    invoke(RP1, 'SetTagVal', 'RiseFall', FFR_Gating.rftime_ms);
                    
                    FFRnpts=ceil((FFR_Gating.FFRlength_ms/1000)*Stimuli.RPsamprate_Hz);
                    pair1 = 1;
                    pair2 = 1;
                    firstSTIM=or(pair1,pair2);
                    
                    % Clear all data
                    set(FIG.ax.line(1),'ydata',[]);
                    set(FIG.ax.line(2),'ydata',[]);
                    set(FIG.ax.line(3),'ydata',[]);
                    set(FIG.ax.line(4),'ydata',[]);
                    
                    if Stimuli.rec_channel > 2 %if more than 1 chan is plotted, clear the other as well
                        set(FIG.ax.line2(1),'ydata',0);
                        set(FIG.ax.line2(3),'ydata',0);
                    elseif Stimuli.rec_channel == 2
                        set(FIG.ax.line2(3),'ydata',0);
                    else
                        set(FIG.ax.line2(1),'ydata',0);
                    end
                    
                    drawnow;  % clear the plot.
                    FIG.NewStim = 0;
                    break
                    
                case 2 % case: updated wav-file
                    % RP1= connect_tdt('RP2', 1);
                    invoke(RP1,'Halt');
                    
                    %% SP: Is it necessary to clear COF?
                    invoke(RP1,'ClearCOF');
                    invoke(RP1,'LoadCOF', stimRCXfName);
                    
                    %%
                    invoke(RP1, 'SetTagVal', 'StmOn', FFR_Gating.duration_ms);
                    invoke(RP1, 'SetTagVal', 'StmOff', FFR_Gating.period_ms-FFR_Gating.duration_ms);
                    invoke(RP1, 'SetTagVal', 'RiseFall', FFR_Gating.rftime_ms);
                    invoke(RP1,'Run');
                    
                    % round attenuation
%                     att_run = floor(Stimuli.maxSPL-Stimuli.atten_dB-20);
                    
                    %FFR_set_attns(Stimuli.atten_dB,-120,Stimuli.channel,Stimuli.KHosc,RP1,RP2);
%                     FFR_set_attns(att_run,-120,Stimuli.channel,Stimuli.KHosc,RP1,RP2);
                    
                    AEP_set_attns(Stimuli.atten_dB,Stimuli.channel,Stimuli.KHosc,RP1,RP2);
                    
                    % debug deal with later Khite
                    
                    FFRnpts=floor(FFR_Gating.FFRlength_ms/1000*Stimuli.RPsamprate_Hz); %Changed from ceil to floor based on ABR, VMA, SH (7/18/23)
                    if Stimuli.FFRmem_reps>0
                        FFR_memFact=exp(-2/Stimuli.FFRmem_reps);... % changed from 1 to 2 to reflect num pairs zz 03nov2011
                    else
                    FFR_memFact=0;
                    end
                    
                    %% SP on 12Oct19: Different wav-file means ADdur maybe different
                    % For ADC (data in)
                    invoke(RP3,'Halt');
                    invoke(RP3,'SetTagVal','ADdur', FFR_Gating.FFRlength_ms);
                    invoke(RP3,'Run');
                    
                    %%
                    pair1 = 1;
                    pair2 = 1;
                    firstSTIM=or(pair1,pair2);
                    
                    set(FIG.ax.line(1),'xdata',[],'ydata',[]);
                    set(FIG.ax.line(2),'xdata',[],'ydata',[]);
                    set(FIG.ax.line(3),'xdata',[],'ydata',[]);
                    set(FIG.ax.line(4),'xdata',[],'ydata',[]);
                    
                    if Stimuli.rec_channel > 2 %if more than 1 chan is plotted, clear the other as well
                        set(FIG.ax.line2(1),'ydata',0);
                        set(FIG.ax.line2(3),'ydata',0);
                    elseif Stimuli.rec_channel == 2
                        set(FIG.ax.line2(3),'ydata',0);
                    else
                        set(FIG.ax.line2(1),'ydata',0);
                    end
                    
                    drawnow;  % clear the plot.
                    
                    veryfirstSTIM=1;  ... % The very first FFRdata when program starts is all zeros,
                        %so skip this, debug later MH 18Nov2003
                    
                    invoke(RP1,'SoftTrg',1);
                    
                case 3
                    if Stimuli.FFRmem_reps > 0
                        FFR_memFact=exp(-2/Stimuli.FFRmem_reps); ...
                            % changed from 1 to 2 to reflect num pairs zz 03nov2011
                    else
                        FFR_memFact=0;
                    end 
                    
                case 4   % Run Levels
                    [firstSTIM, NelData]=FFRwav_RunLevels(FIG,Stimuli,RunLevels_params, misc, FFR_Gating, ...
                        FFRnpts,interface_type, Display, NelData, data_dir, RP1, RP3, PROG);
                    veryfirstSTIM=1; ...
                        % misc.n = int(~(invoke(RP1,'GetTagVal','ORG')));
                    
                case 5 % Make "free-run" forget previous averages.
                    pair1 = 1;
                    pair2 = 1;
                    firstSTIM=or(pair1,pair2);
                    
                    % Clear all data
                    set(FIG.ax.line(1),'ydata',[]);
                    set(FIG.ax.line(2),'ydata',[]);
                    set(FIG.ax.line(3),'ydata',[]);
                    set(FIG.ax.line(4),'ydata',[]);
                    
                    if Stimuli.rec_channel > 2 %if more than 1 chan is plotted, clear the other as well   
                        set(FIG.ax.line2(1),'ydata',0);
                        set(FIG.ax.line2(3),'ydata',0);
                    elseif Stimuli.rec_channel == 2
                        set(FIG.ax.line2(3),'ydata',0);
                    else
                        set(FIG.ax.line2(1),'ydata',0);
                    end
                    
                    drawnow;  % clear the plot.
                    
                case 6 ...
                        % Change Voltage Display
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
                    
                case 7 % Change ThreshV or ThreshV2
                    if Stimuli.rec_channel > 2
                        set(FIG.ax.line2(2),'YData',[Stimuli.threshV Stimuli.threshV]);
                        set(FIG.ax.line2(4),'YData',[Stimuli.threshV2 Stimuli.threshV2]);
                    elseif Stimuli.rec_channel == 2
                        set(FIG.ax.line2(4),'YData',[Stimuli.threshV2 Stimuli.threshV2]);
                    else
                        set(FIG.ax.line2(2),'YData',[Stimuli.threshV Stimuli.threshV]);
                    end
                    maxThresh = max([Stimuli.threshV, Stimuli.threshV2]); 
                    set(FIG.ax.axis2, 'Ylim', [0, maxThresh+1]); 

                case 18 % changing number of recording channels
                    
                    if Stimuli.rec_channel>2
                        set(FIG.ax.line(1),'xdata',[],'ydata',[], 'Visible', 'on')
                        set(FIG.ax.line(2),'xdata',[],'ydata',[], 'Visible', 'on')
                        set(FIG.ax.line(3),'xdata',[],'ydata',[], 'Visible', 'on')
                        set(FIG.ax.line(4),'xdata',[],'ydata',[], 'Visible', 'on')
                        
                        set(FIG.ax.line2(1), 'xdata', 0.25, 'ydata', 0, 'Color', 'r', 'Visible', 'on')
                        set(FIG.ax.line2(2), 'xdata', [0 1], 'ydata', [Stimuli.threshV Stimuli.threshV], 'Color', 'r', 'Visible', 'on')
                        set(FIG.ax.line2(3), 'xdata', 0.75, 'ydata', 0, 'Color', 'b', 'Visible', 'on')
                        set(FIG.ax.line2(4), 'xdata', [0 1], 'ydata', [Stimuli.threshV2 Stimuli.threshV2], 'Color', 'b', 'Visible', 'on')
                        
                    elseif Stimuli.rec_channel==2
                        set(FIG.ax.line(1),'xdata',[],'ydata',[], 'Visible', 'off')
                        set(FIG.ax.line(2),'xdata',[],'ydata',[], 'Visible', 'off')
                        set(FIG.ax.line(3),'xdata',[],'ydata',[], 'Visible', 'on')
                        set(FIG.ax.line(4),'xdata',[],'ydata',[], 'Visible', 'on')
                        set(FIG.ax.line2(1), 'Visible', 'off')
                        set(FIG.ax.line2(2), 'Visible', 'off')
                        set(FIG.ax.line2(3), 'xdata', 0.5, 'ydata', 0, 'Color', 'b', 'Visible', 'on')
                        set(FIG.ax.line2(4), 'xdata', [0 1], 'ydata', [Stimuli.threshV2 Stimuli.threshV2], 'Color', 'b', 'Visible', 'on')
                    else
                        set(FIG.ax.line(1),'xdata',[],'ydata',[], 'Visible', 'on')
                        set(FIG.ax.line(2),'xdata',[],'ydata',[], 'Visible', 'on')
                        set(FIG.ax.line(3),'xdata',[],'ydata',[], 'Visible', 'off')
                        set(FIG.ax.line(4),'xdata',[],'ydata',[], 'Visible', 'off')
                        set(FIG.ax.line2(1), 'xdata', 0.5, 'ydata', 0, 'Color', 'r','Visible', 'on')
                        set(FIG.ax.line2(2), 'xdata', [0 1], 'ydata', [Stimuli.threshV Stimuli.threshV], 'Color', 'r', 'Visible', 'on')
                        set(FIG.ax.line2(3), 'Visible', 'off')
                        set(FIG.ax.line2(4), 'Visible', 'off')
                    end

                    drawnow;
                   
                case 101 ...
                        % For ??
            end
            FIG.NewStim = 0;
        end
    end
end

Stimuli.KHosc = 0;    % added by GE/MH, 17Jan2003.  To force Krohn-Hite to disconnect.
% FFR_set_attns(-120,-120, Stimuli.channel, Stimuli.KHosc, RP1, RP2);
AEP_set_attns(120,Stimuli.channel,Stimuli.KHosc,RP1,RP2);
rc = PAset([120;120;120;120]); % added by GE/MH, 17Jan2003.  To force all attens to 120

invoke(RP1,'Halt');
invoke(RP2,'Halt');
invoke(RP3,'Halt');

delete(FIG.handle);
clear FIG;