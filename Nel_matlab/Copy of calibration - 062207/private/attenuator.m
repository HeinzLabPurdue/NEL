function attenuator(num,db);
%Call as attenuator(num,dB)
%  num = device ID number
%  dB  = attenuation setting

PAco1=actxcontrol('PA5.x',[0 0 1 1]);
invoke(PAco1,'Connect',4,num);
invoke(PAco1,'SetAtten',db);
