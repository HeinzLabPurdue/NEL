function mic = micER10b()
% Modified from micER7c.m
% SP

er10Sens= load('mic_ER10B_SN988_SensDATA_scanned.mat');
freqs_kHz=logspace(log10(50), log10(20000), 100)'/1000;

closest_freq_inds= dsearchn(er10Sens.freqVEC_Hz(:), freqs_kHz*1e3);
er10Sens_closest= er10Sens.SensOffset_re_1kHz_dB(closest_freq_inds);
dBSPLforCalib=84*ones(size(freqs_kHz));  % from ER7C data sheet

ProbeCalib_dBre1uV= dBSPLforCalib(:) + er10Sens_closest(:);
ProbeCalib_dBre1uV=ProbeCalib_dBre1uV';

phase_rad=0*ones(size(freqs_kHz));

mic = struct('number', 88669, 'probename', 'ER7c', ...
      'date', '12-Jul-2006 ', ...
      'preamp', 0, 'S0', 0, 'expect', 0, ...
      'dBV', -999, ...
      'CalData', {[freqs_kHz(:) dBSPLforCalib(:) ProbeCalib_dBre1uV(:) phase_rad(:)]});
  
  