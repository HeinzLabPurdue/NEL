function [fnum] = make_calib_text_file(comment)

global data_dir home_dir root_dir NelData PROG Stimuli DDATA

fname = current_data_file('cal');

x.General.program_name  = PROG.name;
x.General.picture_number= NelData.General.fnum +1;
x.General.date          = date;
x.General.time          = datestr(now,13);
x.General.comment       = comment;

%store the parameter block

x.Stimuli.frqlo  = Stimuli.frqlo;
x.Stimuli.frqhi  = Stimuli.frqhi;
x.Stimuli.frqcal = Stimuli.frqcal;
x.Stimuli.syslv = Stimuli.attencal;

x.CalibData = DDATA;
x.User = NelData.General.User;

x.Hardware.mic        = Stimuli.nmic;
x.Hardware.amp_vlt    = NelData.General.Volts;

rc = write_nel_data(fname,x,0);
while (rc < 0)
    title_str = ['Choose a different file name! Can''t write to ''' fname ''''];
    [fname dirname] = uiputfile(fullfile(fileparts(fname),'*.m'),title_str);
    fname = fullfile(dirname,fname);
    rc = write_nel_data(fname,x,0);
end

copyfile(fname,fullfile(root_dir,'general','lastcal.m'));
d = dir(fullfile(data_dir,NelData.General.CurDataDir));
fnum = length(d(find([d.isdir]==0)));
