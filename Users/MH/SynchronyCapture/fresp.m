function h = fresp(f, bw, n, fs, g)
%FRESP Response given formants.
%   Z = FRESP(F, BW, N, FS) returns the complex frequency response of a
%   cascade of formants specified by the vector of centre frequencies F and
%   bandwidths BW given the sampling rate in FS at N equidistant points
%   between 0 Hz and the Nyquist frequency. If FS isn't specified, it
%   defaults to 10000 Hz. If N is not specified, it defaults to 512.
%   Negative frequencies in F indicate zeros instead of poles. Either F or
%   BW can be a vector. If the other argument is a scalar, it is
%   automatically expanded.
%
%   Z = FRESP(F, BW, N, FS, G) adjusts the response by a fixed gain in dB.

%   Copyright (c) by Michael Kiefte 2000-2001.

error(nargchk(2, 5, nargin))

if nargin > 2 & all(size(bw) == size(n))
    warning('This function has changed. Some default behaviour no longer applies.')
end

if nargin < 5
    g = 0;
    if nargin < 4
        fs = 10000;
        if nargin < 3
            n = 512;
        end
    end
elseif length(g) > 1
    error('Gain must be a scalar.')
end

if length(n) == 1
    w = linspace(0, fs/2, n);
else
    w = n;
end

if length(f) == 1
    f = f(ones(size(bw)));
elseif length(bw) == 1
    bw = bw(ones(size(f)));
end

% multiply by something like this to get the -6 dB/octave slope.
% z = z.*(exp(sqrt(-1)*2*pi*w/fs)-1)

z = 10^(g/20)*ones(size(w));

for i = 1:length(f)
  [a b c] = setabc(f(i), bw(i), pi/fs);
  if f(i) < 0
      z = z.*freqz([a b c], 1, w, fs);
  else
      z = z.*freqz(a, [1 -b -c], w, fs);
  end
end

if nargout == 0
    plot(w, 20*log10(abs(z)));
    grid on
    xlabel('Frequency (Hz)')
    ylabel('Magnitude (dB)')
else
    h = z;
end
