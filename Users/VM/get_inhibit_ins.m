%Inhibition Curve Maker Instruction Block
%M. Sayles (2014)

frqlo   = 0.100;			%low frequency (in kHz) bounds for data
frqhi   =20.000;			%high frequency (in kHz) bounds for data
fstlin  =     0;			% # of linear frequency steps (set = 0 for log steps)
fstoct  =    -5;			% # of log freq. steps (per oct. OR per 10-dB BW for Qspaced) (= 0 for lin steps; NEGATIVE for Qspaced)
attlo   =    15;			%low atten (in dB atten) for auto tracking
atthi   =   120;			%high atten (in dB atten) for auto tracking
attstp  =     2;			%size of initial attenuation steps (in dB atten) for auto tracking
match2  =     1;			%number of threshod replications (1, 2, or 3)
crit    =    20;			%number of sps above spont for response
ear     =     2;			%ear code (lft = 1, rgt = 2, both = 3
ToneOn  =    60;			%duration of tone presentation
ToneOff =    60;			%duration of interstim interval
RespWin1=    10;			%start of window for sampling resp
RespWin2=    60;			%end of window for sampling resp
CFAtt=feval('current_unit_thresh')-15;			%CF tone attenuation (fixed)
CFFreq=feval('current_unit_bf');			%CF tone frequency (fixed)
AnalysisType=     1;			%1 = suppression tuning curve, 2 = suppression growth function, 3 = adaptation growth function
GrowthFreqLo=feval('max',[CFFreq*2^-3, 0.1]);			%kHz - lower limit for suppressor freq in growth functions
GrowthFreqHi=feval('min',[CFFreq*2^2, 12]);			%kHz - upper limit for suppressor freq in growth functions
GrowthFreqStep= 0.500;			%octaves re. CF. Set to 0 to specify individual frequencies
GrowthFreqs= 0.000;			% kHz, can use this to input specific frequencies of interest, otherwise set to 0
GrowthLevelStart=feval('min',[feval('current_unit_thresh')+10 120]);			%Starting attenuation level for the growth function
GrowthLevelStep=     5;			%Step size (dB) for the growth function
GrowthCriterion=   100;			%Criterion spike rate to track for growth function (Ideally, re-set to 2/3 max. rate from CF-tone IOFn)
maskerF   = 1.000;			%Fixed Masker Frequency (in kHz)
maskerdBSPL   =    85;			%Fixed Masker Level (in dBSPL)
CalibPicNum   =     1;			%Calibration picture number
minDeltaT   =     1;			%Minimum Delta T in recovery function (in ms)
maxDeltaT   =362.039;			%Maximum Delta T in recovery function (in ms)
DeltaTStep   = 0.500;			%Delta T step (in octaves)
