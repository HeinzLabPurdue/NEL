while ~length(get(FIG.push.close,'Userdata'))
    while(1)
    %For now no free run
    % see initial code for example of free run code
    
      if get(FIG.push.close,'Userdata')
         break;
      elseif FIG.NewStim  % && ~noNEL    
         
         switch FIG.NewStim
            
         case 3
            CAP_set_attns(Stimuli.atten_dB,Stimuli.channel,Stimuli.KHosc,RP1,RP2);
         case 4
             % No free run mode
%             invoke(RP1,'SetTagVal','StmOn',CAP_Gating.duration_ms);
%             invoke(RP1,'SetTagVal','StmOff',CAP_Gating.period_ms-CAP_Gating.duration_ms);
%             invoke(RP2,'SetTagVal','ADdur',CAP_Gating.CAPlength_ms);
%             invoke(RP1,'SetTagVal','gateTime',CAP_Gating.rftime_ms);  %NB: was called 'RiseFall' in CAP
%             invoke(RP1,'SetTagVal','clickDelay', CAP_intervals.clickDelay);  
%             
%             CAPnpts=ceil((CAP_Gating.CAPlength_ms/1000)*Stimuli.RPsamprate_Hz);
            firstSTIM = 1;
            FIG.NewStim = 0;
            break
         case 5
            CAP_set_attns(Stimuli.atten_dB,Stimuli.channel,Stimuli.KHosc,RP1,RP2);
         case 7
            CAP_set_attns(Stimuli.atten_dB,Stimuli.channel,Stimuli.KHosc,RP1,RP2);
         case 8
            %invoke(RP1,'SetTagVal','FixedPhase',Stimuli.fixedPhase);
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
           
         case 117

         end
         FIG.NewStim = 0;
      end
    end
end

% msdl(0); % Reset

Stimuli.KHosc = 0;    % added by GE/MH, 17Jan2003.  To force Krohn-Hite to disconnect.
CAP_set_attns(120,Stimuli.channel,Stimuli.KHosc,RP1,RP2);
rc = PAset([120;120;120;120]); % added by GE/MH, 17Jan2003.  To force all attens to 120


if ~noNEL
    invoke(RP1,'Halt');
    invoke(RP2,'Halt');
    invoke(RP3,'Halt');
end

delete(FIG.handle);
clear FIG;

