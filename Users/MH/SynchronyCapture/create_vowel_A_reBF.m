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

function create_vowel_A_reBF(outDataDir, BF_Hz, CodesDir, featureList_stat, featureList_kin)  %#ok<INUSL>

%% Initialize input arguments
if nargin<2
    error('Need atleast two inputs: output directory and BF (in Hz) as input');
end


if ~exist('featureList_stat', 'var')
    if BF_Hz>600
        featureList_stat= {'RAW', 'F2', 'F2T2', 'T2', 'F3'};
    else
        featureList_stat= {'RAW', 'F1', 'F1T1', 'T1', 'F3'};
    end
end

if ~exist('featureList_kin', 'var')
    %     featureList_kin= {'RAW', 'F2', 'F2T2', 'T2', 'F3'};
    featureList_kin= featureList_stat;
end

% if ~exist('CodesDir', 'var')
%     CodesDir= '/media/parida/DATAPART1/Matlab/MWcentral/Klatt/';
% end

BF_Hz= round(BF_Hz);

if ~strcmp(outDataDir(end), filesep)
    outDataDir= [outDataDir filesep];
end
if ~isdir(outDataDir)
    mkdir(outDataDir);
end

doPlot= 0;
doPlay= 0;
target_dBSPL= 75;

% curDir= pwd;

% cd(CodesDir);

%% stationary params
base_duration_ms= 188;
fsKlatt= 40e3; % not sure if Klatt-Synth will work with 100e3. So create with 40e3, upsample and save.
fsWav= 100e3;
stationary_base_params.fsOrg= fsKlatt;
stationary_base_params.f0= [100 100];
stationary_base_params.f1= [600 600];
stationary_base_params.t1= 980; % single value and not two values to ...
% indicate this is not used to design stim. Just something we needed ...
% to figure out new_fs/duration. Value based on lpc of raw wav-file
stationary_base_params.f1t1= 750;

stationary_base_params.f2= [1200 1200];
stationary_base_params.t2= 2000; % see stationary_base_params.t1
stationary_base_params.f2t2= 1600; % see stationary_base_params.t1 (real-value 1550)
stationary_base_params.f3= [2500 2500];

% don't change bandwidths
stationary_base_params.b1= [90 90];
stationary_base_params.b2= [110 110];
stationary_base_params.b3= [170 170];
stationary_base_params.sw= [0 0]; % Cascade mode: produces more natural vowels


for stat_feat_var= 1:length(featureList_stat)
    stationary_params= stationary_base_params;
    switch featureList_stat{stat_feat_var}
        case 'RAW'
            BF_sim_Hz= BF_Hz;
            BF_Hz_approx= BF_Hz;
        case 'F1'
            BF_sim_Hz= stationary_base_params.f1(1);
            BF_Hz_approx= round(BF_Hz/stationary_base_params.f0(1))*stationary_base_params.f0(1);
            % put it on a harmonic of the F0
        case 'F1T1'
            BF_sim_Hz= stationary_base_params.f1t1;
            BF_Hz_approx= BF_Hz;
        case 'F2'
            BF_sim_Hz= stationary_base_params.f2(1);
            BF_Hz_approx= round(BF_Hz/stationary_base_params.f0(1))*stationary_base_params.f0(1); % put it on a harmonic of the F0
        case 'F2T2'
            BF_sim_Hz= stationary_base_params.f2t2;
            BF_Hz_approx= BF_Hz;
        case 'T2'
            BF_sim_Hz= stationary_base_params.t2;
            BF_Hz_approx= BF_Hz;
        case 'F3'
            BF_sim_Hz= stationary_base_params.f3(1);
            BF_Hz_approx= round(BF_Hz/stationary_base_params.f0(1))*stationary_base_params.f0(1);
    end
    %     stationary_params.f0= round(stationary_base_params.f0*BF_sim_Hz/BF_Hz_approx);
    stationary_params.f0= stationary_base_params.f0*BF_sim_Hz/BF_Hz_approx;
    stationary_params.dur_ms= ceil(base_duration_ms*BF_Hz_approx/BF_sim_Hz);
    sig_stat_temp= run_synthesis_fun(stationary_params, doPlay);
    sig_stat= gen_resample(sig_stat_temp, BF_Hz_approx, BF_sim_Hz);
    sig_stat= sig_stat(1:round(base_duration_ms*stationary_params.fsOrg/1e3));
    %     sig_stat= hp_filter(sig_stat, stationary_base_params.fsOrg);
    sig_stat= detrend(sig_stat);
    sig_stat= gen_rescale(sig_stat, target_dBSPL);
    fName_pos= sprintf('%svowelA_stat_BF%.0f_%s_pos.wav', outDataDir, BF_Hz, featureList_stat{stat_feat_var});
    fName_neg= sprintf('%svowelA_stat_BF%.0f_%s_neg.wav', outDataDir, BF_Hz, featureList_stat{stat_feat_var});
    
    % Finally save both +ve and -ve polarity at Fs = 100e3
    sig_stat= gen_resample(sig_stat, stationary_base_params.fsOrg, fsWav);
    audiowrite(fName_pos, sig_stat, fsWav);
    audiowrite(fName_neg, -sig_stat, fsWav);
    
    if max(abs(sig_stat))>.99
        sig_stat= sig_stat/max(abs(sig_stat))*.99;
        warning('Couldn''t acheive desired intensity by %.1f dB SPL for file %s\n', target_dBSPL-calc_dbspl(sig_stat), fName_pos);
        beep;
    end
    
    if doPlot
        plot_before_after_rs(sig_stat_temp, sig_stat, stationary_params.fsOrg, BF_Hz, featureList_stat{stat_feat_var});
    end
end


%% kinematic params
kinematic_base_params.fsOrg= fsKlatt;
kinematic_base_params.f0= [100 120];
kinematic_base_params.f1= [625 575];
kinematic_base_params.t1= 980; % = stationary_base_params.t1
kinematic_base_params.f1t1= 750; % see stationary_base_params.f1t1: real value 777
kinematic_base_params.f2= [1200 1500];
kinematic_base_params.t2= 2000; % = stationary_base_params.t2
kinematic_base_params.f2t2= 1600; % see stationary_base_params.t1: real value 1643
kinematic_base_params.f3= [2500 2500];

% don't change bandwidths
kinematic_base_params.b1= [90 90];
kinematic_base_params.b2= [110 110];
kinematic_base_params.b3= [170 170];
kinematic_base_params.sw= [0 0]; % Cascade mode: produces more natural vowels


for kin_feat_var= 1:length(featureList_kin)
    switch featureList_kin{kin_feat_var}
        case 'RAW'
            BF_sim_Hz= BF_Hz;
        case 'F1'
            BF_sim_Hz= round(mean(kinematic_base_params.f1));
        case 'F1T1'
            BF_sim_Hz= kinematic_base_params.f1t1;
        case 'F2'
            BF_sim_Hz= round(mean(kinematic_base_params.f2));
        case 'F2T2'
            BF_sim_Hz= kinematic_base_params.f2t2;
        case 'T2'
            BF_sim_Hz= kinematic_base_params.t2;
        case 'F3'
            BF_sim_Hz= round(mean(kinematic_base_params.f3));
    end
    
    kinematic_params= kinematic_base_params;
    %     kinematic_params.f0= round(kinematic_base_params.f0*BF_sim_Hz/BF_Hz);
    kinematic_params.f0= kinematic_base_params.f0*BF_sim_Hz/BF_Hz;
    kinematic_params.dur_ms= ceil(base_duration_ms*BF_Hz/BF_sim_Hz);
    sig_kin_temp= run_synthesis_fun(kinematic_params, doPlay);
    sig_kin= gen_resample(sig_kin_temp, BF_Hz, BF_sim_Hz);
    sig_kin= sig_kin(1:round(base_duration_ms*kinematic_params.fsOrg/1e3));
    %     sig_kin= hp_filter(sig_kin, stationary_base_params.fsOrg);
    sig_kin= detrend(sig_kin);
    sig_kin= gen_rescale(sig_kin, target_dBSPL);
    
    fName_pos= sprintf('%svowelA_kin_BF%.0f_%s_pos.wav', outDataDir, BF_Hz, featureList_kin{kin_feat_var});
    fName_neg= sprintf('%svowelA_kin_BF%.0f_%s_neg.wav', outDataDir, BF_Hz, featureList_kin{kin_feat_var});
    % Finally save both +ve and -ve polarity at Fs = 100e3
    sig_kin= gen_resample(sig_kin, kinematic_base_params.fsOrg, fsWav);
    if max(abs(sig_kin))>.99
        sig_kin= sig_kin/max(abs(sig_kin))*.99;
        warning('Couldn''t acheive desired intensity by %.1f dB SPL for file %s\n', target_dBSPL-calc_dbspl(sig_kin), fName_pos);
        beep;
    end
    
    audiowrite(fName_pos, sig_kin, fsWav);
    audiowrite(fName_neg, -sig_kin, fsWav);
    if doPlot
        plot_before_after_rs(sig_kin_temp, sig_kin, kinematic_params.fsOrg, BF_Hz, featureList_stat{kin_feat_var});
    end
end


% cd(curDir);
end

function plot_before_after_rs(sigPre, sigPost, fs, BF_Hz, feature_name)

% Plot params
xtick_vals= [100 500 1e3 2e3 5e3 10e3 20e3];
xtick_labs= cellfun(@(x) num2str(x), num2cell(xtick_vals), 'UniformOutput', false);
tPre= (1:numel(sigPre))/fs;
tPost= (1:numel(sigPost))/fs;
%% Plot
figure(111);
clf;

subplot(221)
plot(tPre, sigPre);
title('Before Resampling')

yyaxis right;
[splVals, timeVals] = gen_get_spl_vals(sigPre, fs, 20e-3, .5);
plot(timeVals, splVals, 'd-', 'MarkerSize', 12, 'LineWidth', 3);

subplot(223);
plot_dpss_psd(sigPre, fs, 'yrange', 70)
xlim([75 fs/2]);
set(gca, 'XTick', xtick_vals, 'XTickLabel', xtick_labs);
hold on;
plot([BF_Hz BF_Hz], [min(ylim) mean(ylim)], 'r*', 'MarkerSize', 10, 'LineWidth', 2);


subplot(222)
plot(tPost, sigPost);
title('After Resampling')

yyaxis right;
[splVals, timeVals] = gen_get_spl_vals(sigPost, fs, 20e-3, .5);
plot(timeVals, splVals, 'd-', 'MarkerSize', 12, 'LineWidth', 3);

subplot(224);
plot_dpss_psd(sigPost, fs, 'yrange', 70)
xlim([75 fs/2]);
set(gca, 'XTick', xtick_vals, 'XTickLabel', xtick_labs);
ylabel(feature_name);
hold on;
plot([BF_Hz BF_Hz], [min(ylim) mean(ylim)], 'r*', 'MarkerSize', 10, 'LineWidth', 2);
set(findall(gcf,'-property','FontSize'),'FontSize', 14);

end


function vecOut= gen_rescale(vecIn, newSPL, verbose)

if ~exist('verbose', 'var')
    verbose=0;
end

if ~ismember(size(vecIn,2), [1,2])
    error('signal should be a one or two column matrix');
end

pRef= 20e-6; % for re. dB SPl
vecOut= nan(size(vecIn));
for chanVar= 1:size(vecIn, 2)
    if any(vecIn(:,chanVar))
        oldSPL= 20*log10(rms(vecIn(:,chanVar))/pRef);
        gainVal= 10^( (newSPL-oldSPL)/20 );
    else
        gainVal =0;
    end
    vecOut(:,chanVar)= vecIn(:,chanVar)*gainVal;
end

if verbose
    fprintf('Signal RMS= %.1f (Desired %.1f) \n', 20*log10(rms(vecOut)/pRef), newSPL);
end
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

