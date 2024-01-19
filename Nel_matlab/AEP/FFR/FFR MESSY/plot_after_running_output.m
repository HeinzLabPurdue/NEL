% Plots the averaged at each carrier frequency and noise level, each graph
% is separated into HI and NH animals.
% RUN ONLY AFTER running FFR_output with necessary code.

% 1 khz
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i = 0;
for i=1:length(HI_1l)
    avg = 0;
    for j=1:HI_1l(i)
        avg = (i-1)/i.*avg + 1/i.*HI_1{i,j};
    end
    avgHI1{i} = avg;
end
    
i = 0;
for i=1:length(NH_1l)
    avg = 0;
    for j=1:NH_1l(i)
        avg = (i-1)/i.*avg + 1/i.*NH_1{i,j};
    end
    avgNH1{i} = avg;
end

for i=1:4
    figure(i+1);
    title('1k');
    plot(avgHI1{i},'r')
    hold on;
    plot(avgNH1{i});
    hold off;
%     pause;
end
pause
% 2 khz
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i = 0;
for i=1:length(HI_2l)
    avg = 0;
    for j=1:HI_2l(i)
        avg = (i-1)/i.*avg + 1/i.*HI_2{i,j};
    end
    avgHI2{i} = avg;
end
    
i = 0;
for i=1:length(NH_2l)
    avg = 0;
    for j=1:NH_2l(i)
        avg = (i-1)/i.*avg + 1/i.*NH_2{i,j};
    end
    avgNH2{i} = avg;
end

for i=1:4
    figure(i+1);
    title('2k');
    plot(avgHI2{i},'r')
    hold on;
    plot(avgNH2{i});
    hold off;
%     pause;
end
pause

% 4 khz
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i = 0;
for i=1:length(HI_4l)
    avg = 0;
    for j=1:HI_4l(i)
        avg = (i-1)/i.*avg + 1/i.*HI_4{i,j};
    end
    avgHI4{i} = avg;
end
    
i = 0;
for i=1:length(NH_4l)
    avg = 0;
    for j=1:NH_4l(i)
        avg = (i-1)/i.*avg + 1/i.*NH_4{i,j};
    end
    avgNH4{i} = avg;
end

for i=1:4
    figure(i+1);
    title('2k');
    plot(avgHI4{i},'r')
    hold on;
    plot(avgNH4{i});
    hold off;
%     pause;
end
pause

% 8 khz
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i = 0;
for i=1:length(HI_8l)
    avg = 0;
    for j=1:HI_8l(i)
        avg = (i-1)/i.*avg + 1/i.*HI_8{i,j};
    end
    avgHI8{i} = avg;
end
    
i = 0;
for i=1:length(NH_8l)
    avg = 0;
    for j=1:NH_8l(i)
        avg = (i-1)/i.*avg + 1/i.*NH_8{i,j};
    end
    avgNH8{i} = avg;
end

for i=1:4
    figure(i+1);
    title('2k');
    plot(avgHI8{i},'r')
    hold on;
    plot(avgNH8{i});
    hold off;
%     pause;
end