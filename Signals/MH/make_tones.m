% Written by MH 10/24/03
% generates tone WAV files to debug NI board


Nstim=10;
Fs=100000;
dur=.3;

time=0:1/Fs:dur-1/Fs;

LOWfreq=500;
int=1/12;

freqs=LOWfreq*(2^int).^(0:Nstim-1);
tone_stim=cell(1,Nstim);

for i=1:Nstim
   tone_stim{i}=0.999*sin(2*pi*freqs(i)*time);
   filenameStr=sprintf('test_tone%d.wav',i);
   wavwrite(tone_stim{i}, Fs, filenameStr);
   
end

