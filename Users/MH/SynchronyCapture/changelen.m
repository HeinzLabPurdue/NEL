function h = changelen(h, dur)

fn = fieldnames(h);
for i = 1:length(fn)
    par = getfield(h, fn{i});
    if isstruct(par)
%         if par.xdata(end-1) > par.xdata(end)
%             par.xdata(end-1) = par.xdata(end) - 5;
%             eval(sprintf('h.%s = par;', fn{i}));
%         end

        factor = dur/par.xdata(end);
        par.xdata = par.xdata*factor;
        step = h.nws / h.sr * 1000;
        par.xdata = step*round(par.xdata / step);
        eval(sprintf('h.%s.xdata = par.xdata;', fn{i}));
    end
end
