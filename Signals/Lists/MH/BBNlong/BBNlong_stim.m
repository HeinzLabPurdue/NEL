% Written by GE_MH 04nov2003. Modified EDY 5/10/05.
% Modified M Heinz 8/3/07

global signals_dir

Lchannel.file_list = cell(10,1);

files ={
'BBN1_P.wav',          
'BBN1_N.wav',
'BBN2_P.wav',          
'BBN2_N.wav',
'BBN3_P.wav',          
'BBN3_N.wav',
'BBN4_P.wav',          
'BBN4_N.wav',
'BBN5_P.wav',          
'BBN5_N.wav'};

ii=0;
for i=1:10
    ii=ii+1;
    Lchannel.file_list{ii} = sprintf('%sMH\\BBNlong\\%s', signals_dir,files{i});
end
