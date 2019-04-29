function rc = TRIGset(stim_duration,interstim_interval,stim_num)
%

% AF 8/26/01

global Trigger

if (stim_duration >= interstim_interval)
   nelerror('inter-stimulus interval must be larger than stimulus duration');
   rc = -1;
   return;
end
if (stim_duration < 1 | interstim_interval < 1)
   nelwarn('inter-stimulus interval and stimulus duration are given in msec, and should be larger than 1');
   rc = -2;
   return;
end

Trigger.params.StmOn  = stim_duration;
Trigger.params.StmOff = interstim_interval - stim_duration;
Trigger.params.StmNum = stim_num;
rc = RPset_params(Trigger);
   