global root_dir home_dir data_dir signals_dir profiles_dir host icon_dir SKIPintro

fs = filesep;
root_dir = [fileparts(fileparts(which('startup'))) fs];
% root_dir = [fileparts(fileparts(which('XXXstartup'))) fs]; %testing for renamed startup file
home_dir = [fileparts(fileparts(root_dir))];
if (~isequal(home_dir(end),'\'))
   home_dir = [home_dir '\'];
end
data_dir = [home_dir 'ExpData' fs];
signals_dir = [home_dir 'Signals' fs];
icon_dir = [root_dir 'nel_gui\icons' fs];
profiles_dir = [home_dir 'NelUsersProfiles' fs];

addpath([root_dir  'nel_general']);
addpath([root_dir  'tdt_interface']);
addpath([root_dir  'nel_gui']);
addpath([root_dir  'stimulate']);
addpath([root_dir  'stimulate' fs 'Templates']);
addpath([root_dir  'file_manager']);
addpath([root_dir  'inhibit']); %MKW 10/17/2014 M.Sayles suppression/inhibit button
addpath([root_dir  'tuning_curve']);
% addpath([root_dir  'srcal_232']);
addpath([root_dir  'calibration']);
addpath([root_dir  'search']);
addpath([root_dir  'mex']);
addpath([root_dir  'DPOAE']);
addpath([root_dir  'CAP']);
addpath([root_dir  'NELanalysis_Mfiles']);
% addpath([root_dir  'wiring_test']);   %LQ 10/29/04

%% Decide whether to run FAKE_TDT (e.g., on a PC not connected to TDT) or REAL_TDT 
% if (isunix)
%    [rc host] = dos('hostname');
%    host = lower(strtok(host,'.'));
% else
%    host = lower(getenv('hostname'));
% end
% host = host(~isspace(host));

%% FOR FASTER DEBUGGING, skip all questions
SKIPintro=1;

if SKIPintro
    ButtonName='Real_TDT';
else    
    ButtonName=questdlg('Do you want to Emulate TDT?','TDT Emulation SETUP','Emulate_TDT','Real_TDT','Emulate_TDT');
    
    if strcmp(ButtonName,'Emulate_TDT')
        addpath([home_dir 'fake_tdt']);
        fprintf( '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n');
        fprintf( '!!          HOST: %-15s      !!\n', host);
        fprintf( '!!     Using a fake tdt-interface      !!\n');
        fprintf( '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n');
    end
end
nelinit

% switch (host)
%    %case {'alon_home','chernoble','south-chamber','behemoth','providence'}
% case {'alon_home','chernoble','behemoth','providence','carassius'}
%    addpath([home_dir 'fake_tdt']);
%    fprintf( '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n');
%    fprintf( '!!          HOST: %-15s      !!\n', host);
%    fprintf( '!!     Using a fake tdt-interface      !!\n');
%    fprintf( '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n');
% end
% nelinit