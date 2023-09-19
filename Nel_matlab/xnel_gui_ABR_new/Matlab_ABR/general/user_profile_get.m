function val = user_profile_get(entry_name,lower_case_only)
%

% AF 10/31/01

global userProfile__

if (exist('lower_case_only','var') ~= 1)
   lower_case_only = 0;
end
if (lower_case_only)
   entry_name = lower(entry_name);
end

if (isfield(userProfile__, entry_name))
   eval(['val = userProfile__.' entry_name ';']); % faster than getfield
end
