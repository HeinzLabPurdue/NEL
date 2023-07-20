%% Working

function [firstSTIM, NelData]=FFRwav_RunLevels(FIG,Stimuli,RunLevels_params, misc, FFRwav_Gating,...
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

%% RunLevels_params.nPairs = Stimuli.FFRmem_reps;
% Setup panel for acquire/write mode:
set(FIG.push.run_levels,'string','Abort');
set(FIG.push.forget_now,'string','Save NOW');
bAbort = 0;
save = 0;
set(FIG.ax.line ,'xdata',[],'ydata',[]);
set(FIG.ax.line2,'xdata',[],'ydata',[]);
set(FIG.ax.line3,'ydata',0);
drawnow;  % clear the plot.

%% New axes for showing maximum of each input waveform - KHZZ 2011 Nov 4
FIG.ax.axis2 = axes('position',[.925 .34 .025 .62]);
FIG.ax.line3 = plot(0.5,0,'r*');
hold on;
FIG.ax.line4 = plot([0 1],[Stimuli.threshV Stimuli.threshV],':r');
%set(FIG.ax.line2,'MarkerSize',2,'Color','r');
xlim([0 1]);
ylim([0 2]);
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
FFRdataAvg_PO_plot=cell(size(RunLevels_params.attenMask));  % Average data polarized     %zz 04nov11
FFRdataAvg_NP_plot=cell(size(RunLevels_params.attenMask));  % Average data not polarized %zz 04nov11
FFRdataAvg_PO_save= cell(size(RunLevels_params.attenMask));
FFRdataAvg_NP_save= cell(size(RunLevels_params.attenMask));

%% not storing all repetitions zz 04nov11
FFRdataReps_outer=cell(size(RunLevels_params.attenMask));  % All Reps
FFRattens=cell(size(RunLevels_params.attenMask));

%% Main Loop
% Not looping through attens for SFR. Assuming single attenutation.
for attenIND= 1
    attenLevel= Stimuli.atten_dB;
    set(FIG.ax.line3,'ydata',[]);
    rejections=0; %for artifact rejection KHZZ 2011 Nov 4
    
    FFRattens{attenIND}=attenLevel;
    
    set(FIG.statText.status, 'String', sprintf('STATUS: averaging at -%.1f dB...', attenLevel));
    
    FFRdataAvg_PO_plot{attenIND} = zeros(1, FFRnpts);
    FFRdataAvg_NP_plot{attenIND} = zeros(1, FFRnpts);
    
    
    %     for nnnnnnnn=1:2*RunLevels_params.nPairs
    %         FFRdataReps{nnnnnnnn} = zeros(1,FFRnpts); % 2*RunLevels_params.nPairs changed to 1 DA 7/24/13
    %     end
    FFRdataReps= cell(1, 2*RunLevels_params.nPairs); % SP on 22Jul19
    
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
                FFRdata = invoke(RP3,'ReadTagV','ADbuf',0,FFRnpts);
                maxFFRobs = max(abs(FFRdata)); %Artifact rejection KHZZ 2011 Nov 4
                set(FIG.ax.line3,'xdata',0.5,'ydata',maxFFRobs);
                drawnow;
                
                % fixing the function to make sure the polarity matches, starts with 1,
                % which must match with 1 for original
                
                %% SP Debug
                %                 if maxFFRobs <= critVal
                if  invoke(RP1,'GetTagVal','ORG') == mod(currStim,2) && maxFFRobs <= critVal
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
                            FFRdataAvg_PO_plot{attenIND} = FFRdataAvg_PO_plot{attenIND}*(1 - weight) + weight*FFRdata;

                        else
                            FFRdataAvg_NP_plot{attenIND} = FFRdataAvg_NP_plot{attenIND}*(1 - weight) + weight*FFRdata;
                        end
                    end
                    
                    if currStim
                        FFRdataReps{currStim}=FFRdata; %added DA 7/23/13
                        %                         fprintf('rejections %1.0f:: ORGval = %1.0f :: currStim= %1.0f :: MaxVal=%1.2f :: nSamps= %d\n', ...
                        %                             rejections, invoke(RP1,'GetTagVal','ORG') ,currStim, maxFFRobs, bNoSampleObtained);
                    end
                    
                elseif maxFFRobs > critVal
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
            if mod(currStim,2)
                %                 set(FIG.ax.line,'xdata',[0:(1/Stimuli.RPsamprate_Hz):
                %                     FFR_SNRenv_Gating.FFRlength_ms/1000],
                %                 'ydata',FFRdataAvg_NP{attenIND}*Display.PlotFactor); drawnow;
            else  % every other curstim, plot SUM (ENV_FFR)
                
                %make sure to plot same dimension x and y data
                data_x = 0:(1/Stimuli.RPsamprate_Hz):FFRwav_Gating.FFRlength_ms/1000;
                newlen = min(length(data_x),length(FFRdataAvg_PO_plot{attenIND}));
                data_x = data_x(1:newlen);
                data_pos = FFRdataAvg_PO_plot{attenIND}(1:newlen);
                data_neg = FFRdataAvg_NP_plot{attenIND}(1:newlen);
                data_y = (data_pos+data_neg)/2;
                
                
                set(FIG.ax.line,'xdata',data_x, ...
                    'ydata',data_y*Display.PlotFactor);
                drawnow;
            end
        end
    end
    
    % Odd that 1 is negative polarity - need to check if it's correct % SP
    % on 7/22/19
    FFRdataAvg_PO_save{attenIND}= nanmean(cell2mat(FFRdataReps(1:2:end)'), 1);
    FFRdataAvg_NP_save{attenIND}= nanmean(cell2mat(FFRdataReps(2:2:end)'), 1);
    FFRdataReps_outer{attenIND}= FFRdataReps;
    
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
        NelData= make_FFRwav_text_file(misc, Stimuli, PROG, NelData, comment, ...
            RunLevels_params, FFRwav_Gating, FFRdataAvg_PO_plot, FFRdataAvg_NP_plot, FFRdataAvg_PO_save, ...
            FFRdataAvg_NP_save, Display, FFRattens, FFRdataReps, interface_type);
        
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
set(FIG.ax.line ,'xdata',[],'ydata',[]);
set(FIG.ax.line2,'xdata',[],'ydata',[]); drawnow;  % clear the plot.
% misc.n = double(~(invoke(RP1,'GetTagVal','ORG')))+(~save);
% misc.n = double(~(invoke(RP1,'GetTagVal','ORG')))+(bAbort);  %original 27jan2012
misc.n = double(~(invoke(RP1,'GetTagVal','ORG')));