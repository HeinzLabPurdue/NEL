function my_startup
% MY_STARTUP personlized startup file for nel users

%% set for XX
% To copy for new ueser XX, replace all "MH" with "XX"

global XX_root_dir

XX_root_dir = [fileparts(which('my_startup')) filesep];

addpath([XX_root_dir  'Templates']);

XX_Templates = struct(...
   'TB',                  'TB_template', ...
   'FN',                  'FN_template' ...
   );

register_user_templates(XX_Templates);
