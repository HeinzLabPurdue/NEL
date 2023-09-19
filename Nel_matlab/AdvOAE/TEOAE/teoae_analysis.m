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


end
