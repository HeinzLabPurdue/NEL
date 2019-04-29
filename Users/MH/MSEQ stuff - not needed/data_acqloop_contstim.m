function [block_info,stim_info] = data_acqloop_contstim(DAL,nChannels,h_status,EP_nChannels)
global root_dir
global RP PA Trigger SwitchBox
global NelData

%%%%%
% This is done for efficiency only (because Matlab does not enable passing arguments by refference) - AF.
global spikes
%%%%%

%initialize
if (exist('nChannels','var') ~= 1)
   nChannels = 1;
end
spikes.times = cell(1,nChannels);
spikes.last  = zeros(1,nChannels);
for i = 1:nChannels
   spikes.times{i} = zeros(100000,2);
end

if (isfield(DAL,'contPlotParams'))
   contPlotParams = DAL.contPlotParams;
else
   contPlotParams     = default_plot_raster_params(DAL.Gating.Duration/1000);
end
if (isfield(DAL,'endLinePlotParams'))
   endLinePlotParams = DAL.endLinePlotParams;
else
   endLinePlotParams  = plot_rate_params_contstim(DAL.Gating.Duration/1000);
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

%% Attens and SwitchBox code
stim_info.attens_devices = stim_info.attens_devices .* DAL.Mix;
if (~isstruct(stim_info))
   rc =0; 
else
   nlines  = block_info.nlines;
   [select,connect,PAattns] = find_mix_settings(stim_info(1).attens_devices); 
   if (isempty(select) | isempty(connect))
      nelerror('''data_acqloop_contstim'': Can''t find appropriate select and connect parameters. Aborting...');
      return;
   end
   rc = SBset(select,connect) & (rc==1);
   rc = PAset(PAattns) & (rc==1);
   if (rc)
      [rc_set,RP] = RPset_params(RP);
      rc = rc_set & (rc==1);
   end
end
if (rc ~= 1)
   nelerror('''data_acqloop_contstim'': One or more errors detected. Aborting...');
   return;
end
contPlotParams = call_user_func(contPlotParams.func,[],contPlotParams,plot_info,nChannels);
endLinePlotParams = call_user_func(endLinePlotParams.func,0,endLinePlotParams,plot_info,nChannels);

NelData.run_mode = 1;
RPSoftTrig(RP(1),1);  % !!! Hard coded RP(1) here...

call_user_func(dispStatus.func,dispStatus.handle,1,plot_info);
max_spike_time = 1.0005 * DAL.Gating.Period/1000;
number_of_presented_lines = 0;
number_of_presented_stims = 1;
end_of_loop_flag = 0;
index = 1;
%% Added for better state-detection and error checking (MGH & AF: 7/16/02)

%%%%%%%%%%% MAIN PRESENTATION LOOP %%%%%%%%%%%%%%%
%% SIMPLIFIED DETECTION AND ERROR CHECKING FOR STIM UPDATE and PLOTTING (MGH & AF 7/16/02)
%% to avoid not catching missed stimuli, and to reduce how often errors occur
%
% PLOTTING: if index>prev_index, ==>PLOT!
% STIM UPDATE: if index-Nbadstim>last_stimsent_index & TRIGstate=2, ==>UPDATE!! 

while (end_of_loop_flag == 0)
    
   prev_index = index;
   if prev_index==nlines
      if RPget_params(RP(1),'DoneFlag') % !! Hard coded RP(1)...
         % Stimulus is finished.  Last time through loop to collect last spikes.
         end_of_loop_flag=1;
      end
   end
   [spk index msdl_status] = msdl(2);
   if (any(msdl_status) < 0)
      nelwarn(['msdl error (' int2str(msdl_status(msdl_status<0)) ') in line ' int2str(index)]);
   end
      
   %% CHECK that we are looping more often that the stimulus buffer is being reset.  I'm not sure that it is 
   % necessary that we are, but to be safe...
   if ((index-prev_index>1)&(~end_of_loop_flag)) 
      ding;
      errstr='In data_acqloop_contstim:  We are looping less often than stimuli are being presented. Matlab load too high!';
      nelerror(errstr);  % Only show this on 1st bad stimulus
   end
   
   % Check spikes. Trim longer than max_spike_time for the last line only.
   for i = 1:length(spk)
      if (any(spk{i}(:,2) < 0))
         nelerror('ERROR IN msdl: NEGATIVE spike times!!!');
      end
      if (index>nlines)  % Remove spikes from any extra pulses after all stim presented
         bad_spikes = (spk{i}(:,1) > nlines);
         spk{i} = spk{i}(~bad_spikes,:);
      end
      bad_spikes = (spk{i}(:,2) > max_spike_time);
      if (any(bad_spikes))
         if (index >= nlines)  %% Take extra spikes away from last line 
            spk{i} = spk{i}(~bad_spikes,:);
         else
            nelerror('ERROR IN msdl: Spike times longer than stimulus period!!!');
         end
      end
   end
   
   call_user_func(contPlotParams.func,spk,contPlotParams);
   concat_spikes(spk);
   drawnow
   
   if (check_stop_request), break; end  

   %% CHECK if ready to load new stimulus
   if (index>prev_index)  
      number_of_presented_lines = index;
      % Check again for user break before we prepare for the next stimulus
      if (check_stop_request), break; end
      
      %Prepare for next stimulus
      if index==nlines
         if RPget_params(RP(1),'DoneFlag')  % !! Hard coded RP(1)...
            % Last stim has finished (MH: 7/19/02), turn off sound to avoid hearing extra stimuli
            %% These values from: [select,connect,PAattns] = find_mix_settings(NaN*stim_info(1).attens_devices)
            %% But are hard-coded here to avoid 'find_mix_settings.m' warning that nothing will be heard
            rc = PAset(PAattns-PAattns+120);
            rc = SBset([7 7],[0 0]);
            % Note:  not setting end_of_loop_flag here b/c we don't know if the done state was reached before 
            % or after the last time we queried for spikes.  
         end
      end
      call_user_func(endLinePlotParams.func,prev_index,endLinePlotParams);
      %% Match to stimulus actually being played
      call_user_func(dispStatus.func,dispStatus.handle,index,plot_info);
   end
   if (rc ~= 1)
      break;
   end
end % while end_of_loop_flag==0

if (~check_stop_request), beep; end % AF 06/11/02

PAset(PAattns-PAattns+120);
SBset([7 7],[0 0]);
RPhalt(RP);
RPclear(RP);
block_info.fully_presented_stimuli = number_of_presented_stims;
block_info.fully_presented_lines = number_of_presented_lines;
%% This refreshes the contPlot in case it was minimized during loop
call_user_func(contPlotParams.func,{},contPlotParams,[],[],1:nChannels); % Allow contplot to set all the data points.
%%%cleanup
call_user_func(DAL.Inloop.Name);
msdl(0);
SBset([],[]);
if (rc ~= 1)
   nelerror('''STM'': Error(s) detected within stimulus presentation loop');
end

