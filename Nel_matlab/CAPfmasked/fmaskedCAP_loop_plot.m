% UNIT = sprintf('%1d.%02d', NelData.File_Manager.track.No, NelData.File_Manager.unit.No);

FIG.radio.fast   = uicontrol(FIG.handle,'callback','fmaskedCAP(''fast'');','style','radio','Enable','on','Units','normalized','position',[.125 .315 .08 .03],'string','Fast','fontsize',12,'BackgroundColor','w','value',1);
FIG.radio.slow   = uicontrol(FIG.handle,'callback','fmaskedCAP(''slow'');','style','radio','Enable','on','Units','normalized','position',[.125 .285 .08 .03],'string','Slow','fontsize',12,'BackgroundColor','w');
FIG.checkbox.fixedPhase = uicontrol(FIG.handle, 'callback', 'fmaskedCAP(''fixedPhase'');','style','checkbox','Enable','on','Units','normalized','position',[.125 .365 .09 .03],'string','fixedPhase','fontsize',12,'BackgroundColor','w','value',Stimuli.fixedPhase);


FIG.push.close   = uicontrol(FIG.handle,'callback','fmaskedCAP(''close'');','style','pushbutton','Units','normalized','position',[.1 .518 .125 .09],'string','Close','fontsize',12,'fontangle','normal','fontweight','normal');


FIG.asldr.slider = uicontrol(FIG.handle,'callback','fmaskedCAP(''slide_atten'');','style','slider','SliderStep',[1/120 5/120],'Enable','on','min',-120,'max',0,'Units','normalized','position',[.35 .075 .525 .04],'Value',-Stimuli.atten_dB);
FIG.asldr.min    = uicontrol(FIG.handle,'style','text','string',num2str(get(FIG.asldr.slider,'min')),'backgroundcolor',[1 1 1],'Units','normalized','position',[.33 .04 .05 .03],'fontsize',10);
FIG.asldr.max    = uicontrol(FIG.handle,'style','text','string',num2str(get(FIG.asldr.slider,'max')),'backgroundcolor',[1 1 1],'Units','normalized','position',[.825 .04 .05 .03],'fontsize',10,'horizontalalignment','right');
FIG.asldr.val    = uicontrol(FIG.handle,'style','edit','Units','normalized','Userdata',Stimuli.atten_dB,'position',[.5825 .075 .06 .04],'string',num2str(-Stimuli.atten_dB),'fontsize',12,'callback', 'fmaskedCAP(''slide_atten_text'');');
FIG.statText.info_asldr =  uicontrol(FIG.handle, 'callback', '', 'style', 'text','Units','normalized', 'position', [.552 .04 .12 .03], 'string', 'Atten. click (dB)','fontsize',10,'BackgroundColor','w');

FIG.asldr2.slider = uicontrol(FIG.handle,'callback','fmaskedCAP(''slide_atten'');','style','slider','SliderStep',[1/120 5/120],'Enable','on','min',-120,'max',0,'Units','normalized','position',[.35 .175 .525 .04],'Value',-Stimuli.masker_atten_dB);
FIG.asldr2.min    = uicontrol(FIG.handle,'style','text','string',num2str(get(FIG.asldr.slider,'min')),'backgroundcolor',[1 1 1],'Units','normalized','position',[.33 .14 .05 .03],'fontsize',10);
FIG.asldr2.max    = uicontrol(FIG.handle,'style','text','string',num2str(get(FIG.asldr.slider,'max')),'backgroundcolor',[1 1 1],'Units','normalized','position',[.825 .14 .05 .03],'fontsize',10,'horizontalalignment','right');
% LQ 01/31/05 add callback
FIG.asldr2.val    = uicontrol(FIG.handle,'style','edit','Units','normalized','Userdata',Stimuli.masker_atten_dB,'position',[.5825 .175 .06 .04],'string',num2str(-Stimuli.masker_atten_dB),'fontsize',12,'callback', 'fmaskedCAP(''slide_atten_text'');');
FIG.statText.info_asldr2 =  uicontrol(FIG.handle, 'callback', '', 'style', 'text','Units','normalized', 'position', [.554 .14 .12 .03], 'string', 'Atten. masker (dB)','fontsize',10,'BackgroundColor','w');


% FIG.edit         = uicontrol(FIG.handle,'Visible','off','style','edit','Units','normalized','position',[.12 .75 .1 .04],'string',num2str(UNIT),'fontsize',14);
FIG.statText.memReps =  uicontrol(FIG.handle, 'callback', '', 'style', 'text','Units','normalized', 'position', [.05 .415 .12 .03], 'string', 'Reps (free run) :','fontsize',12,'BackgroundColor','w');  
FIG.edit.memReps = uicontrol(FIG.handle,'callback','fmaskedCAP(''memReps'');','style','edit','Units','normalized','position',[.18 .415 .04 .04],'string',Stimuli.CAPmem_reps,'fontsize',12, 'Enable', 'oN');
FIG.statText.threshV =  uicontrol(FIG.handle, 'callback', '', 'style', 'text','Units','normalized', 'position', [.05 .465 .12 .03], 'string', 'Reject thresh (V):','fontsize',12,'BackgroundColor','w');   % added by kh 2011Jun08
FIG.edit.threshV = uicontrol(FIG.handle,'callback','fmaskedCAP(''threshV'');','style','edit','Units','normalized','position',[.18 .465 .04 .04],'string',Stimuli.threshV,'fontsize',12); % KH 2011 Jun 08

FIG.statText.status =  uicontrol(FIG.handle, 'callback', '', 'style', 'text','Units','normalized', 'position', [.05 .87 .25 .09], 'string', ['STATUS (' interface_type '): Idle...'],'fontsize',12,'BackgroundColor','w','horizontalalignment','left');   % added by GE 17Jan2003.
FIG.listbox= uicontrol(FIG.handle, 'callback', '', 'style', 'listbox','Units','normalized', 'position', [.04 .74 .25 .12], 'string', '','fontsize',12,'BackgroundColor','w','horizontalalignment','left', 'Max', 1, 'Enable', 'off');   % FD 2020 - list of wavefiles
FIG.statText.status2 =  uicontrol(FIG.handle, 'callback', '', 'style', 'text','Units','normalized', 'position', [.80 .95 .15 .03], 'string', '','fontsize',10,'BackgroundColor','w','horizontalalignment','right');   % FD 2020 - shows nb of pair


FIG.radio.left   = uicontrol(FIG.handle,'callback','fmaskedCAP(''left'');', 'style','radio','Enable','on','Units','normalized','position',[.125 .235 .08 .03],'string','Left Ear', 'fontsize',12,'BackgroundColor','w','value',0);
FIG.radio.right  = uicontrol(FIG.handle,'callback','fmaskedCAP(''right'');','style','radio','Enable','on','Units','normalized','position',[.125 .205 .08 .03],'string','Right Ear','fontsize',12,'BackgroundColor','w','value',1);
FIG.radio.both   = uicontrol(FIG.handle,'callback','fmaskedCAP(''both'');', 'style','radio','Enable','on','Units','normalized','position',[.125 .175 .08 .03],'string','Both Ears','fontsize',12,'BackgroundColor','w','value',0);


FIG.push.free_run = uicontrol(FIG.handle,'callback','fmaskedCAP(''free_run'');','style','pushbutton','Units','normalized',...
    'position',[.06 .63 .09 .09],'string','Free run...','fontsize',12,'fontangle','normal','fontweight','normal', 'Enable', 'on'); 
FIG.push.run_stimuli = uicontrol(FIG.handle,'callback','fmaskedCAP(''run_stimuli'');','style','pushbutton','Units','normalized',...
    'position',[.18 .63 .09 .09],'string','Run stimuli...','fontsize',12,'fontangle','normal','fontweight','normal');


% FIG.push.forget_now = uicontrol(FIG.handle,'callback','fmaskedCAP(''forget_now'');','style','pushbutton','Units','normalized','position',[.07 .43 .125 .05],'string','Forget NOW','fontsize',12,'fontangle','normal','fontweight','normal');

% 28Apr2004 M.Heinz - Add Gain field, and Voltage-display choice
FIG.statText.gain = uicontrol(FIG.handle, 'callback', '', 'style', 'text','Units','normalized', 'position', [.02 .11 .15 .03], 'string', 'Gain (Electode to AD):','fontsize',12,'BackgroundColor','w');
FIG.edit.gain     = uicontrol(FIG.handle,'callback','fmaskedCAP(''Gain'');','style','edit','Units','normalized','position',[.17 .11 .07 .04],'string',Display.Gain,'fontsize',12);
FIG.statText.voltDisplay = uicontrol(FIG.handle, 'callback', '', 'style', 'text','Units','normalized', 'position', [.003 .07 .15 .03], 'string', 'Display: voltage','fontsize',12,'BackgroundColor','w');
FIG.radio.atAD    = uicontrol(FIG.handle,'callback','fmaskedCAP(''atAD'');', 'style','radio','Enable','on','Units','normalized','position',[.135 .07 .13 .03],'string','at AD;  YLim (AD): ', 'fontsize',12,'BackgroundColor','w','value',strcmp(Display.Voltage,'atAD'));
FIG.radio.atELEC  = uicontrol(FIG.handle,'callback','fmaskedCAP(''atELEC'');','style','radio','Enable','on','Units','normalized','position',[.135 .04 .12 .03],'string','at Electrode','fontsize',12,'BackgroundColor','w','value',~strcmp(Display.Voltage,'atAD'));
FIG.edit.yscale     = uicontrol(FIG.handle,'callback','fmaskedCAP(''YLim'');','style','edit','Units','normalized','position',[.265 .07 .05 .04],'string',Display.YLim_atAD,'fontsize',12);


% FIG.statText.spike_channel =  uicontrol(FIG.handle, 'callback', '', 'style', 'text','Units','normalized', 'position', [.1 .49 .13 .03], 'string', 'spike channel:','fontsize',12,'BackgroundColor','w');   % added by GE 17Jan2003.
% FIG.popup.spike_channel = uicontrol(FIG.handle, 'callback', 'fmaskedCAP(''spike_channel'');', 'style', 'popup', 'Enable', 'on','Units','normalized', 'position', [.22 .5 .035 .03], 'string', '1|2|3|4|5|6','fontsize',12,'BackgroundColor','w','value',1);   % added by GE 17Jan2003.

% if (isempty(strmatch('KH-oscillator', devices_names_vector,'exact')))
%     set(FIG.radio.khite,'Enable','off');
% end


if ~noNEL
    if (fmaskedCAP_set_attns(0,0,1,0) == 0)
        set(FIG.radio.left,'Enable','off');
    end    
    if (fmaskedCAP_set_attns(0,0,2,0) == 0)
        set(FIG.radio.right,'Enable','off');
    end
end

set(FIG.handle,'Userdata',struct('handles',FIG));
set(FIG.handle,'Visible','on');

% Init Gating
if get(FIG.radio.fast, 'value') == 1
   CAP_intervals=Stimuli.fast;
else
   CAP_intervals=Stimuli.slow;
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
