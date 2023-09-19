function err_str = nidaq_error_code(err_code)
%

% AF 10/29/01

global root_dir

err_file = [root_dir 'mex\source\nidaqerr.h'];

err_str = '';
strs = grep(err_file,num2str(err_code));
if (length(strs) == 1)
   if (~isempty(strs) & ~isempty(strs{1}))
      err_str = strs{1}(50:end);
   end
elseif (length(strs) > 1)
   warning(['More than one possible error code for ''' num2str(err_code) '''']);
end
