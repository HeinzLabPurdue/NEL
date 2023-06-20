global NelData

fname = current_data_file('memr',1);
x.General.program_name  = PROG;
x.General.picture_number = NelData.File_Manager.picture+1;
x.General.track          = NelData.File_Manager.track.No;
x.General.unit           = NelData.File_Manager.unit.No;
x.General.date          = date;
x.General.time          = datestr(now,13);
x.General.spike_res     = 1e-5;
x.General.spike_unit    = 'sec';
x.General.timing_unit   = 'ms';
x.General.comment       = 'FILL IN LATER';

%saving important MEMR data
x.stim = stim;
if exists('stim_AR',1)
    x.stim_AR = stim_AR;
end 

save(fname,'x');

