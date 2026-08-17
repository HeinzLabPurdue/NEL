function rc = pABR_set_attns(attn,ear,attn2,ear2,kh_flag,RPco1,RPco2)
% AEP_set_attns2
%
% Routes no more than one signal to each ear.
%
% Signal 1: RP1.1
% Signal 2: RP1.2
%
% Ear coding:
%   1 = Right
%   2 = Left
%   3 = Both
%
% If both signals request the same ear, Signal 1 has priority and
% Signal 2 is disconnected from that ear.

global devices_names_vector Trigger FIG

%% Wait until stimulus has turned off before changing routing
% Stage 1 = stimulus ON
% Stage 2 = stimulus OFF

if exist('RPco1','var')

    while double(invoke(RPco1,'GetTagVal','Stage')) == 2
        if strcmp(get(FIG.push.run_levels,'Userdata'),'abort')
            break;
        end
    end

    while double(invoke(RPco1,'GetTagVal','Stage')) == 1
        if strcmp(get(FIG.push.run_levels,'Userdata'),'abort')
            break;
        end
    end
end

rc = 1;

%% Identify Signal 1 and Signal 2 devices
devices = nel_devices_vector('1.1');
row1 = find(~isnan(devices));

devices2 = nel_devices_vector('1.2');
row2 = find(~isnan(devices2));

% Columns:
%   column 1 = Left ear
%   column 2 = Right ear
attens_devices = NaN(length(devices),2);

%% Route Signal 1
if bitget(ear,1)                     % Right
    attens_devices(row1,2) = attn;
end

if bitget(ear,2)                     % Left
    attens_devices(row1,1) = attn;
end

%% Route Signal 2
% Signal 2 can use an ear only if Signal 1 is not already using it.

if ~isnan(ear2)

    if bitget(ear2,1) && ~bitget(ear,1)    % Right
        attens_devices(row2,2) = attn2;
    end

    if bitget(ear2,2) && ~bitget(ear,2)    % Left
        attens_devices(row2,1) = attn2;
    end
end

%% Determine switch and attenuator settings
[select,connect,PAattns] = find_mix_settings(attens_devices);

if isempty(select)
    rc = 0;
    return;
end

%% Mute ears that are not being used
rightEarActive = any(~isnan(attens_devices(:,2)));
leftEarActive  = any(~isnan(attens_devices(:,1)));

if ~rightEarActive
    PAattns(4) = 120;
end

if ~leftEarActive
    PAattns(3) = 120;
end

%% Apply routing
if exist('RPco1','var') == 1

    % Mute outputs while changing the switches
    PAset(120);

    invoke(RPco1,'SetTagVal','Select_L', select(1));
    invoke(RPco1,'SetTagVal','Connect_L',connect(1));

    invoke(RPco2,'SetTagVal','Select_R', select(2));
    invoke(RPco2,'SetTagVal','Connect_R',connect(2));
end

%% Apply final attenuation values
rc = PAset(PAattns);

end