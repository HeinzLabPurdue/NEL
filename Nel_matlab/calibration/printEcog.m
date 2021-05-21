%  File: printEcog
%
% Date: March 5, 2020
% By: Caitlin Heffner
% Updated: 

function printEcog(picNums)

% cdd
close all

f = figure('units', 'normalized', 'outerposition', [0 0 1 1]); %makes image fullscreen
uit = uitable(f); %creates empty UI table
legendTEXT='';

uit.ColumnName = {'PicNum', 'RMS', 'AMP'};

height = (length(picNums)+1)*20; %height of table
uit.Position = [300 800 258 height]; 

%will need to add/adjust if more than 7 pics compared at once
colors = {'b', 'k', 'r', 'g', 'c', 'm', 'y'};

% for Ecog runs for now, only looking at one click/freq at one level for
% many reps (e.g. 1 or 5k), so when setting up to load pics can take that
% into account

%assuming time only goes to 25 ms
noise_win = [0.015 0.025]; %last 10 ms of recording assumed to be just noise
data = cell(length(picNums), 3); %intializing cell for data (picnum, rms, amp)
for i = 1:length(picNums) %loops through pics
    x = loadpic(picNums(i));
    stim = x.Stimuli;
    avg = x.AD_Data.AD_Avg_V; %sets variable as averaged data
    sf = stim.RPsamprate_Hz; %sampling rate
    t = 0:1/sf:1/sf*(length(avg{1})-1); %creats time vector
    ind = find(t >= noise_win(1) & t <= noise_win(2)); %indices for noise window
    noise = avg{1}(ind(1):(ind(length(ind))-5)); %subtracting out last 5 samples
    
    %take rms of noise portion
    rms_noise = rms(noise); %finds rms of noise window
    %find amp of noise portion
    max_noise = max(noise);
    min_noise = min(noise);
    amp_noise = max_noise - min_noise; %peak to peak amplitude of noise
    
    %saves values to data cell for table
    data{i,1} = picNums(i); 
    data{i,2} = rms_noise;
    data{i,3} = amp_noise;
    
    plot(t*1000, avg{1}/50000*1e6, colors{i}) %take out colors if more than 7 pics
    ylabel('Amp uV')
    xlabel('Time (ms)')
    hold on
    legendTEXT{i}=sprintf('P%d',picNums(i));
end

y = ylim;
% plots vertical lines for noise window
plot([noise_win(1)*1000 noise_win(1)*1000], [y(1) y(2)], ':', 'Color', 'k', 'LineWidth', 2)
plot([noise_win(2)*1000 noise_win(2)*1000], [y(1) y(2)], ':', 'Color', 'k', 'LineWidth', 2)

hold off
% xlabel('Time (s)')
legend(legendTEXT)
uit.Data = data;
