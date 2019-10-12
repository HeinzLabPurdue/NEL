function rc = tdtinit(h)
% TDTINIT conencts to the various TDT devices

% AF 8/22/01

global RP PA Trigger SwitchBox NelData

if (~ishandle(h))
   h = gcf;
end
rc = 1;
for i = 1:length(RP)
    RP(i).activeX = actxcontrol('RPco.x',[0 0 1 1],h);
    if (invoke(RP(i).activeX,'ConnectRP2', NelData.General.TDTcommMode,i) == 0)
        nelerror(['Failed to connect to RP2 #' int2str(i)]);
        rc = 0;
    end
    SwitchBox(i).activeX = RP(i).activeX;
end
Trigger.activeX = RP(Trigger.RP_index).activeX; 

for i = 1:length(PA)
    PA(i).activeX = actxcontrol('PA5.x',[0 0 1 1],h);
    if (invoke(PA(i).activeX,'ConnectPA5', NelData.General.TDTcommMode, i) == 0)
        nelerror(['Failed to connect to PA #' int2str(i)]);
        rc = 0;
    end
end
PAset(120.0);
SBset([],[]);
