function [filename, filename_inv, train_file] = pabr_stim()
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