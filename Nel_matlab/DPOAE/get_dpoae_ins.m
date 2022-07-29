% DPOAE Instruction Block

F2frqlo  =           0.500;	% low frequency (in kHz) bounds for data
F2frqhi  =           12.00;	% high frequency (in kHz) bounds for data
fstlin   =               0;	% # of linear frequency steps (set = 0 for log steps)
fstoct   =               6;	% # of log freq. steps (per oct. OR per 10-dB BW for Qspaced) (= 0 for lin steps; NEGATIVE for Qspaced)
ear      =               1;	% NOT USED!! ear code (lft = 1, rgt = 2, both = 3  ***code ONLY set up for ear=1; 
ToneOn   =            2000;	% duration of tone presentation (ms)
ToneOff  =            1000;	% duration of interstim interval (ms)
Fratio   =             1.2;	% ratio of F2/F1
ADdur    =       ToneOn+20;	% Duration to sample the microphone (add 20ms to allow for delays)
Nreps    =               4;	% Number of reps per condition

CalibSPL =           100;	% NOT USED, bad way - assumes flat calib
                            % dB SPL corresponding to 0 dB attenuation for ER2 (assuming 5v peak, rather than 1v rms)
                                                        
L2_dBSPL =        65; % dB SPL presentation level for F2  %edit MW 08-11-2015
L1_dBSPL =        75;	% dB SPL presentation level for F1  %edit MW 08-11-2015
MicGain  =              40; % dB gain on mic signal
