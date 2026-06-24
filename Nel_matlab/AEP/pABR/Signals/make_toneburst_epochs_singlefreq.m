function [leftEpochs, rightEpochs, stimTrain, toneBurst, leftFreqOrder, rightFreqOrder] = ...
    make_toneburst_epochs_singlefreq(frequencies, fs, nEpochs, nStim)

Nepoch = fs;
nFreq = length(frequencies);

% Left goes high → low
leftFreqOrder = sort(frequencies, 'descend');

% Right goes low → high
rightFreqOrder = sort(frequencies, 'ascend');

leftEpochs  = zeros(nEpochs, Nepoch);
rightEpochs = zeros(nEpochs, Nepoch);

toneBurst = struct();
stimTrain = struct();

for e = 1:nEpochs

    leftFreq  = leftFreqOrder(mod(e-1,nFreq) + 1);
    rightFreq = rightFreqOrder(mod(e-1,nFreq) + 1);

    % ----- Left ear -----
    [leftTrain, leftInfo, toneBurst] = make_one_freq_train(leftFreq, fs, Nepoch, nStim, toneBurst);
    leftEpochs(e,:) = leftTrain;

    stimTrain(e,1).frequency = sprintf("%0.0f_Hz", leftFreq);
    stimTrain(e,1).impulseTrain = leftInfo.impulseTrain;
    stimTrain(e,1).stimIdx = leftInfo.stimIdx;
    stimTrain(e,1).polarity = leftInfo.polarity;
    stimTrain(e,1).signal = leftTrain;
    stimTrain(e,1).earLabel = "left";

    % ----- Right ear -----
    [rightTrain, rightInfo, toneBurst] = make_one_freq_train(rightFreq, fs, Nepoch, nStim, toneBurst);
    rightEpochs(e,:) = rightTrain;

    stimTrain(e,2).frequency = sprintf("%0.0f_Hz", rightFreq);
    stimTrain(e,2).impulseTrain = rightInfo.impulseTrain;
    stimTrain(e,2).stimIdx = rightInfo.stimIdx;
    stimTrain(e,2).polarity = rightInfo.polarity;
    stimTrain(e,2).signal = rightTrain;
    stimTrain(e,2).earLabel = "right";
end

end


function [train, info, toneBurst] = make_one_freq_train(freq, fs, Nepoch, nStim, toneBurst)

Tburst = 5/freq;
t = 0:1/fs:Tburst-1/fs;

temp = cos(2*pi*freq*t);
window = blackman(length(temp))';

tone = temp .* window;

fieldName = sprintf("f_%0.0f_Hz", freq);
toneBurst.(fieldName).frequency = sprintf("%0.0f_Hz",freq);
toneBurst.(fieldName).signal = tone;

burstLen = length(tone);
impulseTrain = zeros(1,Nepoch);

validIdx = 1:(Nepoch - burstLen + 1);
stimIdx = validIdx(randperm(length(validIdx), nStim));

polarity = [ones(1,nStim/2), -ones(1,nStim/2)];
polarity = polarity(randperm(nStim));

impulseTrain(stimIdx) = polarity;

train = conv(impulseTrain, tone);
train = train(1:Nepoch);

info.impulseTrain = impulseTrain;
info.stimIdx = stimIdx;
info.polarity = polarity;

end