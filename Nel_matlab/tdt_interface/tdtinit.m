function rc = tdtinit(h)
% TDTINIT conencts to the various TDT devices

% AF 8/22/01

%%
global RX RP PA Trigger SwitchBox
global default_rco devices_names_vector hardwired_devices NelData
% AF FA 6/24/24 add VERSION
global VERSION

params = struct('StmOn', 0 ...
   , 'StmOff', 0 ...
   , 'StmNum', 0 ...
   );
paramsin = struct('Stage', 0 ...
   , 'CurN', 0 ...
   );
Trigger = struct('params', params ...
   , 'params_in', paramsin  ...
   , 'activeX', [] ...
   , 'RP_index', 1  ...
   );

% One important issue!!! The Ground option (in select_key, select_res1 and select_res2) should always be the last option!
% If you want to change this convention, please make the appropriate changes in SBfind_route.
select_key  = [          2                    0                     1                    4                    5                     3                    6                    7           ];
select_res1 = [ [0 0 0 0 1 0 0 0 0]' [0 0 0 0 0 1 0 0 0]'  [0 0 0 0 0 1 1 0 0]'  [0 0 0 0 0 0 0 1 0]' [0 0 0 0 0 0 0 0 1]' [0 1 0 0 0 0 0 0 0]' [1 0 0 0 0 0 0 0 0]' [0 0 0 0 0 0 0 0 0]' ];
select_res2 = [ [0 0 0 0 1 0 0 0 0]' [0 0 0 0 0 0 0 1 0]'  [0 0 0 0 0 0 0 1 1]'  [0 0 0 0 0 1 0 0 0]' [0 0 0 0 0 0 1 0 0]' [0 0 0 1 0 0 0 0 0]' [0 0 1 0 0 0 0 0 0]' [0 0 0 0 0 0 0 0 0]'];
% Element order for select_res is: L6  L3  R6  R3  KH-oscillator  RP1-ch1 RP1-ch2 RP2-ch1 RP2-ch2
connect_key  = [  0      2       1      3   ];
connect_res1 = [[0 0]' [0 1]', [1 0]' [1 1]'];
connect_res2 = [[0 0]' [0 1]', [1 0]' [1 1]'];
% Element order for connect_res is: Left-channel  Right-channel

devices_names_vector = {'L6'  'L3'  'R6'  'R3'  'KH-oscillator' 'RP1-ch1' 'RP1-ch2' 'RP2-ch1' 'RP2-ch2'};
hardwired_devices    = [  0     0     0     0         0            0         0        0         0    ];

params = struct('BitOut3_7', -1 ...
   );
SwitchBox = struct('select_key',{select_key select_key} ...
   , 'select_res', {select_res1 select_res2} ...  
   , 'connect_key',{connect_key} ...
   , 'connect_res', {connect_res1 connect_res2} ...  
   , 'params', {params params} ...
   , 'prev_params', {params params} ...
   , 'activeX', {[] []} ...
   );
%% 

% if (~ishandle(h))
%     h = gcf;
% end

%figure(NelData.General.main_handle);
%toAppDesignerTag - creating a dummy figure to allow actxcontrol to work...
rp_temp_fig_forActiveX = figure();  % creates figure(1) - need to be careful not to delete 
set(rp_temp_fig_forActiveX, 'Visible','off')

%RPtemp= actxcontrol('RPco.x',[0 0 1 1],NelData.General.main_handle);
RPtemp= actxcontrol('RPco.x',[0 0 1 1],rp_temp_fig_forActiveX);
yesUSB= invoke(RPtemp,'ConnectRP2', 'USB', 1);
yesGB= invoke(RPtemp,'ConnectRP2', 'GB', 1);

if yesUSB && ~yesGB
    NelData.General.TDTcommMode= 'USB';
elseif yesGB && ~yesUSB
    NelData.General.TDTcommMode= 'GB';
end

%% RP2s 
% Assuming RP2s only: will be different for RX8
% Check how many RP2s
initFlag= true;
[~, yesRP2_1]= connect_tdt('RP2', 1, initFlag);
[~, yesRP2_2]= connect_tdt('RP2', 2, initFlag);
[~, yesRP2_3]= connect_tdt('RP2', 3, initFlag);
[~, yesRP2_4]= connect_tdt('RP2', 4, initFlag);

% Initialize other field of the structure RP that used to be defined in the
% function hardware_setup_default
temp_serNum= num2cell(1:numel(RP));
[RP.('params')]= deal([]);
[RP.('params_in')]= deal([]);
[RP.('serial_no')]= temp_serNum{:};
[RP.('nchannels')]= deal(2);
[RP.('peak_amp_volt')]= deal(5);
[RP.('sampling_rate')]= deal(0);
[RP.('cycle_usage')]= deal(0);

%% PS5s 
[~, yesPA5(1)]= connect_tdt('PA5', 1, initFlag);
[~, yesPA5(2)]= connect_tdt('PA5', 2, initFlag);
[~, yesPA5(3)]= connect_tdt('PA5', 3, initFlag);
[~, yesPA5(4)]= connect_tdt('PA5', 4, initFlag);

temp_serNum= num2cell(1:numel(PA));
[PA.('attn')]= deal(-1);
[PA.('serial_no')]= temp_serNum{:};

%%

if (yesRP2_1&&yesRP2_2) && (yesRP2_3&&yesRP2_4) % All RP2s are connected
    NelData.General.RP2_3and4= true; % RP2 #3 and #4 are connected
elseif (yesRP2_1&&yesRP2_2) && ~(yesRP2_3||yesRP2_4) % RP2s (1 and 2) connected, 3 and 4 do not exist
    NelData.General.RP2_3and4= false; % RP2 #3 and #4 do are not connected
else % Why is this happening
    NelData.General.RP2_3and4= nan; % Error
end

%%
[~, yesRX8]= connect_tdt('RX8', 1, initFlag);
% yesRX8=invoke(RPtemp,'ConnectRX8', NelData.General.TDTcommMode, 1);
if yesRX8
    NelData.General.RX8= true; % RX8 is connected
    
    temp_serNum= num2cell(1:numel(RX));
    [RX.('params')]= deal([]);
    [RX.('params_in')]= deal([]);
    [RX.('serial_no')]= temp_serNum{:};
    [RX.('nchannels')]= deal(2); % by SP: not sure if this should be 2: Ask MH (5.23.2021)
    [RX.('peak_amp_volt')]= deal(5);
    [RX.('sampling_rate')]= deal(0);
    [RX.('cycle_usage')]= deal(0);
    
else
    NelData.General.RX8= false; % RX8 is connected
end

% AF,FA  add which NEL to Version  6/24/24

    if NelData.General.RP2_3and4
        VERSION = 'NEL1';
    elseif NelData.General.RX8
        VERSION = 'NEL2';
    end


%% Old stuff
rc = 1;
for i = 1:2 %length(RP)
    %     RP(i).activeX = actxcontrol('RPco.x',[0 0 1 1],h);
    %     if (invoke(RP(i).activeX,'ConnectRP2', NelData.General.TDTcommMode,i) == 0)
    %         nelerror(['Failed to connect to RP2 #' int2str(i)]);
    %         rc = 0;
    %     end
    SwitchBox(i).activeX = RP(i).activeX;
end
Trigger.activeX = RP(Trigger.RP_index).activeX;

% for i = 1:length(PA)
%     PA(i).activeX = actxcontrol('PA5.x',[0 0 1 1],h);
%     if (invoke(PA(i).activeX,'ConnectPA5', NelData.General.TDTcommMode, i) == 0)
%         nelerror(['Failed to connect to PA #' int2str(i)]);
%         rc = 0;
%     end
% end
if all(yesPA5)
    PAset(120.0);
end

SBset([],[]);
