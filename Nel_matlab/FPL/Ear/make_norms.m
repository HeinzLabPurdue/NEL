chins = [Q421, Q422, Q424, Q428, Q427, Q426]; 
for i = 1:numel(chins)
    freq(i, :) = chins(i).freq'; 
    abs(i,:) = chins(i).abs'; 
end

meanabs = mean(abs,1,'omitmissing'); 
stdabs = std(abs, 1); 

smoothbump = interp1([13,19], [meanabs(1,13), meanabs(1,19)], [13:19])
meanabs(1,13:19) = smoothbump; 
meanabs = sgolayfilt(meanabs,4,25)
stdabs = sgolayfilt(stdabs,4,25)


loabs = meanabs - stdabs; 
hiabs = meanabs + stdabs; 

%loabs(1,loabs<0) = 0; 
%hiabs(1,hiabs<0) = 0;
% f = freq(1,:); 
% loabs = loabs(1,:); 
% hiabs = hiabs(1,:); 

idx = loabs > 0 & hiabs > 0; 
f = freq(1,idx); 
loabs = loabs(1,idx); 
hiabs = hiabs(1,idx); 

figure; 
hold on; 
plot(f, loabs); 
plot(f, hiabs)
set(gca, 'XScale', 'log')
ylim([0,100])
xlim([.2, 8])

save('FPLear_norms', 'f', 'loabs', 'hiabs'); 