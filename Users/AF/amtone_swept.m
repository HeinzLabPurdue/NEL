
function [samtone,fs,filename]=amtone_swept(fc,fm,sweep_direction)


% sweep_direction=1;

if sweep_direction == 1
        depth_start = -36;  % Starting modulation depth for upward sweep
        depth_end = 0;      % Ending modulation depth for upward sweep
    elseif sweep_direction == 2
        depth_start = 0;    % Starting modulation depth for downward sweep
        depth_end = -36;    % Ending modulation depth for downward sweep
    else
        error('Invalid sweep direction. Use 1 for upward sweep or 2 for downward sweep.');
end
    


fs=81920;

t = [0:0.5*fs]'/fs;


%%% AF holding for removing onset and offset maybe zero for now
% hold_duration_sec=0;
% hold_samples = round(hold_duration_sec * fs);
%  % Step 4: Ensure the hold duration does not exceed the total stimulus duration
     total_samples = length(t);  % Total number of samples in the stimulus
%     if 2 * hold_samples > total_samples
%         error('Hold duration is too long for the total stimulus duration.');
%     end
    
     % Step 5: Define the continuous modulation depth over the stimulus duration
%     depth_cont = zeros(1, total_samples);  % Initialize modulation depth
%     depth_cont(1:hold_samples) = depth_start;  % Hold at start
    sweep_length = total_samples;% - 2 * hold_samples;  % Number of samples for the sweep
    depth_sweep = depth_start + (depth_end - depth_start) * linspace(0, 1, sweep_length);  % Linear sweep
%     depth_cont(hold_samples+1:hold_samples+sweep_length) = depth_sweep;  % Apply sweep
%     depth_cont(hold_samples+sweep_length+1:end) = depth_end;  % Hold at end

    % Step 6: Calculate the modulation index (based on the depth in dB)
    m = 20.^(depth_sweep / 20);  % Convert dB depth to modulation index
    m=m(:);
       % Step 7: Generate the carrier and modulator signals
    carrier = sin(2 * pi * fc * t);        % Carrier signal
    modulator = sin(2 * pi * fm * t);      % Modulator signal

    % Step 8: Create the swept stimulus
    stim_swept = (1 + m .* modulator) .* carrier;  % Modulated carrier signal
%     stim_swept = 20e-6 * 10^(level / 20.0) * stim_swept / rms(stim_swept);  % Scale to desired level (dB SPL)

    % Step 9: Calculate gain based on modulation index and normalize the stimulus
    A = 1;  % Amplitude scaling factor
    Gain = A ./ (sqrt(1 + 0.5 * m.^2));  % Gain calculation
    stim_swept = Gain .* stim_swept;  % Apply gain to normalize the stimulus
y=stim_swept;
    


%y=C*(1+M*sin (wm*t)).*cos (wc*t);
% y=(1+M*sin (wm*t)).*sin (wc*t);



 %Y=(1+M*sin (2*pi*fm*t)).*cos (2*pi*fc*t);
if sweep_direction == 1
       filename=sprintf('SAMtone_CF%0.3f_swept_upward_fm%0.4f.wav',fc/1000,fm/1000);
    elseif sweep_direction == 2
       filename=sprintf('SAMtone_CF%0.3f_swept_downward_fm%0.4f.wav',fc/1000,fm/1000);
    
end
    
% filename=sprintf('SAMtone_CF%0.3f_swept_fm%0.4f.wav',fc/1000,fm/1000);
%RMS=sqrt(mean(y.^2));
% samtone=(y*(10^(level/20)*20e-6))/RMS;

samtone=y/max(abs(y))*0.99; %changed on 06/25/2007 

% y2=y/max(y);
% y2(find(y2>=1))=0.95*y2(find(y2>=1));
% y2(find(y2<=-1))=-0.95*y2(find(y2<=-1));
% samtone=y2;



