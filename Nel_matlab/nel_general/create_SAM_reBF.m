% SP: to create stationary/kinematic vowel for a fiber with
% shifted/original features. Shifting based in resampling.
% --------------------------------------------------------------------------
% Algorithm: We know the features for original wav-file. For each BF/feature
% paur, we need to create the new stim with the feature centered on BF, and
% then resample. So duration will change --> first figure out what should
% be the original duration so that final duration after resampling is
% constant (188 ms) in this case. Save wav-file with max amplitude = 0.99.
% Then based on calib-based max dB SPL, figure out attenuation to acheive
% target dB SPL. Also final fundamental frequency should be 100 Hz =
% constant: so create a stimulus with adjusted F0 before resampling.
% Note: CF/BF same- no distinction. Tried to use BF everywhere.

function fName= create_SAM_reBF(outDataDir, BF_Hz, AllModFreqs, polarityString)

%% Initialize input arguments
if nargin<2
    error('Need atleast two inputs: output directory and BF (in Hz) as input');
end


if ~exist('AllModFreqs', 'var')
    AllModFreqs= [8 32 128];
end


BF_Hz= round(BF_Hz);

if ~strcmp(outDataDir(end), filesep)
    outDataDir= [outDataDir filesep];
end
if ~isdir(outDataDir)
    mkdir(outDataDir);
end

doPlot= 0;
doPlay= 0;

%% stationary params
duration_ms= 500;
fs= 100e3;
modDepth= 1;
amp= 1;
phi_c= 0;
phi_m= pi;

for fmVar= 1:length(AllModFreqs)
    cur_fm= AllModFreqs(fmVar);
    
    sig_sam= create_SAM(BF_Hz, cur_fm, fs, modDepth, duration_ms/1e3, amp, phi_c, phi_m);
    sig_sam= sig_sam/max(abs(sig_sam))*.99;
    
    switch polarityString
        case 'pos'
            fName= sprintf('%sSAM_stat_BF%.0f_fm%.0fHz_pos.wav', outDataDir, BF_Hz, cur_fm);
        case 'neg'
            fName= sprintf('%sSAM_stat_BF%.0f_fm%.0fHz_neg.wav', outDataDir, BF_Hz, cur_fm);
            sig_sam= -sig_sam;
    end
    if ~exist(fName, 'file')
        audiowrite(fName, sig_sam, fs);
    end
%     fprintf('OA I = %.1f db SPL\n', calc_dbspl(sig_sam))
    if doPlot
        plot_before_after_rs(sig_sam, fs, BF_Hz, cur_fm);
    end
    if doPlay
        soundsc(sig_sam, fs);
        pause(numel(sig_sam)/fs+1);
    end
end

end

function plot_before_after_rs(sigPre, fs, BF_Hz, FM_Hz)

% Plot params
xtick_vals= [100 500 1e3 2e3 5e3 10e3 20e3];
xtick_labs= cellfun(@(x) num2str(x), num2cell(xtick_vals), 'UniformOutput', false);
time= (1:numel(sigPre))/fs;
%% Plot
figure(111);
clf;

subplot(211)
plot(time, sigPre);
title('Before Resampling')

yyaxis right;
[splVals, timeVals] = gen_get_spl_vals(sigPre, fs, 20e-3, .5);
plot(timeVals, splVals, 'd-', 'MarkerSize', 12, 'LineWidth', 3);
ylim([max(splVals)-15 max(splVals)+5]);
subplot(212);
plot_dft(sigPre, fs, 'yscale', 'dbspl', 'yrange', 70)
xlim([75 fs/2]);
% set(gca, 'XTick', xtick_vals, 'XTickLabel', xtick_labs);
hold on;
plot([BF_Hz BF_Hz], [mean(ylim) max(ylim)]-.1*range(ylim), 'r*', 'MarkerSize', 10, 'LineWidth', 2);
plot([BF_Hz BF_Hz]-FM_Hz, [mean(ylim) max(ylim)]-.1*range(ylim), 'm<', 'MarkerSize', 10, 'LineWidth', 2);
plot([BF_Hz BF_Hz]+FM_Hz, [mean(ylim) max(ylim)]-.1*range(ylim), 'm>', 'MarkerSize', 10, 'LineWidth', 2);

set(findall(gcf,'-property','FontSize'),'FontSize', 14);

end


function spl_out= calc_dbspl(vecin)

pRef= 20e-6;
vecin= vecin-mean(vecin);
spl_out= 20*log10(rms(vecin)/pRef);
end
% function outData= hp_filter(inData, fs)
% hpFilt = designfilt('highpassfir','StopbandFrequency',60, ...
%          'PassbandFrequency',80,'PassbandRipple',0.5, ...
%          'StopbandAttenuation',65,'DesignMethod','kaiserwin', ...
%          'SampleRate', fs);
% % fvtool(hpFilt)
% outData= filtfilt(hpFilt, inData);
% end



% function [sig, time]= create_SAM(fc, fm, fs, modDepth, dur, amp, phi_c, phi_m)
function [sig, time]= create_SAM(fc, fm, fs, modDepth, dur, amp, phi_c, phi_m)

if nargin <3
    error ('Need more love');
end

if ~exist('phi_m', 'var')
    phi_m= pi;
elseif isempty(phi_m)
    phi_m= pi;
end

if ~exist('phi_c', 'var')
    phi_c= 0;
elseif isempty(phi_c)
    phi_c= 0;
end

if ~exist('amp', 'var')
    amp= 1;
elseif isempty(amp)
    amp= 1;
end

if ~exist('dur', 'var')
    dur= .2;
elseif isempty(dur)
    dur= .2;
end

if ~exist('modDepth', 'var')
    modDepth= 1;
elseif isempty(modDepth)
    modDepth= 1;
end


time= (0:1/fs:dur-1/fs)';
sig= amp*(1 + modDepth*cos(2*pi*fm*time + phi_m)).*sin(2*pi*fc*time + phi_c);
end