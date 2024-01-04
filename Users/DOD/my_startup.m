function my_startup
% MY_STARTUP personlized startup file for nel users

global DOD_root_dir

DOD_root_dir = [fileparts(which('my_startup')) filesep];

addpath([DOD_root_dir  'Templates']);

DOD_Templates = struct(...
   'TB',                  'TB_template', ...
   'FN',                  'FN_template' ...
   );

register_user_templates(DOD_Templates);
