global data_dir NelData

fname = current_data_file('inhibit');

x.General.program_name  = PROG;
x.General.picture_number = NelData.File_Manager.picture+1;
x.General.track          = NelData.File_Manager.track.No;
x.General.unit           = NelData.File_Manager.unit.No;
x.General.date          = date;
x.General.time          = datestr(now,13);
x.General.spike_res     = 1e-5;
x.General.spike_unit    = 'sec';
x.General.timing_unit   = 'ms';
x.General.comment       = comment;

%store the parameter block
x.Stimuli.file_frqlo     = PARAMS(1);
x.Stimuli.file_frqhi     = PARAMS(2);
x.Stimuli.file_fstlin    = PARAMS(3);
x.Stimuli.file_fstoct    = PARAMS(4);
x.Stimuli.file_attlo     = PARAMS(5);
x.Stimuli.file_atthi     = PARAMS(6);
x.Stimuli.file_attstp    = PARAMS(7);

if logstps > 0,
   x.Stimuli.FreqSteps   ='log';
elseif logstps < 0,
   x.Stimuli.FreqSteps   ='Q';
else
   x.Stimuli.FreqSteps   ='linear';
end

x.Stimuli.match2       = PARAMS(8);
x.Stimuli.crit         = PARAMS(9);
x.Stimuli.ear          = PARAMS(10);
x.Stimuli.ToneOn       = PARAMS(11);
x.Stimuli.ToneOff      = PARAMS(12);
x.Stimuli.RespWin1     = PARAMS(13);
x.Stimuli.RespWin2     = PARAMS(14);
x.Stimuli.CFAtten      = PARAMS(15);
x.Stimuli.CFFreq       = PARAMS(16);
x.Stimuli.AnalysisType = PARAMS(17); %1 = suppression tuning curve, 2 = suppression growth functions
if x.Stimuli.AnalysisType==2 | x.Stimuli.AnalysisType==3
    x.Stimuli.GrowthFreqLo = PARAMS(18);
    x.Stimuli.GrowthFreqHi = PARAMS(19);
    x.Stimuli.GrowthFreqStep = PARAMS(20);
    x.Stimuli.GrowthFreqs = PARAMS(21);
    x.Stimuli.GrowthLevelStart = PARAMS(22);
    x.Stimuli.GrowthLevelStep = PARAMS(23);
    x.Stimuli.GrowthCriterion = PARAMS(24);
else
    x.Stimuli.GrowthFreqLo = [];
    x.Stimuli.GrowthFreqHi = [];
    x.Stimuli.GrowthFreqStep = [];
    x.Stimuli.GrowthFreqs = [];
    x.Stimuli.GrowthLevelStart = [];
    x.Stimuli.GrowthLevelStep = [];
    x.Stimuli.GrowthCriterion = [];
end
if x.Stimuli.AnalysisType==4 | x.Stimuli.AnalysisType==5
    x.Stimuli.FixedMaskerFreq = PARAMS(25);
    x.Stimuli.FixedMaskerLevel = PARAMS(26);
    x.Stimuli.CalibrationPic = PARAMS(27);
else
    x.Stimuli.FixedMaskerFreq = [];
    x.Stimuli.FixedMaskerLevel = [];
    x.Stimuli.CalibrationPic = [];
end
if x.Stimuli.AnalysisType==6
    x.Stimuli.minDeltaT = PARAMS(28);
    x.Stimuli.maxDeltaT = PARAMS(29);
    x.Stimuli.DeltaTStep_octs = PARAMS(30);
else
    x.Stimuli.minDeltaT = [];
    x.Stimuli.maxDeltaT = [];
    x.Stimuli.DeltaTStep_octs = [];
end


x.Line    = [];

x.InhibitData = inhibitdata;

% x.Thresh.thresh = NelData.TC.Th;
% x.Thresh.BF = NelData.TC.BF;

x.User = [];

x.Hardware.amp_vlt   = VOLTS; % MGH, what to put here? (alon)


rc = write_nel_data(fname,x,0);
while (rc < 0)
   title_str = ['Choose a different file name! Can''t write to ''' fname ''''];
   [fname dirname] = uiputfile([fileparts(fname) filesep '*.m'],title_str);
   rc = write_nel_data(fullfile(dirname,fname),x,0);
end
NelData.File_Manager.picture = NelData.File_Manager.picture+1;