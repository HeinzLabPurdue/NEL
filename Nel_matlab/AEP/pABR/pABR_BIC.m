function [firstSTIM,NelData] = pABR_BIC(FIG,Stimuli,invfiltdata,RunLevels_params,misc,FFR_Gating,...
    pABRnpts,interface_type,Display,NelData,data_dir,RP1,RP2,RP3,PROG,prog_dir,pABRstim)
% Complete BIC sequence: monaural right, monaural left, then binaural.
% All conditions record only RP3 ADbuf and are saved together once.

if Stimuli.rec_channel ~= 1
    error('pABR_BIC requires Stimuli.rec_channel = 1 (ADbuf).');
end
% [Signal 1 requested ear, Signal 2 requested ear].
% The routing function gives Signal 1 priority when both request one ear.
conditionChannels = [ ...
    1   1;   ... % monaural right; Signal 2 is disconnected by priority
    2   2;   ... % monaural left; Signal 2 is disconnected by priority
    1   2];      % RP1.1 -> right and RP1.2 -> left

conditionLabels = {
    'MonauralRight'
    'MonauralLeft'
    'Binaural'
};
nConditions = 3;
critVal = Stimuli.threshV;
pABR_flag = 1;
RunLevels_params.demean = true;
stimRCXfName = [prog_dir '\object\pABRwav2_polIN.rcx'];

set(FIG.push.run_levels,'String','Abort','Userdata','');
set(FIG.push.forget_now,'String','Save NOW','Userdata','');
set(FIG.push.close,'Enable','off');
bAbort = false;
saveNow = false;
for ii=1:5
    set(FIG.ax.line(ii),'XData',[],'YData',[]);
    set(FIG.ax.line(ii+5),'XData',[],'YData',[]);
end
set(FIG.ax.line2(1),'YData',[]);
drawnow;

pABRlevels =80;
pABRlevelAtten = pABRstim.maxSPL-pABRlevels;
nLevels = numel(pABRlevels);
pABR_Rstim = pABRstim.rightEpochs;
pABR_Lstim = pABR_Rstim;
% Both RP1 output buffers use the same stimulus and timing train.
pABRstim.leftEpochs = pABRstim.rightEpochs;
pABRstim.stimTrain(:,2,:) = pABRstim.stimTrain(:,1,:);
listlength = size(pABR_Rstim,1);
pABRnpts = size(pABR_Rstim,2);
totalPresentations = 2*listlength;
pABRattens = num2cell(pABRlevels);
pABRinterstim = cell(nConditions,nLevels,totalPresentations);
pABR_EpochResp1 = cell(nConditions,nLevels,totalPresentations);
savedPairCount = zeros(nConditions,nLevels);
RunLevels_params.nPairs_actual_BIC = zeros(nConditions,nLevels);

realtimeDir = 'C:\pABR_Realtime';
if ~exist(realtimeDir,'dir'), mkdir(realtimeDir); end
stimFile = fullfile(realtimeDir,'pABRstim.mat');
stimSavingFile = fullfile(realtimeDir,'pABRstim_saving.mat');
resultFile = fullfile(realtimeDir,'pABR_results.mat');
delete(fullfile(realtimeDir,'pABR_condition_*_level_*_epoch_*.mat'));
if exist(stimFile,'file'), delete(stimFile); end
if exist(stimSavingFile,'file'), delete(stimSavingFile); end
if exist(resultFile,'file'), delete(resultFile); end
recordingChannel = 1; %#ok<NASGU>
builtin('save',stimSavingFile,'pABRstim','pABRlevels','conditionChannels',...
    'conditionLabels','recordingChannel');
movefile(stimSavingFile,stimFile,'f');

for conditionIND=1:nConditions
    Stimuli.channel = conditionChannels(conditionIND,1);
    Stimuli.channel2 = conditionChannels(conditionIND,2);
    conditionLabel = conditionLabels{conditionIND};

    % The normal FFRwav2 right/left callbacks call calibInit whenever the
    % routing changes. Reproduce that behavior here so an output that was
    % previously assigned "allstop" is enabled for the new BIC condition.
    PAset([120;120;120;120]);

    if strcmp(NelData.Metadata.calib_type,'SPL')
        inverseFilterName = 'inversefilt';
    elseif strcmp(NelData.Metadata.calib_type,'FPL')
        inverseFilterName = 'inversefilt_FPL';
    else
        error('Unknown calibration type: %s.',NelData.Metadata.calib_type);
    end

    if Stimuli.channel==1 && Stimuli.channel2==1
        % Monaural right: left output stopped, right output enabled.
        filttype = {'allstop',inverseFilterName};
    elseif Stimuli.channel==2 && Stimuli.channel2==2
        % Monaural left: left output enabled, right output stopped.
        filttype = {inverseFilterName,'allstop'};
    else
        % Binaural: enable both calibrated outputs.
        filttype = {inverseFilterName,inverseFilterName};
    end

    invfiltdata = set_invFilter(filttype,Stimuli.calibPicNum);

    for attenIND=1:nLevels
        attenLevel = pABRlevels(attenIND);
        atten = pABRlevelAtten(attenIND);
        rejections = 0;
        set(FIG.statText.status,'String',sprintf('STATUS: %s | %.1f dB',...
            conditionLabel,attenLevel));
        drawnow;

        invoke(RP1,'ClearCOF');
        invoke(RP1,'LoadCOF',stimRCXfName);
        invoke(RP1,'Run');
        invoke(RP1,'SetTagVal','StmOn',pABRstim.Gating.pABRDur_ms);
        invoke(RP1,'SetTagVal','StmOff',...
            pABRstim.Gating.Period_ms-pABRstim.Gating.pABRDur_ms);
        invoke(RP1,'SetTagVal','RiseFall',pABRstim.Gating.rftime_ms);

        nextStim = 1;
        tmpR = invoke(RP1,'WriteTagV','STIM_R',0,double(pABR_Rstim(nextStim,:)));
        tmpL = invoke(RP1,'WriteTagV','STIM_L',0,double(pABR_Lstim(nextStim,:)));
        if tmpR~=1 || tmpL~=1, error('First pABR stimulus failed to load.'); end
        nextStim = nextStim+1;

        % Use the original routing function already proven by RunLevels.
        pABR_set_attns(atten,Stimuli.channel,...
            atten,Stimuli.channel2,...
            Stimuli.KHosc,RP1,RP2);
        invoke(RP1,'SoftTrg',1);
        positiveAccepted = false;
        pABR_PO_CumRes1 = [];

        for currStim=1:totalPresentations
            if mod(currStim,2)==1, positiveAccepted=false; end
            loadedThisOffTime = false;
            pairReadyToSave = false;
            savedStimIdx = nextStim-1;
            if savedStimIdx<1, savedStimIdx=listlength; end
            pABRinterstim{conditionIND,attenIND,currStim} = savedStimIdx;
            set(FIG.statText.status,'String',sprintf(...
                'STATUS: %s | %.1f dB [%d | %d | %d]',conditionLabel,...
                attenLevel,currStim,rejections,totalPresentations));
            drawnow;

            if strcmp(get(FIG.push.run_levels,'Userdata'),'abort')
                bAbort=true; break;
            end
            if strcmp(get(FIG.push.forget_now,'Userdata'),'save') && ~mod(currStim,2)
                saveNow=true; break;
            end
            while invoke(RP1,'GetTagVal','Stage')==1
                drawnow limitrate;
            end

            dataReadThisOff = false;
            while invoke(RP1,'GetTagVal','Stage')==2
                if ~dataReadThisOff && invoke(RP3,'GetTagVal','BufFlag')==1
                    pABRdata1 = invoke(RP3,'ReadTagV','ADbuf',0,pABRnpts);
                    if ~isempty(pABRdata1) && numel(pABRdata1)==pABRnpts
                        dataReadThisOff = true;
                        artifactFree = max(abs(pABRdata1))<=critVal;
                        polarityCorrect = invoke(RP1,'GetTagVal','ORG')==mod(currStim,2);
                        if polarityCorrect && artifactFree
                            if mod(currStim,2)==1
                                pABR_PO_CumRes1 = pABRdata1;
                                positiveAccepted = true;
                            elseif positiveAccepted
                                pABR_NP_CumRes1 = pABRdata1;
                                epochData.currentStimIdx = ...
                                    pABRinterstim{conditionIND,attenIND,currStim};
                                epochData.conditionIND = conditionIND;
                                epochData.conditionLabel = conditionLabel;
                                epochData.stimulusChannel1 = Stimuli.channel;
                                epochData.stimulusChannel2 = Stimuli.channel2;
                                epochData.recordingChannel = 1;
                                epochData.attenIND = attenIND;
                                epochData.attenLevel = attenLevel;
                                epochData.pABR_CumRes1 = ...
                                    (pABR_PO_CumRes1+pABR_NP_CumRes1)/2;
                                pairReadyToSave = true;
                            end
                            pABR_EpochResp1{conditionIND,attenIND,currStim}=pABRdata1;
                        elseif ~artifactFree
                            rejections=rejections+1;
                        end
                        invoke(RP3,'SoftTrg',2);
                    end
                end

                if pABR_flag && ~loadedThisOffTime && mod(currStim,2)==0
                    tmpR=invoke(RP1,'WriteTagV','STIM_R',0,double(pABR_Rstim(nextStim,:)));
                    tmpL=invoke(RP1,'WriteTagV','STIM_L',0,double(pABR_Lstim(nextStim,:)));
                    if tmpR==1 && tmpL==1
                        loadedThisOffTime=true;
                        nextStim=nextStim+1;
                        if nextStim>listlength, nextStim=1; end
                    end
                end
            end

            if pairReadyToSave
                pairSavingFile=fullfile(realtimeDir,sprintf(...
                    'pABR_condition_%02d_level_%03d_epoch_%04d_saving.mat',...
                    conditionIND,attenIND,currStim/2));
                pairFile=fullfile(realtimeDir,sprintf(...
                    'pABR_condition_%02d_level_%03d_epoch_%04d.mat',...
                    conditionIND,attenIND,currStim/2));
                builtin('save',pairSavingFile,'-struct','epochData');
                movefile(pairSavingFile,pairFile,'f');
                savedPairCount(conditionIND,attenIND)=...
                    savedPairCount(conditionIND,attenIND)+1;
            end
        end
        RunLevels_params.nPairs_actual_BIC(conditionIND,attenIND)=...
            savedPairCount(conditionIND,attenIND);
        if bAbort || saveNow, break; end
    end
    % Reproduce the full end-of-run reset used by pABR_RunLevels before
    % switching automatically to the next BIC condition.
    AEP_set_attns2(120,Stimuli.channel, ...
        120,Stimuli.channel2, ...
        Stimuli.KHosc,RP1,RP2);

    PAset([120;120;120;120]);
    invoke(RP1,'Halt');
    invoke(RP1,'ClearCOF');
    pause(0.2);

    if bAbort || saveNow, break; end
end

if ~bAbort
    if sum(savedPairCount(:))==0, error('No accepted BIC pairs were saved.'); end
    set(FIG.statText.status,'String','STATUS: waiting for BIC processing...');
    while true
        epochFiles=dir(fullfile(realtimeDir,'pABR_condition_*_level_*_epoch_*.mat'));
        epochNames=string({epochFiles.name});
        epochNames=epochNames(~contains(epochNames,'_saving'));
        if isempty(epochNames), break; end
        pause(0.05); drawnow;
    end
    resultReady=false;
    while ~resultReady
        if exist(resultFile,'file')
            try
                resultData=load(resultFile,'BICResp','processedPairs');
                resultReady=isequal(size(resultData.processedPairs),size(savedPairCount)) && ...
                    all(resultData.processedPairs(:)>=savedPairCount(:));
            catch
                resultReady=false;
            end
        end
        if ~resultReady, pause(0.05); drawnow; end
    end
    BICResp=resultData.BICResp;
    beep;
    PAset([120;120;120;120]);
    set(FIG.statText.status,'String','STATUS: saving complete BIC data...');
    NelData=make_pABR_BIC_text_file(misc,Stimuli,invfiltdata,PROG,NelData,...
        'No comment.',RunLevels_params,FFR_Gating,BICResp,Display,...
        pABRattens,pABRinterstim,pABR_EpochResp1,pABRstim,...
        conditionChannels,conditionLabels);
    current_data_file('FFR',1);
    uiresume;
end

set(FIG.statText.status,'String',['STATUS (' interface_type '): free running...']);
PAset([120;120;120;120]);
set(FIG.push.run_levels,'String','Run levels...','Userdata','');
set(FIG.push.forget_now,'String','Forget NOW','Userdata','');
set(FIG.push.close,'Enable','on');
firstSTIM=1;
for ii=1:5
    set(FIG.ax.line(ii),'XData',[],'YData',[]);
    set(FIG.ax.line(ii+5),'XData',[],'YData',[]);
end
set(FIG.ax.line2(1),'YData',[]);
drawnow;
misc.n=double(~invoke(RP1,'GetTagVal','ORG'));
end
