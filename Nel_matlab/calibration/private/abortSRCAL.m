%script to run when aborting SRCAL

global NumPreAttens COMM

prog = 'SRCAL';

PAco1=actxcontrol('PA5.x',[0 0 1 1]);
for dev = 1:2+NumPreAttens
    invoke(PAco1,'Connect',4,dev);
    invoke(PAco1,'SetAtten',120.0);
end

if ~isempty(instrfind)
    fprintf(COMM.handle.SR530,'%s\n','G24') %sensitivity 500 mV
    fprintf(COMM.handle.SR530,'%s\n','I2')  %activate panel inputs
    fclose(COMM.handle.SR530)
    delete(COMM.handle.SR530)
    clear COMM.handle.SR530
end
