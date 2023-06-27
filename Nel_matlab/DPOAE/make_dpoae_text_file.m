global NelData

fname = current_data_file('dpoae',1);

x.General.program_name  = PROG;
x.General.version = VERSION;   % added 6/27/2023 MH
x.General.picture_number = NelData.File_Manager.picture+1;
x.General.track          = NelData.File_Manager.track.No;
x.General.unit           = NelData.File_Manager.unit.No;
x.General.date          = date;
x.General.time          = datestr(now,13);
x.General.spike_res     = 1e-5;
x.General.spike_unit    = 'sec';
x.General.timing_unit   = 'ms';
x.General.comment       = 'FILL IN LATER';

%store the parameter block
x.Stimuli.file_frqlo     = PARAMS(1);
x.Stimuli.file_frqhi     = PARAMS(2);
x.Stimuli.file_fstlin    = PARAMS(3);
x.Stimuli.file_fstoct    = PARAMS(4);

if logstps > 0
   x.Stimuli.FreqSteps   ='log';
elseif logstps < 0
   x.Stimuli.FreqSteps   ='Q';
else
   x.Stimuli.FreqSteps   ='linear';
end

x.Stimuli.ear          = PARAMS(5);
x.Stimuli.ToneOn       = PARAMS(6);
x.Stimuli.ToneOff      = PARAMS(7);
x.Stimuli.Fratio       = PARAMS(8);
x.Stimuli.ADdur        = PARAMS(9);
x.Stimuli.Nreps        = PARAMS(10);
x.Stimuli.CalibSPL     = PARAMS(11);
x.Stimuli.L2_dBSPL     = PARAMS(12);
x.Stimuli.L1_dBSPL     = PARAMS(13);

x.Line    = [];

x.DpoaeData = dpoaedata;
x.DpoaeSpectra = dpoaespectra;
x.Dpoaefreqs = dpoaefreqs;

x.User = [];

x.Hardware.amp_vlt   = VOLTS; 


rc = write_nel_data(fname,x,0);
while (rc < 0)
   title_str = ['Choose a different file name! Can''t write to ''' fname ''''];
   [fname, dirname] = uiputfile([fileparts(fname) filesep '*.m'],title_str);
   rc = write_nel_data(fullfile(dirname,fname),x,0);
end
NelData.File_Manager.picture = NelData.File_Manager.picture+1;