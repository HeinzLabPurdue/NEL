function my_startup
% MY_STARTUP personlized startup file for nel users

global MP_root_dir

MP_root_dir = [fileparts(which('my_startup')) filesep];

addpath([MP_root_dir  'Templates']);

MP_Templates = struct(...
   'TB',                  'TB_template', ...
   'FN',                  'FN_template' ...
   );

register_user_templates(MP_Templates);
