function [error] = make_tone()

global object_dir COMM FIG Stimuli newCalib coefFileNum NelData

error = 0;

%%
if (NelData.General.RP2_3and4 || NelData.General.RX8)
    cdd;
    allCalibsRAW= dir('p*calib*raw*');
    all_calibRAW_picNums= cell2mat(cellfun(@(x) getPicNum(x), {allCalibsRAW.name}', 'UniformOutput', false));
    
    all_Calib_files= dir('p*calib*');
    if isempty(all_Calib_files)
        newCalib= true;
    else
        inStr= questdlg('Calib files already exists - run new calib or use latest FIR coeffs?', 'New or Rerun?', 'New Calib', 'FIR Calib', 'FIR Calib');
        if strcmp(inStr, 'New Calib')
            newCalib= true;
        elseif strcmp(inStr, 'FIR Calib')
            newCalib= false;
        end
    end
    rdd;
    CalibPicNum=all_calibRAW_picNums(end);
    if ~newCalib; % if not new (means old => coef-file exists), then run inverse calibration
        
        filttype = {'inversefilt','inversefilt'};
        invfiltdata = set_invFilter(filttype, CalibPicNum);  % need raw calib #
    else
        filttype = {'allpass','allpass'};
        invfiltdata = set_invFilter(filttype,NaN,1);  % need raw calib #
    end
    
    %% OLD
    %     doInvCalib= ~newCalib; % if not new (means old => coef-file exists), then run inverse calibration
    %     coefFileNum= run_invCalib(doInvCalib);
else
    newCalib= true;
end

%%
if Stimuli.ear == 1 %left ear
    %%
    %     COMM.handle.RP2_1 = actxcontrol('RPco.x',[0 0 5 5]);
    %     status1 = invoke(COMM.handle.RP2_1, 'ConnectRP2', NelData.General.TDTcommMode, 1);
    [COMM.handle.RP2_1, status1]=connect_tdt('RP2', 1);
    invoke(COMM.handle.RP2_1,'LoadCof',[object_dir '\make_tone_left.rco']);
    invoke(COMM.handle.RP2_1,'SetTagVal','Select',160);
    invoke(COMM.handle.RP2_1,'Run');
    
    %     COMM.handle.RP2_2 = actxcontrol('RPco.x',[0 0 5 5]);
    %     status2 = invoke(COMM.handle.RP2_2, 'ConnectRP2', NelData.General.TDTcommMode, 2);
    [COMM.handle.RP2_2, status2 ]=connect_tdt('RP2', 2);
    invoke(COMM.handle.RP2_2,'LoadCof',[object_dir '\make_tone_right_PU.rco']);
    invoke(COMM.handle.RP2_2,'SetTagVal','Select', 56);
    invoke(COMM.handle.RP2_2,'Run');
else
    
    %     COMM.handle.RP2_1 = actxcontrol('RPco.x',[0 0 5 5]);
    %     status1 = invoke(COMM.handle.RP2_1, 'ConnectRP2', NelData.General.TDTcommMode, 1);
    [COMM.handle.RP2_1, status1]=connect_tdt('RP2', 1);
    invoke(COMM.handle.RP2_1,'LoadCof',[object_dir '\make_tone_left.rco']);
    invoke(COMM.handle.RP2_1,'SetTagVal','Select',56);
    invoke(COMM.handle.RP2_1,'Run');
    
    %     COMM.handle.RP2_2 = actxcontrol('RPco.x',[0 0 5 5]);
    %     status2 = invoke(COMM.handle.RP2_2, 'ConnectRP2', NelData.General.TDTcommMode, 2);
    [COMM.handle.RP2_2, status2]=connect_tdt('RP2', 2);
    invoke(COMM.handle.RP2_2,'LoadCof',[object_dir '\make_tone_right_PU.rco']);
    invoke(COMM.handle.RP2_2,'SetTagVal','Select',64);
    invoke(COMM.handle.RP2_2,'Run');
end
if ~status1 || ~status2
    set(FIG.ax2.ProgMess,'String','TONE: Not communicating with TDT system!');
    error = 1;
end
