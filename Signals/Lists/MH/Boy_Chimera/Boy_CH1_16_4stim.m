% Written by GE_MH 04nov2003. Modified EDY 5/10/05.
% Modified M Heinz 8/3/07

global signals_dir

files ={
'CHSpeechENV-1.wav',
'NCHSpeechENV-1.wav',
'CHSpeechENV-16.wav',
'NCHSpeechENV-16.wav'};

Lchannel.file_list = cell(length(files),1);

ii=0;
for i=1:length(files)
    ii=ii+1;
    Lchannel.file_list{ii} = sprintf('%sMH\\Boy_Chimera\\%s', signals_dir,files{i});
end
