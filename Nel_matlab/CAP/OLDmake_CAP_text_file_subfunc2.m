% make_CAP_text_file_subfunc1.m

fname = current_data_file([misc.fileExtension '_' num2str(Stimuli.freq_hz)],1);
[pathstr name ext versn]=fileparts(fname);
aux_fname = fullfile(pathstr,['a' name(2:end)]);

x.General.program_name  = PROG.name;
x.General.picture_number = NelData.File_Manager.picture+1;
x.General.date          = date;
x.General.time          = datestr(now,13);
x.General.comment       = comment;
x.General.host = lower(getenv('hostname'));

x.Stimuli=Stimuli;
x.Stimuli.RunLevels_params = RunLevels_params;
x.Stimuli.CAP_Gating = CAP_Gating;
x.Line.freq_Hz = Stimuli.freq_hz;

x.AD_Data.Gain=Display.Gain;