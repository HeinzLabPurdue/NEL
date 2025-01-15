% File: printEcog_reps
%
% Date: March 10, 2020
% By: Caitlin Heffner
% Updated:

function printEcog_reps(picNum)

cdd
close all

f = figure('units', 'normalized', 'outerposition', [0 0 1 1]); %makes image fullscreen
uit = uitable(f); %creates empty UI table
legendTEXT='';

uit.ColumnName = {'Reps', 'RMS', 'AMP'};

height = (length(picNum)+1)*40; %height of table
uit.Position = [300 800 258 height];

%assuming time only goes to 25 ms
noise_win = [0.015 0.025]; %last 10 ms of recording assumed to be just noise

x = loadpic(picNum);
stim = x.Stimuli;
all_data = cell2mat(x.AD_Data.AD_All_V); %sets variable for all data & converts
Avg = x.AD_Data.AD_Avg_V; %sets variable as averaged data
sf = stim.RPsamprate_Hz; %sampling rate
t = 0:1/sf:1/sf*(length(Avg{1})-1); %creats time vector
ind = find(t >= noise_win(1) & t <= noise_win(2)); %indices for noise window
sz = size(all_data);

if sz(1) == 10000 %5000 reps
    % NEED TO CHANGE DATA TO HAVE ROWS OF NUMBER OF REP COMPARISIONS
    data = cell(5, 3); %intializing cell for data (reps, rms, amp)
    avg = cell(5,1); %initializing avgerages cell
    
    %1000 reps
    pos_1k = mean(all_data(1:2:2000,:));
    neg_1k = mean(all_data(2:2:2000,:));
    data_1k(1,:) = pos_1k; data_1k(2,:) = neg_1k;
    avg{1} = mean(data_1k);
    data{1,1} = 1000;
    
    %2000 reps
    pos_2k = mean(all_data(1:2:4000,:));
    neg_2k = mean(all_data(2:2:4000,:));
    data_2k(1,:) = pos_2k; data_2k(2,:) = neg_2k;
    avg{2} = mean(data_2k);
    data{2,1} = 2000;
    
    %3000 reps
    pos_3k = mean(all_data(1:2:6000,:));
    neg_3k = mean(all_data(2:2:6000,:));
    data_3k(1,:) = pos_3k; data_3k(2,:) = neg_3k;
    avg{3} = mean(data_3k);
    data{3,1} = 3000;
    
    %4000 reps
    pos_4k = mean(all_data(1:2:8000,:));
    neg_4k = mean(all_data(2:2:8000,:));
    data_4k(1,:) = pos_4k; data_4k(2,:) = neg_4k;
    avg{4} = mean(data_4k);
    data{4,1} = 4000;
    
    %5000 reps
    pos_5k = mean(all_data(1:2:end,:));
    neg_5k = mean(all_data(2:2:end,:));
    data_5k(1,:) = pos_5k; data_5k(2,:) = neg_5k;
    avg{5} = mean(data_5k);
    data{5,1} = 5000;
    
    noise = cell(5,1); rms_noise = cell(5,1); amp_noise = cell(5,1);
    for i = 1:5
        noise{i} = avg{i}(ind(1):ind(length(ind))-5); %noise window
        rms_noise{i} = rms(noise{i}); %rms of noise window
        max_noise = max(noise{i});
        min_noise = min(noise{i});
        amp_noise{i} = max_noise - min_noise; %peak-peak amplitude of noise
        
        data{i,2} = rms_noise{i};
        data{i,3} = amp_noise{i};
        
        plot(t, avg{i})
        hold on
        legendTEXT{i}=sprintf('%d reps', data{i,1});
    end
elseif sz(1) == 6000
    data = cell(3, 3); %intializing cell for data (reps, rms, amp)
    avg = cell(3,1); %initializing avgerages cell
    
    %1000 reps
    pos_1k = mean(all_data(1:2:2000,:));
    neg_1k = mean(all_data(2:2:2000,:));
    data_1k(1,:) = pos_1k; data_1k(2,:) = neg_1k;
    avg{1} = mean(data_1k);
    data{1,1} = 1000;
    
    %2000 reps
    pos_2k = mean(all_data(1:2:4000,:));
    neg_2k = mean(all_data(2:2:4000,:));
    data_2k(1,:) = pos_2k; data_2k(2,:) = neg_2k;
    avg{2} = mean(data_2k);
    data{2,1} = 2000;
    
    %3000 reps
    pos_3k = mean(all_data(1:2:6000,:));
    neg_3k = mean(all_data(2:2:6000,:));
    data_3k(1,:) = pos_3k; data_3k(2,:) = neg_3k;
    avg{3} = mean(data_3k);
    data{3,1} = 3000;
    
    noise = cell(3,1); rms_noise = cell(3,1); amp_noise = cell(3,1);
    for i = 1:3
        noise{i} = avg{i}(ind(1):ind(length(ind))-5); %noise window
        rms_noise{i} = rms(noise{i}); %rms of noise window
        max_noise = max(noise{i});
        min_noise = min(noise{i});
        amp_noise{i} = max_noise - min_noise; %peak-peak amplitude of noise
        
        data{i,2} = rms_noise{i};
        data{i,3} = amp_noise{i};
        
        plot(t*1000, avg{i}/50000*1e6)
        ylabel('Amp uV')
        xlabel('Time (ms)')
        hold on
        legendTEXT{i}=sprintf('%d reps', data{i,1});
    end
elseif sz(1) == 2000
    data = cell(2, 3); %intializing cell for data (reps, rms, amp)
    avg = cell(2,1); %initializing avgerages cell
    
    %500 reps
    pos_1k = mean(all_data(1:2:1000,:));
    neg_1k = mean(all_data(2:2:1000,:));
    data_1k(1,:) = pos_1k; data_1k(2,:) = neg_1k;
    avg{1} = mean(data_1k);
    data{1,1} = 500;
    
    %1000 reps
    pos_2k = mean(all_data(1:2:2000,:));
    neg_2k = mean(all_data(2:2:2000,:));
    data_2k(1,:) = pos_2k; data_2k(2,:) = neg_2k;
    avg{2} = mean(data_2k);
    data{2,1} = 1000;
    
    noise = cell(2,1); rms_noise = cell(2,1); amp_noise = cell(2,1);
    for i = 1:2
        noise{i} = avg{i}(ind(1):ind(length(ind))-5); %noise window
        rms_noise{i} = rms(noise{i}); %rms of noise window
        max_noise = max(noise{i});
        min_noise = min(noise{i});
        amp_noise{i} = max_noise - min_noise; %peak-peak amplitude of noise
        
        data{i,2} = rms_noise{i};
        data{i,3} = amp_noise{i};
        
        plot(t, avg{i})
        hold on
        legendTEXT{i}=sprintf('%d reps', data{i,1});
    end
end

y = ylim;
% plots vertical lines for noise window
plot([noise_win(1)*1000 noise_win(1)*1000], [y(1) y(2)], ':', 'Color', 'k', 'LineWidth', 2)
plot([noise_win(2)*1000 noise_win(2)*1000], [y(1) y(2)], ':', 'Color', 'k', 'LineWidth', 2)

hold off
% xlabel('Time (s)')
legend(legendTEXT)
uit.Data = data;

