global CAP_interface_type
% UNIT = sprintf('%1d.%02d', NelData.File_Manager.track.No, NelData.File_Manager.unit.No);

% FIG.radio.noise  = uicontrol(FIG.handle,'callback','CAP(''noise'');','style','radio','Enable','on','Units','normalized','position',[.125 .425 .08 .03],'string','Noise','fontsize',12,'BackgroundColor','w','value',1);
% FIG.radio.tone   = uicontrol(FIG.handle,'callback','CAP(''tone'');','style','radio','Enable','on','Units','normalized','position',[.125 .395 .08 .03],'string','Tone','fontsize',12,'BackgroundColor','w','value',1);
% FIG.radio.khite  = uicontrol(FIG.handle,'callback','CAP(''khite'');','style','radio','Enable','on','Units','normalized','position',[.125 .365 .08 .03],'string','KH Osc','fontsize',12,'BackgroundColor','w');
FIG.radio.fast   = uicontrol(FIG.handle,'callback','CAP(''fast'');','style','radio','Enable','on','Units','normalized','position',[.125 .315 .08 .03],'string','Fast','fontsize',12,'BackgroundColor','w','value',1);
FIG.radio.slow   = uicontrol(FIG.handle,'callback','CAP(''slow'');','style','radio','Enable','on','Units','normalized','position',[.125 .285 .08 .03],'string','Slow','fontsize',12,'BackgroundColor','w');
FIG.checkbox.fixedPhase = uicontrol(FIG.handle, 'callback', 'CAP(''fixedPhase'');','style','checkbox','Enable','on','Units','normalized','position',[.125 .365 .09 .03],'string','fixedPhase','fontsize',12,'BackgroundColor','w','value',Stimuli.fixedPhase);
FIG.push.close   = uicontrol(FIG.handle,'callback','CAP(''close'');','style','pushbutton','Units','normalized','position',[.1 .6 .125 .09],'string','Close','fontsize',12,'fontangle','normal','fontweight','normal');

FIG.radio.clickYes = uicontrol(FIG.handle,'callback','CAP(''clickYes'');','style','radio','Enable','on','Units','normalized','position',[.89 .175 .08 .03],'string','Click','fontsize',12,'BackgroundColor','w','value',Stimuli.clickYes); %added by KH 06Jan2012

FIG.fsldr.slider = uicontrol(FIG.handle,'callback','CAP(''slide_freq'');','style','slider','SliderStep',[0.001 0.01],'Enable','on','min',100,'max',1000,'Units','normalized','position',[.35 .175 .525 .04],'Value',Stimuli.freq_hz/Stimuli.fmult);
FIG.fsldr.min    = uicontrol(FIG.handle,'style','text','string',num2str(get(FIG.fsldr.slider,'min')),'backgroundcolor',[1 1 1],'Units','normalized','position',[.33 .14 .05 .03],'fontsize',10);
FIG.fsldr.max    = uicontrol(FIG.handle,'style','text','string',num2str(get(FIG.fsldr.slider,'max')),'backgroundcolor',[1 1 1],'Units','normalized','position',[.835 .14 .05 .03],'fontsize',10,'horizontalalignment','right');
% LQ 01/31/05 add callback
%FIG.fsldr.val    = uicontrol(FIG.handle,'style','edit','Units','normalized','position',[.5825 .175 .06 .04],'string',num2str(Stimuli.freq_hz),'fontsize',12);
FIG.fsldr.val    = uicontrol(FIG.handle,'style','edit','Units','normalized','position',[.5825 .175 .06 .04],'string',num2str(Stimuli.freq_hz),'fontsize',12,'callback', 'CAP(''slide_freq_text'');');

FIG.asldr.slider = uicontrol(FIG.handle,'callback','CAP(''slide_atten'');','style','slider','SliderStep',[1/120 5/120],'Enable','on','min',-120,'max',0,'Units','normalized','position',[.35 .075 .525 .04],'value',-Stimuli.atten_dB);
FIG.asldr.min    = uicontrol(FIG.handle,'style','text','string',num2str(get(FIG.asldr.slider,'min')),'backgroundcolor',[1 1 1],'Units','normalized','position',[.33 .04 .05 .03],'fontsize',10);
FIG.asldr.max    = uicontrol(FIG.handle,'style','text','string',num2str(get(FIG.asldr.slider,'max')),'backgroundcolor',[1 1 1],'Units','normalized','position',[.825 .04 .05 .03],'fontsize',10,'horizontalalignment','right');
% LQ 01/31/05 add callback
%FIG.asldr.val    = uicontrol(FIG.handle,'style','edit','Units','normalized','Userdata',Stimuli.atten_dB,'position',[.5825 .075 .06 .04],'string',num2str(-Stimuli.atten_dB),'fontsize',12);
FIG.asldr.val    = uicontrol(FIG.handle,'style','edit','Units','normalized','Userdata',Stimuli.atten_dB,'position',[.5825 .075 .06 .04],'string',num2str(-Stimuli.atten_dB),'fontsize',12,'callback', 'CAP(''slide_atten_text'');');
FIG.asldr.SPL    = uicontrol(FIG.handle,'style','text','string',sprintf('%.1f dB SPL',120+get(FIG.asldr.slider,'Value')),...
    'backgroundcolor',[1 1 1],'Units','normalized','position',[.9 .06 .1 .03],'fontsize',10,'horizontalalignment','right');


FIG.edit         = uicontrol(FIG.handle,'Visible','off','style','edit','Units','normalized','position',[.12 .75 .1 .04],'string',num2str(UNIT),'fontsize',14);
FIG.statText.memReps =  uicontrol(FIG.handle, 'callback', '', 'style', 'text','Units','normalized', 'position', [.05 .49 .12 .03], 'string', 'Forget Time (reps):','fontsize',12,'BackgroundColor','w');   % added by GE 17Jan2003.
FIG.edit.memReps = uicontrol(FIG.handle,'callback','CAP(''memReps'');','style','edit','Units','normalized','position',[.18 .49 .04 .04],'string',Stimuli.CAPmem_reps,'fontsize',12);
FIG.statText.threshV =  uicontrol(FIG.handle, 'callback', '', 'style', 'text','Units','normalized', 'position', [.05 .54 .12 .03], 'string', 'Reject thresh (V):','fontsize',12,'BackgroundColor','w');   % added by kh 2011Jun08
FIG.edit.threshV = uicontrol(FIG.handle,'callback','CAP(''threshV'');','style','edit','Units','normalized','position',[.18 .54 .04 .04],'string',Stimuli.threshV,'fontsize',12); % KH 2011 Jun 08
FIG.statText.status =  uicontrol(FIG.handle, 'callback', '', 'style', 'text','Units','normalized', 'position', [.05 .9 .25 .03], 'string', ['STATUS (' CAP_interface_type '): free running...'],'fontsize',12,'BackgroundColor','w','horizontalalignment','left');   % added by GE 17Jan2003.

FIG.push.x1      = uicontrol(FIG.handle,'callback','CAP(''mult_1x'');','style','pushbutton','Enable','on','Units','normalized','position',[.5 .23 .05 .037],'string','1X','fontsize',12,'fontangle','normal','fontweight','normal','foregroundcolor',[0 0 0]);
FIG.push.x10     = uicontrol(FIG.handle,'callback','CAP(''mult_10x'');','style','pushbutton','Enable','on','Units','normalized','position',[.585 .23 .05 .037],'string','10X','fontsize',12,'fontangle','normal','fontweight','normal','foregroundcolor',[1 1 1]);
FIG.push.x100    = uicontrol(FIG.handle,'callback','CAP(''mult_100x'');','style','pushbutton','Enable','on','Units','normalized','position',[.67 .23 .05 .037],'string','100X','fontsize',12,'fontangle','normal','fontweight','normal','foregroundcolor',[0 0 0]);

FIG.radio.left   = uicontrol(FIG.handle,'callback','CAP(''left'');', 'style','radio','Enable','on','Units','normalized','position',[.125 .235 .08 .03],'string','Left Ear', 'fontsize',12,'BackgroundColor','w','value',0);
FIG.radio.right  = uicontrol(FIG.handle,'callback','CAP(''right'');','style','radio','Enable','on','Units','normalized','position',[.125 .205 .08 .03],'string','Right Ear','fontsize',12,'BackgroundColor','w','value',1);
FIG.radio.both   = uicontrol(FIG.handle,'callback','CAP(''both'');', 'style','radio','Enable','on','Units','normalized','position',[.125 .175 .08 .03],'string','Both Ears','fontsize',12,'BackgroundColor','w','value',0);


FIG.push.run_levels = uicontrol(FIG.handle,'callback','CAP(''run_levels'');','style','pushbutton','Units','normalized',...
    'position',[.06 .726 .09 .09],'string','Run levels...','fontsize',12,'fontangle','normal','fontweight','normal');
FIG.push.run_audiogram = uicontrol(FIG.handle,'callback','CAP(''audiogram'');','style','pushbutton','Units','normalized',...
    'position',[.18 .726 .09 .09],'string','Audiogram...','fontsize',12,'fontangle','normal','fontweight','normal'); %added by KH 05Jan2012


FIG.push.forget_now = uicontrol(FIG.handle,'callback','CAP(''forget_now'');','style','pushbutton','Units','normalized','position',[.07 .43 .125 .05],'string','Forget NOW','fontsize',12,'fontangle','normal','fontweight','normal');

% 28Apr2004 M.Heinz - Add Gain field, and Voltage-display choice
FIG.statText.gain = uicontrol(FIG.handle, 'callback', '', 'style', 'text','Units','normalized', 'position', [.02 .11 .15 .03], 'string', 'Gain (Electode to AD):','fontsize',12,'BackgroundColor','w');
FIG.edit.gain     = uicontrol(FIG.handle,'callback','CAP(''Gain'');','style','edit','Units','normalized','position',[.17 .11 .07 .04],'string',Display.Gain,'fontsize',12);
FIG.statText.voltDisplay = uicontrol(FIG.handle, 'callback', '', 'style', 'text','Units','normalized', 'position', [.003 .07 .15 .03], 'string', 'Display: voltage','fontsize',12,'BackgroundColor','w');
FIG.radio.atAD    = uicontrol(FIG.handle,'callback','CAP(''atAD'');', 'style','radio','Enable','on','Units','normalized','position',[.135 .07 .13 .03],'string','at AD;  YLim (AD): ', 'fontsize',12,'BackgroundColor','w','value',strcmp(Display.Voltage,'atAD'));
FIG.radio.atELEC  = uicontrol(FIG.handle,'callback','CAP(''atELEC'');','style','radio','Enable','on','Units','normalized','position',[.135 .04 .12 .03],'string','at Electrode','fontsize',12,'BackgroundColor','w','value',~strcmp(Display.Voltage,'atAD'));
FIG.edit.yscale     = uicontrol(FIG.handle,'callback','CAP(''YLim'');','style','edit','Units','normalized','position',[.265 .07 .05 .04],'string',Display.YLim_atAD,'fontsize',12);


% FIG.statText.spike_channel =  uicontrol(FIG.handle, 'callback', '', 'style', 'text','Units','normalized', 'position', [.1 .49 .13 .03], 'string', 'spike channel:','fontsize',12,'BackgroundColor','w');   % added by GE 17Jan2003.
% FIG.popup.spike_channel = uicontrol(FIG.handle, 'callback', 'CAP(''spike_channel'');', 'style', 'popup', 'Enable', 'on','Units','normalized', 'position', [.22 .5 .035 .03], 'string', '1|2|3|4|5|6','fontsize',12,'BackgroundColor','w','value',1);   % added by GE 17Jan2003.

% if (isempty(strmatch('KH-oscillator', devices_names_vector,'exact')))
%     set(FIG.radio.khite,'Enable','off');
% end
if (AEP_set_attns(0,1,0) == 0)
    set(FIG.radio.left,'Enable','off');
end    
if (AEP_set_attns(0,2,0) == 0)
    set(FIG.radio.right,'Enable','off');
end
set(FIG.handle,'Userdata',struct('handles',FIG));
set(FIG.handle,'Visible','on');

% Init Gating
if get(FIG.radio.fast, 'value') == 1
   CAP_Gating=Stimuli.fast;
else
   CAP_Gating=Stimuli.slow;
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
