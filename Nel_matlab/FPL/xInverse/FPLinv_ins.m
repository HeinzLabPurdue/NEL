%% FPLinv_ins

function Stimuli = FPLinv_ins()

Stimuli= struct(...
    'frqlo', .05, ... % in kHz
    'frqhi', 20.000, ...
    'fstlin', 0.000, ...
    'fstoct',40.000, ...
    'bplo',   0.125, ...
    'bphi',  64.000, ...
    'n60lo',  2.000, ...
    'n60hi', 64.000, ...
    'n120lo', 2.000, ...
    'n120hi',64.000, ...
    'chan',    2.000, ...
    'syslv', 30.000, ...
    'lvslp',  6.000, ...
    'frqcnr', 11.000, ...
    'cal',    1.000, ... % plot y axis in dB or in RMS/1V
    'nmic',   'ER7c', ... % ER7c || ER10b
    'crit',  100.000);