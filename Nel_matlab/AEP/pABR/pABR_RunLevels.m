function [firstSTIM, NelData]=pABR_RunLevels(FIG,Stimuli,invfiltdata, RunLevels_params, misc, FFR_Gating,...
    FFRnpts,interface_type, Display, NelData, data_dir, RP1, RP2, RP3, PROG, prog_dir,pABRstim)

pABR_flag = 1;

% File: FFR_SNRenv_RunLevels
% M. Heinz 18Nov2003
% Modified for pABR Stage-2 loading logic

critVal  = Stimuli.threshV;  %for artigact rejection KHZZ 2011 Nov 4
critVal2 = Stimuli.threshV2;


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


if Stimuli.rec_channel > 2 %3 for two channels
    set(FIG.ax.line2(1),'ydata',[]);
    set(FIG.ax.line2(2),'ydata',[]);
elseif Stimuli.rec_channel == 2
    set(FIG.ax.line2(2),'ydata',[]);
else
    set(FIG.ax.line2(1),'ydata',[]);
end

drawnow;

if numel(RunLevels_params.attenMask) ~= 1
    warning('Length of RunLevels_params.attenMask should be one');
end

%%
%updated by SP on 22Jul19: before it was saving the weighted average for
%plotting in the data-file. it should be saving the unweighted average in
%the final data-file
% ----
% updated by JMR to save second channel
% chan 1

pABR_500Avg1 = cell(size(pABRstim.attenMask)); %#ok<*PREALL,*NASGU>
pABR_1000Avg1 = cell(size(pABRstim.attenMask));
pABR_2000Avg1 = cell(size(pABRstim.attenMask));
pABR_4000Avg1 = cell(size(pABRstim.attenMask));
pABR_8000Avg1 = cell(size(pABRstim.attenMask));

pABR_PO_CumRes1= cell(size(pABRstim.attenMask));
pABR_PO_CumRes2= cell(size(pABRstim.attenMask));

pABR_NP_CumRes1= cell(size(pABRstim.attenMask));
pABR_NP_CumRes2= cell(size(pABRstim.attenMask));

% chan 1

pABR_500Avg2 = cell(size(pABRstim.attenMask)); %#ok<*NASGU>
pABR_1000Avg2 = cell(size(pABRstim.attenMask));
pABR_2000Avg2 = cell(size(pABRstim.attenMask));
pABR_4000Avg2 = cell(size(pABRstim.attenMask));
pABR_8000Avg2 = cell(size(pABRstim.attenMask));



%loading pABR stimuli JL 08jun26
pABR_Lstim=pABRstim.leftEpochs;
pABR_Rstim=pABRstim.rightEpochs;
listlength = size(pABR_Rstim,1);


pABRattens = cell(size(RunLevels_params.attenMask));
pABRinterstim= cell(1,2*listlength);
pABR_EpochResp1 = cell(1,2*listlength);
pABR_EpochResp2 = cell(1,2*listlength);

pABRnpts = floor(pABRstim.Gating.pABRDur_ms/1000 * pABRstim.RPsamprate_Hz);


%% Main loop
% Not looping through attens for SFR. Assuming single attenuation
for attenIND = 1
    attenLevel = pABRstim.atten_dB;
    rejections = 0;   %for artifact rejection KHZZ 2011 Nov 4
    pABRattens{attenIND} = attenLevel;
    
    set(FIG.statText.status, 'String', sprintf('STATUS: averaging at -%.1f dB...', attenLevel));
    
    pABR_500Avg1{attenIND} = zeros(1,pABRnpts);                            %chan1
    pABR_1000Avg1{attenIND} = zeros(1,pABRnpts);
    pABR_2000Avg1{attenIND} = zeros(1,pABRnpts);
    pABR_4000Avg1{attenIND} = zeros(1,pABRnpts);
    pABR_8000Avg1{attenIND} = zeros(1,pABRnpts);
    
    pABR_PO_CumRes1{attenIND} = zeros(1,pABRnpts);
    pABR_PO_CumRes2{attenIND} = zeros(1,pABRnpts);
    pABR_NP_CumRes1{attenIND} = zeros(1,pABRnpts);
    pABR_NP_CumRes2{attenIND} = zeros(1,pABRnpts);
    
    
    
    pABR_500Avg2{attenIND} = zeros(1,pABRnpts);                            %chan2
    pABR_1000Avg2{attenIND} = zeros(1,pABRnpts);
    pABR_2000Avg2{attenIND} = zeros(1,pABRnpts);
    pABR_4000Avg2{attenIND} = zeros(1,pABRnpts);
    pABR_8000Avg2{attenIND} = zeros(1,pABRnpts);
    
    pABR_500CumNoise1 = 0;
    pABR_1000CumNoise1 = 0;
    pABR_2000CumNoise1 = 0;
    pABR_4000CumNoise1 = 0;
    pABR_8000CumNoise1 = 0;
    
    pABR_500CumNoise2 = 0;
    pABR_1000CumNoise2 = 0;
    pABR_2000CumNoise2 = 0;
    pABR_4000CumNoise2 = 0;
    pABR_8000CumNoise2 = 0;
    
    
    
    
    
    
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
    
    AEP_set_attns2( pABRstim.atten_dB,Stimuli.channel, pABRstim.atten2_dB,Stimuli.channel2,Stimuli.KHosc,RP1,RP2);
    % Start the pulse train once. JL 2026 Jun 8
    invoke(RP1,'SoftTrg',1);
    
    
    totalPresentations = 2*listlength;
    
    for currStim = 1:totalPresentations
        
        loadedThisOffTime = false;
        cumVar1 = 0;
        cumVar2 = 0;
        
        
        
        
        if currStim
            set(FIG.statText.status, 'String', sprintf('STATUS: averaging at -%.1f dB [%d | %d | %d]...', ...
                attenLevel, currStim, rejections, totalPresentations));
            
            pABRinterstim{currStim} = max(nextStim-1,1);
            
        end
        
        if (strcmp(get(FIG.push.forget_now, 'Userdata'), 'save') && ~mod(currStim,2))
            save = 1;
            RunLevels_params.nPairs_actual = currStim/2;
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
                pABRdata1 = invoke(RP3,'ReadTagV','ADbuf',0,pABRnpts);
                pABRdata2 = invoke(RP3,'ReadTagV','ADbuf2',0,pABRnpts);
                maxpABRobs1 = max(abs( pABRdata1));  %Artifact rejection KHZZ 2011 Nov 4
                maxpABRobs2 = max(abs(pABRdata2));
                
                %read response once per STIM presentation
                
                if ~isempty(pABRdata1) && ~isempty(pABRdata1) && length(pABRdata1)==pABRnpts ...
                        && length(pABRdata2)==pABRnpts
                    dataReadThisOff = true;
                    
                    % fixing the function to make sure the polarity matches, starts with 1,
                    % which must match with 1 for original
                    if invoke(RP1,'GetTagVal','ORG') == mod(currStim,2) && ...
                            maxpABRobs1 <= critVal && maxpABRobs2 <= critVal2
                        
                        if currStim > 0 %might not be necessary since we start looping from 1
                            if mod(currStim,2) % odd stim presentation
                                % Positive polarity cummulative frequency response
                                pABR_PO_CumRes1{attenIND} = pABRdata1;
                                pABR_PO_CumRes2{attenIND} = pABRdata2;
                                
                            else
                                % Negative polarity cummulative frequency response
                                pABR_NP_CumRes1{attenIND} = pABRdata1;
                                pABR_NP_CumRes2{attenIND} = pABRdata2;
                            end
                        end
                        
                        if currStim
                            pABR_EpochResp1{currStim} = pABRdata1;  %added DA 7/23/13 %changed to pABR JL 6/30/26
                            pABR_EpochResp2{currStim} = pABRdata2;
                        end
                        
                        if mod(currStim,2) == 0
                            pABR_CumRes1 = (pABR_PO_CumRes1{attenIND} + pABR_NP_CumRes1{attenIND})/2;
                            pABR_CumRes2 = (pABR_PO_CumRes2{attenIND} + pABR_NP_CumRes2{attenIND})/2;
                            [combFreq_1] = pABRCC( pABR_CumRes1,squeeze(pABRstim.stimTrain(nextStim,1,:)));
                            [combFreq_2] = pABRCC(pABR_CumRes2,squeeze(pABRstim.stimTrain(nextStim,2,:)));
                            
                            pABR_500CumNoise1 = combFreq_1(1).var;
                            pABR_1000CumNoise1 = combFreq_1(2).var;
                            pABR_2000CumNoise1 = combFreq_1(3).var;
                            pABR_4000CumNoise1 = combFreq_1(4).var;
                            pABR_8000CumNoise1 = combFreq_1(5).var;
                            
                            pABR_500CumNoise2 = combFreq_2(1).var;
                            pABR_1000CumNoise2 = combFreq_2(2).var;
                            pABR_2000CumNoise2 = combFreq_2(3).var;
                            pABR_4000CumNoise2 = combFreq_2(4).var;
                            pABR_8000CumNoise2 = combFreq_2(5).var;
                            
                            
                            
                            
                            %epoch weighted response for right ear
                            pABR_500Avg1{attenIND} = pABR_500Avg1{attenIND} + combFreq_1(1).response*(combFreq_1(1).var/pABR_500CumNoise1);                            %chan1
                            pABR_1000Avg1{attenIND} = pABR_1000Avg1{attenIND} + combFreq_1(2).response*(combFreq_1(2).var/pABR_1000CumNoise1);
                            pABR_2000Avg1{attenIND} = pABR_2000Avg1{attenIND} + combFreq_1(3).response*(combFreq_1(3).var/pABR_2000CumNoise1);
                            pABR_4000Avg1{attenIND} = pABR_4000Avg1{attenIND} + combFreq_1(4).response*(combFreq_1(4).var/pABR_4000CumNoise1);
                            pABR_8000Avg1{attenIND} = pABR_8000Avg1{attenIND} + combFreq_1(5).response*(combFreq_1(5).var/pABR_8000CumNoise1);
                            
                            %epoch weighted reponse for left ear
                            pABR_500Avg2{attenIND} = pABR_500Avg2{attenIND} + combFreq_2(1).response*(combFreq_2(1).var/pABR_500CumNoise2);                            %chan2
                            pABR_1000Avg2{attenIND} = pABR_1000Avg2{attenIND} + combFreq_2(2).response*(combFreq_2(2).var/pABR_1000CumNoise2);
                            pABR_2000Avg2{attenIND} = pABR_2000Avg2{attenIND} + combFreq_2(3).response*(combFreq_2(3).var/pABR_2000CumNoise2);
                            pABR_4000Avg2{attenIND} = pABR_4000Avg2{attenIND} + combFreq_2(4).response*(combFreq_2(4).var/pABR_4000CumNoise2);
                            pABR_8000Avg2{attenIND} = pABR_8000Avg2{attenIND} + combFreq_2(5).response*(combFreq_2(5).var/pABR_8000CumNoise2);
                            
                        end
                        
                        
                        
                        
                        
                    elseif maxpABRobs1 > critVal || maxpABRobs2 > critVal2
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
                
                if tmpR == 1 && tmpL == 1
                    loadedThisOffTime = true;
                    nextStim = nextStim + 1;
                    
                    if nextStim >  listlength
                        nextStim = 1;
                    end
                end
                
                
            end
        end
        
        if ~dataReadThisOff
            sprintf('currStim %d: Data not read during stage2', currStim);
        end
        if ~loadedThisOffTime && mod(currStim,2)==0
            sprintf('currStim %d: Next Stim not loaded during stage2', currStim);
        end
        
        rightResp = {
            pABR_500Avg1{attenIND}
            pABR_1000Avg1{attenIND}
            pABR_2000Avg1{attenIND}
            pABR_4000Avg1{attenIND}
            pABR_8000Avg1{attenIND}
            };
        
        leftResp = {
            pABR_500Avg2{attenIND}
            pABR_1000Avg2{attenIND}
            pABR_2000Avg2{attenIND}
            pABR_4000Avg2{attenIND}
            pABR_8000Avg2{attenIND}
            };
        
        rightY = [9.5 8.5 7.5 6.5 5.5];
        leftY  = [3.7 2.7 1.7 0.7 -0.3];
        
        
        if currStim > 0
            % XData and YData need to be the same Length
            datax = 0:(1/pABRstim.RPsamprate_Hz):(2*pABRstim.pad_ms)/1000;
            newlen = min([ ...
                length(datax),...
                length(rightResp{1}), length(rightResp{2}), length(rightResp{3}), ...
                length(rightResp{4}), length(rightResp{5}), ...
                length(leftResp{1}), length(leftResp{2}), length(leftResp{3}), ...
                length(leftResp{4}), length(leftResp{5})]);
            datax = datax(1:newlen);
            if Stimuli.rec_channel > 2
                for ff = 1:5
                    set(FIG.ax.line(ff), ...
                        'xdata',datax, ...
                        'ydata',rightResp{ff}(1:newlen)*Display.PlotFactor + rightY(ff));
                    
                    set(FIG.ax.line(ff+5), ...
                        'xdata',datax, ...
                        'ydata',leftResp{ff}(1:newlen)*Display.PlotFactor+ leftY(ff));
                end
            elseif Stimuli.rec_channel == 1
                for ff = 1:5
                    set(FIG.ax.line(ff), ...
                        'xdata',datax, ...
                        'ydata',rightResp{ff}(1:newlen)*Display.PlotFactor+ rightY(ff));
                    
                    set(FIG.ax.line(ff+5), ...
                        'xdata',[], ...
                        'ydata',[],'Visible', 'off');
                end
            elseif Stimuli.rec_channel == 2
                for ff = 1:5
                    set(FIG.ax.line(ff), ...
                        'xdata',[], ...
                        'ydata',[],'Visible', 'off');
                    
                    set(FIG.ax.line(ff+5), ...
                        'xdata',datax, ...
                        'ydata',leftResp{ff}(1:newlen)*Display.PlotFactor+ leftY(ff));
                end
            end
            
            set(FIG.ax.axis,'XLim',[0 max(datax)]);
            drawnow;
        end
    end
    
    
    
    if bAbort == 1 || save == 1  % not sure if the right place to abort/save
        break;
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
            Display, pABRattens, pABRinterstim, pABR_EpochResp1, pABR_EpochResp2);
        
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
