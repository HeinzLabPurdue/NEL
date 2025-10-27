global root_dir NelData data_dir PROTOCOL

% NEL Version of RunMEMR_chin_edited_NEL1.m based off Hari's SNAPLab script

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
host=lower(getenv('hostname'));
host = host(~isspace(host));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Insert NEL/GUI Parameters here...none for WBMEMR
PROTOCOL = 'MEMR';
%% Calibration

%default WBMEMR calib...needs improvement  (based on NO invCalib so far -
%FIX later
mic_sens = 0.05; % V / Pa-RMS
mic_gain = db2mag(40);
P_ref = 20e-6; % Pa-RMS
DR_onesided = 1;

%% Meat and Potatoes of the external app you made (here it's RunMEMR_chin_edited_NEL1)

%TDT initialization params

fig_num=99;
GB_ch=2;
FS_tag = 3;
Fs = 48828.125;

%TODO: Make this a conditional to handle NEL1 vs NEL2 ??

[f1RP,RP,~]=load_play_circuit_Nel1(FS_tag,fig_num,GB_ch);
disp('circuit loaded');

if ~isfield(NelData,'WBMEMR') % First time through, need to ask all this.
    subj = input('Please subject ID:', 's');    % NelData.WBMEMR.subj,earflag
    
    earflag = 1;
    while earflag == 1
        ear = input('Please enter which year (L or R):', 's');
        switch ear
            case {'L', 'R', 'l', 'r', 'Left', 'Right', 'left', 'right',...
                    'LEFT', 'RIGHT'}
                earname = strcat(ear, 'Ear');
                earflag = 0;
            otherwise
                fprintf(2, 'Unrecognized ear type! Try again!');
        end
    end
    
    uiwait(warndlg('Set ER-10B+ GAIN to 40 dB','SET ER-10B+ GAIN WARNING','modal'));
    
    % Save in case if restart
    NelData.WBMEMR.subj=subj;
    NelData.WBMEMR.ear=ear;
    NelData.WBMEMR.Fig2close=[];  % set up the place to keep track of figures generted here (to be closed in NEL_App Checkout
    NelData.WBMEMR.MEMR_figNum=177;  % arbitrary for wbMEMR
else
    subj=NelData.WBMEMR.subj;
    ear=NelData.WBMEMR.ear;
    
    disp(sprintf('RESTARTING: \n   Subj: %s;\n   Ear: %s',subj,ear))
    uiwait(warndlg(sprintf('RESTARTING: \n   Subj: %s;\n   Ear: %s',subj,ear),'modal'));
end


%% DO FULL BAND FIRST
% stim = makeMEMRstim_500to8500Hz;
stim = makeMEMRstim_rapidSweep; % new fxn


stim.subj = subj;
stim.ear = ear;
stim.mic_gain = mic_gain;

pause(3);

%Set the delay of the sound
invoke(RP, 'SetTagVal', 'onsetdel',0); % onset delay is in ms
playrecTrigger = 1;

disp('Starting stimulation...');

resplength = stim.resplength; %numel(stim.t);
stim.resp = zeros(stim.nSweeps, resplength);

AR = 0; %0=No Artifact rejection, 1=Do Artifact rejection

%% Inverse Calibration 

%OLD 

%NEEDS TO BE CLEANED UP ASAP.
% 1. run_invCalib needs cleaned up...currently clunky
% 2. Need calibration to be correct for MEMR (currently all pass, w/o calib)
% [~, calibPicNum, ~] = run_invCalib(false);   % skipping INV calib for now since based on 94 dB SPL benig highest value, bot the 105 dB SPL from inv Calib.
% [coefFileNum, ~, ~] = run_invCalib(-2);

% stim.CalibPICnum2use = calibPicNum;  % save this so we know what calib file to use right from data file
% coefFileNum = NaN;

%NEW%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%get user-specified Raw calib
%note to MH from AS, if doing FPL calibration, make sure to consider both L
%and R transducers (CalibData and CalibData2). 

%AS copied from dpoae.m. Might help. Basically search for right and left
%and assign the right calibdata to the right transducer.

% if length(cal.ear_ord)>1
%     %L1 - 'Right' inv calib
%     calib_to_use = contains(cal.ear_ord,'right','IgnoreCase',true);
%     calib_to_use = find(calib_to_use);
%     
%     if calib_to_use == 2
%         CalibData_L1 = cal.CalibData2(:,1:2);
%     else
%         CalibData_L1 = cal.CalibData(:,1:2);
%     end 
%     
%     %L2 - 'Left' inv calib
%     calib_to_use = contains(cal.ear_ord,'left','IgnoreCase',true);
%     calib_to_use = find(calib_to_use);
%     
%     if calib_to_use == 2
%         CalibData_L2 = cal.CalibData2(:,1:2);
%     else
%         CalibData_L2 = cal.CalibData(:,1:2);
%     end 
% else
%     CalibData_L1 = cal.CalibData(:,1:2);
%     CalibData_L2 = CalibData_L1;
% end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

cdd;
%filttype = {'allpass','allpass'};
filttype = {'inversefilt_FPL','inversefilt_FPL'};
all_raw = findPics('raw*');
RawCalibPicNum = max(all_raw);

%prompt user for RAW calib
RawCalibPicNum = inputdlg('Please enter the RAW calibration file to use (default = last raw calib): ', 'Calibration!',...
    1,{num2str(RawCalibPicNum)});
RawCalibPicNum = str2double(RawCalibPicNum{1});
rdd;


%TODO: WHAT CALIBRATION TO USE?????
invfilterdata = set_invFilter(filttype,RawCalibPicNum); %gets appended in make_memr_text_file
calibPicNum = invfilterdata.CalibPICnum2use;
coefFileNum = invfilterdata.coefFileNum;

%% Data Collection Loop

for s = 1:stim.nSweeps
    % --- fixed PA5 attenuation (use your calibrated settings) ---
    rc = PAset([0 0 stim.clickatt stim.noiseatt]);   % these needs to be set correctly AF           % keeps NEL bookkeeping consistent
    invoke(RP, 'SetTagVal', 'nsamps', stim.resplength);

    buffdataL = stim.click;
    buffdataR = stim.noise(s, :);

    % safety: prevent RZ6 clipping
    if any(abs(buffdataL) > 0.99) || any(abs(buffdataR) > 0.99)
        error('Stimulus exceeds ±1 range; reduce amplitude or increase attenuation.');
    end

    % write to RZ6 buffers (identical tags as in existing circuit)
    invoke(RP, 'WriteTagVEX', 'datainL', 0, 'F32', buffdataL);
    invoke(RP, 'WriteTagVEX', 'datainR', 0, 'F32', buffdataR);

    pause(0.25); % short gap for hardware buffering

    % start playback
    invoke(RP, 'SoftTrg', playrecTrigger);

    % wait until sweep completes
    currindex = invoke(RP, 'GetTagVal', 'indexin');
    while currindex < stim.resplength
        currindex = invoke(RP, 'GetTagVal', 'indexin');
    end

    % read response
    vin = invoke(RP, 'ReadTagVex', 'dataout', 0, stim.resplength, 'F32', 'F64', 1);
    stim.resp(s,:) = vin;

    % reset circuit buffer
    invoke(RP, 'SoftTrg', 8);

    fprintf('Completed sweep %d / %d\n', s, stim.nSweeps);
    
    
    ud_status = get(h_push_stop,'Userdata');  % only call this once - ACT on 1st button push
            if strcmp(ud_status,'abort') || strcmp(ud_status,'restart')
                break;
            end
            
            
end

%% Shut off buttons once out of data collection loop 
% until we put STOP functionality in, all roads mean we're done here
set(h_push_stop,'Enable','off');
set(h_push_restart,'Enable','off');
set(h_push_abort,'Enable','off');
set(h_push_saveNquit,'Enable','off');

stim.NUMtrials_Completed = s;  % save how many trials completed

%store last button command, or that it ended all reps
if ~isempty(ud_status)
    NelData.WBMEMR.rc = ud_status;  % button was pushed
    stim.ALLtrials_Completed=0;
else
    NelData.WBMEMR.rc = 'saveNquit';  % ended all REPS - saveNquit
    stim.ALLtrials_Completed=1;
end

%% Shut Down TDT, no matter what button pushed, or if ended naturally
close_play_circuit(f1RP, RP);
rc = PAset(120.0*ones(1,4)); % need to use PAset, since it saves current value in PA, which is assumed way in NEL (causes problems when PAset is used to set attens later)

%set to all pass??? necessary only if inv calibrating
dummy = set_invFilter({'allpass','allpass'},RawCalibPicNum);
%% Return to GUI script, unless need to save
if strcmp(NelData.WBMEMR.rc,'abort') || strcmp(NelData.WBMEMR.rc,'restart')
    return;  % don't need to save
end

%% Set up data structure to save
stim.mat2Pa = 1 / (DR_onesided * mic_gain * mic_sens * P_ref);
stim.date = datestr(clock);

% artifact rejection
answer = questdlg('Would you like to perform artifact rejection?'...
    ,'Artifact Rejection?','Yes','No','Dont know');
%Handle response
switch answer
    case {'Yes'}
%         figure;    %need to close when done
        AR = 1;
        % Call function
        % instead of saving as a separate file, it just saves stim_AR in a
        % pic file
        [stim_AR] = analyzeMEM_Fn(stim,AR);
        disp('Saving Artifact Rejected data ...')
    case {'No'}
        % do nothing
end

warning('off');  % ??

%% Big Switch case to handle end of data collection
switch NelData.WBMEMR.rc
    case 'stop'   % 6/2023MH: MAY ADDD LATER (to stop, reset chin, then restart from where stopped) for NOW - only saveNquit, ohtherwise, abort or restart is already out by here
        % if want to RE-ADD stop, see DPOAE
        
    case 'saveNquit'
            
        %% Option to save comment in data file
        comment='';
        TEMPans = inputdlg('Enter Comment (optional)');
        if ~isempty(TEMPans)
            comment=TEMPans{1};
        end
        stim.comment = comment
        
        %% NEL based data saving script
        make_memr_text_file;     
        
        %% remind user to turn of microphone
        h = msgbox('Please remember to turn off the microphone');
        uiwait(h);
       
end
rdd;

