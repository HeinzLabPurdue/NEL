% Stim generation for SFOAE

% Set parameters of stimulus: 
stim.fmin = 500; %stim.cf/sqrt(2); % 1/2 octave below
stim.fmax = 16000; %stim.cf*sqrt(2); % 1/2 octave above
stim.speed = -1; % oct/sec downsweep
stim.diff = 50; % Hz (Fprobe - 50 = Fsupp; Probe is higher)
stim.buffdur = 0.1; %seconds; for either side of sweep
stim.drop_Probe = 60; % for 40dB probe
stim.drop_Supp = 40; % for 60dB suppressor

% Trial params
stim.SNRcriterion = 6;
stim.minTrials = 1;
stim.maxTrials = 3;
stim.ThrowAway = 1;

% Standard params
stim.Fs = 48828.125;

% some values for analysis can be changed here: 
stim.analysis.windowdur = 0.040; % 40ms in paper
stim.analysis.offsetwin = 0.02; % 20ms in paper
stim.analysis.npoints = 512;

% Create actual stimulus 
if stim.speed < 0 %downsweep
    f1 = stim.fmax;
    f2 = stim.fmin;
else
    f1 = stim.fmin;
    f2 = stim.fmax;
end

buffdur = stim.buffdur; 
Fs = stim.Fs;
dur = log2(stim.fmax/stim.fmin) / abs(stim.speed) + (2*stim.buffdur);
t = 0: (1/Fs): (dur - 1/Fs);
stim.t = t;

buffinst1 = find(t < stim.buffdur, 1, 'last');
buffinst2 = find(t > (dur-stim.buffdur) , 1, 'first');

% Create probe
start_probe = f1*t(1:buffinst1);
buffdur_exact = t(buffinst1);
phiProbe_inst = f1 * (2.^( (t-buffdur_exact) * stim.speed) - 1) / (stim.speed * log(2)) + start_probe(end);
end_probe = f2*t(1:(length(t)-buffinst2+1)) + phiProbe_inst(buffinst2);
phiProbe_inst(1:buffinst1) = start_probe;
phiProbe_inst(buffinst2:end) = end_probe;

phiSupp_inst = phiProbe_inst - stim.diff*t;

stim.yProbe = scaleSound(rampsound(cos(2 * pi * phiProbe_inst), stim.Fs, 0.005));
stim.ySupp = scaleSound(rampsound(cos(2 * pi * phiSupp_inst), stim.Fs, 0.005));
stim.phiProbe_inst = phiProbe_inst;
stim.phiSupp_inst = phiSupp_inst;
