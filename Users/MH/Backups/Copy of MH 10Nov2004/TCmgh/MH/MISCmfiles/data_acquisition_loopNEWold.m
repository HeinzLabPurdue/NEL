function [block_info,stim_info] = data_acquisition_loop(DAL,nChannels,h_status,EP_nChannels)
global root_dir
global RP PA Trigger SwitchBox
global stm_common_parameters NelData

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
else
   dispStatus.func    = 'default_inloop_status';
   dispStatus.handle  = h_status;
end

rc = 1;
% common = stm_common_parameters;
common.index = 1;   
common.dispStatus = dispStatus;  % To allow the inploopfunction to display status and errors.
common.short_description = DAL.short_description;
common.description = DAL.description;
msdl(1,nChannels);
%% Call Inloop function (loads/runs/sends appropriate params to the rcos)
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
         
         % some "short-hand" for use later:
         ep_lineLen = NelData.General.EP(i_ep).lineLength;
         ep_sampInt = NelData.General.EP(i_ep).sampleInterval;
         ep_lastN = NelData.General.EP(i_ep).lastN;
         
         EPdata(i_ep).X = (1:ep_lineLen) * ep_sampInt;   %in msec
         EPdata(i_ep).aveY = zeros(1, ep_lineLen);
         EPdata(i_ep).allY = repmat(NaN, block_info.nlines, ep_lineLen);
         
         % plot initializations:
         NelData.General.EP(i_ep).plotFunc = 'default_plot_EP';
         call_user_func(NelData.General.EP(i_ep).plotFunc, i_ep);
      end
   end
end

%% Pulse stim init
if (isfield(NelData.General,'Pulse'))
   if (NelData.General.Pulse.enabled == 1)
      rc = Pulse_stim(NelData.General.Pulse.delay);
   end
end

%% Attens and SwitchBox code
stim_info.attens_devices = stim_info.attens_devices .* DAL.Mix;
if (~isstruct(stim_info))
   rc =0; 
else
   nlines  = block_info.nlines;
   stim_info = repmat(stim_info, nlines,1);
   [select,connect,PAattns] = find_mix_settings(stim_info(1).attens_devices); 
   if (isempty(select) | isempty(connect))
      nelerror('''data_acquisition_loop'': Can''t find appropriate select and connect parameters. Aborting...');
      return;
   end
   rc = SBset(select,connect) & (rc==1);
   rc = PAset(PAattns) & (rc==1);
   rc = (Trigcheck & (rc==1));
   if (rc)
      rc = TRIGset(DAL.Gating.Duration,DAL.Gating.Period,nlines) & (rc==1);
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
TRIGstart;
call_user_func(dispStatus.func,dispStatus.handle,1,plot_info);
max_spike_time = 1.0005 * DAL.Gating.Period/1000;
trig_state = 1;
number_of_presented_lines = 0;
number_of_presented_stims = 0;
end_of_loop_flag = 0;
index = 1;

%%
last_stimsent_index=0; %%%  index at which the last stimulus was sent
%%

inloop_time_stamp = clock;%%X

%last_endline_display  = clock;

%%%%%%%%%%% MAIN PRESENTATION LOOP %%%%%%%%%%%%%%%
%% ADD time check for the off period!!!


%% SIMPLIFIED DETECTION AND ERROR CHECKING FOR STIM UPDATE and PLOTTING (MGH & AF 7/16/02)
%
% PLOTTING: if index>prev_index, ==>PLOT!
% STIM UPDATE: if index>last_stimsent_index & TRIGstate=2, ==>UPDATE!! 
%
% These are much simpler detectors, and saving last_stimsent)index will allow better error catching!!

%%
loop_times = NaN*zeros(1,10000); loop_counter = 1;%%X
%%
while (end_of_loop_flag == 0)
   inloop_elapsed_time = etime(clock,inloop_time_stamp);%%X

   %% Is this needed?? if we have an accurate way of checking that stim finished loading in time??
%    if (inloop_elapsed_time > 0.7*trig_period)
%       nelerror([sprintf('System is too busy to manage the data acquisition. (~BAD: from line %d) ',prev_index) ...
%             'Reduce system/Matlab load and/or increase the Gating period and REPEAT this picture! ' ...
%             '[Error: inloop_elapsed_time > 0.7 * trigger period]']);
%    end
   
   %%
   loop_times(loop_counter) = etime(clock,inloop_time_stamp); loop_counter = loop_counter+1;%%X
   %%

   inloop_time_stamp = clock;  %%X
   trig_prev_state = trig_state;
   prev_index      = index; %%
   
   %%% SWITCHED ORDER (index before TRIGstate) TO SIMPLIFY detecting trigger downswing
   [spk index msdl_status] = msdl(2);    
   [trig_state count_down] = TRIGget_state;
   if (index-last_stimsent_index>1)   %% MAJOR PROBLEM: MISSED ENTIRE STIMULUS
      nelerror([sprintf('Stimulus for line %d was MISSED!! ',last_stimsent_index+2) ...
            'Reduce system/Matlab load and/or increase the Gating period and REPEAT this picture! ']);
   end
   if (any(msdl_status) < 0)
      nelwarn(['msdl error (' int2str(msdl_status(msdl_status<0)) ') in line ' int2str(index)]);
   end
   if ((trig_state == 0) & (count_down == nlines))
      end_of_loop_flag = 1;
      index = index+1;
   else
      %% Checks major discrepancies between TDT and counter board, e.g., trigger not connected
      if ((((nlines-count_down+1)-index < 0) | ((nlines-count_down+1) - index  >1)) & ~(nlines == index))
         nelerror(sprintf( ...
            'Inconcistent line number in RP2 (%d) and counter-card (%d). Check Trigger connections!', ...
            nlines-count_down+1, index));
      end
      
      %%% REMOVE THIS?
      %       if (index>prev_index+1)  %%% Needed??? -- NO, Not if we check index re last_stimsent_index!!!
      %          nelerror([sprintf('System is too busy to manage the data acquisition. (~BAD: from line %d) ',prev_index) ...
      %                'Reduce system/Matlab load and/or increase the Gating period and REPEAT this picture! ' ...
      %                '[Error: More than 1 trigger passed during inloop]']);
      %       end
   end
   % Check spikes. Trim longer than max_spike_time for the last line only.
   for i = 1:length(spk)
      if (any(spk{i}(:,2) < 0))
         nelerror('ERROR IN msdl: NEGATIVE spike times!!!');
      end
      bad_spikes = (spk{i}(:,2) > max_spike_time);
      if (any(bad_spikes))
         if (index >= nlines)
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
            [ep,rc] = EP_record(i_ep); %% ADD i_ep into EP_record in the future and implement below
            if (~isempty(ep))
               NelData.General.EP(i_ep).lastN = NelData.General.EP(i_ep).lastN + 1;
               ep_lastN = NelData.General.EP(i_ep).lastN;
               if (ep_lastN ~= index)
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
   call_user_func(contPlotParams.func,spk,contPlotParams);
   concat_spikes(spk);
   drawnow

   if (check_stop_request), break; end

   % AF & MGH (7/16/02): Get updated trigger state before deciding whether to update stimulus.
   %   [trig_state2 count_down] = TRIGget_state;
   
   %% ???  WE MAY WANT A MORE RECENT TRIGstate check here??
   
   % AF & MGH (7/16/02): added checks to catch undetected trigger transitions to state 1 or state 2.
   %   %% Check if we missed entire Trig_on based on most recent trig_state 
   %   if (trig_state2==2 & trig_prev_state==2 & index > prev_index & inloop_elapsed_time > 0.04)
   
   %   if (trig_state==2 & trig_prev_state==2 & index > prev_index & inloop_elapsed_time > 0.04)
   %      missed_s1_flag = 1;
   %      ding
   %   else
   %      missed_s1_flag = 0;
   %   end
   %% Decide if we missed entire Trig_off based on trig_state at begin. of loop, ow/ false detections
   %   if (trig_state==1 & trig_prev_state==1 & index > prev_index & inloop_elapsed_time > 0.04)
   %      %etime(clock,inloop_time_stamp)
   %      nelerror([sprintf('System is too busy to manage the data acquisition. (~BAD: from line %d) ',prev_index) ...
   %            'Reduce system/Matlab load and/or increase the Gating period and REPEAT this picture! ' ...
   %            '[Error: Missed entire Trig_off state in inloop]']);
   %   end
   %   %% Check if stimulus needs to be updated based on most recent trig_state 
   %   if ( ((trig_state2 == 2) & (trig_prev_state == 1))  | missed_s1_flag ) % Trigger pulse switched to off
   
   %   fprintf('Prev_index=%d; index=%d; prev trig_state=%d; trig_state=%d; loop_count=%d; elapsed_loop_time=%.3f\n', ...
   %       prev_index,index,trig_prev_state,trig_state,loop_counter,loop_times(loop_counter-1))
 
   %   if ( ((trig_state == 2) & (trig_prev_state == 1))  | missed_s1_flag ) % Trigger pulse switched to off
   if ( (index>last_stimsent_index)&(trig_state == 2))  % Trigger pulse switched to off
      %      fprintf('     UPDATE STIM\n')
      trig_offtime = clock;   %% Can remove this??
      number_of_presented_stims = index;
      % Check again for user break before we prepare for the next stimulus
      if (check_stop_request), break; end
      
      %Prepare for next stimulus
      if (index < nlines)
         common.index = index+1;
         [stim_info(common.index)] = call_user_func(DAL.Inloop.Name,common,DAL.Inloop.params);
         if (~isstruct(stim_info(common.index)))
            rc =0; break;
         end
         stim_info(common.index).attens_devices = stim_info(common.index).attens_devices .* DAL.Mix;
         [rc_set,RP] = RPset_params(RP);
         rc = rc_set & (rc==1);
         if (~all(nan_equal(stim_info(common.index).attens_devices,stim_info(common.index-1).attens_devices)))
            [select,connect,PAattns] = find_mix_settings(stim_info(common.index).attens_devices);
            rc = SBset(select,connect);
            rc = PAset(PAattns);
         end
         %%% Check that next trigger has not occurred before stimulus loaded!!!!
         index_increment=msdl(4);  
         if (index+index_increment-last_stimsent_index>1)  % MAJOR PROBLEM: STIMULUS NOT LOADED IN TIME
            %         if (index_increment)
            nelerror([sprintf('Stimulus for line %d not loaded in time!!! ',index+1) ...
                  'Reduce system/Matlab load and/or increase the Gating period and REPEAT this picture!']);
         else
            last_stimsent_index=index;
         end
         
         %%% Inexact b/c trig_offtime is not right at offset, better to use index from msdl to check
         %          if (etime(clock,trig_offtime) > 0.9*trig_off_time)  
         %             nelerror('Not enough time to prepare next stimulus. Increase the Gating period and repeat this picture!');
         %          end
      end
   end
  
   % AF & MGH (7/16/02): added missed_s1_flag and changed the plot to work with prev_index instead of index-1.
   %% Decide whether to plot based on trig_state at loop begin, where index was updated
   %   disp(sprintf('Prev_index=%d; index=%d; trig_state=%d; prev_trig_state=%d',prev_index,index,trig_state,trig_prev_state))
   %   if (((trig_state ~= 2) & (trig_prev_state == 2)) | missed_s1_flag )
   if (index>prev_index)  %% Simple detection for plotting
      %      disp(sprintf('PLOTING: Prev_index=%d; index=%d; trig_state=%d; prev_trig_state=%d',prev_index,index,trig_state,trig_prev_state))
      % Trigger pulse switched to on or last line ended.
      number_of_presented_lines = prev_index;
      call_user_func(contPlotParams.func,{},contPlotParams,[],[],1:nChannels); % Allow contplot to set all the data points.
      call_user_func(endLinePlotParams.func,prev_index,endLinePlotParams);
      call_user_func(dispStatus.func,dispStatus.handle,max(1,min(index,nlines)),plot_info);
   end
   if (rc ~= 1)
      break;
   end
end
if (~check_stop_request), beep; end % AF 06/11/02
RPhalt(RP);
RPclear(RP);
if (index < nlines)  % user break, not all the stimuli were fully presented!
   stim_info = stim_info(1:index);
end
block_info.fully_presented_stimuli = number_of_presented_stims;
block_info.fully_presented_lines = number_of_presented_lines;
call_user_func(contPlotParams.func,{},contPlotParams,[],[],1:nChannels); % Allow contplot to set all the data points.
%%%cleanup
call_user_func(DAL.Inloop.Name);
msdl(0);
SBset([],[]);
if (rc ~= 1)
   nelerror('''STM'': Error(s) detected within stimulus presentation loop');
end
asdfasdfasdf = 1;