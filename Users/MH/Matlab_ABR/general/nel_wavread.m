function [data,sr,rc] = nel_wavread(fname)
%

% AF 10/23/01
 
global CurrentDataDir signals_dir

data = [];
sr   = [];
rc = 1;
eval('[data,sr] = wavread(fname);', 'rc=0;');
if (rc == 0)
   waitfor(errordlg(['Can''t read wavfile ''' fname ''''], 'nel_wavread'));
   return;
else
   if (~isempty(CurrentDataDir))
      % if the wav file is within the signals_dir, copy the dir structure, else
      % copy just the file.
      if (~isempty(findstr(lower(signals_dir),lower(fname))))
         tail_fname = fname(length(signals_dir)+1:end);
         lastsep = max(findstr(filesep,tail_fname));
         dest_fname = [CurrentDataDir 'Signals\' tail_fname(1:lastsep)];
      else
         dest_fname = [CurrentDataDir 'Signals\' ];
      end
      if (exist(dest_fname,'file') ~= 1) 
         [rcdos status] = dos(['xcopy ' fname ' ' dest_fname ' /Y /Q']);
      end
   end
end
