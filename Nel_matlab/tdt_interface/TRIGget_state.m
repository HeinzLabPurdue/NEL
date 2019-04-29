function [state,count_down] = TRIGget_state
%

% AF 8/26/01

global Trigger

Trigger = RPget_params(Trigger);
state = Trigger.params_in.Stage; % Yes, 'Stage' is the name in the rco.
count_down = Trigger.params_in.CurN;