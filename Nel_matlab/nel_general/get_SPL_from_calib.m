% use one calib file
% use one broadband stimulus (probably (1) white noise and (2) speech)
% 100 dB at 1 kHz at 1 Vrms in calib means if we play a sqrt(2)/5 unit amplitude (1/5 unit rms) 1 kHz sinusoid, then Voltage output = (1/5 * 5) = 1 V RMS => 100 dB.
% If we have a wav-file with 1Vpp => 1/sqrt(2) Vrms: that corresponds to calib output 

function [filteredSPL, originalSPL]= get_SPL_from_calib(stimOrg, fsOrg, calibdata, plotFigs)

% plotFigs= 1;
co= [0    0.4470    0.7410;
    0.8500    0.3250    0.0980;
    0.4940    0.1840    0.5560;
    0.4660    0.6740    0.1880;
    0.3010    0.7450    0.9330;
    0.6350    0.0780    0.1840];

if plotFigs
    figure(1); clf;
    figure(2); clf;
    lw=2;
end
%% load stim
fs=20e3;
qBYp=round(fsOrg/fs);
fs=fsOrg/qBYp;
stim= resample(stimOrg, 1, qBYp);
t=(1:length(stim))/fs;

%% remove anything above fs/2.
calibOrgFreqs= calibdata(:,1)*1e3;
calibOrgMaxOutput= calibdata(:,2); % This corresponds to db 5/sqrt(2) V => 1/sqrt(2) RMS

% 1 V P-P with 0 dB gain
baseline_dB= 20*log10(1/sqrt(2)/(20e-6)); % 1Vpp wav-amp = 1/sqrt(2) rms = Ideal calibOUT
calibOrgRelative_dB= calibOrgMaxOutput-baseline_dB;

%% Consider a signal x.
% Energy equation: sum(x.^2)=(1/nfft)*sum(|fft(x, nfft)|.^2)
% So power equation: will be sum(x.^2)/L=(1/L/nfft)*sum(|fft(x, nfft)|.^2)
nfft= 2^nextpow2(length(stim));
fft_stim= fftshift(fft(stim, nfft));
fft_freq=linspace(-fs/2, fs/2, nfft);

%% create calib filter
calibUpdated_dB= 0*fft_stim;

[minFreq, minFreqInd]=min(calibOrgFreqs);
LowRange_freq_inds=abs(fft_freq)<minFreq;
calibUpdated_dB(LowRange_freq_inds)=calibOrgMaxOutput(minFreqInd);

[maxFreq, maxFreqInd]=max(calibOrgFreqs);
HighRange_freq_inds=abs(fft_freq)>maxFreq;
calibUpdated_dB(HighRange_freq_inds)=calibOrgMaxOutput(maxFreqInd);

PosInRange_freq_inds= find(fft_freq>=minFreq & fft_freq<=maxFreq);
calibUpdated_dB(PosInRange_freq_inds)=interp1(calibOrgFreqs, calibOrgMaxOutput, fft_freq(PosInRange_freq_inds));
calibUpdated_dB(nfft-PosInRange_freq_inds+1)=calibUpdated_dB(PosInRange_freq_inds);
calibFilter_lin=db2mag(calibUpdated_dB-baseline_dB);


%% Calculate power in the signal
OrgPowerFFT= (1/length(stim)/nfft)*sum(abs(fft_stim).^2);
OrgPowerSIG= sum(stim.^2)/length(stim);

thresh_error= 1e-10;
if abs((OrgPowerSIG-OrgPowerFFT)/OrgPowerFFT)>thresh_error
   error('Error in verifying Parseval'); 
end
FilteredPowerFFT= (1/length(stim)/nfft)*sum( (abs(fft_stim) .*  calibFilter_lin).^2);

originalSPL= 20*log10(sqrt(OrgPowerFFT)/(20e-6));
filteredSPL= 20*log10(sqrt(FilteredPowerFFT)/(20e-6));
fprintf('Originial I= %.1f dB SPL, Filtered I= %.1f dB SPL\n', originalSPL, filteredSPL);


%% Calibration plots
if plotFigs
% % %     figure(1);
% % %     subplot(211);
% % %     hold on;
% % %     plot(calibOrgFreqs, calibOrgMaxOutput, 'linew', lw);
% % %     grid on;
% % %     ylabel('Max Output (dB)');
% % %     
% % %     subplot(212);
% % %     plot(calibOrgFreqs, calibOrgRelative_dB, 'linew', lw); % this is a useless plot
% % %     grid on;
% % %     ylabel('Calib Filter (dB)');
% % %     xlabel('Frequency (Hz)');
    %%
    figure(2);
    subplot(211);
    hold on;
    plot(t, stim);
    xlabel('time (sec)');
    ylabel('in signal');
    
    subplot(212);
    % [amp_dB,freq, ax]=plot_fft(stim, fs, 0, nfft);
    % [amp_dB,freq, ax]=plot_dpss_psd(stim, fs, 0, nfft);
    yyaxis left;
    hold on;
    pl(1)= plot(fft_freq, db(abs(fft_stim)), 'color', co(1, :), 'linew', lw);
    pl(2)= plot(fft_freq, db(abs(fft_stim) .*  calibFilter_lin), 'color', co(4, :), 'linew', 1);
    ylabel('DFT (dB)', 'color', co(1, :));
    
    yyaxis right;
    pl(3)= plot(fft_freq, db(calibFilter_lin), 'linew', lw);
    ylabel('Calib filter (dB)', 'color', co(2, :));
    xlabel('freq (Hz)');
    
    legend(pl, 'sig-In', 'sig-Filtered', 'calib-Filter');
    
    grid on;
    set(gca, 'xscale', 'lin');
end