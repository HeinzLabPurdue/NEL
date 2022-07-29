function [stim] = analyzeMEM_Fn(stim,AR)

%ARTIFACT REJECTION
if AR == 1
   %Call artifact rejection function
   [stim] = artifact_rejection_Fn(stim);
   %Compare GREATtrials to stim.rms-->NEW STIM.RMS
   for L = 1:stim.nLevels
      for T = 1:stim.nTrials
         if stim.reject(L,T)
            stim.resp(L,T,:,:) = NaN;
         end
      end
   end
end

%original analyzeMEM below
endsamps = ceil(stim.clickwin*stim.Fs*1e-3);

freq = 10.^linspace(log10(200), log10(8000), 1024);
MEMband = [500, 2000];
ind = (freq >= MEMband(1)) & (freq <= MEMband(2));

for k = 1:stim.nLevels
   temp = reshape(squeeze(stim.resp(k, :, 2:end, 1:endsamps)),...
      (stim.nreps-1)*stim.Averages, endsamps);
   resp(k, :) = trimmean(temp, 20, 1); %#ok<*SAGROW>
   resp_freq(k, :) = pmtm(resp(k, :), 4, freq, stim.Fs);
   blevs = k;
   temp2 = squeeze(stim.resp(k, :, 1, 1:endsamps));
   if(numel(blevs) > 1) 
      temp2 = reshape(temp2, size(temp2, 2)*numel(k), endsamps);
   end
   bline(k, :) = trimmean(temp2, 20, 1);
   bline_freq(k, :) = pmtm(bline(k, :), 4, freq, stim.Fs);
end

%Calculate MEM
MEM = pow2db(resp_freq ./ bline_freq);

%Set elicitor values
if(min(stim.noiseatt) == 6)
    elicitor = 94 - (stim.noiseatt - 6);
else
    elicitor = 94 - stim.noiseatt;
end

%Sets colors
cols = [103,0,31;
178,24,43;
214,96,77;
244,165,130;
253,219,199;
247, 247, 247;
209,229,240;
146,197,222;
67,147,195;
33,102,172;
5,48,97];
cols = cols(end:-1:1, :)/255;

% cols = jet(size(MEM, 1));
figure;
axes('NextPlot','replacechildren', 'ColorOrder',cols);
subplot(1,2,1); 
semilogx(freq / 1e3, MEM, 'linew', 2);
xlim([0.2, 8]);
ticks = [0.25, 0.5, 1, 2, 4, 8];
set(gca, 'XTick', ticks, 'XTickLabel', num2str(ticks'), 'FontSize', 10);
%legend(num2str(elicitor'));
lgd = legend(num2str(elicitor')); 
set(lgd,'FontSize',8); %added
xlabel('Frequency (kHz)', 'FontSize', 10);
ylabel('Ear canal pressure (dB re: Baseline)', 'FontSize', 10);

%figure;
subplot(1,2,2);
plot(elicitor, mean(abs(MEM(:, ind)), 2)*5 , 'ok-', 'linew', 2);
hold on;
xlabel('Elicitor Level (dB SPL)', 'FontSize', 10);
ylabel('\Delta Absorbed Power (dB)', 'FontSize', 10);
set(gca,'FontSize', 10);

hold off;

end

