% Written by GE_MH 04nov2003. Modified EDY 5/10/05.
% Modified M Heinz 8/3/07

global signals_dir

Lchannel.file_list = cell(1,1);

files ={
    'BBN.wav'};

% ii=0;
% for i=1:2
%     ii=ii+1;
Lchannel.file_list{1} = sprintf('%sSK\\BBNatCF\\%s', signals_dir,files{1});
% end
