global root_dir NelData data_dir PROTOCOL

% NEL Version of RunMEMR_chin_edited_NEL1.m based off Hari's SNAPLab script

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
host=lower(getenv('hostname'));
host = host(~isspace(host));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Insert NEL/GUI Parameters here...none for WBMEMR
PROTOCOL = 'OAE'; 
%% Initialize TDT
card = initialize_card;

%% Inverse Calibration
cdd;
allCalibFiles= dir('*calib*raw*');
Stimuli.calibPicNum= getPicNum(allCalibFiles(end).name);
Stimuli.calibPicNum= str2double(inputdlg('Enter RAW Calibration File Number (default = last raw calib)','Load Calib File', 1,{num2str(Stimuli.calibPicNum)}));
rdd;
filttype = {'inversefilt_FPL','inversefilt_FPL'};
invfiltdata = set_invFilter(filttype,Stimuli.calibPicNum);

%% Enter subject information
if ~isfield(NelData,'AdvOAE') % First time through, need to ask all this.
    subj = input('Please subject ID:', 's');    % NelData.sweptSFOAE.subj,earflag
    stim.subj = subj; 
    
    earflag = 1;
    while earflag == 1
        ear = input('Please enter which year (L or R):', 's');
        switch ear
            case {'L', 'R', 'l', 'r', 'Left', 'Right', 'left', 'right',...
                    'LEFT', 'RIGHT'}
                earname = strcat(ear, 'Ear');
                earflag = 0;
                stim.ear = ear; 
            otherwise
                fprintf(2, 'Unrecognized ear type! Try again!');
        end
    end
    
    uiwait(warndlg('Set ER-10B+ GAIN to 40 dB','SET ER-10B+ GAIN WARNING','modal'));
    
    % Save in case if restart
    NelData.AdvOAE.subj=subj;
    NelData.AdvOAE.ear=ear;
    NelData.AdvOAE.Fig2close=[];  % set up the place to keep track of figures generted here (to be closed in NEL_App Checkout)
    NelData.AdvOAE.AdvOAE_figNum=377;  % +200 from wbMEMR
    
else
    subj=NelData.AdvOAE.subj;
    ear=NelData.AdvOAE.ear;
    
    disp(sprintf('RESTARTING: \n   Subj: %s;\n   Ear: %s',subj,ear))
    uiwait(warndlg(sprintf('RESTARTING: \n   Subj: %s;\n   Ear: %s',subj,ear),'modal'));
end

% %% Start (w/ Delay if needed)
% button = input('Do you want a 10 second delay? (Y or N):', 's');
% switch button
%     case {'Y', 'y', 'yes', 'Yes', 'YES'}
%         DELAY_sec=10;
%         fprintf(1, '\n%.f seconds until START...\n',DELAY_sec);
%         pause(DELAY_sec)
%         fprintf(1, '\nWe waited %.f seconds ...\nStarting Stimulation...\n',DELAY_sec);
%     otherwise
%         fprintf(1, '\nStarting Stimulation...\n');
% end

%% Initializing SFOAE variables for running and live analysis
teoae_ins;

%% Running Script

vo = click.y;
buffdata = zeros(2, numel(vo));
buffdata(click.driver, :) = vo; % The other source plays nothing
click.vo = vo;
odd = 1:2:click.Averages;
even = 2:2:click.Averages;

drops = [120; 120];
drops(click.driver) = click.Attenuation;

% Make arrays to store measured mic outputs
resp = zeros(click.Averages, size(buffdata,2));

disp('Starting stimulation...');
for k = 1:(click.Averages + click.ThrowAway)
    
    vin = PlayCaptureNEL(card, buffdata, drops(1), drops(2), 1);
    
    % Save data
    if k > click.ThrowAway
        resp(k - click.ThrowAway,  :) = vin;
    end
    
    fprintf(1, 'Done with trial %d / %d\n', k,...
        (click.ThrowAway + click.Averages));
    % Check for abort or restart:
    ud_status = get(h_push_stop,'Userdata');  % only call this once - ACT on 1st button push
    if strcmp(ud_status,'abort') || strcmp(ud_status,'restart')
        break; % abort or restart button push breaks loop
    end
    
end

click.resp = resp; % full response -- gets windowed in analysis. 

%% Shut off buttons once out of data collection loop
% until we put STOP functionality in, all roads mean we're done here
set(h_push_stop,'Enable','off');
set(h_push_restart,'Enable','off');
set(h_push_abort,'Enable','off');
set(h_push_saveNquit,'Enable','off');

click.NUMtrials_Completed = k;  % save how many trials completed

%store last button command, or that it ended all reps
if ~isempty(ud_status)
    NelData.AdvOAE.rc = ud_status;  % button was pushed
    click.ALLtrials_Completed=0;
else
    NelData.AdvOAE.rc = 'saveNquit';  % ended all REPS - saveNquit
    click.ALLtrials_Completed=1;
end

%% Shut Down TDT, no matter what button pushed, or if ended naturally
close_play_circuit(card.f1RP, card.RP);
rc = PAset(120.0*ones(1,4)); % need to use PAset, since it saves current value in PA, which is assumed way in NEL (causes problems when PAset is used to set attens later)
filttype = {'allpass','allpass'};
dummy = set_invFilter(filttype,Stimuli.calibPicNum);

%% Return to GUI script, unless need to save
if strcmp(NelData.AdvOAE.rc,'abort') || strcmp(NelData.AdvOAE.rc,'restart')
    return;  % don't need to save
end

%% Set up data structure to save
click.date = datestr(clock);

answer = questdlg('Would you like to analyze this data?'...
    ,'Analysis?','Yes','No','No');
%Handle response
switch answer
    case {'Yes'}
        % figure;    %need to close when done
        % Call function
        % instead of saving as a separate file, it just saves stim_AR in a
        % pic file
        
        [teoae_res] = teoae_analysis(click);
        disp('Saving Analyzed data ...')
    case {'No'}
        % do nothing
end

warning('off');  % ??

%% Big Switch case to handle end of data collection
switch NelData.AdvOAE.rc
    case 'stop'   % 6/2023MH: MAY ADDD LATER (to stop, reset chin, then restart from where stopped) for NOW - only saveNquit, ohtherwise, abort or restart is already out by here
        % if want to RE-ADD stop, see DPOAE
        
    case 'saveNquit'
        
        %% Option to save comment in data file
        comment='';
        TEMPans = inputdlg('Enter Comment (optional)');
        if ~isempty(TEMPans)
            comment=TEMPans{1};
        end
        click.comment = comment;
        
        %% NEL based data saving script
        make_teoae_text_file;
        
        %% remind user to turn of microphone
        h = msgbox('Please remember to turn off the microphone');
        uiwait(h);
        
end


