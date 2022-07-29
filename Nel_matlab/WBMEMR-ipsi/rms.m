function [outRMS] = rms(inVEC)

outRMS = sqrt(mean(inVEC.^2));

end


