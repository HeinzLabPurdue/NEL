function user_profile_save(user_name)
%

% AF 10/31/01

global userProfile__
global profiles_dir

if (exist('user_name','var') ~= 1)
   user_name = '';
end

if (isempty(user_name))
   waitfor(errordlg('Can''t save profile without user name','user_profile_save'));
else
   fname = [profiles_dir user_name];
   try
      save(fname,'userProfile__');
   catch
      waitfor(errordlg(['Problem saving user profile in: ' fname],'user_profile_save'));
   end
end
