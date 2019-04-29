% Written by GE_MH 04nov2003. Modified EDY 5/10/05.
% Modified M Heinz 8/3/07

global signals_dir

Lchannel.file_list = cell(14,1);

files ={
'Speech.wav',          
'NSpeech.wav',
'CHSpeechFS-1.wav',     
'NCHSpeechFS-1.wav',    
'CHSpeechFS-16.wav',
'NCHSpeechFS-16.wav',  
'CHSpeechENV-1.wav',
'NCHSpeechENV-1.wav',
'CHSpeechENV-16.wav',
'NCHSpeechENV-16.wav',
'CFtone.wav',
'NCFtone.wav',
'CFtone.wav',
'NCFtone.wav'};

for i=1:14
    Lchannel.file_list{i} = sprintf('%sSK\\Boy_Chimera\\%s', signals_dir,files{i});
end
