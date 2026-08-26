function [x, aux_fname, fname] = make_Bic_text_file_subfunc1 ...
    (misc, pABRstim, invfiltdata, PROG, NelData, comment, ...
    RunLevels_params, FFR_Gating, Display, FFRattens, ...
    FFRinterstim, BIC_condition)

level = FFRattens{1};

label = sprintf('pABR_BIC_%s_%gdB', ...
    BIC_condition,level);

fname = current_data_file(label,1);

if contains(fname,'pink')
    fname = strrep(fname,'pinkSSN_Stim_','pink_');
    fname = strrep(fname,'_P_','_');
end

fname = strrep(fname,'complex_','');

[pathstr,name,~] = fileparts(fname);

aux_fname = fullfile(pathstr,['a' name(2:end)]);

x.General.program_name = PROG.name;
x.General.picture_number = NelData.File_Manager.picture+1;
x.General.date = date;
x.General.time = datestr(now,13);
x.General.comment = comment;
x.General.host = lower(getenv('hostname'));

x.Stimuli = pABRstim;
x.Stimuli.BIC_condition = BIC_condition;
x.Stimuli.RunLevels_params = RunLevels_params;
x.Stimuli.FFR_Gating = FFR_Gating;

x.invfilterdata = invfiltdata;

x.AD_Data.Gain = Display.Gain;
x.MetaData = NelData.Metadata;

x.Line.attens_dB = FFRattens;
x.Line.intervalstim = FFRinterstim;

end