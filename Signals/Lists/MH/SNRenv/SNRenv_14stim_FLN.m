% Written by GE_MH 04nov2003. Modified EDY 5/10/05.
% Modified M Heinz 8/3/07

global signals_dir

files ={
'Stim-5dB_SN_P.wav',
'Stim-5dB_SN_N.wav',  
'Stim-5dB_N_P.wav',    
'Stim-5dB_N_N.wav',    
'Stim_S_P.wav',       
'Stim_S_N.wav',       
'Stim-10dB_N_P.wav',   
'Stim-10dB_N_N.wav',   
'Stim0dB_N_P.wav',    
'Stim0dB_N_N.wav',    
'Stim-10dB_SN_P.wav',  
'Stim-10dB_SN_N.wav',  
'Stim0dB_SN_P.wav',   
'Stim0dB_SN_N.wav'   
};

Lchannel.file_list = cell(length(files),1);

for i=1:length(files)
    Lchannel.file_list{i} = sprintf('%sMH\\SNRenv\\stimSetFluctuating\\%s', signals_dir,files{i});
end
