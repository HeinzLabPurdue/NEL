function dev = nel_devices_vector(dev_names, dev_desc)
% 

% AF 9/23/01

global devices_names_vector
% For example, the standard nel device_names_vector is:
% devices_names_vector = {'L6'  'L3'  'R6'  'R3'  'KH-oscillator' 'RP1-ch1' 'RP1-ch2' 'RP2-ch1' 'RP2-ch2'};

dev = repmat(NaN,length(devices_names_vector),1);
description = cell(length(devices_names_vector),1);
if (nargin == 0)
   disp_usage;
   return
elseif (nargin == 1) 
   dev = repmat(NaN,length(devices_names_vector),1);
   if (isempty(dev_names))
      return;
   else
      dev_desc = {};
   end
else 
   dev = cell(length(devices_names_vector),1);
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
      canonic_name = 'RP1-ch1';
   case {'rp1-ch2','rp1_2','rp1.2','1.2','1_2'}
      canonic_name = 'RP1-ch2';
   case {'rp2-ch1','rp2_1','rp2.1','2.1','2_1'}
      canonic_name = 'RP2-ch1';
   case {'rp2-ch2','rp2_2','rp2.2','2.2','2_2'}
      canonic_name = 'RP2-ch2';
   case {'kh-oscillator','kh-osc','kh','oscillator'}
      canonic_name = 'KH-oscillator';
   case {'r3'}
      canonic_name = 'R3';
   case {'r6'}
      canonic_name = 'R6';
   case {'l3'}
      canonic_name = 'L3';
   case {'l6'}
      canonic_name = 'L6';
   otherwise
      opt = grep(which(mfilename),'case ');
      header = 'nel_devices_vector'; 
      msg = cat(1,{['Illegal option ''' dev_names{i} '''. Legal options:']}, opt(1:end-3));
      waitfor(errordlg(msg,header));
      canonic_name = '';
   end
   ind = strmatch(canonic_name,devices_names_vector,'exact');
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
