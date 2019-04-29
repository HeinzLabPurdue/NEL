function [error] = make_tone

global object_dir COMM FIG Stimuli

error = 0;

if Stimuli.ear == 1 %left ear
   COMM.handle.RP2_1 = actxcontrol('RPco.x',[0 0 5 5]);
   status1 = invoke(COMM.handle.RP2_1,'Connect',4,1);
   invoke(COMM.handle.RP2_1,'LoadCof',[object_dir '\make_tone_left.rco']);
   invoke(COMM.handle.RP2_1,'SetTagVal','Select',160);
   invoke(COMM.handle.RP2_1,'Run');
   
   COMM.handle.RP2_2 = actxcontrol('RPco.x',[0 0 5 5]);
   status2 = invoke(COMM.handle.RP2_2,'Connect',4,2);
   invoke(COMM.handle.RP2_2,'LoadCof',[object_dir '\make_tone_right_PU.rco']);
   invoke(COMM.handle.RP2_2,'SetTagVal','Select',56);
   invoke(COMM.handle.RP2_2,'Run');
else
%    COMM.handle.RP2_1 = actxcontrol('RPco.x',[0 0 5 5]);
%    status1 = invoke(COMM.handle.RP2_1,'Connect',4,2);
%    invoke(COMM.handle.RP2_1,'LoadCof',[object_dir '\make_tone_left.rco']);
%    invoke(COMM.handle.RP2_1,'SetTagVal','Select',160);
%    invoke(COMM.handle.RP2_1,'Run');
%    
%    COMM.handle.RP2_2 = actxcontrol('RPco.x',[0 0 5 5]);
%    status2 = invoke(COMM.handle.RP2_2,'Connect',4,1);
%    invoke(COMM.handle.RP2_2,'LoadCof',[object_dir '\make_tone_right_PU.rco']);
%    invoke(COMM.handle.RP2_2,'SetTagVal','Select',4);
%    invoke(COMM.handle.RP2_2,'Run');
   
   COMM.handle.RP2_1 = actxcontrol('RPco.x',[0 0 5 5]);
   status1 = invoke(COMM.handle.RP2_1,'Connect',4,1);
   invoke(COMM.handle.RP2_1,'LoadCof',[object_dir '\make_tone_left.rco']);
   invoke(COMM.handle.RP2_1,'SetTagVal','Select',56);
   invoke(COMM.handle.RP2_1,'Run');
   
   COMM.handle.RP2_2 = actxcontrol('RPco.x',[0 0 5 5]);
   status2 = invoke(COMM.handle.RP2_2,'Connect',4,2);
   invoke(COMM.handle.RP2_2,'LoadCof',[object_dir '\make_tone_right_PU.rco']);
   invoke(COMM.handle.RP2_2,'SetTagVal','Select',64);
   invoke(COMM.handle.RP2_2,'Run');
end
if ~status1 | ~status2,
   set(FIG.ax2.ProgMess,'String','TONE: Not communicating with TDT system!');
   error = 1;
end
