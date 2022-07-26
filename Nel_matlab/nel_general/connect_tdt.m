% Wrapper function for connecting TDT
% Returns
% ---- (1)activeX if already connected
% ---- (2)connects and then returns activeX if not connected
% TDTmoduleName= {'RP2', 'PA5'}
function varargout= connect_tdt(TDTmoduleName, deviceNumbers, initFlag)

if ~exist('initFlag', 'var')
    initFlag= false;
end

global RX PA RP NelData

varargout= cell(1, 2*numel(deviceNumbers));

for devIter= 1:numel(deviceNumbers)
    TDTout= '';
    status= false;
    
    devNum= deviceNumbers(devIter);
    switch TDTmoduleName
        case {'RP', 'RP2'}
            if devNum <= numel(RP) && (~initFlag)
                TDTout= RP(devNum).activeX;
                status= true;
            elseif initFlag
                TDTout=actxcontrol('RPco.x', [0 0 1 1]);
                status= TDTout.ConnectRP2(NelData.General.TDTcommMode, devNum);
                
                if status
                    RP(devNum).activeX= TDTout;
                end
            end
        case {'PA', 'PA5'}
            if devNum <= numel(PA) && (~initFlag)
                TDTout= PA(devNum).activeX;
                status= true;
            elseif initFlag
                TDTout=actxcontrol('PA5.x', [0 0 1 1]);
                status= TDTout.ConnectPA5(NelData.General.TDTcommMode, devNum);
                
                if status
                    PA(devNum).activeX= TDTout;
                end
            end
        case {'RX', 'RX8'}
            if devNum <= numel(RX) && (~initFlag)
                %TDTout=actxcontrol('RPco.x', [0 0 1 1]);
                TDTout= RX(devNum).activeX;
                status= true;
            elseif initFlag
                TDTout=actxcontrol('RPco.x', [0 0 1 1]);
                status= TDTout.ConnectRX8(NelData.General.TDTcommMode, devNum);
                if status
                    RX(devNum).activeX= TDTout;
                end
            end
    end
    varargout{2*devIter-1}= TDTout;
    varargout{2*devIter}= status == 1;
end