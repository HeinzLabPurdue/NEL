function updateTDT

global root_dir Stimuli COMM

if Stimuli.freq_hz
    COMM.RCO = 'tone.rco';
else
    COMM.RCO = 'click.rco';
end
invoke(COMM.RP2_1,'LoadCOFsf',fullfile(root_dir,'signal_averager','object',COMM.RCO),5);

asr1 = 0;
tryit = 0;

while asr1 <= 0
    asr1 = invoke(COMM.RP2_1,'GetSFreq');
    tryit = tryit + 1;
    if tryit == 10
        errordlg('Couldn''t read sample rate of first RP2','TDT Error!');
        return
    end
end

COMM.asr1 = asr1;


COMM.RP2_2=actxcontrol('RPco.x',[0 0 1 1]);
invoke(COMM.RP2_2,'ConnectRP2','GB',2);
invoke(COMM.RP2_2,'ClearCOF');
invoke(COMM.RP2_2,'LoadCOFsf',fullfile(root_dir,'signal_averager','object','averager.rco'),1);

asr2 = 0;
tryit = 0;

while asr2 <= 0
    asr2 = invoke(COMM.RP2_2,'GetSFreq');
    tryit = tryit + 1;
    if tryit == 10
        errordlg('Couldn''t read sample rate of second RP2','TDT Error!');
        return
    end
end

COMM.asr2 = asr2;

invoke(COMM.PA5_1,'SetAtten',Stimuli.db_atten);

if Stimuli.freq_hz
    invoke(COMM.RP2_1,'SetTagVal','freq',Stimuli.freq_hz);
end
invoke(COMM.RP2_1,'Run');
