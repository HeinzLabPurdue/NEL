% Written by GE_MH 04nov2003. Modified EDY 5/10/05.
% Modified M Heinz 8/3/07

global signals_dir

files ={
'Speech.wav',          
'NSpeech.wav',
'CHSpeechFS-1.wav',     
'NCHSpeechFS-1.wav',    
'CHSpeechFS-16.wav',
'NCHSpeechFS-16.wav'};

Lchannel.file_list = cell(length(files),1);

for i=1:length(files)
    Lchannel.file_list{i} = sprintf('%sMH\\Boy_Chimera\\%s', signals_dir,files{i});
end
