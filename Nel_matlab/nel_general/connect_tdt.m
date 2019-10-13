% Wrapper function for connecting TDT
% Returns
% ---- (1)activeX if already connected
% ---- (2)connects and then returns activeX if not connected
% TDTmoduleName= {'RP2', 'PA5'}
function varargout= connect_tdt(TDTmoduleName, deviceNumbers)

global PA RP NelData 

varargout= cell(1, 2*numel(deviceNumbers));

for devIter= 1:numel(deviceNumbers)
    devNum= deviceNumbers(devIter);
    switch TDTmoduleName
        case {'RP', 'RP2'}
            if devNum <= numel(RP)
                TDTout= RP(devNum).activeX;
                status= true;
            else
                TDTout=actxcontrol('RPco.x', [0 0 1 1]);
                status= TDTout.ConnectRP2(NelData.General.TDTcommMode, devNum);
                RP(devNum).activeX= TDTout;
            end
        case {'PA', 'PA5'}
            if devNum <= numel(PA)
                TDTout= PA(devNum).activeX;
                status= true;
            else
                TDTout=actxcontrol('PA5.x', [0 0 1 1]);
                status= TDTout.ConnectPA5(NelData.General.TDTcommMode, devNum);
                PA(devNum).activeX= TDTout;
            end
    end
    varargout{2*devIter-1}= TDTout;
    varargout{2*devIter}= status;
end