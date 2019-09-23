% File: CAP_RunLevels
% M. Heinz 18Nov2003
%
% Script for Taking CAP data (Run Levels), called at "case 10" within CAP_loop
%


% Setup panel for acquire/write mode:
SaveFlag=1;

if runAudiogram==1 %KH 10Jan2012
    frequencies=RunLevels_params.audiogramFreqs;
else
    frequencies=Stimuli.freq_hz;
end
freqIND=0;

critVal=Stimuli.threshV;  %for artifact rejection, KH Jun2011
rejections=zeros(length(frequencies),length(RunLevels_params.attenMask));

set(FIG.push.run_levels,'string','Abort');
bAbort = 0;
set(FIG.ax.line,'xdata',[],'ydata',[]); drawnow;  % clear the plot.


CAPdataAvg=cell(size(rejections));  % Average data, KH 10Jan2012
CAPdataReps=cell(size(rejections));  % All Reps

CAPattens=cell(size(RunLevels_params.attenMask));


for zfrequency = frequencies %New outer loop, KH 10Jan2012
    freqIND=freqIND+1;
    if runAudiogram==1
        invoke(RP1,'SetTagVal','freq',zfrequency);
    end
    attenIND=0;
    
    for attenLevel = Stimuli.atten_dB + RunLevels_params.stepdB*RunLevels_params.attenMask
        attenIND=attenIND+1;
        CAPattens{attenIND}=attenLevel;
        %   disp(attenLevel);
        %set(FIG.statText.status, 'String', sprintf('STATUS: averaging at %dHz, -%ddB...', zfrequency, attenLevel));
        CAP_set_attns(attenLevel,Stimuli.channel,Stimuli.KHosc,RP1,RP2);
        
        set(FIG.asldr.val, 'string', ['-' num2str(attenLevel)]);
        set(FIG.asldr.SPL,'string',sprintf('%.1f dBSPL',Stimuli.MaxdBSPLCalib-attenLevel));
        
        
        CAPdataAvg{freqIND,attenIND} = zeros(1, CAPnpts);
        CAPdataReps{freqIND,attenIND} = zeros(2*RunLevels_params.nPairs,CAPnpts);
        % 28Apr2004 M.Heinz: Setup to skip 1st pulse pair, which is sometimes from previous level condition
        for currPair = 0:RunLevels_params.nPairs
            if currPair
                set(FIG.statText.status, 'String', sprintf('STATUS: %d Hz, -%.1f dB (%d %d)...',... %KH 2011 Jun 08
                    zfrequency, attenLevel, currPair, rejections(freqIND,attenIND)));
            end
            if (strcmp(get(FIG.push.run_levels, 'Userdata'), 'abort'))
                bAbort = 1;
                break;
            end
            % Get first of paired samples:
            bNoSampleObtained = 1;
            while(bNoSampleObtained)
                if(invoke(RP3,'GetTagVal','BufFlag') == 1)
                    if(invoke(RP1,'GetTagVal','ampPolarity') > 0 || (Stimuli.fixedPhase == 1)) % check for stim polarity, if necessary
                        CAPdata1 = invoke(RP3,'ReadTagV','ADbuf',0,CAPnpts);
                        CAPobs1=max(abs(CAPdata1(1:end-2)-mean(CAPdata1(1:end-2)))); %KH Jun2011
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
                    if(invoke(RP1,'GetTagVal','ampPolarity') < 0 || (Stimuli.fixedPhase == 1)) % check for stim polarity, if necessary
                        CAPdata2 = invoke(RP3,'ReadTagV','ADbuf',0,CAPnpts);
                        CAPobs2=max(abs(CAPdata2(1:end-2)-mean(CAPdata2(1:end-2)))); %KH Jun2011
                        if CAPobs2 <= critVal %Artifact rejection KH 2011 June 08
                            bNoSampleObtained = 0;
                            if currPair
                                CAPdataReps{freqIND,attenIND}(2*currPair,:) = CAPdata2;
                                CAPdataAvg{freqIND,attenIND} = CAPdataAvg{freqIND,attenIND} + CAPdataReps{freqIND,attenIND}(2*currPair,:);
                            end
                        else
                            rejections(freqIND,attenIND)=rejections(freqIND,attenIND)+1;
                        end
                    end
                    invoke(RP3,'SoftTrg',2);
                end
            end
            if currPair
                set(FIG.ax.line,'xdata',0:(1/Stimuli.RPsamprate_Hz):CAP_Gating.CAPlength_ms/1000, ...
                    'ydata',(CAPdataAvg{freqIND,attenIND}-mean(CAPdataAvg{freqIND,attenIND}))/(2*currPair)*Display.PlotFactor);
                set(FIG.ax.line2(1),'ydata',max([CAPobs1 CAPobs2])); %KH 2011 June 08
                drawnow;
            end
        end
        if (bAbort == 1)
            break;
        end
        CAPdataAvg{freqIND,attenIND} = CAPdataAvg{freqIND,attenIND} / (2*RunLevels_params.nPairs);
        set(FIG.ax.line,'xdata',0:(1/Stimuli.RPsamprate_Hz):CAP_Gating.CAPlength_ms/1000, ...
            'ydata',(CAPdataAvg{freqIND,attenIND}-mean(CAPdataAvg{freqIND,attenIND}))*Display.PlotFactor); drawnow;
    end
end

rc = PAset([120;120;120;120]); % added by GE/MH, 17Jan2003.  To force all attens to 120
set(FIG.asldr.val,'string',num2str(-120));
set(FIG.asldr.SPL,'string',sprintf('%.1f dB SPL',Stimuli.MaxdBSPLCalib-120));
set(FIG.asldr.slider, 'value', -120);
set(FIG.asldr.SPL,'string',sprintf('%.1f dB SPL',Stimuli.MaxdBSPLCalib-120));


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
        
        temp=AutoLevel_params.bMultiOutputFiles;
        AutoLevel_params.bMultiOutputFiles=0;
        make_ABR_text_file_auto;
        AutoLevel_params.bMultiOutputFiles=temp;
        clear temp;
        
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

% Reset to "free running..." mode:
set(FIG.statText.status, 'String', ['STATUS (' interface_type '): free running...']);
CAP_set_attns(Stimuli.atten_dB,Stimuli.channel,Stimuli.KHosc,RP1,RP2);
set(FIG.push.run_levels,'string','Run levels...');
set(FIG.push.run_levels,'Userdata','');
set(FIG.push.close,'Enable','on');
set(FIG.push.forget_now,'Enable','on');
firstSTIM = 1;  % Reset Running Avgs: MH 18Nov2003
