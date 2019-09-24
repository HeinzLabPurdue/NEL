set(h_push_start,'Enable','off');
set(h_push_noise,'Enable','on');
set(h_push_stop,'Enable','on');
set(h_push_stop,'Userdata',[]);
set(h_push_close,'Enable','off');

ear = get(h_push_left,'userdata');
left  = 1;
right = 2;

config(1) = struct('atten',[1 0],'sel',[0 7 2 7],'conn',[2 0]); %left ear select code
config(2) = struct('atten',[0 1],'sel',[7 4 7 2],'conn',[0 1]); %right ear select code
config(3) = struct('atten',[1 1],'sel',[0 4 2 2],'conn',[2 1]); %both ears selected

KHosc = get(h_push_khite,'Userdata');

RPco1=actxcontrol('RPco.x',[0 0 1 1]);
invoke(RPco1,'Connect',4,1);
invoke(RPco1,'LoadCof','d:\Matlab_user\search\object\search_left.rco');
invoke(RPco1,'SetTagVal','Select_L',config(ear).sel(left+KHosc));
invoke(RPco1,'SetTagVal','Connect_L',config(ear).conn(left));

if get(h_push_noise,'Userdata')==0,
   invoke(RPco1,'SetTagVal','freq',PARAMS(2));
   invoke(RPco1,'SetTagVal','ToneRun',1);
   invoke(RPco1,'SetTagVal','NoisRun',0);
elseif get(h_push_noise,'Userdata')==1,
   invoke(RPco1,'SetTagVal','NoisRun',1);
   invoke(RPco1,'SetTagVal','ToneRun',0);
else
   invoke(RPco1,'SetTagVal','NoisRun',0);
   invoke(RPco1,'SetTagVal','ToneRun',0);
end

invoke(RPco1,'SetTagVal','StmOn',PARAMS(3));
invoke(RPco1,'SetTagVal','StmOff',PARAMS(4)-PARAMS(3));
invoke(RPco1,'Run');

RPco2=actxcontrol('RPco.x',[0 0 1 1]);
invoke(RPco2,'Connect',4,2);
invoke(RPco2,'LoadCof','d:\Matlab_user\search\object\search_right');
invoke(RPco2,'SetTagVal','Select_R',config(ear).sel(right+KHosc));
invoke(RPco2,'SetTagVal','Connect_R',config(ear).conn(right));
invoke(RPco2,'Run');

PAco1=actxcontrol('PA5.x',[0 0 1 1]);
if config(ear).atten(left),
   invoke(PAco1,'Connect',4,1);
   invoke(PAco1,'SetAtten',0);
   invoke(PAco1,'Connect',4,3);
   invoke(PAco1,'SetAtten',PARAMS(1));
else
   invoke(PAco1,'Connect',4,1);
   invoke(PAco1,'SetAtten',120.0);
   invoke(PAco1,'Connect',4,3);
   invoke(PAco1,'SetAtten',120.0);
end
if config(ear).atten(right),
   invoke(PAco1,'Connect',4,2);
   invoke(PAco1,'SetAtten',0);
   invoke(PAco1,'Connect',4,4);
   invoke(PAco1,'SetAtten',PARAMS(1));
else
   invoke(PAco1,'Connect',4,2);
   invoke(PAco1,'SetAtten',120.0);
   invoke(PAco1,'Connect',4,4);
   invoke(PAco1,'SetAtten',120.0);
end

while ~length(get(h_push_stop,'Userdata')),
   h_line1 = plot(-5,-5,'*');
   set(h_line1,'MarkerSize',2,'Color','g');
   
   msdl(1,1);
   
   invoke(RPco1,'SoftTrg',1);
   tspan = PARAMS(4)/1000;
   seq = 1;
   prev_seq = 1;
   while (seq < 100)
      [spk seq] = msdl(2);
      if (~isempty(spk{1}))
         set(h_line1,'xdata',spk{1}(:,2),'ydata',spk{1}(:,1));
      end
      drawnow;
      
      if (prev_seq ~= seq)
         status = msdl(3);
         if (status(1) < 0)
            nelwarn(['ERROR from channel 1:' char([13 10]) nidaq_error_code(status(1))]);
         end
         prev_seq = seq;
      end
      
      if get(h_push_stop,'Userdata'),
         break;
      elseif get(h_push_10x,'Userdata'),
         new_stim = get(h_push_10x,'Userdata');
         set(h_push_10x,'Userdata',[]);
         switch new_stim;
         case 1
            ear = get(h_push_left,'Userdata');               
            if config(ear).atten(left),
               invoke(PAco1,'Connect',4,3);
               invoke(PAco1,'SetAtten',PARAMS(1));
            end
            if config(ear).atten(right),
               invoke(PAco1,'Connect',4,4);
               invoke(PAco1,'SetAtten',PARAMS(1));
            end
         case 2
            invoke(RPco1,'SetTagVal','freq',PARAMS(2));
         case 3
            invoke(RPco1,'SetTagVal','StmOn',PARAMS(3));
            invoke(RPco1,'SetTagVal','StmOff',PARAMS(4)-PARAMS(3));
            set(h_ax1,'XLim',[0 PARAMS(4)/1000]);
            break   
         case 4
            if get(h_push_noise,'Userdata')==0,
               invoke(RPco1,'SetTagVal','freq',PARAMS(2));
               invoke(RPco1,'SetTagVal','ToneRun',1);
               invoke(RPco1,'SetTagVal','NoisRun',0);
            elseif get(h_push_noise,'Userdata')==1,
               invoke(RPco1,'SetTagVal','NoisRun',1);
               invoke(RPco1,'SetTagVal','ToneRun',0);
            else
               invoke(RPco1,'SetTagVal','NoisRun',0);
               invoke(RPco1,'SetTagVal','ToneRun',0);
            end
            KHosc = get(h_push_khite,'Userdata');
            invoke(RPco1,'SetTagVal','Select_L',config(ear).sel(left+KHosc));
            invoke(RPco2,'SetTagVal','Select_R',config(ear).sel(right+KHosc));
            break
         case 5
            ear = get(h_push_left,'Userdata');               
            if config(ear).atten(left),
               invoke(PAco1,'Connect',4,1);
               invoke(PAco1,'SetAtten',0);
               invoke(PAco1,'Connect',4,3);
               invoke(PAco1,'SetAtten',PARAMS(1));
            else
               invoke(PAco1,'Connect',4,1);
               invoke(PAco1,'SetAtten',120.0);
               invoke(PAco1,'Connect',4,3);
               invoke(PAco1,'SetAtten',120.0);
            end
            if config(ear).atten(right),
               invoke(PAco1,'Connect',4,2);
               invoke(PAco1,'SetAtten',0);
               invoke(PAco1,'Connect',4,4);
               invoke(PAco1,'SetAtten',PARAMS(1));
            else
               invoke(PAco1,'Connect',4,2);
               invoke(PAco1,'SetAtten',120.0);
               invoke(PAco1,'Connect',4,4);
               invoke(PAco1,'SetAtten',120.0);
            end
            
            KHosc = get(h_push_khite,'Userdata');
            invoke(RPco1,'SetTagVal','Select_L',config(ear).sel(left+KHosc));
            invoke(RPco1,'SetTagVal','Connect_L',config(ear).conn(left));
            invoke(RPco2,'SetTagVal','Select_R',config(ear).sel(right+KHosc));
            invoke(RPco2,'SetTagVal','Connect_R',config(ear).conn(right));
            break
         end
      end
   end
  
   delete(h_line1);
end

msdl(0); % Reset

for atten_num = 1:4,
   invoke(PAco1,'Connect',4,atten_num);
   invoke(PAco1,'SetAtten',120.0);
end

invoke(RPco1,'Halt');
invoke(RPco2,'Halt');

set(h_push_start,'Enable','on');
set(h_push_stop,'Enable','off');
set(h_push_close,'Enable','on');

