function mic = micER7c_2;
% Modified Feb18 2014 M. Heinz
% changed 84 to 94 db SPL to match data sheet    
%
% Modified from mic067g.m
% % % % Calibration file for microphone/probe '067g'.
% % % % dBV = absolute mic calib = dB re 1V from B&K amp with 0 dB B&K gain
% % % %      and an input signal of 124 dB SPL at 250 Hz (e.g. from pistonphone).
% % % % CalData column 1 is frequency in kHz.
% % % %         column 2 is gain calib, so dBSPL=dBre1V-dBV+column2.
% % % %			    (to get the probe correction, subtract 124 dB.). NOTE saturated at 164 dB manually
% % % %         column 3 is phase correction, phase = phase from lockin + column 3.
% % % %			    (note, no unwrapping has been done.)
%
%
% Calibration file for microphone/probe 'ER7c'.
% CalData column 1 is frequency in kHz.
%         column 2 is SPL at which probe microphone calibration data was taken.
%         column 3 is phase correction, phase = phase from lockin + column 3.
%			    (note, no unwrapping has been done.)
%         column 4 is pahse correction (if we had one)
%
% dBSPL measured = 20*log10(RMS_V/1uV) - ProbeCalibData(col3) + dBSPL for ProbeCalibData(col2)

freqs_kHz=logspace(log10(200), log10(20000), 34)'/1000;
dBSPLforCalib=94*ones(size(freqs_kHz));  % from ER7C data sheet

% Rough approximation based on ER7C data sheet
FreqCorner_kHz = 11;
Slope_dBoct =-6;
for i = 1:length(freqs_kHz)
    if freqs_kHz(i)<FreqCorner_kHz
        ProbeCalib_dBre1uV(i)=94;
    else
        ProbeCalib_dBre1uV(i)=94+Slope_dBoct*log2(freqs_kHz(i)/FreqCorner_kHz);
    end
end
ProbeCalib_dBre1uV=ProbeCalib_dBre1uV';

phase_rad=0*ones(size(freqs_kHz));

mic = struct('number', 88669, 'probename', 'ER7c_2', ...
      'date', '18-Feb-2014 ', ...
      'preamp', 0, 'S0', 0, 'expect', 0, ...
      'dBV', -999, ...
      'CalData', {[freqs_kHz dBSPLforCalib ProbeCalib_dBre1uV phase_rad]});
  
  