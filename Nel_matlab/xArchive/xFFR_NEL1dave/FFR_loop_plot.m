% UNIT = sprintf('%1d.%02d', NelData.File_Manager.track.No, NelData.File_Manager.unit.No);

FIG.radio.fast   = uicontrol(FIG.handle,'callback','FFR(''fast'');','style','radio','Enable','on','Units','normalized','position',[.125 .315 .08 .03],'string','Fast','fontsize',12,'BackgroundColor','w','value',1);
FIG.radio.slow   = uicontrol(FIG.handle,'callback','FFR(''slow'');','style','radio','Enable','on','Units','normalized','position',[.125 .285 .08 .03],'string','Slow','fontsize',12,'BackgroundColor','w','value',0);
FIG.push.close   = uicontrol(FIG.handle,'callback','FFR(''close'');','style','pushbutton','Units','normalized','position',[.1 .6 .125 .09],'string','Close','fontsize',12,'fontangle','normal','fontweight','normal');

% WAV file loader and AM Tone generator - zz 31oct11
FIG.wavfile.func = uicontrol(FIG.handle,'style','edit','Units','normalized','Userdata',Stimuli.filename,'position',[.35 .175 .525 .04],'string',Stimuli.filename,'fontsize',12,'callback', 'FFR(''wavfile'');');
FIG.push.amtone = uicontrol(FIG.handle,'callback','FFR(''amtone'');','style','pushbutton','Units','normalized','position',[.5825 .125 .06 .04],'string','AM Tone','fontsize',12,'fontangle','normal','fontweight','normal');
FIG.push.logSwept_amtone = uicontrol(FIG.handle,'callback','FFR(''logSwept_amtone'');','style','pushbutton','Units','normalized','position',[.68 .125 .12 .04],'string','Lg-swpt AM Tone','fontsize',12,'fontangle','normal','fontweight','normal');
FIG.push.fmtone = uicontrol(FIG.handle,'callback','FFR(''fmtone'');','style','pushbutton','Units','normalized','position',[.4825 .125 .06 .04],'string','FM Tone','fontsize',12,'fontangle','normal','fontweight','normal');

% FIG.radio.noise  = uicontrol(FIG.handle,'callback','FFR(''noise'');','style','radio','Enable','on','Units','normalized','position',[.125 .425 .08 .03],'string','Noise','fontsize',12,'BackgroundColor','w','value',1);
% FIG.radio.tone   = uicontrol(FIG.handle,'callback','FFR(''tone'');','style','radio','Enable','on','Units','normalized','position',[.125 .395 .08 .03],'string','Tone','fontsize',12,'BackgroundColor','w','value',1);
% FIG.radio.khite  = uicontrol(FIG.handle,'callback','FFR(''khite'');','style','radio','Enable','on','Units','normalized','position',[.125 .365 .08 .03],'string','KH Osc','fontsize',12,'BackgroundColor','w');
% removed fixed phase for FFR, coded into AM Tone generator - zz 31nov11
% FIG.checkbox.fixedPhase = uicontrol(FIG.handle, 'callback', 'FFR(''fixedPhase'');','style','checkbox','Enable','on','Units','normalized','position',[.125 .365 .09 .03],'string','fixedPhase','fontsize',12,'BackgroundColor','w','value',Stimuli.fixedPhase);

% zz 7feb12
% noise slider
FIG.nsldr.slider = uicontrol(FIG.handle,'callback','FFR(''noise_atten'');','style','slider','SliderStep',[1/100 5/100],'Enable','on','min',-50,'max',50,'Units','normalized','position',[.35 .225 .525 .04],'Value',Stimuli.noiseLevel);
FIG.nsldr.min    = uicontrol(FIG.handle,'style','text','string',num2str(get(FIG.nsldr.slider,'min')),'backgroundcolor',[1 1 1],'Units','normalized','position',[.33 .14 .05 .03],'fontsize',10);
FIG.nsldr.max    = uicontrol(FIG.handle,'style','text','string',num2str(get(FIG.nsldr.slider,'max')),'backgroundcolor',[1 1 1],'Units','normalized','position',[.825 .14 .05 .03],'fontsize',10,'horizontalalignment','right');
FIG.nsldr.val    = uicontrol(FIG.handle,'style','edit','Units','normalized','Userdata',Stimuli.noiseLevel,'position',[.5825 .225 .06 .04],'string',num2str(-Stimuli.noiseLevel),'fontsize',12,'callback', 'FFR(''noise_atten_text'');');
FIG.checkbox.noNoise = uicontrol(FIG.handle, 'callback', 'FFR(''noNoise'');','style','checkbox','Enable','on','Units','normalized','position',[.125 .365 .09 .03],'string','No noise','fontsize',12,'BackgroundColor','w','Value',Stimuli.noNoise);

FIG.asldr.slider = uicontrol(FIG.handle,'callback','FFR(''slide_atten'');','style','slider','SliderStep',[1/120 5/120],'Enable','on','min',-120,'max',0,'Units','normalized','position',[.35 .075 .525 .04],'Value',-Stimuli.atten_dB);
FIG.asldr.min    = uicontrol(FIG.handle,'style','text','string',num2str(get(FIG.asldr.slider,'min')),'backgroundcolor',[1 1 1],'Units','normalized','position',[.33 .04 .05 .03],'fontsize',10);
FIG.asldr.max    = uicontrol(FIG.handle,'style','text','string',num2str(get(FIG.asldr.slider,'max')),'backgroundcolor',[1 1 1],'Units','normalized','position',[.825 .04 .05 .03],'fontsize',10,'horizontalalignment','right');
% LQ 01/31/05 add callback
%FIG.asldr.val    = uicontrol(FIG.handle,'style','edit','Units','normalized','Userdata',Stimuli.atten_dB,'position',[.5825 .075 .06 .04],'string',num2str(-Stimuli.atten_dB),'fontsize',12);
FIG.asldr.val    = uicontrol(FIG.handle,'style','edit','Units','normalized','Userdata',Stimuli.atten_dB,'position',[.5825 .075 .06 .04],'string',num2str(-Stimuli.atten_dB),'fontsize',12,'callback', 'FFR(''slide_atten_text'');');
% FIG.edit         = uicontrol(FIG.handle,'Visible','off','style','edit','Units','normalized','position',[.12 .75 .1 .04],'string',num2str(UNIT),'fontsize',14);
FIG.statText.memReps =  uicontrol(FIG.handle, 'callback', '', 'style', 'text','Units','normalized', 'position', [.05 .49 .12 .03], 'string', 'Forget Time (reps):','fontsize',12,'BackgroundColor','w');   % added by GE 17Jan2003.
FIG.statText.threshV =  uicontrol(FIG.handle, 'callback', '', 'style', 'text','Units','normalized', 'position', [.05 .54 .12 .03], 'string', 'Reject thresh (V):','fontsize',12,'BackgroundColor','w');   % added by khZZ 2011 Nov 4
FIG.edit.threshV = uicontrol(FIG.handle,'callback','FFR(''threshV'');','style','edit','Units','normalized','position',[.18 .54 .04 .04],'string',Stimuli.threshV,'fontsize',12); % KHZZ 2011 Nov 4
FIG.edit.memReps = uicontrol(FIG.handle,'callback','FFR(''memReps'');','style','edit','Units','normalized','position',[.18 .49 .04 .04],'string',Stimuli.FFRmem_reps,'fontsize',12);
FIG.statText.status =  uicontrol(FIG.handle, 'callback', '', 'style', 'text','Units','normalized', 'position', [.05 .9 .25 .03], 'string', ['STATUS (' interface_type '): free running...'],'fontsize',12,'BackgroundColor','w','horizontalalignment','left');   % added by GE 17Jan2003.

FIG.radio.left   = uicontrol(FIG.handle,'callback','FFR(''left'');', 'style','radio','Enable','on','Units','normalized','position',[.125 .235 .08 .03],'string','Left Ear', 'fontsize',12,'BackgroundColor','w','value',0);
FIG.radio.right  = uicontrol(FIG.handle,'callback','FFR(''right'');','style','radio','Enable','on','Units','normalized','position',[.125 .205 .08 .03],'string','Right Ear','fontsize',12,'BackgroundColor','w','value',0);
FIG.radio.both   = uicontrol(FIG.handle,'callback','FFR(''both'');', 'style','radio','Enable','on','Units','normalized','position',[.125 .175 .08 .03],'string','Both Ears','fontsize',12,'BackgroundColor','w','value',1);

% zz 07nov11 added save now function
% FIG.push.save_now   = 
FIG.push.run_levels = uicontrol(FIG.handle,'callback','FFR(''run_levels'');','style','pushbutton','Units','normalized','position',[.1 .726 .125 .09],'string','Run levels...','fontsize',12,'fontangle','normal','fontweight','normal');
FIG.push.forget_now = uicontrol(FIG.handle,'callback','FFR(''forget_now'');','style','pushbutton','Units','normalized','position',[.07 .43 .125 .05],'string','Forget NOW','fontsize',12,'fontangle','normal','fontweight','normal','Userdata','');

% 28Apr2004 M.Heinz - Add Gain field, and Voltage-display choice
FIG.statText.gain = uicontrol(FIG.handle, 'callback', '', 'style', 'text','Units','normalized', 'position', [.02 .11 .15 .03], 'string', 'Gain (Electode to AD):','fontsize',12,'BackgroundColor','w');
FIG.edit.gain     = uicontrol(FIG.handle,'callback','FFR(''Gain'');','style','edit','Units','normalized','position',[.17 .11 .07 .04],'string',Display.Gain,'fontsize',12);
FIG.statText.voltDisplay = uicontrol(FIG.handle, 'callback', '', 'style', 'text','Units','normalized', 'position', [.003 .07 .15 .03], 'string', 'Display: voltage','fontsize',12,'BackgroundColor','w');
FIG.radio.atAD    = uicontrol(FIG.handle,'callback','FFR(''atAD'');', 'style','radio','Enable','on','Units','normalized','position',[.135 .07 .13 .03],'string','at AD;  YLim (AD): ', 'fontsize',12,'BackgroundColor','w','value',strcmp(Display.Voltage,'atAD'));
FIG.radio.atELEC  = uicontrol(FIG.handle,'callback','FFR(''atELEC'');','style','radio','Enable','on','Units','normalized','position',[.135 .04 .12 .03],'string','at Electrode','fontsize',12,'BackgroundColor','w','value',~strcmp(Display.Voltage,'atAD'));
FIG.edit.yscale     = uicontrol(FIG.handle,'callback','FFR(''YLim'');','style','edit','Units','normalized','position',[.265 .07 .05 .04],'string',Display.YLim_atAD,'fontsize',12);


% FIG.statText.spike_channel =  uicontrol(FIG.handle, 'callback', '', 'style', 'text','Units','normalized', 'position', [.1 .49 .13 .03], 'string', 'spike channel:','fontsize',12,'BackgroundColor','w');   % added by GE 17Jan2003.
% FIG.popup.spike_channel = uicontrol(FIG.handle, 'callback', 'FFR(''spike_channel'');', 'style', 'popup', 'Enable', 'on','Units','normalized', 'position', [.22 .5 .035 .03], 'string', '1|2|3|4|5|6','fontsize',12,'BackgroundColor','w','value',1);   % added by GE 17Jan2003.

% if (isempty(strmatch('KH-oscillator', devices_names_vector,'exact')))
%     set(FIG.radio.khite,'Enable','off');
% end
if (FFR_set_attns(0,0,1,0) == 0)
    set(FIG.radio.left,'Enable','off');
end    
if (FFR_set_attns(0,0,2,0) == 0)
    set(FIG.radio.right,'Enable','off');
end
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
