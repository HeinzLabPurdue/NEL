%Tuning Curve Maker Instruction Block
%North Chamber Version 1.0

frqlo   = 0.200;			%low frequency (in kHz) bounds for data
frqhi   =10.000;			%high frequency (in kHz) bounds for data
fstlin  =     0;			% # of linear frequency steps (set = 0 for log steps)
fstoct  =    -9;			% # of log freq. steps (per oct. OR per 10-dB BW for Qspaced) (= 0 for lin steps; NEGATIVE for Qspaced)
attlo   =    20;			%low atten (in dB atten) for auto tracking
atthi   =   120;			%high atten (in dB atten) for auto tracking
attstp  =     2;			%size of initial attenuation steps (in dB atten) for auto tracking
match2  =     2;			%number of threshod replications (1 or 2)
crit    =     0;			%number of sps above spont for response
ear     =     2;			%ear code (lft = 1, rgt = 2, both = 3
ToneOn  =    60;			%duration of tone presentation
ToneOff =    60;			%duration of interstim interval
RespWin1=    10;			%start of window for sampling resp
RespWin2=    60;			%end of window for sampling resp
SponWin1=    70;			%start of window for sampling spont
SponWin2=   120;			%end of window for sampling spont
SponSamp1=     0;			%user can elect to sample SR at start of TC
SponSamp2=     0;			%user can elect to sample SR at stop of TC
