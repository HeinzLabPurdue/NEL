% Written by MH 24oct2003.

global signals_dir

Nfiles = 100;
Lchannel.file_list = cell(Nfiles,1);
for ifiles = 1:Nfiles
   Lchannel.file_list{ifiles} = sprintf('%sMH\\ramp300msec_100k.wav', signals_dir);
end

Lchannel.sort = 0;
Lchannel.shift = 0;
