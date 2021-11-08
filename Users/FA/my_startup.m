function my_startup
% MY_STARTUP personlized startup file for nel users

%% set for XX
% To copy for new ueser XX, replace all "MH" with "XX"

global FA_root_dir

FA_root_dir = [fileparts(which('my_startup')) filesep];

addpath([FA_root_dir  'Templates']);

FA_Templates = struct(...
   'TB',                  'TB_template', ...
   'FN',                  'FN_template' ...
   );

register_user_templates(FA_Templates);
