% make_FFR_text_file_subfunc1.m

fname = current_data_file([misc.fileExtension '_' num2str(Stimuli.fc) '_' num2str(Stimuli.fm)],1); % zz 04nov2011
[pathstr, name, ext]=fileparts(fname);
aux_fname = fullfile(pathstr,['a' name(2:end)]);

x.General.program_name  = PROG.name;


x.General.picture_number = NelData.File_Manager.picture+1;
x.General.date          = date;
x.General.time          = datestr(now,13);
x.General.comment       = comment;
x.General.host = lower(getenv('hostname'));

x.Stimuli=Stimuli;
x.Stimuli.RunLevels_params = RunLevels_params;
x.Stimuli.FFR_Gating = FFR_Gating;
x.Line.freq_Hz = Stimuli.fc; % zz 04nov11 original only had one frequency, updated to carrier frequency
x.invfilterdata = invfiltdata;

x.AD_Data.Gain=Display.Gain;
x.MetaData=NelData.Metadata;

stimuli_fname = fullfile(pathstr,'Signals');
copyfile(Stimuli.filename,stimuli_fname,'f');