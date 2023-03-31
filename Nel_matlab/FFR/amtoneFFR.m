function [filename, filename_inv, train_file] = amtoneFFR()
global NelData

% NEEDS TO BE CHANGEd WHEN MOVING INTO NEL from NEL_DEBUG
name_org=sprintf('pabr.wav');
train_org=sprintf('train.mat');
name_inv=sprintf('pabr_inv.wav');
filename=fullfile(NelData.General.RootDir,'Nel_matlab','FFR','signals',name_org);
train_file=fullfile(NelData.General.RootDir,'Nel_matlab','FFR','signals',train_org);

% Loading random generator seed and state so that anything generated
% randomly will be regenerated with the same realization everytime
load('s.mat');
rng(s);
fs = 48828.125;
fc_list = [500, 1000, 2000, 4000, 8000];
burst_rate = 40;
n_epochs = 30;
dur = 1.0;
n_cycles_per_burst = 5;
% Mouse has high-frequency hearing + we intend to play 32kHz
% fs = 97656.25;
% dur = 1.0;
% n_epochs = 30;
% burst_rate  = 40; % 40 burst for each frequency per second
% fc_list = [12.14, 30.49]*1e3;
% n_cycles_per_burst = 5;
[x, trains] = makeParallelABRstims(fs,  dur, n_epochs, burst_rate,...
    fc_list, n_cycles_per_burst);

y = reshape(x', [1, numel(x)]);
% save mouseCentralGainStim y trains fs...
%     fc_list n_epochs n_cycles_per_burst dur;

save(train_file,trains);




pabrtone=y; %changed on 06/25/2007 
%soundsc(samtone,fs);
% y2=y/max(y);
% y2(find(y2>=1))=0.95*y2(find(y2>=1));
% y2(find(y2<=-1))=-0.95*y2(find(y2<=-1));
% samtone=y2;
% if(pol)
%     pol_1 = ones(1,fs*dur/2);
%     pol_2 = -1 * ones(1,fs*dur/2);
%     polarizer = [pol_1 pol_2 -1];
% %     polarizer = [p1 -1]
%     samtone = samtone .* (polarizer.');
% end
audiowrite(filename,pabrtone,round(fs));

% if signal needs to be polarized, creates the inverse signal
% otherwise, creates the same signal with the name inv zz 20oct11
% if(pol)
filename_inv=fullfile(NelData.General.RootDir,'Nel_matlab','FFR','Signals',name_inv);
pabrtone = -1 * pabrtone;
audiowrite(filename_inv,pabrtone,round(fs));
% else
%     filename_inv=fullfile(NelData.General.RootDir,'Nel_matlab','FFR','Signals',name_inv);
%     audiowrite(filename_inv,samtone,round(fs));
% end























%%
% % clear all;close all;clc;
% 
% %modified by zz on 10.20.11 for FFR use
% 
% 
% function [filename, filename_inv] = amtoneFFR(fc,fm,dur,pol,mod,fs)
% global NelData
% %x=(1+Msin 2pifmt)cos 2pifct
% 
% 
% 
% %fs=12207.03125*2;  % 12/7/11: MH&KH: changed to pass as param
% %T=1/fm;
% %t = [0:T*fs]'/fs;
% 
% t = [0:dur*fs]'/fs;
% wc=2*pi*fc;
% wm=2*pi*fm;
% 
% %y=C*(1+M*sin (wm*t)).*cos (wc*t);
% % y=(1+M*sin (wm*t)).*sin (wc*t);
% 
% 
% % MODULATION zz 17nov11
% M = (1-mod)/(1+mod);
% y = ((M)+(1-M)*(0.5-0.5*cos(wm*t))).*(sin(wc*t));
% 
% % RAMP zz 17nov11
% % This should be the cosine-squared ramp
% ramp_len_ms = 5;
% ramp_freq_hz = 1000/(2*ramp_len_ms);
% t_ramp = t(1:ramp_len_ms*fs/1000)';
% ramp_up = (sin(ramp_freq_hz*pi*t_ramp)).^2;
% ramp_down = (cos(ramp_freq_hz*pi*t_ramp)).^2;
% a= size(t);
% b= size(t_ramp');
% ramp = [ramp_up ones(1,a(1)-2*b(1)) ramp_down];
% 
% 
% 
% 
% 
% 
% %Y=C*cos(wc*t)+(M/2)*(sin((wc+wm)*t)+sin((wm-wc)*t));
% 
% 
% % x=sin(2*pi*fm*t);
% % y = modulate(x,fc,fs,'am');
% 
% %Y=(1+M*sin (2*pi*fm*t)).*cos (2*pi*fc*t);
% 
% % OUTPUT FILENAME zz 20oct11
% % NEEDS TO BE CHANGEd WHEN MOVING INTO NEL from NEL_DEBUG
% name_org=sprintf('AM_%d_%d_%g_%g_org.wav',fc,fm,dur*1000,mod*100);
% name_inv=sprintf('AM_%d_%d_%g_%g_inv.wav',fc,fm,dur*1000,mod*100);
% filename=fullfile(NelData.General.RootDir,'Nel_matlab','FFR','signals',name_org);
% 
% 
% %RMS=sqrt(mean(y.^2));
% % samtone=(y*(10^(level/20)*20e-6))/RMS;
% 
% samtone=y/max(abs(y))*0.99.*ramp'; %changed on 06/25/2007 
% %soundsc(samtone,fs);
% % y2=y/max(y);
% % y2(find(y2>=1))=0.95*y2(find(y2>=1));
% % y2(find(y2<=-1))=-0.95*y2(find(y2<=-1));
% % samtone=y2;
% % if(pol)
% %     pol_1 = ones(1,fs*dur/2);
% %     pol_2 = -1 * ones(1,fs*dur/2);
% %     polarizer = [pol_1 pol_2 -1];
% % %     polarizer = [p1 -1]
% %     samtone = samtone .* (polarizer.');
% % end
% audiowrite(filename,samtone,round(fs));
% 
% % if signal needs to be polarized, creates the inverse signal
% % otherwise, creates the same signal with the name inv zz 20oct11
% if(pol)
%     filename_inv=fullfile(NelData.General.RootDir,'Nel_matlab','FFR','Signals',name_inv);
%     samtone = -1 * samtone;
%     audiowrite(filename_inv,samtone,round(fs));
% else
%     filename_inv=fullfile(NelData.General.RootDir,'Nel_matlab','FFR','Signals',name_inv);
%     audiowrite(filename_inv,samtone,round(fs));
% end