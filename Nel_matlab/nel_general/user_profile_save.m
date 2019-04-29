function user_profile_save(user_name)
%

% AF 10/31/01

global userProfile__
global profiles_dir

if (exist('user_name','var') ~= 1)
   user_name = '';
end

if (isempty(user_name))
   nelerror('user_profile_save: Can''t save profile without user name');
else
   fname = [profiles_dir user_name];
   try
      save(fname,'userProfile__');
   catch
      nelerror(['user_profile_save: Problem saving user profile in: ' fname]);
   end
end
