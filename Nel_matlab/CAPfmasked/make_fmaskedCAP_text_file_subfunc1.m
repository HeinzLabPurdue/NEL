% make_CAP_text_file_subfunc1.m

if isfield(Stimuli_adv.masker, 'name')
    maskerName = ['_' Stimuli_adv.masker.name];
    maskerName= strrep(maskerName, '-', '_');
else
    maskerName='';
end

fname = current_data_file([misc.fileExtension maskerName],1);


[pathstr, name, ext]=fileparts(fname); %MW 04-2017 removed 4th argument versn, unused and threw obscelence warning
aux_fname = fullfile(pathstr,['a' name(2:end)]);
% aux_fname = fullfile(pathstr,['p' name(2:end)]);
x.General.program_name  = PROG.name;
x.General.picture_number = NelData.File_Manager.picture+1;
x.General.date          = date;
x.General.time          = datestr(now,13);
x.General.comment       = CAPcomment;
x.General.host = lower(getenv('hostname'));

x.General.rejections    = rejections; % KH 2011 Jun 08

x.Stimuli=Stimuli_adv;  %Stimuli_adv contains info on the masker
x.Stimuli.RunStimuli_params = RunLevels_params;
x.Stimuli.CAP_intervals = CAP_intervals;

x.AD_Data.Gain=Display.Gain;