function zBusReset()

% function to reset the Hardware programatically inseated of running the 

%   zBus monitor. A reset is needed to eliminate any DC offset voltages 

%   after a power cycle of the TDT equipment.  TDT acknowledges this is a 

%   problem.

global TDT_interface

f = figure('position',[1 1 300 300]);
zBUS = actxcontrol('ZBUS.x',[1 1 1 1], f);
if zBUS.ConnectZBUS(TDT_interface) %'GB'
    e = 'connected to zBUS';
    disp(e)
    if zBUS.HardwareReset(1)
        e = 'ERROR:  zBUS Hardware Reset unsuccessful!  please run zBUS monitor, reboot system and perform transfer test.';
    else
        e = 'zBUS Hardware Reset successful.';
    end
else
    e = 'Unable to connect to zBUS';
end
disp(e)
zBUS.delete;
delete(f);
clear f;
