function loadTDT

global root_dir Stimuli COMM

COMM = struct('PA5_1',[],'PA5_2',[],'RP2_1',[],'RP2_2',[],'asr1',0,'asr2',0,'RCO',[]);

COMM.PA5_1 = actxcontrol('PA5.x',[0 0 1 1]);
invoke(COMM.PA5_1,'ConnectPA5','GB',1);
invoke(COMM.PA5_1,'SetAtten',120);

COMM.RP2_1=actxcontrol('RPco.x',[0 0 1 1]);
invoke(COMM.RP2_1,'ConnectRP2','GB',1);
invoke(COMM.RP2_1,'ClearCOF');
