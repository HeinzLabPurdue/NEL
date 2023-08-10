%% Working

function [firstSTIM, NelData]=FFRwav_RunLevels(FIG,Stimuli,invfiltdata, RunLevels_params, misc, FFR_Gating,...
    FFRnpts,interface_type, Display, NelData, data_dir, RP1, RP3, PROG)

% RP1=RP.activeX;
% RP2=RP.activeX;

% File: FFR_SNRenv_RunLevels
% M. Heinz 18Nov2003
%
% Script for Taking FFR data (Run Levels), called at "case 10" within FFR_loop
%
% Modified zz 04nov2011
% warning off;
critVal=Stimuli.threshV;  %for artifact rejection KHZZ 2011 Nov 4
critVal2 = Stimuli.threshV2; 

% adding demean flag (JMR 2021)
demean_flag = 1;


%% RunLevels_params.nPairs = Stimuli.FFRmem_reps;
% Setup panel for acquire/write mode:
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


%%
if numel(RunLevels_params.attenMask)~=1
    warning('Length of RunLevels_params.attenMask should be one');
end

%%
% updated by SP on 22Jul19: before it was saving the weighted average for
% plotting in the data-file. it should be saving the unweighted average in
% the final data-file
% ----
% updated by JMR to save second channel
% chan 1
FFRdataAvg_PO_plot1=cell(size(RunLevels_params.attenMask));  % Average data polarized     %zz 04nov11
FFRdataAvg_NP_plot1=cell(size(RunLevels_params.attenMask));  % Average data not polarized %zz 04nov11
FFRdataAvg_PO_save1= cell(size(RunLevels_params.attenMask));
FFRdataAvg_NP_save1= cell(size(RunLevels_params.attenMask));

% chan 2
FFRdataAvg_PO_plot2=cell(size(RunLevels_params.attenMask));  % Average data polarized     %zz 04nov11
FFRdataAvg_NP_plot2=cell(size(RunLevels_params.attenMask));  % Average data not polarized %zz 04nov11
FFRdataAvg_PO_save2= cell(size(RunLevels_params.attenMask));
FFRdataAvg_NP_save2= cell(size(RunLevels_params.attenMask));

%% not storing all repetitions zz 04nov11
FFRdataReps_outer1 = cell(size(RunLevels_params.attenMask));  % All Reps
FFRdataReps_outer2 = cell(size(RunLevels_params.attenMask)); % chan 2
FFRattens=cell(size(RunLevels_params.attenMask));

%% Main Loop
% Not looping through attens for SFR. Assuming single attenutation.
for attenIND = 1
    attenLevel= Stimuli.atten_dB;
 
    rejections=0; %for artifact rejection KHZZ 2011 Nov 4
    
    FFRattens{attenIND}=attenLevel;
    
    set(FIG.statText.status, 'String', sprintf('STATUS: averaging at -%.1f dB...', attenLevel));
    
    FFRdataAvg_PO_plot1{attenIND} = zeros(1, FFRnpts); % chan 1
    FFRdataAvg_NP_plot1{attenIND} = zeros(1, FFRnpts);
    
    FFRdataAvg_PO_plot2{attenIND} = zeros(1, FFRnpts); % chan2
    FFRdataAvg_NP_plot2{attenIND} = zeros(1, FFRnpts);
    
    FFRdataReps1= cell(1, 2*RunLevels_params.nPairs); % SP on 22Jul19
    FFRdataReps2= cell(1, 2*RunLevels_params.nPairs); % SP on 22Jul19
    
    % 28Apr2004 M.Heinz: Setup to skip 1st pulse pair, which is sometimes from previous level condition
    % 7/22/19 if we want to skip first pair, should start at
    % for currStim= -1:2*RunLevels_params.nPairs and we should be checking
    % if currStim is >0 in if statements
    for currStim = 0:2*RunLevels_params.nPairs
        
        if currStim
            set(FIG.statText.status, 'String', sprintf('STATUS: averaging at -%.1f dB [%d | %d | %d]...', ...
                attenLevel, currStim, rejections, 2*RunLevels_params.nPairs)); % KHZZ 2011 Nov 4
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
        
        while bNoSampleObtained
            if invoke(RP3,'GetTagVal','BufFlag') == 1
                FFRdata1 = invoke(RP3,'ReadTagV','ADbuf',0,FFRnpts);
                FFRdata2 = invoke(RP3,'ReadTagV','ADbuf2',0,FFRnpts);
                maxFFRobs1 = max(abs(FFRdata1)); %Artifact rejection KHZZ 2011 Nov 4
                maxFFRobs2 = max(abs(FFRdata2));

                %drawnow;
                
                % fixing the function to make sure the polarity matches, starts with 1,
                % which must match with 1 for original
                
                if  invoke(RP1,'GetTagVal','ORG') == mod(currStim,2) && maxFFRobs1 <= critVal && maxFFRobs2<= critVal2
                    %                     if  invoke(RP1,'GetTagVal','ORG')
                    bNoSampleObtained = 0;
                    % Need to skip 1st pair, which is from last stimulus
                    
                    % if currStim>2 %Commented by SP on 7/22/19| not
                    % sure if this is happening anymore. Plus we have
                    % been saving all reps (including the first two reps)
                    weight = 1/ceil(currStim/2);
                    if currStim>0
                        if mod(currStim,2)
                            % Important: Before 7/22/19, all FFR data saved
                            % had POS and NEG polarity switched in the
                            % average
                            FFRdataAvg_PO_plot1{attenIND} = FFRdataAvg_PO_plot1{attenIND}*(1 - weight) + weight*FFRdata1;
                            FFRdataAvg_PO_plot2{attenIND} = FFRdataAvg_PO_plot2{attenIND}*(1 - weight) + weight*FFRdata2;
                            % adding demean option (JMR 2021)
                            if demean_flag
                                FFRdataAvg_PO_plot1{attenIND} = FFRdataAvg_PO_plot1{attenIND}-mean(FFRdataAvg_PO_plot1{attenIND});
                                FFRdataAvg_PO_plot2{attenIND} = FFRdataAvg_PO_plot2{attenIND}-mean(FFRdataAvg_PO_plot2{attenIND});
                            end

                        else
                            FFRdataAvg_NP_plot1{attenIND} = FFRdataAvg_NP_plot1{attenIND}*(1 - weight) + weight*FFRdata1;
                            FFRdataAvg_NP_plot2{attenIND} = FFRdataAvg_NP_plot2{attenIND}*(1 - weight) + weight*FFRdata2;
                            if demean_flag
                                FFRdataAvg_NP_plot1{attenIND} = FFRdataAvg_NP_plot1{attenIND}-mean(FFRdataAvg_NP_plot1{attenIND});
                                FFRdataAvg_NP_plot2{attenIND} = FFRdataAvg_NP_plot2{attenIND}-mean(FFRdataAvg_NP_plot2{attenIND});
                            end
                        end
                    end
                    
                    if currStim
                        FFRdataReps1{currStim}=FFRdata1; %added DA 7/23/13
                        FFRdataReps2{currStim}=FFRdata2;
                    end
                    
                elseif maxFFRobs1 > critVal || maxFFRobs2> critVal2
                    %             else
                    rejections=rejections+1;
                end %End for artifact rejection KH 2011 June 08
                
                invoke(RP3,'SoftTrg',2);
            end

        end

        if currStim > 0
            
            % XData and YData need to be the same Length
            data_x = 0:(1/Stimuli.RPsamprate_Hz):FFR_Gating.FFRlength_ms/1000;
            newlen = min([length(data_x),length(FFRdataAvg_PO_plot1{attenIND}),...
                length(FFRdataAvg_NP_plot1{attenIND}), length(FFRdataAvg_PO_plot2{attenIND}),...
                length(FFRdataAvg_NP_plot2{attenIND})]);
            data_x = data_x(1:newlen);
            
            data_NP1 = zeros(1,newlen); 
            data_NP1 = FFRdataAvg_NP_plot1{attenIND}(1:newlen);
            data_PO1 = zeros(1,newlen); 
            data_PO1 = FFRdataAvg_PO_plot1{attenIND}(1:newlen);
            data_NP2 = zeros(1,newlen);
            data_NP2 = FFRdataAvg_NP_plot2{attenIND}(1:newlen);
            data_PO2 = zeros(1,newlen); 
            data_PO2 = FFRdataAvg_PO_plot2{attenIND}(1:newlen);
            
            if Stimuli.rec_channel > 2
                set(FIG.ax.line(1),'xdata',data_x, ...
                    'ydata',(data_NP1+data_PO1)*Display.PlotFactor/2);
                set(FIG.ax.line(3),'xdata',data_x, ...
                    'ydata',(data_NP2+data_PO2)*Display.PlotFactor/2');
                set(FIG.ax.line(2),'xdata',data_x, ...
                    'ydata',(data_NP1-data_PO1)*Display.PlotFactor/2);
                set(FIG.ax.line(4),'xdata',data_x, ...
                    'ydata',(data_NP2-data_PO2)*Display.PlotFactor/2);
                set(FIG.ax.line2(1),'ydata',maxFFRobs1);
                set(FIG.ax.line2(3),'ydata',maxFFRobs2);
            elseif Stimuli.rec_channel == 2 % Ch2 only 
                set(FIG.ax.line(3),'xdata',data_x, ...
                    'ydata',(data_NP2+data_PO2)*Display.PlotFactor/2);
                set(FIG.ax.line(4),'xdata',data_x, ...
                    'ydata',(data_NP2-data_PO2)*Display.PlotFactor/2);
                set(FIG.ax.line2(3),'ydata',maxFFRobs2);
            else % Ch1 only
                set(FIG.ax.line(1),'xdata',data_x, ...
                    'ydata',(data_NP1+data_PO1)*Display.PlotFactor/2);
                set(FIG.ax.line(2),'xdata',data_x, ...
                    'ydata',(data_NP1-data_PO1)*Display.PlotFactor/2);
                set(FIG.ax.line2(1),'ydata',maxFFRobs1);
            end
            drawnow;
        end
    end
    
    % Odd that 1 is negative polarity - need to check if it's correct % SP
    % on 7/22/19
    FFRdataAvg_PO_save1{attenIND}= nanmean(cell2mat(FFRdataReps1(1:2:end)'), 1);
    FFRdataAvg_NP_save1{attenIND}= nanmean(cell2mat(FFRdataReps1(2:2:end)'), 1);
    FFRdataAvg_PO_save2{attenIND}= nanmean(cell2mat(FFRdataReps2(1:2:end)'), 1);
    FFRdataAvg_NP_save2{attenIND}= nanmean(cell2mat(FFRdataReps2(2:2:end)'), 1);
    FFRdataReps_outer1{attenIND} = FFRdataReps1;
    FFRdataReps_outer2{attenIND} = FFRdataReps2;
    
    if (bAbort == 1 || save == 1) % not sure if the right place to abort/save
        break;
    end
    
end

if (bAbort == 0)
    beep;
    %     ButtonName=questdlg('Do you wish to save these data?', ...
    %         'Save Prompt', ...
    %         'Yes','No','Comment','Yes');
    ButtonName= 'Yes';
    
    switch ButtonName
        case 'Yes'
            comment='No comment.';
        case 'Comment'
            comment=add_comment_line;	%add a comment line before saving data file
    end
    
    %    disp(sprintf(ButtonName))
    if ~strcmp(ButtonName,'No')
        FFR_set_attns(-120,-120,Stimuli.channel,Stimuli.KHosc,RP1,RP3);
        PAset([120;120;120;120]);
        set(FIG.statText.status, 'String', 'STATUS: saving data...');
        % chan 1
        NelData= make_FFRwav_text_file(misc, Stimuli, invfiltdata, PROG, NelData, comment, ...
            RunLevels_params, FFR_Gating, FFRdataAvg_PO_plot1,FFRdataAvg_PO_plot2,...
            FFRdataAvg_NP_plot1,FFRdataAvg_NP_plot2,...
            FFRdataAvg_PO_save1,FFRdataAvg_PO_save2, ...
            FFRdataAvg_NP_save1,FFRdataAvg_NP_save2,...
            Display, FFRattens, FFRdataReps1,FFRdataReps2,...
            interface_type);
        
        current_data_file('FFR',1); %strcat(FILEPREFIX,num2str(FNUM),'.m');
        uiresume; % Allow Nel's main window to update the Title
        
        %% From NEL: "update_nel_title"
        if (strncmp(data_dir,NelData.File_Manager.dirname,length(data_dir)))
            display_dir = strrep(NelData.File_Manager.dirname(length(data_dir)+1:end),'\','');
        else
            display_dir = NelData.File_Manager.dirname;
        end
        set(NelData.General.main_handle,'Name',...
            ['Running FFR ...  -  ''' display_dir '''   (' int2str(NelData.File_Manager.picture) ' Saved Pictures)']);
    end
end

%% Reset to "free running..." mode:
set(FIG.statText.status, 'String', ['STATUS (' interface_type '): free running...']);
FFR_set_attns(Stimuli.atten_dB,-120,Stimuli.channel,Stimuli.KHosc,RP1,RP3);
set(FIG.push.run_levels,'string','Run levels...');
set(FIG.push.run_levels,'Userdata','');
set(FIG.push.forget_now,'string','Forget NOW');
set(FIG.push.forget_now,'Userdata','');
set(FIG.push.close,'Enable','on');

% set(FIG.push.forget_now,'Enable','on');
firstSTIM = 1;  % Reset Running Avgs: MH 18Nov2003

% clear plots
set(FIG.ax.line(1),'xdata',[],'ydata',[]);
set(FIG.ax.line(2),'xdata',[],'ydata',[]);
set(FIG.ax.line(3),'xdata',[],'ydata',[]);
set(FIG.ax.line(4),'xdata',[],'ydata',[]);
% Change the legends back.
set(FIG.ax.line(1),'DisplayName', 'Ch 1 Neg');
set(FIG.ax.line(2),'DisplayName', 'Ch 1 Pos');
set(FIG.ax.line(3),'DisplayName', 'Ch 2 Neg');
set(FIG.ax.line(4),'DisplayName', 'Ch 2 Pos');
% Clear threshold/AR
set(FIG.ax.line2(1),'ydata',[]);
set(FIG.ax.line2(3),'ydata',[]);

drawnow;
% misc.n = double(~(invoke(RP1,'GetTagVal','ORG')))+(~save);
% misc.n = double(~(invoke(RP1,'GetTagVal','ORG')))+(bAbort);  %original 27jan2012
misc.n = double(~(invoke(RP1,'GetTagVal','ORG')));