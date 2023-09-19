function [fnum] = make_average_text_file(comment)

global data_dir NelData PROG Stimuli AVdata

fname = current_data_file('EPavg');

x.General.program_name    = PROG.name;
x.General.picture_number  = NelData.General.fnum +1;
x.General.date            = date;
x.General.time            = datestr(now,13);
x.General.comment         = comment;
 
%store the parameter block

x.Stimuli.freq_hz         = Stimuli.freq_hz;
x.Stimuli.play_duration   = Stimuli.play_duration;
x.Stimuli.record_duration = Stimuli.record_duration;
x.Stimuli.SampRate        = Stimuli.SampRate;
x.Stimuli.pulses_per_sec  = Stimuli.pulses_per_sec;
x.Stimuli.rise_fall       = Stimuli.rise_fall;
x.Stimuli.naves           = Stimuli.naves;
x.Stimuli.db_atten        = Stimuli.db_atten;
x.Stimuli.amp_gain        = Stimuli.amp_gain;

%store the data in four columns (time buf1 buf2 abr)
x.AverageData = AVdata;
x.User = NelData.General.User;

x.Hardware.amp_vlt    = NelData.General.Volts;

rc = write_nel_data(fname,x,0);
while (rc < 0)
    title_str = ['Choose a different file name! Can''t write to ''' fname ''''];
    [fname dirname] = uiputfile(fullfile(fileparts(fname),'*.m'),title_str);
    fname = fullfile(dirname,fname);
    rc = write_nel_data(fname,x,0);
end

d = dir(fullfile(data_dir,NelData.General.CurDataDir));
fnum = length(d(find([d.isdir]==0)));
