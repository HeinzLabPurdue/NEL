function [data,sr,rc] = nel_wavread_smc(fname)

% SMC 4/7/04
% Differs from nel_wavread in that it does not copy the files into the ExpData/Signals directory.
% Had to do this because the randomcarrier directory tends to get very large, and copying into it gets
% slower and slower, to the point where cycle usage becomes a problem.


% AF 10/23/01
 
global NelData signals_dir

data = [];
sr   = [];
rc = 1;

eval('[data,sr] = audioread(fname);', 'rc=0;');

if (rc == 0)
   nelerror(['nel_wavread: Can''t read wavfile ''' fname '''']);
   return;
% else
%    if (~isempty(NelData.File_Manager.dirname))
%       % if the wav file is within the signals_dir, copy the dir structure, else
%       % copy just the file.
%       if (~isempty(findstr(lower(signals_dir),lower(fname))))
%          tail_fname = fname(length(signals_dir)+1:end);
%          lastsep = max(findstr(filesep,tail_fname));
%          dest_fname = [NelData.File_Manager.dirname 'Signals\' tail_fname(1:lastsep)];
%       else
%          dest_fname = [NelData.File_Manager.dirname 'Signals\' ];
%       end
%       [path name ext] = fileparts(fname);
%       %if (exist(dest_fname,'file') ~= 1) % LQ 12/15/03 this will always xcopy since dest_fname is not file
%       if (~exist([dest_fname name ext],'file')) 
%          [rcdos status] = dos(['xcopy ' fname ' ' dest_fname ' /Y /Q']);
%       end
%    end
end
