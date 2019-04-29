%global root_dir NelData

RP1=actxcontrol('RPco.x',[0 0 1 1]);
invoke(RP1,'ConnectRP2','USB',1);
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

invoke(RP1,'SetTagVal','StmOn',Stimuli.duration_ms);
invoke(RP1,'SetTagVal','StmOff',Stimuli.period_ms-Stimuli.duration_ms);
invoke(RP1,'Run');

RP2=actxcontrol('RPco.x',[0 0 1 1]);
invoke(RP2,'ConnectRP2','USB',2);
invoke(RP2,'ClearCOF');
invoke(RP2,'LoadCOF',[prog_dir '\object\CAP_right.rco']);
invoke(RP2,'Run');

CAP_set_attns(Stimuli.atten_dB,Stimuli.channel,Stimuli.KHosc,RP1,RP2);  %% debug deal with later Khite
CAPnpts=ceil(Stimuli.CAPlength_sec*Stimuli.RPsamprate_Hz);
if Stimuli.CAPmem_reps>0
   CAP_memFact=exp(-1/Stimuli.CAPmem_reps);
else
   CAP_memFact=0;
end
firstSTIM=1;

while ~length(get(FIG.push.close,'Userdata')),
   if (ishandle(FIG.ax.axis))
      delete(FIG.ax.axis);
   end
   FIG.ax.axis = axes('position',[.35 .36 .525 .62]);
   FIG.ax.line = plot(0,0,'-');
   set(FIG.ax.line,'MarkerSize',2,'Color','k');
   axis([0 Stimuli.period_ms/1000 -11 11]);  % ge debug: set large enough for A/D input range
   set(FIG.ax.axis,'XTick',[0:.25:1]);
   set(FIG.ax.axis,'YTick',[-5:1:5]);
   xlabel('Time (msec)','fontsize',12,'FontWeight','Bold');
   ylabel('Amplitude (V)','fontsize',12,'FontWeight','Bold');
   text(Stimuli.period_ms/2000,-33,'Frequency (Hz)','fontsize',12,'horizontalalignment','center');
   text(Stimuli.period_ms/2000,-49,'Attenuation (dB)','fontsize',12,'horizontalalignment','center');
   box on;
   
   
   invoke(RP1,'SoftTrg',1);
   %    tspan = Stimuli.period_ms/1000;
   while(1)  % loop until "close" request
      if(invoke(RP2,'GetTagVal','BufFlag') == 1)
         CAPdata = invoke(RP2,'ReadTagV','ADbuf',0,CAPnpts);
         %           CAPdata = ones(size(CAPdata)); % ge debug
         
         % Forgetting AVG
         if ~firstSTIM
            CAPdataAvg_freerun = CAP_memFact * CAPdataAvg_freerun ...
               + (1 - CAP_memFact)*CAPdata;
         else
            CAPdataAvg_freerun = CAPdata;
            firstSTIM=0;
         end
         set(FIG.ax.line,'xdata',[0:(1/Stimuli.RPsamprate_Hz):Stimuli.CAPlength_sec], ...
            'ydata',CAPdataAvg_freerun);
         drawnow;
         invoke(RP2,'SoftTrg',2);
      end
            
      if get(FIG.push.close,'Userdata'),
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
            invoke(RP1,'SetTagVal','StmOn',Stimuli.duration_ms);
            invoke(RP1,'SetTagVal','StmOff',Stimuli.period_ms-Stimuli.duration_ms);
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
            % Setup panel for acquire/write mode:
            set(FIG.push.run_levels,'string','Abort');
            bAbort = 0;
            set(FIG.ax.line,'xdata',[],'ydata',[]); drawnow;  % clear the plot.
            
            attenIND=0;
            CAPdataAvg=cell(size(RunLevels_params.attenMask));
            CAPattens=cell(size(RunLevels_params.attenMask));
            for attenLevel = Stimuli.atten_dB + RunLevels_params.stepdB*RunLevels_params.attenMask
               attenIND=attenIND+1;
               CAPattens{attenIND}=attenLevel;
               disp(attenLevel);
               set(FIG.statText.status, 'String', sprintf('STATUS: averaging at -%ddB...', attenLevel));
               CAP_set_attns(attenLevel,Stimuli.channel,Stimuli.KHosc,RP1,RP2);
               CAPdataAvg{attenIND} = zeros(1, CAPnpts);
               for currPair = 1:RunLevels_params.nPairs
                  if (strcmp(get(FIG.push.run_levels, 'Userdata'), 'abort'))
                     bAbort = 1;
                     break;
                  end
                  % Get first of paired samples:
                  bNoSampleObtained = 1;
                  while(bNoSampleObtained)
                     if(invoke(RP2,'GetTagVal','BufFlag') == 1)
                        if(invoke(RP1,'GetTagVal','ampPolarity') > 0 | (Stimuli.fixedPhase == 1)) % check for stim polarity, if necessary
                           CAPdata = invoke(RP2,'ReadTagV','ADbuf',0,CAPnpts);
                           CAPdataAvg{attenIND} = CAPdataAvg{attenIND} + CAPdata;
                           bNoSampleObtained = 0;
                        end
                        invoke(RP2,'SoftTrg',2);
                     end
                  end
                  % Get second of paired samples:
                  bNoSampleObtained = 1;
                  while(bNoSampleObtained)
                     if(invoke(RP2,'GetTagVal','BufFlag') == 1)
                        if(invoke(RP1,'GetTagVal','ampPolarity') < 0 | (Stimuli.fixedPhase == 1)) % check for stim polarity, if necessary
                           CAPdata = invoke(RP2,'ReadTagV','ADbuf',0,CAPnpts);
                           CAPdataAvg{attenIND} = CAPdataAvg{attenIND} + CAPdata;
                           invoke(RP2,'SoftTrg',2);
                           bNoSampleObtained = 0;
                        end
                     end
                  end
                  set(FIG.ax.line,'xdata',[0:(1/Stimuli.RPsamprate_Hz):Stimuli.CAPlength_sec], ...
                     'ydata',CAPdataAvg{attenIND} / (2*currPair)); drawnow;
               end
               if (bAbort == 1)
                  break;
               end
               CAPdataAvg{attenIND} = CAPdataAvg{attenIND} / (2*RunLevels_params.nPairs);
               set(FIG.ax.line,'xdata',[0:(1/Stimuli.RPsamprate_Hz):Stimuli.CAPlength_sec], ...
                  'ydata',CAPdataAvg{attenIND}); drawnow;
            end
            
            if (bAbort == 0)
               ButtonName=questdlg('Do you wish to save these data?', ...
                  'Save Prompt', ...
                  'Yes','No','Comment','Yes');
               
               switch ButtonName,
               case 'Yes',
                  comment='No comment.';
               case 'Comment'
                  comment=add_comment_line;	%add a comment line before saving data file
               end
               
               disp(sprintf(ButtonName))
               if ~strcmp(ButtonName,'No')
                  make_CAP_text_file;
                  filename = current_data_file('CAP',1); %strcat(FILEPREFIX,num2str(FNUM),'.m');
                  uiresume; % Allow Nel's main window to update the Title
                  
                  %% From NEL: "update_nel_title"
                  if (strncmp(data_dir,NelData.File_Manager.dirname,length(data_dir)))
                     display_dir = strrep(NelData.File_Manager.dirname(length(data_dir)+1:end),'\','');
                  else
                     display_dir = NelData.File_Manager.dirname;
                  end
                  set(NelData.General.main_handle,'Name',['Running CAP ...  -  ''' display_dir '''   (' int2str(NelData.File_Manager.picture) ' Saved Pictures)']);
                  
                  
               end              
            end
            
            %               
            
            
            % Reset to "free running..." mode:
            set(FIG.statText.status, 'String', 'STATUS: free running...');
            CAP_set_attns(Stimuli.atten_dB,Stimuli.channel,Stimuli.KHosc,RP1,RP2);
            set(FIG.push.run_levels,'string','Run levels...');
            set(FIG.push.run_levels,'Userdata','');
            set(FIG.push.close,'Enable','on');
            
            
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

delete(FIG.handle);
clear FIG;

