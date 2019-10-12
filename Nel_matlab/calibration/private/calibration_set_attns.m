function rc = calibration_set_attns(attn,ear)
%calibration_set_attns - temporary patch for the search program to set the select, connect
%                    and attenuations.

% AF 4/1/02
% BJM 8/9/02

global devices_names_vector COMM

rc = 1;

kh_flag = 0;
if ((kh_flag==2) && ~isempty(strmatch('KH-oscillator', devices_names_vector,'exact')))
   devices = nel_devices_vector('kh');
else
   devices = nel_devices_vector('1.1');
end

attens_devices = NaN(length(devices),2);
if (bitget(ear,1)) % Left
   attens_devices(:,2) = devices;
end
if (bitget(ear,2)) % Right
   attens_devices(:,1) = devices;
end
attens_devices = attn * attens_devices;
[select,connect,PAattns] = find_mix_settings(attens_devices);
if (isempty(select))
   % nelerror('Search: can''t find proper select/connect configuration');
   rc = 0;
   return;
end
if (exist('COMM.handle.RP2_1','var') == 1)
   PAset(120);
   invoke(COMM.handle.RP2_1,'SetTagVal','Select_L',select(1));
   invoke(COMM.handle.RP2_1,'SetTagVal','Connect_L',connect(1));
   invoke(COMM.handle.RP2_2,'SetTagVal','Select_R',select(2));
   invoke(COMM.handle.RP2_2,'SetTagVal','Connect_R',connect(2));
end
rc = PAset(PAattns);
