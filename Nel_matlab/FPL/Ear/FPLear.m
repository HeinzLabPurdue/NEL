global root_dir NelData data_dir

% NEL Version of RunMEMR_chin_edited_NEL1.m based off Hari's SNAPLab script

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
host=lower(getenv('hostname'));
host = host(~isspace(host));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Insert NEL/GUI Parameters here...none for WBMEMR

%% Get Probe File
% Setting up for now as in SNAPlab
[FileName,PathName,FilterIndex] = uigetfile(strcat('C:\NEL\Nel_matlab\FPL\Probe\ProbeCal_Data\FPLprobe*', date, '*.mat'),...
    'Please pick DRIVE PROBE CALIBRATION file to use');
probefile = fullfile(PathName, FileName);
load(probefile);

calib = x.FPLprobeData.calib; 
%% Initialize TDT
card = initialize_card;

%% Inverse Calibration
%NEEDS TO BE CLEANED UP ASAP.
% 1. run_invCalib needs cleaned up...currently clunky
% 2. Need calibration to be correct for MEMR (currently all pass, w/o calib)
[~, calibPicNum, ~] = run_invCalib(false);   % skipping INV calib for now since based on 94 dB SPL benig highest value, bot the 105 dB SPL from inv Calib.
[coefFileNum, ~, ~] = run_invCalib(-2);

calib.CalibPICnum2use = calibPicNum;  % save this so we know what calib file to use right from data file
coefFileNum = NaN;

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

%% Initializing variables
FPLear_ins;

subj = input('Please subject ID:', 's');
calib.subj = subj;

earflag = 1;
while earflag == 1
    ear = input('Please enter which ear (L or R):', 's');
    switch ear
        case {'L', 'l', 'Left', 'left', 'LEFT'}
            earname = strcat(ear, 'Ear');
            earlabel = 'L';
            earflag = 0;
            calib.ear = earlabel;
        case {'R', 'r', 'Right','right', 'RIGHT'}
            earname = strcat(ear, 'Ear');
            earlabel = 'R';
            earflag = 0;
            calib.ear = earlabel;
        otherwise
            fprintf(2, 'Unrecognized ear type! Try again!');
    end
end

probeIndex = 0;
gain = 40; % dB
Fs = calib.SamplingRate * 1000;

% Make click
y = zeros(1, calib.BufferSize);
y(2 + (1)) = 0.95;
vo = y(:); % Just in case


disp('Starting stimulation...');

%% Running Script

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
        vins_ear_1(n-calib.ThrowAway,:) = vin;
    end
end

if calib.doFilt
    % High pass at 100 Hz using IIR filter
    [b, a] = butter(4, 100 * 2 * 1e-3/calib.SamplingRate, 'high');
    vins_ear_1 = filtfilt(b, a, vins_ear_1')';
end

vins_ear_1 = demean(vins_ear_1, 2);
energy = squeeze(sum(vins_ear_1.^2, 2));
good = energy < median(energy) + 2*mad(energy, 1);
vavg_1 = squeeze(mean(vins_ear_1(good, :), 1));
Vavg_1 = rfft(vavg_1');
calib.vavg_ear_1 = vavg_1;

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

Vo = rfft(calib.vo)*5*db2mag(-1 * calib.Attenuation);
calib.EarRespH_1 =  outut_Pa_20uPa_per_Vpp_1 ./ Vo; %save for later


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
        vins_ear_2(n-calib.ThrowAway,:) = vin;
    end
end

%compute the average

if calib.doFilt
    % High pass at 100 Hz using IIR filter
    [b, a] = butter(4, 100 * 2 * 1e-3/calib.SamplingRate, 'high');
    vins_ear_2 = filtfilt(b, a, vins_ear_2')';
end

vins_ear_2 = demean(vins_ear_2, 2);
energy = squeeze(sum(vins_ear_2.^2, 2));
good = energy < median(energy) + 2*mad(energy);
vavg_2 = squeeze(mean(vins_ear_2(good, :), 1));
Vavg_2 = rfft(vavg_2'); 
calib.vavg_ear_2 = vavg_2;

% Apply calibartions to convert voltage to pressure
mic_output_V_2 = Vavg_2 / (DR_onesided * mic_gain);
output_Pa_2 = mic_output_V_2/mic_sens;
outut_Pa_20uPa_per_Vpp_2 = output_Pa_2 / P_ref; % unit: 20 uPa / Vpeak

calib.EarRespH_2 =  outut_Pa_20uPa_per_Vpp_2 ./ Vo; %save for later

%% Plot data
figure(11);
ax(1) = subplot(2, 1, 1);
semilogx(calib.freq, db(abs(calib.EarRespH_1)), 'linew', 2);
hold on; 
semilogx(calib.freq, db(abs(calib.EarRespH_2)), 'linew', 2);
hold off; 
ylabel('Response (dB re: 20 \mu Pa / V_{peak})', 'FontSize', 16);
ax(2) = subplot(2, 1, 2);
semilogx(calib.freq, unwrap(angle(calib.EarRespH_1), [], 1), 'linew', 2);
hold on; 
semilogx(calib.freq, unwrap(angle(calib.EarRespH_2), [], 1), 'linew', 2);
hold off; 
xlabel('Frequency (Hz)', 'FontSize', 16);
ylabel('Phase (rad)', 'FontSize', 16);
linkaxes(ax, 'x');
legend('show');
xlim([100, 24e3]);

%% Calculate Ear properties
% *ec: Ear canal
% *s: Source
% R*: Reflectance
% Z*: Impedance
% Pfor: Forward pressure
% Prev: Reverse pressure
% Pinc: Incident pressure

% for both drivers
calib = findHalfWaveRes(calib);
calib.fwb = 0.55;% bandwidth/Nyquist freq of freq.domain window % decompose pressures

% for driver 1
calib.Zec_raw_1 = ldimp(calib.Zs_1, calib.Ps_1, calib.EarRespH_1);
calib.Zec_1 = calib.Zec_raw_1;

[calib.Rec_1, calib.Rs_1, calib.Rx_1, calib.Pfor_1, calib.Prev_1, calib.Pinc_1, ...
    calib.Px_1, calib.Z0_1, calib.Zi_1, calib.Zx_1] = decompose(calib.Zec_1,...
    calib.Zs_1, calib.EarRespH_1, calib.Ps_1, calib.fwb, ...
    calib.CavTemp, calib.CavDiam);

% Check for leaks as in Groon et al
ok = find (calib.freq >= 200 & calib.freq <= 500);
calib.A_lf_1 =  mean(1-(abs(calib.Rec_1(ok))).^2);
fprintf(1, 'Low-frequency absorbance: %2.3f\n', calib.A_lf_1);
calib.Yphase_lf_1 = mean(cycs(1./calib.Zec_1(ok)))*360;
fprintf(1, 'Low-frequency admittance phase: %2.3f%c\n',...
    calib.Yphase_lf_1, char(176));

% for driver 2
calib.Zec_raw_2 = ldimp(calib.Zs_2, calib.Ps_2, calib.EarRespH_2);
calib.Zec_2 = calib.Zec_raw_2;

[calib.Rec_2, calib.Rs_2, calib.Rx_2, calib.Pfor_2, calib.Prev_2, calib.Pinc_2, ...
    calib.Px_2, calib.Z0_2, calib.Zi_2, calib.Zx_2] = decompose(calib.Zec_2,...
    calib.Zs_2, calib.EarRespH_2, calib.Ps_2, calib.fwb, ...
    calib.CavTemp, calib.CavDiam);

% Check for leaks as in Groon et al
ok = find (calib.freq >= 200 & calib.freq <= 500);
calib.A_lf_2 =  mean(1-(abs(calib.Rec_2(ok))).^2);
fprintf(1, 'Low-frequency absorbance: %2.3f\n', calib.A_lf_2);
calib.Yphase_lf_2 = mean(cycs(1./calib.Zec_2(ok)))*360;
fprintf(1, 'Low-frequency admittance phase: %2.3f%c\n',...
    calib.Yphase_lf_2, char(176));

% Give errors if either is off
if (calib.A_lf_1 > 0.29) || (calib.A_lf_2 > 0.29)
    h = warndlg ('Sound-leak alert! Low-frequency absorbance > 0.29');
    waitfor(h);
end

if (calib.Yphase_lf_1 < 44) || (calib.Yphase_lf_2 < 44)
    h = warndlg ('Sound-leak alert! Low-frequency admittance phase < 44 degrees');
    waitfor(h);
end

%% Plot Ear Absorbance
figure(12);
hold on; 
semilogx(calib.freq * 1e-3, 100*(1 - abs(calib.Rec_1).^2), 'linew', 2);
semilogx(calib.freq * 1e-3, 100*(1 - abs(calib.Rec_2).^2), 'linew', 2);
hold off; 
xlabel('Frequency (Hz)', 'FontSize', 16);
ylabel('Absorbance (%)', 'FontSize', 16);
xlim([0.2, 8]); ylim([0, 100]);
set(gca, 'FontSize', 16, 'XTick',[0.25, 0.5, 1, 2, 4, 8]);

%% Shut off buttons once out of data collection loop
% until we put STOP functionality in, all roads mean we're done here
set(h_push_stop,'Enable','off');
set(h_push_restart,'Enable','off');
set(h_push_abort,'Enable','off');
set(h_push_saveNquit,'Enable','off');


%% Shut Down TDT, no matter what button pushed, or if ended naturally
close_play_circuit(card.f1RP, card.RP);
rc = PAset(120.0*ones(1,4)); % need to use PAset, since it saves current value in PA, which is assumed way in NEL (causes problems when PAset is used to set attens later)
run_invCalib(false);

%% Return to GUI script, unless need to save
if strcmp(NelData.FPL.rc,'abort') || strcmp(NelData.FPL.rc,'restart')
    return;  % don't need to save
end

%% Set up data structure to save
calib.date = datestr(clock);

warning('off');  % ??

%% Big Switch case to handle end of data collection
switch NelData.FPL.rc
    case 'stop'   % 6/2023MH: MAY ADDD LATER (to stop, reset chin, then restart from where stopped) for NOW - only saveNquit, ohtherwise, abort or restart is already out by here
        % if want to RE-ADD stop, see DPOAE
        
    case 'saveNquit'
        
        %% Option to save comment in data file
        comment='';
        TEMPans = inputdlg('Enter Comment (optional)');
        if ~isempty(TEMPans)
            comment=TEMPans{1};
        end
        calib.comment = comment;
        
        %% NEL based data saving script
        make_FPLear_text_file;
        
        %% remind user to turn of microphone
        h = msgbox('Please remember to turn off the microphone');
        uiwait(h);
        
end


