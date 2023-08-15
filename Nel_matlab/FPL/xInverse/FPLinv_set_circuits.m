function [error] = FPLinv_set_circuits()

global  COMM FIG Stimuli coefFileNum

error = 0;

object_dir = ('C:\NEL\Nel_matlab\FPL\Inverse\object'); 

%% Set to run inverse only

filttype = {'inversefilt','inversefilt'};
cdd;
all_raw = findPics('raw*');
RawCalibPicNum = max(all_raw);

%prompt user for RAW calib
RawCalibPicNum = inputdlg('Please confirm the RAW calibration file to use (default = last raw calib): ', 'Calibration!',...
    1,{num2str(RawCalibPicNum)});
RawCalibPicNum = str2double(RawCalibPicNum{1});
rdd;

invfilterdata = set_invFilter(filttype, RawCalibPicNum, true);
coefFileNum = invfilterdata.coefFileNum;


%%
if Stimuli.chan == 1 %left ear
    %%
    %     COMM.handle.RP2_1 = actxcontrol('RPco.x',[0 0 5 5]);
    %     status1 = invoke(COMM.handle.RP2_1, 'ConnectRP2', NelData.General.TDTcommMode, 1);
    [COMM.handle.RP2_1, status1]=connect_tdt('RP2', 1);
    invoke(COMM.handle.RP2_1,'LoadCof',[object_dir '\make_tone_left.rcx']);
    invoke(COMM.handle.RP2_1,'SetTagVal','Select',160); % original
    % 8/4/23 (MH/AS): Allow pre-PA1/2 cross over (Select) to avoid LE distortion/-30dB atten from RP2-2Out1.  Use post PA1/2 cross-over (Connect) to aviod the bad hardware on HeinzLab NEL2 Mix/select
    %     invoke(COMM.handle.RP2_1,'SetTagVal','Select',120); % Hack to aviod bad mix/selector hardware on LE
    invoke(COMM.handle.RP2_1,'Run');
    
    %     COMM.handle.RP2_2 = actxcontrol('RPco.x',[0 0 5 5]);
    %     status2 = invoke(COMM.handle.RP2_2, 'ConnectRP2', NelData.General.TDTcommMode, 2);
    [COMM.handle.RP2_2, status2 ]=connect_tdt('RP2', 2);
    invoke(COMM.handle.RP2_2,'LoadCof',[object_dir '\make_tone_right_PU.rcx']);
    invoke(COMM.handle.RP2_2,'SetTagVal','Select', 56);   % original
    % 8/4/23 (MH/AS): Allow pre-PA1/2 cross over (Select) to avoid LE distortion/-30dB atten from RP2-2Out1.  
    %     Use post PA1/2 cross-over (Connect) to aviod the bad hardware on HeinzLab NEL2 Mix/select
    %     invoke(COMM.handle.RP2_2,'SetTagVal','Select', 0);
    invoke(COMM.handle.RP2_2,'Run');

else   % right ear
    %     COMM.handle.RP2_1 = actxcontrol('RPco.x',[0 0 5 5]);
    %     status1 = invoke(COMM.handle.RP2_1, 'ConnectRP2', NelData.General.TDTcommMode, 1);
    [COMM.handle.RP2_1, status1]=connect_tdt('RP2', 1);
    invoke(COMM.handle.RP2_1,'LoadCof',[object_dir '\make_tone_left.rcx']);
    invoke(COMM.handle.RP2_1,'SetTagVal','Select',56);
    invoke(COMM.handle.RP2_1,'Run');
    
    %     COMM.handle.RP2_2 = actxcontrol('RPco.x',[0 0 5 5]);
    %     status2 = invoke(COMM.handle.RP2_2, 'ConnectRP2', NelData.General.TDTcommMode, 2);
    [COMM.handle.RP2_2, status2]=connect_tdt('RP2', 2);
    invoke(COMM.handle.RP2_2,'LoadCof',[object_dir '\make_tone_right_PU.rcx']);
    invoke(COMM.handle.RP2_2,'SetTagVal','Select',64);
    invoke(COMM.handle.RP2_2,'Run');
end

if ~status1 || ~status2
    set(FIG.ax2.ProgMess,'String','TONE: Not communicating with TDT system!');
    error = 1;
end
