function [ff, bw, g, num, den] = tilt(f1, a1, f2, a2, fs)
%TILT Spectral tilt
%   [F, BW, G, NUM, DEN] = TILT(F1, A1, F2, A2, FS) returns the parameters
%   of a filter with tilt appropriate for the input arguments. F1 and F2
%   are reference frequencies while A1 and A2 are their respective
%   amplitudes in dB. FS is the sampling rate.
%
%   The return arguments F and BW specify the frequency and the bandwidth
%   of the resultant filter as would be applied to the function SETABC. G
%   is the gain. NUM and DEN are the numerator and denominator filter
%   coefficients as applied to the MATLAB function FILTER.
%
%   Default values for F1 and F3 are 300 and 3000 respectively.

if nargin == 3
  fs = f2;
  a2 = a1;
  f2 = f1;
  f1 = 300;
  a1 = 0;
end

if nargin == 2
  fs = a1;
  a2 = f1;
  f2 = 3000;
  a1 = 0;
  f1 = 300;
end

if f2 < f1
  temp = f1;
  f1 = f2;
  f2 = temp;
  temp = a1;
  a1 = a2;
  a2 = temp;
end

if a2 == a1
  ff = 0;
  bw = inf;
  g = 1;
  num = 1;
  den = [1 0 0];
  return
end

if a2 <= a1
    h = inline('diff(20*log10(abs(fresp(0.375*10.^bw, 10.^bw, [w1 w2], fs)))) - delta', ...
        'bw', 'w1', 'w2', 'delta', 'fs');
else
    h = inline('diff(20*log10(abs(fresp(-0.375*10.^bw, 10.^bw, [w1 w2], fs)))) - delta', ...
        'bw', 'w1', 'w2', 'delta', 'fs');
end

delta = a2-a1;
bw = 10^fzero(h, 3, optimset('display', 'off'), f1, f2, delta, fs);
if isnan(bw)
    error('Difference in amplitude too steep.')
end

if a1 < a2
  f = -0.375*bw;
else
  f = 0.375*bw;
end

az = min(abs(fresp(f, bw, [f1 f1], fs)));
at = 10^(a1/20);
g = at/az;

[a b c] = setabc(f, bw, pi/fs);

if a1 < a2
  num = g*[a b c];
  den = 1;
else
  num = a*g;
  den = [1 -b -c];
end

if nargout >= 1
    ff = f;
else
    fresp(f, bw, 512, fs, 20*log10(g));
end