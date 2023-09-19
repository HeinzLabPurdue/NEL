function calib = findHalfWaveRes(calib)
% Adds a field calib.fres for the first half wave responance


kopeak = find(calib.freq>=5000 & calib.freq<=12000);%specify the range where to look for the first half-wave resonance
EarResp_1 = dB(calib.EarRespH_1);
EarResp_2 = dB(calib.EarRespH_2);
[~, idx_peak_1] = findpeaks(EarResp_1(kopeak),'sortstr','descend');
idx_peak_1 = kopeak(1)+idx_peak_1(1)-1;
calib.fres_1 = calib.freq(idx_peak_1)/1000;
fprintf(1, 'Resonant Freq: %2.2f kHz\n',calib.fres_1);

[~, idx_peak_2] = findpeaks(EarResp_2(kopeak),'sortstr','descend');
idx_peak_2 = kopeak(1)+idx_peak_2(1)-1;
calib.fres_2 = calib.freq(idx_peak_2)/1000;
fprintf(1, 'Resonant Freq: %2.2f kHz\n',calib.fres_2);
