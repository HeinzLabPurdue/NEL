function [filename, filename_inv]=make_FM_tone(F0,Fs,T,rt,stimdb,fm_freq,fm_range,pol)

% % stimulus parameters
% F0 = 1e3;     % stimulus frequency in Hz
% Fs = 100e3;  % sampling rate in Hz (must be 100, 200 or 500 kHz)
% T  = 2500e-3;  % stimulus duration in seconds
% rt = 2.5e-3; % rise/fall time in seconds
% stimdb = 65; % stimulus intensity in dB SPL
%
% fm_freq=20;  % Frequency of FM
% fm_range=1;% Frequency range of FM
yesplot=0;
fs=Fs;

t = 0:1/Fs:T-1/Fs; % time vector
mxpts = length(t);
irpts = rt*Fs;

FMmod=fm_range/fm_freq*cos(2*pi*fm_freq*t);

Amp_car=sqrt(2)*20e-6*10^(stimdb/20);

pin = Amp_car*cos(2*pi*F0*t+FMmod); % unramped stimulus
pin(1:irpts)= pin(1:irpts).*(0:(irpts-1))/irpts;
pin((mxpts-irpts):mxpts)=pin((mxpts-irpts):mxpts).*(irpts:-1:0)/irpts;

pin=pin/max(pin)*.99;

if yesplot
    figure %#ok<UNRCH>
    subplot(2,1,1)
    plot(t,FMmod)
    subplot(2,1,2)
    plot(t,pin)
    
    sound([pin/max(pin) zeros(1,length(pin)/2)],Fs)
end

name_org=sprintf('FM_%d_%d_%g_%g_org.wav',F0,fm_freq,T*1000,fm_range);
name_inv=sprintf('FM_%d_%d_%g_%g_inv.wav',F0,fm_freq,T*1000,fm_range);
filename=fullfile('C:','NEL','Nel_matlab','AEP', 'FFR','Signals','AMwav',name_org);

audiowrite(filename, pin, round(fs));

% if signal needs to be polarized, creates the inverse signal
% otherwise, creates the same signal with the name inv zz 20oct11
if(pol)
    filename_inv=fullfile('C:','NEL','Nel_matlab','AEP', 'FFR','Signals','AMwav',name_inv);
    pin = -1 * pin;
    audiowrite(filename_inv, pin, round(fs));
else
    filename_inv=fullfile('C:','NEL','Nel_matlab','AEP', 'FFR','Signals','AMwav',name_inv);
    audiowrite(filename_inv, pin, round(fs));
end