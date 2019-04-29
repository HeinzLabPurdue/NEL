function [LFileList,RFileList,rotlist_name] = read_rotate_list_file(rotlist_name)
% [LFileList,RFileList,rotlist_name] = read_rotate_list_file(rotlist_name)

% AF 12/4/01

[rotlist_dir rotlist_file rotlist_ext] = fileparts(rotlist_name);
addpath(rotlist_dir);
try
   eval(rotlist_file);
catch
   nelerror(['Error in ''' rotlist_name ''': ' lasterr  'No stimulus will be generated.']);
   RFileList = [];   LFileList = [];
   rmpath(rotlist_dir);
   return
end
rmpath(rotlist_dir);

if (exist('Rchannel','var') ~= 1)
   Rchannel = [];
end
if (exist('Lchannel','var') ~= 1)
   Lchannel = [];
end

if (isempty(Rchannel) & isempty(Lchannel))
   nelerror(['''' rotlist_name ''' contains no definition for ''Rchannel'' and ''Lchannel''. '  ...
         'No stimulus will be generated.']);
   RFileList = [];   LFileList = [];
   return
end
try
   eval('RFileList = expand_file_list(Rchannel);');
catch
   nelerror(['Error while expanding Rchannel file list: ''' lasterr ''' No stimulus will be generated.']);
   RFileList = [];   LFileList = [];
   return
end
try
   eval('LFileList = expand_file_list(Lchannel);');
catch
   nelerror(['Error while expanding Lchannel file list: ''' lasterr ''' No stimulus will be generated.']);
   RFileList = [];   LFileList = [];
   return
end

return
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function flist = expand_file_list(spec)
%%
if (isempty(spec))
   flist = [];
   return;
end
flist = cell(1,100);
counter = 0;
for i = 1:length(spec.file_list)
   a = dir(spec.file_list{i});
   dirname = [fileparts(spec.file_list{i}) filesep];
   for j = 1:length(a)
      counter = counter+1;
      flist{counter} = [dirname a(j).name];
   end
end
flist = flist(1:counter);
if ((isfield(spec,'sort')) & (spec.sort == 1))
   flist = sort(flist);
end
if (isfield(spec,'shift'))
   N = length(flist);
   if (spec.shift > 0)
      flist = flist([N-(spec.shift-1:-1:0) 1:N-spec.shift]);
   else
      flist = flist([-spec.shift+1:N 1:-spec.shift]);
   end
end
return
