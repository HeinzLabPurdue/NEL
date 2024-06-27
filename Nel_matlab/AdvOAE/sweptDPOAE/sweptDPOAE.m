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
    NelData.AdvOAE.AdvOAE_figNum=377;  % +200 from wbMEMR

else
    ear = NelData.AdvOAE.ear;

    fprintf('RESTARTING')
    uiwait(warndlg(sprintf('RESTARTING'),'modal'));

end

%% Initializing SFOAE variables for running and live analysis
sweptDPOAE_ins;
stim.ear = ear;
load('dp_norms', 'upOAE', 'loOAE', 'upNF', 'loNF', 'f');
col = [237, 246, 252]./255;
colNF = [252, 237, 240]./255;
% this is some initial values, but can be re-decided later
% values we need are f, loNF, loOAE, upNF, upOAE
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
delayComp = 344; % Always

% Live analysis parameters
windowdur = stim.windowdur;
SNRcriterion = stim.SNRcriterion;
maxTrials = stim.maxTrials;
minTrials = stim.minTrials;

phi_dp_inst = (2.*stim.phi1_inst - stim.phi2_inst) * 2 * pi; %dp

%% Loop for presenting stimuli
% variable for live analysis
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

% set matrix for storing response
resp = zeros(maxTrials, size(buffdata,2));
disp('Starting stimulation...');

while doneWithTrials == 0
    k = k + 1;
    k_kept = k - stim.ThrowAway;

    %Start playing from the buffer:
    vins = PlayCaptureNEL(card, buffdata, drop_f1, drop_f2, delayComp);

    % save the response
    if k > stim.ThrowAway
        resp(k - stim.ThrowAway,  :) = vins;
    end

    if k > stim.ThrowAway
        % Set empty matricies for next steps
        coeffs_resp = zeros(npoints, 2);
        coeffs_noise = zeros(npoints, 8);

        for p = 1:npoints
            win = find( (t > (t_freq(p) - windowdur/2)) & ...
                (t < (t_freq(p) + windowdur/2)));
            taper = hanning(numel(win))';

            resp_trial = vins(win) .* taper; % just current trial

            model_dp = [cos(phi_dp_inst(win)) .* taper;
                -sin(phi_dp_inst(win)) .* taper];
            model_noise = ...
                [cos(nearfreqs(1)*phi_dp_inst(win)) .* taper;
                -sin(nearfreqs(1)*phi_dp_inst(win)) .* taper;
                cos(nearfreqs(2)*phi_dp_inst(win)) .* taper;
                -sin(nearfreqs(2)*phi_dp_inst(win)) .* taper;
                cos(nearfreqs(3)*phi_dp_inst(win)) .* taper;
                -sin(nearfreqs(3)*phi_dp_inst(win)) .* taper;
                cos(nearfreqs(4)*phi_dp_inst(win)) .* taper;
                -sin(nearfreqs(4)*phi_dp_inst(win)) .* taper];

            coeffs_resp(p,:) = model_dp' \ resp_trial';
            coeffs_noise(p,:) = model_noise' \ resp_trial';
        end

        % calculate amplitudes
        oae_trials(k_kept,:) = abs(complex(coeffs_resp(:, 1),  coeffs_resp(:, 2)));
        median_oae = median(oae_trials,1);
        dpoae_full = db(median_oae.*VtoSPL);

        noise_trial = zeros(npoints,4);
        for i = 1:2:8
            noise_trial(:,ceil(i/2)) = complex(coeffs_noise(:,i), coeffs_noise(:,i+1));
        end
        noise_trials(k_kept,:) = abs(mean(noise_trial, 2));
        median_noise = median(noise_trials,1);
        dpnf_full = db(median_noise.*VtoSPL);

        dpoae = zeros(length(centerFreqs),1);
        dpnf = zeros(length(centerFreqs),1);
        dpoae_w = zeros(length(centerFreqs),1);
        dpnf_w = zeros(length(centerFreqs),1);

        % weighted average around 9 center frequencies
        for z = 1:length(centerFreqs)
            band = find( testfreq >= bandEdges(z) & testfreq < bandEdges(z+1));

            % TO DO: NF from which SNR was calculated included median of 7 points
            % nearest the target frequency.
            SNR = dpoae_full(band) - dpnf_full(band);
            weight = (10.^(SNR./10)).^2;

            dpoae(z, 1) = mean(dpoae_full(band));
            dpnf(z,1) = mean(dpnf_full(band));

            dpoae_w(z,1) = sum(weight.*dpoae_full(band))/sum(weight);
            dpnf_w(z,1) = sum(weight.*dpnf_full(band))/sum(weight);

        end

        % median SNR
        SNR_temp = dpoae_w - dpnf_w;

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
        oae_pass = dpoae_w;
        oae_fail = dpoae_w;
        oae_pass(~pass) = NaN;
        oae_fail(pass) = NaN;

        % Plot amplitudes from live analysis
        hold off;

        %plot norms
        fill([f, f(end), f(end:-1:1), f(1)], [loOAE, upOAE(end), upOAE(end:-1:1), loOAE(1)], col, 'linestyle', 'none')
        hold on;
        fill([f, f(end), f(end:-1:1), f(1)], [loNF, upNF(end), upNF(end:-1:1), loNF(1)], colNF, 'linestyle', 'none')
        alpha(.5);

        %plot data
        plot(centerFreqs./1000,oae_pass, 'o', 'linew', 2, 'color', [0 0.4470 0.7410]);
        plot(centerFreqs/1000,oae_fail, 'o', 'linew', 2, 'color', 'k'),
        plot(centerFreqs./1000,dpnf_w, 'x', 'linew', 2, 'color', [0.6350 0.0780 0.1840]);
        hold off;
        legend('DPOAE', '', 'NOISE', 'location', 'northeast');
        title('DPOAE')
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

        % Check for button push
        % either ABORT or RESTART needs to break loop immediately,
        % saveNquit will complete current sweep
        ud_status = get(h_push_stop,'Userdata');  % only call this once - ACT on 1st button push
        if ~isempty(ud_status)
            break;
        end

    end % if k > throwaways
end %done w/ trials

stim.resp = resp(1:k_kept,:);

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

% Option to analyze data
answer = questdlg('Would you like to analyze this data?'...
    ,'Analyze?','Yes','No','No');
%Handle response
switch answer
    case {'Yes'}
        % Call function
        % instead of saving as a separate file, it just saves stim_AR in a
        sweptDPOAE_analysis(stim);
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
        make_sweptdpoae_text_file;

        %% remind user to turn of microphone
        h = msgbox('Please remember to turn off the microphone');
        uiwait(h);

end


