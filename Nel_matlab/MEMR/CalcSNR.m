function SNR = CalcSNR(DPAmp_Volts, RMS_Noise, shortFFToffset_dB)

DPAmp_dBSPL = 20*log10(DPAmp_Volts/1e-6) + shortFFToffset_dB;
NoiseVec_dBSPL = 20*log10(RMS_Noise/1e-6) + shortFFToffset_dB;
SNR = DPAmp_dBSPL-NoiseVec_dBSPL;