function vin = PlayCaptureNEL(card, buffdata, dropA, dropB, ADdelay)
f1RP = card.f1RP; 
RP = card.RP; 

%Set the delay of the sound
invoke(RP, 'SetTagVal', 'onsetdel',0); % onset delay is in ms
playrecTrigger = 1;

% if delayComp == 1
%     ADdelay = 344; % Samples was 97 pre 9/12/23, was 70 on 9/12/23
% else
%     ADdelay = 0;
% end

resplength = size(buffdata,2) + ADdelay;

% Set attenuations
rc = PAset([0, 0, dropA, dropB]);
invoke(RP, 'SetTagVal', 'nsamps', resplength);

% Check for clipping
if(any(abs(buffdata(1,:)) > 1) || any(abs(buffdata(2,:)) > 1))
    error('What did you do!? Sound is clipping!! Cannot Continue!!\n');
end

% Load the 2ch variable data:
invoke(RP, 'WriteTagVEX', 'datainL', 0, 'F32', buffdata(1,:));
invoke(RP, 'WriteTagVEX', 'datainR', 0, 'F32', buffdata(2,:));

%Start playing from the buffer:
invoke(RP, 'SoftTrg', playrecTrigger);
currindex = invoke(RP, 'GetTagVal', 'indexin');

while(currindex < resplength)
    currindex=invoke(RP, 'GetTagVal', 'indexin');
end

vin = invoke(RP, 'ReadTagVex', 'dataout', 0, resplength,...
    'F32','F64',1);

ADdelay = max([ADdelay-1, 1]); 
vin = vin((ADdelay):end-2); % was + 1 until 6/28/24 SH, now end -2 to adjust for change

% Get ready for next trial
invoke(RP, 'SoftTrg', 8); % Stop and clear "OAE" buffer
%Reset the play index to zero:
invoke(RP, 'SoftTrg', 5); %Reset Trigger


end