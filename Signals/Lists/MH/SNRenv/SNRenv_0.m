% Written by GE_MH 04nov2003. Modified EDY 5/10/05.
% Modified M Heinz 8/3/07

global signals_dir

files ={
'FLN_Stim0dB_SN_P.wav',
'FLN_Stim_S_N.wav',
'SSN_Stim0dB_N_N.wav',
'FLN_Stim_S_P.wav',       
'FLN_Stim0dB_N_N.wav',   
'SSN_Stim0dB_N_P.wav',   
'FLN_Stim0dB_N_P.wav',  
'SSN_Stim0dB_SN_N.wav',  
'FLN_Stim0dB_SN_N.wav',  
'SSN_Stim0dB_SN_P.wav'  
};

Lchannel.file_list = cell(length(files),1);

for i=1:length(files)
    Lchannel.file_list{i} = sprintf('%sMH\\SNRenv\\SNR_0\\%s', signals_dir,files{i});
end
