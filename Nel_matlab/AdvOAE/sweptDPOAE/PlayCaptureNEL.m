function vins = PlayCaptureNEL(buffdata, dropA, dropB, delayComp)

%Set the delay of the sound
invoke(RP, 'SetTagVal', 'onsetdel',0); % onset delay is in ms
playrecTrigger = 1;

if delayComp == 1
    ADdelay = 97; % Samples
else
    ADdelay = 0;
end

resplength = size(buffdata,2) + ADdelay;

% Set attenuations
rc = PAset([0, 0, dropA, dropB]);
invoke(RP, 'SetTagVal', 'nsamps', resplength);

% Check for clipping
if(any(abs(buffdata(1,:)) > 1) || any(abs(buffdata(2,:)) > 1))
    error('What did you do!? Sound is clipping!! Cannot Continue!!\n');
end

% Load the 2ch variable data:
invoke(RP, 'WriteTagVEX', 'datainL', 0, 'F32', buffdataA);
invoke(RP, 'WriteTagVEX', 'datainR', 0, 'F32', buffdataB);

%Start playing from the buffer:
invoke(RP, 'SoftTrg', playrecTrigger);
currindex = invoke(RP, 'GetTagVal', 'indexin');

while(currindex < resplength)
    currindex=invoke(RP, 'GetTagVal', 'indexin');
end

vin = invoke(RP, 'ReadTagVex', 'dataout', 0, resplength,...
    'F32','F64',1);

vins = vin((ADdelay + 1):end);

% Get ready for next trial
invoke(RP, 'SoftTrg', 8); % Stop and clear "OAE" buffer
%Reset the play index to zero:
invoke(RP, 'SoftTrg', 5); %Reset Trigger


end