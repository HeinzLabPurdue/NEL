function res = sweptSFOAE_analysis(stim)

windowdur = 0.06;
offsetwin = 0.0;
npoints = 512;


phiProbe_inst = 2*pi*stim.phiProbe_inst;
t = stim.t;

% downward vs upward sweeps
if stim.speed < 0
    f1 = stim.fmax;
    f2 = stim.fmin;
else
    f1 = stim.fmin;
    f2 = stim.fmax;
end

% set freq we're testing and the timepoints when they happen.
if stim.speed < 20
    testfreq = 2 .^ linspace(log2(f1), log2(f2), npoints);
    t_freq = log2(testfreq/f1)/stim.speed + stim.buffdur;
else
    testfreq = linspace(f1, f2, npoints);
    t_freq = (testfreq-f1)/stim.speed + stim.buffdur;
end

durs = .038*(2.^(-0.3*t_freq)-1)/ (-0.3*log(2)) + 0.038;

%% Artifact rejection

% Cancel out stimulus
SFOAEtrials = stim.ProbeBuffs + stim.SuppBuffs - stim.BothBuffs;
trials = size(SFOAEtrials,1);

% high pass filter the response (can also be done on ER10X hardware)
filtcutoff = 300;
b = fir1(1000, filtcutoff*2/stim.Fs, 'high');
SFOAEtrials= filtfilt(b, 1, SFOAEtrials')';

% Set empty matricies for next steps
coeffs = zeros(npoints, 6);
a_temp = zeros(trials, npoints);
b_temp = zeros(trials, npoints);

% Least Squares fit of SF Only for AR
for x = 1:trials
    SFOAE = SFOAEtrials(x, :);
    fprintf(1, 'Checking trial %d / %d for artifact\n', x, trials);
    
    for k = 1:npoints
        windowdur = durs(k);
        win = find( (t > (t_freq(k) - windowdur/2)) & ...
            (t < (t_freq(k) + windowdur/2)));
        taper = hanning(numel(win))';
        model_sf = [cos(phiProbe_inst(win)) .* taper;
            -sin(phiProbe_inst(win)) .* taper];
        resp = SFOAE(win) .* taper;
        coeffs(k, 1:2) = model_sf' \ resp';
    end
    a_temp(x,:) = coeffs(:, 1);
    b_temp(x,:) = coeffs(:, 2);
end

oae = abs(complex(a_temp, b_temp));

median_oae = median(oae);
std_oae = std(oae);
resp_AR = SFOAEtrials;
for j = 1:trials
    for k = 1:npoints
        if oae(j,k) > median_oae(1,k) + 4*std_oae(1,k)
            win = find( (t > (t_freq(k) - durs(k).*.1)) & ...
                (t < (t_freq(k) + durs(k).*.1)));
            resp_AR(j,win) = NaN;
        end
    end
end


%% Calculate the Noise Floor (two ways)
numOfTrials = floor(trials/2)*2; % need even number of trials
% first method, subtraction
for y = 1:2:numOfTrials
    pos_SF(ceil(y/2),:) = resp_AR(y,:);
    neg_SF(ceil(y/2),:) = resp_AR(y+1,:);
end

numTrials2 = floor(numOfTrials/4).*2;
pos_noise = zeros(numTrials2/2, size(pos_SF,2));
neg_noise = zeros(numTrials2/2, size(pos_SF,2));
for x = 1:2:numTrials2
    pos_noise(ceil(x/2),:) = (pos_SF(x, :) - pos_SF(x+1, :)) / 2;
    neg_noise(ceil(x/2),:) = (neg_SF(x, :) - neg_SF(x+1, :)) / 2;
end

noise = [pos_noise; neg_noise];

SFOAE = mean(resp_AR, "omitNaN"); % mean SFOAE after artifact rejection
NOISE = mean(noise, "omitNaN"); % mean SFOAE after artifact rejection

%% LSF Analysis

% Set empty matricies for next steps
maxoffset = ceil(stim.Fs * offsetwin);
coeffs = zeros(npoints, 2);
coeffs_n = zeros(npoints, 2);
tau = zeros(npoints, 1);
coeffs_noise = zeros(npoints,8);

durs = .038*(2.^(-0.3*t_freq)-1)/ (-0.3*log(2)) + 0.038;
stim.windowdur = durs; 

% Generate model of chirp and test against response
for k = 1:npoints
    fprintf(1, 'Running window %d / %d\n', k, (npoints));
    windowdur = durs(k);
    win = find( (t > (t_freq(k)-windowdur/2)) & ...
        (t < (t_freq(k)+windowdur/2)));
    taper = hanning(numel(win))';
    
    % set the models
    
    % SF probe frequency
    model = [cos(phiProbe_inst(win)) .* taper;
        -sin(phiProbe_inst(win)) .* taper];
    
    % nearby frequencies for nf calculation
    
    if stim.speed > 0
        nearfreqs = [1.10, 1.12, 1.14, 1.16];
    else
        nearfreqs = [.90, .88, .86, .84];
    end
    
    model_noise = [cos(2*pi*nearfreqs(1)*phiProbe_inst(win)) .* taper;
        -sin(2*pi*nearfreqs(1)*phiProbe_inst(win)) .* taper;
        cos(2*pi*nearfreqs(1)*phiProbe_inst(win)) .* taper;
        -sin(2*pi*nearfreqs(1)*phiProbe_inst(win)) .* taper;
        cos(2*pi*nearfreqs(1)*phiProbe_inst(win)) .* taper;
        -sin(2*pi*nearfreqs(1)*phiProbe_inst(win)) .* taper;
        cos(2*pi*nearfreqs(1)*phiProbe_inst(win)) .* taper;
        -sin(2*pi*nearfreqs(1)*phiProbe_inst(win)) .* taper];
    
    
    % zero out variables for offset calc
    coeff = zeros(maxoffset, 2);
    coeff_n = zeros(maxoffset, 2);
    resid = zeros(maxoffset, 1);
    coeff_noise = zeros(maxoffset, 8);
    
    for offset = 0:maxoffset
        resp = SFOAE(win+offset) .* taper;
        resp_n = NOISE(win+offset) .* taper;
        
        coeff(offset + 1, :) = model' \ resp';
        coeff_n(offset + 1, :) = model' \ resp_n';
        coeff_noise(offset +1, :) = model_noise' \ resp';
        
        resid(offset +1) = sum( (resp - coeff(offset+1, :) * model).^2);
    end
    
    [~, ind] = min(resid);
    
    coeffs(k, :) = coeff(ind, :);
    coeffs_n(k, :) = coeff_n(ind, :);
    coeffs_noise(k,:) = coeff_noise(ind,:);
    
    tau(k) = (ind - 1) * (1/stim.Fs); % delay in sec
    
end

%% Amplitude and delay calculations
a = coeffs(:, 1);
b = coeffs(:, 2);
a_n = coeffs_n(:, 1); % subtraction nf
b_n = coeffs_n(:, 2);

phi = tau.*testfreq'; % cycles (from delay/offset)
phasor = exp(-1j * phi* 2 * pi);

% for noise
noise2 = zeros(npoints,4);
for i = 1:2:8
    noise2(:,ceil(i/2)) = complex(coeffs_noise(:,i), coeffs_noise(:,i+1));
end

oae_complex = complex(a, b).*phasor;
noise_complex2 = complex(a_n, b_n);
noise_complex = mean(noise2,2);
res.multiplier = stim.VoltageToPascal.* stim.PascalToLinearSPL;
drawnow;

%% Plot resulting figure
figure;
plot(testfreq/1000, db(abs(oae_complex).*res.multiplier), 'linew', 1.75);
hold on;
plot(testfreq/1000, db(abs(noise_complex).*res.multiplier), '--', 'linew', 1.5);
title('SFOAE') 
set(gca, 'XScale', 'log', 'FontSize', 14)
xlim([.5, 16])
xticks([.5, 1, 2, 4, 8, 16])
xlabel('Frequency (kHz)')
ylabel('Amplitude (dB SPL)')
legend('SFOAE', 'NF')

%% Save result function
res.windowdur = windowdur;
res.offsetwin = offsetwin;
res.npoints = npoints;
res.avgSFOAEresp = SFOAE;   % average mic response
res.avgNOISEresp = NOISE;
res.t_freq = t_freq;
res.f = testfreq;           % frequency vectors
res.a = a;                  % coefficients
res.b = b;
res.a_n = a_n;
res.b_n = b_n;
res.stim = stim;
res.tau = tau;
res.phasor = phasor; 

res.multiplier = stim.VoltageToPascal.* stim.PascalToLinearSPL;
res.complex.oae = oae_complex; 
res.complex.nf = noise_complex; 
res.complex.nf2 = noise_complex2; 

end