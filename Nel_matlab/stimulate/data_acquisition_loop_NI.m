function [block_info,stim_info] = data_acquisition_loop_NI(DAL,nChannels,h_status,EP_nChannels)
global root_dir
global RP PA Trigger SwitchBox
global NelData
% global stm_common_parameters  % commented out by GE 14Aug2002 (never used).

%%%%%%%%%%%%%%%%%%%
%% Alternate DAL function, adapted from default DAL by GE, 30oct2003.
%%
%% As of 30oct2003:
%%  The function is modified by moving the end-of-line plot call to after
%%  the stimulus has played.  This move is in order to fix a strange bug where the "find"
%%  statement in the "default_plot_rate" was causing stimuli from the NI board to be corrupted.
%%
%%%%%%%%%%%%%%%%%%%


%%%%%
% This is done for efficiency only (because Matlab does not enable passing arguments by refference) - AF.
global spikes EPdata
%%%%%

%initialize
if (exist('nChannels','var') ~= 1)
    nChannels = 1;
end
if (exist('EP_nChannels','var') ~= 1)
    EP_nChannels = 1;
end
spikes.times = cell(1,nChannels);
spikes.last  = zeros(1,nChannels);
for i = 1:nChannels
    spikes.times{i} = zeros(100000,2);
end

if (isfield(DAL,'contPlotParams'))
    contPlotParams = DAL.contPlotParams;
else
    contPlotParams     = default_plot_raster_params(DAL.Gating.Period/1000);
end
if (isfield(DAL,'endLinePlotParams'))
    endLinePlotParams = DAL.endLinePlotParams;
else
    endLinePlotParams  = default_plot_rate_params(DAL.Gating.Period/1000,DAL.Gating.Duration/1000);
end
if (isfield(DAL,'endBlockPlotParams'))
    endBlockPlotParams = DAL.endBlockPlotParams;
else
    endBlockPlotParams = [];
end
if (isfield(DAL,'dispStatus'))
    dispStatus = DAL.dispStatus;
    dispStatus.handle = h_status;   % added by GE, 07Apr2003.
else
    dispStatus.func    = 'default_inloop_status';
    dispStatus.handle  = h_status;
end

rc = 1;
common.index = 1;
common.dispStatus = dispStatus;  % To allow the inploopfunction to display status and errors.
common.short_description = DAL.short_description;
common.description = DAL.description;
msdl(1,nChannels);
%% Call Inloop function (loads/runs/sends appropriate params to the rcos)
%%      ...(and/or loads waveforms to the NI board [GE 14Aug2002]).
[stim_info,block_info,plot_info] = call_user_func(DAL.Inloop.Name,common,DAL.Inloop.params);

%% EP acquisition init (loads the EP rco to the second RP if required)
if (isfield(NelData.General,'EP'))
    for i_ep = 1:EP_nChannels
        if (NelData.General.EP(i_ep).record == 1)
            [ep,rc] = EP_record(i_ep, NelData.General.EP(i_ep).duration, NelData.General.EP(i_ep).start); %% ADD i_ep in the future
            NelData.General.EP(i_ep).sampleInterval = 1000 / RP(2).sampling_rate;   % Equal to 1000msec/sampleFreq(Hz) for RP(2).
            NelData.General.EP(i_ep).lineLength = ...
                floor(NelData.General.EP(i_ep).duration / NelData.General.EP(i_ep).sampleInterval);
            NelData.General.EP(i_ep).lastN = 0;
            NelData.General.EP(i_ep).nClipped = 0;
            
            % some "short-hand" for use later:
            ep_lineLen = NelData.General.EP(i_ep).lineLength;
            ep_sampInt = NelData.General.EP(i_ep).sampleInterval;
            ep_lastN = NelData.General.EP(i_ep).lastN;
            
            EPdata(i_ep).X = (1:ep_lineLen) * ep_sampInt;   %in msec
            EPdata(i_ep).aveY = zeros(1, ep_lineLen);
            EPdata(i_ep).allY = NaN(block_info.nlines, ep_lineLen);  %% Pre-alloc more here??
            
            % plot initializations:
            NelData.General.EP(i_ep).plotFunc = 'default_plot_EP';
            call_user_func(NelData.General.EP(i_ep).plotFunc, i_ep);
        end
    end
end

%% Pulse stim init
if (isfield(NelData.General,'Pulse'))
    if (NelData.General.Pulse.enabled == 1)
        rc = Pulse_stim(NelData.General.Pulse.delay, NelData.General.Pulse.nPulses, NelData.General.Pulse.interPulse);
    end
end

% SP/MH: Oct2 2019 turn on FIR inverse Calib filtering
% disp('HERE START'); 
% ding
[~,block_info.invCALIBpic]=run_invCalib(true);

%% Attens and SwitchBox code
stim_info.attens_devices = stim_info.attens_devices .* DAL.Mix;
if (~isstruct(stim_info))
    rc =0;
else
    nlines  = block_info.nlines;
    MAXtrigs=2*nlines;  %% For RP pulse train
    MAX_pre_nlines=ceil(1.3*nlines);  %% For memory pre-allocation
    %% Pre-allocate space for all possible stim_info lines, but fill with NaN's and {'XXX'}'s
    stim_info(2:MAX_pre_nlines) = repmat(mark_stim_invalid(stim_info(1)), MAX_pre_nlines-1,1);
    [select,connect,PAattns] = find_mix_settings(stim_info(1).attens_devices);
    if (isempty(select) | isempty(connect))
        nelerror('''data_acquisition_loop'': Can''t find appropriate select and connect parameters. Aborting...');
        return;
    end
    rc = SBset(select,connect) & (rc==1);
    rc = PAset(PAattns) & (rc==1);
    rc = (Trigcheck & (rc==1));
    if (rc)
        rc = TRIGset(DAL.Gating.Duration,DAL.Gating.Period,MAXtrigs) & (rc==1);
        trig_off_time = (DAL.Gating.Period - DAL.Gating.Duration) / 1000;
        trig_period   = DAL.Gating.Period / 1000;
        [rc_set,RP] = RPset_params(RP);
        rc = rc_set & (rc==1);
    end
end
if (rc ~= 1)
    nelerror('''data_acquisition_loop'': One or more errors detected. Aborting...');
    return;
end
%if (~isempty(contPlotParams))
contPlotParams = call_user_func(contPlotParams.func,[],contPlotParams,plot_info,nChannels);
%end
%if (~isempty(endLinePlotParams))
endLinePlotParams = call_user_func(endLinePlotParams.func,0,endLinePlotParams,plot_info,nChannels);
%end

%% PreLoop preparation or adaptation or whatever;
common.index = 0;
call_user_func(DAL.Inloop.Name,common,DAL.Inloop.params);
%%
NelData.run_mode = 1;

%% MH/GE 05Nov2003 - Still a problem on first line, try this
pause(DAL.Gating.Duration/1000); % ge debug

TRIGstart;

%%% *** This is needed for NI board to avoid MATLAB doing anything during the stimulus presentation!
%% MH/GE 10/30/03 - Unknown soucre of this bug, but this avoids the issue for now!
% pause(DAL.Gating.Duration/1000); % ge debug

TRIGstart_time=clock;  %% Debug:MH/GE
debug_info.line_time_stamp=TRIGstart_time;
debug_info.debug_index=1;


call_user_func(dispStatus.func,dispStatus.handle,1,plot_info);
max_spike_time = 1.0005 * DAL.Gating.Period/1000;
trig_state = 1;
number_of_presented_lines = 0;
number_of_presented_stims = 0;
end_of_loop_flag = 0;
index = 1;
%% Added for better state-detection and error checking (MGH & AF: 7/16/02)
last_stimsent_index=0; %%%  stimulus index at which the last stimulus was sent SUCCESSFULLY!
stimstat_index=1;  %% current stim being played: For plotting status
Nbadstim=0;  %% counts # of bad lines
bad_lines=[];
line_errors={};
%%

%% For debugging
PRINTyes=0; %%X
LATEerrlines=[-8 -12 -15];
MISSerrlines=[-5 -20];
%%

%%%%%%%%%%% MAIN PRESENTATION LOOP %%%%%%%%%%%%%%%
%% SIMPLIFIED DETECTION AND ERROR CHECKING FOR STIM UPDATE and PLOTTING (MGH & AF 7/16/02)
%% to avoid not catching missed stimuli, and to reduce how often errors occur
%
% PLOTTING: if index>prev_index, ==>PLOT!
% STIM UPDATE: if index-Nbadstim>last_stimsent_index & TRIGstate=2, ==>UPDATE!!

%% For debugging
debug_info.line_times_start = NaN*zeros(1,nlines); %%MH/GE
debug_info.line_times_start(1)=0;
debug_info.msdl_counter = 1;
debug_info.msdl_times = NaN*zeros(2,10000); %%X ([before,after])
debug_info.msdl_lines = NaN*zeros(1,10000); %%X
debug_info.msdl_trigs = NaN*zeros(1,10000); %%X
debug_info.DALinloop_counter = 1;
debug_info.DALinloop_times = NaN*zeros(2,nlines); %%X
debug_info.DALinloop_lines = NaN*zeros(1,nlines); %%X
%%

while (end_of_loop_flag == 0)
    
    
    %    if (index ~= debug_index) % ge debug
    %       pause(DAL.Gating.Duration/1000);
    %       debug_index = debug_index + 1;
    %    end
    
    %% For debugging
    %    if sum(index==MISSerrlines)
    %       pause(2*trig_period)
    %    end
    %%
    
    trig_prev_state = trig_state;
    prev_index      = index;
    %%% SWITCHED ORDER (MH & AF: 7/16/02) (index before TRIGstate) TO SIMPLIFY detecting occurence of trigger downswing
    
    % MH: 11/3/03: Do we need this delay to make sure that nothing gets done during stimuli??
    % Force to wait until external trigger is no longer "up":
    % Needed to avoid calling anything in MATLAB during stimulus presentation!! NI-board bug!
    %    while (double(invoke(Trigger.activeX,'GetTagVal', 'Stage')) == 1)  %ge debug
    %       if (check_stop_request), break; end
    %    end
    
    
    %   if (trig_state_debug~=1)
    %% For debugging MSDL
    debug_info.msdl_times(1,debug_info.msdl_counter) = etime(clock,TRIGstart_time)-(index-1)*DAL.Gating.Period/1000; %%X
    debug_info.msdl_lines(debug_info.msdl_counter) = index;%%X
    
    %%%%KEEP!!!!
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    [spk, index, msdl_status] = msdl(2);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    [debug_info.trig_state, debug_info.count_down] = TRIGget_state; % ge debug
    
    
    %        %% GE debug
    %        [debug_info.trig_state debug_info.count_down] = TRIGget_state;
    %        while(debug_info.trig_state == 1)
    %           [debug_info.trig_state debug_info.count_down] = TRIGget_state;
    %           if (check_stop_request), break; end
    %        end
    
    
    %% MH debug
    %      spk{1}=spk{1}([1 end],:);
    
    %       NUM_SPKS=11;
    %       %       SPK_DUR=.1;
    %       %       NUM_SPKS=ceil(SPK_DUR*SPK_RATE);
    %
    % %       if (trig_state_debug~=trig_prev_state)&(trig_state_debug==1)
    % %          index=index+1;
    % %       end
    %       spk={[index*ones(NUM_SPKS,1) [.1:(.1/(NUM_SPKS-1)):.2]']};
    %       msdl_status=[0 0];
    %
    
    %% For debugging
    debug_info.msdl_times(2,debug_info.msdl_counter) = etime(clock,TRIGstart_time)-(index-1)*DAL.Gating.Period/1000; %%X
    debug_info.msdl_lines(debug_info.msdl_counter) = index;%%X
    debug_info.msdl_counter = debug_info.msdl_counter+1;   %%
    %%
    %% For debugging
    debug_info.msdl_trigs(debug_info.msdl_counter) = debug_info.trig_state;%%X
    %   end
    
    
    [trig_state, count_down] = TRIGget_state;
    
    
    
    
    %% For debugging
    %%%      PRINTyes=1;  % uncomment to see indices for every loop pass, o/w only on errors
    %    if(PRINTyes) %only print if error
    %       fprintf('Last_sentstim_index=%d; Nbad=%d; curstim=%d; Prev_index=%d; index=%d; prev trig_state=%d; trig_state=%d; loop_count=%d; elapsed_loop_time=%.3f\n', ...
    %       last_stimsent_index,Nbadstim,stimstat_index,prev_index,index,trig_prev_state,trig_state,loop_counter,loop_times(loop_counter-1)) %%X
    %       PRINTyes=0;
    %    end
    %%
    
    if (any(msdl_status) < 0)
        nelwarn(['msdl error (' int2str(msdl_status(msdl_status<0)) ') in line ' int2str(index)]);
    end
    % 7/31/02: MGH: added condition to index check to verify last stim not missed
    if ((trig_state == 0) & (count_down == MAXtrigs)) | ((index-Nbadstim>nlines) & (last_stimsent_index == nlines-1))
        %% End of picture: Either TDT counter ran out, or all stimuli were completed
        end_of_loop_flag = 1;
        if(trig_state==0) %% End of picture: TDT counter ran out
            index = index+1; % add 1 trigger, since RP pulses ran out
            nelerror(sprintf('Only %d of %d stimuli presented!! RP2 pulses ran out!', ...
                last_stimsent_index,nlines));
            stimstat_index=stimstat_index-1;
        end
    else
        %% Checks major discrepancies between TDT and counter board, e.g., trigger not connected
        if ((((MAXtrigs-count_down+1)-index < 0) | ((MAXtrigs-count_down+1) - index  >1)) & ~(MAXtrigs == index))
            nelerror(sprintf( ...
                'Inconsistent line number in RP2 (%d) and counter-card (%d). Check Trigger connections!', ...
                MAXtrigs-count_down+1, index));
        end
    end
    
    %% CHECK for MISSED stimulus (1 or more)
    if ((index-last_stimsent_index-Nbadstim>1)&(~end_of_loop_flag))
        if (index-last_stimsent_index-Nbadstim==2)
            nelerror(sprintf('Stimulus %d was MISSED (line %d)!! ... repeated',last_stimsent_index+2,index));
        else
            nelerror(sprintf('Stimuli %d:%d were MISSED (lines %d:%d)!! ... repeated', ...
                last_stimsent_index+2,index-Nbadstim,last_stimsent_index+2+Nbadstim,index));
        end
        ding;
        if(~Nbadstim)
            nelerror('Reduce system/Matlab load; increase Gating period!!');  % Only show this on 1st bad stimulus
        end
        
        %% For debugging
        %       fprintf('Last_sentstim_index=%d; Nbad=%d; curstim=%d; Prev_index=%d; index=%d; prev trig_state=%d; trig_state=%d; loop_count=%d; elapsed_loop_time=%.3f\n', ...
        %          last_stimsent_index,Nbadstim,stimstat_index,prev_index,index,trig_prev_state,trig_state,loop_counter,loop_times(loop_counter-1)) %%X
        %       PRINTyes=1;
        %       fprintf('Stimuli %d:%d were MISSED (lines %d:%d)!!\n', ...
        %          last_stimsent_index+2,index-Nbadstim,last_stimsent_index+2+Nbadstim,index) %%X
        %%%
        
        %% Bookkeeping
        stimstat_index=last_stimsent_index+1;  %%%%% Show stimulus actually being presented (for status plot)
        
        %% Update stim_info to record stimuli actually presented
        stim_info(last_stimsent_index+2+Nbadstim:index)=repmat(stim_info(last_stimsent_index+1+Nbadstim), ...
            length(last_stimsent_index+2+Nbadstim:index),1);
        
        %% Update plotting values to deal with repeats: if bad lines, spikes not plotted
        contPlotParams.var_vals(index+1:end+length(last_stimsent_index+2+Nbadstim:index))= ...
            contPlotParams.var_vals(last_stimsent_index+2+Nbadstim:end);
        contPlotParams.var_vals(last_stimsent_index+2+Nbadstim:index)= ...
            NaN(length(last_stimsent_index+2+Nbadstim:index),1);  % Don't plot unintended repeats
        %%%%%%%%%%%%%
        %% TODO: Same thing for EndLinePlotParams
        %%%%%%%%%%%%%
        
        %% Record badlines and error types
        bad_lines=[bad_lines last_stimsent_index+2+Nbadstim:index];
        line_errors=[line_errors repmat({'miss'},1,length(last_stimsent_index+2+Nbadstim:index))];
        
        %% Last thing, is to update number of BAD stimulus lines
        Nbadstim=Nbadstim+length(last_stimsent_index+2+Nbadstim:index);
    end
    
    % Check spikes. Trim longer than max_spike_time for the last line only.
    for i = 1:length(spk)
        if (any(spk{i}(:,2) < 0))
            nelerror('ERROR IN msdl: NEGATIVE spike times!!!');
        end
        if (index-Nbadstim>nlines)  % Remove spikes from any extra pulses after all stim presented
            bad_spikes = (spk{i}(:,1) > nlines+Nbadstim);
            spk{i} = spk{i}(~bad_spikes,:);
        end
        bad_spikes = (spk{i}(:,2) > max_spike_time);
        if (any(bad_spikes))
            if ((index-Nbadstim >= nlines) | (index>=MAXtrigs))  %% Take extra spikes away from last line
                spk{i} = spk{i}(~bad_spikes,:);
            else
                nelerror('ERROR IN msdl: Spike times longer than stimulus period!!!');
            end
        end
    end
    
    %% Acquire EP
    if (isfield(NelData.General,'EP'))
        for i_ep = 1:EP_nChannels
            if  (NelData.General.EP(i_ep).record == 1)
                [ep,ep_rc,ep_clip_flag] = EP_record(i_ep); %% ADD i_ep into EP_record in the future and implement below
                rc = ep_rc & (rc==1);
                if (ep_clip_flag == 1) % trial rejected because of clipping.
                    NelData.General.EP(i_ep).nClipped = NelData.General.EP(i_ep).nClipped + 1;
                    nelwarn(['Line ' int2str(index) ' A/D input clipped (total = ' int2str(NelData.General.EP(i_ep).nClipped) ')']);
                end
                if (~isempty(ep))
                    NelData.General.EP(i_ep).lastN = NelData.General.EP(i_ep).lastN + 1;
                    ep_lastN = NelData.General.EP(i_ep).lastN;
                    if (ep_lastN+(NelData.General.EP(i_ep).nClipped) ~= index)
                        nelerror('IN data_acquisition_loop: spike line and EP acquisition indexing are not synchronized.');
                    end
                    EPdata(i_ep).aveY = ...
                        ( (EPdata(i_ep).aveY * (ep_lastN - 1)) + (ep{1}(1:ep_lineLen)) ) / ep_lastN;
                    EPdata(i_ep).allY(ep_lastN,:) = ep{1}(1:ep_lineLen);
                    call_user_func(NelData.General.EP(i_ep).plotFunc, i_ep, ...
                        EPdata(i_ep).X, EPdata(i_ep).aveY, ...
                        EPdata(i_ep).X, EPdata(i_ep).allY(ep_lastN, :));
                end
            end
        end
    end
    %% MH/GE 07Nov2003: EP Error checking still needs to be completed, i.e., to match line/missed_lines
    
    call_user_func(contPlotParams.func,spk,contPlotParams);
    concat_spikes(spk);
    drawnow
    
    if (check_stop_request), break; end
    
    %% CHECK if ready to load new stimulus
    if ((index-Nbadstim>last_stimsent_index)&(trig_state == 2))  % Trigger pulse switched to off
        number_of_presented_stims = index;  % This stores total stim presented (good or bad)
        % Check again for user break before we prepare for the next stimulus
        if (check_stop_request), break; end
        
        %% For debugging
        %       if  sum(index==LATEerrlines)
        %          pause(1.17*trig_off_time)
        %       end
        %%
        
        %Prepare for next stimulus
        if (index-Nbadstim < nlines)
            
            % MH debug: ~~~~~WOrks here%     %% GE debug: replaced line here 30oct2003.
            %          call_user_func(endLinePlotParams.func,prev_index,endLinePlotParams);  % MH debug
            
            common.index = last_stimsent_index+2;  %% Next stim to be sent
            
            [stim_info(index+1)] = call_user_func(DAL.Inloop.Name,common,DAL.Inloop.params);
            
            
            if (~isstruct(stim_info(index+1)))
                rc =0; break;
            end
            stim_info(index+1).attens_devices = stim_info(index+1).attens_devices .* DAL.Mix;
            [rc_set,RP] = RPset_params(RP);
            rc = rc_set & (rc==1);
            if (~all(nan_equal(stim_info(index+1).attens_devices,stim_info(index).attens_devices)))
                [select,connect,PAattns] = find_mix_settings(stim_info(index+1).attens_devices);
                rc = SBset(select,connect);
                rc = PAset(PAattns);
            end
            %%% Check that next trigger has not occurred before stimulus loaded!!!!
            index_increment=msdl(4);
            if (index-Nbadstim+index_increment-last_stimsent_index>1)  % MAJOR PROBLEM: STIMULUS NOT LOADED IN TIME
                ding;
                nelerror(sprintf('Stimulus %d not loaded in time (line %d) ...repeated', ...
                    last_stimsent_index+2,index+1));
                if(~Nbadstim)
                    nelerror('Reduce system/Matlab load; increase Gating period!!');
                end
                
                %% For debugging
                %             fprintf('Last_sentstim_index=%d; Nbad=%d, curstim=%d; Prev_index=%d; index=%d; prev trig_state=%d; trig_state=%d; loop_count=%d; elapsed_loop_time=%.3f\n', ...
                %                last_stimsent_index,Nbadstim,stimstat_index,prev_index,index,trig_prev_state,trig_state,loop_counter,loop_times(loop_counter-1)) %%X
                %             PRINTyes=1;
                %             fprintf('Stimulus %d not loaded in time (line %d)!!! (index_increment=%d)\n',last_stimsent_index+2,index+1,index_increment)
                %%
                
                %% Mark stiminfo(index+1)=INVALID, because we can't be sure it was completely loaded
                stim_info(index+1)=mark_stim_invalid(stim_info(index+1),'STIMULUS INVALID');
                
                %% Update plotting values to deal with repeats: if bad lines, spikes not plotted
                contPlotParams.var_vals(index+2:end+1)= ...
                    contPlotParams.var_vals(index+1:end);
                contPlotParams.var_vals(index+1)=NaN;  % Don't plot unintended repeats
                %%%%%%%%%%%%%
                %% TODO: Same thing for EndLinePlotParams
                %%%%%%%%%%%%%
                
                %% Record badlines and error types
                bad_lines=[bad_lines index+1];
                line_errors=[line_errors {'late'}];
                
                %%%%%
                stimstat_index=last_stimsent_index+2;  % Show stim that was loaded UNSUCCESSFULLY
                Nbadstim=Nbadstim+1;
            else
                last_stimsent_index=last_stimsent_index+1;  % Only count SUCCESSFULLY loaded stim
                stimstat_index=last_stimsent_index+1;
            end
        else
            % If last stim has finished (MH: 7/19/02), turn off sound to avoid hearing extra stimuli
            %% These values from: [select,connect,PAattns] = find_mix_settings(NaN*stim_info(1).attens_devices)
            %% But are hard-coded here to avoid 'find_mix_settings.m' warning that nothing will be heard
            rc = PAset(PAattns-PAattns+120);
            rc = SBset([7 7],[0 0]);
        end
    end
    
    % AF & MGH (7/16/02): added prev_index to simplify detection of new line
    %                     and changed the plot to work with prev_index instead of index-1.
    if (index>prev_index)  %% Simple detection for plotting, no matter if badstim
        % Trigger pulse switched to on or last line ended.
        number_of_presented_lines = prev_index;   % This stores total lines presented (good or bad)
        %% THIS IS A HUGE TIME SINK!! Loop delays grow linearly with # of spikes, eventually causing stim errors!!!!
        %% MGH & GE: 7/22/02: Commented this out, so if fig minimized, old spikes in raster are gone
        %% But, refreshed at end of picture, so eventually they will come back!
        %      call_user_func(contPlotParams.func,{},contPlotParams,[],[],1:nChannels); % Allow contplot to set all the data points.
        
        %% For debugging
        debug_info.DALinloop_times(1,debug_info.DALinloop_counter) = etime(clock,TRIGstart_time)-(index-1)*DAL.Gating.Period/1000; %%X
        debug_info.DALinloop_lines(debug_info.DALinloop_counter) = index;%%X
        %%
        
        %% GE debug
        %        debug_info.triggerStage = double(invoke(Trigger.activeX,'GetTagVal', 'Stage'));
        % %        Trigger = RPget_params(Trigger);
        % %        [debug_info.trig_state debug_info.count_down] = TRIGget_state;
        % %        while(Trigger.params_in.Stage == 1)
        %        while(debug_info.triggerStage == 1)
        %           if (check_stop_request), break; end
        % %           [debug_info.trig_state debug_info.count_down] = TRIGget_state;
        % %           Trigger = RPget_params(Trigger);
        %           debug_info.triggerStage = double(invoke(Trigger.activeX,'GetTagVal', 'Stage'));
        % %           debug_info.trigState = double(invoke(actvX, 'GetTagVal', tagname))
        % %           state = Trigger.params_in.Stage; % Yes, 'Stage' is the name in the rco.
        %        end
        
        
        %      %% GE debug 08Nov2003.  These lines can be removed once the mex-file is set up to keep the
        %      %%   NI loadBuffer persistent.
        %        % Force to wait until external trigger is no longer "up":
        %        % Needed to avoid calling EndLinePlot during stimulus presentation!! NI-board bug!
        %        while (double(invoke(Trigger.activeX,'GetTagVal', 'Stage')) == 1)  %ge debug
        %           if (check_stop_request), break; end
        %        end
        
        %% GE debug 30oct2003: removed the call here and moved up such that call is made
        %%  only after current stimulus has finished playing (i.e., trigger is back down).
        call_user_func(endLinePlotParams.func,prev_index,endLinePlotParams);
        
        %% For debugging
        debug_info.DALinloop_times(2,debug_info.DALinloop_counter) = etime(clock,TRIGstart_time)-(index-1)*DAL.Gating.Period/1000; %%X
        debug_info.DALinloop_lines(debug_info.DALinloop_counter) = index;%%X
        debug_info.DALinloop_counter = debug_info.DALinloop_counter+1;   %%
        %%
        
        
        
        %% Match to stimulus actually being played
        call_user_func(dispStatus.func,dispStatus.handle,stimstat_index,plot_info);
    end
    if (rc ~= 1)
        break;
    end
end
if (~check_stop_request), beep; end % AF 06/11/02
PAset(PAattns-PAattns+120);
SBset([7 7],[0 0]);
RPhalt(RP);
RPclear(RP);
%PAset(PAattns-PAattns+120);  % Moved up Oct 27 2003 , to avoid click in SBset
%SBset([7 7],[0 0]);  %MH: moved up Oct2003 , only works above RPhalt/RPclear?
if (end_of_loop_flag)
    %7/31/02: MGH: min(index-1,end) should never use end, but just in case to avoid losing data on error
    stim_info = stim_info(1:min(index-1,end));  %Remove extra pre-allocated lines
else  % user (or error) break, not all the stimuli were fully presented!
    stim_info = stim_info(1:min(index,end));  %Store all lines presented at all, good or bad
end
block_info.fully_presented_stimuli = number_of_presented_stims;
block_info.fully_presented_lines = number_of_presented_lines;
block_info.bad_lines=bad_lines;
block_info.line_errors=line_errors;
%% This refreshes the contPlot in case it was minimized during loop
call_user_func(contPlotParams.func,{},contPlotParams,[],[],1:nChannels); % Allow contplot to set all the data points.
%%%cleanup
call_user_func(DAL.Inloop.Name);
msdl(0);
SBset([],[]);
if (rc ~= 1)
    nelerror('''STM'': Error(s) detected within stimulus presentation loop');
end

% SP/MH: Oct2 2019 turn off FIR inverse Calib filtering
% disp('HERE END'); 
% ding
run_invCalib(false);

% MH:11Nov2004  This is a bit of a hack, but is needed to generalize the use of nstim in showing Number of Spikes / Condition
global nstim
nstim=0;

%% For debugging
% save timing_debug_102803.mat line_times_start msdl_times DALinloop_times msdl_lines msdl_trigs DALinloop_lines  %MH/GE
%
% save \Users\GE\timing_debug_102803.mat debug_info  %MH/GE
%

% asdfasdfasdf = 1;   % For debugging breakpoint to look at loop_times
%%