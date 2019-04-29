function int2wav(fname,fs,resample_flag)
% int2wav(fname,fs)

% AF 7/26/01

if (exist('resample_flag','var') ~= 1)
   resample_flag = 1;
end
clipping_factor = 10^(-1/20);

if (exist(fname,'dir') ~= 0)
   return;
end
[path,name,ext] = fileparts(fname);
if (~strcmp(ext,'.int'))
   disp([fname ' is not an int file']);
   return;
end
[y orig_fs] = read_intfile(fname);
y = clipping_factor*y/(2^15);

if (exist('fs','var') ~= 1)
   master_fs = 97656.25;
   factor = floor(master_fs/orig_fs);
   if (factor == 0)
      warning(sprintf('Can not convert %s. Sampling rate (%.1f) is too high',fname,orig_fs));
      return
   end
   fs = master_fs / factor;
end
if (resample_flag & orig_fs ~= fs)
   fprintf('converting from %.1f to %.1f\n', round(orig_fs), round(fs));
   y = resample(y,round(fs),round(orig_fs),100);
end
wavwrite(y,fs,fullfile(path,name));


% --------------------------------------------------------------------------
function [sig,fs] = read_intfile(fname)
fid = fopen(fname,'r','ieee-le');
header = fread(fid,2,'long');
sig    = fread(fid,Inf,'short');
fs     = header(1);
fclose(fid);