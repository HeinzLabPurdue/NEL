function [name,file_name] = current_data_file(short_description,supp_unitno)
%function [name,file_name] = current_data_file(short_description,supp_unitno) % MH/GE 11/03/03
% [name file_name] = current_data_file(short_description)

% AF 10/22/01

global NelData

if (exist('supp_unitno','var') ~= 1)
   supp_unitno=0;
end

if (exist('short_description','var') ~= 1)
   short_description = '';
end

if (isempty(NelData.File_Manager.dirname))
   nelerror('NelData.File_Manager.dirname is empty! please notify the authorities. Fixing the problem...');
   choose_data_dir;
end
pic = NelData.File_Manager.picture + 1;
%if (strcmp(short_description,'calib'))  %% MH/GE 11/03/03 changed to generalize
if supp_unitno
   name = sprintf('%sp%04d_%s',NelData.File_Manager.dirname,pic,short_description);
else
   track = NelData.File_Manager.track.No;
   unit  = NelData.File_Manager.unit.No;
   name = sprintf('%sp%04d_u%d_%02d',NelData.File_Manager.dirname,pic,track,unit);
   if (~isempty(short_description) & ~all(isspace(short_description)))
      name = [name '_' short_description];
   end
end
file_name = fliplr(strtok(fliplr(name),'\'));