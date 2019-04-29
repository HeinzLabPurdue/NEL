%% File: make_OBnoise_at500Hz.m
% M. Heinz
% Nov 4, 2009
% Modified from make_NBnoise_50at2k.m
%
%% Creates a WAV file with an octave-band noise centered at 500 Hz

clear

RMSnew=0;

Nbits=16;
sfreq=25e6/1024;  %=TDT ~25kHz
Npts=24405;   % ~ 1 sec duration

freq=(0:Npts-1)*sfreq/Npts;   %Full range of frequencies (positive and negative)
% BW=50;  %Hz
% CF=2000; %Hz
LFcut_Hz=500*2^-0.5;  %Hz
HFcut_Hz=500*2^0.5;  %Hz
BWinds=find((freq>=LFcut_Hz)&(freq<=HFcut_Hz));  % Indices within noise BW

% while (abs(RMSnew-RMSold)>0.001)

%% Generate 100 noise samples to check the distribution of RMS values, then
%% pick one closest to the mean (to avoid outliers wrt crest factor (peak to RMS))
Nnoises=100;
RMSvector=zeros(1,Nnoises);
SEEDvector=zeros(1,Nnoises);
NBnoises=zeros(Nnoises,Npts);

rand('state',208267);  %from 50-Hz noise, for historical purposes!
for i=1:100
	%%% RE-SEED each time, but in a repeatable way based on intial seed
	SEEDvector(i)=round(rand*100000);
	rand('state',SEEDvector(i));
	
	mag=zeros(1,Npts);
   phase=2*pi*(rand(1,Npts)-0.5);
   mag(BWinds)=1;
   
   fftNBnoise=mag.*exp(j*phase);   % Convert to complex DFT
   
   NBnoise=real(ifft(fftNBnoise));  % Make time domain signal
   NBnoise=0.99*NBnoise'/max(abs(NBnoise));  % Convert to WAV file format 
   
   RMSvector(i)=sqrt(mean(NBnoise.^2));
	NBnoises(i,:)=NBnoise;
   disp(sprintf('Noise # %d: seed=%8.f; RMSnew=%.4f',i,SEEDvector(i),RMSvector(i)))
end

meanRMS=mean(RMSvector);
stdRMS=std(RMSvector);
disp(sprintf('meanRMS=%.3f; stdRMS=%.3f',meanRMS,stdRMS))
%% FIND noise sample with RMS closest to the mean to avoid outliers
[yy,NOISEind]=min(abs(RMSvector-meanRMS));  %
disp(sprintf('NOISEind=%d, RMS=%.3f',NOISEind,RMSvector(NOISEind)))

NBnoise=NBnoises(NOISEind,:);

%%% Save stim to *.wav format
wavwrite(NBnoise,sfreq,Nbits,'OBnoise_at500Hz.wav')

%%%%%%%%% Play sounds %%%%%%%%%%%%%%%%%%

figure(1); clf
plot(1000*(0:Npts-1)/sfreq,NBnoise)
title(sprintf('%s: Max=%.4f; Min=%.4f; RMS=%.4f (seed=%8.f)','OBnoise_at500Hz.wav',max(NBnoise),min(NBnoise),sqrt(mean(NBnoise.^2)),SEEDvector(NOISEind)),'Interpreter','none')
grid on
ylabel('Amplitude')
xlabel('Time (msec)')
orient tall

x=input('Press Neter to hear OBnoise_at500Hz.wav:  ');
sound(NBnoise,sfreq)
x=input('Press Neter to hear OBnoise_at500Hz.wav REPEATED 3 times (?ANY CLICKS?):  ');
sound(repmat(NBnoise,1,3),sfreq)
pause(4)


%% %%%%%%%%%% Verify New file is OK %%%%%%%%%%%%%%%%%%%
%% %%%% Figures %%%%%%%%%%%
% Freq domain
figure(11); clf
subplot(221)
stem(freq,mag)
title(sprintf('%s\nGenerating OBnoise_at500Hz.wav',date),'Interpreter','none')
xlabel('Frequency (Hz)'); ylabel('Magnitude')
xlim([300 800])
subplot(223)
plot(freq,phase)
hold on
plot(freq(BWinds),phase(BWinds),'r')
hold off
xlabel('Frequency (Hz)'); ylabel('Phase (rad)')
xlim([300 800])
subplot(222)
stem(freq,abs(fftNBnoise))
title('FFT of IFFT (OK!!)')
xlabel('Frequency (Hz)'); ylabel('Magnitude')
xlim([300 800])
subplot(224)
plot(freq,angle(fftNBnoise))
xlabel('Frequency (Hz)'); ylabel('Phase (rad)')
xlim([300 800])
orient landscape

%% Time domain
% Verify no clicks at transition of concatenated noise (red to blue)
figure(2); clf
plot(1000*(0:2*length(NBnoise)-1)/sfreq,[NBnoise NBnoise])
hold on
plot(1000*(0:length(NBnoise)-1)/sfreq,NBnoise,'r')
hold off
title('OBnoise_at500Hz.wav','Interpreter','none')
grid on
xlabel('Time (msec)')
xlim([995 1005])
ylim('auto')
orient tall

%%%%%%%%%%%%% FFTs: 1 period with Nfft=Nstim
FFTfact=1;

NfftNB=round(FFTfact*length(NBnoise));
fftNB=fft(NBnoise,NfftNB);
freqNB=(0:NfftNB-1)*sfreq/NfftNB;

figure(3); clf
plot(freqNB,20*log10(abs(fftNB))-max(20*log10(abs(fftNB))))
title(sprintf('Nfft=Nstim (%d-pt) FFT: %s',NfftNB,'OBnoise_at500Hz.wav'),'Interpreter','none')
xlabel('Frequency (Hz)')
ylabel('Magnitude (dB re:max)')
xlim([0 5000])
ylim([-120 0])
orient tall

%%%%%%%%%%%%% FFTs with denser sampling: 1 period with Nfft=FFTfact*Nstim
FFTfact=2.7;

NfftNB=round(FFTfact*length(NBnoise));
fftNB=fft(NBnoise,NfftNB);
freqNB=(0:NfftNB-1)*sfreq/NfftNB;

figure(4); clf
plot(freqNB,20*log10(abs(fftNB))-max(20*log10(abs(fftNB))))
title(sprintf('Nfft=%.1f*Nstim (%d-pt) FFT: %s',NfftNB,'OBnoise_at500Hz.wav'),'Interpreter','none')
xlabel('Frequency (Hz)')
ylabel('Magnitude (dB re:max)')
xlim([0 5000])
ylim([-120 0])
orient tall

