%Search Instruction Block

% Dec 15 2017 MHeinz- search at 70 dB SPL (avged over 1-4 kHz)
cdd
dlist=dir('*calib*');
CalibPICnum=getpicNum(dlist(end).name);  % find LAST calib picture
CalibData=loadpic(CalibPICnum)

lowFREQ=1;
highFREQ=4;
OALsearch_dBSPL=70;  % always search at 70 dB SPL

ind_1k=dsearchn(CalibData.CalibData(:,1),lowFREQ); % find closest to 1 khz
ind_4k=dsearchn(CalibData.CalibData(:,1),highFREQ); % find closest to 4 khz
AVGcalib_14=mean(CalibData.CalibData(ind_1k:ind_4k,2));

SEARCHatten = AVGcalib_14-OALsearch_dBSPL;

disp(sprintf('***SEARCH (at %.f dB atten) using CalibPIC number: %d \n   to search at %.f dB SPL OAL based on %.f to %.f kHz', ...
    SEARCHatten,CalibPICnum,OALsearch_dBSPL,lowFREQ,highFREQ))
%warn - uie CALIB

Stimuli = struct('freq_hz',5000, ...
    'atten',    round(SEARCHatten), ...
    'duration', 50, ...
    'period',  250, ...
    'channel',   3, ...
    'KHosc',     0, ...
    'fmult',    10, ...
    'spike_channel', 1);   % added by GE 17Jan2003.

