%global root_dir NelData

RP1=actxcontrol('RPco.x',[0 0 1 1]);
invoke(RP1,'ConnectRP2',NelData.General.TDTcommMode,2);
invoke(RP1,'ClearCOF');
invoke(RP1,'LoadCOF',[prog_dir '\object\CAP_left.rco']);

% if get(FIG.radio.tone,'value')
invoke(RP1,'SetTagVal','freq',Stimuli.freq_hz);
invoke(RP1,'SetTagVal','tone',1);
invoke(RP1,'SetTagVal','FixedPhase',Stimuli.fixedPhase);
% elseif get(FIG.radio.noise,'value')
%     invoke(RP1,'SetTagVal','tone',0);
% elseif get(FIG.radio.khite,'value')
%     invoke(RP1,'SetTagVal','tone',2);
% end

invoke(RP1,'SetTagVal','StmOn',CAP_Gating.duration_ms);
invoke(RP1,'SetTagVal','StmOff',CAP_Gating.period_ms-CAP_Gating.duration_ms);
invoke(RP1,'SetTagVal','RiseFall',CAP_Gating.rftime_ms);
invoke(RP1,'Run');

RP2=actxcontrol('RPco.x',[0 0 1 1]);
invoke(RP2,'ConnectRP2',NelData.General.TDTcommMode,1);
invoke(RP2,'ClearCOF');
invoke(RP2,'LoadCOF',[prog_dir '\object\CAP_right.rco']);
invoke(RP2,'SetTagVal','ADdur', CAP_Gating.CAPlength_ms);
invoke(RP2,'Run');

AEP_set_attns(Stimuli.atten_dB,Stimuli.channel,Stimuli.KHosc,RP1,RP2);  %% debug deal with later Khite
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
   
   
   invoke(RP1,'SoftTrg',1);
   %    tspan = CAP_Gating.period_ms/1000;
   while(1)  % loop until "close" request
      if(invoke(RP2,'GetTagVal','BufFlag') == 1)
         CAPdata = invoke(RP2,'ReadTagV','ADbuf',0,CAPnpts);
         %           CAPdata = ones(size(CAPdata)); % ge debug
         
         if ~veryfirstSTIM  % MH 18Nov2003 Skip very first, all zeros
            % Forgetting AVG - on first rep, set AVG=REP, otherwise, add with exponential weighting
            if ~firstSTIM
               CAPdataAvg_freerun = CAP_memFact * CAPdataAvg_freerun ...
                  + (1 - CAP_memFact)*CAPdata;
            else
               CAPdataAvg_freerun = CAPdata;
               firstSTIM=0;
            end
            set(FIG.ax.line,'xdata',0:(1/Stimuli.RPsamprate_Hz):CAP_Gating.CAPlength_ms/1000, ...
               'ydata',CAPdataAvg_freerun*Display.PlotFactor);
            drawnow;
         else
            veryfirstSTIM=0;
         end
         invoke(RP2,'SoftTrg',2);
      end
      
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
            invoke(RP2,'SetTagVal','ADdur',CAP_Gating.CAPlength_ms);
            CAPnpts=ceil((CAP_Gating.CAPlength_ms/1000)*Stimuli.RPsamprate_Hz);
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
         end
         FIG.NewStim = 0;
      end
   end
end

% msdl(0); % Reset

Stimuli.KHosc = 0;    % added by GE/MH, 17Jan2003.  To force Krohn-Hite to disconnect.
AEP_set_attns(120,Stimuli.channel,Stimuli.KHosc,RP1,RP2);
rc = PAset([120;120;120;120]); % added by GE/MH, 17Jan2003.  To force all attens to 120

invoke(RP1,'Halt');
invoke(RP2,'Halt');

delete(FIG.handle);
clear FIG;

