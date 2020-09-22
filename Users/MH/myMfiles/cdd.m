% CDD - Change to the data directory
% SP on 10/17/2019: made it a function because calling cdd in a function where NelData is alrady in
% workspace overwrites NelData values. 
function cdd()
global NelData SaveDirXYZ

SaveDirXYZ = cd;
cd(NelData.File_Manager.dirname);
% fprintf('\nRemember to call RDD to reset directory.\n')
