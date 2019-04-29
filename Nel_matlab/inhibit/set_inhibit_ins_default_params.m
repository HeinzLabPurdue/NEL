global root_dir NelData

%parameter files are stored under the subject's name in the subjects directory
file_name = fullfile(root_dir,'..','Users',NelData.General.User,'get_inhibit_ins.m');

fid = fopen(file_name,'wt');					%open file ID as as a writeable text file (text files are easy to read and portable)

fprintf(fid,'%s\n','%Inhibition Curve Maker Instruction Block');		%the following print statements convert parameters to lines of text in parameter file
fprintf(fid,'%s\n\n','%M. Sayles (2014)');		%the following print statements convert parameters to lines of text in parameter file

fprintf(fid,'%s%6.3f%c\t\t\t%s\n','frqlo   =',0.1,';','%low frequency (in kHz) bounds for data');
fprintf(fid,'%s%6.3f%c\t\t\t%s\n','frqhi   =',20.000,';','%high frequency (in kHz) bounds for data');
fprintf(fid,'%s%6d%c\t\t\t%s\n'  ,'fstlin  =',0,';','% # of linear frequency steps (set = 0 for log steps)');
fprintf(fid,'%s%6d%c\t\t\t%s\n'  ,'fstoct  =',-5,';','% # of log freq. steps (per oct. OR per 10-dB BW for Qspaced) (= 0 for lin steps; NEGATIVE for Qspaced)');
fprintf(fid,'%s%6d%c\t\t\t%s\n'  ,'attlo   =',15,';','%low atten (in dB atten) for auto tracking');
fprintf(fid,'%s%6d%c\t\t\t%s\n'  ,'atthi   =',120,';','%high atten (in dB atten) for auto tracking');
fprintf(fid,'%s%6d%c\t\t\t%s\n'  ,'attstp  =',2,';','%size of initial attenuation steps (in dB atten) for auto tracking');
fprintf(fid,'%s%6d%c\t\t\t%s\n'  ,'match2  =',1,';','%number of threshod replications (1, 2, or 3)');
fprintf(fid,'%s%6d%c\t\t\t%s\n'  ,'crit    =',20,';','%number of sps above spont for response');
fprintf(fid,'%s%6d%c\t\t\t%s\n'  ,'ear     =',2,';','%ear code (lft = 1, rgt = 2, both = 3');
fprintf(fid,'%s%6d%c\t\t\t%s\n'  ,'ToneOn  =',60,';','%duration of tone presentation');
fprintf(fid,'%s%6d%c\t\t\t%s\n'  ,'ToneOff =',60,';','%duration of interstim interval');
fprintf(fid,'%s%6d%c\t\t\t%s\n'  ,'RespWin1=',10,';','%start of window for sampling resp');
fprintf(fid,'%s%6d%c\t\t\t%s\n'  ,'RespWin2=',60,';','%end of window for sampling resp');
fprintf(fid,'%s%s%c\t\t\t%s\n'  ,'CFAtt=','feval(''current_unit_thresh'')-15',';','%CF tone attenuation (fixed)');
fprintf(fid,'%s%s%c\t\t\t%s\n'  ,'CFFreq=','feval(''current_unit_bf'')',';','%CF tone frequency (fixed)');
fprintf(fid,'%s%6d%c\t\t\t%s\n'  ,'AnalysisType=',1,';','%1 = suppression tuning curve, 2 = suppression growth function, 3 = adaptation growth function');
fprintf(fid,'%s%s%c\t\t\t%s\n'  ,'GrowthFreqLo=','feval(''max'',[CFFreq*2^-3, 0.1])',';','%kHz - lower limit for suppressor freq in growth functions');
fprintf(fid,'%s%s%c\t\t\t%s\n'  ,'GrowthFreqHi=','feval(''min'',[CFFreq*2^2, 12])',';','%kHz - upper limit for suppressor freq in growth functions');
fprintf(fid,'%s%6.3f%c\t\t\t%s\n'  ,'GrowthFreqStep=',0.500,';','%octaves re. CF. Set to 0 to specify individual frequencies');
fprintf(fid,'%s%6.3f%c\t\t\t%s\n'  ,'GrowthFreqs=',0.000,';','% kHz, can use this to input specific frequencies of interest, otherwise set to 0');
fprintf(fid,'%s%s%c\t\t\t%s\n'  ,'GrowthLevelStart=','feval(''min'',[feval(''current_unit_thresh'')+10 120])',';','%Starting attenuation level for the growth function');
fprintf(fid,'%s%6d%c\t\t\t%s\n'  ,'GrowthLevelStep=',5,';','%Step size (dB) for the growth function');
fprintf(fid,'%s%6d%c\t\t\t%s\n'  ,'GrowthCriterion=',100,';','%Criterion spike rate to track for growth function (Ideally, re-set to 2/3 max. rate from CF-tone IOFn)');
fprintf(fid,'%s%6.3f%c\t\t\t%s\n','maskerF   =',1.000,';','%Fixed Masker Frequency (in kHz)');
fprintf(fid,'%s%6d%c\t\t\t%s\n','maskerdBSPL   =',85,';','%Fixed Masker Level (in dBSPL)');
fprintf(fid,'%s%6d%c\t\t\t%s\n','CalibPicNum   =',1,';','%Calibration picture number');
fprintf(fid,'%s%6d%c\t\t\t%s\n','minDeltaT   =',1,';','%Minimum Delta T in recovery function (in ms)');
fprintf(fid,'%s%6.3f%c\t\t\t%s\n','maxDeltaT   =',256*2^0.5,';','%Maximum Delta T in recovery function (in ms)');
fprintf(fid,'%s%6.3f%c\t\t\t%s\n','DeltaTStep   =',0.5,';','%Delta T step (in octaves)');



fclose(fid);	%close the file and return to parameter change function