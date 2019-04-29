% Written by GE_MH 04nov2003. Modified EDY 5/10/05.
% Modified M Heinz 8/3/07

global signals_dir


files ={
'BBN_A.wav',          
'BBN_AN.wav',          
'BBN_B.wav',          
'BBN_BN.wav',
'BBN_A.wav',          
'BBN_AN.wav'};

Lchannel.file_list = cell(length(files),1);

ii=0;
for i=1:length(files)
    ii=ii+1;
    Lchannel.file_list{ii} = sprintf('%sMH\\BBN_SCCXCC\\%s', signals_dir,files{i});
end
