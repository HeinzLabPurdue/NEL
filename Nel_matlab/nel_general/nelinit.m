function nelinit
% NELINIT variable initialization

% AF 8/22/01

global root_dir profiles_dir host
% global RP PA Trigger SwitchBox
global default_rco NelData ProgName

set(0,'DefaultTextInterpreter','none');  % so we can display strings with '_' properly
set(0,'defaultTextColor','k');

ProgName    = 'Nel 1.2.0';
default_rco = [root_dir 'stimulate\object\control.rco'];

if (~isempty(host) & exist(['hardware_setup_' host],'file'))
    eval(['hardware_setup_' host]);
else
    hardware_setup_default;
end

Nel_Templates = struct(...
    'RLV',                  'nel_rate_level_template', ...
    'RM',                   'nel_resp_map_template', ...
    'NO',                   'nel_noise_rlv_template', ...
    'PST',                  'nel_pst_template', ...
    'PST_tone',             'nel_pst_tone_template', ...
    'PST_noise',            'nel_pst_noise_template', ...
    'RLV_2T',               'nel_TT_rate_level_template', ...
    'RM_2T',                'nel_TT_resp_map_template', ...
    'WAV',                  'nel_wavfile_template', ...
    'WAV_NIboard',          'nel_NI_wavfile_template', ...
    'ROT',                  'nel_rot_wavfile_template', ...
    'ROT_NIboard',          'nel_rot_NI_wavfile_template', ...
    'general_tone_noise',   'general_tone_noise_template', ...
    'notch_frequency_sweep','noisebands_template' ... %LQ 11/14/03 Include Lina's noisebands stimuli
    );

save_fname = [profiles_dir 'Nel_Workspace'];
if (exist([save_fname '.mat'],'file'))
    saved = load([profiles_dir 'Nel_Workspace.mat']);
else
    %TODO: empty the block_templates definition
    saved.NelData = struct('General', struct('User','', 'nChannels',1, 'save_fname', save_fname), ...
        'File_Manager', [], ... % will be filled later.
        'Block_templates', Nel_Templates ...
        );
    saved.NelData.run_mode = 0;
end
NelData = saved.NelData;
NelData.File_Manager.track.No = -1;
NelData.File_Manager.unit.No = -1;
NelData.General.save_fname = save_fname;
NelData.General.Nel_Templates = Nel_Templates;
NelData.General.User_templates = [];
NelData.UnSaved = [];

% Check Windows User-Login
NelData.General.WindowsUserName = char(java.lang.System.getProperty('user.name'));
NelData.General.WindowsHostName = char(java.net.InetAddress.getLocalHost.getHostName);
NelData.General.RootDir= [fileparts(fileparts(pwd)) filesep];

nel;