function [error] = lockin_config

global COMM FIG

error = 0;

device = instrfind;
if isempty(device) & ~length(get(FIG.push.stop,'userdata'))
    COMM.handle.SR530 = serial('COM1','BaudRate',19200,'Parity','none','DataBits',8,'StopBits',1,'Terminator','CR');
    
    fopen(COMM.handle.SR530);
    neltimer(.5);
    
    fprintf(COMM.handle.SR530,'%s\n','Z')   %reset
    neltimer(.5);
    
    fprintf(COMM.handle.SR530,'%s\n','W0')      %lockout panel inputs
    fprintf(COMM.handle.SR530,'%s\n','W')
    resp = fscanf(COMM.handle.SR530,'%d');
    if resp ~=0, error=1; end
    
    if ~error
        fprintf(COMM.handle.SR530,'%s\n','I2')      %lockout panel inputs
        fprintf(COMM.handle.SR530,'%s\n','I')
        resp = fscanf(COMM.handle.SR530,'%d');
        if resp ~=2, error=1; end
    end
    
    if ~error
        fprintf(COMM.handle.SR530,'%s\n','S0')      % analog meter in XY mode
        fprintf(COMM.handle.SR530,'%s\n','S')
        resp = fscanf(COMM.handle.SR530,'%d');
        if resp ~=0, error=1; end
    end
    
    if ~error
        fprintf(COMM.handle.SR530,'%s\n','T1,4')   % pre-time constant is 30 mS
        fprintf(COMM.handle.SR530,'%s\n','T1')
        resp = fscanf(COMM.handle.SR530,'%d');
        if resp ~=4, error=1; end
    end
    
    if ~error
        fprintf(COMM.handle.SR530,'%s\n','T2,1')   % post-time constant is 0.1 S
        fprintf(COMM.handle.SR530,'%s\n','T2')
        resp = fscanf(COMM.handle.SR530,'%d');
        if resp ~=1, error=1; end
    end
    
    if ~error
        fprintf(COMM.handle.SR530,'%s\n','R1')     % reference input symmetric
        fprintf(COMM.handle.SR530,'%s\n','R')
        resp = fscanf(COMM.handle.SR530,'%d');
        if resp ~=1, error=1; end
    end
    
    if ~error
        fprintf(COMM.handle.SR530,'%s\n','G24')     % sensitivity 500mV
        fprintf(COMM.handle.SR530,'%s\n','G')
        resp = fscanf(COMM.handle.SR530,'%d');
        if resp ~=24, error=1; end
    end
    
    if error,
        set(FIG.ax2.ProgMess,'String','CONFIG: Error initializing lock-in!');
    end
    
else
    error = 1;
    set(FIG.ax2.ProgMess,'String','CONFIG: Error opening lock-in!');
end
