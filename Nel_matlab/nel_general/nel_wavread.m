function [data,sr,rc] = nel_wavread(fname)
%

% AF 10/23/01
 
global NelData signals_dir

data = [];
sr   = [];
rc = 1;
eval('[data,sr] = audioread(fname);', 'rc=0;');
if (rc == 0)
   nelerror(['nel_wavread: Can''t read wavfile ''' fname '''']);
   return;
else
   if (~isempty(NelData.File_Manager.dirname))
      % if the wav file is within the signals_dir, copy the dir structure, else
      % copy just the file.
      if (~isempty(findstr(lower(signals_dir),lower(fname))))
         tail_fname = fname(length(signals_dir)+1:end);
         lastsep = max(findstr(filesep,tail_fname));
         dest_fname = [NelData.File_Manager.dirname 'Signals\' tail_fname(1:lastsep)];
      else
         dest_fname = [NelData.File_Manager.dirname 'Signals\' ];
      end
      [~, name, ext] = fileparts(fname);
      %if (exist(dest_fname,'file') ~= 1) % LQ 12/15/03 this will always xcopy since dest_fname is not file
      if (~exist([dest_fname name ext],'file')) 
         [~, ~] = dos(['xcopy ' fname ' ' dest_fname ' /Y /Q']);
      end
   end
end
