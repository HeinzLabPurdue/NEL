% filename = strcat(FILEPREFIX,num2str(FNUM),'.m');global root_dir NelData data_dir%% Update: CodingSprint2022 - AS/MH% cleaning this up for templatee for integrating MEMR, etc.% was goofy patterns (L=R, and R=L - weird), cleaning those up as follows:% RP1 - just Control bits% RP2 - stim gen&recording:RP2-1_out=f1; Rp2-2_out=f2; RP2-1_in = mic% re-doing to pass %     f1 to Rselect %     f2 to Lselect%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%host=lower(getenv('hostname'));host = host(~isspace(host));%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%filename = current_data_file('dpoae',1);Channel = 1;% DPOAE - Get frequency & step parametersF2frqlo = PARAMS(1);F2frqhi = PARAMS(2);octaves = log2(F2frqhi/F2frqlo);linstps = PARAMS(3);logstps = PARAMS(4);Fratio = PARAMS(8);% DPOAE - Calculate number of frequenciesif logstps > 0    F2frqlst=logspace(log10(F2frqlo),log10(F2frqhi),octaves*logstps);elseif logstps < 0    F2frqlst=Qspace(F2frqlo,F2frqhi,-logstps);else    F2frqlst=linspace(F2frqlo,F2frqhi,octaves*linstps);endfrqnum = length(F2frqlst);F1frqlst = F2frqlst/Fratio;% DPOAE - Get level parameters%CalibSPL = PARAMS(11);   % NOT USED, bad way - assumes flat calibL2_dBSPL = PARAMS(12);L1_dBSPL = PARAMS(13);MicGain = PARAMS(14);% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%cdd;allCalibs= dir('p*calib*raw*');all_calib_picNums= cell2mat(cellfun(@(x) getPicNum(x), {allCalibs.name}', 'UniformOutput', false));CalibPicNum = inputdlg('Enter Calibration Pic number:                [Cancel]=Use average calibration','Calibration Pic',1,{num2str(max(all_calib_picNums))});if ~isempty(CalibPicNum)    CalibPicNum = str2double(CalibPicNum{1});else    CalibPicNum = 1;    SaveDirXYZ = cd;    cd([NelData.General.RootDir 'Nel_matlab\DPOAE\calibfiles'])endxCAL = loadpic(CalibPicNum);CalibData = xCAL.CalibData(:,1:2);rdd% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Interpolate calibrationsL1_dBatten= nan(1, frqnum);L2_dBatten= nan(1, frqnum);for ii=1:frqnum    L1_dBatten(ii) = CalibInterp(F1frqlst(ii),CalibData) - L1_dBSPL;    L2_dBatten(ii) = CalibInterp(F2frqlst(ii),CalibData) - L2_dBSPL;end% DPOAE - Set left/right SwitchBox (SB) parameters [ear not USED]ear = PARAMS(5);  %1 left [2 right, 3 both (set in *ins) - CODE REQUIRES 1 here, don't change]left_SB  = 1;right_SB = 2;% both = 3;% Actually, we're using both left and right acoustic outputs (for the two tones separately)...% but the code is written as if everything was going through the left ear...if (ear>1)    nelerror('dpoae.m: code is only designed for the left ear');end% DPOAE - Build config structures [1st number is LEFT channel; 2nd number is RIGHT channel in TDT]% RP2-1-out1 is NOT USED% RP2-1-out2 is NOT USED% RP2-2-out1 is routed through PA5-1&3% RP2-2-out2 is routed through PA5-2&4% RP2-2-in1 is microphoneconfig = struct('atten',[1 1],'sel',[5 0],'conn',[2 1]); %[1st number is lEFT channel; 2nd number is RIGHT channel in TDT]% atten is not used% 2022 MH/AS - fixed this to bee linear pass throughs (f1 and f2 stay on% same side whole way, rather than switch at end% DPOAE - Get tone duration parametersToneOn  = PARAMS(6);ToneOff = PARAMS(7);tspan = (ToneOff)/1000;% % DPOAE - Set up the position of the main figure axis in the GUIhandles = get(gcf,'Userdata');h_ax1   = handles(8);if (ishandle(h_ax1))    delete(h_ax1);endh_ax1 = axes('position',[.1 .415-0.08 .8 .56+0.08]);handles(8) = h_ax1;set(gcf,'Userdata',handles);% DPOAE - Set up the axis and line properties for the main figure axish_line1 = semilogx(50,0,'r-','LineWidth',2);hold on;h_line2 = semilogx(50,0,'w-','LineWidth',1);h_line3 = semilogx(50,0,'yo','MarkerSize',12);%axis([0.5*F2frqlo*1000 2*F2frqhi*1000 -20 max(L1_dBSPL,L2_dBSPL)+20]);%set(h_ax1,'XTick',[1000*F2frqlo+.000001 1000*F2frqhi],'TickDir','out');axis([199 20001 -20 max(L1_dBSPL,L2_dBSPL)+20]);set(h_ax1,'XTick',[200 300 400 500 600 700 800 900 1000 2000 3000 4000 5000 6000 7000 8000 9000 10000 20000],...    'XTickLabel', ['0.2';'0.3';'0.4';'0.5';'0.6';'   ';'0.8';'   ';'1.0';'2.0';'3.0';'4.0';'5.0';'6.0';'   ';...    '8.0';'   ';' 10';' 20'],'TickDir','out');% % set(h_ax1, 'XTick', ...% %    unique(min(F2frqhi,max(F2frqlo, [F2frqlo+.000001 0.1 0.2 0.4 1 2 4 7 10 15 20:10:50 100 F2frqhi]))));set(h_ax1, 'XMinorTick', 'off');set(h_ax1,'YTick',-20:20:120);xlabel('Frequency (kHz)','fontsize',14);ylabel('Level (dB SPL)','fontsize',14);set(h_ax1,'Color',[0.3 0.3 0.3]);drawnow;% DPOAE - Get measurement parametersADdur = PARAMS(9);Nreps = PARAMS(10);%%%%%%%%%%%%%%%%%% - fix this to grab from TDT.SR_Hz = 24414.0625; % Assuming this sample rate%%%%%%%%%%%%%%%ADdur_pts = floor(ADdur/1000*SR_Hz);% Set up the RP2% RPco2=actxcontrol('RPco.x',[0 0 1 1]);% invoke(RPco2, 'ConnectRP2',NelData.General.TDTcommMode,2);[RPco2, rc]= connect_tdt('RP2', 2);rc = rc & invoke(RPco2,'LoadCof',[root_dir 'dpoae\object\dpoae_right.rcx']);rc = rc & invoke(RPco2,'SetTagVal','Select_R',config.sel(right_SB));rc = rc & invoke(RPco2,'SetTagVal','Connect_R',config.conn(right_SB));%% Use these if Matlab is initiating each rep:rc = rc & invoke(RPco2,'SetTagVal','Tone_ms', ToneOn);rc = rc & invoke(RPco2,'SetTagVal','AD_ms', ADdur);%% Use these if the cirecuit is initiating each rep:% rc = rc & invoke(RPco2,'SetTagVal','Tone_On_ms', ToneOn);% rc = rc & invoke(RPco2,'SetTagVal','Tone_Off_ms', ToneOff);% rc = rc & invoke(RPco2,'SetTagVal','AD_On_ms', ADdur);% rc = rc & invoke(RPco2,'SetTagVal','AD_Off_ms', ToneOn+ToneOff-ADdur);% rc = rc & invoke(RPco2,'SetTagVal','Nreps', Nreps);%%rc = rc & invoke(RPco2,'Run');if (rc ~= 1)    nelerror('dpoae.m: can''t load circuit to 2nds RP2');end% Set up the other RP2% rc = 1;% RPco1=actxcontrol('RPco.x',[0 0 1 1]);% invoke(RPco1, 'ConnectRP2',NelData.General.TDTcommMode,1);[RPco1, rc]= connect_tdt('RP2', 1);rc = rc & invoke(RPco1,'LoadCof',[root_dir 'dpoae\object\blank_left.rcx']);rc = rc & invoke(RPco1,'SetTagVal','Select_L',config.sel(left_SB));rc = rc & invoke(RPco1,'SetTagVal','Connect_L',config.conn(left_SB));rc = rc & invoke(RPco1,'Run');if (rc ~= 1)    nelerror('dpoae.m: can''t load circuit to 1st RP2');end% Turn down the volume on all attenuators% PAco1=actxcontrol('PA5.x',[0 0 1 1]);for atten_num = 1:4    %     invoke(PAco1,'ConnectPA5',NelData.General.TDTcommMode,atten_num);    PAco1= connect_tdt('PA5', atten_num);    invoke(PAco1,'SetAtten',120.0);end% Set first 2 attenuators% invoke(PAco1,'ConnectPA5',NelData.General.TDTcommMode,1);PAco1= connect_tdt('PA5', 1);invoke(PAco1,'SetAtten',0);% invoke(PAco1,'ConnectPA5',NelData.General.TDTcommMode,2);PAco1= connect_tdt('PA5', 2);invoke(PAco1,'SetAtten',0);%invoke(PAco1,'ConnectPA5',NelData.General.TDTcommMode,3);%invoke(PAco1,'SetAtten',L1_dBatten);%invoke(PAco1,'ConnectPA5',NelData.General.TDTcommMode,4);%invoke(PAco1,'SetAtten',L2_dBatten);ADdata_V_FULL=cell(frqnum);  % Initialize Full Raw data cell array% FFT parametersStartTime_ms = 100;  % Time to start FFT windowFFT_Window_ms = ToneOn-StartTime_ms; % we will ignore the first few msFFT_Window_pts = round(FFT_Window_ms/1000*SR_Hz);first_pt = round(StartTime_ms/1000*SR_Hz);last_pt = first_pt+FFT_Window_pts-1;  % Last index for windowWindowIndices = first_pt:last_pt;  % list of indices for time windows% Run through all the stimulus frequenciesrun=1;while (run <= frqnum) && (isempty(get(h_push_stop,'Userdata'))) % check for stop here    if get(h_push_stop,'Userdata'), break; end    new_freq = 0;        %    disp(sprintf('Run #%d',run));        F1freq = F1frqlst(run);    F2freq = F2frqlst(run);    %    level_stk = zeros(1,6);        set(h_text7,'String',sprintf('F1 is %.0f Hz\nF2 is %.0f Hz',F1freq*1000,F2freq*1000),'FontSize',10);            % 2022 AS/MH: re-doing to pass    %     f1 to Rselect  (L1 to PA4)    %     f2 to Lselect  (L2 to PA3)    %    Set attenuatators    %     invoke(PAco1,'ConnectPA5',NelData.General.TDTcommMode,3);    PAco1= connect_tdt('PA5', 3);    invoke(PAco1,'SetAtten',L2_dBatten(run));    %     invoke(PAco1,'ConnectPA5',NelData.General.TDTcommMode,4);    PAco1= connect_tdt('PA5', 4);    invoke(PAco1,'SetAtten',L1_dBatten(run));        % Set Rp2 frequency parameters    invoke(RPco2,'SetTagVal','F1_Hz',F1freq*1000);    invoke(RPco2,'SetTagVal','F2_Hz',F2freq*1000);        ADdata_V_FULL{run}=zeros(Nreps,ADdur_pts);            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    % Use this block if Matlab is initiating each rep %    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    % Run several repetitions    for REPindex=1:Nreps        if  (~isempty(get(h_push_stop,'Userdata'))) % check for stop here            break;        end        %       disp(sprintf('... Rep #%d',REPindex));                invoke(RPco2,'SoftTrg',2); % start circuit                DataIndex = invoke(RPco2, 'GetTagVal', 'Index'); % read the value of index                % read the value of index until the buffer is full        while DataIndex < ADdur_pts % Assuming Fs=24414.0625            DataIndex = invoke(RPco2, 'GetTagVal', 'Index');        end                ADdata_V_FULL{run}(REPindex,:) = invoke(RPco2,'ReadTagV','Data OUT',0,ADdur_pts); % read in buffer data                neltimer(tspan);  % This serves as a rough control of the inter-stimulus interval    end    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%            %    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    %    % Use this block if the circuit is initiating each rep %    %    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    %    invoke(RPco2,'SoftTrg',2); % start circuit    %    DataIndex = invoke(RPco2, 'GetTagVal', 'Index'); % read the value of index    %    while DataIndex < ADdur_pts*Nreps % Assuming Fs=24414.0625    %       DataIndex = invoke(RPco2, 'GetTagVal', 'Index');    %    end    %    temp = invoke(RPco2,'ReadTagV','Data OUT',0,ADdur_pts*Nreps); % read in buffer data    %    ADdata_V_FULL{run} = reshape(temp',Nreps,ADdur_pts); % put each rep in its own row    %    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                %% DP frequency and search window    DP_Freq_Hz = (2*F1freq-F2freq)*1000;  %expected 2f1-f2 frequency    SEARCHfactDP=0.05;    DP_Search_Win = DP_Freq_Hz*SEARCHfactDP;  %window to look in for 2f1-f2 peak        % Data Averaging    ADdataMATRIX_V=ADdata_V_FULL{run};    if Nreps>1        ADdata_V = mean(ADdataMATRIX_V(1:Nreps,:)); %% AVG all reps    else        ADdata_V = ADdataMATRIX_V(1,:); %% Take 1st rep only    end    hanwin = blackman(FFT_Window_pts, 'symmetric')';% blackman window    ADdataWINDOW_V=(ADdata_V(WindowIndices)-mean(ADdata_V(WindowIndices))).*hanwin;        % Calculate DPOAE    [Amp, Phase, FreqV_Hz] = FourierTransform(ADdataWINDOW_V, SR_Hz);% compute FFT    clear SNR    SNRcriterion = 8;    SearchDPIndices = find(FreqV_Hz < DP_Freq_Hz + DP_Search_Win & FreqV_Hz > DP_Freq_Hz - DP_Search_Win);    [DPAmp_Volts, TEMPindex] = max(Amp(SearchDPIndices));    DPFreq_Hz=FreqV_Hz(SearchDPIndices(TEMPindex));    [RMS_Noise,LOWsideINDs,HIGHsideINDs] = EstimateNoise(Amp, FreqV_Hz, DPFreq_Hz, F1freq*1000, SearchDPIndices);    shortFFToffset_dB=0;%-20*log10(10^(L1_dBSPL/20)/(2*length(FreqV_Hz)));    SNR = CalcSNR(DPAmp_Volts, RMS_Noise, shortFFToffset_dB);    if SNR < SNRcriterion        DPAmp_Volts = NaN;    end            dpoaedata(run,:) = [F1freq*1000,F2freq*1000,DPFreq_Hz, 20*log10((DPAmp_Volts/1e-6))-MicGain+shortFFToffset_dB];        dpoaespectra(run,:) = 20*log10((Amp/1e-6))-MicGain+shortFFToffset_dB;        % Plot FFT    set(h_line1,'XData',dpoaedata(1:run,3),'YData',dpoaedata(1:run,4)); % dpoae amplitudes    set(h_line2,'XData',FreqV_Hz,'YData',20*log10((Amp/1e-6))-MicGain+shortFFToffset_dB); % current fft    set(h_line3,'XData',DPFreq_Hz,'YData',20*log10((DPAmp_Volts/1e-6))-MicGain+shortFFToffset_dB); % current dpoae    drawnow; pause(0.1);        set(h_push_start,'Userdata',dpoaedata);        run=run+1;end  %Step through all freqsdpoaefreqs = FreqV_Hz;if (isempty(get(h_push_stop,'UserData')))  %% Went through all freqs, i.e., finished on its own    set(h_push_stop,'Userdata','stop');endNelData.DPOAE.rc=get(h_push_stop,'Userdata');set(h_push_stop,'Userdata',[]);%% USE NelData.DPOAE.rc as a return flag%% Leave DPOAE window open when data is saved ow/ close window!%% Shut down TDT: Needed for all stop conditions (stop, savenquit, restart, abort)for atten_num = 1:4    %     invoke(PAco1,'ConnectPA5',NelData.General.TDTcommMode,atten_num);    PAco1= connect_tdt('PA5', atten_num);    invoke(PAco1,'SetAtten',120.0);endinvoke(RPco2,'Halt');invoke(RPco1,'Halt');set(h_line2,'XData',1e-10,'YData',0);set(h_push_start,'Enable','off');set(h_push_stop,'Enable','off');set(h_push_restart,'Enable','off');set(h_push_abort,'Enable','off');set(h_push_saveNquit,'Enable','off');%set(h_push_close,'Enable','off');set(h_push_params,'Enable','off');set(h_text3,'buttondownfcn','');set(h_text4,'buttondownfcn','');set(h_text5,'buttondownfcn','');set(h_text6,'buttondownfcn','');%%% Switch on end of data-collection loopswitch NelData.DPOAE.rc    case 'change_levels/freqs'        def.F2_Level={PARAMS(12) 'dB SPL' [0 120]};        def.F1_Level={PARAMS(13) 'dB SPL' [0 120]};        def.Low_Freq={PARAMS(1) 'kHz' [0.04 45]};        def.High_Freq={PARAMS(2) 'kHz' [0.04 45]};        def.NumSteps={PARAMS(1) 'steps' [2 6]};        def.NumReps={PARAMS(2) 'reps' [4 8]};                dlg_pos=[40.9600   16  122.8800   13.5000];        inp = structdlg(def, 'Change Levels/Frequency Limits',struct([]),'on',[],dlg_pos);        PARAMS(12)=inp.F2_Level;        PARAMS(13)=inp.F1_Level;        PARAMS(1)=inp.Low_Freq;        PARAMS(2)=inp.High_Freq;        PARAMS(4)=inp.NumSteps;        PARAMS(10)=inp.NumReps;        clear def inp        eval('update_dpoae_params');		% use function update_dpoae_params to rewrite the file        NelData.DPOAE.rc='restart';        return;    case 'abort'        distortion_product('close');        return;    case 'restart'        return;    case 'stop'        last_stim=run-1;                if last_stim == frqnum            %run save...all frequencies are run, ended naturally            [filename, shortfname] = current_data_file('dpoae',1);            make_dpoae_text_file;            text_str = sprintf('%s %s','Saved data file: ',shortfname);            set(h_text7,'String',text_str,'FontSize',10);            update_dpoae_params;            filename = current_data_file('dpoae',1);            %set(h_push_close,'Enable','off');            set(h_push_saveNquit,'Enable','off');         else            set(h_push_saveNquit,'Enable','on');        end                set(h_push_restart,'Enable','on');        set(h_push_abort,'Enable','on');        set(h_push_params,'Enable','on');        while isempty(get(h_push_stop,'Userdata')) % Wait for user to do something else            pause(.1)        end                set(h_ax1,'ButtonDownFcn','')        set(h_line1,'ButtonDownFcn','')        NelData.DPOAE.rc=get(h_push_stop,'Userdata');        set(h_push_stop,'Userdata',[]);                % remind user to turn of microphone        h = msgbox('Please remember to turn off the microphone');        uiwait(h);                switch NelData.DPOAE.rc            case 'abort'                distortion_product('close');                return;            case 'restart'                return;            case 'params'                h_dpoae_params = view_dpoae_params;                uiwait(h_dpoae_params);                distortion_product('start');                return;            case 'saveNquit'                set(h_push_restart,'Enable','off');                set(h_push_abort,'Enable','on');                set(h_push_saveNquit,'Enable','off');                set(h_push_params,'Enable','off');                                dlg_pos=[40.9600   1.5  122.8800   15.5000];                                % add in comment ability later...                % comment=NelData.File_Manager.unit.comment;                comment='NOTHING FOR NOW';                                [filename, shortfname] = current_data_file('dpoae',1);                make_dpoae_text_file;                text_str = sprintf('%s %s','Saved data file: ',shortfname);                set(h_text7,'String',text_str,'FontSize',10);                update_dpoae_params;                filename = current_data_file('dpoae',1);                %set(h_push_close,'Enable','on');                %uiresume;                distortion_product('close');                return;        endend% end