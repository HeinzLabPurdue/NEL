function rc = search_set_attns(attn,ear,kh_flag,RPco1,RPco2)
% search_set_attns - temporary patch for the search program to set the select, connect
%                    and attenuations.
% AF 4/1/02

global devices_names_vector FIG;

% rc = 1;
% if ((kh_flag==2) && ~isempty(strmatch('KH-oscillator', devices_names_vector,'exact')))
%    devices = nel_devices_vector('kh');
% else
%    devices = nel_devices_vector('1.1');
% end
%M Sayles 2017 - modified to take the KH OSc input from ADC channel 1 on
%RP1.1 instead of through the back panel of the switchbox.
if FIG.radio.binauralbeat.Value && FIG.radio.both.Value
    devices = nan(9,2);
    devices(6,1) =1;
    devices(7,2) =1;
else
    devices = nel_devices_vector('1.1');
end
attens_devices = NaN(length(devices),2);
if FIG.radio.binauralbeat.Value && FIG.radio.both.Value
    attens_devices = devices;
else
    if (bitget(ear,1)) % Left
        attens_devices(:,2) = devices;
    end
    if (bitget(ear,2)) % Right
        attens_devices(:,1) = devices;
    end
end
attens_devices = attn * attens_devices;
[select,connect,PAattns] = find_mix_settings(attens_devices);
if (isempty(select))
   % nelerror('Search: can''t find proper select/connect configuration');
   rc = 0;
   return;
end
if (exist('RPco1','var') == 1)
   PAset(120.0);
   invoke(RPco1,'SetTagVal','Select_L',select(1));
   invoke(RPco1,'SetTagVal','Connect_L',connect(1));
   invoke(RPco2,'SetTagVal','Select_R',select(2));
   invoke(RPco2,'SetTagVal','Connect_R',connect(2));
end
%% Added 2017 Mark Sayles
if all(isnan(attens_devices(:,1)))
    PAattns(3) = 120;
elseif all(isnan(attens_devices(:,2)))
    PAattns(4) = 120;
end
%% 
rc = PAset(PAattns);

