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
sweptSFOAE_ins;

%% Additional info
mic_sens = 0.05; % V / Pa-RMS
mic_gain = db2mag(40);
P_ref = 20e-6; % Pa-RMS
DR_onesided = 1;
stim.VoltageToPascal = 1 / (DR_onesided * mic_gain * mic_sens);
stim.PascalToLinearSPL = 1 /  P_ref;
delayComp = 1; 

% SH?: Change figure name, give handle?
snr_fig = figure;

% Make arrays to store measured mic outputs
ProbeBuffs = zeros(stim.maxTrials, numel(stim.yProbe));
SuppBuffs = zeros(stim.maxTrials, numel(stim.yProbe));
BothBuffs = zeros(stim.maxTrials, numel(stim.yProbe));
flip = -1;

% variable for live analysis
k = 0;
doneWithTrials = 0;
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

%% Data Collection Loop
disp('Starting stimulation...');

while doneWithTrials == 0
    k = k + 1;
    % alternate phase of the suppressor
    flip = flip .* -1;
    
    % Do probe only
    dropSupp = 120;
    dropProbe = stim.drop_Probe;
    buffdata = zeros(2, numel(stim.yProbe));
    buffdata(1, :) = stim.yProbe;
    
    vins = PlayCaptureNEL(card, buffdata, dropProbe, dropSupp, delayComp);
    
    % Save data
    if k > stim.ThrowAway
        ProbeBuffs(k - stim.ThrowAway,  :) = vins;
    end
    
    pause(0.15);
    
    % Do suppressor only
    dropProbe = 120;
    dropSupp = stim.drop_Supp;
    buffdata = zeros(2, numel(stim.ySupp));
    buffdata(2, :) = flip.*stim.ySupp;
    
    vins = PlayCaptureNEL(card, buffdata, dropProbe, dropSupp, delayComp);
    
    % Save data
    if k > stim.ThrowAway
        SuppBuffs(k - stim.ThrowAway,  :) = vins;
    end
    
    pause(0.15);
    
    % Do both
    dropProbe = stim.drop_Probe;
    dropSupp = stim.drop_Supp;
    buffdata = zeros(2, numel(stim.yProbe));
    buffdata(1, :) = stim.yProbe;
    buffdata(2, :) = flip.*stim.ySupp;
    
    vins = PlayCaptureNEL(card, buffdata, dropProbe, dropSupp, delayComp);
    
    % Save data
    if k > stim.ThrowAway
        BothBuffs(k - stim.ThrowAway,  :) = vins;
    end
    
    pause(0.15);
    
    fprintf(1, 'Done with trial %d \n', k);
    
    %% Analysis to check SNR
    % test OAE
    windowdur = 0.5;
    if k - stim.ThrowAway >= stim.minTrials
        SFOAEtrials = ProbeBuffs(1:(k - stim.ThrowAway), :) + SuppBuffs(1:(k - stim.ThrowAway), :) - BothBuffs(1:(k - stim.ThrowAway), :);
        SFOAE = median(SFOAEtrials,1);
        coeffs_temp = zeros(length(testfreq), 2);
        coeffs_noise = zeros(length(testfreq), 8);
        for m = 1:length(testfreq)
            win = find( (t > (t_freq(m)-windowdur/2)) & ...
                (t < (t_freq(m)+windowdur/2)));
            taper = hanning(numel(win))';
            
            resp = SFOAE(win) .* taper;
            
            phiProbe_inst = stim.phiProbe_inst;
            model_sf = [cos(2*pi*phiProbe_inst(win)) .* taper;
                -sin(2*pi*phiProbe_inst(win)) .* taper];
            
            if stim.speed < 0
                nearfreqs = [1.10, 1.12, 1.14, 1.16];
            else
                nearfreqs = [.90, .88, .86, .84];
            end
            
            model_noise = [cos(2*pi*nearfreqs(1)*phiProbe_inst(win)) .* taper;
                -sin(2*pi*nearfreqs(1)*phiProbe_inst(win)) .* taper;
                cos(2*pi*nearfreqs(2)*phiProbe_inst(win)) .* taper;
                -sin(2*pi*nearfreqs(2)*phiProbe_inst(win)) .* taper;
                cos(2*pi*nearfreqs(3)*phiProbe_inst(win)) .* taper;
                -sin(2*pi*nearfreqs(3)*phiProbe_inst(win)) .* taper;
                cos(2*pi*nearfreqs(4)*phiProbe_inst(win)) .* taper;
                -sin(2*pi*nearfreqs(4)*phiProbe_inst(win)) .* taper];
            
            coeffs_temp(m,:) = model_sf' \ resp';
            coeffs_noise(m,:) = model_noise' \ resp';
        end
        
        % for noise
        noise2 = zeros(length(testfreq),4);
        for i = 1:2:8
            noise2(:,ceil(i/2)) = abs(complex(coeffs_noise(:,i), coeffs_noise(:,i+1)));
        end
        noise = mean(noise2, 2);
        
        oae = abs(complex(coeffs_temp(:,1), coeffs_temp(:,2)));
        
        SNR_temp = db(oae) - db(noise);
        
        figure(snr_fig);
        hold off;
        plot(testfreq./1000,db(oae.*10000), 'o', 'linew', 2);
        hold on;
        plot(testfreq./1000,db(noise.*10000), 'x', 'linew', 2);
        legend('SFOAE', 'NOISE');
        xlabel('Frequency (Hz)')
        ylabel('Median Amplitude dB')
        set(gca, 'XScale', 'log', 'FontSize', 14)
        xticks([.5, 1, 2, 4, 8, 16])
        xlim([0.5, 16])
        
        
        if SNR_temp(1:8) > stim.SNRcriterion
            doneWithTrials = 1;
        elseif k-stim.ThrowAway == stim.maxTrials
            doneWithTrials = 1;
        end
        
    end
    
    % Check for button push to abort/restart/saveNquit
    ud_status = get(h_push_stop,'Userdata');  % only call this once - ACT on 1st button push
    if ~isempty(ud_status)
        break;
    end
    
end % End of Trials

% Only save what was filled - initialized matixes are size maxTrials x resplength
stim.ProbeBuffs = ProbeBuffs(1:k - stim.ThrowAway,:);
stim.SuppBuffs = SuppBuffs(1:k - stim.ThrowAway,:);
stim.BothBuffs = BothBuffs(1:k - stim.ThrowAway,:);


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
close_play_circuit(card.f1RP, card.RP);
rc = PAset(120.0*ones(1,4)); % need to use PAset, since it saves current value in PA, which is assumed way in NEL (causes problems when PAset is used to set attens later)
run_invCalib(false);

%% Return to GUI script, unless need to save
if strcmp(NelData.AdvOAE.rc,'abort') || strcmp(NelData.AdvOAE.rc,'restart')
    return;  % don't need to save
end

%% Set up data structure to save
stim.date = datestr(clock);

answer = questdlg('Would you like to analyze this data?'...
    ,'Analyze?','Yes','No', 'No');
%Handle response
switch answer
    case {'Yes'}
        % Call function
        % instead of saving as a separate file, it just saves stim_AR in a
        [res_SFOAE] = sweptSFOAE_analysis(stim);
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
        stim.comment = comment;
        
        %% NEL based data saving script
        make_sfoae_text_file;
        
        %% remind user to turn of microphone
        h = msgbox('Please remember to turn off the microphone');
        uiwait(h);
        
end


