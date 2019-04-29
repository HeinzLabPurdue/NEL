function rc = Pulse_stim(delay, nPulses, interpulse)
%

% GE 26Feb2002

global RP root_dir default_rco
persistent Pulse_device

if (nargin > 0) % Init
   if (strcmp(RP(2).rco_file, [root_dir 'stimulate\object\EP_recorder_stm.rco']) == 0)
      if (strcmp(RP(2).rco_file, default_rco) == 0)
         nelwarn(['Pulse_stim: overriding non-default rco in RP(2) ''' RP(2).rco_file '''']);
      end
      RP(2).rco_file = [root_dir 'stimulate\object\EP_recorder_stm.rco'];
      RP(2).params = [];
      rc = RPprepare(2);
      if (rc == 0)
         return;
      end
   end
   params.stm_flag = 1;
   params.stm_delay = delay;
   params.stm_nPulses = nPulses;
   params.stm_Thi = 1;    % hard-coded value.
   params.stm_Tlo = interpulse - params.stm_Thi;
   
   Pulse_device = struct('params', params ...
      ,'params_in', [] ...      
      , 'activeX', RP(2).activeX ...
      , 'RP_index', 2  ...
      );
   
   [rc,Pulse_device] = RPset_params(Pulse_device);
   return;
end