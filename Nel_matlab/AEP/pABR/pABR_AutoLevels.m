function [firstSTIM, NelData]=pABR_AutoLevels(FIG,Stimuli,invfiltdata, RunLevels_params, misc, FFR_Gating,...
     pABRnpts,interface_type, Display, NelData, data_dir, RP1, RP2, RP3, PROG, prog_dir,pABRstim)

pABR_flag = 1;
RunLevels_params.demean = true;
% File: FFR_SNRenv_RunLevels
% M. Heinz 18Nov2003
% Modified for pABR Stage-2 loading logic

critVal  = Stimuli.threshV;  %for artigact rejection KHZZ 2011 Nov 4
critVal2 = Stimuli.threshV2;

% Recording-channel selection (JL 19Aug2026)
% Stimuli.channel = 1: right response only (ADbuf)
% Stimuli.channel = 2: left response only  (ADbuf2)
% Stimuli.channel = 3: both responses
if ~ismember(Stimuli.channel,[1 2 3])
    error('Stimuli.channel must be 1 (right), 2 (left), or 3 (both).');
end
recordRight = Stimuli.channel == 1 || Stimuli.channel == 3;
recordLeft  = Stimuli.channel == 2 || Stimuli.channel == 3;

%adding pABR flag (JL 2026)
stimRCXfName = [prog_dir '\object\pABRwav2_polIN.rcx'];

set(FIG.push.run_levels,'string','Abort');
set(FIG.push.forget_now,'string','Save NOW');
bAbort = 0;
save = 0;

% Clear out all plots
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

pABRlevels = 0:10:80;
pABRlevelAtten = zeros(1,length(pABRlevels));
for i=1:numel(pABRlevels)
    pABRlevelAtten(:,i) = pABRstim.maxSPL - pABRlevels(i);
end
    
nLevels = numel(pABRlevels);

%%
%updated by SP on 22Jul19: before it was saving the weighted average for
%plotting in the data-file. it should be saving the unweighted average in
%the final data-file
% ----
% updated by JMR to save second channel
% chan 1

% chan 1
pABR_PO_CumRes1 = cell(1,nLevels);
pABR_PO_CumRes2 = cell(1,nLevels);

pABR_NP_CumRes1 = cell(1,nLevels);
pABR_NP_CumRes2 = cell(1,nLevels);

%loading pABR stimuli JL 08jun26
pABR_Lstim=pABRstim.leftEpochs;
pABR_Rstim=pABRstim.rightEpochs;
listlength = size(pABR_Rstim,1);

nPresentations = 1;
totalPresentations = 2*listlength*nPresentations;
pABRattens = num2cell(pABRlevels);
pABRinterstim = cell(nLevels,totalPresentations);
pABR_EpochResp1 = cell(nLevels,totalPresentations);
pABR_EpochResp2 = cell(nLevels,totalPresentations);

%pABRnpts = floor(pABRstim.Gating.pABRDur_ms/1000 * pABRstim.RPsamprate_Hz);
pABRnpts = size(pABR_Rstim,2);
%padSamples = round((pABRstim.pad_ms/1000) * ...
% pABRstim.RPsamprate_Hz);
%padSamples = pABRstim.padSamples;

%responseLength = 2 * padSamples;

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

recordingCondition = Stimuli.channel; %#ok<NASGU>

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

%% Main loop
% Looping through all attenuation levels
for attenIND = 1:nLevels
    attenLevel = pABRlevels(attenIND);
    atten = pABRlevelAtten(attenIND);
    rejections = 0;   %for artifact rejection KHZZ 2011 Nov 4
    pABRattens{attenIND} = attenLevel;

    set(FIG.statText.status, 'String', sprintf('STATUS: averaging at -%.1f dB...', attenLevel));

    % load stimulus before first pulse train since it starts with the rising edge, no off time. JL 2026 Jun 8

    invoke(RP1,'ClearCOF');
    invoke(RP1,'LoadCOF', stimRCXfName);
    invoke(RP1,'Run');

    invoke(RP1, 'SetTagVal', 'StmOn',  pABRstim.Gating.pABRDur_ms);
    invoke(RP1, 'SetTagVal', 'StmOff',  pABRstim.Gating.Period_ms - pABRstim.Gating.pABRDur_ms);
    invoke(RP1, 'SetTagVal', 'RiseFall', pABRstim.Gating.rftime_ms);

    nextStim = 1;

    xpR = double(pABR_Rstim(nextStim,:));
    xpL = double(pABR_Lstim(nextStim,:));

    tmpR = invoke(RP1,'WriteTagV','STIM_R',0,xpR); %writing directly to buffer JL 09June2026
    tmpL = invoke(RP1,'WriteTagV','STIM_L',0,xpL);

    if tmpR ~= 1 || tmpL ~= 1            %check if writing stimulus to buffer succeeded. JL 2026 Jun 8
        error('First pABR stimulus failed to load');
    end

    nextStim = nextStim + 1;

    pABR_set_attns(atten,Stimuli.channel, ...
        atten,Stimuli.channel2, ...
        Stimuli.KHosc,RP1,RP2);

    % Start the pulse train once. JL 2026 Jun 8
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

        %setup to monitor run and off times JL 07Jul2026
        %load new stimulus during the off time at the end of +- pol
        % Stage 1 = ON/play time. Wait until it ends.

        while invoke(RP1,'GetTagVal','Stage') == 1
            %do nothing
        end

        % Stage 2 = OFF time. JL 07Jul2026
        % During this window:
        %   1. Keep checking for acquired data.
        %   2. Load the next pABR stimulus only once, after + - polarity completes.
        dataReadThisOff = false;

        while invoke(RP1,'GetTagVal','Stage') == 2

            %pABR_set_attns2(120,Stimuli.channel,Stimuli.atten2_dB,120,Stimuli.KHosc,RP1,RP2)

            if ~dataReadThisOff && invoke(RP3,'GetTagVal','BufFlag') == 1
                % Read only the response channel(s) used by this condition.
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
                    pABRdata2 = invoke(RP3,'ReadTagV','ADbuf2',0,pABRnpts);
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

                %read response once per STIM presentation

                if dataValid

                    dataReadThisOff = true;

                    % fixing the function to make sure the polarity matches, starts with 1,
                    % which must match with 1 for original
                    fprintf('stim=%d ORG=%d expected=%d max1=%g/%g max2=%g/%g\n', ...
                        currStim, invoke(RP1,'GetTagVal','ORG'), mod(currStim,2), ...
                        maxpABRobs1, critVal, maxpABRobs2, critVal2);

                    if invoke(RP1,'GetTagVal','ORG') == mod(currStim,2) && artifactFree

                        if currStim > 0 %might not be necessary since we start looping from 1
                            if mod(currStim,2) % odd stim presentation
                                fprintf('ODD accepted: currStim = %d\n',currStim);

                                % Positive polarity cummulative frequency response
                                if recordRight
                                    pABR_PO_CumRes1{attenIND} = pABRdata1;
                                end
                                if recordLeft
                                    pABR_PO_CumRes2{attenIND} = pABRdata2;
                                end
                                positiveAccepted = true;

                            else
                                % Negative polarity cummulative frequency response
                                fprintf('EVEN accepted: currStim = %d\n',currStim);

                                if positiveAccepted
                                    if recordRight
                                        pABR_NP_CumRes1{attenIND} = pABRdata1;
                                    end
                                    if recordLeft
                                        pABR_NP_CumRes2{attenIND} = pABRdata2;
                                    end

                                    epochData.currentStimIdx = pABRinterstim{attenIND,currStim};
                                    epochData.attenIND = attenIND;
                                    epochData.attenLevel = attenLevel;
                                    epochData.recordingCondition = Stimuli.channel;
                                    epochData.recordRight = recordRight;
                                    epochData.recordLeft = recordLeft;

                                    % Keep both fields for a stable file format,
                                    % but leave the inactive response empty.
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
                    end %End for artifact rejection KH 2011 June 08

                    invoke(RP3,'SoftTrg',2);
                end
            end

            % pABR: load next stimulus once during OFF time, after + and - are done.
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

    if bAbort == 1 || save == 1  % not sure if the right place to abort/save
        break;
    end
end

if bAbort == 0
    if sum(savedPairCount) == 0
        error('No accepted pABR pairs were saved.');
    end

    set(FIG.statText.status, ...
        'String', ...
        'STATUS: waiting for pABR processing...');

    while true
        epochFiles = dir(fullfile(realtimeDir,'pABR_level_*_epoch_*.mat'));
        epochNames = string({epochFiles.name});
        epochNames = epochNames(~contains(epochNames,'_saving'));

        if isempty(epochNames)
            break;
        end

        pause(0.05);
        drawnow;
    end

    while ~exist(resultFile,'file')
        pause(0.05);
        drawnow;
    end

    resultData = load(resultFile);

    rightResp = [];
    leftResp = [];
    if recordRight
        if ~isfield(resultData,'rightResp')
            error('The processing result does not contain rightResp.');
        end
        rightResp = resultData.rightResp;
    end
    if recordLeft
        if ~isfield(resultData,'leftResp')
            error('The processing result does not contain leftResp.');
        end
        leftResp = resultData.leftResp;
    end
end

%% SAVE FILE
if bAbort == 0
    beep;
    ButtonName = 'Yes';

    switch ButtonName
        case 'Yes'
            comment = 'No comment.';
        case 'Comment'
            comment = add_comment_line; %add a comment line before saving data file
    end

    if ~strcmp(ButtonName,'No')
        AEP_set_attns2(120,Stimuli.channel,120,Stimuli.channel2,Stimuli.KHosc,RP1,RP2);
        PAset([120;120;120;120]);
        set(FIG.statText.status, 'String', 'STATUS: saving data...');
        % chan 1
        NelData = make_FFRwav_text_file(misc, Stimuli, invfiltdata, PROG, NelData, comment, ...
            RunLevels_params, FFR_Gating, rightResp, leftResp, ...
            Display, pABRattens, pABRinterstim, pABR_EpochResp1, pABR_EpochResp2,pABRstim);

        current_data_file('FFR',1);
        uiresume; % Allow Nel's main window to update the Title'
        %% From NEL: "update_nel_title"
        if strncmp(data_dir,NelData.File_Manager.dirname,length(data_dir))
            display_dir = strrep(NelData.File_Manager.dirname(length(data_dir)+1:end),'\','');
        else
            display_dir = NelData.File_Manager.dirname;
        end

        set(NelData.General.main_handle,'Name', ...
            ['Running pABR ...  -  ''' display_dir '''   (' int2str(NelData.File_Manager.picture) ' Saved Pictures)']);
    end
end

%% Reset to "free running..." mode:
set(FIG.statText.status, 'String', ['STATUS (' interface_type '): free running...']);

AEP_set_attns2(120,Stimuli.channel,120,Stimuli.channel2,Stimuli.KHosc,RP1,RP2);

set(FIG.push.run_levels,'string','Run levels...');
set(FIG.push.run_levels,'Userdata','');
set(FIG.push.forget_now,'string','Forget NOW');
set(FIG.push.forget_now,'Userdata','');
set(FIG.push.close,'Enable','on');

firstSTIM = 1; % Reset Running Avgs: MH 18Nov2003

% clear plots
for ii=1:5
    set(FIG.ax.line(ii),...
        'xdata',[],...
        'ydata',[]);

    set(FIG.ax.line(ii+5),...
        'xdata',[],...
        'ydata',[]);
end

% change the legends back
%set(FIG.ax.line(1),'DisplayName', 'Ch 1 Neg');
%set(FIG.ax.line(2),'DisplayName', 'Ch 1 Pos');
%set(FIG.ax.line(3),'DisplayName', 'Ch 2 Neg');
%set(FIG.ax.line(4),'DisplayName', 'Ch 2 Pos');
% clear threshold/AR
set(FIG.ax.line2(1),'ydata',[]);
set(FIG.ax.line2(2),'ydata',[]);

drawnow;
misc.n = double(~(invoke(RP1,'GetTagVal','ORG')));
end
