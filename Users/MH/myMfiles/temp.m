
cdd;
audio_fName='C:\NEL\Signals\MH\SNRenv\SNR_0\FLN_Stim_S_P.wav';
calib_picNum= 1;

plotYes=0 ;
verbose=0;
[filteredSPL, originalSPL]=CalibFilter_outSPL(audio_fName, calib_picNum, plotYes, verbose)
rdd;