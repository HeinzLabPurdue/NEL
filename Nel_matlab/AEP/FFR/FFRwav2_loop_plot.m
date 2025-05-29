% SP (8 May, 2017)--> changed to function

function [FIG, FFR_Gating, Display]=FFRwav2_loop_plot(FIG,Display,Stimuli,interface_type)

fName=Stimuli.list;
fName2=Stimuli.list2;  % AF/MH

gray_dark=[1 1 1];
gray_light=[1 1 1];

%% Calibration
%INV CALIB WILL ALWAYS BE RUN!
FIG.statText.calibLabel = uicontrol(FIG.handle, 'callback', '', 'style', 'text','Units','normalized', 'position', [.06 .38 .2 .03], 'string', 'Sorry! You MUST use inv calib!','fontsize',12,'BackgroundColor','w','FontWeight','Bold');
FIG.radio.invCalib = uicontrol(FIG.handle,'callback','FFRwav2(''invCalib'');','style','radio','Enable','off','Units','normalized','position',[.125 .355 .08 .03],'string','invCalib','fontsize',12,'BackgroundColor','w','value',1); %added by KH 06Jan2012

%% Fast/Slow
FIG.radio.fast   = uicontrol(FIG.handle,'callback','FFRwav2(''fast'');','style','radio','Enable','on','Units','normalized','position',[.27 .38 .08 .03],'string','Fast','fontsize',12,'BackgroundColor','w','value',1);
FIG.radio.slow   = uicontrol(FIG.handle,'callback','FFRwav2(''slow'');','style','radio','Enable','on','Units','normalized','position',[.27 .35 .08 .03],'string','Slow','fontsize',12,'BackgroundColor','w','value',0);

%% Stimulus menu
FIG.popup.siglabel = uicontrol(FIG.handle, 'callback', '', 'style', 'text','Units','normalized', 'position', [.35 .22 .05 .04], 'string', 'Stimulus 1:','fontsize',12,'BackgroundColor','w','FontWeight','Bold');
FIG.popup.stims = uicontrol(FIG.handle,'callback', 'FFRwav2(''update_stim'',''newStim'');','style','popup','Units','normalized','Userdata',Stimuli.filename,'position',[.43 .23 .4 .04],'string',{fName.name},'fontsize',12);
FIG.push.prev_stim = uicontrol(FIG.handle,'callback','FFRwav2(''update_stim'',''prevStim'');','style','pushbutton','Units','normalized','position',[.4 .23 .03 .04],'string','<<','fontsize',12,'fontangle','normal','fontweight','normal');
FIG.push.next_stim = uicontrol(FIG.handle,'callback','FFRwav2(''update_stim'',''nextStim'');','style','pushbutton','Units','normalized','position',[.83 .23 .03 .04],'string','>>','fontsize',12,'fontangle','normal','fontweight','normal');

%% Stimulus2 menu
FIG.popup2.siglabel = uicontrol(FIG.handle, 'callback', '', 'style', 'text','Units','normalized', 'position', [.35 .11 .05 .04], 'string', 'Stimulus 2:','fontsize',12,'BackgroundColor','w','FontWeight','Bold');
FIG.popup2.stims = uicontrol(FIG.handle,'callback', 'FFRwav2(''update_stim'',''newStim2'');','style','popup','Units','normalized','Userdata',Stimuli.filename2,'position',[.43 .12 .4 .04],'string',{fName2.name},'fontsize',12,'Value',find(strcmp({fName.name},Stimuli.filename2)));
FIG.push2.prev_stim2 = uicontrol(FIG.handle,'callback','FFRwav2(''update_stim'',''prevStim2'');','style','pushbutton','Units','normalized','position',[.4 .12 .03 .04],'string','<<','fontsize',12,'fontangle','normal','fontweight','normal');
FIG.push2.next_stim2 = uicontrol(FIG.handle,'callback','FFRwav2(''update_stim'',''nextStim2'');','style','pushbutton','Units','normalized','position',[.83 .12 .03 .04],'string','>>','fontsize',12,'fontangle','normal','fontweight','normal');

%% Intensity buttongroup
FIG.bg.spl.parent= uibuttongroup('visible','on','Position',[.87 .23 .1 .04],'BackgroundColor',gray_light);
FIG.bg.spl.dB65=uicontrol('parent',FIG.bg.spl.parent,'style','radio','Enable','on','Units','normalized','position',[0 0 .5 1],'string','65dB','fontsize',12,'BackgroundColor',gray_light,'value',0);
FIG.bg.spl.dB80=uicontrol('parent',FIG.bg.spl.parent,'style','radio','Enable','on','Units','normalized','position',[.5 0 .5 1],'string','80dB','fontsize',12,'BackgroundColor',gray_light,'value',1);
% set(FIG.bg.spl.parent, 'SelectedObject', FIG.bg.spl.dB65);
set(FIG.bg.spl.parent,'SelectionChangeFcn','FFRwav2(''update_stim'',''spl'');');
%% Intensity buttongroup 2
FIG.bg2.spl.parent= uibuttongroup('visible','on','Position',[.87 .12 .1 .04],'BackgroundColor',gray_light);
FIG.bg2.spl.dB65=uicontrol('parent',FIG.bg2.spl.parent,'style','radio','Enable','on','Units','normalized','position',[0 0 .5 1],'string','65dB','fontsize',12,'BackgroundColor',gray_light,'value',1);
FIG.bg2.spl.dB80=uicontrol('parent',FIG.bg2.spl.parent,'style','radio','Enable','on','Units','normalized','position',[.5 0 .5 1],'string','80dB','fontsize',12,'BackgroundColor',gray_light,'value',0);
% set(FIG.bg.spl.parent, 'SelectedObject', FIG.bg.spl.dB65);
set(FIG.bg2.spl.parent,'SelectionChangeFcn','FFRwav2(''update_stim'',''spl2'');');



%% 14 stim/ 22 stim buttongroup
% FIG.bg.stim.parent= uibuttongroup('visible','on','Position',[.5 .12 .24 .05],'BackgroundColor',gray_light);
% FIG.bg.stim.stim14=uicontrol('parent',FIG.bg.stim.parent,'callback','FFRwav(''update_stim'',14);','style','radio','Enable','on','Units','normalized','position',[0 0 .5 1],'string','14-stim','fontsize',12,'BackgroundColor',gray_light,'value',1);
% FIG.bg.stim.stim22=uicontrol('parent',FIG.bg.stim.parent,'callback','FFRwav(''update_stim'',18);','style','radio','Enable','on','Units','normalized','position',[.33 0 .5 1],'string','22-stim','fontsize',12,'BackgroundColor',gray_light,'value',1);
% FIG.bg.stim.stimDir=uicontrol('parent',FIG.bg.stim.parent,'callback','FFRwav(''update_stim'',-1);','style','radio','Enable','on','Units','normalized','position',[.67 0 .5 1],'string','Dir_Based','fontsize',12,'BackgroundColor',gray_light,'value',1);
% set(FIG.bg.stim.parent, 'SelectedObject', FIG.bg.stim.stimDir);
% set(FIG.bg.stim.parent,'SelectionChangeFcn','FFRwav(''update_stim'',''list'');');



%% ???? this may not be used - get rid of??? 
%% SSN/FN buttongroup
% FIG.bg.nt.parent= uibuttongroup('visible','on','Position',[.75 .12 .12 .05],'BackgroundColor',gray_light);
% FIG.bg.nt.nt_ssn=uicontrol('parent',FIG.bg.nt.parent,'style','radio','Enable','on','Units','normalized','position',[0 0 .5 1],'string','SSN','fontsize',12,'BackgroundColor',gray_light,'value',1); % steady state
% FIG.bg.nt.nt_f=uicontrol('parent',FIG.bg.nt.parent,'style','radio','Enable','on','Units','normalized','position',[.5 0 .5 1],'string','FN','fontsize',12,'BackgroundColor',gray_light,'value',1); %fluctuating
% set(FIG.bg.nt.parent, 'SelectedObject', FIG.bg.nt.nt_ssn);
% set(FIG.bg.nt.parent,'SelectionChangeFcn','FFRwav(''update_stim'',''noise_type'');');




%% SPL slider
%FIG.asldr.slider = uicontrol(FIG.handle,'callback','FFRwav(''slide_atten'');','style','slider','SliderStep',[1/120 5/120],'Enable','on','min',-120,'max',0,'Units','normalized','position',[.35 .075 .225 .04],'Value',-Stimuli.atten_dB);
% FIG.asldr.siglabel = uicontrol(FIG.handle, 'callback', '', 'style', 'text','Units','normalized', 'position', [.35 .17 .05 .04], 'string', 'Stimulus 1:','fontsize',12,'BackgroundColor','w','FontWeight','Bold');
FIG.asldr.slider = uicontrol(FIG.handle,'callback','FFRwav2(''slide_atten'');','style','slider','SliderStep',[1/120 5/120],'Enable','on','min',-120,'max',0,'Units','normalized','position',[.4 .18 .525 .04],'Value',-Stimuli.atten_dB);
FIG.asldr.min    = uicontrol(FIG.handle,'style','text','string',num2str(get(FIG.asldr.slider,'min')),'backgroundcolor',gray_dark,'Units','normalized','position',[.38 .16 .05 .02],'fontsize',10);
FIG.asldr.max    = uicontrol(FIG.handle,'style','text','string',num2str(get(FIG.asldr.slider,'max')),'backgroundcolor',gray_dark,'Units','normalized','position',[.875 .16 .05 .02],'fontsize',10,'horizontalalignment','right');
FIG.asldr.val    = uicontrol(FIG.handle,'style','edit','Units','normalized','Userdata',Stimuli.atten_dB,'position',[.6325 .18 .06 .04],'string',num2str(-Stimuli.atten_dB),'fontsize',12,'callback', 'FFRwav2(''slide_atten_text'');');
FIG.asldr.SPL    = uicontrol(FIG.handle,'style','text','string',sprintf('%.1f dB SPL',0), 'backgroundcolor',[1 1 1],'Units','normalized','position',[.93 .18 .075 .03],'fontsize',10,'horizontalalignment','left');
% 

%% SPL slider signal 2
% FIG.asldr2.siglabel = uicontrol(FIG.handle, 'callback', '', 'style', 'text','Units','normalized', 'position', [.35 .07 .05 .04], 'string', 'Stimulus 2:','fontsize',12,'BackgroundColor','w','FontWeight','Bold');
FIG.asldr2.slider = uicontrol(FIG.handle,'callback','FFRwav2(''slide_atten2'');','style','slider','SliderStep',[1/120 5/120],'Enable','on','min',-120,'max',0,'Units','normalized','position',[.4 .07 .525 .04],'Value',-Stimuli.atten_dB);
FIG.asldr2.min    = uicontrol(FIG.handle,'style','text','string',num2str(get(FIG.asldr.slider,'min')),'backgroundcolor',gray_dark,'Units','normalized','position',[.38 .04 .05 .03],'fontsize',10);
FIG.asldr2.max    = uicontrol(FIG.handle,'style','text','string',num2str(get(FIG.asldr.slider,'max')),'backgroundcolor',gray_dark,'Units','normalized','position',[.875 .04 .05 .03],'fontsize',10,'horizontalalignment','right');
FIG.asldr2.val    = uicontrol(FIG.handle,'style','edit','Units','normalized','Userdata',Stimuli.atten_dB,'position',[.6325 .07 .06 .04],'string',num2str(-Stimuli.atten_dB),'fontsize',12,'callback', 'FFRwav2(''slide_atten_text2'');');
FIG.asldr2.SPL    = uicontrol(FIG.handle,'style','text','string',sprintf('%.1f dB SPL',0), 'backgroundcolor',[1 1 1],'Units','normalized','position',[.93 .07 .075 .03],'fontsize',10,'horizontalalignment','left');

%% LQ 01/31/05 add callback
FIG.statText.memReps = uicontrol(FIG.handle, 'style', 'text','Units','normalized', 'position', [.05 .49 .12 .03], 'string', 'Forget Time (reps):','fontsize',12,'BackgroundColor','w');   % added by GE 17Jan2003.
FIG.statText.threshV = uicontrol(FIG.handle, 'style', 'text','Units','normalized', 'position', [.05 .54 .12 .03], 'string', 'Reject thresh (V):','fontsize',12,'BackgroundColor','w');   % added by khZZ 2011 Nov 4
FIG.edit.threshV     = uicontrol(FIG.handle,'callback','FFRwav2(''threshV'');','style','edit','Units','normalized','position',[.18 .54 .04 .04],'string',Stimuli.threshV,'fontsize',12); % KHZZ 2011 Nov 4
FIG.edit.threshV2    = uicontrol(FIG.handle,'callback','FFRwav2(''threshV2'');','style','edit','Units','normalized','position',[.18+.05 .54 .04 .04],'string',Stimuli.threshV2,'fontsize',12, 'Enable', 'off'); % channel 2 threshold JMR nov 21
FIG.edit.memReps     = uicontrol(FIG.handle,'callback','FFRwav2(''memReps'');','style','edit','Units','normalized','position',[.18 .49 .04 .04],'string',Stimuli.FFRmem_reps,'fontsize',12);

FIG.statText.status =  uicontrol(FIG.handle, 'style', 'text','Units','normalized', 'position', [.05 .9 .25 .03], 'string', ['STATUS (' interface_type '): free running...'],'fontsize',12,'BackgroundColor','w','horizontalalignment','left');   % added by GE 17Jan2003.




%% Speakers
FIG.statText.EarLabel = uicontrol(FIG.handle, 'callback', '', 'style', 'text','Units','normalized', 'position', [.02 .3 .1 .05], 'string', 'Stimulus 1:','fontsize',12,'BackgroundColor','w','FontWeight','Bold');
FIG.radio.left   = uicontrol(FIG.handle,'callback','FFRwav2(''left'');', 'style','radio','Enable','on','Units','normalized','position',[.045 .29 .08 .03],'string','Left Ear', 'fontsize',12,'BackgroundColor','w','value',0);
FIG.radio.right  = uicontrol(FIG.handle,'callback','FFRwav2(''right'');','style','radio','Enable','on','Units','normalized','position',[.045 .26 .08 .03],'string','Right Ear','fontsize',12,'BackgroundColor','w','value',1);
FIG.radio.both   = uicontrol(FIG.handle,'callback','FFRwav2(''both'');', 'style','radio','Enable','on','Units','normalized','position',[.045 .23 .08 .03],'string','Both Ears','fontsize',12,'BackgroundColor','w','value',0);

%%% Speakers for signal 2
FIG.statText.EarLabel2 = uicontrol(FIG.handle, 'callback', '', 'style', 'text','Units','normalized', 'position', [.1 .3 .1 .05], 'string', 'Stimulus 2:','fontsize',12,'BackgroundColor','w','FontWeight','Bold');
FIG.radio.left2   = uicontrol(FIG.handle,'callback','FFRwav2(''left2'');', 'style','radio','Enable','on','Units','normalized','position',[.125 .29 .08 .03],'string','Left Ear', 'fontsize',12,'BackgroundColor','w','value',0);
FIG.radio.right2  = uicontrol(FIG.handle,'callback','FFRwav2(''right2'');','style','radio','Enable','on','Units','normalized','position',[.125 .26 .08 .03],'string','Right Ear','fontsize',12,'BackgroundColor','w','value',1);
FIG.radio.both2   = uicontrol(FIG.handle,'callback','FFRwav2(''both2'');', 'style','radio','Enable','on','Units','normalized','position',[.125 .23 .08 .03],'string','Both Ears','fontsize',12,'BackgroundColor','w','value',0);
FIG.radio.no_audio2   = uicontrol(FIG.handle,'callback','FFRwav2(''no_audio2'');', 'style','radio','Enable','on','Units','normalized','position',[.125 .2 .08 .03],'string','No stimulus','fontsize',12,'BackgroundColor','w','value',0);

%% Setting 2 channel vs 1 channel  (RECORDING)
FIG.statText.ChanLabel = uicontrol(FIG.handle, 'callback', '', 'style', 'text','Units','normalized', 'position', [.22 .3 .1 .05], 'string', 'Physiological Signal:','fontsize',12,'BackgroundColor','w','FontWeight','Bold');
FIG.radio.chan_1 = uicontrol(FIG.handle,'callback','FFRwav2(''chan_1'');', 'style','radio','Enable','on','Units','normalized','position',[.125*2 .29 .08 .03],'string','Chan 1','fontsize',12,'BackgroundColor','w','value',1);
FIG.radio.chan_2 = uicontrol(FIG.handle,'callback','FFRwav2(''chan_2'');', 'style','radio','Enable','on','Units','normalized','position',[.125*2 .26 .08 .03],'string','Chan 2','fontsize',12,'BackgroundColor','w','value',0);
FIG.radio.Simultaneous = uicontrol(FIG.handle,'callback','FFRwav2(''Simultaneous'');', 'style','radio','Enable','on','Units','normalized','position',[.125*2 .23 .08 .03],'string','Simultaneous','fontsize',12,'BackgroundColor','w','value',0);

%% 28Apr2004 M.Heinz - Add Gain field, and Voltage-display choice
FIG.statText.gain = uicontrol(FIG.handle, 'style', 'text','Units','normalized', 'position', [.02 .11 .15 .03], 'string', 'Gain (Electode to AD):','fontsize',12,'BackgroundColor','w');
FIG.edit.gain     = uicontrol(FIG.handle,'callback','FFRwav2(''Gain'');','style','edit','Units','normalized','position',[.17 .11 .07 .04],'string',Display.Gain,'fontsize',12);
FIG.statText.voltDisplay = uicontrol(FIG.handle, 'style', 'text','Units','normalized', 'position', [.003 .07 .15 .03], 'string', 'Display: voltage','fontsize',12,'BackgroundColor','w');
FIG.radio.atAD    = uicontrol(FIG.handle,'callback','FFRwav2(''atAD'');', 'style','radio','Enable','on','Units','normalized','position',[.135 .07 .13 .03],'string','at AD;  YLim (AD): ', 'fontsize',12,'BackgroundColor','w','value',strcmp(Display.Voltage,'atAD'));
FIG.radio.atELEC  = uicontrol(FIG.handle,'callback','FFRwav2(''atELEC'');','style','radio','Enable','on','Units','normalized','position',[.135 .04 .12 .03],'string','at Electrode','fontsize',12,'BackgroundColor','w','value',~strcmp(Display.Voltage,'atAD'));
FIG.edit.yscale     = uicontrol(FIG.handle,'callback','FFRwav2(''YLim'');','style','edit','Units','normalized','position',[.265 .07 .05 .04],'string',Display.YLim_atAD,'fontsize',12);

%% Make things happen
FIG.push.close   = uicontrol(FIG.handle,'callback','FFRwav2(''close'');','style','pushbutton','Units','normalized','position',[.1 .6 .125 .09],'string','Close','fontsize',12,'fontangle','normal','fontweight','normal');
FIG.push.run_levels = uicontrol(FIG.handle,'callback','FFRwav2(''run_levels'');','style','pushbutton','Units','normalized','position',[.1 .726 .125 .09],'string','Run levels...','fontsize',12,'fontangle','normal','fontweight','normal');
FIG.push.forget_now = uicontrol(FIG.handle,'callback','FFRwav2(''forget_now'');','style','pushbutton','Units','normalized','position',[.07 .43 .125 .05],'string','Forget NOW','fontsize',12,'fontangle','normal','fontweight','normal','Userdata','');

%% ???? CHANGE THIS???  %% MH/AF take out  (set later correctly)
% if (FFR_set_attns(0,0,1,0) == 0)
%     set(FIG.radio.left,'Enable','off');
% end
% if (FFR_set_attns(0,0,2,0) == 0)
%     set(FIG.radio.right,'Enable','off');
% end
set(FIG.handle,'Userdata',struct('handles',FIG));
set(FIG.handle,'Visible','on');

% Init Gating
if get(FIG.radio.fast, 'value') == 1
    FFR_Gating=Stimuli.fast;
else
    FFR_Gating=Stimuli.slow;
end

% Init Voltage_Display_Factor
if strcmp(Display.Voltage,'atELEC')
    Display.PlotFactor=1/Display.Gain;
    Display.YLim=Display.YLim_atAD/Display.Gain;
else
    Display.PlotFactor=1;
    Display.YLim=Display.YLim_atAD;
end

drawnow;
