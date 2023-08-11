function y = Qspace(frq1, frq2, N)
% QSPACE Auditory-Nerve-Q10-spaced frequency vector.
%   QSPACE(frq1, frq2, N) generates a row vector of
%   equally spaced points on a Q-10 (ANF) based frequency scale 
%   between frequencies frq1 and frq2 (in kHz), with ~N points
%   within the TC tip (ie, within 10 dB of threshold).
%   
%   Q10 (=CF/BW10, where BW10 is the bandwidth 10 dB above threhsold)
%   for ANFs is described by
%        log10(Q10)=0.4708*log10(CF/1000)+0.4664  (CF in Hz)
%   from Zhang et al (2001) describing Q10 data from Miller et al (1997)
%
%   See also LOGSPACE, LINSPACE, :.
%
%   Modified from LOGSPACE
%   Michael Heinz, 4/26/02

frq1=frq1*1000;
frq2=frq2*1000;

y(1)=frq1;
i=1;
while (sign(y(i)-frq2)==sign(frq1-frq2))
   BW=8.8308*y(i)^(0.5292);   % From Q10 fit
   Ffact=10^( (log10(y(i)+BW) - log10(y(i))) / (N-1));  % logspace N pts in BW10 (above f!)
   y(i+1) = y(i) * Ffact^sign(frq2-frq1);
   i=i+1;
end

y=y/1000;