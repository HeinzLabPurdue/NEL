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

if (~isempty(host) && exist(['hardware_setup_' host],'file'))
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
%         saved.NelData = struct('Metadata',struct('NEL','','Date','','NELVersion',ProgName,'User','', 'Otherusers','', 'ChinID','','Sex','','Exposure','' ),'General', struct('User','', 'nChannels',1, 'save_fname', save_fname), ...
%         'File_Manager', [], ... % will be filled later.
%         'Block_templates', Nel_Templates ...
%         );  
    
    saved.NelData = struct('General', struct('User','', 'nChannels',1, 'save_fname', save_fname), ...
        'File_Manager', [], ... % will be filled later.
        'Block_templates', Nel_Templates ...
        );

    saved.NelData.run_mode = 0;
end


NelData = saved.NelData;
NelData.Metadata = struct('NEL','','Date','','NELVersion',ProgName,'User','', 'Otherusers','', 'ChinID','','Sex','','Exposure','','ExposureDate','','Branch','','Comments','','Sedation','', 'Dirname','','calib_type','');

NelData.File_Manager.track.No = -1;
NelData.File_Manager.unit.No = -1;
NelData.File_Manager.unit.SR = -1; %SP on 8May19
NelData.General.save_fname = save_fname;
NelData.General.Nel_Templates = Nel_Templates;
NelData.General.User_templates = [];
NelData.UnSaved = [];

% Check Windows User-Login
NelData.General.WindowsUserName = char(java.lang.System.getProperty('user.name'));
NelData.General.WindowsHostName = char(java.net.InetAddress.getLocalHost.getHostName);
NelData.General.RootDir= [fileparts(fileparts(pwd)) filesep];


%% Initialize NelData.General.**flags** to check
% if RP2 or RX8
% if USB or GB: assuming same connection mode for both RP2s and PA5s
% if 2 or 4 RP2s
% % % figure(314);
% % % text(0, .5,  'connecting to TDT', 'FontSize', 20);
% % % RPtemp= actxcontrol('RPco.x',[0 0 1 1]);
% % % yesUSB= invoke(RPtemp,'ConnectRP2', 'USB', 1);
% % % yesGB= invoke(RPtemp,'ConnectRP2', 'GB', 1);
% % % if yesUSB && ~yesGB
% % %     NelData.General.TDTcommMode= 'USB';
% % % elseif yesGB && ~yesUSB
% % %     NelData.General.TDTcommMode= 'GB';
% % % end
% % % 
% % % % Assuming RP2s only: will be different for RX8
% % % % Check how many RP2s
% % % initFlag= true;
% % % [~, yesRP1]= connect_tdt('RP2', 1, initFlag);
% % % [~, yesRP2]= connect_tdt('RP2', 2, initFlag);
% % % [~, yesRP3]= connect_tdt('RP2', 3, initFlag);
% % % [~, yesRP4]= connect_tdt('RP2', 4, initFlag);
% % % % yesRP1=invoke(RPtemp,'ConnectRP2', NelData.General.TDTcommMode, 1);
% % % % yesRP2=invoke(RPtemp,'ConnectRP2', NelData.General.TDTcommMode, 2);
% % % % yesRP3=invoke(RPtemp,'ConnectRP2', NelData.General.TDTcommMode, 3);
% % % % yesRP4=invoke(RPtemp,'ConnectRP2', NelData.General.TDTcommMode, 4);
% % % 
% % % if (yesRP1&&yesRP2) && (yesRP3&&yesRP4) % All RP2s are connected
% % %     NelData.General.RP2_3and4= true; % RP2 #3 and #4 are connected
% % % elseif (yesRP1&&yesRP2) && ~(yesRP3||yesRP4) % RP2s (1 and 2) connected, 3 and 4 do not exist
% % %     NelData.General.RP2_3and4= false; % RP2 #3 and #4 do are not connected
% % % else % Why is this happening
% % %     NelData.General.RP2_3and4= nan; % Error
% % % end
% % % 
% % % [~, yesRX8]= connect_tdt('RX8', 1, initFlag);
% % % % yesRX8=invoke(RPtemp,'ConnectRX8', NelData.General.TDTcommMode, 1);
% % % if yesRX8
% % %     NelData.General.RX8= true; % RX8 is connected
% % % else 
% % %     NelData.General.RX8= false; % RX8 is connected
% % % end
% % % close(314);

%%
%nel;

%toAppDesignerTag
nel_App