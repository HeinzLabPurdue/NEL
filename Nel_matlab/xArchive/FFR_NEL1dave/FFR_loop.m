%global root_dir NelData

RP1=actxcontrol('RPco.x',[0 0 1 1]);
invoke(RP1,'ConnectRP2','USB',1);
invoke(RP1,'ClearCOF');
%FOLLOWING LINE FOR FINAL USE zz10.21.11
% invoke(RP1,'LoadCOF',[prog_dir '\object\FFR_wav.rcx']);
%FOLLOWING LINE FOR TEST USE zz10.21.11


invoke(RP1,'LoadCOF',[prog_dir '\object\FFR_wav_polIN.rcx']);

invoke(RP1,'SetTagVal','StmOn',FFR_Gating.duration_ms);
invoke(RP1,'SetTagVal','StmOff',(FFR_Gating.period_ms-FFR_Gating.duration_ms));
invoke(RP1,'SetTagVal','RiseFall',FFR_Gating.rftime_ms);
invoke(RP1,'Run');
% if get(FIG.radio.tone,'value')
% invoke(RP1,'SetTagVal','freq',Stimuli.freq_hz);
% invoke(RP1,'SetTagVal','tone',1);
% invoke(RP1,'SetTagVal','FixedPhase',Stimuli.fixedPhase);
% elseif get(FIG.radio.noise,'value')
%     invoke(RP1,'SetTagVal','tone',0);
% elseif get(FIG.radio.khite,'value')
%     invoke(RP1,'SetTagVal','tone',2);
% end

%use a filename
% invoke(RP1,'SetTagVal','filename',[Stimuli.filename]);



% invoke(RP1,'SoftTrg',1);


RP2=actxcontrol('RPco.x',[0 0 1 1]);
invoke(RP2,'ConnectRP2','USB',2);
invoke(RP2,'ClearCOF');
% invoke(RP2,'LoadCOF',[prog_dir '\object\FFR_right.rco']); % MH/KH Dec 8 2011
invoke(RP2,'LoadCOF',[prog_dir '\object\FFR_right2.rcx']);
invoke(RP2,'SetTagVal','ADdur', FFR_Gating.FFRlength_ms);
invoke(RP2,'Run');

FFR_set_attns(Stimuli.atten_dB,(Stimuli.noiseLevel*(1-Stimuli.noNoise)...
                    +(Stimuli.noNoise)*(Stimuli.atten_dB-120)),Stimuli.channel,Stimuli.KHosc,RP1,RP2); %% debug deal with later Khite



FFRnpts=ceil(FFR_Gating.FFRlength_ms/1000*Stimuli.RPsamprate_Hz);
if Stimuli.FFRmem_reps>0
    FFR_memFact=exp(-2/Stimuli.FFRmem_reps);
else
    FFR_memFact=0;
end
% firstSTIM will be based on the two pairs of stims zz 03nov11
pair1 = 1;
pair2 = 1;
firstSTIM=or(pair1,pair2);

veryfirstSTIM=1;  % The very first FFRdata when program starts is all zeros, so skip this, debug later MH 18Nov2003 
set(FIG.ax.line,'xdata',[],'y1data',[]); drawnow;

% alternating polarities in different matricies zz 04nov11
FFRdataAvg_freerun_np = 0;
FFRdataAvg_freerun_po = 0;
while ~length(get(FIG.push.close,'Userdata')),
    if (ishandle(FIG.ax.axis))
        delete(FIG.ax.axis);
    end
    FIG.ax.axis = axes('position',[.35 .34 .525 .62]);
    
    FIG.ax.line = plot(0,0,'-'); hold on;
    FIG.ax.line2= plot(0,0,'-');
    set(FIG.ax.line,'MarkerSize',2,'Color','k');
    set(FIG.ax.line2,'MarkerSize',2,'Color','r');
    
    
    
    xlim([FFR_Gating.XstartPlot_ms/1000 FFR_Gating.XendPlot_ms/1000]);
    ylim([-Display.YLim Display.YLim]);  % ge debug: set large enough for A/D input range
    %   axis([FFR_Gating.XstartPlot_ms/1000 .010 -1 1]);  % ge debug: set large enough for A/D input range
    %    set(FIG.ax.axis,'XTick',[0:.25:1]);
    %    set(FIG.ax.axis,'YTick',[-5:1:5]);
    set(FIG.ax.axis,'XTickMode','auto');
    set(FIG.ax.axis,'YTickMode','auto');
    %    ylim('auto');
    xlabel('Time (sec)','fontsize',12,'FontWeight','Bold');
    if strcmp(Display.Voltage,'atELEC')
        FIG.ax.ylabel=ylabel('Voltage at Electrode (V)','fontsize',12,'FontWeight','Bold');
    else
        FIG.ax.ylabel=ylabel('Voltage at AD (V)','fontsize',12,'FontWeight','Bold');
    end
    text(FFR_Gating.period_ms/2000,-33,'Frequency (Hz)','fontsize',12,'horizontalalignment','center');
    text(FFR_Gating.period_ms/2000,-49,'Attenuation (dB)','fontsize',12,'horizontalalignment','center');
    box on;
    
    %New axes for showing maximum of each input waveform - KHZZ 2011 Nov 4
    FIG.ax.axis2 = axes('position',[.925 .34 .025 .62]);
    FIG.ax.line3 = plot(0.5,0,'r*'); 
    hold on;
    FIG.ax.line4 = plot([0 1],[Stimuli.threshV Stimuli.threshV],':r');
    %set(FIG.ax.line2,'MarkerSize',2,'Color','r');
    xlim([0 1]);
    ylim([0 2]);  
    set(FIG.ax.axis2,'XTickMode','auto');
    set(FIG.ax.axis2,'YTickMode','auto');
    ylabel('Max AD Voltage (1 rep)','fontsize',12,'FontWeight','Bold');
    box on;
    
    
    
    invoke(RP1,'SoftTrg',1);
    %    tspan = FFR_Gating.period_ms/1000;
    while(1)  % loop until "close" request
        if(invoke(RP2,'GetTagVal','BufFlag') == 1)
            FFRdata = invoke(RP2,'ReadTagV','ADbuf',0,FFRnpts);
            FFRobs=max(abs(FFRdata));

            % THE ABOVE LINE HAS A LOGIC FLAW, NEEDS TO BE REPLACED
            % SPECIFICALLY, WITH THE INTRODUCTION OF REJECTIONS, THE POLARIZED/NP
            % MAY BECOME OUT OF PHASE, NEEDS TO BE REPLACED IN RUN LEVELS AS WELL
            % TO FIX, USE A invoke(RP1,'ReadTagV','ADbuf',0,FFRnpts
            % NOT COMPLETELY SURE THIS WILL WORK, BUT NEED SOME WAY TO READ FROM THE FILE, OR SKIP TWO INPUTS
            % ZZ - 05nov11
            
            %           FFRdata = ones(size(FFRdata)); % ge debug
            
            if ~veryfirstSTIM  % MH 18Nov2003 Skip very first, all zeros
                % Forgetting AVG - on first rep, set AVG=REP, otherwise, add with exponential weighting
                if ~firstSTIM
                    set(FIG.ax.line3,'ydata',FFRobs);
                    %KHZZ 2011 Nov 4 - artifact rejection while ensuring polarity remains the same
                    a = invoke(RP1,'GetTagVal','ORG');
                    mod(misc.n,2);
                    if ((FFRobs <= Stimuli.threshV) & (a == mod(misc.n,2)))
                        misc.n = mod(misc.n + 1,100);    % counter for stimuli for polarity zz 31oct11
                        %                if FFRobs <= Stimuli.threshV  %KHZZ 2011 Nov 4 - artifact rejection
                        if mod(misc.n,2)
                            FFRdataAvg_freerun_np = FFR_memFact * FFRdataAvg_freerun_np ...
                                + (1 - FFR_memFact)*FFRdata;
                            
                        else
                            FFRdataAvg_freerun_po = FFR_memFact * FFRdataAvg_freerun_po ...
                                + (1 - FFR_memFact)*FFRdata;
                            
                        end
                        %                else
                        
                    end
                    
                else
                    if ~mod(misc.n,2)
                        FFRdataAvg_freerun_np = FFRdata;
                        pair1 = 0;
                        misc.n = mod(misc.n + 1,100);
                    else
                        FFRdataAvg_freerun_po = FFRdata;
                        pair2 = 0;
                        misc.n = mod(misc.n + 1,100);
                    end
                    firstSTIM=or(pair1,pair2);
                end
                
                b=mod(misc.n,2);
                if mod(misc.n,2)
                    %                FFR_xdata = decimate(0:(1/Stimuli.RPsamprate_Hz):FFR_Gating.FFRlength_ms/1000,4);
                    %                FFR_ydata = decimate(FFRdataAvg_freerun_np*Display.PlotFactor,4);
                    %                set(FIG.ax.line,'xdata',FFR_xdata,'ydata',FFR_ydata);
                    set(FIG.ax.line,'xdata',[0:(1/Stimuli.RPsamprate_Hz):FFR_Gating.FFRlength_ms/1000], ...
                        'ydata',FFRdataAvg_freerun_np*Display.PlotFactor);
                    
                else
                    %                FFR_xdata = decimate(0:(1/Stimuli.RPsamprate_Hz):FFR_Gating.FFRlength_ms/1000,4);
                    %                FFR_ydata = decimate(FFRdataAvg_freerun_po*Display.PlotFactor,4);
                    %                set(FIG.ax.line2,'xdata',FFR_xdata,'ydata',FFR_ydata);
                    set(FIG.ax.line2,'xdata',[0:(1/Stimuli.RPsamprate_Hz):FFR_Gating.FFRlength_ms/1000], ...
                        'ydata',FFRdataAvg_freerun_po*Display.PlotFactor);
                end
                %             FFRxCOMB = [0:(1/Stimuli.RPsamprate_Hz):FFR_Gating.FFRlength_ms/1000 0:(1/Stimuli.RPsamprate_Hz):FFR_Gating.FFRlength_ms/1000];
                %             FFRdataCOMB = [FFRdataAvg_freerun_np FFRdataAvg_freerun_po];
                %             set(FIG.ax.line,'xdata',FFRxCOMB, ...
                %                       'ydata',FFRdataCOMB*Display.PlotFactor);
                drawnow;
            else
                veryfirstSTIM=0;
            end
            invoke(RP2,'SoftTrg',2);
        end
        
        if get(FIG.push.close,'Userdata'),
            break;
        elseif FIG.NewStim
            switch FIG.NewStim
                
            case 1
                invoke(RP1,'SetTagVal','freq',Stimuli.freq_hz);
                invoke(RP1,'SetTagVal','tone',1);
                FFR_set_attns(Stimuli.atten_dB,(Stimuli.noiseLevel*(1-Stimuli.noNoise)...
                    +(Stimuli.noNoise)*(Stimuli.atten_dB-120)),Stimuli.channel,Stimuli.KHosc,RP1,RP2);
            case 2
                invoke(RP1,'SetTagVal','tone',0);
                FFR_set_attns(Stimuli.atten_dB,(Stimuli.noiseLevel*(1-Stimuli.noNoise)...
                    +(Stimuli.noNoise)*(Stimuli.atten_dB-120)),Stimuli.channel,Stimuli.KHosc,RP1,RP2);
            case 3
                FFR_set_attns(Stimuli.atten_dB,(Stimuli.noiseLevel*(1-Stimuli.noNoise)...
                    +(Stimuli.noNoise)*(Stimuli.atten_dB-120)),Stimuli.channel,Stimuli.KHosc,RP1,RP2);
            case 4
                invoke(RP1,'SetTagVal','StmOn',FFR_Gating.duration_ms);
                invoke(RP1,'SetTagVal','StmOff',(FFR_Gating.period_ms-FFR_Gating.duration_ms));
                invoke(RP2,'SetTagVal','ADdur',FFR_Gating.FFRlength_ms);
                FFRnpts=ceil((FFR_Gating.FFRlength_ms/1000)*Stimuli.RPsamprate_Hz);
                pair1 = 1;
                pair2 = 1;
                firstSTIM=or(pair1,pair2);
                set(FIG.ax.line ,'xdata',[],'ydata',[]);   
                set(FIG.ax.line2,'xdata',[],'ydata',[]); 
                set(FIG.ax.line3,'xdata',[],'ydata',[]); drawnow;  % clear the plot.
                FIG.NewStim = 0;
                break
            case 5
                FFR_set_attns(Stimuli.atten_dB,(Stimuli.noiseLevel*(1-Stimuli.noNoise)...
                    +(Stimuli.noNoise)*(Stimuli.atten_dB-120)),Stimuli.channel,Stimuli.KHosc,RP1,RP2);
            case 6
                % upon moving the created AM Tone, or a specific WAV file,
                % reloads the COF, resets the plots
                invoke(RP1,'Halt');
                invoke(RP1,'ClearCOF');
                invoke(RP1,'LoadCOF',[prog_dir '\object\FFR_wav_polIN.rcx']);
                % AEH circuit below was active on 12/12/14, since 1/27/14 (?)
%                 invoke(RP1,'LoadCOF',[prog_dir '\object\FFR_wav_polIN_AEH.rcx']); % AEH 1/27/14 Fs=24k 
                invoke(RP1,'SetTagVal','StmOn',FFR_Gating.duration_ms);
                invoke(RP1,'SetTagVal','StmOff',(FFR_Gating.period_ms-FFR_Gating.duration_ms));
                invoke(RP1,'SetTagVal','RiseFall',FFR_Gating.rftime_ms);
                invoke(RP1,'Run');
                FFR_set_attns(Stimuli.atten_dB,(Stimuli.noiseLevel*(1-Stimuli.noNoise)...
                    +(Stimuli.noNoise)*(Stimuli.atten_dB-120)),Stimuli.channel,Stimuli.KHosc,RP1,RP2);
                %FFR_set_attns(Stimuli.atten_dB,Stimuli.channel,Stimuli.KHosc,RP1,RP2);  %% debug deal with later Khite
                FFRnpts=ceil(FFR_Gating.FFRlength_ms/1000*Stimuli.RPsamprate_Hz);
                if Stimuli.FFRmem_reps>0
                    FFR_memFact=exp(-2/Stimuli.FFRmem_reps);% changed from 1 to 2 to reflect num pairs zz 03nov2011
                else
                    FFR_memFact=0;
                end
                
                pair1 = 1;
                pair2 = 1;
                firstSTIM=or(pair1,pair2);
                set(FIG.ax.line ,'xdata',[],'ydata',[]);   
                set(FIG.ax.line2,'xdata',[],'ydata',[]); 
                set(FIG.ax.line3,'xdata',[],'ydata',[]); drawnow;  % clear the plot.
                veryfirstSTIM=1;  % The very first FFRdata when program starts is all zeros, so skip this, debug later MH 18Nov2003 
                
                invoke(RP1,'SoftTrg',1);
            case 7
                FFR_set_attns(Stimuli.atten_dB,(Stimuli.noiseLevel*(1-Stimuli.noNoise)...
                    +(Stimuli.noNoise)*(Stimuli.atten_dB-120)),Stimuli.channel,Stimuli.KHosc,RP1,RP2);
            case 8
                invoke(RP1,'SetTagVal','FixedPhase',Stimuli.fixedPhase);
            case 9
                if Stimuli.FFRmem_reps>0
                    FFR_memFact=exp(-2/Stimuli.FFRmem_reps);% changed from 1 to 2 to reflect num pairs zz 03nov2011
                else
                    FFR_memFact=0;
                end
            case 10 % Stimulate and acquire FFR curves at levels based on AttenMask around the current freq/atten combo.
                FFR_RunLevels;
                veryfirstSTIM=1;
                %             misc.n = int(~(invoke(RP1,'GetTagVal','ORG')));
            case 11 % Make "free-run" forget previous averages.
                pair1 = 1;
                pair2 = 1;
                firstSTIM=or(pair1,pair2);
                set(FIG.ax.line ,'xdata',[],'ydata',[]);   
                set(FIG.ax.line2,'xdata',[],'ydata',[]); 
                set(FIG.ax.line3,'xdata',[],'ydata',[]); drawnow;  % clear the plot.
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
            case 13
                FFR_set_attns(Stimuli.atten_dB,(Stimuli.noiseLevel*(1-Stimuli.noNoise)...
                    +(Stimuli.noNoise)*(Stimuli.atten_dB-120)),Stimuli.channel,Stimuli.KHosc,RP1,RP2);
            case 14
                
                FFR_set_attns(Stimuli.atten_dB,(Stimuli.noiseLevel*(1-Stimuli.noNoise)...
                    +(Stimuli.noNoise)*(Stimuli.atten_dB-120)),Stimuli.channel,Stimuli.KHosc,RP1,RP2);
            end
            FIG.NewStim = 0;
        end
    end
end

% msdl(0); % Reset

Stimuli.KHosc = 0;    % added by GE/MH, 17Jan2003.  To force Krohn-Hite to disconnect.
FFR_set_attns(120,0,Stimuli.channel,Stimuli.KHosc,RP1,RP2);
rc = PAset([120;120;120;120]); % added by GE/MH, 17Jan2003.  To force all attens to 120

invoke(RP1,'Halt');
invoke(RP2,'Halt');

delete(FIG.handle);
clear FIG;

