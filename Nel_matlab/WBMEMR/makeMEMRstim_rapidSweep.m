function stim = makeMEMRstim_rapidSweep


stim.Fs = 48828.125;        % ms
stim.fBand = [500 8500];    % elicitor band (Hz)
stim.sweepDur = 8;          % seconds per sweep
stim.nSweeps = 15;          % total sweeps
stim.clickRate = 20;        % clicks / s
stim.clickDur = 0.0002;     % 0.2 ms
stim.clickAmp = 0.95;% 0.02;       % linear amplitude (≈ 96 dB pSPL)
stim.maxLevel = 110;         % SPL top of ramp
stim.minLevel = 40;          % SPL bottom of ramp


stim.clickatt = 12;
stim.noiseatt = 60;


Fs = stim.Fs;
t = 0:1/Fs:stim.sweepDur-1/Fs;

%% --- Noise carrier (band-limited) ---
noise = randn(size(t));
[b,a] = butter(4, stim.fBand/(Fs/2), 'bandpass');
noise = filter(b,a,noise);

%% --- Click train (probe) ---
click = zeros(size(t));
clickOnsets = round((0:1/stim.clickRate:stim.sweepDur-1/stim.clickRate)*Fs) + 1;
nClickPts   = round(stim.clickDur*Fs);

for c = 1:numel(clickOnsets)
    idx = clickOnsets(c):min(clickOnsets(c)+nClickPts-1, numel(click));
    click(idx) = stim.clickAmp;
end

%% --- Create linear level ramp envelope 40→110→40 dB ---
nSamps = numel(noise);
halfN = floor(nSamps/2);
L_up = linspace(stim.minLevel, stim.maxLevel, halfN);
L_down = linspace(stim.maxLevel, stim.minLevel, nSamps - halfN);
L_dB = [L_up L_down];       

env = 10.^((L_dB - 94)/20); % linear amplitude envelope
env = env / max(env);        % normalize to 1

%% --- Apply envelope to noise ---
noiseSweep = noise .* env;

%% --- Remove noise around each click (hole) ---
preClickDur = 0.003;    % seconds before click
postClickDur = 0.012;   % seconds after click
preN = round(preClickDur * Fs);
postN = round(postClickDur * Fs);

mask = ones(size(noiseSweep));  % start with all ones
clickIndex = find(click>0.01);  % indices of clicks

for ii = 1:length(clickIndex)
    idxStart = max(clickIndex(ii) - preN, 1);
    idxEnd = min(clickIndex(ii) + postN, numel(mask));
    mask(idxStart:idxEnd) = 0;
end

noiseSweep = noiseSweep .* mask;  % apply mask

 noiseSweep=0.95*(noiseSweep/max(noiseSweep));


%noise = rampsound(noise,fs,rampSize); AF : Do we ned this seems ramped
%already
% noiserms = rms(noiseSweep);
% noiserms = sqrt(mean(noiseSweep.^2));
% noiseSweep = (noiseSweep/noiserms) * 0.1;



%% --- Package for NEL playback ---
stim.noise = repmat(noiseSweep, stim.nSweeps, 1);  % right-channel buffer
stim.click = click;                                % left-channel buffer
stim.resplength = numel(click);
stim.nreps = 1;
stim.ThrowAway = 0;
stim.Averages = stim.nSweeps;

%% === Visualization of Rapid MEMR Stimulus with noise holes ===
% t = (0:stim.resplength-1)/stim.Fs;
% 
% % Make copies for plotting
% noiseSweep_plot = noiseSweep;  % zeros preserved for gaps
% clickTrain_plot = click;
% 
% % Scale for visualization only
% nonZeroNoise = noiseSweep(noiseSweep ~= 0);
% if isempty(nonZeroNoise)
%     maxNoise = 1;  % fallback to avoid division by zero
% else
%     maxNoise = max(abs(nonZeroNoise));
% end
% 
% noiseSweep_plot = noiseSweep_plot / maxNoise;  % scale so gaps visible
% clickTrain_plot = clickTrain_plot / stim.clickAmp;  % scale clicks to 1
% 
% figure('Name','Rapid MEMR Stimulus','Color','w');
% subplot(2,1,1)
% plot(t, noiseSweep_plot, 'b'); hold on
% plot(t, clickTrain_plot, 'r', 'LineWidth', 1);
% xlabel('Time (s)')
% ylabel('Amplitude (norm.)')
% title('Rapid MEMR Sweep (Noise + Clicks)')
% legend({'Sweeping Broadband Noise','Click Probe'}, 'Location','best')
% xlim([0 max(t)])
% ylim([-0.2 1.2])
% grid on
% 
% % Plot the level envelope in dB SPL equivalent (40→110→40)
% nSamps = length(noiseSweep_plot);
% t_env  = linspace(0, max(t), nSamps);
% halfN  = floor(nSamps/2);
% L_up   = linspace(stim.minLevel, stim.maxLevel, halfN);
% L_down = linspace(stim.maxLevel, stim.minLevel, nSamps - halfN);
% L_dB   = [L_up L_down];
% 
% subplot(2,1,2)
% plot(t_env, L_dB, 'LineWidth', 2)
% xlabel('Time (s)')
% ylabel('Elicitor Level (dB SPL)')
% title('Noise Envelope: 40 → 110 → 40 dB SPL')
% xlim([0 max(t_env)])
% ylim([30 115])
% grid on

end
