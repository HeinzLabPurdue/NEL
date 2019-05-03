%% quick script for checking the spont-rate of a unit with an SR picture file
%% This will take either a single picture number or an array of picnums
function spontrate = SRcheck(picnum)
if length(picnum) > 1
    for i = 1:length(picnum)
        x = loadpic(picnum(i));
        numspikes = length(x.spikes{:});
        spontrate(i,:) = [numspikes/30 picnum(i)];
    end
else
    x = loadpic(picnum);
    numspikes = length(x.spikes{:});
    spontrate = numspikes/30;
end
end