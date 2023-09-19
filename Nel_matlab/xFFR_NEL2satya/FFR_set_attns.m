% ear = binary (10 (L), 01 (R) or 11 (both))
function rc = FFR_set_attns(attn,noiseLevel,ear,kh_flag,RPco1,RPco2)
% FFR_set_attns - temporary patch for the FFR program to set the select, connect
%                    and attenuations.
% AF 4/1/02

global devices_names_vector FIG

% Delay to wait for stim off (falling edge of trigger) before setting attens  MH/GE 10Nov2003
% Stage: 1: high; 2: low

% SP - stuck in infy loop after rerun. So, added skipFlag
if exist('RPco1','var')
    while (double(invoke(RPco1,'GetTagVal', 'Stage')) == 2) %ge debug
        if (strcmp(get(FIG.push.run_levels, 'Userdata'), 'abort'))
            break; % break doesn't work
        end
    end
    
    while (double(invoke(RPco1,'GetTagVal', 'Stage')) == 1) %ge debug
        if (strcmp(get(FIG.push.run_levels, 'Userdata'), 'abort'))
            break; % break doesn't work
        end
    end
end

%%
% rc = 1;
if ((kh_flag==2) && ~isempty(strcmp('KH-oscillator', devices_names_vector)))
    devices = nel_devices_vector('kh');
    disp(num2str(devices));
else
    devices_tone = nel_devices_vector({'1.1'});
    devices_masker = nel_devices_vector({'1.2'});
end
attens_devices = nan(length(devices_tone),2);
if (bitget(ear,1)) % Left
    %    attens_devices(:,2) = devices_tone;
    attens_devices(~isnan(devices_masker),2) = attn-noiseLevel;
    attens_devices(~isnan(devices_tone),2) = attn;
end
if (bitget(ear,2)) % Right
    attens_devices(~isnan(devices_masker),1) = attn-noiseLevel;
    attens_devices(~isnan(devices_tone),1) = attn;
end
% attens_devices = attn * attens_devices;
% attens_devices = [[NaN NaN NaN NaN NaN NaN NaN NaN NaN]' [NaN NaN NaN NaN NaN attn attn-noiseLevel NaN NaN]'];  %KHZZ
% attens_devices = [[NaN NaN NaN NaN NaN attn attn-noiseLevel NaN NaN]' [NaN NaN NaN NaN NaN NaN NaN NaN NaN]'];  %KHZZ
[select,connect,PAattns] = find_mix_settings(attens_devices);
if (isempty(select))
    % nelerror('FFR: can''t find proper select/connect configuration');
    rc = 0;
    return;
end


%connect=[1 0];
%select=[1 7];
if (exist('RPco1','var') == 1)
    PAset(120.0);
    invoke(RPco1,'SetTagVal','Select_L',select(1));
    invoke(RPco1,'SetTagVal','Connect_L',connect(1));
    invoke(RPco2,'SetTagVal','Select_R',select(2));
    invoke(RPco2,'SetTagVal','Connect_R',connect(2));
end

%PAattns=[0 0 25 35];
rc = PAset(PAattns);
