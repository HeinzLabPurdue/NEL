function CAP_loop_plot_enable_disable(on_or_off)
global FIG
% UNIT = sprintf('%1d.%02d', NelData.File_Manager.track.No, NelData.File_Manager.unit.No);

set(FIG.radio.fast, 'Enable',on_or_off)
set(FIG.radio.slow, 'Enable',on_or_off)

set(FIG.checkbox.fixedPhase, 'Enable',on_or_off)

set(FIG.asldr.slider, 'Enable',on_or_off)
set(FIG.asldr2.slider, 'Enable',on_or_off)

set(FIG.asldr.val, 'Enable',on_or_off)
set(FIG.asldr2.val, 'Enable',on_or_off)


% % FIG.edit         = uicontrol(FIG.handle,'Visible','off','style','edit','Units','normalized','position',[.12 .75 .1 .04],'string',num2str(UNIT),'fontsize',14);
% FIG.statText.memReps =  uicontrol(FIG.handle, 'callback', '', 'style', 'text','Units','normalized', 'position', [.05 .49 .12 .03], 'string', 'Forget Time (reps):','fontsize',12,'BackgroundColor','w');   % added by GE 17Jan2003.
% FIG.edit.memReps = uicontrol(FIG.handle,'callback','CAP(''memReps'');','style','edit','Units','normalized','position',[.18 .49 .04 .04],'string',Stimuli.CAPmem_reps,'fontsize',12);
% FIG.statText.threshV =  uicontrol(FIG.handle, 'callback', '', 'style', 'text','Units','normalized', 'position', [.05 .54 .12 .03], 'string', 'Reject thresh (V):','fontsize',12,'BackgroundColor','w');   % added by kh 2011Jun08
% FIG.edit.threshV = uicontrol(FIG.handle,'callback','CAP(''threshV'');','style','edit','Units','normalized','position',[.18 .54 .04 .04],'string',Stimuli.threshV,'fontsize',12); % KH 2011 Jun 08
% FIG.statText.status =  uicontrol(FIG.handle, 'callback', '', 'style', 'text','Units','normalized', 'position', [.05 .9 .25 .03], 'string', ['STATUS (' interface_type '): Idle...'],'fontsize',12,'BackgroundColor','w','horizontalalignment','left');   % added by GE 17Jan2003.
% 
% FIG.radio.left   = uicontrol(FIG.handle,'callback','CAP(''left'');', 'style','radio','Enable','on','Units','normalized','position',[.125 .235 .08 .03],'string','Left Ear', 'fontsize',12,'BackgroundColor','w','value',0);
% FIG.radio.right  = uicontrol(FIG.handle,'callback','CAP(''right'');','style','radio','Enable','on','Units','normalized','position',[.125 .205 .08 .03],'string','Right Ear','fontsize',12,'BackgroundColor','w','value',1);
% FIG.radio.both   = uicontrol(FIG.handle,'callback','CAP(''both'');', 'style','radio','Enable','on','Units','normalized','position',[.125 .175 .08 .03],'string','Both Ears','fontsize',12,'BackgroundColor','w','value',0);
% 
% 
% FIG.push.run_levels = uicontrol(FIG.handle,'callback','CAP(''run_levels'');','style','pushbutton','Units','normalized',...
%     'position',[.06 .726 .09 .09],'string','Run levels...','fontsize',12,'fontangle','normal','fontweight','normal');
% FIG.push.run_stimuli = uicontrol(FIG.handle,'callback','CAP(''run_stimuli'');','style','pushbutton','Units','normalized',...
%     'position',[.18 .726 .09 .09],'string','Run stimuli...','fontsize',12,'fontangle','normal','fontweight','normal');
% 
% 
% FIG.push.forget_now = uicontrol(FIG.handle,'callback','CAP(''forget_now'');','style','pushbutton','Units','normalized','position',[.07 .43 .125 .05],'string','Forget NOW','fontsize',12,'fontangle','normal','fontweight','normal');
% 
% % 28Apr2004 M.Heinz - Add Gain field, and Voltage-display choice
% FIG.statText.gain = uicontrol(FIG.handle, 'callback', '', 'style', 'text','Units','normalized', 'position', [.02 .11 .15 .03], 'string', 'Gain (Electode to AD):','fontsize',12,'BackgroundColor','w');
% FIG.edit.gain     = uicontrol(FIG.handle,'callback','CAP(''Gain'');','style','edit','Units','normalized','position',[.17 .11 .07 .04],'string',Display.Gain,'fontsize',12);
% FIG.statText.voltDisplay = uicontrol(FIG.handle, 'callback', '', 'style', 'text','Units','normalized', 'position', [.003 .07 .15 .03], 'string', 'Display: voltage','fontsize',12,'BackgroundColor','w');
% FIG.radio.atAD    = uicontrol(FIG.handle,'callback','CAP(''atAD'');', 'style','radio','Enable','on','Units','normalized','position',[.135 .07 .13 .03],'string','at AD;  YLim (AD): ', 'fontsize',12,'BackgroundColor','w','value',strcmp(Display.Voltage,'atAD'));
% FIG.radio.atELEC  = uicontrol(FIG.handle,'callback','CAP(''atELEC'');','style','radio','Enable','on','Units','normalized','position',[.135 .04 .12 .03],'string','at Electrode','fontsize',12,'BackgroundColor','w','value',~strcmp(Display.Voltage,'atAD'));
% FIG.edit.yscale     = uicontrol(FIG.handle,'callback','CAP(''YLim'');','style','edit','Units','normalized','position',[.265 .07 .05 .04],'string',Display.YLim_atAD,'fontsize',12);
% 
% 
% % FIG.statText.spike_channel =  uicontrol(FIG.handle, 'callback', '', 'style', 'text','Units','normalized', 'position', [.1 .49 .13 .03], 'string', 'spike channel:','fontsize',12,'BackgroundColor','w');   % added by GE 17Jan2003.
% % FIG.popup.spike_channel = uicontrol(FIG.handle, 'callback', 'CAP(''spike_channel'');', 'style', 'popup', 'Enable', 'on','Units','normalized', 'position', [.22 .5 .035 .03], 'string', '1|2|3|4|5|6','fontsize',12,'BackgroundColor','w','value',1);   % added by GE 17Jan2003.
% 
% % if (isempty(strmatch('KH-oscillator', devices_names_vector,'exact')))
% %     set(FIG.radio.khite,'Enable','off');
% % end

end
