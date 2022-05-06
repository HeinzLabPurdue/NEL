masker_type=questdlg('Select masker type:','','No masker','Broadband noise', 'hp-6000', 'No masker'); 

if strcmp(masker_type, 'No masker')
    dirpath=[prog_dir 'stimuli/'];
    filename= 'nomasker.json'; 
elseif  strcmp(masker_type, 'hp-6000')
      dirpath=[prog_dir 'stimuli/'];
    filename= '5-hp-6000Hz.json';       
else
    dirpath=[prog_dir 'stimuli/'];
    filename= 'broadband-noise.json'; 
end

%Check stim file
filepath=[dirpath filename];
stim_json=fileread(filepath);
stim_struct=jsondecode(stim_json);
message= ['stimuli type not specified for file ', filepath];
assert(isfield(stim_struct, 'type'), message) 
noWAV=true;
for wavefile=stim_struct.wavefiles
   if wavefile.fs==Stimuli.RPsamprate_Hz
       noWAV=false;
       wavefile_duration=wavefile.duration_s*1000; %in ms 
       wavefilename=wavefile.filename;
       break;
   end
end
assert(~RunLevels_params.loadWavefiles || ~noWAV, ['wavefile not found for file ' , filepath])


if get(FIG.radio.fast, 'value') == 1
    CAP_intervals.duration_ms=Stimuli.fast.duration_ms;
else
    CAP_intervals.duration_ms=Stimuli.slow.duration_ms;
end


clickAmp=5;  
maskerAmp=5;

pushButton=FIG.push.free_run;
set(pushButton,'string','Abort');

message1=['STATUS: free run mode...'];
message2=masker_type;
set(FIG.statText.status, 'String', sprintf('%s\n%s', message1, message2));


if ~RunLevels_params.loadWavefiles
    %load config file and change duration
    config_json=fileread('fmaskedCAP_maskers_config.json');
    config_struct=jsondecode(config_json);
    config_struct.duration_s = min(CAP_intervals.duration_ms/1000*2*RunLevels_params.nPairs*1.5, 5);  %extra x1.5 factor
end



if ~noNEL
   if ~RunLevels_params.loadWavefiles  %Create wavefile on the fly 

         if RunLevels_params.invFilterOnWavefiles && ~noNEL
            cdd
            temp = load('fmasked_coef_invCalib');
            rdd
            b_coeffs= temp.b_coeffs(:)';
            sig=fmaskedCAP_create_signal_func(config_struct, stim_struct, b_coeffs);
         else
            sig=fmaskedCAP_create_signal_func(config_struct, stim_struct);
         end
       
        if any(sig>1.)
            warning([filename ': a value in the generated signal exceeds 1'])
        end
     
   end
        
   
    path2= [prog_dir '\stimuli\current_masker.wav'];
        
    if RunLevels_params.loadWavefiles
        %copy WAV
        path1=[dirpath wavefilename];
        [status, message]= copyfile(path1,path2);
        
       if status==0
            warning(message);
        end
    else
        audiowrite(path2, sig, config_struct.fs)
        wavefile_duration=config_struct.duration_s;
    end
    
    %need to reload COF to reload wavefile 
    invoke(RP1,'ClearCOF');
    
    if RunLevels_params.lpcInvFilterOnClick 
        invoke(RP1,'LoadCOF',[prog_dir '\object\fmasking_CAP_click_wav.rcx']);
    else
        invoke(RP1,'LoadCOF',[prog_dir '\object\fmasking_CAP.rcx']);
    end

    % invoke(RP1,'ConnectRP2','GB',1); %changed USB to GB, 5.8.13 MW/MH
    % if get(FIG.radio.tone,'value')
    invoke(RP1,'SetTagVal','FixedPhase',Stimuli.fixedPhase);
    invoke(RP1,'SetTagVal','clickAmp',clickAmp);
    invoke(RP1,'SetTagVal','maskerAmp',maskerAmp);

    invoke(RP1,'SetTagVal','StmOn',CAP_intervals.duration_ms);  
    invoke(RP1,'SetTagVal','StmOff',CAP_intervals.period_ms-CAP_intervals.duration_ms+CAP_intervals.rftime_ms);
    invoke(RP1,'SetTagVal','gateTime',CAP_intervals.rftime_ms);  %NB: was called 'RiseFall' in CAP
    invoke(RP1,'SetTagVal','clickDelay', CAP_intervals.clickDelay); 
    invoke(RP1,'SetTagVal','wavDur', wavefile_duration);             


    %set variables RP2/RP3 + run
    if NelData.General.RP2_3and4 && ~debugStimuliGeneration
            % For bit select (RP2#3 is not connected to Mix/Sel). So have to use RP2#2. May use RP2#1?
            invoke(RP2,'Run');

            % For ADC (data in)
            invoke(RP3,'SetTagVal','ADdur', CAP_intervals.CAPlength_ms);
            invoke(RP3,'SetTagVal','gateTime',CAP_intervals.rftime_ms); 
            invoke(RP3,'SetTagVal','clickDelay', CAP_intervals.clickDelay);
            invoke(RP3,'Run');
    else
        if (~NelData.General.RX8)
            RP3= RP2;
        else
            invoke(RP2,'Run');
        end
            invoke(RP3,'SetTagVal','ADdur', CAP_intervals.CAPlength_ms);
            invoke(RP3,'SetTagVal','gateTime',CAP_intervals.rftime_ms); 
            invoke(RP3,'SetTagVal','clickDelay', CAP_intervals.clickDelay);
            invoke(RP3,'Run');
            
    end

    attenLevel=Stimuli.atten_dB;
    CAPattens=attenLevel;


    invoke(RP1,'Run');
    fmaskedCAP_set_attns(attenLevel, Stimuli.masker_atten_dB, Stimuli.channel,Stimuli.KHosc,RP1,RP2);

    invoke(RP3,'SoftTrg',2); %reset bufFlag if needed
end

CAPnpts=ceil(CAP_intervals.CAPlength_ms/1000*Stimuli.RPsamprate_Hz);
if Stimuli.CAPmem_reps>0
   CAP_memFact=exp(-1/Stimuli.CAPmem_reps);
else
   CAP_memFact=0;
end
firstSTIM=1;
veryfirstSTIM=1;  % The very first CAPdata when program starts is all zeros, so skip this, debug later MH 18Nov2003 

if (ishandle(FIG.ax.axis))
  delete(FIG.ax.axis);
end

FIG.ax.axis = axes('position',[.35 .32 .525 .62]);
FIG.ax.line = plot(0,0,'-');
set(FIG.ax.line,'MarkerSize',2,'Color','k');
xlim([CAP_intervals.XstartPlot_ms/1000 CAP_intervals.XendPlot_ms/1000]);
ylim([-Display.YLim Display.YLim]);  % ge debug: set large enough for A/D input range
%   axis([CAP_intervals.XstartPlot_ms/1000 .010 -1 1]);  % ge debug: set large enough for A/D input range
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
text(CAP_intervals.period_ms/2000,-33,'Frequency (Hz)','fontsize',12,'horizontalalignment','center');
text(CAP_intervals.period_ms/2000,-49,'Attenuation (dB)','fontsize',12,'horizontalalignment','center');
box on;
set(FIG.statText.status2, 'String', '');

%New axes for showing maximum of each input waveform - KH 2011 Jun 08
FIG.ax.axis2 = axes('position',[.925 .32 .025 .62]);
FIG.ax.line2 = plot(0.5,0,'r*',[0 1],[Stimuli.threshV Stimuli.threshV],':r');
xlim([0 1]); ylim([0 10]);  
set(FIG.ax.axis2,'XTickMode','auto');
set(FIG.ax.axis2,'YTickMode','auto');
ylabel('Max AD Voltage (1 rep)','fontsize',12,'FontWeight','Bold');
box on;

if ~noNEL
    invoke(RP1,'SoftTrg',1);
end

bAbort=0;

while(1)  % loop until "abort or close" request
  if (strcmp(get(pushButton, 'Userdata'), 'abort') || ~isempty(get(FIG.push.close,'Userdata')) )
    bAbort = 1;
    break;
  end

  if(noNEL || invoke(RP3,'GetTagVal','BufFlag') == 1)
    if noNEL  
        CAPdata= 0.05*randn(1, CAPnpts);
        pause(0.1);
    else
        CAPdata = invoke(RP3,'ReadTagV','ADbuf',0,CAPnpts);
    end    
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
        
      if (strcmp(get(pushButton, 'Userdata'), 'abort') || ~isempty(get(FIG.push.close,'Userdata')) )
        bAbort = 1;
        break;
      end
        
        set(FIG.ax.line,'xdata',0:(1/Stimuli.RPsamprate_Hz):CAP_intervals.CAPlength_ms/1000, ...
           'ydata',CAPdataAvg_freerun*Display.PlotFactor);

        set(FIG.ax.line2(1),'ydata',CAPobs); %KH 10Jan2012

        drawnow;
     else
        veryfirstSTIM=0;
     end
     if ~noNEL
         invoke(RP3,'SoftTrg',2);
     end
  end


  if FIG.NewStim && ~noNEL
     switch FIG.NewStim

%      case 2
%         invoke(RP1,'SetTagVal','tone',0);
%         CAP_set_attns(Stimuli.atten_dB,Stimuli.channel,Stimuli.KHosc,RP1,RP2);
%      case 3
%         CAP_set_attns(Stimuli.atten_dB,Stimuli.channel,Stimuli.KHosc,RP1,RP2);
     case 4
            
        invoke(RP1,'SetTagVal','StmOn',CAP_intervals.duration_ms);  
        invoke(RP1,'SetTagVal','StmOff',CAP_intervals.period_ms-CAP_intervals.duration_ms+CAP_intervals.rftime_ms);
        invoke(RP1,'SetTagVal','gateTime',CAP_intervals.rftime_ms);  %NB: was called 'RiseFall' in CAP
        invoke(RP1,'SetTagVal','clickDelay', CAP_intervals.clickDelay); 

        %RP2/RP3
        if NelData.General.RP2_3and4
                % For ADC (data in)
                invoke(RP3,'SetTagVal','ADdur', CAP_intervals.CAPlength_ms);
                invoke(RP3,'SetTagVal','gateTime',CAP_intervals.rftime_ms); 
                invoke(RP3,'SetTagVal','clickDelay', CAP_intervals.clickDelay);
        else
                invoke(RP3,'SetTagVal','ADdur', CAP_intervals.CAPlength_ms);
                invoke(RP3,'SetTagVal','gateTime',CAP_intervals.rftime_ms); 
                invoke(RP3,'SetTagVal','clickDelay', CAP_intervals.clickDelay);
        end
         
        CAPnpts=ceil((CAP_intervals.CAPlength_ms/1000)*Stimuli.RPsamprate_Hz);
        firstSTIM = 1;
%         FIG.NewStim = 0;
%         break
     case 5
        fmaskedCAP_set_attns(Stimuli.atten_dB, Stimuli.masker_atten_dB, Stimuli.channel,Stimuli.KHosc,RP1,RP2);
%      case 6
%         invoke(RP1,'SetTagVal','freq',Stimuli.freq_hz);
     case 7
        fmaskedCAP_set_attns(Stimuli.atten_dB, Stimuli.masker_atten_dB, Stimuli.channel,Stimuli.KHosc,RP1,RP2);
     case 8
        invoke(RP1,'SetTagVal','FixedPhase',Stimuli.fixedPhase);
     case 9
        if Stimuli.CAPmem_reps>0
           CAP_memFact=exp(-1/Stimuli.CAPmem_reps);
        else
           CAP_memFact=0;
        end
%      case 10   
% 
%         runAudiogram=0; %KH 10Jan2012
% 
%         CAP_RunLevels;
%         veryfirstSTIM=1;
%      case 11 % Make "free-run" forget previous averages.
%         firstSTIM = 1;          
      case 12 
        % Change Voltage Display  %partly in main script       
        if strcmp(Display.Voltage,'atELEC')
           set(FIG.ax.ylabel,'String','Voltage at Electrode (V)')
%            Display.PlotFactor=1/Display.Gain;
%            Display.YLim=Display.YLim_atAD/Display.Gain;
        else
           set(FIG.ax.ylabel,'String','Voltage at AD (V)')
%            Display.PlotFactor=1;
%            Display.YLim=Display.YLim_atAD;
        end
         set(FIG.ax.axis,'Ylim',[-Display.YLim Display.YLim])
% 
%      case 13 %KH 08Jun2011
%         set(FIG.ax.line2(2),'ydata',[Stimuli.threshV Stimuli.threshV]);
%         drawnow;
% 
%      case 15 % Runs through Stimuli.audiogramFreqs at levels specified, KH 10Jan2012
%         runAudiogram=1;
%         CAP_RunLevels;
%         veryfirstSTIM=1;
% 
%      case 16 % KH 10Jan2012, switch between click and tone
%         if Stimuli.clickYes==1
%             clickAmp=5; toneAmp=0;
%             CAP_intervals.duration_ms=Stimuli.clickLength_ms;
%         else
%             clickAmp=0; toneAmp=5;
%             if get(FIG.radio.fast, 'value') == 1
%                 CAP_intervals.duration_ms=Stimuli.fast.duration_ms;
%             else
%                 CAP_intervals.duration_ms=Stimuli.slow.duration_ms;
%             end
%         end
%         invoke(RP1,'SetTagVal','toneAmp',toneAmp); 
%         invoke(RP1,'SetTagVal','clickAmp',clickAmp); 
%         invoke(RP1,'SetTagVal','StmOn',CAP_intervals.duration_ms);
%         invoke(RP1,'SetTagVal','StmOff',CAP_intervals.period_ms-CAP_intervals.duration_ms);
%   
     end
     FIG.NewStim = 0;
  elseif FIG.NewStim==12 && noNEL  %for emulation purposes
    if strcmp(Display.Voltage,'atELEC')
       set(FIG.ax.ylabel,'String','Voltage at Electrode (V)')
%            Display.PlotFactor=1/Display.Gain;
%            Display.YLim=Display.YLim_atAD/Display.Gain;
    else
       set(FIG.ax.ylabel,'String','Voltage at AD (V)')
%            Display.PlotFactor=1;
%            Display.YLim=Display.YLim_atAD;
    end
     set(FIG.ax.axis,'Ylim',[-Display.YLim Display.YLim])
  end
end


% msdl(0); % Reset

Stimuli.KHosc = 0;    % added by GE/MH, 17Jan2003.  To force Krohn-Hite to disconnect.

if ~noNEL
    fmaskedCAP_set_attns(120, 120, Stimuli.channel,Stimuli.KHosc,RP1,RP2);
    rc = PAset([120;120;120;120]); % added by GE/MH, 17Jan2003.  To force all attens to 120


    invoke(RP1,'Halt');
    if (NelData.General.RP2_3and4 && ~debugStimuliGeneration) || NelData.General.RX8
        invoke(RP2,'Halt');
    end
     invoke(RP3,'Halt');
    end

% Reset to "Idle" mode:
set(pushButton,'string','Free run...');
set(pushButton,'Userdata','');
set(FIG.statText.status, 'String', ['STATUS (' interface_type '): Idle...']);
set(FIG.statText.status2, 'String', '');

fmaskedCAP_loop_plot_enable_disable('on')


