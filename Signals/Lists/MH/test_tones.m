% Written by MH 24oct2003.

global signals_dir

Nfiles = 10;
Lchannel.file_list = cell(Nfiles,1);
for ifiles = 1:Nfiles
   Lchannel.file_list{ifiles} = sprintf('%sMH\\test_tone%d.wav', signals_dir, ifiles);
end

Lchannel.sort = 0;
Lchannel.shift = 0;
