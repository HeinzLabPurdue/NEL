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

driverflag = 1;
while driverflag == 1
    driver = input('Please enter whether you want driver 1, 2 or 3 (Aux on ER-10X):');
    switch driver
        case {1, 2}
            drivername = strcat('Ph',num2str(driver));
            driverflag = 0;
        case 3
            if strcmp(device, 'ER-10X')
                drivername = 'PhAux';
                driverflag = 0;
            else
                fprintf(2, 'Unrecognized driver! Try again!');
            end
        otherwise
            fprintf(2, 'Unrecognized driver! Try again!');
    end
end

calib.drivername = drivername;
calib.driver = driver;

vo = calib.y; 
buffdata = zeros(2, numel(vo));
buffdata(driver, :) = vo; % The other source plays nothing
calib.vo = vo;
vins = zeros(calib.CavNumb, calib.Averages, calib.BufferSize);
calib.vavg = zeros(calib.CavNumb, calib.BufferSize);

for m = 1: calib.CavNumb
    
    % Check for button push
    % either ABORT or RESTART needs to break loop immediately,
    % saveNquit will complete current LEVEL sweep
    ud_status = get(h_push_stop,'Userdata');  % only call this once - ACT on 1st button push
    if strcmp(ud_status,'abort') || strcmp(ud_status,'restart')
        break;
    end
    
    drop = [120, 120]; 
    drop(driver) = calib.Attenuation; 
    
    for n = 1:(calib.Averages + calib.ThrowAway)
        vin = PlayCaptureNEL(card, buffdata, drop(1), drop(2), 1); 
        
          % Save data
        if (n > calib.ThrowAway)
            vins(m,n-calib.ThrowAway,:) = vin;
        end
    end
    
        %compute the average
    
    if calib.doFilt
        % High pass at 100 Hz using IIR filter
        [b, a] = butter(4, 100 * 2 * 1e-3/calib.SamplingRate, 'high');
        vins(m, :, :) = filtfilt(b, a, squeeze(vins(m, :, :))')';
    end
    
    vins(m, :, :) = demean(squeeze(vins(m, :, :)), 2);
    energy = squeeze(sum(vins(m, :, :).^2, 3));
    good = energy < median(energy) + 2*mad(energy);
    vavg = squeeze(mean(vins(m, good, :), 2));
    calib.vavg(m, :) = vavg;
    Vavg = rfft(vavg);
    
    % Apply calibartions to convert voltage to pressure
    % For ER-10X, this is approximate
    mic_sens = 50e-3; % mV/Pa. TO DO: change after calibration
    mic_gain = db2mag(gain); % +6 for balanced cable
    P_ref = 20e-6;
    DR_onesided = 1;
    mic_output_V = Vavg / (DR_onesided * mic_gain);
    output_Pa = mic_output_V/mic_sens;
    outut_Pa_20uPa_per_Vpp = output_Pa / P_ref; % unit: 20 uPa / Vpeak
    
    freq = 1000*linspace(0,calib.SamplingRate/2,length(Vavg))';
    calib.freq = freq;
    
    % CARD MAT2VOLTS = 5.0
    Vo = rfft(calib.vo)*5*db2mag(-1 * calib.Attenuation);
    calib.CavRespH(:,m) =  outut_Pa_20uPa_per_Vpp ./ Vo; %save for later
    
    if m+1 <= calib.CavNumb
        fprintf('Move to next tube! \n');
        % Tell user to make sure calibrator is set correctly
        uiwait(warndlg('MOVE TO THE NEXT SMALLEST TUBE','SET TUBE WARNING','modal'));
    end
    
end

%% Plot data
figure; 
ax(1) = subplot(2, 1, 1);
semilogx(calib.freq, db(abs(calib.CavRespH)) + 20, 'linew', 2);
ylabel('Response (dB re: 20 \mu Pa / V_{peak})', 'FontSize', 16);
ax(2) = subplot(2, 1, 2);
semilogx(calib.freq, unwrap(angle(calib.CavRespH), [], 1), 'linew', 2);
xlabel('Frequency (Hz)', 'FontSize', 16);
ylabel('Phase (rad)', 'FontSize', 16);
linkaxes(ax, 'x');
legend('show');
xlim([20, 24e3]);

%% Compute Thevenin Equivalent Pressure and Impedance

%set up some variables
irr = 1; %ideal cavity reflection

%  calc the cavity length
calib.CavLength = cavlen(calib.SamplingRate,calib.CavRespH, calib.CavTemp);
if (irr)
    la = [calib.CavLength 1]; %the one is reflection fo perfect cavit
else
    la = calib.CavLength; %#ok<UNRCH>
end

df=freq(2)-freq(1);
jef1=1+round(calib.f_err(1)*1000/df);
jef2=1+round(calib.f_err(2)*1000/df);
ej=jef1:jef2; %limit freq range for error calc

calib.Zc = cavimp(freq, la, irr, calib.CavDiam, calib.CavTemp); %calc cavity impedances

%% Plot impedances
% It's best to have the set of half-wave resonant peaks (combined across
% all cavities and including all harmonics) distributed as uniformly as
% possible across the frequency range of interest.
figure(2)
plot(calib.freq/1000,dB(calib.Zc)); hold on
xlabel('Frequency kHz')
ylabel('Impedance dB')
%
pcav = calib.CavRespH;
options = optimset('TolFun', 1e-12, 'MaxIter', 1e5, 'MaxFunEvals', 1e5);
la=fminsearch(@ (la) thverr(la,ej, freq, pcav, irr, calib.CavDiam, calib.CavTemp),la, options);
calib.Error = thverr(la, ej, freq, pcav, irr, calib.CavDiam, calib.CavTemp);

calib.Zc=cavimp(freq,la, irr, calib.CavDiam, calib.CavTemp);  % calculate cavity impedances
[calib.Zs,calib.Ps]=thvsrc(calib.Zc,pcav); % estimate zs & ps

plot(freq/1000,dB(calib.Zc),'--'); %plot estimated Zc

calib.CavLength = la;

if ~(calib.Error >= 0 && calib.Error <=1)
    h = warndlg ('Calibration error out of range!');
    waitfor(h);
end


%% Shut off buttons once out of data collection loop
% until we put STOP functionality in, all roads mean we're done here
set(h_push_stop,'Enable','off');
set(h_push_restart,'Enable','off');
set(h_push_abort,'Enable','off');
set(h_push_saveNquit,'Enable','off');

stim.NUMtrials_Completed = m;  % save how many trials completed

%store last button command, or that it ended all reps
if ~isempty(ud_status)
    NelData.FPL.rc = ud_status;  % button was pushed
    stim.ALLtrials_Completed=0;
else
    NelData.FPL.rc = 'saveNquit';  % ended all REPS - saveNquit
    stim.ALLtrials_Completed=1;
end

%% Shut Down TDT, no matter what button pushed, or if ended naturally
close_play_circuit(card.f1RP, card.RP);
rc = PAset(120.0*ones(1,4)); % need to use PAset, since it saves current value in PA, which is assumed way in NEL (causes problems when PAset is used to set attens later)
run_invCalib(false);

%% Return to GUI script, unless need to save
if strcmp(NelData.FPL.rc,'abort') || strcmp(NelData.FPL.rc,'restart')
    return;  % don't need to save
end

%% Set up data structure to save
stim.date = datestr(clock);

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
        stim.comment = comment;
        
        %% NEL based data saving script
        make_sweptdpoae_text_file;
        
        %% remind user to turn of microphone
        h = msgbox('Please remember to turn off the microphone');
        uiwait(h);
        
end


