function [ep,rc, clip_flag] = EP_record(i_ep, duration, start)
%

% AF 2/19/02
% GE 04Apr2002: will need to implement i_ep

global RP root_dir default_rco
persistent EP_device

clip_flag = 0;

if (nargin > 1) % Init
   ep = {};
   if (strcmp(RP(2).rco_file, [root_dir 'stimulate\object\EP_recorder_stm.rco']) == 0) 
      if (strcmp(RP(2).rco_file, default_rco) == 0)
         nelwarn(['EP_record: overriding non-default rco in RP(2) ''' RP(2).rco_file '''']);
      end
      RP(2).rco_file = [root_dir 'stimulate\object\EP_recorder_stm.rco'];
      RP(2).params = [];
      rc = RPprepare(2);
      if (rc == 0)
         return;
      end
   end

   %% Patch start
   params.EPdur = 350;
   params.EPstart = 10;
   EP_device = struct('params', params ...
      ,'params_in', [] ...      
      , 'activeX', RP(2).activeX ...
      , 'RP_index', 2  ...
      );
   [rc,EP_device] = RPset_params(EP_device);
   rc = RPSoftTrig(EP_device,2); % TODO: check the rc
   rc = RPSoftTrig(EP_device,3); % TODO: check the rc
   bufflag = 0;
   while (bufflag == 0)
      bufflag = RPget_params(EP_device,'BufFlag');
   end
   rc = RPSoftTrig(EP_device,2); % TODO: check the rc
   %% Patch end

   EP_device.params.EPdur = duration;
   EP_device.params.EPstart = start;
   [rc,EP_device] = RPset_params(EP_device);
   rc = RPSoftTrig(EP_device,2); % TODO: check the rc
   % rc = RPset_params(EP_device,'ReadReset',0);
   return;
end

bufflag = RPget_params(EP_device,'BufFlag');
if (bufflag == 1)
   ep = {double(RPget_params(EP_device,'ADbuf'))};
   rc = RPSoftTrig(EP_device,2); % TODO: check the rc
   % Check for clipping.  Added by GE 07Jul2003.
   if ( (max(ep{i_ep})>11) | (min(ep{i_ep})<-11) )  % Clipping values are hard-coded at +/- 11 volts for now.
      ep = {};
      clip_flag = 1;
   end
else
   ep = {};
   rc = 1;
end

   
   
   
