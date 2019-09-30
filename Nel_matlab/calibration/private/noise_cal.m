frqlo = 2;
frqhi = 40;
frqcal = 16;
nmic = '168';
DataFile = 'calib_p121.m';

PAco1=actxcontrol('PA5.x',[0 0 1 1]);
invoke(PAco1, 'ConnectPA5', NelData.General.TDTcommMode, 1);
invoke(PAco1,'SetAtten',0);

RPco1=actxcontrol('RPco.x',[0 0 1 1]);
invoke(RPco1, 'ConnectPA5', NelData.General.TDTcommMode, 1);
invoke(RPco1,'LoadCof','C:\matlab_user\srcal_232\object\tone_DAC.rco');
invoke(RPco1,'Run');
invoke(RPco1,'SoftTrg',1);

pause(2);

npts = invoke(RPco1,'GetTagVal','index');
dac = invoke(RPco1,'ReadTagV','DAC',0,npts);

tone = dac - mean(dac);

j = 5000:length(tone);
zcross = find(tone(j-1)<=0 & tone(j)>=0);

npers = 0;
magSum = 0;
for k = 2:length(zcross)
    wave=tone(zcross(k-1):zcross(k));
    magSum = magSum + max(wave)-min(wave);
    npers = npers + 1;
end

v16k = magSum/npers*0.3535;

RPco1=actxcontrol('RPco.x',[0 0 1 1]);
invoke(RPco1, 'ConnectPA5', NelData.General.TDTcommMode, 1);
invoke(RPco1,'LoadCof','C:\matlab_user\srcal_232\object\noise_DAC.rco');
invoke(RPco1,'Run');
invoke(RPco1,'SoftTrg',1);

pause(5);

npts = invoke(RPco1,'GetTagVal','index');
src = invoke(RPco1,'ReadTagV','source',0,npts);
dac = invoke(RPco1,'ReadTagV','DAC',0,npts);

invoke(RPco1,'Halt');
invoke(PAco1,'SetAtten',120);

[Txy,f]=tfe(src,dac,1024,97656.3,1024,512,'none');
FrqRange = find(f>=frqlo*1000 & f<=frqhi*1000);

dbSPL = 20*log10(abs(Txy(FrqRange)));
freq  = f(FrqRange)/1000;

data_file = strcat('mic',nmic,'.m');
command_line = sprintf('%s%s%c','[mic]=',strrep(lower(data_file),'.m',''),';');
eval(command_line);
FrqLoc = find(mic.CalData(:,1) <= frqcal, 1, 'last' );
dbSPL16k = 20 * log10(v16k) - mic.dBV;
CalLoc = find(freq >=frqcal, 1 );
mag16k = dbSPL(CalLoc);

cal = dbSPL16k - mag16k;

for index = 1:length(freq)
    FrqLoc = find(mic.CalData(:,1) <= freq(index), 1, 'last' );
    dbSPL(index) = dbSPL(index) + mic.CalData(FrqLoc,2) + cal;
end
semilogx(freq,dbSPL,'b');

hold on;

command_line = sprintf('%s%s%c','[x]=',strrep(lower(DataFile),'.m',''),';');
eval(command_line);
semilogx(x.CalibData(:,1),x.CalibData(:,2),'r');

lowY = floor(min(dbSPL)/20)*20;
upY  =  ceil(max(dbSPL)/20)*20;
set(gca,'xlim',[frqlo frqhi],'ylim',[lowY upY]);
