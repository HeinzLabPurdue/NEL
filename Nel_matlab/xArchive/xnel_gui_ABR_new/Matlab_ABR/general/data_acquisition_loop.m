function data_acquisition_loop(stim_params, trig_param, SB_params, user_params)
%

% AF 8/24/01

% 1. Standard GUI will update the trig_parms and SB_params directly to the global variales
%    while enabling the user to modify them at will?

global RP PA Trigger SwitchBox

% Init 
spike_times = zeros(100000,2);
last_spike = 0;
if (RPprepare == 0)
   return;
end
DAL_params.preloop_func = call_user_func(DAL_params.preloop_func);
tspan = Trigger.params.StmOn / 1000;
nstim = Trigger.params.StmNum;
if (~isempty(DAL_params.inloop_func.cycle))
   inloop_cycle = DAL_params.inloop_func.cycle;
else
   inloop_cycle = nstim+1;
end

[seq time] = msds(1,1,1,0);clear msds;pack;[seq time] = msds(1,1,1,1);
[seq time] = msds(1,tspan,nstim,1); 
last_stage = 0;
current_sequence = 0;
%% Prepare first stimulus
DAL_params.inloop_func.params.seq = currnet_sequence+1;
DAL_params.inloop_func = call_user_func(DAL_params.inloop_func);

TRIGstart;
while (currnet_sequence <= nstim)
   [seq time] = msds(1,tspan,nstim,2);
   spk_locs = find((seq <= nstim) & (max(seq) ~= 0) & (max(time) > 0));
   spk_num = length(spk_locs);
   if (spk_num > 0)  % new spikes detected
      if (~isempty(DAL_params.plot_func.name))
         DAL_params.plot_func = call_user_func(DAL_params.plot_func);
      else
         set(h_line1,'xdata',time(spk_locs),'ydata',stm_lst(seq(spk_locs))); 
      end
      spike_times(last_spike+1:last_spike+spk_num,1)=seq(spk_locs)';
      spike_times(last_spike+1:last_spike+spk_num,2)=time(spk_locs)';
      last_spike = last_spike+spk_num;
   end
   
   current_sequence = max(seq);
   stage = TRIGget_stage;
   if (stage == 2 & last_stage == 1)
      if (current_sequence < nstim & mod(current_sequence,inloop_cycle)) 
         % Prepare next stimulus
         DAL_params.inloop_func.params.seq = currnet_sequence+1;
         DAL_params.inloop_func = call_user_func(DAL_params.inloop_func);
      end
   end
end
      


   