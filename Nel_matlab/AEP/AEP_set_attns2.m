function rc = AEP_set_attns2(attn,ear,attn2,ear2,kh_flag,RPco1,RPco2)
% CAP_set_attns - temporary patch for the CAP program to set the select, connect
%                    and attenuations.

% AF 4/1/02

global devices_names_vector Trigger FIG


% Delay to wait for stim off (falling edge of trigger) before setting attens  MH/GE 10Nov2003
% Stage: 1: high; 2: low
if (exist('RPco1','var'))
   while (double(invoke(RPco1,'GetTagVal', 'Stage')) == 2)  %ge debug
      if (strcmp(get(FIG.push.run_levels, 'Userdata'), 'abort')), break; end  
   end
   while (double(invoke(RPco1,'GetTagVal', 'Stage')) == 1)  %ge debug
      if (strcmp(get(FIG.push.run_levels, 'Userdata'), 'abort')), break; end  
   end
end
   
rc = 1;
%% Signal 1 is on RP1.1; Signal 2 is on RP1.2
devices = nel_devices_vector('1.1');
row1=find(~isnan(devices));
devices2 = nel_devices_vector('1.2');
row2=find(~isnan(devices2));
attens_devices = NaN(length(devices),2);
%% Signal 1 is on RP1.1; Signal 2 is on RP1.2
if (bitget(ear,1)) % Right
   attens_devices(row1,2) = attn;
end
if (bitget(ear,2)) % Left
   attens_devices(row1,1) = attn;
end
if ~isnan(ear2)
    if (bitget(ear2,1)) % Right
        attens_devices(row2,2) = attn2;
    end
    if (bitget(ear2,2)) % Left
        attens_devices(row2,1) = attn2;
    end
end
% attens_devices = attn * attens_devices;
[select,connect,PAattns] = find_mix_settings(attens_devices);

%hopefully works AS/MH/SH - 03/17/2023
if(~bitget(ear,1)&&~bitget(ear2,1)) %Right
    %set left PA5-3 to 120 attn
    PAattns(4) = 120;
end
if(~bitget(ear,2)&&~bitget(ear2,2)) %Left
    PAattns(3) = 120;
end

if (isempty(select))
   % nelerror('CAP: can''t find proper select/connect configuration');
   rc = 0;
   return;
end
if (exist('RPco1','var') == 1)
   PAset(120);
   invoke(RPco1,'SetTagVal','Select_L',select(1));
   invoke(RPco1,'SetTagVal','Connect_L',connect(1));
   invoke(RPco2,'SetTagVal','Select_R',select(2));
   invoke(RPco2,'SetTagVal','Connect_R',connect(2));
end
rc = PAset(PAattns);


