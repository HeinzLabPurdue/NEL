global savedata_dir trigger_counter Stimuli

% File: CAP_RunLevels
% M. Heinz 18Nov2003
%
% Script for Taking CAP data (Run Levels), called at "case 10" within CAP_loop
%

%SP_nel_gui version


% Setup panel for acquire/write mode:

AutoLevel_params.ManThresh_dBSPL= Stimuli.MaxdBSPLCalib-Stimuli.atten_dB;
SaveFlag=1;

if runAudiogram==1 %KH 10Jan2012
    frequencies=AutoLevel_params.audiogramFreqs;s
else
    frequencies=Stimuli.freq_hz;
end
freqIND=0;

critVal=Stimuli.threshV;  %for artifact rejection, KH Jun2011

set(FIG.push.Automate_Levels,'string','Abort');
bAbort = 0;
set(FIG.ax.line,'xdata',[],'ydata',[]); 
drawnow;  % clear the plot.

if ~AutoLevel_params.ReRunFlag
    %Stimuli.MaxdBSPLCalib is TDT max atten
%     AutoLevel_params.attenMask=[round((Stimuli.MaxdBSPLCalib-AutoLevel_params.maxdBSPLtoRUN)/AutoLevel_params.stepdB): ...
%             min(120,ceil((Stimuli.atten_dB+AutoLevel_params.dB_below_thresh)/AutoLevel_params.stepdB))];
    dBs2RUN=AutoLevel_params.stepdB*floor(max(Stimuli.MaxdBSPLCalib-Stimuli.atten_dB-...
            AutoLevel_params.dB_below_thresh,Stimuli.MaxdBSPLCalib-120)/AutoLevel_params.stepdB)...
            :AutoLevel_params.stepdB:min(Stimuli.MaxdBSPLCalib,AutoLevel_params.maxdBSPLtoRUN);
    if dBs2RUN(1)<Stimuli.MaxdBSPLCalib-120 % Case: When the floor10 of -20 is not possible
        dBs2RUN(1)=Stimuli.MaxdBSPLCalib-120;
    end

    if Stimuli.MaxdBSPLCalib<AutoLevel_params.maxdBSPLtoRUN % Case when calibration is < 90
        AutoLevel_params.dBs2RUN=[dBs2RUN ,Stimuli.MaxdBSPLCalib];
        warning ('Calibration Below 90');
        ding, ding, 
        pause(0.1);
        ding, ding,
    else 
        AutoLevel_params.dBs2RUN=dBs2RUN;
    end
    
else 
    %     AutoLevel_params.attenMask=fliplr((Stimuli.MaxdBSPLCalib-...
    %     AutoLevel_params.ReRun_dBSPL-Stimuli.cur_freq_calib_dbshift)/AutoLevel_params.stepdB);
    AutoLevel_params.dBs2RUN=AutoLevel_params.ReRun_dBSPL;
    AutoLevel_params.ReRun_dBSPL=[];
end

% temp_a=AutoLevel_params.attenMask;

% if Stimuli.CalibBelow90
%     zdB_att_corr=-Stimuli.cur_freq_calib_dbshift/AutoLevel_params.stepdB;
%     temp_a=[zdB_att_corr,temp_a(2:end)];
%     AutoLevel_params.attenMask=temp_a;
%     ding;
%     warning ('Calibration Below 90');
% end

% rejections=zeros(length(frequencies),length(AutoLevel_params.attenMask));
% CAPattens=cell(size(AutoLevel_params.attenMask));
rejections=zeros(length(frequencies),length(AutoLevel_params.dBs2RUN));
CAPattens=cell(size(AutoLevel_params.dBs2RUN));

CAPdataAvg=cell(size(rejections));  % Average data, KH 10Jan2012
CAPdataReps=cell(size(rejections));  % All Reps

% Atten_dBs= fliplr(AutoLevel_params.stepdB*AutoLevel_params.attenMask)+Stimuli.cur_freq_calib_dbshift;
% Atten_dBs=Atten_dBs(Atten_dBs>=0);
Atten_dBs=(Stimuli.MaxdBSPLCalib-AutoLevel_params.dBs2RUN);

for zfrequency = frequencies %New outer loop, KH 10Jan2012
    freqIND=freqIND+1;
    if runAudiogram==1
        invoke(RP1,'SetTagVal','freq',zfrequency);
    end
    attenIND=0;
    
    for attenLevel = Atten_dBs
        attenIND=attenIND+1;
      
        CAPattens{attenIND}=attenLevel;
        %   disp(attenLevel);
        %set(FIG.statText.status, 'String', sprintf('STATUS: averaging at %dHz, -%ddB...', zfrequency, attenLevel));
        CAP_set_attns(attenLevel,Stimuli.channel,Stimuli.KHosc,RP1,RP2);
        set(FIG.asldr.val, 'string', sprintf('- %.1f',attenLevel));
        set(FIG.asldr.SPL,'string',sprintf('%.1f dBSPL',Stimuli.MaxdBSPLCalib-attenLevel));
        trigger_counter = trigger_counter + 1;
        fprintf('\nNew Trigger. Trigger %d',trigger_counter);
        invoke(RP3,'SetTagVal','StartTrig', 4); %start sending trigger
        invoke(RP3,'SetTagVal','TrigCounter', trigger_counter);

        %pause(5);
        %Grab current level and frequency, save into
        %triggers.txt
        current_atten = attenLevel;
        current_freq = Stimuli.freq_hz;
        current_click = Stimuli.clickYes; %1/0
        current_trigger = trigger_counter;
        %Initialize text file
        currentspot = pwd;
        cd(savedata_dir);
        fid = fopen('triggers.txt','at+');
        fprintf(fid,'%d,%d,%.2f,%d\r\n',current_trigger,current_freq,current_atten,current_click);
        fclose(fid);
        cd(currentspot);
        
        CAPdataAvg{freqIND,attenIND} = zeros(1, CAPnpts);
        CAPdataReps{freqIND,attenIND} = zeros(2*AutoLevel_params.nPairs,CAPnpts);
        % 28Apr2004 M.Heinz: Setup to skip 1st pulse pair, which is sometimes from previous level condition
        for currPair = 0:AutoLevel_params.nPairs
            if currPair
                set(FIG.statText.status, 'String', sprintf('STATUS: %dHz, -%.1fdB (%d %d)...',... %KH 2011 Jun 08
                    zfrequency, attenLevel, currPair, rejections(freqIND,attenIND)));
            end
            if (strcmp(get(FIG.push.Automate_Levels, 'Userdata'), 'abort'))
                invoke(RP3,'SetTagVal','StartTrig', 1); %stop sending trigger
                rc = PAset([120;120;120;120]);
                bAbort = 1;
                break;
            end
            % Get first of paired samples:
            bNoSampleObtained = 1;
            while(bNoSampleObtained)
                if(invoke(RP3,'GetTagVal','BufFlag') == 1)
                    if(invoke(RP1,'GetTagVal','ampPolarity') > 0 || (Stimuli.fixedPhase == 1)) 
                             % check for stim polarity, if necessary
                        CAPdata1 = invoke(RP3,'ReadTagV','ADbuf',0,CAPnpts);
                        CAPobs1=max(abs(CAPdata1(1:end-2)-mean(CAPdata1(1:end-2)))); %KH Jun2011
                        % ^^  Added SP because DC shift in abr probably affects the whole signal except the last point
                        if CAPobs1 <= critVal %Artifact rejection KH 2011 June 08
                            bNoSampleObtained = 0;
                            % Need to skip 1st pair, which is from last stimulus
                            if currPair
                                CAPdataReps{freqIND,attenIND}(2*(currPair-1)+1,:) = CAPdata1;
                                CAPdataAvg{freqIND,attenIND} = CAPdataAvg{freqIND,attenIND}...
                                    + CAPdataReps{freqIND,attenIND}(2*(currPair-1)+1,:);
                            end
                        else
                            rejections(freqIND,attenIND)=rejections(freqIND,attenIND)+1;
                        end                          %End for artifact rejection KH 2011 June 08
                    end
                    invoke(RP3,'SoftTrg',2);
                end
            end
            % Get second of paired samples:
            bNoSampleObtained = 1;
            while(bNoSampleObtained)
                if(invoke(RP3,'GetTagVal','BufFlag') == 1)
                    if(invoke(RP1,'GetTagVal','ampPolarity') < 0 || (Stimuli.fixedPhase == 1)) 
                             % check for stim polarity, if necessary
                        CAPdata2 = invoke(RP3,'ReadTagV','ADbuf',0,CAPnpts);
                        CAPobs2=max(abs(CAPdata2(1:end-2)-mean(CAPdata2(1:end-2))));
                        if CAPobs2 <= critVal %Artifact rejection KH 2011 June 08
                            bNoSampleObtained = 0;
                            if currPair
                                CAPdataReps{freqIND,attenIND}(2*currPair,:) = CAPdata2;
                                CAPdataAvg{freqIND,attenIND} = CAPdataAvg{freqIND,attenIND}...
                                    + CAPdataReps{freqIND,attenIND}(2*currPair,:);
                            end
                        else
                            rejections(freqIND,attenIND)=rejections(freqIND,attenIND)+1;
                        end
                    end
                    invoke(RP3,'SoftTrg',2);
                end
            end
            if currPair
                set(FIG.ax.line,'xdata',(1:CAPnpts)/Stimuli.RPsamprate_Hz, ...
                    'ydata',(CAPdataAvg{freqIND,attenIND}-mean(CAPdataAvg{freqIND,attenIND}))/(2*currPair)*Display.PlotFactor); 
                set(FIG.ax.line2(1),'ydata',max([CAPobs1 CAPobs2])); %KH 2011 June 08
                drawnow;
            end
        end
        if (bAbort == 1)
            break;
        end
        CAPdataAvg{freqIND,attenIND} = CAPdataAvg{freqIND,attenIND} / (2*AutoLevel_params.nPairs);
        set(FIG.ax.line,'xdata',(1:CAPnpts)/Stimuli.RPsamprate_Hz, ...
            'ydata',(CAPdataAvg{freqIND,attenIND}-mean(CAPdataAvg{freqIND,attenIND}))*Display.PlotFactor); drawnow;
        
        invoke(RP3,'SetTagVal','StartTrig', 1); %stop sending trigger
    end
    if (bAbort == 1)
        break;
    end
end

rc = PAset([120;120;120;120]); % added by GE/MH, 17Jan2003.  To force all attens to 120
Stimuli.atten_dB = 120;
set(FIG.asldr.val,'string',num2str(-Stimuli.atten_dB));
set(FIG.asldr.SPL,'string',sprintf('%.1f dB SPL',Stimuli.MaxdBSPLCalib-Stimuli.atten_dB));
set(FIG.asldr.slider, 'value', -Stimuli.atten_dB);
set(FIG.asldr.SPL,'string',sprintf('%.1f dB SPL',Stimuli.MaxdBSPLCalib-Stimuli.atten_dB));

if (bAbort == 0)
    beep;
    ButtonName=questdlg('Do you wish to save these data?', ...
        'Save Prompt', ...
        'Yes','No','Comment','Yes');
    
    switch ButtonName
    case 'Yes'
        comment='No comment.';
    case 'No'
        SaveFlag=0;
    case 'Comment'
        comment=add_comment_line;	%add a comment line before saving data file
    end
    
    %    disp(sprintf(ButtonName))
    if ~strcmp(ButtonName,'No')
        set(FIG.statText.status, 'String', 'STATUS: saving data...');
        
        make_ABR_text_file_auto;
        
        filename = current_data_file('CAP',1); %strcat(FILEPREFIX,num2str(FNUM),'.m');
        uiresume; % Allow Nel's main window to update the Title
        
        %% From NEL: "update_nel_title"
        if (strncmp(data_dir,NelData.File_Manager.dirname,length(data_dir)))
            display_dir = strrep(NelData.File_Manager.dirname(length(data_dir)+1:end),'\','');
        else
            display_dir = NelData.File_Manager.dirname;
        end
        set(NelData.General.main_handle,'Name',...
            ['Running CAP ...  -  ''' display_dir '''   (' int2str(NelData.File_Manager.picture) ' Saved Pictures)']);
        
        
    end
end

% Reset to "free running..." mode:
set(FIG.statText.status, 'String', ['STATUS (' interface_type '): free running...']);
CAP_set_attns(Stimuli.atten_dB,Stimuli.channel,Stimuli.KHosc,RP1,RP2);
set(FIG.push.Automate_Levels,'string','Auto Levels');
set(FIG.push.Automate_Levels,'Userdata','');
set(FIG.push.close,'Enable','on');
set(FIG.push.forget_now,'Enable','on');
firstSTIM = 1;  % Reset Running Avgs: MH 18Nov2003
AutoLevel_params.numAttens_1=attenIND;

