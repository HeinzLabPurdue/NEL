function [pABRstim] = ...
    make_toneburst_epochs(frequencies, fs, nEpochs, nStim,calib,desiredSpl)
pad_ms = 500;
Nepoch = fs;
%desiredSPL =75;
nEars = 2;
earLabel = ["left","right"];                     
padN = round((pad_ms/1000) * fs);                         
paddedNepoch = Nepoch + 2*padN; 
%JL 18June2026
%scaling based on calibration Data to relative desired dB SPL 
%Make sure to use inverse calib file!!!!!

scaleTemp =zeros(1,length(frequencies));
calibTemp = zeros(1,length(frequencies));
for jj =1:length(frequencies)
     calibMaxx = getcalibMax(frequencies(jj),calib);
     scalee = 10^((desiredSpl-calibMaxx)/20);
     scaleTemp(jj) = scalee;
     calibTemp(jj) =  calibMaxx;
end
[tempMin,ind] = min(scaleTemp);
scaleAdj  = 1/tempMin.*(scaleTemp); %we need to keep the signal 
                                    %as loud as possible scale to highest dB spl
                                    %till we get to last PA5
maxCalibSPL = calibTemp(ind); 

leftEpochs  = zeros(nEpochs,paddedNepoch);
rightEpochs = zeros(nEpochs,paddedNepoch);

toneBurst = struct();
stimTrain = struct();

for e = 1:nEpochs

    epoch = zeros(nEars,Nepoch);

    for ear = 1:nEars
        Label = earLabel(ear);

        for i = 1:length(frequencies)

            freq = frequencies(i);

            Tburst = 5/freq;
            t = 0:1/fs:Tburst-1/fs;

            temp1 = cos(2*pi*freq*t);
            %temp2 = setdb(temp1,freq,desiredSpl,calib);
            temp2 =scaleAdj(i)*temp1;
            window = blackman(length(temp2))';

            tone = temp2 .* window;

            toneBurst(i).frequency = sprintf("%0.0f_Hz",freq);
            toneBurst(i).signal = tone;

            burstLen = length(tone);
            impulseTrain = zeros(1,Nepoch);

            validIdx = 1:(Nepoch - burstLen + 1);
            stimIdx = validIdx(randperm(length(validIdx), nStim));

            polarity = [ones(1,nStim/2), -ones(1,nStim/2)];
            polarity = polarity(randperm(nStim));

            impulseTrain(stimIdx) = polarity;

            train = conv(impulseTrain, tone);
            train = train(1:Nepoch);

            stimTrain(e,ear,i).frequency = sprintf("%0.0f_Hz",freq);
            stimTrain(e,ear,i).impulseTrain = impulseTrain;
            stimTrain(e,ear,i).stimIdx = stimIdx;
            stimTrain(e,ear,i).polarity = polarity;
            stimTrain(e,ear,i).signal = train;
            stimTrain(e,ear,i).earLabel = Label;

            epoch(ear,:) = epoch(ear,:) + train;
        end
    end

    leftEpochs(e,:)  = [zeros(1,padN), epoch(1,:), zeros(1,padN)];
    rightEpochs(e,:) = [zeros(1,padN), epoch(2,:), zeros(1,padN)];
end


function scaledSig = setdb(signal,frequency, desiredSpl,calib) %#ok<DEFNU>
calibMax = getcalibMax(frequency, calib);

scale = 10^((desiredSpl - calibMax)/20);
scaledSig = scale * signal;
end

function maxdB = getcalibMax(freq,calibData)
%function to extract the maximum dB from the inverse calibration data
calibData(:,1)=calibData(:,1)*1e3;
[~,j] = min(abs(freq-calibData(:,1))); %closest frequency with SPL 
if freq < calibData(j,1)
    maxdB = calibData(j,2)+(freq-calibData(j,1))/(calibData(j-1,1)-calibData(j,1))...
        *(calibData(j-1,2)-calibData(j,2));
elseif freq > calibData(j,1)
    maxdB = calibData(j,2)+(freq-calibData(j,1))/(calibData(j+1,1)-calibData(j,1))...
        *(calibData(j+1,2)-calibData(j,2));
else
    maxdB = calibData(j,1);
end
end


pABRstim = struct();
pABRstim.leftEpochs = leftEpochs;
pABRstim.rightEpochs = rightEpochs;
pABRstim.stimTrain = stimTrain;
pABRstim.toneBurst = toneBurst;
pABRstim.maxSPL = maxCalibSPL;
pABRstim.Gating.Dur_ms=1000;
pABRstim.RPsamprate_Hz=50e6/1024;
pABRstim.Gating.pABRDur_ms=2*pad_ms+1000;
pABRstim.Gating.Period_ms=2*pad_ms+1000+100;
pABRstim.Gating.rftime_ms=5;
pABRstim.pad_ms=pad_ms;
pABRstim.attenMask =0;


end