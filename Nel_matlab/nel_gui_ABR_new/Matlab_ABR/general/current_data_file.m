function name = current_data_file(short_description)

global NelData data_dir

if (exist('short_description','var') ~= 1)
   short_description = 'unknown';
end

if (isempty(NelData.General.CurDataDir))
   NelData.General.CurDataDir = 'lost&found';
   warndlg('Data directory unspecified. Saving in lost&found...','File Error');
end

file = sprintf('%s%s%03d%s',short_description,'_p',NelData.General.fnum+1,'.m');
name = fullfile(data_dir,NelData.General.CurDataDir,file);