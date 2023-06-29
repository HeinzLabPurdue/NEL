% MEMR Instruction Block

clickwin =          41.92; % ms
noisewin =          120; % ms
Fs =                48828.125;
rampdur =           5; %ms
fc =                4500; % 1 - 8 kHz
bw =                8000;
noiseramp =         5;
nreps =             7; % How many reps per trial

clickatt = 30;
clickatt = stim.clickatt + 6; % WITH HB7 USING DIFFERENTIAL OUPUT
noiseatt = 60:-6:0; %Note makeNBNoiseFFT returns RMS of -20 dB re: 1
noiseatt = stim.noiseatt + 6; % WITH HB7 USING DIFFERENTIAL OUPUT
ThrowAway = 1;
Averages = 32;
pad = 256; % Number of samples extra to read in after stim ends
nLevels = numel(stim.noiseatt);

clicksamps = ceil(stim.clickwin * 1e-3  * stim.Fs);


template = makeEqExNoiseFFT(stim.bw, stim.fc,...
    noisewin * 1e-3, Fs, noiseramp * 1e-3, 0);

tokenlength = numel(template);
totalsamps = clicksamps + tokenlength + stim.pad;
noise = zeros(nLevels, ThrowAway + Averages, totalsamps);

for L = 1:nLevels
    for m =  1: (ThrowAway + stim.Averages)
        noise(L, m, clicksamps + (1:tokenlength)) = ...
            makeNBNoiseFFT(stim.bw, fc,...
            noisewin * 1e-3, Fs,...
            noiseramp * 1e-3, 0);
        
    end
end



nsampsclick = 5;
initbuff =  floor(clicksamps/3);
click = zeros(1, totalsamps);
click(initbuff + (1:nsampsclick)) = 0.95;
t = (0:(totalsamps - 1)) / stim.Fs;
%% DPOAE

F2frqlo  =           0.500;	% low frequency (in kHz) bounds for data
F2frqhi  =           12.00;	% high frequency (in kHz) bounds for data
fstlin   =               0;	% # of linear frequency steps (set = 0 for log steps)
fstoct   =               6;	% # of log freq. steps (per oct. OR per 10-dB BW for Qspaced) (= 0 for lin steps; NEGATIVE for Qspaced)
ear      =               1;	% ear code (lft = 1, rgt = 2, both = 3
ToneOn   =            2000;	% duration of tone presentation (ms)
ToneOff  =            1000;	% duration of interstim interval (ms)
Fratio   =             1.2;	% ratio of F2/F1
ADdur    =       ToneOn+20;	% Duration to sample the microphone (add 20ms to allow for delays)
Nreps    =               4;	% Number of reps per condition
CalibSPL =             100;	% dB SPL corresponding to 0 dB attenuation for ER2 (assuming 5v peak, rather than 1v rms)

L2_dBSPL =        65; % dB SPL presentation level for F2  %edit MW 08-11-2015

L1_dBSPL =        75;	% dB SPL presentation level for F1  %edit MW 08-11-2015

MicGain  =              40; % dB gain on mic signal