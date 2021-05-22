function rc = tdtinit(h)
% TDTINIT conencts to the various TDT devices

% AF 8/22/01

global RP PA RX Trigger SwitchBox NelData

% if (~ishandle(h))
%     h = gcf;
% end

figure(NelData.General.main_handle);

RPtemp= actxcontrol('RPco.x',[0 0 1 1],NelData.General.main_handle);
yesUSB= invoke(RPtemp,'ConnectRP2', 'USB', 1);
yesGB= invoke(RPtemp,'ConnectRP2', 'GB', 1);
if yesUSB && ~yesGB
    NelData.General.TDTcommMode= 'USB';
elseif yesGB && ~yesUSB
    NelData.General.TDTcommMode= 'GB';
end

% Assuming RP2s only: will be different for RX8
% Check how many RP2s
initFlag= true;
[~, yesRP2_1]= connect_tdt('RP2', 1, initFlag);
[~, yesRP2_2]= connect_tdt('RP2', 2, initFlag);
[~, yesRP2_3]= connect_tdt('RP2', 3, initFlag);
[~, yesRP2_4]= connect_tdt('RP2', 4, initFlag);
% yesRP1=invoke(RPtemp,'ConnectRP2', NelData.General.TDTcommMode, 1);
% yesRP2=invoke(RPtemp,'ConnectRP2', NelData.General.TDTcommMode, 2);
% yesRP3=invoke(RPtemp,'ConnectRP2', NelData.General.TDTcommMode, 3);
% yesRP4=invoke(RPtemp,'ConnectRP2', NelData.General.TDTcommMode, 4);

[~, yesPA5(1)]= connect_tdt('PA5', 1, initFlag);
[~, yesPA5(2)]= connect_tdt('PA5', 2, initFlag);
[~, yesPA5(3)]= connect_tdt('PA5', 3, initFlag);
[~, yesPA5(4)]= connect_tdt('PA5', 4, initFlag);


if (yesRP2_1&&yesRP2_2) && (yesRP2_3&&yesRP2_4) % All RP2s are connected
    NelData.General.RP2_3and4= true; % RP2 #3 and #4 are connected
elseif (yesRP2_1&&yesRP2_2) && ~(yesRP2_3||yesRP2_4) % RP2s (1 and 2) connected, 3 and 4 do not exist
    NelData.General.RP2_3and4= false; % RP2 #3 and #4 do are not connected
else % Why is this happening
    NelData.General.RP2_3and4= nan; % Error
end

[~, yesRX8]= connect_tdt('RX8', 1, initFlag);
% yesRX8=invoke(RPtemp,'ConnectRX8', NelData.General.TDTcommMode, 1);
if yesRX8
    NelData.General.RX8= true; % RX8 is connected
else
    NelData.General.RX8= false; % RX8 is connected
    clear global RX;
end


%% Old stuff
rc = 1;
for i = 1:length(RP)
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
