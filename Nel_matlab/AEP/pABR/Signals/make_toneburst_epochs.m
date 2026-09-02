function pABRstim = make_toneburst_epochs( ...
    frequencies,fs,nEpochs,nStim, ...
    calibRight,calibLeft,desiredSpl)
% MAKE_TONEBURST_EPOCHS
%
% Generates independently randomized pABR tone-burst trains.
%
% Right-ear stimuli are scaled using calibRight.
% Left-ear stimuli are scaled using calibLeft.
%
% Ear convention:
%   ear = 1 -> right
%   ear = 2 -> left
%
% Inputs
%   frequencies : stimulus frequencies in Hz
%   fs          : sampling frequency in Hz
%   nEpochs     : number of randomized epochs
%   nStim       : tone bursts per frequency per epoch
%   calibRight  : right-ear inverse calibration [frequency, maximum SPL]
%   calibLeft   : left-ear inverse calibration [frequency, maximum SPL]
%   desiredSpl  : reference level used during waveform scaling
%
% Author: John Love
% Reference: Ross and Polonenko, parallel ABR

%% Input checks

frequencies = frequencies(:).';

if mod(nStim,2) ~= 0
    error('nStim must be even so positive and negative polarities are equal.');
end

if size(calibRight,2) < 2
    error('calibRight must contain frequency and SPL columns.');
end

if size(calibLeft,2) < 2
    error('calibLeft must contain frequency and SPL columns.');
end

calibRight = double(calibRight(:,1:2));
calibLeft  = double(calibLeft(:,1:2));

%% General parameters

pad_ms = 50;

Nepoch = round(fs);
padN = round((pad_ms/1000)*fs);
paddedNepoch = Nepoch + 2*padN;

nEars = 2;
nFreq = numel(frequencies);

earLabel = ["right","left"];

%% Obtain calibration SPL at every stimulus frequency

calibSPLRight = zeros(1,nFreq);
calibSPLLeft  = zeros(1,nFreq);

for i = 1:nFreq
    calibSPLRight(i) = ...
        getcalibMax(frequencies(i),calibRight);

    calibSPLLeft(i) = ...
        getcalibMax(frequencies(i),calibLeft);
end

%% Calculate independent right- and left-ear scaling

rawScaleRight = ...
    10.^((desiredSpl-calibSPLRight)/20);

rawScaleLeft = ...
    10.^((desiredSpl-calibSPLLeft)/20);

% Preserve the original pABR scaling convention independently for each ear.
%
% The frequency with the greatest calibrated output receives a scale of 1.
% Other frequencies are increased relative to that reference.

[minimumRightScale,rightReferenceIndex] = min(rawScaleRight);
[minimumLeftScale,leftReferenceIndex]   = min(rawScaleLeft);

scaleAdjRight = rawScaleRight/minimumRightScale;
scaleAdjLeft  = rawScaleLeft/minimumLeftScale;

% Maximum output represented by a scale of 1 for each ear
maxSPLRight = calibSPLRight(rightReferenceIndex);
maxSPLLeft  = calibSPLLeft(leftReferenceIndex);

fprintf('\n--- pABR calibration ---\n');

fprintf('Right-ear maximum SPL: %.2f dB SPL\n', ...
    maxSPLRight);

fprintf('Left-ear maximum SPL:  %.2f dB SPL\n', ...
    maxSPLLeft);

for i = 1:nFreq
    fprintf(['%5.0f Hz: right calibration = %7.2f dB, ' ...
             'right scale = %8.4f | ' ...
             'left calibration = %7.2f dB, ' ...
             'left scale = %8.4f\n'], ...
        frequencies(i), ...
        calibSPLRight(i),scaleAdjRight(i), ...
        calibSPLLeft(i),scaleAdjLeft(i));
end

%% Allocate output arrays

rightEpochs = zeros(nEpochs,paddedNepoch);
leftEpochs  = zeros(nEpochs,paddedNepoch);

toneBurst = struct();
stimTrain = struct();

%% Generate randomized epochs

for e = 1:nEpochs

    epoch = zeros(nEars,Nepoch);

    for ear = 1:nEars

        Label = earLabel(ear);

        for i = 1:nFreq

            freq = frequencies(i);

            %% Generate five-cycle tone burst

            Tburst = 5/freq;
            nBurstSamples = round(Tburst*fs);

            t = (0:nBurstSamples-1)/fs;

            carrier = cos(2*pi*freq*t);

            if ear == 1
                % Right ear uses right-ear calibration
                scaledCarrier = ...
                    scaleAdjRight(i)*carrier;
            else
                % Left ear uses left-ear calibration
                scaledCarrier = ...
                    scaleAdjLeft(i)*carrier;
            end

            burstWindow = blackman(nBurstSamples).';
            tone = scaledCarrier.*burstWindow;

            burstLen = numel(tone);

            %% Ensure the tone burst fits inside the epoch

            nValidLocations = Nepoch-burstLen+1;

            if nStim > nValidLocations
                error(['nStim exceeds the number of valid tone-burst ' ...
                       'locations for %.0f Hz.'],freq);
            end

            %% Generate randomized impulse train

            impulseTrain = zeros(1,Nepoch);

            validIdx = 1:nValidLocations;

            randomizedLocations = ...
                randperm(nValidLocations,nStim);

            stimIdx = validIdx(randomizedLocations);

            %% Generate balanced randomized polarity

            polarity = [ ...
                ones(1,nStim/2), ...
               -ones(1,nStim/2)];

            polarity = polarity(randperm(nStim));

            impulseTrain(stimIdx) = polarity;

            %% Convolve impulse train with tone burst

            train = conv(impulseTrain,tone);
            train = train(1:Nepoch);

            %% Store tone-burst information

            toneBurst(ear,i).frequency = ...
                sprintf('%0.0f_Hz',freq);

            toneBurst(ear,i).frequency_Hz = freq;
            toneBurst(ear,i).earLabel = Label;
            toneBurst(ear,i).signal = tone;

            if ear == 1
                toneBurst(ear,i).calibMaxSPL = ...
                    calibSPLRight(i);

                toneBurst(ear,i).scaleAdjustment = ...
                    scaleAdjRight(i);
            else
                toneBurst(ear,i).calibMaxSPL = ...
                    calibSPLLeft(i);

                toneBurst(ear,i).scaleAdjustment = ...
                    scaleAdjLeft(i);
            end

            %% Store randomized stimulus-train information

            stimTrain(e,ear,i).frequency = ...
                sprintf('%0.0f_Hz',freq);

            stimTrain(e,ear,i).frequency_Hz = freq;
            stimTrain(e,ear,i).impulseTrain = impulseTrain;
            stimTrain(e,ear,i).stimIdx = stimIdx;
            stimTrain(e,ear,i).polarity = polarity;
            stimTrain(e,ear,i).signal = train;
            stimTrain(e,ear,i).earLabel = Label;

            %% Add frequency train to corresponding ear

            epoch(ear,:) = epoch(ear,:) + train;
        end
    end

    %% Store the ears correctly
    %
    % epoch(1,:) = right
    % epoch(2,:) = left

    rightEpochs(e,:) = [ ...
        zeros(1,padN), ...
        epoch(1,:), ...
        zeros(1,padN)];

    leftEpochs(e,:) = [ ...
        zeros(1,padN), ...
        epoch(2,:), ...
        zeros(1,padN)];
end

%% Check stimulus peaks

rightPeak = max(abs(rightEpochs),[],'all');
leftPeak  = max(abs(leftEpochs),[],'all');

fprintf('Right digital peak: %.4f\n',rightPeak);
fprintf('Left digital peak:  %.4f\n',leftPeak);

if rightPeak > 1
    warning(['Right pABR waveform has a digital peak greater than 1. ' ...
             'Confirm that the TDT buffer does not clip.']);
end

if leftPeak > 1
    warning(['Left pABR waveform has a digital peak greater than 1. ' ...
             'Confirm that the TDT buffer does not clip.']);
end

%% Store output structure

pABRstim = struct();

pABRstim.rightEpochs = rightEpochs;
pABRstim.leftEpochs = leftEpochs;

pABRstim.stimTrain = stimTrain;
pABRstim.toneBurst = toneBurst;

% Independent calibration information
pABRstim.maxSPLRight = maxSPLRight;
pABRstim.maxSPLLeft = maxSPLLeft;

pABRstim.calibSPLRight = calibSPLRight;
pABRstim.calibSPLLeft = calibSPLLeft;

pABRstim.scaleAdjRight = scaleAdjRight;
pABRstim.scaleAdjLeft = scaleAdjLeft;

pABRstim.calibRight = calibRight;
pABRstim.calibLeft = calibLeft;

pABRstim.desiredSpl = desiredSpl;
pABRstim.calibrationMode = ...
    'Independent right- and left-ear calibration';

% Gating information
pABRstim.Gating.Dur_ms = 1000*Nepoch/fs;
pABRstim.Gating.rftime_ms = 5;

pABRstim.pad_ms = pad_ms;
pABRstim.padSamples = padN;
pABRstim.attenMask = 0;
pABRstim.RPsamprate_Hz = fs;

pABRstim.Gating.pABRDur_ms = ...
    1000*paddedNepoch/fs;

pABRstim.Gating.Period_ms = ...
    pABRstim.Gating.pABRDur_ms + 450;

end


function maxdB = getcalibMax(freq,calibData)
% GETCALIBMAX
% Interpolates the inverse calibration at the requested frequency.
%
% freq is supplied in Hz.
% Calibration frequency may be stored in kHz or Hz.

calibFrequency = double(calibData(:,1));
calibSPL = double(calibData(:,2));

% Existing NEL calibration files normally store frequency in kHz.
if max(calibFrequency) < 100
    calibFrequency = calibFrequency*1e3;
end

% Remove invalid entries
validRows = ...
    isfinite(calibFrequency) & ...
    isfinite(calibSPL);

calibFrequency = calibFrequency(validRows);
calibSPL = calibSPL(validRows);

% Sort frequencies before interpolation
[calibFrequency,sortIndex] = sort(calibFrequency);
calibSPL = calibSPL(sortIndex);

% Remove duplicate frequencies
[calibFrequency,uniqueIndex] = ...
    unique(calibFrequency,'stable');

calibSPL = calibSPL(uniqueIndex);

if freq < calibFrequency(1) || freq > calibFrequency(end)
    error(['Requested frequency %.0f Hz is outside the calibration ' ...
           'range %.0f-%.0f Hz.'], ...
           freq,calibFrequency(1),calibFrequency(end));
end

maxdB = interp1( ...
    calibFrequency, ...
    calibSPL, ...
    freq, ...
    'linear');

end