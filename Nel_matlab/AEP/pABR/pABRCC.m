function [combFreq] = pABRCC(cumResponse,stim,pABRstim)

global pABRstim

frequencies = [500,1000, 2000, 4000, 8000];

combFreq = struct();
for i=1:length(frequencies)

    impTrain= stim(i).impulseTrain;

    impTrain = impTrain(:);
    cumResponse = cumResponse(:);
    impTrain = abs(impTrain);
    n = sum(impTrain); %tone burst presentation rate
    %padSamples = round((pABRstim.pad_ms/1000)*pABRstim.RPsamprate_Hz);
    padSamples = pABRstim.padSamples;
    padImpTrain = [zeros(padSamples,1);impTrain;zeros(padSamples,1)];
    noiseStartSamp = round(0.10 * padSamples) + 1;   % start at 10% into pad
    noiseEndSamp   = round(0.90 * padSamples); 

    if length(padImpTrain)==length(cumResponse)
        nfft = length(cumResponse);
    else
        error("Length of response and padded impulse train have to match")
    end

    tmpRes = ifft(conj(fft(padImpTrain,nfft)).*fft(cumResponse,nfft)); 

    tmpResNorm = tmpRes/n;

    response = [tmpResNorm(end-padSamples+1:end);tmpResNorm(1:padSamples)];
    combFreq(i).response = response;

    if noiseEndSamp > noiseStartSamp
        noise = response(noiseStartSamp:noiseEndSamp);
    else
        warning('Not enough padding samples for noise estimate.');
        noise = [];
    end
    combFreq(i).var = 1/var(noise);

end
end



