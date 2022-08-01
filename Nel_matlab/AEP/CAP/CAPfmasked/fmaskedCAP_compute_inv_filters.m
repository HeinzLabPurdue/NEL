curDir= pwd;
cdd


 lpc_fName = 'fmasked_coef_lpc';
 if RunLevels_params.lpcInvFilterOnClick && ~isfile([lpc_fName '.mat'])
    %FIND LPC COEFFICIENTS
    
    invoke(RP1,'ConnectRP2',NelData.General.TDTcommMode,1);
    invoke(RP1,'ClearCOF');
    invoke(RP1,'LoadCOF',[prog_dir '\object\LPC\run_gauss_noise.rcx']);

    if (~NelData.General.RX8) 
        %assert(~NelData.General.RP2_3and4)
        invoke(RP2,'ConnectRP2',NelData.General.TDTcommMode,2);
   else  %NEL2
       %RP2 already invoked
       
       %but needs to load circuit on RP3 to bypass fir filter?
            invoke(RP3,'ClearCOF');
            invoke(RP3,'LoadCOF',[prog_dir '\object\LPC\gauss_noise_RX8.rcx']); 
            invoke(RP3,'Run');
    end
        
        
    %NEL1/2: calib in on RP2#2
    invoke(RP2,'ClearCOF');

    invoke(RP2,'LoadCOF',[prog_dir '\object\LPC\gauss_noise_right.rcx']);

    invoke(RP2,'Run');

   
    
    dur_noise_ms = 5000;  %duration noise played in ms 

     invoke(RP1,'Run');

    invoke(RP1,'SetTagVal','dur_ms',dur_noise_ms);
    invoke(RP2,'SetTagVal','dur_ms',dur_noise_ms);

    fmaskedCAP_set_attns(0, 0, Stimuli.channel,Stimuli.KHosc,RP1,RP2);


    invoke(RP2,'SoftTrg',2); %reset bufFlag if needed
    invoke(RP1,'SoftTrg',1);


    while( invoke(RP2,'GetTagVal','BufFlag') == 0)

    end
    npts=round(dur_noise_ms/1000*Stimuli.RPsamprate_Hz);
    response = invoke(RP2,'ReadTagV','ADbuf',0, npts);        

    invoke(RP1,'Halt');
    invoke(RP2,'Halt');

    if NelData.General.RX8
       invoke(RP3,'Halt');
    end
    fmaskedCAP_set_attns(120, 120, Stimuli.channel,Stimuli.KHosc,RP1,RP2);

    t=(1:npts)/Stimuli.RPsamprate_Hz;
    figure(5)
    plot(t*1000, response, 'b')
    xlabel('t (ms)')
    title('Output (probe mic)')
    

    res2 = response(10000:end-10000);

    [a,~] = lpc(res2,128);

    b_lpc = [1 a(2:end)];


    figure(6)
    freqz(b_lpc,1,2056, Stimuli.RPsamprate_Hz)
    %freqz(1,a,2056, Stimuli.RPsamprate_Hz)
    title('Inverted gain filter (LPC)')


    %Save coeffs
    b_lpc=b_lpc';
    save(lpc_fName,'b_lpc')  % save coefs
    
    
    
    %create click stimuli (wav)
    click_stim=zeros(1, 500);
    click_stim(1)=1;
    %click_stim(1:4)=1;  %80-ms pulse
    click_stim=filter(b_lpc,1,click_stim);
    RunLevels_params.click_wav_normalization_factor=1/max(abs(click_stim));
    fprintf('multiplication factor click after LPC filter: %.2f dB',20*log10(1/max(abs(click_stim))))
    click_stim=click_stim/max(abs(click_stim));
    
    
    path= [prog_dir '\stimuli\click.wav'];
    audiowrite(path, click_stim, Stimuli.RPsamprate_Hz)
 end

%% Code if we would want to use RP4 for inverse filtering
% 
% %% Connecting to RP2_4
% global COMM root_dir NelData
% object_dir = [root_dir 'calibration\object'];
% 
% COMM.handle.RP2_4= actxcontrol('RPco.x',[0 0 5 5]);
% status3 = invoke(COMM.handle.RP2_4,'ConnectRP2', NelData.General.TDTcommMode, 4);
% invoke(COMM.handle.RP2_4,'LoadCof',[object_dir '\calib_invFIR_right.rcx']);
% 
% 
% %% Run the circuit
% e1= COMM.handle.RP2_4.WriteTagV('FIR_Coefs', 0, b_lpc);
% 
% invoke(COMM.handle.RP2_4,'Run');



% Inverse filtering 1024 coeffs


invCalibCoefs_fName = 'fmasked_coef_invCalib';
%create inverse filter
if RunLevels_params.invFilterOnWavefiles && ~isfile([invCalibCoefs_fName '.mat'])
    all_Calib_files= dir('p*calib*raw*');
    all_calib_picNums= cell2mat(cellfun(@(x) getPicNum(x), {all_Calib_files.name}', 'UniformOutput', false));
    calibPicNum= max(all_calib_picNums);
   
    [b_coeffs, dBSPL_ideal]=fmaskedCAP_get_inv_calib_fir_coeff(calibPicNum);
    RunLevels_params.calibPic=calibPicNum;
    RunLevels_params.broadband_dBSPL_ideal =  dBSPL_ideal; %dBSPL_ideal  dB for broadband noise (at RMS = 1)
    fprintf('from calib file, max output should be  %.2f dB for broaband noise at RMS=1 \n', dBSPL_ideal);
    
    
    %Save coeffs
    save(invCalibCoefs_fName,'b_coeffs')  % save coefs

end
cd(curDir);