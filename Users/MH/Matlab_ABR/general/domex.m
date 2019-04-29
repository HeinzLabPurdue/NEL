function domex(fnames,dist,debug)
% DOMEX  calls mex 

% AF 10/15/01

global root_dir

if (exist('dist','var') ~= 1)
   dist = 0;
end
if (exist('debug','var') ~=1)
   debug = 0;
end

orig_dir = cd([root_dir 'mex\source\']);
mexdir    = [root_dir 'mex'];

if (iscell(fnames))
   for i = 1:length(fnames)
      call_mex(char(fnames(i)),dist,debug,mexdir);
   end
else
   call_mex(char(fnames),dist,debug,mexdir);
end
cd(orig_dir);
return;

% call_mex
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function call_mex(name,dist,debug,mexdir)

if (debug)
   fprintf(['Compiling (with debug information) and Linking '  name '...']);
   eval([ 'mex -g -O ' name ]);
else
   fprintf(['Compiling and Linking '  name '...']);
   eval([ 'mex -O ' name ]);
end
if (dist)
   fname = strtok(name,'.c');
   disp(['copy '  fname ' to ' mexdir]);
   if (copyfile([fname '.dll'], mexdir) ~= 1)
      warning(['Can''t dist ' fname '.dll']);
   end
end
return;