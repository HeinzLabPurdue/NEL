% make_CAP_text_file.m
% Adapted from "make_tc_text_file.m" by GE/MH, 02Nov2003.

fname = current_data_file('CAP1f',1);

x.General.program_name  = PROG.name;
x.General.picture_number = NelData.File_Manager.picture+1;
x.General.date          = date;
x.General.time          = datestr(now,13);
x.General.comment       = comment;

%store the parameter block
x.Stimuli=Stimuli;
x.Stimuli.RunLevels_params = RunLevels_params;

x.Line.freq_Hz = Stimuli.freq_hz;
x.Line.attens_dB = CAPattens; % cell array(3)

for i=1:length(CAPdataAvg)
   if (RunLevels_params.decimateFact~=1)
      CAPdataAvg{i} = decimate(CAPdataAvg{i}, RunLevels_params.decimateFact);
   end
end


x.CAPDataAvg_V = CAPdataAvg; %cell array(3)

%x.User = [];


rc = write_nel_data(fname,x,0);
while (rc < 0)
   title_str = ['Choose a different file name! Can''t write to ''' fname ''''];
   [fname dirname] = uiputfile([fileparts(fname) filesep '*.m'],title_str);
   rc = write_nel_data(fullfile(dirname,fname),x,0);
end
NelData.File_Manager.picture = NelData.File_Manager.picture+1;