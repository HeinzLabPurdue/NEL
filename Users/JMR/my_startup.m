function my_startup
% MY_STARTUP personlized startup file for nel users

%% set for JMR
% To copy for new ueser JMR, replace all "MH" with "JMR"

global JMR_root_dir

JMR_root_dir = [fileparts(which('my_startup')) filesep];

addpath([JMR_root_dir  'Templates']);

JMR_Templates = struct(...
   'TB',                  'TB_template', ...
   'FN',                  'FN_template' ...
   );

register_user_templates(JMR_Templates);
