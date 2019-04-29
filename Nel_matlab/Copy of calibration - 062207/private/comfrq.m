function comfrq

global Stimuli FREQS

%Function computes frequency as:

if Stimuli.fstoct == 0,
   FREQS.freq = Stimuli.frqlo + FREQS.ndpnts*Stimuli.fstlin;		%linear steps
elseif Stimuli.fstlin == 0,
   FREQS.freq = Stimuli.frqlo*2.0^(FREQS.ndpnts/Stimuli.fstoct);	%log steps
end
