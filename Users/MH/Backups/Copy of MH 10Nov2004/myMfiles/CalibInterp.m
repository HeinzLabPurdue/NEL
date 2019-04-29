function max_dBSPL=CalibInterp(cal_freq,calib)
% FILE: CalibInterp.m
% Created 6/25/02 M. Heinz
%
% Does simple interpolation to find the calibration level
% at any freq from a calibration file 
% calib: 1st col=freq, 2nd col=dB SPL
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%% Find Max dB SPL at cal_freq
[x,i]=min(abs(cal_freq-calib(:,1)));
if(calib(i,1)<cal_freq)
   %linear interpolation of frequency
   max_dBSPL=(cal_freq-calib(i,1))/(calib(i+1,1)-calib(i,1))* ...
      (calib(i+1,2)-calib(i,2)) + calib(i,2);  
elseif(calib(i,1)>cal_freq)
   max_dBSPL=(cal_freq-calib(i-1,1))/(calib(i,1)-calib(i-1,1))* ...
      (calib(i,2)-calib(i-1,2)) + calib(i-1,2);	
elseif(calib(i,1)==cal_freq)
   max_dBSPL=calib(i,2);
end

return;

    