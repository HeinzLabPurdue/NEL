%% Working

function [firstSTIM, NelData]=FFR_SNRenv_RunLevels2(FIG,Stimuli,RunLevels_params, misc, FFR_SNRenv_Gating,...
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

% adding demean flag (JMR 2021)
demean_flag = 1;
% Artefact threshold for chan 2 :JMR Sept 21
art_factor = 15;
%% RunLevels_params.nPairs = Stimuli.FFRmem_reps;
% Setup panel for acquire/write mode:
set(FIG.push.run_levels,'string','Abort');
set(FIG.push.forget_now,'string','Save NOW');
bAbort = 0;
save = 0;
%set(FIG.ax.line(1),'xdata',[],'ydata',[]);
%set(FIG.ax.line(2),'xdata',[],'ydata',[]);
%set(FIG.ax.line(3),'xdata',[],'ydata',[]);
%set(FIG.ax.line(4),'xdata',[],'ydata',[]);
set(FIG.ax.line2(1),'ydata',[]);
set(FIG.ax.line2(3),'ydata',[]);

%drawnow;  % clear the plot.

%% New axes for showing maximum of each input waveform - KHZZ 2011 Nov 4
FIG.ax.axis2 = axes('position',[.925 .34 .025 .62]);
FIG.ax.line2 = plot(0.4,0,'r*',[0 1],[Stimuli.threshV Stimuli.threshV],':r',0.6,0,'b*',[0 1],[Stimuli.threshV*art_factor Stimuli.threshV*art_factor],':b');

xlim([0 1]);
ylim([0 10]);
set(FIG.ax.axis2,'XTickMode','auto');
set(FIG.ax.axis2,'YTickMode','auto');
ylabel('Max AD Voltage (1 rep)','fontsize',12,'FontWeight','Bold');
box on;

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
for attenIND= 1
    attenLevel= Stimuli.atten_dB;
    %set(FIG.ax.line3,'ydata',[]);
    rejections=0; %for artifact rejection KHZZ 2011 Nov 4
    
    FFRattens{attenIND}=attenLevel;
    
    set(FIG.statText.status, 'String', sprintf('STATUS: averaging at -%.1f dB...', attenLevel));
    
    FFRdataAvg_PO_plot1{attenIND} = zeros(1, FFRnpts); % chan 1
    FFRdataAvg_NP_plot1{attenIND} = zeros(1, FFRnpts);
    
    FFRdataAvg_PO_plot2{attenIND} = zeros(1, FFRnpts); % chan2
    FFRdataAvg_NP_plot2{attenIND} = zeros(1, FFRnpts);
    
    
    %     for nnnnnnnn=1:2*RunLevels_params.nPairs
    %         FFRdataReps{nnnnnnnn} = zeros(1,FFRnpts); % 2*RunLevels_params.nPairs changed to 1 DA 7/24/13
    %     end
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
                
                %% SP Debug
                %                 if maxFFRobs <= critVal
                if  invoke(RP1,'GetTagVal','ORG') == mod(currStim,2) && maxFFRobs1 <= critVal && maxFFRobs2<= critVal*art_factor
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
                        %                         fprintf('rejections %1.0f:: ORGval = %1.0f :: currStim= %1.0f :: MaxVal=%1.2f :: nSamps= %d\n', ...
                        %                             rejections, invoke(RP1,'GetTagVal','ORG') ,currStim, maxFFRobs, bNoSampleObtained);
                    end
                    
                elseif maxFFRobs1 > critVal || maxFFRobs2> critVal*art_factor
                    %             else
                    rejections=rejections+1;
                end %End for artifact rejection KH 2011 June 08
                
                invoke(RP3,'SoftTrg',2);
            end

        end
        %% Debugging
        %         fprintf('rejections %1.0f:: ORGval = %1.0f :: currStim= %1.0f :: MaxVal=%1.2f :: nSamps= %d\n', ...
        %             rejections, invoke(RP1,'GetTagVal','ORG') ,currStim, maxFFRobs, bNoSampleObtained);
        %
         if currStim>0
%             %if mod(currStim,2)
%                 %                 set(FIG.ax.line,'xdata',[0:(1/Stimuli.RPsamprate_Hz):
%                 %                     FFR_SNRenv_Gating.FFRlength_ms/1000],
%                 %                 'ydata',FFRdataAvg_NP{attenIND}*Display.PlotFactor); drawnow;
%             %else  % every other curstim, plot SUM (ENV_FFR)
                set(FIG.ax.line(3),'xdata',0:(1/Stimuli.RPsamprate_Hz):FFR_SNRenv_Gating.FFRlength_ms/1000, ...
                    'ydata',(FFRdataAvg_PO_plot1{attenIND}+FFRdataAvg_NP_plot1{attenIND})*Display.PlotFactor/2);
                set(FIG.ax.line(4),'xdata',0:(1/Stimuli.RPsamprate_Hz):FFR_SNRenv_Gating.FFRlength_ms/1000, ...
                    'ydata',(FFRdataAvg_PO_plot1{attenIND}-FFRdataAvg_NP_plot1{attenIND})*Display.PlotFactor/2); 
                set(FIG.ax.line(1),'xdata',0:(1/Stimuli.RPsamprate_Hz):FFR_SNRenv_Gating.FFRlength_ms/1000, ...
                    'ydata',(FFRdataAvg_PO_plot2{attenIND}+FFRdataAvg_NP_plot2{attenIND})*Display.PlotFactor/2);   
                set(FIG.ax.line(2),'xdata',0:(1/Stimuli.RPsamprate_Hz):FFR_SNRenv_Gating.FFRlength_ms/1000, ...
                    'ydata',(FFRdataAvg_PO_plot2{attenIND}-FFRdataAvg_NP_plot2{attenIND})*Display.PlotFactor/2);     
                set(FIG.ax.line2(1),'ydata',maxFFRobs1);
                set(FIG.ax.line2(3),'ydata',maxFFRobs2);
                drawnow;
             %end
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
        NelData= make_FFR_Se_text_file_2chan(misc, Stimuli, PROG, NelData, comment, ...
            RunLevels_params, FFR_SNRenv_Gating, FFRdataAvg_PO_plot1,FFRdataAvg_PO_plot2,...
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
set(FIG.ax.line(1),'xdata',[],'ydata',[]);
set(FIG.ax.line(2),'xdata',[],'ydata',[]);
set(FIG.ax.line(3),'xdata',[],'ydata',[]);
set(FIG.ax.line(4),'xdata',[],'ydata',[]);
set(FIG.ax.line2(1),'ydata',[]);
set(FIG.ax.line2(3),'ydata',[]);
drawnow;
% misc.n = double(~(invoke(RP1,'GetTagVal','ORG')))+(~save);
% misc.n = double(~(invoke(RP1,'GetTagVal','ORG')))+(bAbort);  %original 27jan2012
misc.n = double(~(invoke(RP1,'GetTagVal','ORG')));