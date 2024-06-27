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
    
    ear = questdlg('Which Ear?', 'Ear', 'L', 'R', 'R');
    uiwait(warndlg('Set ER-10B+ GAIN to 40 dB','SET ER-10B+ GAIN WARNING','modal'));
    
    % Save in case if restart
    NelData.AdvOAE.ear = ear;
    NelData.AdvOAE.Fig2close=[];  % set up the place to keep track of figures generted here (to be closed in NEL_App Checkout)
    NelData.AdvOAE.AdvOAE_figNum=277;  % +200 from wbMEMR
    
else
    ear = NelData.AdvOAE.ear;
    
    fprintf('RESTARTING')
    uiwait(warndlg(sprintf('RESTARTING'),'modal'));
    
end

%% Initializing SFOAE variables for running and live analysis
sweptSFOAE_ins;
stim.ear = ear;
load('sf_norms', 'upOAE', 'loOAE', 'upNF', 'loNF', 'f');
col = [237, 246, 252]./255;
colNF = [252, 237, 240]./255;

% SH?: Change figure name, give handle?
snr_fig = figure;

% Set live analysis parameters
windowdur = stim.windowdur;
SNRcriterion = stim.SNRcriterion;
maxTrials = stim.maxTrials;
minTrials = stim.minTrials;

phiProbe_inst = stim.phiProbe_inst*2*pi;
t = stim.t;
npoints = stim.npoints;
nearfreqs = stim.nearfreqs;
VtoSPL = stim.VoltageToPascal .* stim.PascalToLinearSPL;

edges = 2 .^ linspace(log2(stim.fmin), log2(stim.fmax), 21);
bandEdges = edges(2:2:end-1);
centerFreqs = edges(3:2:end-2);

if stim.speed < 0
    f_start = stim.fmax;
    f_end = stim.fmin;
else
    f_start = stim.fmin;
    f_end = stim.fmax;
end

testfreq = 2 .^ linspace(log2(f_start), log2(f_end), npoints);

if strcmp(stim.scale, 'log')
    t_freq = log2(testfreq/f_start)/stim.speed + stim.buffdur;
else
    t_freq = (testfreq-f_start)/stim.speed + stim.buffdur;
end

k = 0;
doneWithTrials = 0;
figure;

% Make arrays to store measured mic outputs
ProbeBuffs = zeros(maxTrials, numel(stim.yProbe));
SuppBuffs = zeros(maxTrials, numel(stim.yProbe));
BothBuffs = zeros(maxTrials, numel(stim.yProbe));
flip = -1;
delayComp = 344;
stim.delayComp = delayComp; 

%% Data Collection Loop
disp('Starting stimulation...');

while doneWithTrials == 0
    k = k + 1;
    k_kept = k - stim.ThrowAway;
    
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
        ProbeBuffs(k_kept,  :) = vins;
    end
    
    pause(0.05);
    
    % Do suppressor only
    dropProbe = 120;
    dropSupp = stim.drop_Supp;
    buffdata = zeros(2, numel(stim.ySupp));
    buffdata(2, :) = flip.*stim.ySupp;
    
    vins = PlayCaptureNEL(card, buffdata, dropProbe, dropSupp, delayComp);
    
    % Save data
    if k > stim.ThrowAway
        SuppBuffs(k_kept,  :) = vins;
    end
    
    pause(0.05);
    
    % Do both
    dropProbe = stim.drop_Probe;
    dropSupp = stim.drop_Supp;
    buffdata = zeros(2, numel(stim.yProbe));
    buffdata(1, :) = stim.yProbe;
    buffdata(2, :) = flip.*stim.ySupp;
    
    vins = PlayCaptureNEL(card, buffdata, dropProbe, dropSupp, delayComp);
    
    % Save data
    if k > stim.ThrowAway
        BothBuffs(k_kept,  :) = vins;
    end
    
    pause(0.05);
   
    
    %% Analysis to check SNR
    if k > stim.ThrowAway
        % Set empty matricies for next steps
        coeffs_resp = zeros(npoints, 2);
        coeffs_noise = zeros(npoints, 8);
        
        for p = 1:npoints
            win = find( (t > (t_freq(p) - windowdur/2)) & ...
                (t < (t_freq(p) + windowdur/2)));
            taper = hanning(numel(win))';
            
            a_plus_b_minus_ab = ProbeBuffs(k_kept,:) ...
                + SuppBuffs(k_kept,:) - BothBuffs(k_kept,:);
            resp_trial = a_plus_b_minus_ab(win).* taper; % just curr trial
            
            model_probe = [cos(phiProbe_inst(win)) .* taper;
                -sin(phiProbe_inst(win)) .* taper];
            model_noise = ...
                [cos(nearfreqs(1)*phiProbe_inst(win)) .* taper;
                -sin(nearfreqs(1)*phiProbe_inst(win)) .* taper;
                cos(nearfreqs(2)*phiProbe_inst(win)) .* taper;
                -sin(nearfreqs(2)*phiProbe_inst(win)) .* taper;
                cos(nearfreqs(3)*phiProbe_inst(win)) .* taper;
                -sin(nearfreqs(3)*phiProbe_inst(win)) .* taper;
                cos(nearfreqs(4)*phiProbe_inst(win)) .* taper;
                -sin(nearfreqs(4)*phiProbe_inst(win)) .* taper];
            
            coeffs_resp(p,:) = model_probe' \ resp_trial';
            coeffs_noise(p,:) = model_noise' \ resp_trial';
        end
        
        % calculate amplitudes
        oae_trials(k_kept,:) = abs(complex(coeffs_resp(:, 1),  coeffs_resp(:, 2)));
        median_oae = median(oae_trials,1);
        sfoae_full = db(median_oae.*VtoSPL);
        
        noise_trial = zeros(npoints,4);
        for i = 1:2:8
            noise_trial(:,ceil(i/2)) = complex(coeffs_noise(:,i), coeffs_noise(:,i+1));
        end
        noise_trials(k_kept,:) = abs(mean(noise_trial, 2));
        median_noise = median(noise_trials,1);
        nf_full = db(median_noise.*VtoSPL);
        
        % Get summary points (weighted by SNR)
        sfoae = zeros(length(centerFreqs),1);
        nf = zeros(length(centerFreqs),1);
        sfoae_w = zeros(length(centerFreqs),1);
        nf_w = zeros(length(centerFreqs),1);
        
        % weighted average around 9 center frequencies
        for z = 1:length(centerFreqs)
            band = find( testfreq >= bandEdges(z) & testfreq < bandEdges(z+1));
            
            % TO DO: NF from which SNR was calculated included median of 7 points
            % nearest the target frequency.
            SNR = sfoae_full(band) - nf_full(band);
            weight = (10.^(SNR./10)).^2;
            
            sfoae(z, 1) = mean(sfoae_full(band));
            nf(z,1) = mean(nf_full(band));
            
            sfoae_w(z,1) = sum(weight.*sfoae_full(band))/sum(weight);
            nf_w(z,1) = sum(weight.*nf_full(band))/sum(weight);
            
        end
        
        % median SNR
        SNR_temp = sfoae_w - nf_w;
        
        noisy_trials = 0;
        % artifact check
        if k_kept > 1
            std_oae = std(oae_trials,1);
            for r = 1:k_kept
                for q = 1:npoints
                    if oae_trials(r,q) > median_oae(1,q) + 3*std_oae(1,q)
                        noisy_trials = noisy_trials+1;
                        break;
                    end
                end
            end
        end
        
        % if SNR is good enough and we've hit the minimum number of
        % trials, then stop.
        if SNR_temp(1:8) >= SNRcriterion
            if k_kept >= minTrials + noisy_trials
                doneWithTrials = 1;
            end
        elseif k == maxTrials
            doneWithTrials = 1;
        end
        
        pass = (SNR_temp>=SNRcriterion);
        oae_pass = sfoae_w;
        oae_fail = sfoae_w;
        oae_pass(~pass) = NaN;
        oae_fail(pass) = NaN;
        
        % Plot amplitudes from live analysis
        hold off;

        %plot norms
        fill([f, f(end), f(end:-1:1), f(1)], [loOAE, upOAE(end), upOAE(end:-1:1), loOAE(1)], col, 'linestyle', 'none')
        hold on;
        fill([f, f(end), f(end:-1:1), f(1)], [loNF, upNF(end), upNF(end:-1:1), loNF(1)], colNF, 'linestyle', 'none')
        alpha(.5);

        %plot results
        plot(centerFreqs./1000,oae_pass, 'o', 'linew', 2, 'color', [0 0.4470 0.7410]);
        plot(centerFreqs/1000,oae_fail, 'o', 'linew', 2, 'color', 'k'),
        plot(centerFreqs./1000,nf_w, 'x', 'linew', 2, 'color', [0.6350 0.0780 0.1840]);
        hold off;
        legend('SFOAE', '', 'NOISE', 'location', 'northeast');
        title('SFOAE')
        xlabel('Frequency (Hz)')
        ylabel('Median Amplitude (dB SPL)')
        set(gca, 'XScale', 'log', 'FontSize', 14)
        xlim([0.5, 16]);
        xticks([.5, 1, 2, 4, 8, 16]);
        ylim([-45, 45]);
        yticks((-45:15:45))
        grid on;
        drawnow;
        
        fprintf(1, 'Trials run: %d / Noisy Trials: %d \n', k_kept, noisy_trials);
    end
    
    % Check for button push to abort/restart/saveNquit
    ud_status = get(h_push_stop,'Userdata');  % only call this once - ACT on 1st button push
    if ~isempty(ud_status)
        break
    end
    
end % End of Trials

% Only save what was filled - initialized matixes are size maxTrials x resplength
stim.ProbeBuffs = ProbeBuffs(1:k_kept,:);
stim.SuppBuffs = SuppBuffs(1:k_kept,:);
stim.BothBuffs = BothBuffs(1:k_kept,:);


%% Shut off buttons once out of data collection loop
% until we put STOP functionality in, all roads mean we're done here
set(h_push_stop,'Enable','off');
set(h_push_restart,'Enable','off');
set(h_push_abort,'Enable','off');
set(h_push_saveNquit,'Enable','off');

stim.NUMtrials_Completed = k_kept;  % save how many trials completed

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
filttype = {'allpass','allpass'};
dummy = set_invFilter(filttype,Stimuli.calibPicNum);

%% Return to GUI script, unless need to save
if strcmp(NelData.AdvOAE.rc,'abort') || strcmp(NelData.AdvOAE.rc,'restart')
    return;  % don't need to save
end

%% Set up data structure to save
stim.date = datestr(clock);

% answer = questdlg('Would you like to analyze this data?'...
%     ,'Analyze?','Yes','No', 'No');
% %Handle response
% switch answer
%     case {'Yes'}
%         % Call function
%         % instead of saving as a separate file, it just saves stim_AR in a
%         [res_SFOAE] = sweptSFOAE_analysis(stim);
%         disp('Saving Analyzed data ...')
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
        make_sfoae_text_file;
        
        %% remind user to turn of microphone
        h = msgbox('Please remember to turn off the microphone');
        uiwait(h);
        
end


