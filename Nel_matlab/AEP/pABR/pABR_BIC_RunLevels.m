function [firstSTIM, NelData]=pABR_BIC_RunLevels(FIG,Stimuli,invfiltdata, RunLevels_params, misc, FFR_Gating,...
     pABRnpts,interface_type, Display, NelData, data_dir, RP1, RP2, RP3, PROG, prog_dir,pABRstim)
pABR_flag = 1;
RunLevels_params.demean = true;
critVal = Stimuli.threshV;
if Stimuli.rec_channel ~= 1
    error('BIC requires Physiological Channel 1.');
end
recordRight = true;
recordLeft = false;
if Stimuli.channel == 1 && (isempty(Stimuli.channel2) || isnan(Stimuli.channel2))
    Stimuli.BIC_condition = 'MonauralRight';
elseif Stimuli.channel == 2 && (isempty(Stimuli.channel2) || isnan(Stimuli.channel2))
    Stimuli.BIC_condition = 'MonauralLeft';
elseif Stimuli.channel == 1 && Stimuli.channel2 == 2
    Stimuli.BIC_condition = 'Binaural';
else
    error('Invalid BIC routing. Use Right + No stimulus, Left + No stimulus, or Right + Left.');
end
stimRCXfName = [prog_dir '\object\pABRwav2_polIN.rcx'];
set(FIG.push.run_levels,'string','Abort');
set(FIG.push.forget_now,'string','Save NOW');
bAbort = 0;
save = 0;
for ii=1:5
    set(FIG.ax.line(ii),...
        'xdata',[],...
        'ydata',[]);
    set(FIG.ax.line(ii+5),...
        'xdata',[],...
        'ydata',[]);
end
if recordRight && recordLeft
    set(FIG.ax.line2(1),'ydata',[]);
    set(FIG.ax.line2(2),'ydata',[]);
elseif recordLeft
    set(FIG.ax.line2(2),'ydata',[]);
else
    set(FIG.ax.line2(1),'ydata',[]);
end
drawnow;
pABRlevels = RunLevels_params.attenMask(:).';
if isempty(pABRlevels)
    error('RunLevels_params.attenMask is empty.');
end
pABRlevels = 60:10:70;
pABRlevelAtten = zeros(1,length(pABRlevels));
for i=1:numel(pABRlevels)
    pABRlevelAtten(:,i) = pABRstim.maxSPL - pABRlevels(i);
end
nLevels = numel(pABRlevels);
pABR_PO_CumRes1 = cell(1,nLevels);
pABR_PO_CumRes2 = cell(1,nLevels);
pABR_NP_CumRes1 = cell(1,nLevels);
pABR_NP_CumRes2 = cell(1,nLevels);
pABR_Rstim=pABRstim.rightEpochs;
pABR_Lstim=pABR_Rstim;
pABRstim.leftEpochs=pABRstim.rightEpochs;
pABRstim.stimTrain(:,2,:)=pABRstim.stimTrain(:,1,:);
listlength = size(pABR_Rstim,1);
nPresentations =1;
totalPresentations = 2*listlength*nPresentations;
pABRattens = num2cell(pABRlevels);
pABRinterstim = cell(nLevels,totalPresentations);
pABR_EpochResp1 = cell(nLevels,totalPresentations);
pABR_EpochResp2 = cell(nLevels,totalPresentations);
pABRnpts = size(pABR_Rstim,2);
realtimeDir = 'C:\pABR_Realtime';
resultFile = fullfile(realtimeDir,'pABR_results.mat');
if ~exist(realtimeDir,'dir')
    mkdir(realtimeDir);
end
delete(fullfile(realtimeDir,'pABR_epoch_*.mat'));
delete(fullfile(realtimeDir,'pABR_level_*_epoch_*.mat'));
if exist(resultFile,'file')
    delete(resultFile);
end
stimFile = fullfile(realtimeDir,'pABRstim.mat');
if exist(stimFile,'file')
    delete(stimFile);
end
stimSavingFile = fullfile(realtimeDir,'pABRstim_saving.mat');
if exist(stimSavingFile,'file')
    delete(stimSavingFile);
end
savedPairCount = zeros(1,nLevels);
recordingCondition = 1;
builtin('save', ...
    stimSavingFile, ...
    'pABRstim', ...
    'pABRlevels', ...
    'recordingCondition', ...
    'recordRight', ...
    'recordLeft');
movefile( ...
    stimSavingFile, ...
    stimFile, ...
    'f');
for attenIND = 1:nLevels
    attenLevel = pABRlevels(attenIND);
    atten = pABRlevelAtten(attenIND);
    rejections = 0;
    pABRattens{attenIND} = attenLevel;
    set(FIG.statText.status, 'String', sprintf('STATUS: averaging at -%.1f dB...', attenLevel));
    invoke(RP1,'ClearCOF');
    invoke(RP1,'LoadCOF', stimRCXfName);
    invoke(RP1,'Run');
    invoke(RP1, 'SetTagVal', 'StmOn',  pABRstim.Gating.pABRDur_ms);
    invoke(RP1, 'SetTagVal', 'StmOff',  pABRstim.Gating.Period_ms - pABRstim.Gating.pABRDur_ms);
    invoke(RP1, 'SetTagVal', 'RiseFall', pABRstim.Gating.rftime_ms);
    nextStim = 1;
    xpR = double(pABR_Rstim(nextStim,:));
    xpL = double(pABR_Lstim(nextStim,:));
    tmpR = invoke(RP1,'WriteTagV','STIM_R',0,xpR);
    tmpL = invoke(RP1,'WriteTagV','STIM_L',0,xpL);
    if tmpR ~= 1 || tmpL ~= 1
        error('First pABR stimulus failed to load');
    end
    nextStim = nextStim + 1;
    pABR_set_attns(atten,Stimuli.channel, ...
        atten,Stimuli.channel2, ...
        Stimuli.KHosc,RP1,RP2);
    invoke(RP1,'SoftTrg',1);
    positiveAccepted = false;
    for currStim = 1:totalPresentations
        if mod(currStim,2) == 1
            positiveAccepted = false;
        end
        loadedThisOffTime = false;
        pairReadyToSave = false;
        if currStim
            set(FIG.statText.status, 'String', sprintf('STATUS: averaging at -%.1f dB [%d | %d | %d]...', ...
                attenLevel, currStim, rejections, totalPresentations));
            drawnow;
            savedStimIdx = nextStim - 1;
            if savedStimIdx < 1
                savedStimIdx = listlength;
            end
            pABRinterstim{attenIND,currStim} = savedStimIdx;
        end
        if (strcmp(get(FIG.push.forget_now, 'Userdata'), 'save') && ~mod(currStim,2))
            save = 1;
            RunLevels_params.nPairs_actual(attenIND) = currStim/2;
            break;
        end
        if strcmp(get(FIG.push.run_levels, 'Userdata'), 'abort')
            bAbort = 1;
            break;
        end
        while invoke(RP1,'GetTagVal','Stage') == 1
        end
        dataReadThisOff = false;
        while invoke(RP1,'GetTagVal','Stage') == 2
            if ~dataReadThisOff && invoke(RP3,'GetTagVal','BufFlag') == 1
                pABRdata1 = [];
                pABRdata2 = [];
                maxpABRobs1 = NaN;
                maxpABRobs2 = NaN;
                if recordRight
                    pABRdata1 = invoke(RP3,'ReadTagV','ADbuf',0,pABRnpts);
                    if ~isempty(pABRdata1)
                        maxpABRobs1 = max(abs(pABRdata1));
                    end
                end
                if recordLeft
                    pABRdata2 = invoke(RP3,'ReadTagV','ADbuf2',0,pABRnpts); %#ok<UNRCH>
                    if ~isempty(pABRdata2)
                        maxpABRobs2 = max(abs(pABRdata2));
                    end
                end
                rightDataValid = ~recordRight || ...
                    (~isempty(pABRdata1) && length(pABRdata1)==pABRnpts);
                leftDataValid = ~recordLeft || ...
                    (~isempty(pABRdata2) && length(pABRdata2)==pABRnpts);
                dataValid = rightDataValid && leftDataValid;
                rightArtifactFree = ~recordRight || maxpABRobs1 <= critVal;
                leftArtifactFree = ~recordLeft || maxpABRobs2 <= critVal2;
                artifactFree = rightArtifactFree && leftArtifactFree;
                if dataValid
                    dataReadThisOff = true;
                    fprintf('stim=%d ORG=%d expected=%d max1=%g/%g max2=%g/%g\n', ...
                        currStim, invoke(RP1,'GetTagVal','ORG'), mod(currStim,2), ...
                        maxpABRobs1, critVal);
                    if invoke(RP1,'GetTagVal','ORG') == mod(currStim,2) && artifactFree
                        if currStim > 0
                            if mod(currStim,2)
                                fprintf('ODD accepted: currStim = %d\n',currStim);
                                if recordRight
                                    pABR_PO_CumRes1{attenIND} = pABRdata1;
                                end
                                if recordLeft
                                    pABR_PO_CumRes2{attenIND} = pABRdata2;
                                end
                                positiveAccepted = true;
                            else
                                fprintf('EVEN accepted: currStim = %d\n',currStim);
                                if positiveAccepted
                                    if recordRight
                                        pABR_NP_CumRes1{attenIND} = pABRdata1;
                                    end
                                    if recordLeft
                                        pABR_NP_CumRes2{attenIND} = pABRdata2; %#ok<*UNRCH>
                                    end
                                    epochData.currentStimIdx = pABRinterstim{attenIND,currStim};
                                    epochData.attenIND = attenIND;
                                    epochData.attenLevel = attenLevel;
                                    epochData.recordingCondition = Stimuli.rec_channel;
                                    epochData.recordRight = recordRight;
                                    epochData.recordLeft = recordLeft;
                                    epochData.BIC_condition = Stimuli.BIC_condition;
                                    epochData.stimulusChannel1 = Stimuli.channel;
                                    epochData.stimulusChannel2 = Stimuli.channel2;
                                    epochData.pABR_CumRes1 = [];
                                    epochData.pABR_CumRes2 = [];
                                    if recordRight
                                        epochData.pABR_CumRes1 = ...
                                            (pABR_PO_CumRes1{attenIND} + ...
                                            pABR_NP_CumRes1{attenIND})/2;
                                    end
                                    if recordLeft
                                        epochData.pABR_CumRes2 = ...
                                            (pABR_PO_CumRes2{attenIND} + ...
                                            pABR_NP_CumRes2{attenIND})/2;
                                    end
                                    pairReadyToSave = true;
                                end
                            end
                        end
                        if currStim
                            if recordRight
                                pABR_EpochResp1{attenIND,currStim} = pABRdata1;
                            end
                            if recordLeft
                                pABR_EpochResp2{attenIND,currStim} = pABRdata2;
                            end
                        end
                    elseif ~artifactFree
                        rejections = rejections + 1;
                    end
                    invoke(RP3,'SoftTrg',2);
                end
            end
            if pABR_flag && ~loadedThisOffTime && mod(currStim,2)==0 && nextStim <= listlength
                xpR = double(pABR_Rstim(nextStim,:));
                xpL = double(pABR_Lstim(nextStim,:));
                tmpR = invoke(RP1,'WriteTagV','STIM_R',0,xpR);
                tmpL = invoke(RP1,'WriteTagV','STIM_L',0,xpL);
                sprintf('loaded %.0d',currStim)
                if tmpR == 1 && tmpL == 1
                    loadedThisOffTime = true;
                    nextStim = nextStim + 1;
                    if nextStim > listlength
                        nextStim = 1;
                    end
                end
            end
        end
        if pairReadyToSave
            pairSavingFile = fullfile(realtimeDir, ...
                sprintf('pABR_level_%03d_epoch_%04d_saving.mat',attenIND,currStim/2));
            pairFile = fullfile(realtimeDir, ...
                sprintf('pABR_level_%03d_epoch_%04d.mat',attenIND,currStim/2));
            builtin('save', ...
                pairSavingFile, ...
                '-struct', ...
                'epochData');
            movefile( ...
                pairSavingFile, ...
                pairFile, ...
                'f');
            savedPairCount(attenIND) = savedPairCount(attenIND) + 1;
        end
        if ~dataReadThisOff
            sprintf('currStim %d: Data not read during stage2', currStim);
        end
        if ~loadedThisOffTime && mod(currStim,2)==0
            sprintf('currStim %d: Next Stim not loaded during stage2', currStim);
        end
    end
    RunLevels_params.nPairs_actual(attenIND) = savedPairCount(attenIND);
    if bAbort == 0 && savedPairCount(attenIND) > 0
        set(FIG.statText.status, ...
            'String', ...
            sprintf('STATUS: waiting for %.1f dB processing...',attenLevel));
        levelProcessed = false;
        resultData = struct();
        while ~levelProcessed
            if exist(resultFile,'file')
                try
                    resultData = load(resultFile, ...
                        'processedPairs', ...
                        'rightResp', ...
                        'leftResp');
                    if isfield(resultData,'processedPairs') && ...
                            numel(resultData.processedPairs) >= attenIND
                        levelProcessed = ...
                            resultData.processedPairs(attenIND) >= ...
                            savedPairCount(attenIND);
                    end
                catch
                    levelProcessed = false;
                end
            end
            if ~levelProcessed
                pause(0.05);
                drawnow;
                if strcmp(get(FIG.push.run_levels,'Userdata'),'abort')
                    bAbort = 1;
                    break;
                end
            end
        end
        if bAbort == 0
            rightResp_level = [];
            leftResp_level = [];
            if recordRight
                if ~isfield(resultData,'rightResp') || ...
                        size(resultData.rightResp,2) < attenIND
                    error('The processing result does not contain the right response for %.1f dB.',attenLevel);
                end
                rightResp_level = resultData.rightResp(:,attenIND);
            end
            if recordLeft
                if ~isfield(resultData,'leftResp') || ...
                        size(resultData.leftResp,2) < attenIND
                    error('The processing result does not contain the left response for %.1f dB.',attenLevel);
                end
                leftResp_level = resultData.leftResp(:,attenIND);
            end
            RunLevels_params_level = RunLevels_params;
            RunLevels_params_level.attenMask = attenLevel;
            RunLevels_params_level.nPairs_actual = savedPairCount(attenIND);
            pABRattens_level = pABRattens(attenIND);
            pABRinterstim_level = pABRinterstim(attenIND,:);
            pABR_EpochResp1_level = pABR_EpochResp1(attenIND,:);
            pABR_EpochResp2_level = pABR_EpochResp2(attenIND,:);
            comment = sprintf('pABR BIC %s level %.1f dB.',Stimuli.BIC_condition,attenLevel);
            AEP_set_attns2(120,Stimuli.channel,120,Stimuli.channel2, ...
                Stimuli.KHosc,RP1,RP2);
            PAset([120;120;120;120]);
            set(FIG.statText.status, ...
                'String', ...
                sprintf('STATUS: saving %.1f dB data...',attenLevel));
            NelData = make_pABR_BIC_text_file( ...
                misc, ...
                Stimuli, ...
                invfiltdata, ...
                PROG, ...
                NelData, ...
                comment, ...
                RunLevels_params_level, ...
                FFR_Gating, ...
                rightResp_level, ...
                Display, ...
                pABRattens_level, ...
                pABRinterstim_level, ...
                pABR_EpochResp1_level, ...
                pABRstim);
            current_data_file('FFR',1);
            fprintf('Saved pABR level %.1f dB to NEL (%d pairs).\n', ...
                attenLevel,savedPairCount(attenIND));
            if strncmp(data_dir,NelData.File_Manager.dirname,length(data_dir))
                display_dir = strrep( ...
                    NelData.File_Manager.dirname(length(data_dir)+1:end),'\','');
            else
                display_dir = NelData.File_Manager.dirname;
            end
            set(NelData.General.main_handle,'Name', ...
                ['Running pABR ...  -  ''' display_dir '''   (' ...
                int2str(NelData.File_Manager.picture) ' Saved Pictures)']);
        end
    end
    if bAbort == 1 || save == 1
        break;
    end
end
if bAbort == 0 && sum(savedPairCount) == 0
    error('No accepted pABR pairs were saved.');
end
if bAbort == 0
    beep;
end
set(FIG.statText.status, 'String', ['STATUS (' interface_type '): free running...']);
AEP_set_attns2(120,Stimuli.channel,120,Stimuli.channel2,Stimuli.KHosc,RP1,RP2);
set(FIG.push.run_levels,'string','Run BIC...');
set(FIG.push.run_levels,'Userdata','');
set(FIG.push.forget_now,'string','Forget NOW');
set(FIG.push.forget_now,'Userdata','');
set(FIG.push.close,'Enable','on');
firstSTIM = 1;
for ii=1:5
    set(FIG.ax.line(ii),...
        'xdata',[],...
        'ydata',[]);
    set(FIG.ax.line(ii+5),...
        'xdata',[],...
        'ydata',[]);
end
set(FIG.ax.line2(1),'ydata',[]);
set(FIG.ax.line2(2),'ydata',[]);
drawnow;
misc.n = double(~(invoke(RP1,'GetTagVal','ORG')));
end
