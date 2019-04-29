function [index,m,curNbuf,ch1,doneflag]=test_mycirc

reps=5;
buff_data=[1:25000]/25000;
buff_size=length(buff_data);

fig = figure(1);
set(fig,'Visible','off');

RP2 = actxcontrol('RPco.x',[0 0 5 5],fig);
rc = invoke(RP2,'ConnectRP2','USB',2);
invoke(RP2,'LoadCof','Object\continualstim_test.rco');

rc = invoke(RP2, 'SetTagVal', 'buff_size', buff_size);
rc = invoke(RP2, 'SetTagVal', 'size_x_reps', reps*buff_size);
rc = invoke(RP2, 'WriteTagV', 'buff_data', 0, buff_data);

invoke(RP2,'Run');

if ~rc
   disp('Summat didn''t work');
   return;
end
  
invoke(RP2, 'SoftTrg',1);
flaggy=1; index=[];
while flaggy
   index=[index,invoke(RP2,'GetTagVal','CurN')];
   if index(end)>=reps
      flaggy=0;
   end
end
m=invoke(RP2,'ReadTagV','m',0,300000);
curNbuf=invoke(RP2,'ReadTagV','curNbuff',0,300000);
ch1=invoke(RP2,'ReadTagV','ch1',0,300000);
doneflag=invoke(RP2,'ReadTagV','DoneFlagBuff',0,300000);
invoke(RP2,'Halt');

return