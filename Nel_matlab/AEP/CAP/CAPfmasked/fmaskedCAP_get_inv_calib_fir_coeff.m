function [b, dBSPL_ideal]=fmaskedCAP_get_inv_calib_fir_coeff(calibPicNum, plotYes)
%This function is almost the same as get_inv_calib_fir_coeff. It uses a
%larger number of coefficients, and also has a different strategy for the
%filter gain (=1 for broadband noise).
co= [  0    0.4470    0.7410
    0.8500    0.3250    0.0980
    0.9290    0.6940    0.1250
    0.4940    0.1840    0.5560
    0.4660    0.6740    0.1880
    0.3010    0.7450    0.9330
    0.6350    0.0780    0.1840];
set(groot,'defaultAxesColorOrder',co);


if ~exist('plotYes', 'var')
    plotYes= false;
end

cdd;

data= loadpic(calibPicNum);
data=data.CalibData;

freq_kHz=data(:,1);
dBspl_at0dB_atten=data(:,2);

%% figure out inverse filter gains
% ER2 technical specs says gain at 1V rms should be 100 dB
% https://www.etymotic.com/auditory-research/insert-earphones-for-research/er2.html
% We are playing = 10V pp (TDT max Output)
% RMS= 10/sqrt(2); : should be ~(100+17)=~117 dB
% 117 dB: too loud. So set ideal dB SPL to something between 90-100 dB
%dBSPL_ideal= 105; 

%Different strategy here, gain of the inverse filter is set to 1 for a broadband noise
ind=(freq_kHz>0.2)&(freq_kHz<13);
mean_sq=mean(db2mag(-2*dBspl_at0dB_atten(ind)));
dBSPL_ideal=-10*log10(mean_sq);
filter_gain= dBSPL_ideal-dBspl_at0dB_atten;

% Suppress high frequency gain (Taper to zero?)
freq_near13k= dsearchn(freq_kHz, 13);
filter_gain(freq_near13k:end)= filter_gain(freq_near13k);


%% design filter
fs=  48828.125;
Nfilter= 1023;
b = fir2(Nfilter, [0; freq_kHz; 20; fs/2/1e3]/(fs/2/1e3), [db2mag(filter_gain(1)); db2mag(filter_gain); db2mag(filter_gain(end)); 0]);
% b = fir2(Nfilter, [0; .1; freq_kHz; 20; fs/2/1e3]/(fs/2/1e3), [0; 0; db2mag(filter_gain-max(filter_gain)); 0; 0]);
% b_nogain = fir2(Nfilter, [0; .1; freq_kHz; 20; fs/2/1e3]/(fs/2/1e3), [1; 1; db2mag(zeros(size(filter_gain))); 0; 0]);
b_nogain= [1 zeros(1, Nfilter)];


% freqz(b)
if plotYes
    figure(5)
    freqz(b_nogain,1,2056, fs)
    title('No gain filter')
  
    figure(6)
    freqz(b,1,2056, fs)
    title('Inverted gain filter')
end

[gd, w]= grpdelay(b,1,2056, fs);

%% plot
if plotYes
    figure(1); clf;
    xtick_vals= [.1 .2 1 3 10 16];
    fSize= 16;
    xtick_labs= cellfun(@(x) num2str(x), num2cell(xtick_vals), 'UniformOutput', false);
    
    ax(1)=subplot(311);
    semilogx(freq_kHz*1e3, filter_gain, 'linew', 2);
    grid on;
    set(gca, 'FontSize', fSize, 'XTick', xtick_vals, 'XTickLabel', xtick_labs);
    xlabel('freq (kHz)');
    
    
    figure(2); clf;
    freqz(b,1, 2^10, fs);
    [H,W]= freqz(b,1, 2^10, fs);
    
    figure(1);
    ax(2)=subplot(312);
    plot(W, unwrap(angle(H)));
    grid on;
    set(gca, 'XScale', 'log');
    
    title(sprintf('mean group delay  (below 10kHz)= %.1f ms',  mean(gd(w<10e3))/fs*1e3));
    
    
end
b=b'; %#ok<*NASGU>
b_nogain=b_nogain';

rdd;
