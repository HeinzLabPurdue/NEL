% Adapted from
% File: CAP_RunLevels (CAP code)
% M. Heinz 18Nov2003

%WARNING : This code is only used as a script for RunStimuli.


critVal=Stimuli.threshV;  %for artifact rejection, KH Jun2011
runStimuli = strcmp(runLevelsMode, 'run_stimuli'); %if true, run only a single level (code below used as a script in CAP_RunStimuli.m)
assert(runStimuli, 'only run_Stimuli is available');

rejections=0;
pushButton=FIG.push.run_stimuli;

bAbort = 0;
set(FIG.ax.line,'xdata',[],'ydata',[]); drawnow;  % clear the plot.

%atten set in RunStimuli

CAPnpts=ceil(CAP_Gating.CAPlength_ms/1000*Stimuli.RPsamprate_Hz);
CAPdataAvg = zeros(1, CAPnpts);
CAPdataReps = zeros(2*RunLevels_params.nPairs,CAPnpts);

CAPmaxAvg=0;
% 28Apr2004 M.Heinz: Setup to skip 1st pulse pair, which is sometimes from previous condition
% FD 2020 - ignore skip (index begins at 1)
for currPair = 1:RunLevels_params.nPairs
    if currPair
        set(FIG.statText.status2, 'String', sprintf('Pairs: %d, %d rejec.', currPair, rejections));
    end
    if (strcmp(get(pushButton, 'Userdata'), 'abort'))
        bAbort = 1;
        break;
    end
    
    % Get first of paired samples:
    bNoSampleObtained = 1;
    while(bNoSampleObtained)
        if(noNEL || invoke(RP3,'GetTagVal','BufFlag') == 1)
            if(noNEL || invoke(RP1,'GetTagVal','ampPolarity') > 0 || (Stimuli.fixedPhase == 1)) % check for stim polarity, if necessary
                if noNEL  
                    CAPdata1= 0.05*randn(1, CAPnpts);
                    pause(0.1);
                else
                    CAPdata1 = invoke(RP3,'ReadTagV','ADbuf',0,CAPnpts);
                end
                CAPobs1=max(abs(CAPdata1)); %KH Jun2011
                if CAPobs1 <= critVal %Artifact rejection KH 2011 June 08
                    bNoSampleObtained = 0;
                    CAPmaxAvg=CAPmaxAvg+CAPobs1;
                    % Need to skip 1st pair, which is from last stimulus
                    if currPair
                        CAPdataReps(2*(currPair-1)+1,:) = CAPdata1;
                        CAPdataAvg = CAPdataAvg+ CAPdataReps(2*(currPair-1)+1,:);
                    end
                else
                    rejections=rejections+1;
                end                          %End for artifact rejection KH 2011 June 08
            end
            if ~noNEL
              invoke(RP3,'SoftTrg',2);
            end
        end
    end
    
    % Get second of paired samples:
    bNoSampleObtained = 1;
    while(bNoSampleObtained)
        if(noNEL || invoke(RP3,'GetTagVal','BufFlag') == 1)
            if(noNEL || invoke(RP1,'GetTagVal','ampPolarity') < 0 || (Stimuli.fixedPhase == 1)) % check for stim polarity, if necessary
                if noNEL  
                    CAPdata2= 0.05*randn(1, CAPnpts);
                    pause(0.1);
                else
                    CAPdata2 = invoke(RP3,'ReadTagV','ADbuf',0,CAPnpts);
                end
                CAPobs2=max(abs(CAPdata2));
                if CAPobs2 <= critVal %Artifact rejection KH 2011 June 08
                    
                     bNoSampleObtained = 0;
                     CAPmaxAvg=CAPmaxAvg+CAPobs2;
                    % Need to skip 1st pair, which is from last stimulus
                    if currPair
                        CAPdataReps(2*currPair,:) = CAPdata2;
                        CAPdataAvg = CAPdataAvg+ CAPdataReps(2*currPair,:);
                    end
                    
                   
                else
                    rejections=rejections+1;
                end
            end
            if ~noNEL
                invoke(RP3,'SoftTrg',2);
            end
        end
    end
    
    if currPair
        set(FIG.ax.line,'xdata',0:(1/Stimuli.RPsamprate_Hz):CAP_Gating.CAPlength_ms/1000, ...
            'ydata',(CAPdataAvg-mean(CAPdataAvg))/(2*currPair)*Display.PlotFactor); % added demean SP 21 Aug 2018
        set(FIG.ax.line2(1),'ydata',max([CAPobs1 CAPobs2])); %KH 2011 June 08
        drawnow;
    end
    
        
end

CAPdataAvg = CAPdataAvg/(2*RunLevels_params.nPairs);
CAPmaxAvg = CAPmaxAvg/(2*RunLevels_params.nPairs);        

% force all attens to 120
%   In RunStimuli
% 

if (bAbort == 0)
    %beep;
    

    %    disp(sprintf(ButtonName))
    if ~strcmp(CAPButtonName,'No') && ~noNEL
        set(FIG.statText.status, 'String', 'STATUS: saving data...');
        
        make_fmaskedCAP_text_file;
        % filename = current_data_file('fmasked-CAP',1); %strcat(FILEPREFIX,num2str(FNUM),'.m'); %useless line?
        uiresume; % Allow Nel's main window to update the Title

        % From NEL: "update_nel_title"
        if (strncmp(data_dir,NelData.File_Manager.dirname,length(data_dir)))
            display_dir = strrep(NelData.File_Manager.dirname(length(data_dir)+1:end),'\','');
        else
            display_dir = NelData.File_Manager.dirname;
        end
        
        set(NelData.General.main_handle,'Name',['Running fmasked CAP ...  -  ''' display_dir '''   (' int2str(NelData.File_Manager.picture) ' Saved Pictures)']);


    end

end
% Reset to "free running..." mode:
% In RunStimuli
