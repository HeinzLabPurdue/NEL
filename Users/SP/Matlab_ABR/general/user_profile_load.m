function user_profile_load(user_name);
%

% AF 10/30/01

global userProfile__
global profiles_dir

if (exist('user_name','var') ~= 1)
   user_name = '';
end

fname = [profiles_dir 'default_user'];
if (exist([fname '.mat'],'file'))
   dflt = load(fname);
else
   dflt.userProfile__ = [];
end
if (~isempty(user_name))
   fname = [profiles_dir user_name];
   if (exist([fname '.mat'],'file'))
      user_prof = load(fname);
   else
      user_prof.userProfile__ = [];
   end
else
   user_prof.userProfile__ = [];
end   

userProfile__ = merge_structs(dflt.userProfile__,user_prof.userProfile__);

