function [out_env env_amp tfs_amp fm_sum fc_sum fm_p1 fc_p1 fc_sb noise] = ffr_noplot(x,isOLD)
% FFR_NOPLOT
% Accepts a figure from NEL, and outputs various calculations of envelope
% and TFS magnitudes. Plots four figures.  
% 1: averaged per polarity, envelope, and fine structure with smoothing
%    tracings
% 2: hamming transformed data of the envelope and TFS
% 3: FFT of each polarity, and FFT of hamming transformed envelope and TFS
% 4: FFT of hamming transformed envelope and TFS, with labeled noise floor,
%    carrier frequency, modulation frequency, and sidebands and harmonics
%    included in fc_sum and fm_sum, respective
%--------------------------------------------------------------------------
% OUTPUTS:
% out_env -     envelope (average of alternating polarities)
%
% env_amp -     peak to peak amplitude of the smoothed envelope
%                 Estimate is OK, but not the best
%
% tfs_amp -     peak to peak amplitude of the smoothed TFS
%                 Estimate is TERRIBLE, do not use
%
% fm_sum  -     sum of the first (iLimit) fundamental and harmoic
%               frequencies of the FFT of the hamming transformed envelope
%                 Estimate is GOOD, probably the best
%
% fc_sum  -     sum of the fundamental and sidebands frequencies of the FFT
%               of the hamming transformed TFS
%                 Estimate is GOOD, probably the best
%
% fm_p1   -     first fundamental of the FFT of the hamming transformed
%               envelope
%                 Estimate is GOOD, on par with fm_sum
%
% fc_p1   -     fundamental of the FFT of the hamming transformed TFS
%                 Estimate is GOOD, on par with fc_sum
%
% fc_sb   -     side bands of the FFT of the hamming transformed TFS
%                 Not a good estimate by itself, can be used with fc_p1
%
% noise   -     noise to signal ratio (NSR), in dB. If no noise, NaN
%--------------------------------------------------------------------------
% INPUT: a MATLAB file storing the pic data obtained from NEL
%
%--------------------------------------------------------------------------
%
% 
% Code is the exact same as FFR, only does not plot when going through the
% data files.

% Ziwei Zhong on 6 Jul 2012
%

close all;

% time
t=[0:(1/x.Stimuli.RPsamprate_Hz):x.Stimuli.FFR_Gating.FFRlength_ms/1000];

% If there is more than one iteration for each polarity, takes the average
% of iterations.
avgNP = 0;
avgPO = 0;
for i = 1:length(x.Stimuli.RunLevels_params.attenMask)
    avgNP = avgNP * (i-1)/i + (x.AD_Data.AD_Avg_NP_V{i}) * (1/i);
    avgPO = avgPO * (i-1)/i + (x.AD_Data.AD_Avg_PO_V{i}) * (1/i);
end

% removing the final data point (incorrect due to DC offset)
avgNP = avgNP(1:(length(avgNP)-1));
avgPO = avgPO(1:(length(avgPO)-1));
t = t(1:(length(t)-1));
% removing the DC offset
avgNP = avgNP - mean(avgNP);
avgPO = avgPO - mean(avgPO);

% Checks for whether noise was present or not, if not present, noise level
% is NaN.
if x.Stimuli.noNoise
    noise = NaN;
else
    noise = x.Stimuli.noiseLevel;
end

% changes frequency to kHz
fc = x.Stimuli.fc/1000;
fm = x.Stimuli.fm/1000;

% OLD data, as defined prior to a certain date in the output file, was
% collected incorrectly, thus, the following correction code
if ~isOLD
% Change back to the following two lines for data gathered correctly
    env = 0.5*(avgNP+avgPO);
    tfs = 0.5*(avgNP-avgPO);
else
% INCORRECT temporary implementation of envelope and TFS
    env = avgPO;
    tfs = avgNP;
end

% outputted envelope before hamming transformation
out_env = env;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Part 1: OVERALL SIGNALS
% Estimates using smooting function.

% x1/x2 - starting and ending indicies
% needs to be changed for different sampling rates, rough estimates for 48kHz
% can be generalized with edits in code.
x1 = round(20*7000/150);
x2 = round(x.Stimuli.FFR_Gating.duration_ms*7000/150);
% x1p - starting index for smoothing function to estimate height
x1p = round(40*7000/150);

% smoothing curve and overlay
tp = t(x1p:x2);
env_noham = env(x1p:x2);
tfs_noham = tfs(x1p:x2);
smoothENV = ksr(tp,env_noham,5e-4);
smoothTFS = ksr(tp,tfs_noham,1e-5);

% Finding the amplitude from smoothed functions.  May be a good estimate
% for envelope, but terrible estimate (as of now) for carrier frequencies,
% especially higher frequencies
l = length(smoothENV.f);
env_amp = (0.5)*(max(smoothENV.f(0.1*l:0.9*l))-min(smoothENV.f(0.1*l:0.9*l)));
tfs_amp = (0.5)*(max(smoothTFS.f(0.1*l:0.9*l))-min(smoothTFS.f(0.1*l:0.9*l)));


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Part 2: CROPPED SIGNAL (strongest FFR response to AM signal)

t = t(x1:x2);
env = 1.855*hamming(x2-x1+1)'.*env(x1:x2);
tfs = 1.855*hamming(x2-x1+1)'.*tfs(x1:x2);
avgNP = avgNP(x1:x2);
avgPO = avgPO(x1:x2);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Part 3: FFTs (of the previously defined regions)

fftpts = length(t);
freq=(x.Stimuli.RPsamprate_Hz/2*linspace(0,1,fftpts/2+1))/1000;

% FFT of each polarity
NPfft=fft(avgNP,fftpts)/fftpts;
NPamp = abs(2*NPfft(1:(fftpts/2+1)));
NPmag = 20*log10(NPamp);

POfft=fft(avgPO,fftpts)/fftpts;
POamp = abs(2*POfft(1:(fftpts/2+1)));
POmag = 20*log10(POamp);


% FFT of envelope and TFS
ENVfft=fft(env,fftpts)/fftpts;
ENVamp = abs(2*ENVfft(1:(fftpts/2+1)));

TFSfft=fft(tfs,fftpts)/fftpts;
TFSamp = abs(2*TFSfft(1:(fftpts/2+1)));
TFSmag = 20*log10(TFSamp);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Part 4: FFT amplitude calculations

% finding the amplitudes
fm_sum = 0;
fc_sum = 0;

% magnitude factor, if the harmonics are above this percentage of the
% fundamental frequency, it is added to the magnitude.
% mag_fact = 0.15; 
% NEW VARIABLE: Replaced mag_fact with noise_floor   %zz 7 Apr 2012
% iLimit is the maximum number of harmonics to take
noise_floor = 5 * mean(ENVamp);
iLimit = 3;

%--------------------------------------------------------------------------
% Amplitude of the Envelope

% FUNDAMENTAL FREQUENCY
fm_amp(1) = max(ENVamp(find(freq>(fm*(0.75))&freq<(fm*(1.25))))); 
% FIRST HARMONIC
fm_amp(2) = max(ENVamp(find(freq>(1.75*fm)&freq<(2.25*fm))));
i = 2;
fm_sum = fm_amp(1);

num_hmon = 1;

    
% FINDING MORE HARMONICS IF NECESSARY
%  this occurs when the amplitude of the next harmonic is at least mag_fact
%  times as large as the primarly amplidue (modulation frequency)
%  NOTE: probably not optimized
while fm_amp(i) > (noise_floor) && ((i+1) * fm) < fc && i <= iLimit
    fm_sum = fm_sum + fm_amp(i);
    num_hmon = i;
    i = i + 1;
    fm_amp(i) = max(ENVamp(find(freq>((i-0.25)*fm)&freq<((i+0.25)*fm))));
end

% height of the first peak
fm_p1 = fm_amp(1);

%--------------------------------------------------------------------------
% Amplitude of the Carrier

% Similar to a previous instance, because data was collected with mistakes,
% the following code was inserted to correct for the code
if isOLD
    TFSamp = ENVamp;
end

% Finding the fundamentals and sidebands
fc_amp(1) = max(TFSamp(find(freq>(fc-0.5*fm)&freq<(fc+0.5*fm)))); % fundamental
fc_amp(2) = max(TFSamp(find(freq>(fc-1.5*fm)&freq<(fc-0.5*fm)))); % side band
fc_amp(3) = max(TFSamp(find(freq>(fc+0.5*fm)&freq<(fc+1.5*fm)))); % side band

% adding the fc side bands if they are great enough magnitude
if fc_amp(2) > noise_floor || fc_amp(3) > noise_floor
    fc_sum = sum(fc_amp);

    fc_p1 = fc_amp(1);               %first peak
    fc_sb = fc_amp(2) + fc_amp(3);   %side bands
else
    fc_sum = fc_amp(1);

    fc_p1 = fc_amp(1);
    fc_sb = 0;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%





