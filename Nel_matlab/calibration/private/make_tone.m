function [error] = make_tone()

global object_dir COMM FIG Stimuli newCalib doInvCalib coefFileNum NelData

error = 0;

%%
if (NelData.General.RP2_3and4 || NelData.General.RX8)
    cdd;
    all_Calib_files= dir('p*calib*');
    
    if isempty(all_Calib_files) 
            newCalib= true;
            doInvCalib = false;
    elseif ~Stimuli.completeRun
    else 
        inStr= questdlg('Calib files already exists - run new calib or use latest FIR coeffs?', 'New or Rerun?', 'New Calib', 'FIR Calib', 'FIR Calib');
        if strcmp(inStr, 'New Calib')
            newCalib= true;
            doInvCalib = false;
        elseif strcmp(inStr, 'FIR Calib')
            newCalib= false;
            doInvCalib = true;
        end
    end
    rdd;
    
    
%      doInvCalib= ~newCalib; % if not new (means old => coef-file exists), then run inverse calibration
%     coefFileNum= run_invCalib(doInvCalib);
    
    if doInvCalib %already has a raw
        filttype = {'inversefilt','inversefilt'};
        cdd;
        all_raw = findPics('raw*');
        RawCalibPicNum = max(all_raw);
        
        %prompt user for RAW calib
        RawCalibPicNum = inputdlg('Please confirm the RAW calibration file to use (default = last raw calib): ', 'Calibration!',...
            1,{num2str(RawCalibPicNum)});
        RawCalibPicNum = str2double(RawCalibPicNum{1});
        rdd;
    else %first time calib
        filttype = {'allpass','allpass'};
        RawCalibPicNum = NaN;
    end
    
    invfilterdata = set_invFilter(filttype, RawCalibPicNum, true);
    coefFileNum = invfilterdata.coefFileNum;
else
    newCalib= true;
end

%%
if Stimuli.ear == 1 %left ear
    %%
    %     COMM.handle.RP2_1 = actxcontrol('RPco.x',[0 0 5 5]);
    %     status1 = invoke(COMM.handle.RP2_1, 'ConnectRP2', NelData.General.TDTcommMode, 1);
    [COMM.handle.RP2_1, status1]=connect_tdt('RP2', 1);
    invoke(COMM.handle.RP2_1,'LoadCof',[object_dir '\make_tone_left.rcx']);
    invoke(COMM.handle.RP2_1,'SetTagVal','Select',160);
    invoke(COMM.handle.RP2_1,'Run');
    
    %     COMM.handle.RP2_2 = actxcontrol('RPco.x',[0 0 5 5]);
    %     status2 = invoke(COMM.handle.RP2_2, 'ConnectRP2', NelData.General.TDTcommMode, 2);
    [COMM.handle.RP2_2, status2 ]=connect_tdt('RP2', 2);
    invoke(COMM.handle.RP2_2,'LoadCof',[object_dir '\make_tone_right_PU.rcx']);
    invoke(COMM.handle.RP2_2,'SetTagVal','Select', 56);
    invoke(COMM.handle.RP2_2,'Run');
else
    
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
