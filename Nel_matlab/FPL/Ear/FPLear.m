global root_dir NelData data_dir PROTOCOL

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
host=lower(getenv('hostname'));
host = host(~isspace(host));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Insert NEL/GUI Parameters here.
PROTOCOL = 'FPLear';

%% Initialize TDT
card = initialize_card;

% Eliminating this here because will be live calculated: 
% ADdelay = 216; 
ADdelay = 0; 
%% New Ear Calib or Inverse Calib

if (NelData.General.RP2_3and4 || NelData.General.RX8)
    cdd;
    all_Calib_files= dir('p*calib_FPL*');
    if isempty(all_Calib_files)
        newCalib = true;
        doInvCalib = false;
    else
        inStr= questdlg('Calib files already exists - run new calib or use latest FIR coeffs?', 'New or Rerun?', 'New Calib', 'FIR Calib', 'FIR Calib');
        if strcmp(inStr, 'New Calib')
            newCalib= true;
            doInvCalib = false;
        elseif strcmp(inStr, 'FIR Calib')
            newCalib= false;
            doInvCalib = true;
        end
    end
    rdd;
    
    if doInvCalib %already has a raw
        filttype = {'inversefilt_FPL','inversefilt_FPL'};
        cdd;
        all_raw = findPics('FPL_raw*');
        RawCalibPicNum = max(all_raw);     
        %prompt user for RAW calib
        RawCalibPicNum = inputdlg('Please confirm the RAW calibration file to use (default = last raw calib): ', 'Calibration!',...
            1,{num2str(RawCalibPicNum)});
        RawCalibPicNum = str2double(RawCalibPicNum{1});
        rdd;
       %ADdelay = 344; 
    else %first time calib
        filttype = {'allpass','allpass'};
        RawCalibPicNum = NaN;
         %ADdelay = 216;
    end
    
    invfilterdata = set_invFilter(filttype, RawCalibPicNum, true);
    coefFileNum = invfilterdata.coefFileNum;
    
else
    newCalib= true;
end

%% Get Probe File
% Setting up for now as in SNAPlab
[FileName,PathName,FilterIndex] = uigetfile(strcat('C:\NEL\Nel_matlab\FPL\Probe\ProbeCal_Data\FPLprobe*', date, '*.mat'),...
    'Please pick PROBE CALIBRATION file to use');
probefile = fullfile(PathName, FileName);
load(probefile);

calib = x.FPLprobeData.calib;

%% Enter subject information
if ~isfield(NelData,'FPL') % First time through, need to ask all this.
      
    % Save in case if restart
    NelData.FPL.Fig2close=[];  % set up the place to keep track of figures generted here (to be closed in NEL_App Checkout)
    NelData.FPL.FPL_figNum=477;  % +200 from wbMEMR
    
else
    fprintf('RESTARTING...\n')
end

%% Initializing variables
%FPLear_ins;

ear = questdlg('Which Ear?', 'Ear', 'L', 'R', 'R');
calib.ear = ear;
uiwait(warndlg('Set ER-10B+ GAIN to 40 dB','SET ER-10B+ GAIN WARNING','modal'));

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
    vin = PlayCaptureNEL(card, buffdata, drop(1), drop(2), ADdelay);
    
    % Save data
    if (n > calib.ThrowAway)
        vins_ear_1(n-calib.ThrowAway,:) = vin;
    end
end

%% Calculate the delay when first passing zero delay
% then adjust the buffer to account for measured difference
abs_resp_temp = abs(mean(vins_ear_1,1)); 
[~, clickpeak] = max(vo); 
baselinepeak = max(abs_resp_temp(end-500:end)); 
if doInvCalib
    [~, resppeak] = max(abs_resp_temp); 
else
    [~, resppeak] = findpeaks(abs_resp_temp, 'MinPeakHeight', baselinepeak*2, 'NPeaks', 1);
end
measuredDelay_1 = resppeak - clickpeak; 
measuredDelay_1 = max([measuredDelay_1 - 1, 1]); 
new_vins_ear_1 = zeros(size(vins_ear_1)); 
temp_vins_ear_1 = vins_ear_1(:, measuredDelay_1:end);
new_vins_ear_1(:, 1:length(temp_vins_ear_1)) = temp_vins_ear_1; 
vins_ear_1 = new_vins_ear_1; 

%% back to rest of analysis
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

freq = calib.freq; %1000*linspace(0,calib.SamplingRate/2,length(Vavg_1))';

% if doInvCalib
%      vo_filt = filter(invfilterdata.b_chan1, 1, calib.vo); 
%      Vo_1 = rfft(vo_filt)*5*db2mag(-1 * calib.Attenuation);
% else 
    Vo = rfft(calib.vo)*5*db2mag(-1 * calib.Attenuation);
    Vo_1 = Vo; 
% end

calib.EarRespH_1 =  outut_Pa_20uPa_per_Vpp_1 ./ Vo_1; %save for later


%% Do driver 2 next:
driver = 2;
buffdata = zeros(2, numel(vo));
buffdata(driver, :) = vo; % The other source plays nothing

drop = [120, 120];
drop(driver) = calib.Attenuation;

for n = 1:(calib.Averages + calib.ThrowAway)
    vin = PlayCaptureNEL(card, buffdata, drop(1), drop(2), ADdelay);
    
    % Save data
    if (n > calib.ThrowAway)
        vins_ear_2(n-calib.ThrowAway,:) = vin;
    end
end

%% Calculate the delay when first passing zero delay
% then adjust the buffer to account for measured difference
abs_resp_temp_2 = abs(mean(vins_ear_2,1)); 
[~, clickpeak] = max(vo); 
baselinepeak = max(abs_resp_temp_2(end-500:end)); 
if doInvCalib
    [~, resppeak] = max(abs_resp_temp); 
else
    [~, resppeak] = findpeaks(abs_resp_temp, 'MinPeakHeight', baselinepeak*2, 'NPeaks', 1);
end
measuredDelay_2 = resppeak - clickpeak; 
measuredDelay_2 = max([measuredDelay_2 - 1, 1]); 
new_vins_ear_2 = zeros(size(vins_ear_2)); 
temp_vins_ear_2 = vins_ear_2(:, measuredDelay_2:end);
new_vins_ear_2(:, 1:length(temp_vins_ear_2)) = temp_vins_ear_2; 
vins_ear_2 = new_vins_ear_2; 

%%
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
output_Pa_20uPa_per_Vpp_2 = output_Pa_2 / P_ref; % unit: 20 uPa / Vpeak

% if doInvCalib
%      vo_filt = filter(invfilterdata.b_chan1, 1, calib.vo); 
%      Vo_2 = rfft(vo_filt)*5*db2mag(-1 * calib.Attenuation);
% else 
    Vo = rfft(calib.vo)*5*db2mag(-1 * calib.Attenuation);
    Vo_2 = Vo; 
%end

calib.EarRespH_2 =  output_Pa_20uPa_per_Vpp_2 ./ Vo_2; %save for later

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

if strcmp(NelData.Metadata.NEL, 'NEL1')
    NEL1delay = 25;
else 
    NEL1delay = 0; 
end

if doInvCalib
    expDelay = 214+128 + NEL1delay; 
    %214 is knowledge from measuring the click in an inf tube
    %128 is half the FIR filter order
    %25 for NEL1 delay is measured from click in tube across both NELS
    %All of this is true as of 6/28/24 - May need to check periodically. 
else
    expDelay = 214 + NEL1delay;
end 
% Give warning about NEL latency that was calculated
    h = warndlg (sprintf('Expected Latency: %d samples \n Chan. 1 Latency: %d samples \n Chan. 2 Latency: %d samples', expDelay, measuredDelay_1, measuredDelay_2), 'Computed Latencies', 'modal');
    waitfor(h);
    
% Give errors if either is off
if (calib.A_lf_1 > 0.29) || (calib.A_lf_2 > 0.29)
    h = warndlg ('Sound-leak alert! Low-frequency absorbance > 0.29');
    waitfor(h);
end

if (calib.Yphase_lf_1 < 44) || (calib.Yphase_lf_2 < 44)
    h = warndlg ('Sound-leak alert! Low-frequency admittance phase < 44 degrees');
    waitfor(h);
end

ud_status = get(h_push_stop,'Userdata');  % only call this once - ACT on 1st button push

%% Set up like NEL varibles
fullCalibData = zeros(length(freq), 5); 
fullCalibData2 = zeros(length(freq), 5); 
% Frequencies in NEL form
fullCalibData(:,1) = calib.freq./1000; % kHz
fullCalibData2(:,1) = calib.freq./1000;
% Output in NEL form
fullCalibData(:,2) = db(abs(calib.Pfor_1.*(5/sqrt(2))));
fullCalibData2(:,2) = db(abs(calib.Pfor_2.*(5/sqrt(2))));

% Resample to match frequencies from standard NEL calib
nel_freq = [0.05*2.0.^((0:345)/40)]'; 
CalibData = zeros(length(nel_freq), 5);
CalibData2 = zeros(length(nel_freq), 5);
CalibData(:,1) = nel_freq; 
CalibData2(:,1) = nel_freq; 
CalibData(:,2) = interp1(fullCalibData(:,1), fullCalibData(:,2), nel_freq); 
CalibData2(:,2) = interp1(fullCalibData2(:,1), fullCalibData2(:,2), nel_freq); 
%% Plot data
figure(61);
semilogx(CalibData(:,1).*1000, CalibData(:,2), 'linew', 2, 'color', [0 0.447 0.741]);
hold on;
semilogx(CalibData2(:,1).*1000, CalibData2(:,2), 'linew', 2, 'color', [0.635 0.078 0.184]);
hold on; 
plot([10 20e3], [105 105], '--', 'linew', 2, 'color', [178 190 181]/255);
hold off;
ylabel('Response (dB)', 'FontSize', 16);
xlabel('Frequency (Hz)', 'FontSize', 16);
legend('Left', 'Right');
xlim([100, 20e3]);
xticks([100, 200, 400, 800, 1600, 3200, 6400, 12800])
set(gca, 'XScale', 'log')

%% Plot data
% figure(61);
% % ax(1) = subplot(2, 1, 1);
% semilogx(calib.freq, db(abs(calib.Pfor_1)), 'linew', 2);
% hold on;
% semilogx(calib.freq, db(abs(calib.Pfor_2)), 'linew', 2);
% hold off;
% ylabel('Response (dB re: 20 \mu Pa / V_{peak})', 'FontSize', 16);
% % ax(2) = subplot(2, 1, 2);
% % semilogx(calib.freq, unwrap(angle(calib.Pfor_1), [], 1), 'linew', 2);
% % hold on;
% % semilogx(calib.freq, unwrap(angle(calib.Pfor_2), [], 1), 'linew', 2);
% % hold off;
% xlabel('Frequency (Hz)', 'FontSize', 16);
% % ylabel('Phase (rad)', 'FontSize', 16);
% % linkaxes(ax, 'x');
% legend('show');
% xlim([100, 24e3]);
%% Plot Ear Absorbance
if newCalib
    figure(12);
    hold on; 
    % plot absorbance norms
    load('FPLear_norms.mat', 'f', 'loabs', 'hiabs'); 
    col = [.9, .9, .9];
    fill([f, f(end), f(end:-1:1), f(1)], [loabs, hiabs(end), hiabs(end:-1:1), loabs(1)], col, 'linestyle', 'none');

    % plot data
    semilogx(calib.freq * 1e-3, 100*(1 - abs(calib.Rec_1).^2), 'linew', 2);
    hold on;
    semilogx(calib.freq * 1e-3, 100*(1 - abs(calib.Rec_2).^2), 'linew', 2);
    hold off;
    xlabel('Frequency (kHz)', 'FontSize', 16);
    ylabel('Absorbance (%)', 'FontSize', 16);
    xlim([0.2, 8]); ylim([0, 100]);
    set(gca, 'FontSize', 16, 'XTick',[0.25, 0.5, 1, 2, 4, 8], 'XScale', 'log');
end
%% Shut off buttons once out of data collection loop
% until we put STOP functionality in, all roads mean we're done here
set(h_push_stop,'Enable','off');
set(h_push_restart,'Enable','off');
set(h_push_abort,'Enable','off');
set(h_push_saveNquit,'Enable','off');

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

%set back to allpass
dummy = set_invFilter({'allpass','allpass'},RawCalibPicNum, true);

%% Return to GUI script, unless need to save
if strcmp(NelData.FPL.rc,'abort') || strcmp(NelData.FPL.rc,'restart')
    return;  % don't need to save
end

%% Set up data structure to save
calib.date = datestr(clock);

warning('off');  % ??

%% Big Switch case to handle end of data collection
switch NelData.FPL.rc
    case 'stop'   
        % 6/2023MH: MAY ADDD LATER (to stop, reset chin, then restart from 
        % where stopped) for NOW - only saveNquit, ohtherwise, abort or restart
        % is already out by here
        % if want to RE-ADD stop, see DPOAE
        
    case 'saveNquit'
        
        %% Option to save comment in data file
        comment='';
        TEMPans = inputdlg('Enter Comment (optional)');
        if ~isempty(TEMPans)
            comment=TEMPans{1};
        end
        calib.comment = comment;
        
        fname = current_data_file('calib_FPL',1);
        
        if newCalib % save as raw and get coeffs
            fname= strcat(fname, '_raw');
        else % save as inverse calib
            fname= sprintf('%s_inv%d', fname, coefFileNum);
        end
        
        make_FPLear_text_file;
        
        if newCalib
            [~, temp_picName] = fileparts(fname);
            get_inv_calib_fir_coeff(getPicNum(temp_picName));
        end
        %% remind user to turn of microphone
        h = msgbox('Please remember to turn off the microphone');
        uiwait(h);
        
        
end


