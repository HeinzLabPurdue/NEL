% make_ABR_text_file_subfunc1.m

if Stimuli.clickYes ~= 1 %KH 09Jan2012
    fname = current_data_file([misc.fileExtension '_' num2str(Stimuli.freq_hz)],1);
else
    fname = current_data_file([misc.fileExtension '_click'],1);
end

% [pathstr name ext versn]=fileparts(fname);
[pathstr, name, ext]=fileparts(fname);
aux_fname = fullfile(pathstr,['a' name(2:end)]);
% aux_fname = fullfile(pathstr,['p' name(2:end)]);
x.General.program_name  = PROG.name;
% AF FA 6/24/24  add which NEl which is savd in VERSION

x.General.picture_number = NelData.File_Manager.picture+1;
x.General.date          = date;
x.General.time          = datestr(now,13);
x.General.comment       = comment;
x.General.host = lower(getenv('hostname'));

x.General.rejections    = rejections; % KH 2011 Jun 08

x.General.runAudiogram = runAudiogram; %KH 10Jan2012

x.Stimuli=Stimuli;
x.Stimuli.RunLevels_params = RunLevels_params;
x.Stimuli.CAP_Gating = CAP_Gating;
x.Line.freq_Hz = Stimuli.freq_hz;

invfiltdata = get(FIG.radio.invCalib,'UserData'); 
x.invfilterdata = invfiltdata; 

x.AD_Data.Gain=Display.Gain;
x.AD_Data.SampleRate= Stimuli.RPsamprate_Hz/RunLevels_params.decimateFact;
x.MetaData=NelData.Metadata;
