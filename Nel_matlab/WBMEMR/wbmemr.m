global root_dir NelData data_dir

% NEL Version of RunMEMR_chin_edited_NEL1.m based off Hari's SNAPLab script

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
host=lower(getenv('hostname'));
host = host(~isspace(host));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

filename = current_data_file('wbmemr',1);
Channel = 1; %??? AS

%Insert NEL/GUI Parameters here...none for WBMEMR

NelData.MEMR.rc = 'start';
%% Calibration

%default WBMEMR calib...needs improvement

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

%TODO: Make this a conditional to handle NEL1 vs NEL2
[f1RP,RP,~]=load_play_circuit_Nel1(FS_tag,fig_num,GB_ch);
disp('circuit loaded');

subj = input('Please subject ID:', 's');

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

% Make directory to save results (NOT NEEDED HERE)

% paraDir = 'C:\NEL\Nel_matlab\WBMEMR';
% % whichScreen = 1;
% addpath(genpath(paraDir));
% if(~exist(strcat(paraDir,'\',subj),'dir'))
%     mkdir(strcat(paraDir,'\',subj));
% end
% respDir = strcat(paraDir,'\',subj,'\');

%% DO FULL BAND FIRST
stim = makeMEMRstim_500to8500Hz;
stim.subj = subj;
stim.ear = ear;

pause(3);

%Set the delay of the sound
invoke(RP, 'SetTagVal', 'onsetdel',0); % onset delay is in ms
playrecTrigger = 1;

%set attn and play
% button = input('Do you want the subject to press a button to proceed? (Y or N):', 's');
disp('Starting stimulation...');

resplength = numel(stim.t);
stim.resp = zeros(stim.nLevels, stim.Averages, stim.nreps, resplength);

% *1) re-order stim presentation
% *2) way to exit data collection (Fig: KeyPressfnc)
% *3) plot at end of each 3rd rep (after throw away)
continueDATA=1;
h=figure('KeyPressFcn','continueDATA=0');
disp('Press any key in FIG to STOP data collection')
AR = 0; %0=No Artifact rejection, 1=Do Artifact rejection

for nTRIALS = 1: (stim.Averages + stim.ThrowAway) 
    for L = 1:stim.nLevels
        
        % Set attenuation on PA5 using Nel 2.0's PAset
        rc = PAset([0, 0, stim.clickatt, stim.noiseatt(L)]);
        %     invoke(RP, 'SetTagVal', 'attA', stim.clickatt);
        %     invoke(RP, 'SetTagVal', 'attB', stim.noiseatt(L));
        invoke(RP, 'SetTagVal', 'nsamps', resplength);
        
        buffdataL = stim.click;
        buffdataR = squeeze(stim.noise(L, nTRIALS, :))';
        % Check for clipping and load to buffer
        if(any(abs(buffdataL(:)) > 1) || any(abs(buffdataR(:)) > 1))
            error('What did you do!? Sound is clipping!! Cannot Continue!!\n');
        end
        %Load the 2ch variable data into the RZ6:
        %invoke(RP, 'WriteTagVEX', 'datain', 0, 'I16', (buffdata*2^15));
        invoke(RP, 'WriteTagVEX', 'datainL', 0, 'F32', buffdataL);
        invoke(RP, 'WriteTagVEX', 'datainR', 0, 'F32', buffdataR);
        pause(1.5);
        for k = 1:stim.nreps
            %Start playing from the buffer:
            invoke(RP, 'SoftTrg', playrecTrigger);
            currindex = invoke(RP, 'GetTagVal', 'indexin');
            while(currindex < resplength)
                currindex=invoke(RP, 'GetTagVal', 'indexin');
            end
            
            vin = invoke(RP, 'ReadTagVex', 'dataout', 0, resplength,...
                'F32','F64',1);
            %Accumluate the time waveform - no artifact rejection
            if (nTRIALS > stim.ThrowAway)
                stim.resp(L, nTRIALS-stim.ThrowAway, k, :) = vin;
            end
            
            % Get ready for next trial
            invoke(RP, 'SoftTrg', 8); % Reset OAE buffer
            
            fprintf(1, 'Done with Level #%d, Trial # %d \n', L, nTRIALS);
        end
        
        if ~continueDATA
            break
        end
        
    end  % levels
    pause(2);
    if ~continueDATA
        break
    end
    
    if nTRIALS>stim.ThrowAway
        if ~rem((nTRIALS-stim.ThrowAway),3)
            stimTEMP=stim;
            stimTEMP.resp=stim.resp(:,1:(nTRIALS-stim.ThrowAway),:,:);
            stimTEMP.Averages=nTRIALS-stim.ThrowAway;
            [~] = analyzeMEM_Fn(stimTEMP,AR); %Calls function, builds two plots
            clear stimTEMP
        end
    end
    
end

stim.mat2Pa = 1 / (DR_onesided * mic_gain * mic_sens * P_ref);

%% Set up data structure to save
stim.date = datestr(clock);


%artifact rejection
answer = questdlg('Would you like to perform artifact rejection?'...
    ,'Artifact Rejection?','Yes','No','Dont know');
%Handle response
switch answer
    case {'Yes'}
        figure;
        AR = 1;
        %Call function
        %instead of saving as a separate file, it just saves stim_AR in a
        %pic file
        [stim_AR] = analyzeMEM_Fn(stim,AR);
        disp('Saving Artifact Rejected data ...')
    case {'No'}
        %Completed, do nothing
end
warning('off');
%% Right place to do this?

if (isempty(get(h_push_stop,'UserData')))  %% Went through all freqs, i.e., finished on its own
    set(h_push_stop,'Userdata','stop');
end
NelData.WBMEMR.rc=get(h_push_stop,'Userdata');
%% Shut down TDT
close_play_circuit(f1RP, RP);
for atten_num = 1:4
    %     invoke(PAco1,'ConnectPA5',NelData.General.TDTcommMode,atten_num);
    PAco1= connect_tdt('PA5', atten_num);
    invoke(PAco1,'SetAtten',120.0);
end

%% Communicate closing with GUI and Nel_App
%communicate with GUI
set(h_push_stop,'Enable','off');
set(h_push_restart,'Enable','off');
set(h_push_abort,'Enable','off');
set(h_push_saveNquit,'Enable','off');

%% Big Switch case to handle end of data collection

switch NelData.WBMEMR.rc
    case 'abort'
        wideband_memr('close');
        return;
    case 'restart'
        return;
    case 'stop'
        last_stim=nTRIALS;
        
        if last_stim == stim.Averages + stim.ThrowAway
            %run save...all frequencies are run, ended naturally
            [filename, shortfname] = current_data_file('memr',1);
            make_memr_text_file;
            text_str = sprintf('%s %s','Saved data file: ',shortfname);
            set(h_text7,'String',text_str,'FontSize',10);
%             update_dpoae_params;
            filename = current_data_file('memr',1);
            %set(h_push_close,'Enable','off');
            set(h_push_saveNquit,'Enable','off'); 
        else
            set(h_push_saveNquit,'Enable','on');
        end
        
        set(h_push_restart,'Enable','on');
        set(h_push_abort,'Enable','on');
        set(h_push_params,'Enable','on');

        while isempty(get(h_push_stop,'Userdata')) % Wait for user to do something else
            pause(.1)
        end
        
        set(h_ax1,'ButtonDownFcn','')
        set(h_line1,'ButtonDownFcn','')
        NelData.WBMEMR.rc=get(h_push_stop,'Userdata');
        set(h_push_stop,'Userdata',[]);
        
        % remind user to turn of microphone
        h = msgbox('Please remember to turn off the microphone');
        uiwait(h);
        
        switch NelData.WBMEMR.rc
            case 'abort'
                distortion_product('close');
                return;
            case 'restart'
                return;
%             case 'params'
%                 h_dpoae_params = view_dpoae_params;
%                 uiwait(h_dpoae_params);
%                 distortion_product('start');
%                 return;
            case 'saveNquit'
                set(h_push_restart,'Enable','off');
                set(h_push_abort,'Enable','on');
                set(h_push_saveNquit,'Enable','off');
                set(h_push_params,'Enable','off');
                
                dlg_pos=[40.9600   1.5  122.8800   15.5000];
                
                % add in comment ability later...
                % comment=NelData.File_Manager.unit.comment;
                comment='NOTHING FOR NOW';
                
                [filename, shortfname] = current_data_file('memr',1);
                make_memr_text_file;
                text_str = sprintf('%s %s','Saved data file: ',shortfname);
                set(h_text7,'String',text_str,'FontSize',10);
%                 update_dpoae_params;
                filename = current_data_file('memr',1);
                %set(h_push_close,'Enable','on');
                %uiresume;
                wideband_memr('close');
                return;
        end
end


