clear;
% clc;
clf;

% fName= '/media/parida/DATAPART1/Matlab/MWcentral/Klatt/output/schwa_stationary.wav'
fName= '/media/parida/DATAPART1/Matlab/MWcentral/Klatt/output/schwa_kinematic.wav'

[sig, fs]= audioread(fName);
a= lpc(sig, 24);
[H,W] = freqz(1, a, fs);
W_Hz= W/pi*fs/2;


refFormants= [500 1200 2500 3200];
refTroughs= sqrt(refFormants(1:end-1).*refFormants(2:end));

[~, peak_inds]= findpeaks(db(H));
peak_inds= peak_inds(dsearchn(W_Hz(peak_inds), refFormants(:)));
formants= round(W_Hz(peak_inds))
[~, trou_inds]= findpeaks(-db(H));
trou_inds= trou_inds(dsearchn(W_Hz(trou_inds), refTroughs(:)));
troughs= round(W_Hz(trou_inds))

yyaxis left;
plot_dpss_psd(sig/rms(sig), fs, 'xscale', 'lin', 'yrange', 70);
yyaxis right; 
plot(W/pi*fs/2, db(H), 'LineWidth', 3);
hold on;
plot(W(peak_inds)/pi*fs/2, db(H(peak_inds)), 'k^', 'LineWidth', 2, 'MarkerSize', 16);
plot(W(trou_inds)/pi*fs/2, db(H(trou_inds)), 'kv', 'LineWidth', 2, 'MarkerSize', 16);