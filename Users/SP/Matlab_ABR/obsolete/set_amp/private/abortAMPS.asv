%script to run when aborting SetAmp

global NumPreAttens

prog = 'SetAmp';

PAco1=actxcontrol('PA5.x',[0 0 1 1]);
for dev = 1:2+NumPreAttens
    invoke(PAco1,'ConnectPA5','GB',dev);
    invoke(PAco1,'SetAtten',120.0);
end
