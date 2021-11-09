function dev = nel_devices_vector(dev_names, dev_desc)
% 

% AF 9/23/01


dev = repmat(NaN,9,1);
description = cell(9,1);
% L6  L3  R6  R3  KH-oscilator RP1-ch1 RP1-ch2 RP2-ch1 RP2-ch2
if (nargin == 0)
   disp_usage;
   return
elseif (nargin == 1) 
   dev = repmat(NaN,9,1);
   if (isempty(dev_names))
      return;
   else
      dev_desc = {};
   end
else 
   dev = cell(9,1);
end
if (~iscell(dev_names))
   dev_names = {dev_names};
end
if (~iscell(dev_desc))
   dev_desc = {dev_desc};
end
for i = 1:length(dev_names)
   switch (lower(dev_names{i}))
   case {'rp1-ch1','rp1_1','rp1.1','1.1','1_1'}
      ind = 6;
   case {'rp1-ch2','rp1_2','rp1.2','1.2','1_2'}
      ind = 7;
   case {'rp2-ch1','rp2_1','rp2.1','2.1','2_1'}
      ind = 8;
   case {'rp2-ch2','rp2_2','rp2.2','2.2','2_2'}
      ind = 9;
   case {'KH-oscilator','KH-osc','KH','oscilator'}
      ind = 5;
   case {'r3'}
      ind = 4;
   case {'r6'}
      ind = 3;
   case {'l3'}
      ind = 2;
   case {'l6'}
      ind = 1;
   otherwise
      opt = grep(which(mfilename),'case ');
      header = 'nel_devices_vector'; 
      msg = cat(1,{['Illegal option ''' dev_names{i} '''. Legal options:']}, opt(1:end-3));
      waitfor(errordlg(msg,header));
   end
   if (nargin == 1)
      dev(ind) = 1;
   else
      dev{ind} = dev_desc{i};
   end
end
%%%%%%%%%%%%%%%%%%%%%%%%      
function disp_usage
opt = grep(which(mfilename),'case ');
msg = cat(1,{['Legal case options:']}, opt(1:end-3));
fprintf('%s\n', msg{:});
return
