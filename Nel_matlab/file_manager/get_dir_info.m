function get_dir_info(dirname)
% get_dir_info(dirname)
%      returns the saved picture numnber, track and unit for a given data directory.

% AF 11/28/01

global NelData

% NelData.File_Manager.picture = val_from_filename([dirname 'p*.m'],
% 'p%d_u'); % Commented SP: on 22Sep19
NelData.File_Manager.picture = max(val_from_filename([dirname 'p*'], 'p%d_u'), val_from_filename([dirname 'a*'], 'a%d_u'));

track.No = val_from_filename([dirname 'Track_*.m'], 'Track_%d');
if (track.No == 0)
   new_track(0); % This will update NelData with track.No=0 and Unit.No=0
   return;
end
origdir = cd(dirname);
try
   NelData.File_Manager.track = eval(['Track_' int2str(track.No)]);
   cd(origdir)
catch
   cd(origdir);
   nelerror(lasterr);
end

unit.No = val_from_filename([dirname 'Unit_' int2str(track.No) '*.m'], ['Unit_' int2str(track.No) '_%d']);
if (unit.No == 0)
   new_unit(0);
   return;
end
origdir = cd(dirname);
try
   fname = sprintf('Unit_%d_%02d',track.No,unit.No);
   NelData.File_Manager.unit = eval(fname);
   cd(origdir);
catch
   cd(origdir);
   nelerror(lasterr);
end

%----------------------------------------
function val = val_from_filename(dirname, frmt)
d = dir(dirname);
u = zeros(length(d),1);
for i = 1:length(d)
   tmp = sscanf(d(i).name, frmt);
   if (~isempty(tmp))
      u(i) = tmp;
   end
end
if (~isempty(u))
   val = max(u);
else
   val = 0;
end
