global data_dir NelData

fname = current_data_file('tc');

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

x.Line    = [];

x.TcData = tcdata;

x.User = [];

x.Hardware.amp_vlt   = VOLTS; % MGH, what to put here? (alon)


rc = write_nel_data(fname,x,0);
while (rc < 0)
   title_str = ['Choose a different file name! Can''t write to ''' fname ''''];
   [fname dirname] = uiputfile([fileparts(fname) filesep '*.m'],title_str);
   rc = write_nel_data(fullfile(dirname,fname),x,0);
end
NelData.File_Manager.picture = NelData.File_Manager.picture+1;