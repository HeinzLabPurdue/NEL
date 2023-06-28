global root_dir NelData data_dir

% NEL Version of RunMEMR_chin_edited_NEL1.m based off Hari's SNAPLab script

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
host=lower(getenv('hostname'));
host = host(~isspace(host));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Insert NEL/GUI Parameters here...none for WBMEMR

%% Initialize TDT
card = initialize_card; 

%% Inverse Calibration
%NEEDS TO BE CLEANED UP ASAP.
% 1. run_invCalib needs cleaned up...currently clunky
% 2. Need calibration to be correct for MEMR (currently all pass, w/o calib)
[~, calibPicNum, ~] = run_invCalib(false);   % skipping INV calib for now since based on 94 dB SPL benig highest value, bot the 105 dB SPL from inv Calib.
[coefFileNum, ~, ~] = run_invCalib(-2);

stim.CalibPICnum2use = calibPicNum;  % save this so we know what calib file to use right from data file
coefFileNum = NaN;


%% Enter subject information
if ~isfield(NelData,'AdvOAE') % First time through, need to ask all this.
    subj = input('Please subject ID:', 's');    % NelData.sweptSFOAE.subj,earflag
    
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
    NelData.AdvOAE.subj=subj;
    NelData.AdvOAE.ear=ear;
    NelData.AdvOAE.Fig2close=[];  % set up the place to keep track of figures generted here (to be closed in NEL_App Checkout)
    NelData.AdvOAE.AdvOAE_figNum=277;  % +100 from wbMEMR
    
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
sweptDPOAE_ins;
disp('Starting stimulation...');

%% Running Script

 % Set stims in buffdata:
    buffdata = [stim.y1; stim.y2];
    % Check for clipping and load to buffer
    if(any(abs(buffdata(:)) > 1))
        error('What did you do!? Sound is clipping!! Cannot Continue!!\n');
    end
    
     %% Set attenuation and play
    drop_f1 = stim.drop_f1;
    drop_f2 = stim.drop_f2;
    delayComp = 1; % Always
    
    windowdur = 0.5;
    SNRcriterion = stim.SNRcriterion;
    maxTrials = stim.maxTrials;
    minTrials = stim.minTrials;
    doneWithTrials = 0;
    figure;
    
    %% Add useful info to structure
    mic_sens = 50e-3; % mV/Pa
    mic_gain = db2mag(40); % +6 for balanced cable
    P_ref = 20e-6;
    DR_onesided = 1;
    stim.VoltageToPascal = 1 / (DR_onesided * mic_gain * mic_sens);
    stim.PascalToLinearSPL = 1 /  P_ref;
    
    resp = zeros(maxTrials, size(buffdata,2));
    
    %% Loop for presenting stimuli
    % variable for live analysis
    k = 0;
    t = stim.t;
    testfreq = [.75, 1, 1.5, 2, 3, 4, 6, 8, 12].* 1000;
    
    if stim.speed < 0
        f1 = stim.fmax;
        f2 = stim.fmin;
    else
        f1 = stim.fmin;
        f2 = stim.fmax;
    end
    
    if stim.speed < 20
        t_freq = log2(testfreq/f1)/stim.speed + stim.buffdur;
    else
        t_freq = (testfreq-f1)/stim.speed + stim.buffdur;
    end
    
    
    while doneWithTrials == 0
        k = k + 1;
        
        %Start playing from the buffer:
        vins = PlayCaptureNEL(card, buffdata, drop_f1, drop_f2, delayComp);
        
        if k > stim.ThrowAway
            resp(k - stim.ThrowAway,  :) = vins;
        end
        
        WaitSecs(0.25);
        
        fprintf(1, 'Done with # %d trials \n', k);
        
        % test OAE
        
        OAEtrials = resp(1:k-stim.ThrowAway, :);
        OAE = median(OAEtrials,1);
        coeffs_temp = zeros(length(testfreq), 2);
        coeffs_noise = zeros(length(testfreq), 8);
        for m = 1:length(testfreq)
            win = find( (t > (t_freq(m)-windowdur/2)) & ...
                (t < (t_freq(m)+windowdur/2)));
            taper = hanning(numel(win))';
            
            oae_win = OAE(win) .* taper;
            
            phiProbe_inst = (2.*stim.phi1_inst - stim.phi2_inst) * 2 * pi;
            
            model_dp = [cos(phiProbe_inst(win)) .* taper;
                -sin(phiProbe_inst(win)) .* taper];
            if stim.speed > 0
                nearfreqs = [1.10, 1.12, 1.14, 1.16];
            else
                nearfreqs = [.90, .88, .86, .84];
            end
            
            model_noise = ...
                [cos(nearfreqs*phiProbe_inst(win)) .* taper;
                -sin(nearfreqs*phiProbe_inst(win)) .* taper;
                cos(nearfreqs*phiProbe_inst(win)) .* taper;
                -sin(nearfreqs*phiProbe_inst(win)) .* taper;
                cos(nearfreqs*phiProbe_inst(win)) .* taper;
                -sin(nearfreqs*phiProbe_inst(win)) .* taper;
                cos(nearfreqs*phiProbe_inst(win)) .* taper;
                -sin(nearfreqs*phiProbe_inst(win)) .* taper];
            
            coeffs_temp(m,:) = model_dp' \ oae_win';
            coeffs_noise(m,:) = model_noise' \ oae_win';
        end
        
        % for noise
        noise2 = zeros(length(testfreq),4);
        for i = 1:2:8
            noise2(:,ceil(i/2)) = abs(complex(coeffs_noise(:,i), coeffs_noise(:,i+1)));
        end
        noise = mean(noise2, 2);
        
        oae = abs(complex(coeffs_temp(:,1), coeffs_temp(:,2)));
        
        SNR_temp = db(oae) - db(noise);
        
        mult = stim.VoltageToPascal .* stim.PascalToLinearSPL;
        hold off;
        plot(testfreq./1000,db(oae.*mult), 'o', 'linew', 2);
        hold on;
        plot(testfreq./1000,db(noise.*mult), 'x', 'linew', 2);
        legend('DPOAE', 'NOISE');
        xlabel('Frequency (Hz)')
        ylabel('Median Amplitude dB')
        set(gca, 'XScale', 'log', 'FontSize', 14)
        xticks([.5, 1, 2, 4, 8, 16])
        xlim([0.5, 16])
        drawnow; 
        
        % if SNR is good enough and we've hit the minimum number of
        % trials, then stop.
        if SNR_temp(1:8) > SNRcriterion
            if k - stim.ThrowAway >= minTrials
                doneWithTrials = 1;
            end
        elseif k == maxTrials
            doneWithTrials = 1;
        end
        
          % Check for button push
    % either ABORT or RESTART needs to break loop immediately,
    % saveNquit will complete current LEVEL sweep
    % SH?: May want to do this after every sweep
    ud_status = get(h_push_stop,'Userdata');  % only call this once - ACT on 1st button push
    if strcmp(ud_status,'abort') || strcmp(ud_status,'restart')
        break;
    end
    
        
    end
    
    stim.resp = resp(1:k-stim.ThrowAway,:);
    
    

%% Shut off buttons once out of data collection loop
% until we put STOP functionality in, all roads mean we're done here
set(h_push_stop,'Enable','off');
set(h_push_restart,'Enable','off');
set(h_push_abort,'Enable','off');
set(h_push_saveNquit,'Enable','off');

stim.NUMtrials_Completed = k;  % save how many trials completed

%store last button command, or that it ended all reps
if ~isempty(ud_status)
    NelData.AdvOAE.rc = ud_status;  % button was pushed
    stim.ALLtrials_Completed=0;
else
    NelData.AdvOAE.rc = 'saveNquit';  % ended all REPS - saveNquit
    stim.ALLtrials_Completed=1;
end

%% Shut Down TDT, no matter what button pushed, or if ended naturally
close_play_circuit(f1RP, RP);
rc = PAset(120.0*ones(1,4)); % need to use PAset, since it saves current value in PA, which is assumed way in NEL (causes problems when PAset is used to set attens later)
run_invCalib(false);

%% Return to GUI script, unless need to save
if strcmp(NelData.AdvOAE.rc,'abort') || strcmp(NelData.AdvOAE.rc,'restart')
    return;  % don't need to save
end

%% Set up data structure to save
stim.date = datestr(clock);

% SH? May want to add my analysis code here.
% answer = questdlg('Would you like to perform artifact rejection?'...
%     ,'Artifact Rejection?','Yes','No','Dont know');
% %Handle response
% switch answer
%     case {'Yes'}
%         %         figure;    %need to close when done
%         AR = 1;
%         % Call function
%         % instead of saving as a separate file, it just saves stim_AR in a
%         % pic file
%         [stim_AR] = analyzeMEM_Fn(stim,AR);
%         disp('Saving Artifact Rejected data ...')
%     case {'No'}
%         % do nothing
% end

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
        stim.comment = comment; 
        
        %% NEL based data saving script
        make_sweptdpoae_text_file;
        
        %% remind user to turn of microphone
        h = msgbox('Please remember to turn off the microphone');
        uiwait(h);
        
end


