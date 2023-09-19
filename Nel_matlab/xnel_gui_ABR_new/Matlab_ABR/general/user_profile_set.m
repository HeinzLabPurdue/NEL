function user_profile_set(entry_name,val,lower_case_only)
%

% AF 10/31/01

global userProfile__

if (exist('lower_case_only','var') ~= 1)
   lower_case_only = 0;
end
if (lower_case_only)
   entry_name = lower(entry_name);
end

eval(['userProfile__.' entry_name ' = val;']); % faster than setfield
