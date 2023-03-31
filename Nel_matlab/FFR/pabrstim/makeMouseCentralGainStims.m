% Loading random generator seed and state so that anything generated
% randomly will be regenerated with the same realization everytime

fs = 48828.125;
fc_list = [500, 1000, 2000, 4000, 8000];
burst_rate = 40;
n_epochs = 1;
dur = 1.0;
n_cycles_per_burst = 5;
n_samps = floor(fs * dur);
number = 32;
i=1;
% final_32 = zeros(n_samps*30*number);
% for i=1:number
    load('s.mat');
    rng(s);
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
    y=y';
    save mouseCentralGainStim y trains fs...
        fc_list n_epochs n_cycles_per_burst dur;
    file_train = ['train', num2str(i), '.mat'];
    save(file_train,'trains')
    name = sprintf('pabr_%g_org.wav',i);
    file = fullfile(name);
    audiowrite(file,y,round(fs));
    nameinv = sprintf('pabr_%g_inv.wav',i);
    file = fullfile(nameinv);
    y_inv = -1*y;
    audiowrite(file,y_inv,round(fs));
%     final_32(end+1) = y;
% end

