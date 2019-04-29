function rc = TRIGstart
%

% AF 8/27/01

global Trigger

rc = invoke(Trigger.activeX,'SoftTrg',1);
if (rc == 0)
   nelerror('''TRIGstart'': Error while sending soft-trigger');
end