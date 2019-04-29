% File: ISH_StimSetup.m
%
% M. Heinz
% Dec 14, 2008

clear

cd('C:\Documents and Settings\Mike\My Documents\Work\Research\R03 Experiments\Data Analysis\STMP Mfiles\ISHstim')

[BBN_A Fs1]=wavread('BBN_A');
[BBN_AN Fs2]=wavread('BBN_AN');
[BoyFell Fs3]=wavread('Speech');
[BoyFellN Fs4]=wavread('NSpeech');
Fs=Fs1;

RMS(1)=sqrt(mean(BBN_A.^2));
RMS(2)=sqrt(mean(BBN_AN.^2));
RMS(3)=sqrt(mean(BoyFell.^2));
RMS(4)=sqrt(mean(BoyFellN.^2));

MAXABS(1)=max(abs(BBN_A));
MAXABS(2)=max(abs(BBN_AN));
MAXABS(3)=max(abs(BoyFell));
MAXABS(4)=max(abs(BoyFellN));

PSD{1}=20*log10(abs(fft(BBN_A,Fs)));
PSD{2}=20*log10(abs(fft(BoyFell,Fs)));

h=spectrum.welch;
HPSD{1}=psd(h,BBN_A,'Fs',Fs);
HPSD{2}=psd(h,BoyFell,'Fs',Fs);

figure(1); clf
semilogx(PSD{1})
hold on
semilogx(PSD{2},'r')
title('OLD: BBN_A (blue); BoyFell (red)','Interpreter','none')
xlabel('Freq (Hz)')
ylabel('dB')
grid on
xlim([100 33000/2])
ylim([-25 55])

figure(2); clf
h1=plot(HPSD{1});
hold on
h2=plot(HPSD{2})
set(h2,'Color','r')
title('OLD: BBN_A (blue); BoyFell (red)','Interpreter','none')
xlim([.1 16.5])
set(gca,'XScale','log')

%% % TODO - 
% 1) Rescale to MAX out WAV file range
% 2) Make same length (1.7 sec)
% 3) Rename, and save

BBN_A_=BBN_A*0.999/MAXABS(1);
BBN_A_N=-BBN_A_;
BoyFell_=BoyFell(1:length(BBN_A_))*0.999/MAXABS(3);
BoyFell_N=-BoyFell_;

RMS2(1)=sqrt(mean(BBN_A_.^2));
RMS2(2)=sqrt(mean(BBN_A_N.^2));
RMS2(3)=sqrt(mean(BoyFell_.^2));
RMS2(4)=sqrt(mean(BoyFell_N.^2));

MAXABS2(1)=max(abs(BBN_A_));
MAXABS2(2)=max(abs(BBN_A_N));
MAXABS2(3)=max(abs(BoyFell_));
MAXABS2(4)=max(abs(BoyFell_N));

PSD2{1}=20*log10(abs(fft(BBN_A_,Fs)));
PSD2{2}=20*log10(abs(fft(BoyFell_,Fs)));
HPSD2{1}=psd(h,BBN_A_,'Fs',Fs);
HPSD2{2}=psd(h,BoyFell_,'Fs',Fs);

PSD2{3}=20*log10(abs(fft(BBN_A_N,Fs)));
PSD2{4}=20*log10(abs(fft(BoyFell_N,Fs)));
HPSD2{3}=psd(h,BBN_A_N,'Fs',Fs);
HPSD2{4}=psd(h,BoyFell_N,'Fs',Fs);

figure(3); clf
semilogx(PSD2{1})
hold on
semilogx(PSD2{2},'r')
title('NEW: BBN_A_ (blue); BoyFell_ (red)','Interpreter','none')
xlabel('Freq (Hz)')
ylabel('dB')
grid on
xlim([100 33000/2])
ylim([-25 55])

figure(4); clf
h12=plot(HPSD2{1});
hold on
h22=plot(HPSD2{2})
h32=plot(HPSD2{3});
h42=plot(HPSD2{4})
set(h22,'Color','r')
set(h32,'Color','b','LineWidth',2)
set(h42,'Color','r','LineWidth',2)
title('NEW: BBN_A_ (blue); BoyFell_ (red)','Interpreter','none')
xlim([.1 16.5])
set(gca,'XScale','log')

%% Zero-pad all stimuli to allow for STMP shifting up/down
BBN_A_=[BBN_A_' zeros(size(BBN_A_'))]';
BBN_A_N=[BBN_A_N' zeros(size(BBN_A_N'))]';
BoyFell_=[BoyFell_' zeros(size(BoyFell_'))]';
BoyFell_N=[BoyFell_N' zeros(size(BoyFell_N'))]';

%% SAVE out new WAV file
wavwrite(BBN_A_,Fs,'BBN_A_.wav');
wavwrite(BBN_A_N,Fs,'BBN_A_N.wav');
wavwrite(BoyFell_,Fs,'BoyFell_.wav');
wavwrite(BoyFell_N,Fs,'BoyFell_N.wav');


% - RMS is different due to zero-padding
%% TEST/VERIFY
[BBN_A_2 Fs1]=wavread('BBN_A_');
[BBN_A_N2 Fs2]=wavread('BBN_A_N');
[BoyFell_2 Fs3]=wavread('BoyFell_');
[BoyFell_N2 Fs4]=wavread('BoyFell_N');

RMS3(1)=sqrt(mean(BBN_A_.^2));
RMS3(2)=sqrt(mean(BBN_A_N.^2));
RMS3(3)=sqrt(mean(BoyFell_.^2));
RMS3(4)=sqrt(mean(BoyFell_N.^2));

MAXABS3(1)=max(abs(BBN_A_));
MAXABS3(2)=max(abs(BBN_A_N));
MAXABS3(3)=max(abs(BoyFell_));
MAXABS3(4)=max(abs(BoyFell_N));

MAXABS3(5)=max(abs(BBN_A_+BBN_A_N));
MAXABS3(6)=max(abs(BoyFell_+BoyFell_N));

figure; clf
subplot(611)
plot(BBN_A_)
title(sprintf('"BBN_A_.wav":  RMS = %.4f;  MAXABS = %.4f',RMS3(1), MAXABS3(1)),'Interpreter','none')
subplot(612)
plot(BBN_A_N)
title(sprintf('"BBN_A_N.wav":  RMS = %.4f;  MAXABS = %.4f',RMS3(2), MAXABS3(2)),'Interpreter','none')
subplot(613)
plot(BBN_A_+BBN_A_N)
title(sprintf('SUM: MAXABS = %.4f',MAXABS3(5)),'Interpreter','none')
subplot(614)
plot(BoyFell_)
title(sprintf('"BoyFell_.wav":  RMS = %.4f;  MAXABS = %.4f',RMS3(3), MAXABS3(3)),'Interpreter','none')
subplot(615)
plot(BoyFell_N)
title(sprintf('"BoyFell_N.wav":  RMS = %.4f;  MAXABS = %.4f',RMS3(4), MAXABS3(4)),'Interpreter','none')
subplot(616)
plot(BoyFell_+BoyFell_N)
title(sprintf('SUM:   MAXABS = %.4f', MAXABS3(6)),'Interpreter','none')



sound(BBN_A_,Fs)
pause(2)
sound(BBN_A_N,Fs)
pause(2)
sound(BoyFell_,Fs)
pause(2)
sound(BoyFell_N,Fs)
