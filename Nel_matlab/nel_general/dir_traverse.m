function dir_traverse(dirname,cmd,do_recurse,verbose,varargin)
% DIR_TRAVERSE executes a command on each file in a directory (recursively).
%              dir_traverse(dirname,cmd). cmd gets one parameter which is a file 
%              structure as returned by 'dir' command.
%              Example: dir_traverse('d:\temp\old-phd','lower_case_fname')

% Alon Fishbach 13/8/99

if (exist('do_recurse','var') ~= 1)
   do_recurse = 1;
end
if (exist('verbose','var') ~= 1)
   verbose = 0;
end

% if (exist('parameter') ~= 1)
%    parameter = [];
% end
parrent = pwd;
cd(dirname);
fprintf('--------------\n\t\tGoing into %s Directory\n',dirname);
%eval(cmd);
files = dir;
for i = 1:length(files)
   if (files(i).isdir)
      if (do_recurse)
         if (files(i).name(1) ~= '.')
            eval([cmd '( files(i).name )']);
            dir_traverse(files(i).name,cmd,do_recurse,verbose,varargin{:}); %% Rrecursive call;
         end
      end
   else
      if (verbose)
         if (ishandle(verbose))
            set(verbose,'String',files(i).name);
            drawnow;
         else
            fprintf('%s\n', files(i).name);
         end
      end
      if (isempty(varargin))
         eval([cmd '( files(i).name );']);
      else
         eval([cmd '( files(i).name,varargin{:} );']);
      end
   end
end
cd(parrent)
