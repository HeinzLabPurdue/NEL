function [firstSTIM, NelData]=FFRwav2_RunLevels_pABR(FIG,Stimuli,invfiltdata, RunLevels_params, misc, FFR_Gating,...
    FFRnpts,interface_type, Display, NelData, data_dir, RP1, RP2, RP3, PROG, prog_dir,pABRstim)

pABR_flag = 1;

% File: FFR_SNRenv_RunLevels
% M. Heinz 18Nov2003
% Modified for pABR Stage-2 loading logic

critVal  = Stimuli.threshV;  %for artigact rejection KHZZ 2011 Nov 4
critVal2 = Stimuli.threshV2;
%adding demean flag (JMR 2021)
demean_flag = 1;

%adding pABR flag (JL 2026)
if pABR_flag
    stimRCXfName = [prog_dir '\object\pABRwav2_polIN.rcx'];
else
    stimRCXfName = [prog_dir '\object\FFRwav2_polIN.rcx'];
end

set(FIG.push.run_levels,'string','Abort');
set(FIG.push.forget_now,'string','Save NOW');
bAbort = 0;
save = 0;

% Clear out all plots
set(FIG.ax.line(1),'xdata',[],'ydata',[], 'DisplayName', 'Ch 1 ENV');
set(FIG.ax.line(2),'xdata',[],'ydata',[], 'DisplayName', 'Ch 1 TFS');
set(FIG.ax.line(3),'xdata',[],'ydata',[], 'DisplayName', 'Ch 2 ENV');
set(FIG.ax.line(4),'xdata',[],'ydata',[], 'DisplayName', 'Ch 2 TFS');

if Stimuli.rec_channel > 2
    set(FIG.ax.line2(1),'ydata',[]);
    set(FIG.ax.line2(3),'ydata',[]);
elseif Stimuli.rec_channel == 2
    set(FIG.ax.line2(3),'ydata',[]);
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

% Averages / storage
FFRdataAvg_PO_plot1 = cell(size(RunLevels_params.attenMask));  % Average data polarized   $zz 04nov11
FFRdataAvg_NP_plot1 = cell(size(RunLevels_params.attenMask));  % Average data  not polarized   $zz 04nov11
FFRdataAvg_PO_save1 = cell(size(RunLevels_params.attenMask));
FFRdataAvg_NP_save1 = cell(size(RunLevels_params.attenMask));
% chan 1
FFRdataAvg_PO_plot2 = cell(size(RunLevels_params.attenMask));  % Average data polarized   $zz 04nov11
FFRdataAvg_NP_plot2 = cell(size(RunLevels_params.attenMask));  % Average data  not polarized   $zz 04nov11
FFRdataAvg_PO_save2 = cell(size(RunLevels_params.attenMask));
FFRdataAvg_NP_save2 = cell(size(RunLevels_params.attenMask));

if pABR_flag             %loading pABR stimuli JL 08jun26
    % For pABR, one matrix row is one actual stimulus.
    %frequencies = [500 1000 2000 4000 8000];
    %[pABR_Lstim, pABR_Rstim, ~, ~] = ... %#ok<NASGU>
        %make_toneburst_epochs(frequencies, round(Stimuli.RPsamprate_Hz), 30, 40);
         
     %[pABR_Lstim, pABR_Rstim, ~, ~] = ... %#ok<NASGU>
      %make_toneburst_epochs_singlefreq(frequencies, round(Stimuli.RPsamprate_Hz), 10, 40);
    pABR_Lstim=pABRstim.leftEpochs;
    pABR_Rstim=pABRstim.rightEpochs;
    listlength = size(pABR_Rstim,1);
else
    listlength = length(Stimuli.filename_inter);
end
%% not storing all repetitions zz 04nov11
FFRdataReps_outer1 = cell(size(RunLevels_params.attenMask)); % All reps
FFRdataReps_outer2 = cell(size(RunLevels_params.attenMask)); % chan 2
FFRattens = cell(size(RunLevels_params.attenMask));
FFRinterstim = cell(RunLevels_params.nPairs*listlength,1);

%% Main loop
% Not looping through attens for SFR. Assuming single attenuation
for attenIND = 1
    attenLevel = pABRstim.atten_dB;
    rejections = 0;   %for artifact rejection KHZZ 2011 Nov 4
    FFRattens{attenIND} = attenLevel;

    set(FIG.statText.status, 'String', sprintf('STATUS: averaging at -%.1f dB...', attenLevel));

    FFRdataAvg_PO_plot1{attenIND} = zeros(1, FFRnpts); % chan1
    FFRdataAvg_NP_plot1{attenIND} = zeros(1, FFRnpts);
    FFRdataAvg_PO_plot2{attenIND} = zeros(1, FFRnpts); % chan2
    FFRdataAvg_NP_plot2{attenIND} = zeros(1, FFRnpts);

    

    FFRdataReps1 = cell(1, 2*RunLevels_params.nPairs*listlength);
    FFRdataReps2 = cell(1, 2*RunLevels_params.nPairs*listlength);

    

    % load stimulus before first pulse train since it starts with the rising edge, no off time. JL 2026 Jun 8
    if pABR_flag
        invoke(RP1,'ClearCOF');
        invoke(RP1,'LoadCOF', stimRCXfName);
        invoke(RP1,'Run');

        invoke(RP1, 'SetTagVal', 'StmOn',   FFR_Gating.duration_ms);
        invoke(RP1, 'SetTagVal', 'StmOff',  FFR_Gating.period_ms - FFR_Gating.duration_ms);
        invoke(RP1, 'SetTagVal', 'RiseFall', FFR_Gating.rftime_ms);

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
    end

    totalPresentations = 2*RunLevels_params.nPairs*listlength;

    for currStim = 1:totalPresentations

        loadedThisOffTime = false;

    

        if currStim
            set(FIG.statText.status, 'String', sprintf('STATUS: averaging at -%.1f dB [%d | %d | %d]...', ...
                attenLevel, currStim, rejections, totalPresentations));
            
             FFRinterstim{currStim} = max(nextStim-1,1);
            
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

        %setup to monitor run and off times
        %load new stimulus during the off time given it is an even presentation
        % Stage 1 = ON/play time. Wait until it ends.
       
        while invoke(RP1,'GetTagVal','Stage') == 1
        %do nothing
        end

        % Stage 2 = OFF time.
        % During this window:
        %   1. Keep checking for acquired data.
        %   2. Load the next pABR stimulus only once, after even presentations.
        dataReadThisOff = false;
        while invoke(RP1,'GetTagVal','Stage') == 2
            
          %pABR_set_attns2(120,Stimuli.channel,Stimuli.atten2_dB,120,Stimuli.KHosc,RP1,RP2)

            if ~dataReadThisOff && invoke(RP3,'GetTagVal','BufFlag') == 1 
                FFRdata1 = invoke(RP3,'ReadTagV','ADbuf',0,FFRnpts);
                FFRdata2 = invoke(RP3,'ReadTagV','ADbuf2',0,FFRnpts);
                maxFFRobs1 = max(abs(FFRdata1));  %Artifact rejection KHZZ 2011 Nov 4
                maxFFRobs2 = max(abs(FFRdata2));
                
                %read response once per STIM presentation
                
                if ~isempty(FFRdata1) && ~isempty(FFRdata1) && length(FFRdata1)==FFRnpts ...
                        && length(FFRdata2)==FFRnpts
                    dataReadThisOff = true;

                % fixing the function to make sure the polarity matches, starts with 1,
                % which must match with 1 for original
                    if invoke(RP1,'GetTagVal','ORG') == mod(currStim,2) && ...
                            maxFFRobs1 <= critVal && maxFFRobs2 <= critVal2

                        weight = 1/ceil(currStim/2);

                        if currStim > 0 %might not be necessary since we start looping from 1
                            if mod(currStim,2) % odd stim presentation
                                % Positive polarity average
                                FFRdataAvg_PO_plot1{attenIND} = FFRdataAvg_PO_plot1{attenIND}*(1-weight) + weight*FFRdata1;
                                FFRdataAvg_PO_plot2{attenIND} = FFRdataAvg_PO_plot2{attenIND}*(1-weight) + weight*FFRdata2;
                                % adding demean option (JMR 2021)
                                if demean_flag
                                    FFRdataAvg_PO_plot1{attenIND} = FFRdataAvg_PO_plot1{attenIND} - mean(FFRdataAvg_PO_plot1{attenIND});
                                    FFRdataAvg_PO_plot2{attenIND} = FFRdataAvg_PO_plot2{attenIND} - mean(FFRdataAvg_PO_plot2{attenIND});
                                end
                            else
                                % Negative polarity average
                                FFRdataAvg_NP_plot1{attenIND} = FFRdataAvg_NP_plot1{attenIND}*(1-weight) + weight*FFRdata1;
                                FFRdataAvg_NP_plot2{attenIND} = FFRdataAvg_NP_plot2{attenIND}*(1-weight) + weight*FFRdata2;

                                if demean_flag
                                    FFRdataAvg_NP_plot1{attenIND} = FFRdataAvg_NP_plot1{attenIND} - mean(FFRdataAvg_NP_plot1{attenIND});
                                    FFRdataAvg_NP_plot2{attenIND} = FFRdataAvg_NP_plot2{attenIND} - mean(FFRdataAvg_NP_plot2{attenIND});
                                end
                            end
                        end

                        if currStim
                            FFRdataReps1{currStim} = FFRdata1;  %added DA 7/23/13
                            FFRdataReps2{currStim} = FFRdata2;
                        end

                    elseif maxFFRobs1 > critVal || maxFFRobs2 > critVal2
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
                %pABR_set_attns2(Stimuli.atten_dB,Stimuli.channel,Stimuli.atten2_dB,Stimuli.channel2,Stimuli.KHosc,RP1,RP2)
                
                
            end
            %pABR_set_attns2(Stimuli.atten_dB,Stimuli.channel,Stimuli.atten2_dB,Stimuli.channel2,Stimuli.KHosc,RP1,RP2)
        end
        
        if ~dataReadThisOff
            sprintf('currStim %d: Data not read during stage2', currStim);
        end
        if ~loadedThisOffTime && mod(currStim,2)==0
            sprintf('currStim %d: Next Stim not loaded during stage2', currStim);
        end
        


        if currStim > 0
            % XData and YData need to be the same Length
            data_x = 0:(1/Stimuli.RPsamprate_Hz):FFR_Gating.FFRlength_ms/1000;
            newlen = min([length(data_x), length(FFRdataAvg_PO_plot1{attenIND}), ...
                length(FFRdataAvg_NP_plot1{attenIND}), length(FFRdataAvg_PO_plot2{attenIND}), ...
                length(FFRdataAvg_NP_plot2{attenIND})]);
            data_x = data_x(1:newlen);

            data_NP1 = FFRdataAvg_NP_plot1{attenIND}(1:newlen);
            data_PO1 = FFRdataAvg_PO_plot1{attenIND}(1:newlen);
            data_NP2 = FFRdataAvg_NP_plot2{attenIND}(1:newlen);
            data_PO2 = FFRdataAvg_PO_plot2{attenIND}(1:newlen);

            if Stimuli.rec_channel > 2
                set(FIG.ax.line(1),'xdata',data_x, 'ydata',(data_NP1+data_PO1)*Display.PlotFactor/2);
                set(FIG.ax.line(3),'xdata',data_x, 'ydata',(data_NP2+data_PO2)*Display.PlotFactor/2');
                set(FIG.ax.line(2),'xdata',data_x, 'ydata',(data_NP1-data_PO1)*Display.PlotFactor/2);
                set(FIG.ax.line(4),'xdata',data_x, 'ydata',(data_NP2-data_PO2)*Display.PlotFactor/2);
                set(FIG.ax.line2(1),'ydata',maxFFRobs1);
                set(FIG.ax.line2(3),'ydata',maxFFRobs2);
            elseif Stimuli.rec_channel == 2 % Ch2 only
                set(FIG.ax.line(3),'xdata',data_x, 'ydata',(data_NP2+data_PO2)*Display.PlotFactor/2);
                set(FIG.ax.line(4),'xdata',data_x, 'ydata',(data_NP2-data_PO2)*Display.PlotFactor/2);
                set(FIG.ax.line2(3),'ydata',maxFFRobs2);
            else %Ch1 only
                set(FIG.ax.line(1),'xdata',data_x, 'ydata',(data_NP1+data_PO1)*Display.PlotFactor/2);
                set(FIG.ax.line(2),'xdata',data_x, 'ydata',(data_NP1-data_PO1)*Display.PlotFactor/2);
                set(FIG.ax.line2(1),'ydata',maxFFRobs1);
            end
            drawnow;
        end
    end

    % Save averages
    FFRdataAvg_PO_save1{attenIND} = nanmean(cell2mat(FFRdataReps1(1:2:end)'), 1);
    FFRdataAvg_NP_save1{attenIND} = nanmean(cell2mat(FFRdataReps1(2:2:end)'), 1);
    FFRdataAvg_PO_save2{attenIND} = nanmean(cell2mat(FFRdataReps2(1:2:end)'), 1);
    FFRdataAvg_NP_save2{attenIND} = nanmean(cell2mat(FFRdataReps2(2:2:end)'), 1);
    FFRdataReps_outer1{attenIND} = FFRdataReps1;
    FFRdataReps_outer2{attenIND} = FFRdataReps2;

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
            RunLevels_params, FFR_Gating, FFRdataAvg_PO_plot1, FFRdataAvg_PO_plot2, ...
            FFRdataAvg_NP_plot1, FFRdataAvg_NP_plot2, ...
            FFRdataAvg_PO_save1, FFRdataAvg_PO_save2, ...
            FFRdataAvg_NP_save1, FFRdataAvg_NP_save2, ...
            Display, FFRattens, FFRinterstim, FFRdataReps1, FFRdataReps2, ...
            interface_type);

        current_data_file('FFR',1);
        uiresume; % Allow Nel's main window to update the Title'
        %% From NEL: "update_nel_title"
        if strncmp(data_dir,NelData.File_Manager.dirname,length(data_dir))
            display_dir = strrep(NelData.File_Manager.dirname(length(data_dir)+1:end),'\','');
        else
            display_dir = NelData.File_Manager.dirname;
        end
        set(NelData.General.main_handle,'Name', ...
            ['Running FFR ...  -  ''' display_dir '''   (' int2str(NelData.File_Manager.picture) ' Saved Pictures)']);
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
set(FIG.ax.line(1),'xdata',[],'ydata',[]);
set(FIG.ax.line(2),'xdata',[],'ydata',[]);
set(FIG.ax.line(3),'xdata',[],'ydata',[]);
set(FIG.ax.line(4),'xdata',[],'ydata',[]);

% change the legends back
set(FIG.ax.line(1),'DisplayName', 'Ch 1 Neg');
set(FIG.ax.line(2),'DisplayName', 'Ch 1 Pos');
set(FIG.ax.line(3),'DisplayName', 'Ch 2 Neg');
set(FIG.ax.line(4),'DisplayName', 'Ch 2 Pos');
% clear threshold/AR
set(FIG.ax.line2(1),'ydata',[]);
set(FIG.ax.line2(3),'ydata',[]);

drawnow;
misc.n = double(~(invoke(RP1,'GetTagVal','ORG')));
end
