function [res] = teoae_analysis(click)

res.resp_win = click.resp(:, (click.StimWin+1):(click.StimWin + click.RespDur)); % Remove stimulus by windowing

resp = res.resp_win;

if click.doFilt
    % High pass at 200 Hz using IIR filter
    [b, a] = butter(4, 200 * 2 * 1e-3/click.SamplingRate, 'high');
    resp = filtfilt(b, a, res.resp_win')';
end

vavg_odd = trimmean(resp(1:2:end, :), 20, 1);
vavg_even = trimmean(resp(2:2:end, :), 20, 1);
rampdur = 0.2e-3; %seconds
Fs = click.SamplingRate/2 * 1e3;
res.vavg = rampsound((vavg_odd + vavg_even)/2, Fs, rampdur);
res.noisefloor = rampsound((vavg_odd - vavg_even)/2, Fs, rampdur);

Vavg = rfft(res.vavg);
Vavg_nf = rfft(res.noisefloor);

% Apply calibartions to convert voltage to pressure
% For ER-10X, this is approximate
mic_sens = click.mic_sens; % mV/Pa. TO DO: change after calibration
mic_gain = click.mic_gain;
P_ref = click.P_ref;
DR_onesided = click.DR_onesided;
factors = DR_onesided * mic_gain * mic_sens * P_ref;
output_Pa_per_20uPa = Vavg / factors; % unit: 20 uPa / Vpeak
noise_Pa_per_20uPa = Vavg_nf / factors;

res.freq = 1000*linspace(0,click.SamplingRate/2,length(Vavg))';

res.Resp =  output_Pa_per_20uPa;
res.NoiseFloor = noise_Pa_per_20uPa;

%% Plot the result somewhere too
figure;
hold on;

% plot norms
load('teoae_norms', 'upOAE', 'loOAE', 'upNF', 'loNF', 'f');
col = [237, 246, 252]./255;
colNF = [252, 237, 240]./255;
f = f/1e3; 
f(1) = f(2); 
fill([f, f(end), f(end:-1:1), f(1)], [loOAE, upOAE(end), upOAE(end:-1:1), loOAE(1)], col, 'linestyle', 'none')
hold on;
fill([f, f(end), f(end:-1:1), f(1)], [loNF, upNF(end), upNF(end:-1:1), loNF(1)], colNF, 'linestyle', 'none')
alpha(.8);

teoae_resp = db(abs(res.Resp)); 
nf_resp = db(abs(res.NoiseFloor)); 

% results
plot(res.freq/1e3, teoae_resp, '-', 'linew', 2, 'color', [0 0.4470 0.7410]);
plot(res.freq/1e3, nf_resp, '-', 'linew', 2, 'color', [0.6350 0.0780 0.1840]);
hold off; 
legend('OAE', 'NF');
title('TEOAE');
xlabel('Frequency (kHz)');
ylabel('Amplitude(dB)');
set(gca, 'XScale', 'log', 'FontSize', 14)
xlim([.5, 20])
xticks([.5, 1, 2, 4, 8, 16]);
ylim([-80, 30]);
yticks((-45:15:45))
grid on;

drawnow;
end
