clear;
clc;

nSamples= 188;
NFC= 4;
G0= 60;
fs= 10e3;
NWS= 50;

force_reStart= 0;
fName= sprintf('/media/parida/DATAPART1/Matlab/MWcentral/Klatt/def_vowel_params_%d.mat', nSamples);
if ~exist(fName, 'file') || force_reStart
    vowel_params= handsy_init(nSamples, NFC, G0, NWS, fs);
    
    save(fName, 'vowel_params');
else
    load(fName);
end

figHan.time_psd= 1;
figHan.spect= 2;

outDataDir= 'output/';
if ~isfolder(outDataDir)
    mkdir(outDataDir)
end

% Plot params
xtick_vals= [100 500 1e3 2e3 5e3];
xtick_labs= cellfun(@(x) num2str(x), num2cell(xtick_vals), 'UniformOutput', false);

%% Stationary signal
vowel_params.av.ydata= [60 60];

vowel_params.f0.ydata= [100 100];
vowel_params.f1.ydata= [600 600];
vowel_params.f2.ydata= [1200 1200];
vowel_params.f3.ydata= [2500 2500];
% vowel_params.f4.ydata= [3500 3500];
% vowel_params.f5.ydata= [4500 4500];

vowel_params.b1.ydata= [90 90];
vowel_params.b2.ydata= [110 110];
vowel_params.b3.ydata= [170 170];

% vowel_params.a1.ydata= [40 40];
% vowel_params.a2.ydata= [40 40];
% vowel_params.a3.ydata= [40 40];
% vowel_params.a4.ydata= [-20 -20];

vowel_params.sw.ydata= [0 0];

sig_stat= synth(vowel_params);
sig_stat= sig_stat/max(abs(sig_stat))*.99;
tSig= (1:numel(sig_stat))/fs;

%% Plot
figure(figHan.time_psd);
clf;

subplot(221)
plot(tSig, sig_stat);
title('Stationary')

yyaxis right;
[splVals, timeVals] = gen_get_spl_vals(sig_stat, fs, 30e-3, .5);
plot(timeVals, splVals, 'd-', 'MarkerSize', 12, 'LineWidth', 3);
ylim([80 85]);

ax(1)= subplot(223);
plot_dpss_psd(sig_stat, fs, 'yrange', 50)
xlim([75 fs/2]);
set(gca, 'XTick', xtick_vals, 'XTickLabel', xtick_labs);

% Spectrogram
window_size= 40e-3;
figure(figHan.spect);
subplot(211);
spectrogram(sig_stat, blackman(window_size*fs), round(window_size*fs*.9), 2^8, 'yaxis', fs);
title('Stationary')

%% Dynamic signal
clear vowel_params;
load(fName);
vowel_params.av.ydata= [60 60];
vowel_params.f0.ydata= [100 120];
vowel_params.f1.ydata= [625 575];
vowel_params.f2.ydata= [1200 1500];
vowel_params.f3.ydata= [2500 2500];
% vowel_params.f4.ydata= [3500 3500];
% vowel_params.f5.ydata= [4500 4500];

vowel_params.b1.ydata= [90 90];
vowel_params.b2.ydata= [110 110];
vowel_params.b3.ydata= [170 170];

% vowel_params.a1.ydata= [40 40];
% vowel_params.a2.ydata= [40 40];
% vowel_params.a3.ydata= [40 40];
% vowel_params.a4.ydata= [-20 -20];

vowel_params.sw.ydata= [0 0];

sig_kin= synth(vowel_params);
sig_kin= sig_kin/max(abs(sig_kin))*.99;
tSig= (1:numel(sig_kin))/fs;

%% Plot
figure(figHan.time_psd);

subplot(222)
plot(tSig, sig_kin);
title('Kinematic')
yyaxis right;
[splVals, timeVals] = gen_get_spl_vals(sig_kin, fs, 30e-3, .5);
plot(timeVals, splVals, 'd-', 'MarkerSize', 12, 'LineWidth', 3);
ylim([80 85]);

ax(2)= subplot(224);
plot_dpss_psd(sig_kin, fs, 'yrange', 50)
xlim([75 fs/2]);
set(gca, 'XTick', xtick_vals, 'XTickLabel', xtick_labs);
linkaxes(ax);

figure(figHan.spect);
subplot(212);
spectrogram(sig_kin, blackman(window_size*fs), round(window_size*fs*.9), 2^8, 'yaxis', fs);
title('Kinematic')

%% Play
sound(sig_stat, fs);
pause(nSamples/fs+1);
sound(sig_kin, fs);

% save
fSize= 18;

figure(figHan.time_psd);
set(findall(gcf,'-property','FontSize'),'FontSize',fSize);
set(figHan.time_psd, 'Units', 'normalized', 'Position', [.1 .1 .8 .8]);
saveas(figHan.time_psd, [outDataDir 'time_psd'], 'png');

figure(figHan.spect);
set(findall(gcf,'-property','FontSize'),'FontSize',fSize);
set(figHan.spect, 'Units', 'normalized', 'Position', [.1 .1 .8 .8]);
saveas(figHan.spect, [outDataDir 'spectrogram'], 'png');

audiowrite([outDataDir 'schwa_stationary.wav'], sig_stat, fs);
audiowrite([outDataDir 'schwa_kinematic.wav'], sig_kin, fs);