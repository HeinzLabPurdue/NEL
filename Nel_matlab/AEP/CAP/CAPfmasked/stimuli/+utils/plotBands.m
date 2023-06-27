function plotBands(ax, ntabs, bandParamsArr)
    f=linspace(0, 12.5, 1000);
    amp=zeros(size(f));
    filter=zeros(size(f)); %values defined
    for i=1:ntabs
       params=bandParamsArr{i};
       filter=max(filter, (f>=params.fleft).*(f<=params.fright));
       amp=amp+params.amp.*(f>=params.fleft).*(f<=params.fright);
    end
    amp=(-200).*(1-filter)+filter.*amp;
    plot(ax, f, amp, 'k');
end

