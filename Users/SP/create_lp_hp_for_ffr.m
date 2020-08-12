[sig, fs] = audioread('C:\NEL1_2\Users\SP\SNRenv_stimuli\FFRSNRenv_short_stationary_org\dyn_harm_complex_SFRbased.wav');

lpFilt= designfilt('lowpassiir','FilterOrder', 8, ...
'PassbandFrequency',0.5e3,'PassbandRipple',0.2, ...
'SampleRate', fs);

fvtool(lpFilt);

hpFilt= designfilt('highpassiir','FilterOrder', 8, ...
'PassbandFrequency',0.5e3,'PassbandRipple',0.2, ...
'SampleRate', fs);

fvtool(hpFilt);

sig_lp= filtfilt(lpFilt, sig);

sig_hp= filtfilt(hpFilt, sig);


figure(3);
clf;
plot_dpss_psd(sig, fs);
hold on ;
plot_dpss_psd(sig_lp, fs);
plot_dpss_psd(sig_hp, fs);


audiowrite('C:\NEL1_2\Users\SP\SNRenv_stimuli\FFRSNRenv_short_stationary_org\LP_dyn_harm_complex_SFRbased.wav', sig_lp, fs);
audiowrite('C:\NEL1_2\Users\SP\SNRenv_stimuli\FFRSNRenv_short_stationary_org\HP_dyn_harm_complex_SFRbased.wav', sig_hp, fs);