function my_startup
% MY_STARTUP personlized startup file for nel users

%% set for AS
% To copy for new ueser AS, replace all "MH" with "AS"

global AS_root_dir

AS_root_dir = [fileparts(which('my_startup')) filesep];

addpath([AS_root_dir  'Templates']);

AS_Templates = struct(...
   'TB',                  'TB_template', ...
   'FN',                  'FN_template' ...
   );

register_user_templates(AS_Templates);
