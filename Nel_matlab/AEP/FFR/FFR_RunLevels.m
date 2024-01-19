% File: FFR_RunLevels
% M. Heinz 18Nov2003
% 
% Script for Taking FFR data (Run Levels), called at "case 10" within FFR_loop
%
% Modified zz 04nov2011
warning off;
critVal=Stimuli.threshV;  %for artifact rejection KHZZ 2011 Nov 4

% RunLevels_params.nPairs = Stimuli.FFRmem_reps;
% Setup panel for acquire/write mode:
set(FIG.push.run_levels,'string','Abort');
set(FIG.push.forget_now,'string','Save NOW');
bAbort = 0;
save = 0;
set(FIG.ax.line ,'xdata',[],'ydata',[]);   
set(FIG.ax.line2,'xdata',[],'ydata',[]); 
set(FIG.ax.line3,'ydata',[0]); drawnow;  % clear the plot.


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

   
attenIND=0;
FFRdataAvg_NP=cell(size(RunLevels_params.attenMask));  % Average data not polarized %zz 04nov11
FFRdataAvg_PO=cell(size(RunLevels_params.attenMask));  % Average data polarized     %zz 04nov11
% FFRdataAvg = cell(size(RunLevels_params.attenMask));   % Bobby
FFRdataStoreNP = cell(size(RunLevels_params.attenMask));
FFRdataStorePO = cell(size(RunLevels_params.attenMask));

% not storing all repetitions zz 04nov11
FFRdataReps=cell(size(RunLevels_params.attenMask));  % All Reps
FFRattens=cell(size(RunLevels_params.attenMask));

for attenLevel = Stimuli.atten_dB + RunLevels_params.stepdB*RunLevels_params.attenMask
   set(FIG.ax.line3,'ydata',[]);
   rejections=0; %for artifact rejection KHZZ 2011 Nov 4
   attenIND=attenIND+1;
   FFRattens{attenIND}=attenLevel;
   %   disp(attenLevel);
   set(FIG.statText.status, 'String', sprintf('STATUS: averaging at -%ddB...', attenLevel));
   FFR_set_attns(Stimuli.atten_dB,(Stimuli.noiseLevel*(1-Stimuli.noNoise)...
                    +(Stimuli.noNoise)*(Stimuli.atten_dB-120)),Stimuli.channel,Stimuli.KHosc,RP1,RP2);
   FFRdataAvg_NP{attenIND} = zeros(1, FFRnpts); %zz 04nov11
   FFRdataAvg_PO{attenIND} = zeros(1, FFRnpts); %zz 04nov11
   for nnnnnnnn=[1:2*RunLevels_params.nPairs]
       FFRdataReps{nnnnnnnn} = zeros(1,FFRnpts); % 2*RunLevels_params.nPairs changed to 1 DA 7/24/13
   end
   % 28Apr2004 M.Heinz: Setup to skip 1st pulse pair, which is sometimes from previous level condition
   for currStim = 0:2*RunLevels_params.nPairs
      if currStim
         set(FIG.statText.status, 'String', sprintf('STATUS: averaging at -%.1f dB (%d/%d)...',... %KHZZ 2011 Nov 4
            attenLevel, currStim, rejections));
         %set(FIG.statText.status, 'String', sprintf('STATUS: averaging at -%ddB (%d)...', attenLevel, currStim));
      end
      if (strcmp(get(FIG.push.forget_now, 'Userdata'), 'save') && ~mod(currStim,2))
         save = 1;
         RunLevels_params.nPairs_actual = currStim/2;
         break;
      end
      if (strcmp(get(FIG.push.run_levels, 'Userdata'), 'abort'))
         bAbort = 1;
         break;
      end
      bNoSampleObtained = 1;
      while(bNoSampleObtained)
         if(invoke(RP3,'GetTagVal','BufFlag') == 1)
            FFRdata = invoke(RP3,'ReadTagV','ADbuf',0,FFRnpts);
            FFRobs1 = max(abs(FFRdata)); %Artifact rejection KHZZ 2011 Nov 4
            set(FIG.ax.line3,'xdata',0.5,'ydata',FFRobs1); drawnow;
            % zz 05nov11
            % fixing the function to make sure the polarity matches, starts with 1, which must match with 1 for original
            if (FFRobs1 <= critVal && (invoke(RP1,'GetTagVal','ORG') == mod(currStim,2)))
               %            if FFRobs1 <= critVal 
               bNoSampleObtained = 0;
               % Need to skip 1st pair, which is from last stimulus
               %            if currStim
               %               CAPdataReps{attenIND}(2*(currStim-1)+1,:) = CAPdata1;
               %              CAPdataAvg{attenIND} = CAPdataAvg{attenIND} + CAPdataReps{attenIND}(2*(currStim-1)+1,:);
               %         end
               
               
               %bNoSampleObtained = 0;
               % Need to skip 1st pair, which is from last stimulus
               if currStim
                  weight = 1/ceil(currStim/2);
                  if mod(currStim,2)
                     FFRdataAvg_NP{attenIND} = FFRdataAvg_NP{attenIND}*(1 - weight) + weight*FFRdata;
                     if strcmp(interface_type,'SPIKES')
                        FFRdataStoreNP{attenIND} = cat( 1, FFRdataStoreNP{attenIND}, FFRdata );
                     end
                  else
                     FFRdataAvg_PO{attenIND} = FFRdataAvg_PO{attenIND}*(1 - weight) + weight*FFRdata;
                     if strcmp(interface_type,'SPIKES')
                        FFRdataStorePO{attenIND} = cat( 1, FFRdataStorePO{attenIND}, FFRdata );
                     end
                  end
                  FFRdataReps{currStim}=FFRdata; %added DA 7/23/13
%                   FFRdataAvg{attenIND} = FFRdataAvg{attenIND} + FFRdataReps{attenIND}(2*(currStim-1)+1,:);      % Bobby
               end
            elseif FFRobs1 > critVal
%             else
               rejections=rejections+1;
            end                          %End for artifact rejection KH 2011 June 08
            invoke(RP3,'SoftTrg',2);
         end
      end
      % Get second of paired samples: - removed zz 04nov11
      % No need to get second of paired samples, as they are interweaved zz 04nov11
      %       bNoSampleObtained = 1;
      %       while(bNoSampleObtained)
      %          if(invoke(RP3,'GetTagVal','BufFlag') == 1)
      %             if(invoke(RP1,'GetTagVal','ampPolarity') < 0 | (Stimuli.fixedPhase == 1)) % check for stim polarity, if necessary
      %                FFRdata2 = invoke(RP3,'ReadTagV','ADbuf',0,FFRnpts);
      %                bNoSampleObtained = 0;
      %                if currStim
      % %                   FFRdataReps{attenIND}(2*currStim,:) = FFRdata2;
      %                   FFRdataAvg{attenIND} = FFRdataAvg{attenIND} + FFRdataReps{attenIND}(2*currStim,:);
      %                end
      %             end
      %             invoke(RP3,'SoftTrg',2);
      %          end
      %       end                 
      if currStim
         if mod(currStim,2)
%             set(FIG.ax.line,'xdata',[0:(1/Stimuli.RPsamprate_Hz):FFR_Gating.FFRlength_ms/1000], ...
%                'ydata',FFRdataAvg_NP{attenIND}*Display.PlotFactor); drawnow;
         else
            set(FIG.ax.line,'xdata',[0:(1/Stimuli.RPsamprate_Hz):FFR_Gating.FFRlength_ms/1000], ...
               'ydata',(FFRdataAvg_PO{attenIND}+FFRdataAvg_NP{attenIND})*Display.PlotFactor/2); drawnow;
         end
      end
   end
   
   if (bAbort == 1 || save == 1)
      break;
   end
   %    FFRdataAvg{attenIND} = FFRdataAvg{attenIND} / (2*RunLevels_params.nPairs);
   %    set(FIG.ax.line,'xdata',[0:(1/Stimuli.RPsamprate_Hz):FFR_Gating.FFRlength_ms/1000], ...
   %       'ydata',FFRdataAvg{attenIND}*Display.PlotFactor); drawnow;
end

if (bAbort == 0)
   beep;
   ButtonName=questdlg('Do you wish to save these data?', ...
      'Save Prompt', ...
      'Yes','No','Comment','Yes');
   
   switch ButtonName,
   case 'Yes',
      comment='No comment.';
   case 'Comment'
      comment=add_comment_line;	%add a comment line before saving data file
   end
   
%    disp(sprintf(ButtonName))
   if ~strcmp(ButtonName,'No')
      set(FIG.statText.status, 'String', 'STATUS: saving data...');
      make_FFR_text_file;
      filename = current_data_file('FFR',1); %strcat(FILEPREFIX,num2str(FNUM),'.m');
      uiresume; % Allow Nel's main window to update the Title
      
      %% From NEL: "update_nel_title"
      if (strncmp(data_dir,NelData.File_Manager.dirname,length(data_dir)))
         display_dir = strrep(NelData.File_Manager.dirname(length(data_dir)+1:end),'\','');
      else
         display_dir = NelData.File_Manager.dirname;
      end
      set(NelData.General.main_handle,'Name',['Running FFR ...  -  ''' display_dir '''   (' int2str(NelData.File_Manager.picture) ' Saved Pictures)']);
      
      
   end              
end

% Reset to "free running..." mode:
set(FIG.statText.status, 'String', ['STATUS (' interface_type '): free running...']);
FFR_set_attns(Stimuli.atten_dB,(Stimuli.noiseLevel*(1-Stimuli.noNoise)...
                    +(Stimuli.noNoise)*(Stimuli.atten_dB-120)),Stimuli.channel,Stimuli.KHosc,RP1,RP2);
set(FIG.push.run_levels,'string','Run levels...');
set(FIG.push.run_levels,'Userdata','');
set(FIG.push.forget_now,'string','Forget NOW');
set(FIG.push.forget_now,'Userdata','');
set(FIG.push.close,'Enable','on');
% set(FIG.push.forget_now,'Enable','on');
firstSTIM = 1;  % Reset Running Avgs: MH 18Nov2003
set(FIG.ax.line ,'xdata',[],'ydata',[]);   
set(FIG.ax.line2,'xdata',[],'ydata',[]); drawnow;  % clear the plot.
% misc.n = double(~(invoke(RP1,'GetTagVal','ORG')))+(~save);
% misc.n = double(~(invoke(RP1,'GetTagVal','ORG')))+(bAbort);  %original 27jan2012
misc.n = double(~(invoke(RP1,'GetTagVal','ORG')));