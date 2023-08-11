global  NelData PROTOCOL root_dir data_dir

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
% [~, calibPicNum, ~] = run_invCalib(false);   % skipping INV calib for now since based on 94 dB SPL benig highest value, bot the 105 dB SPL from inv Calib.
% [coefFileNum, ~, ~] = run_invCalib(-2);
% 
calib.CalibPICnum2use = NaN;  % save this so we know what calib file to use right from data file

PROTOCOL = 'FPLprobe'; 
filttype = {'allpass','allpass'};
RawCalibPicNum = NaN;

invfilterdata = set_invFilter(filttype, RawCalibPicNum, true);
coefFileNum = invfilterdata.coefFileNum;

%% Enter subject information
if ~isfield(NelData,'FPL') % First time through, need to ask all this.
    
    uiwait(warndlg('Set ER-10B+ GAIN to 40 dB','SET ER-10B+ GAIN WARNING','modal'));
    gain = 40;
    
    % Save in case if restart
    NelData.FPL.Fig2close=[];  % set up the place to keep track of figures generted here (to be closed in NEL_App Checkout)
    NelData.FPL.FPL_figNum=477;  % +200 from wbMEMR
    
else
    fprintf('RESTARTING...\n')
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
FPLprobe_ins;
disp('Starting stimulation...');

%% Running Script

Fs = calib.SamplingRate * 1000; % to Hz

vo = calib.y;

calib.vo = vo;
vins_1 = zeros(calib.CavNumb, calib.Averages, calib.BufferSize);
vins_2 = zeros(calib.CavNumb, calib.Averages, calib.BufferSize);
calib.vavg_1 = zeros(calib.CavNumb, calib.BufferSize);
calib.vavg_2 = zeros(calib.CavNumb, calib.BufferSize);

for m = 1: calib.CavNumb
    
    fprintf('Playing for cavity %d \n', m)
    % Do driver 1 first:
    driver = 1;
    buffdata = zeros(2, numel(vo));
    buffdata(driver, :) = vo; % The other source plays nothing
    
    drop = [120, 120];
    drop(driver) = calib.Attenuation;
    
    for n = 1:(calib.Averages + calib.ThrowAway)
        vin = PlayCaptureNEL(card, buffdata, drop(1), drop(2), 1);
        
        % Save data
        if (n > calib.ThrowAway)
            vins_1(m,n-calib.ThrowAway,:) = vin;
        end
    end
    
    %compute the average
    
    if calib.doFilt
        % High pass at 100 Hz using IIR filter
        [b, a] = butter(4, 100 * 2 * 1e-3/calib.SamplingRate, 'high');
        vins_1(m, :, :) = filtfilt(b, a, squeeze(vins_1(m, :, :))')';
    end
    
    vins_1(m, :, :) = demean(squeeze(vins_1(m, :, :)), 2);
    energy = squeeze(sum(vins_1(m, :, :).^2, 3));
    good = energy < median(energy) + 2*mad(energy);
    vavg_1 = squeeze(mean(vins_1(m, good, :), 2));
    calib.vavg_1(m, :) = vavg_1;
    Vavg_1 = rfft(vavg_1);
    
    % Apply calibartions to convert voltage to pressure
    % For ER-10X, this is approximate
    mic_sens = 50e-3; % mV/Pa. TO DO: change after calibration
    mic_gain = db2mag(gain); % +6 for balanced cable
    P_ref = 20e-6;
    DR_onesided = 1;
    mic_output_V_1 = Vavg_1 / (DR_onesided * mic_gain);
    output_Pa_1 = mic_output_V_1/mic_sens;
    outut_Pa_20uPa_per_Vpp_1 = output_Pa_1 / P_ref; % unit: 20 uPa / Vpeak
    
    freq = 1000*linspace(0,calib.SamplingRate/2,length(Vavg_1))';
    calib.freq = freq;
    
    % CARD MAT2VOLTS = 5.0
    Vo = rfft(calib.vo)*5*db2mag(-1 * calib.Attenuation);
    calib.CavRespH_1(:,m) =  outut_Pa_20uPa_per_Vpp_1 ./ Vo; %save for later
    
    
    %% Do driver 2 next:
    driver = 2;
    buffdata = zeros(2, numel(vo));
    buffdata(driver, :) = vo; % The other source plays nothing
    
    drop = [120, 120];
    drop(driver) = calib.Attenuation;
    
    for n = 1:(calib.Averages + calib.ThrowAway)
        vin = PlayCaptureNEL(card, buffdata, drop(1), drop(2), 1);
        
        % Save data
        if (n > calib.ThrowAway)
            vins_2(m,n-calib.ThrowAway,:) = vin;
        end
    end
    
    %compute the average
    
    if calib.doFilt
        % High pass at 100 Hz using IIR filter
        [b, a] = butter(4, 100 * 2 * 1e-3/calib.SamplingRate, 'high');
        vins_2(m, :, :) = filtfilt(b, a, squeeze(vins_2(m, :, :))')';
    end
    
    vins_2(m, :, :) = demean(squeeze(vins_2(m, :, :)), 2);
    energy = squeeze(sum(vins_2(m, :, :).^2, 3));
    good = energy < median(energy) + 2*mad(energy);
    vavg_2 = squeeze(mean(vins_2(m, good, :), 2));
    calib.vavg_2(m, :) = vavg_2;
    Vavg_2 = rfft(vavg_2);
    
    % Apply calibartions to convert voltage to pressure
    mic_output_V_2 = Vavg_2 / (DR_onesided * mic_gain);
    output_Pa_2 = mic_output_V_2/mic_sens;
    outut_Pa_20uPa_per_Vpp_2 = output_Pa_2 / P_ref; % unit: 20 uPa / Vpeak
    
    calib.CavRespH_2(:,m) =  outut_Pa_20uPa_per_Vpp_2 ./ Vo; %save for later
    
    % Check for button push
    % either ABORT or RESTART needs to break loop immediately,
    % saveNquit will complete current LEVEL sweep
    ud_status = get(h_push_stop,'Userdata');  % only call this once - ACT on 1st button push
    if strcmp(ud_status,'abort') || strcmp(ud_status,'restart')
        break;
    end
    
    if m+1 <= calib.CavNumb
        fprintf('Move to next tube! \n');
        % Tell user to make sure calibrator is set correctly
        uiwait(warndlg('MOVE TO THE NEXT SMALLEST TUBE','SET TUBE WARNING','modal'));
    end
    
    
end

%% Plot data
figure(66);
ax(1) = subplot(2, 1, 1);
semilogx(calib.freq, db(abs(calib.CavRespH_1)) + 20, 'linew', 2);
hold on; 
semilogx(calib.freq, db(abs(calib.CavRespH_2)) + 20, 'linew', 2);
ylabel('Response (dB re: 20 \mu Pa / V_{peak})', 'FontSize', 16);
ax(2) = subplot(2, 1, 2);
semilogx(calib.freq, unwrap(angle(calib.CavRespH_1), [], 1), 'linew', 2);
semilogx(calib.freq, unwrap(angle(calib.CavRespH_2), [], 1), 'linew', 2);
xlabel('Frequency (Hz)', 'FontSize', 16);
ylabel('Phase (rad)', 'FontSize', 16);
linkaxes(ax, 'x');
legend('show');
xlim([20, 24e3]);

%% Compute Thevenin Equivalent Pressure and Impedance

% Driver 1
%set up some variables
irr = 1; %ideal cavity reflection

%  calc the cavity length
calib.CavLength_1 = cavlen(calib.SamplingRate,calib.CavRespH_1, calib.CavTemp);
if (irr)
    la_1 = [calib.CavLength_1 1]; %the one is reflection fo perfect cavit
else
    la_1 = calib.CavLength_1; %#ok<UNRCH>
end

df=freq(2)-freq(1);
jef1=1+round(calib.f_err(1)*1000/df);
jef2=1+round(calib.f_err(2)*1000/df);
ej=jef1:jef2; %limit freq range for error calc

calib.Zc_1 = cavimp(freq, la_1, irr, calib.CavDiam, calib.CavTemp); %calc cavity impedances

% Driver 2

%  calc the cavity length
calib.CavLength_2 = cavlen(calib.SamplingRate,calib.CavRespH_2, calib.CavTemp);
if (irr)
    la_2 = [calib.CavLength_2 1]; %the one is reflection of perfect cavity
else
    la_2 = calib.CavLength_2; %#ok<UNRCH>
end

df=freq(2)-freq(1);
jef1=1+round(calib.f_err(1)*1000/df);
jef2=1+round(calib.f_err(2)*1000/df);
ej=jef1:jef2; %limit freq range for error calc

calib.Zc_2 = cavimp(freq, la_2, irr, calib.CavDiam, calib.CavTemp); %calc cavity impedances

%% Plot impedances
% It's best to have the set of half-wave resonant peaks (combined across
% all cavities and including all harmonics) distributed as uniformly as
% possible across the frequency range of interest.
figure(64)
hold on; 
plot(calib.freq/1000,dB(calib.Zc_1)); hold on
xlabel('Frequency kHz')
ylabel('Impedance dB')
%
pcav_1 = calib.CavRespH_1;
options = optimset('TolFun', 1e-12, 'MaxIter', 1e5, 'MaxFunEvals', 1e5);
la_1=fminsearch(@ (la_1) thverr(la_1,ej, freq, pcav_1, irr, calib.CavDiam, calib.CavTemp),la_1, options);
calib.Error_1 = thverr(la_1, ej, freq, pcav_1, irr, calib.CavDiam, calib.CavTemp);

calib.Zc_1=cavimp(freq,la_1, irr, calib.CavDiam, calib.CavTemp);  % calculate cavity impedances
[calib.Zs_1,calib.Ps_1]=thvsrc(calib.Zc_1,pcav_1); % estimate zs & ps

plot(freq/1000,dB(calib.Zc_1),'--'); %plot estimated Zc

calib.CavLength_1 = la_1;

if ~(calib.Error_1 >= 0 && calib.Error_1 <=1)
    h = warndlg ('Calibration error out of range!');
    waitfor(h);
end
 hold off; 
 
% Again for driver 2
figure(65)
hold on; 
plot(calib.freq/1000,dB(calib.Zc_2)); hold on
xlabel('Frequency kHz')
ylabel('Impedance dB')
%
pcav_2 = calib.CavRespH_2;
options = optimset('TolFun', 1e-12, 'MaxIter', 1e5, 'MaxFunEvals', 1e5);
la_2=fminsearch(@ (la_2) thverr(la_2,ej, freq, pcav_2, irr, calib.CavDiam, calib.CavTemp),la_2, options);
calib.Error_2 = thverr(la_2, ej, freq, pcav_2, irr, calib.CavDiam, calib.CavTemp);

calib.Zc_2=cavimp(freq,la_2, irr, calib.CavDiam, calib.CavTemp);  % calculate cavity impedances
[calib.Zs_2,calib.Ps_2]=thvsrc(calib.Zc_2,pcav_2); % estimate zs & ps

plot(freq/1000,dB(calib.Zc_2),'--'); %plot estimated Zc

calib.CavLength_2 = la_2;

if ~(calib.Error_2 >= 0 && calib.Error_2 <=1)
    h = warndlg ('Calibration error out of range!');
    waitfor(h);
end

%% Shut off buttons once out of data collection loop
% until we put STOP functionality in, all roads mean we're done here
set(h_push_stop,'Enable','off');
set(h_push_restart,'Enable','off');
set(h_push_abort,'Enable','off');
set(h_push_saveNquit,'Enable','off');

calib.NUMtrials_Completed = m;  % save how many trials completed

%store last button command, or that it ended all reps
if ~isempty(ud_status)
    NelData.FPL.rc = ud_status;  % button was pushed
    calib.ALLtrials_Completed=0;
else
    NelData.FPL.rc = 'saveNquit';  % ended all REPS - saveNquit
    calib.ALLtrials_Completed=1;
end

%% Shut Down TDT, no matter what button pushed, or if ended naturally
close_play_circuit(card.f1RP, card.RP);
rc = PAset(120.0*ones(1,4)); % need to use PAset, since it saves current value in PA, which is assumed way in NEL (causes problems when PAset is used to set attens later)
% run_invCalib(false);
% invfilterdata = set_invFilter(filttype, RawCalibPicNum, true);
%set back to allpass
filttype = {'allpass','allpass'};
RawCalibPicNum = NaN;
invfilterdata = set_invFilter(filttype, RawCalibPicNum, true);

%% Return to GUI script, unless need to save
if strcmp(NelData.FPL.rc,'abort') || strcmp(NelData.FPL.rc,'restart')
    return;  % don't need to save
end

%% Set up data structure to save
calib.date = datestr(clock);
% warning('off');  % ??

%% Big Switch case to handle end of data collection
switch NelData.FPL.rc
    case 'stop'   % 6/2023MH: MAY ADDD LATER (to stop, reset chin, then restart from where stopped) for NOW - only saveNquit, ohtherwise, abort or restart is already out by here
        % if want to RE-ADD stop, see DPOAE
        
    case 'saveNquit'
        % Option to save comment in data file
        comment='';
        TEMPans = inputdlg('Enter Comment (optional)');
        if ~isempty(TEMPans)
            comment=TEMPans{1};
        end
        calib.comment = comment;
        
        % NEL based data saving script
        make_FPLprobe_text_file;
        
        % remind user to turn of microphone
        h = msgbox('Please remember to turn off the microphone');
        uiwait(h);
        
end


