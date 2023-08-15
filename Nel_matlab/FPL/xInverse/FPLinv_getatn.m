% Subroutine sets attenuators to value appropriate to current
% ear code and frequency (i.e. using correction for high frequency
% slope).  Gets most parameters from /srnprm/.

% freq - current stimulus frequency.
% iatnn - returns actual attenuation set
% error - returns 0 if O.K.
%	 returns -1,-2 if error setting attens (see SETA)
%	 returns +1 if attenuation has saturated.

function FPLinv_getatn

global Stimuli FREQS

% Compute atten as isyslv with ilvslp dB/oct added for frequencies
% above frqcnr:
iatn = Stimuli.syslv;
if FREQS.freq > Stimuli.frqcnr && Stimuli.lvslp ~= 0
   iatn = iatn + 0.5    +    Stimuli.lvslp * log(FREQS.freq/Stimuli.frqcnr) / log(2);
end
FREQS.atnn = max(0, min(iatn, 99.9));
