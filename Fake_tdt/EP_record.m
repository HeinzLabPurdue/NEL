function [ep,rc] = EP_record(i_ep, duration, start)
%

% AF 2/19/02

global RP root_dir NelData
persistent EP_device last_index


if (nargin > 1) % Init
   ep = {};
   rc = 1;
   RP(2).sampling_rate = 12207;
   return;
   
%    init_time = clock;
%    if (strcmp(RP(2).rco_file, [root_dir 'stimulate\object\EP_recorder_stm.rco']) == 0) 
%       RP(2).rco_file = [root_dir 'stimulate\object\EP_recorder_stm.rco'];
%       RP(2).params = [];
%       rc = RPprepare(2);
%       if (rc == 0)
%          return;
%       end
%    end
%    EP_device.params.EPdur = duration;
%    EP_device.params.EPstart = start;
%    params.ReadReset = 1;
%    
%    EP_device = struct('params', params ...
%       ,'params_in', [] ...      
%       , 'activeX', RP(2).activeX ...
%       , 'RP_index', 2  ...
%       );
% %    
%    [rc,EP_device] = RPset_params(EP_device);
%    if (rc ~= 0)
%       rc = RPset_params(EP_device,'ReadReset',0);
%    end
%    return;
end

[spk index] = msdl(2);
rc = 1;
if (isempty(last_index) | index ~= last_index)
    sampleLength = NelData.General.EP.lineLength;
%     rand_phase = 2*pi*randn(1,1);
%     ep = {(1 + 0.5*randn(1,1))*(sin(([1:12000]/(12000/(2*pi*20)))+rand_phase) + 0.1*randn(1,12000))};
    ep{1} = (1 + 0.5*randn(1,1))*sin([1:sampleLength]/(sampleLength/(2*pi*20)));
ep{1}(end) = 0;
    last_index = index;
else
    ep = {};
end
   
   
   
