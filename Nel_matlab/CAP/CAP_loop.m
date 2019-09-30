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
RP1=actxcontrol('RPco.x',[0 0 1 1]);
invoke(RP1,'ConnectRP2',NelData.General.TDTcommMode,1);
invoke(RP1,'ClearCOF');
invoke(RP1,'LoadCOF',[prog_dir '\object\CAP_left.rcx']);

invoke(RP1,'SetTagVal','freq',Stimuli.freq_hz);
invoke(RP1,'SetTagVal','tone',1);
invoke(RP1,'SetTagVal','FixedPhase',Stimuli.fixedPhase);
invoke(RP1,'SetTagVal','toneAmp',toneAmp); %KH 06Jan2012
invoke(RP1,'SetTagVal','clickAmp',clickAmp); %KH 06Jan2012

invoke(RP1,'SetTagVal','StmOn',CAP_Gating.duration_ms);
invoke(RP1,'SetTagVal','StmOff',CAP_Gating.period_ms-CAP_Gating.duration_ms);
invoke(RP1,'SetTagVal','RiseFall',CAP_Gating.rftime_ms);
invoke(RP1,'Run');

if NelData.General.RP2_3and4
    %% For bit select (RP2#3 is not connected to Mix/Sel). So have to use RP2#2. May use RP2#1?
    RP2=actxcontrol('RPco.x',[0 0 1 1]);
    invoke(RP2,'ConnectRP2',NelData.General.TDTcommMode,2);
    invoke(RP2,'ClearCOF');
    invoke(RP2,'LoadCOF',[prog_dir '\object\CAP_BitSet.rcx']);
    invoke(RP2,'Run');
    
    %% For ADC (data in)
    RP3=actxcontrol('RPco.x',[0 0 1 1]);
    invoke(RP3,'ConnectRP2',NelData.General.TDTcommMode,3);
    invoke(RP3,'ClearCOF');
    if strcmpi(interface_type, 'CAP')
        invoke(RP3,'LoadCOF',[prog_dir '\object\CAP_ADC.rcx']);
        % Only difference: Input Channel number
        % For CAP: AD chan #1
    else % ABR
        invoke(RP3,'LoadCOF',[prog_dir '\object\ABR_right.rcx']);
        % For ABR: AD chan #2
    end
    invoke(RP3,'SetTagVal','ADdur', CAP_Gating.CAPlength_ms);
    invoke(RP3,'Run');
else
    RP2=actxcontrol('RPco.x',[0 0 1 1]);
    invoke(RP2,'ConnectRP2',NelData.General.TDTcommMode,2);
    invoke(RP2,'ClearCOF');
    RP3= RP2;
    invoke(RP3,'LoadCOF',[prog_dir '\object\CAP_right.rcx']);
    invoke(RP3,'SetTagVal','ADdur', CAP_Gating.CAPlength_ms);
    invoke(RP3,'Run');
end

CAP_set_attns(Stimuli.atten_dB,Stimuli.channel,Stimuli.KHosc,RP1,RP2);  %% debug deal with later Khite
CAPnpts=ceil(CAP_Gating.CAPlength_ms/1000*Stimuli.RPsamprate_Hz);
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
   FIG.ax.line = plot(0,0,'-');
   set(FIG.ax.line,'MarkerSize',2,'Color','k');
   xlim([CAP_Gating.XstartPlot_ms/1000 CAP_Gating.XendPlot_ms/1000]);
   ylim([-Display.YLim Display.YLim]);  % ge debug: set large enough for A/D input range
   %   axis([CAP_Gating.XstartPlot_ms/1000 .010 -1 1]);  % ge debug: set large enough for A/D input range
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
   text(CAP_Gating.period_ms/2000,-33,'Frequency (Hz)','fontsize',12,'horizontalalignment','center');
   text(CAP_Gating.period_ms/2000,-49,'Attenuation (dB)','fontsize',12,'horizontalalignment','center');
   box on;
   
   %New axes for showing maximum of each input waveform - KH 2011 Jun 08
   FIG.ax.axis2 = axes('position',[.925 .34 .025 .62]);
   FIG.ax.line2 = plot(0.5,0,'r*',[0 1],[Stimuli.threshV Stimuli.threshV],':r');
   xlim([0 1]); ylim([0 10]);  
   set(FIG.ax.axis2,'XTickMode','auto');
   set(FIG.ax.axis2,'YTickMode','auto');
   ylabel('Max AD Voltage (1 rep)','fontsize',12,'FontWeight','Bold');
   box on;
   
   invoke(RP1,'SoftTrg',1);
   %    tspan = CAP_Gating.period_ms/1000;
   while(1)  % loop until "close" request
      if(invoke(RP3,'GetTagVal','BufFlag') == 1)
         CAPdata = invoke(RP3,'ReadTagV','ADbuf',0,CAPnpts);
         %           CAPdata = ones(size(CAPdata)); % ge debug
         
         CAPobs=max(abs(CAPdata)); %KH 08Jun2011
         
         if ~veryfirstSTIM  % MH 18Nov2003 Skip very first, all zeros
            % Forgetting AVG - on first rep, set AVG=REP, otherwise, add with exponential weighting
            if ~firstSTIM
               
               if CAPobs <= Stimuli.threshV  %KH 2011 June 08 - artifact rejection
                  CAPdataAvg_freerun = CAP_memFact * CAPdataAvg_freerun ...
                     + (1 - CAP_memFact)*CAPdata;
               end
               
            else
               CAPdataAvg_freerun = CAPdata;
               firstSTIM=0;
            end
            set(FIG.ax.line,'xdata',0:(1/Stimuli.RPsamprate_Hz):CAP_Gating.CAPlength_ms/1000, ...
               'ydata',CAPdataAvg_freerun*Display.PlotFactor);
           
            set(FIG.ax.line2(1),'ydata',CAPobs); %KH 10Jan2012
            
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
            
         case 1
            invoke(RP1,'SetTagVal','freq',Stimuli.freq_hz);
            invoke(RP1,'SetTagVal','tone',1);
            CAP_set_attns(Stimuli.atten_dB,Stimuli.channel,Stimuli.KHosc,RP1,RP2);
         case 2
            invoke(RP1,'SetTagVal','tone',0);
            CAP_set_attns(Stimuli.atten_dB,Stimuli.channel,Stimuli.KHosc,RP1,RP2);
         case 3
            CAP_set_attns(Stimuli.atten_dB,Stimuli.channel,Stimuli.KHosc,RP1,RP2);
         case 4
            invoke(RP1,'SetTagVal','StmOn',CAP_Gating.duration_ms);
            invoke(RP1,'SetTagVal','StmOff',CAP_Gating.period_ms-CAP_Gating.duration_ms);
            invoke(RP3,'SetTagVal','ADdur',CAP_Gating.CAPlength_ms);
            CAPnpts=ceil((CAP_Gating.CAPlength_ms/1000)*Stimuli.RPsamprate_Hz);
            firstSTIM = 1;
            FIG.NewStim = 0;
            break
         case 5
            CAP_set_attns(Stimuli.atten_dB,Stimuli.channel,Stimuli.KHosc,RP1,RP2);
         case 6
            invoke(RP1,'SetTagVal','freq',Stimuli.freq_hz);
         case 7
            CAP_set_attns(Stimuli.atten_dB,Stimuli.channel,Stimuli.KHosc,RP1,RP2);
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
            
            CAP_RunLevels;
            veryfirstSTIM=1;
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
            set(FIG.ax.line2(2),'ydata',[Stimuli.threshV Stimuli.threshV]);
            drawnow;
            
         case 15 % Runs through Stimuli.audiogramFreqs at levels specified, KH 10Jan2012
            runAudiogram=1;
            CAP_RunLevels;
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
            
         end
         FIG.NewStim = 0;
      end
   end
end

% msdl(0); % Reset

Stimuli.KHosc = 0;    % added by GE/MH, 17Jan2003.  To force Krohn-Hite to disconnect.
CAP_set_attns(120,Stimuli.channel,Stimuli.KHosc,RP1,RP2);
rc = PAset([120;120;120;120]); % added by GE/MH, 17Jan2003.  To force all attens to 120

invoke(RP1,'Halt');
invoke(RP2,'Halt');
invoke(RP3,'Halt');

delete(FIG.handle);
clear FIG;

