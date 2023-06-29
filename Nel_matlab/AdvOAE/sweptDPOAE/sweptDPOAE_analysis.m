function res = sweptDPOAE_analysis(stim)

% Analyze swept tone DPOAE data using least-squares fit of chirp model

windowdur = stim.analysis.windowdur;
offsetwin = stim.analysis.offsetwin; % not finding additional delay
npoints = stim.analysis.npoints;

%% Set variables from the stim
phi1_inst = 2 * pi * stim.phi1_inst;
phi2_inst = 2 * pi * stim.phi2_inst;
phi_dp_inst = (2.*stim.phi1_inst - stim.phi2_inst) * 2 * pi;
rdp = 2 / stim.ratio - 1;    % f_dp = f2 * rdp

trials = size(stim.resp,1); 

t = stim.t;
if stim.speed < 0 % downsweep
    f_start = stim.fmax;
    f_end = stim.fmin;
else
    f_start = stim.fmin;
    f_end = stim.fmax;
end

% set freq we're testing and the timepoints when they happen.
if abs(stim.speed) < 20         % then in octave scaling
    freq_f2 = 2 .^ linspace(log2(f_start), log2(f_end), npoints);
    freq_f1 = freq_f2 ./ stim.ratio;
    freq_dp = 2.*freq_f1 - freq_f2;
    t_freq = log2(freq_f2/f_start)/stim.speed + stim.buffdur;
else                            % otherwise linear scaling
    freq_f2 = linspace(f_start, f_end, npoints);
    freq_f1 = freq_f2 ./ stim.ratio;
    freq_dp = 2.*freq_f1 - freq_f2;
    t_freq = (freq_f2-f_start)/stim.speed + stim.buffdur;
end

%% Artifact Rejection
% high pass filter the response (can also be done on ER10X hardware) 
%filtcutoff = 300;
%b = fir1(1000, filtcutoff*2/stim.Fs, 'high');
%DPOAEtrials= filtfilt(b, 1, stim.resp')';
DPOAEtrials = stim.resp;

% Set empty matricies for next steps
coeffs = zeros(npoints, 6);
a_temp = zeros(trials, npoints);
b_temp = zeros(trials, npoints);

% Least Squares fit of DP Only for AR
for x = 1:trials
    DPOAE = DPOAEtrials(x, :);
    fprintf(1, 'Checking trial %d / %d for artifact\n', x, (trials));
    
    for k = 1:npoints
        win = find( (t > (t_freq(k) - windowdur/2)) & ...
            (t < (t_freq(k) + windowdur/2)));
        taper = hanning(numel(win))';
        
        model_dp = [cos(phi_dp_inst(win)) .* taper;
            -sin(phi_dp_inst(win)) .* taper];
        
        resp = DPOAE(win) .* taper;
        
        coeffs(k, 1:2) = model_dp' \ resp';
    end
    a_temp(x,:) = coeffs(:, 1);
    b_temp(x,:) = coeffs(:, 2);
end

oae = abs(complex(a_temp, b_temp));

median_oae = median(oae);
std_oae = std(oae);
resp_AR = DPOAEtrials;
for j = 1:trials
    for k = 1:npoints
        if oae(j,k) > median_oae(1,k) + 4*std_oae(1,k)
            win = find( (t > (t_freq(k) - windowdur.*.1)) & ...
                (t < (t_freq(k) + windowdur.*.1)));
            resp_AR(j,win) = NaN;
        end
    end
end

%% Calculate Noise Floor

% First way to calculate noise floor, just subtracting alternate trials
numOfTrials = floor(trials/2)*2; % need even number of trials
noise = zeros(numOfTrials/2, size(resp_AR, 2));
for x = 1:2:numOfTrials
    noise(ceil(x/2),:) = (resp_AR(x,:) - resp_AR(x+1,:)) / 2;
end

DPOAE = mean(resp_AR, 1, "omitNaN");
NOISE = mean(noise,1, "omitNaN");


%% LSF analysis

% Set empty matricies for next steps
maxoffset = ceil(stim.Fs * offsetwin);
coeffs = zeros(npoints, 2);
coeffs_n = zeros(npoints, 2);
tau_dp = zeros(npoints, 1); % delay if offset > 0
coeffs_noise = zeros(npoints,8);
%durs = -.5*(2.^(0.003*t_freq)-1)/ (0.003*log(2)) + 0.5; 


% Least Squares fit of Chirp model (stimuli, DP, noise two ways)
for k = 1:npoints
    
    fprintf(1, 'Running window %d / %d\n', k, npoints);
    %windowdur = durs(k); 
    
    win = find( (t > (t_freq(k) - windowdur/2)) & ...
        (t < (t_freq(k) + windowdur/2)));
    taper = hanning(numel(win))';
    
    % nearby frequencies for nf calculation
    if stim.speed > 0
        nearfreqs = [1.10, 1.12, 1.14, 1.16];
    else
        nearfreqs = [.90, .88, .86, .84];
    end
    
    % set the models
    model_dp = [cos(phi_dp_inst(win)) .* taper;
        -sin(phi_dp_inst(win)) .* taper];
    model_f1 = [cos(phi1_inst(win)) .* taper;
        -sin(phi1_inst(win)) .* taper];
    model_f2 = [cos(phi2_inst(win)) .* taper;
        -sin(phi2_inst(win)) .* taper];
    model_noise = ...
        [cos(nearfreqs(1)*phi_dp_inst(win)) .* taper;
        -sin(nearfreqs(1)*phi_dp_inst(win)) .* taper;
        cos(nearfreqs(2)*phi_dp_inst(win)) .* taper;
        -sin(nearfreqs(2)*phi_dp_inst(win)) .* taper;
        cos(nearfreqs(3)*phi_dp_inst(win)) .* taper;
        -sin(nearfreqs(3)*phi_dp_inst(win)) .* taper;
        cos(nearfreqs(4)*phi_dp_inst(win)) .* taper;
        -sin(nearfreqs(4)*phi_dp_inst(win)) .* taper];
    
    % zero out variables for offset calc
    coeff = zeros(maxoffset, 6);
    coeff_n = zeros(maxoffset, 6);
    resid = zeros(maxoffset, 3);
    
    for offset = 0:maxoffset
        resp = DPOAE(win+offset) .* taper;
        resp_n = NOISE(win+offset) .* taper;
        
        % for model_dp
        coeff(offset + 1, 1:2) = model_dp' \ resp';
        coeff_n(offset + 1, 1:2) = model_dp' \ resp_n';
        resid(offset + 1, 1) = sum( (resp  - coeff(offset + 1, 1:2) * model_dp).^2);
    end
    
    resp = DPOAE(win) .* taper;
    resp_n = NOISE(win) .* taper;
    
    % for model_f1
    coeff(1, 3:4) = model_f1' \ resp';
    coeff_n(1, 3:4) = model_f1' \ resp_n';
    resid(1, 2) = sum( (resp  - coeff(1, 3:4) * model_f1).^2);
    
    % for model_f2
    coeff(1, 5:6) = model_f2' \ resp';
    coeff_n(1, 5:6) = model_f2' \ resp_n';
    resid(1, 3) = sum( (resp  - coeff(1, 5:6) * model_f2).^2);
    
    % for model_noise
    coeffs_noise(k,:) = model_noise' \ resp';
    
    [~, ind] = min(resid(:,1));
    coeffs(k, 1:2) = coeff(ind, 1:2);
    coeffs_n(k, 1:2) = coeff_n(ind, 1:2);
    coeffs(k, 3:6) = coeff(1,3:6);
    
    tau_dp(k) = (ind(1) - 1) * 1/stim.Fs; % delay in sec
end

%% Amplitude and Delay calculations
a_dp = coeffs(:, 1);
b_dp = coeffs(:, 2);
a_f1 = coeffs(:, 3);
b_f1 = coeffs(:, 4);
a_f2 = coeffs(:, 5);
b_f2 = coeffs(:, 6);
a_n = coeffs_n(:, 1);
b_n = coeffs_n(:, 2);

% for noise
noise2 = zeros(npoints,4);
for i = 1:2:8
    noise2(:,ceil(i/2)) = complex(coeffs_noise(:,i), coeffs_noise(:,i+1));
end

phi_dp = tau_dp.*freq_dp'; % cycles (from delay/offset)
phasor_dp = exp(-1j * phi_dp * 2 * pi);

oae_complex = complex(a_dp, b_dp);
noise_complex2 = complex(a_n, b_n);
noise_complex = mean(noise2,2);
res.multiplier = stim.VoltageToPascal.* stim.PascalToLinearSPL;

%% Plot Results Figure
figure;
plot(freq_f2/1000, db(abs(oae_complex).*res.multiplier), 'linew', 1.75);
hold on;
plot(freq_f2/1000, db(abs(noise_complex).*res.multiplier), '--', 'linew', 1.5);
%plot(freq_f2/1000, db(abs(noise_complex2).*res.multiplier));
%plot(freq_f2/1000, db(abs(complex(a_f2,b_f2)).*res.multiplier));
%plot(freq_f1/1000, db(abs(complex(a_f1, b_f1)).*res.multiplier));
title(sprintf('DPOAE Subj: %s, Ear: %s', string(subj), string(ear)))
set(gca, 'XScale', 'log', 'FontSize', 14)
xlim([.5, 16])
ylim([-40, 40])
xticks([.5, 1, 2, 4, 8, 16])
xlabel('F_2 Frequency (kHz)')
legend('DPOAE', 'NF')
drawnow; 


%% Save result function
res.windowdur = windowdur;
res.offsetwin = offsetwin;
res.npoints = npoints;
res.avgDPOAEresp = DPOAE;   % average mic response
res.avgNOISEresp = NOISE;
res.t_freq = t_freq;
res.f.f2 = freq_f2;         % frequency vectors
res.f.f1 = freq_f1;
res.f.dp = freq_dp;
res.a.dp = a_dp;            % coefficients
res.b.dp = b_dp;
res.a.f1 = a_f1;
res.b.f1 = b_f1;
res.a.f2 = a_f2;
res.b.f2 = b_f2;
res.a.n = a_n; % subtraction method
res.b.n = b_n;
res.tau.dp = tau_dp;
res.stim = stim;
res.subj = subj;
res.ear = ear;
res.complex.oae = oae_complex; 
res.complex.nf = noise_complex; 
res.complex.nf2 = noise_complex2; 

end