function startup
global root_dir data_dir home_dir NelData

root_dir = fileparts(fileparts(which('startup')));
home_dir = fileparts(root_dir);
data_dir = fullfile(home_dir,'ExpData');

addpath(fullfile(root_dir,'general'));
addpath(fullfile(root_dir,'file_manager'));
addpath(fullfile(root_dir,'signal_averager'));
addpath(fullfile(root_dir,'abr_analysis'));

get_user_info;

%--------------------------------------------------------------------------
%may need to copy calibration file from general folder to data dir

if ~exist(fullfile(NelData.General.CurDataDir,'cal_p001.m'),'file')
    destination = [data_dir filesep NelData.General.CurDataDir filesep 'cal_p001.m'];
    success = copyfile('cal_p001.m',destination);
    if success
        d = dir(fullfile(data_dir,NelData.General.CurDataDir));
        fnum = length(d(find([d.isdir]==0)));
        UpdateExplist(fnum);
    else
        warndlg('Calibration file wasn''t copied to data directory.','File Manager');
    end
end
%--------------------------------------------------------------------------

signal_averager;