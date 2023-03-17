%Distortion Product Instruction Block
%Purdue Chamber Version 1.0

frqlo   = 0.500;			%low frequency (in kHz) bounds for data
frqhi   =12.000;			%high frequency (in kHz) bounds for data
fstlin  =     0;			% # of linear frequency steps (set = 0 for log steps)
fstoct  =     6;			% # of log freq. steps (per oct. OR per 10-dB BW for Qspaced) (= 0 for lin steps; NEGATIVE for Qspaced)
ear     =     1;			%ear code (lft = 1, rgt = 2, both = 3
ToneOn  =  2000;			%duration of tone presentation
ToneOff =  1000;			%duration of interstim interval
Fratio  =1.200000e+00;			%ratio of F2/F1
ADdur   =  2020;			%Duration to sample the microphone
Nreps   =     4;			%Number of reps per condition
CalibSPL=   100;			%dB SPL corresponding to 0 dB attenuation for ER2
L2_dBSPL=    65;			%dB SPL presentation level for F2
L1_dBSPL=    75;			%dB SPL presentation level for F1
MicGain=    40;			%dB Gain on microphone signal path
