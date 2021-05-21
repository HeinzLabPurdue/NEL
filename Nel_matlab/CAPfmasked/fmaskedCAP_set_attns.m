function rc = fmaskedCAP_set_attns(attn_p, attn_m, ear,kh_flag,RPco1,RPco2)
% fmaskedCAP_set_attns -  patch for the CAP program to set the select, connect
%                    and attenuations.  attn_p : attenuation probe, attn_m:
%                    attenuation masker

% AF 4/1/02

global devices_names_vector Trigger FIG

%attn=attn_p;

% Delay to wait for stim off (falling edge of trigger) before setting attens  MH/GE 10Nov2003
% Stage: 1: high; 2: low
% if (exist('RPco1','var'))
%    while (double(invoke(RPco1,'GetTagVal', 'Stage')) == 2)  %ge debug
%       if (strcmp(get(FIG.push.run_levels, 'Userdata'), 'abort')), break; end  
%    end
%    while (double(invoke(RPco1,'GetTagVal', 'Stage')) == 1)  %ge debug
%       if (strcmp(get(FIG.push.run_levels, 'Userdata'), 'abort')), break; end  
%    end
% end
   
rc = 1;
if ((kh_flag==2) & ~isempty(strmatch('KH-oscillator', devices_names_vector,'exact')))
   devices = nel_devices_vector('kh');
else
   %devices = nel_devices_vector('1.1');
   devices = nel_devices_vector({'1.1', '1.2'});
   devices_p = nel_devices_vector({'1.1'});
   devices_m = nel_devices_vector({'1.2'});
end
attens_devices = repmat(NaN,length(devices),2);
if (bitget(ear,1)) % Left
   attens_devices(:,2) = devices;
end
if (bitget(ear,2)) % Right
   attens_devices(:,1) = devices;
end
%attens_devices = attn * attens_devices;
attens_devices = (attn_m * (1- isnan(devices_m)) + attn_p*(1- isnan(devices_p)) ).*attens_devices; 
[select,connect,PAattns] = find_mix_settings(attens_devices);
if (isempty(select))
   % nelerror('CAP: can''t find proper select/connect configuration');
   rc = 0;
   return;
end
if (exist('RPco1','var') == 1)
   fmaskedCAP_PAset(120.0);
   invoke(RPco1,'SetTagVal','Select_L',select(1));
   invoke(RPco1,'SetTagVal','Connect_L',connect(1));
   invoke(RPco2,'SetTagVal','Select_R',select(2));
   invoke(RPco2,'SetTagVal','Connect_R',connect(2));
end
rc = fmaskedCAP_PAset(PAattns);


