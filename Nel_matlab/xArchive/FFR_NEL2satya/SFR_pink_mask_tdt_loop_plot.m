% SP (8 May, 2017)--> changed to function

function [FIG, FFR_SNRenv_Gating, Display]=SFR_pink_mask_tdt_loop_plot(FIG,Display,Stimuli,interface_type)

fName=Stimuli.list;

gray_dark=[1 1 1];
gray_light=[1 1 1];
% gray_dark=[1 1 1]/1.5;

%% 
FIG.radio.fast   = uicontrol(FIG.handle,'callback','SFR_pink_mask_tdt(''fast'');','style','radio','Enable','on','Units','normalized','position',[.125 .315 .08 .03],'string','Fast','fontsize',12,'BackgroundColor','w','value',1);
FIG.radio.slow   = uicontrol(FIG.handle,'callback','SFR_pink_mask_tdt(''slow'');','style','radio','Enable','on','Units','normalized','position',[.125 .285 .08 .03],'string','Slow','fontsize',12,'BackgroundColor','w','value',0);

FIG.push.close   = uicontrol(FIG.handle,'callback','SFR_pink_mask_tdt(''close'');','style','pushbutton','Units','normalized','position',[.1 .6 .125 .09],'string','Close','fontsize',12,'fontangle','normal','fontweight','normal');

%% Stimulus menu 
FIG.popup.stims = uicontrol(FIG.handle,'callback', 'SFR_pink_mask_tdt(''update_stim'',''newStim'');','style','popup','Units','normalized','Userdata',Stimuli.filename, ...
    'value', find(strcmp(struct2cell(Stimuli.list), Stimuli.filename)), 'position',[.4 .175 .425 .04],'string',struct2cell(fName),'fontsize',12);
FIG.push.prev_stim = uicontrol(FIG.handle,'callback','SFR_pink_mask_tdt(''update_stim'',''prevStim'');','style','pushbutton','Units','normalized','position',[.35 .175 .05 .04],'string','<<','fontsize',12,'fontangle','normal','fontweight','normal');
FIG.push.next_stim = uicontrol(FIG.handle,'callback','SFR_pink_mask_tdt(''update_stim'',''nextStim'');','style','pushbutton','Units','normalized','position',[.825 .175 .05 .04],'string','>>','fontsize',12,'fontangle','normal','fontweight','normal');

%% Intensity buttongroup
bf_def_enable= 'on';
FIG.bg.SNR.parent= uibuttongroup('visible','on','Position',[.35 .12 .3 .05],'BackgroundColor',gray_light);
FIG.bg.SNR.dB_m20=uicontrol('parent',FIG.bg.SNR.parent,'style','radio','Enable',bf_def_enable,'Units','normalized','position',[0 0 .5 1],'string','dB_m20','fontsize',12,'BackgroundColor',gray_light,'value',1);
FIG.bg.SNR.dB_m10=uicontrol('parent',FIG.bg.SNR.parent,'style','radio','Enable',bf_def_enable,'Units','normalized','position',[.2 0 .5 1],'string','dB_m10','fontsize',12,'BackgroundColor',gray_light,'value',1);
FIG.bg.SNR.dB_0=uicontrol('parent',FIG.bg.SNR.parent,'style','radio','Enable',bf_def_enable,'Units','normalized','position',[.4 0 .5 1],'string','dB_0','fontsize',12,'BackgroundColor',gray_light,'value',1);
FIG.bg.SNR.dB_p10=uicontrol('parent',FIG.bg.SNR.parent,'style','radio','Enable',bf_def_enable,'Units','normalized','position',[.6 0 .5 1],'string','dB_p10','fontsize',12,'BackgroundColor',gray_light,'value',1);
FIG.bg.SNR.dB_p120=uicontrol('parent',FIG.bg.SNR.parent,'style','radio','Enable',bf_def_enable,'Units','normalized','position',[.8 0 .5 1],'string','dB_p120','fontsize',12,'BackgroundColor',gray_light,'value',1);
set(FIG.bg.SNR.parent, 'SelectedObject', FIG.bg.SNR.dB_p120);
set(FIG.bg.SNR.parent,'SelectionChangeFcn','SFR_pink_mask_tdt(''update_stim'',''SNR'');');

% % % %% 14 stim/ 22 stim buttongroup
% % % bf_def_enable= 'off';
% % % FIG.bg.stim.parent= uibuttongroup('visible','on','Position',[.5 .12 .24 .05],'BackgroundColor',gray_light);
% % % FIG.bg.stim.stim14=uicontrol('parent',FIG.bg.stim.parent,'style','radio','Enable',bf_def_enable,'Units','normalized','position',[0 0 .5 1],'string','14-stim','fontsize',12,'BackgroundColor',gray_light,'value',1);
% % % FIG.bg.stim.stim22=uicontrol('parent',FIG.bg.stim.parent,'callback','SFR_pink_mask_tdt(''update_stim'',18);','style','radio','Enable',bf_def_enable,'Units','normalized','position',[.5 0 .5 1],'string','22-stim','fontsize',12,'BackgroundColor',gray_light,'value',1);
% % % set(FIG.bg.stim.parent, 'SelectedObject', FIG.bg.stim.stim14);
% % % set(FIG.bg.stim.parent,'SelectionChangeFcn','SFR_pink_mask_tdt(''update_stim'',''list'');');
% % % 
% % % %% SSN/FN buttongroup
% % % FIG.bg.nt.parent= uibuttongroup('visible','on','Position',[.75 .12 .12 .05],'BackgroundColor',gray_light);
% % % FIG.bg.nt.nt_ssn=uicontrol('parent',FIG.bg.nt.parent,'style','radio','Enable',bf_def_enable,'Units','normalized','position',[0 0 .5 1],'string','SSN','fontsize',12,'BackgroundColor',gray_light,'value',1); % steady state
% % % FIG.bg.nt.nt_f=uicontrol('parent',FIG.bg.nt.parent,'style','radio','Enable',bf_def_enable,'Units','normalized','position',[.5 0 .5 1],'string','FN','fontsize',12,'BackgroundColor',gray_light,'value',1); %fluctuating
% % % set(FIG.bg.nt.parent, 'SelectedObject', FIG.bg.nt.nt_ssn);
% % % set(FIG.bg.nt.parent,'SelectionChangeFcn','SFR_pink_mask_tdt(''update_stim'',''noise_type'');');

%% Rest
% zz 7feb12
%% SPL slider
FIG.asldr.slider = uicontrol(FIG.handle,'callback','SFR_pink_mask_tdt(''slide_atten'');','style','slider','SliderStep',[1/120 5/120],'Enable','on','min',-120,'max',0,'Units','normalized','position',[.35 .075 .525 .04],'Value',-Stimuli.atten_dB);
FIG.asldr.min    = uicontrol(FIG.handle,'style','text','string',num2str(get(FIG.asldr.slider,'min')),'backgroundcolor',gray_dark,'Units','normalized','position',[.33 .04 .05 .03],'fontsize',10);
FIG.asldr.max    = uicontrol(FIG.handle,'style','text','string',num2str(get(FIG.asldr.slider,'max')),'backgroundcolor',gray_dark,'Units','normalized','position',[.825 .04 .05 .03],'fontsize',10,'horizontalalignment','right');
FIG.asldr.val    = uicontrol(FIG.handle,'style','edit','Units','normalized','Userdata',Stimuli.atten_dB,'position',[.5825 .075 .06 .04],'string',num2str(-Stimuli.atten_dB),'fontsize',12,'callback', 'SFR_pink_mask_tdt(''slide_atten_text'');');


%% LQ 01/31/05 add callback
FIG.statText.memReps =  uicontrol(FIG.handle, 'style', 'text','Units','normalized', 'position', [.05 .49 .12 .03], 'string', 'Forget Time (reps):','fontsize',12,'BackgroundColor','w');   % added by GE 17Jan2003.
FIG.statText.threshV =  uicontrol(FIG.handle, 'style', 'text','Units','normalized', 'position', [.05 .54 .12 .03], 'string', 'Reject thresh (V):','fontsize',12,'BackgroundColor','w');   % added by khZZ 2011 Nov 4
FIG.edit.threshV = uicontrol(FIG.handle,'callback','SFR_pink_mask_tdt(''threshV'');','style','edit','Units','normalized','position',[.18 .54 .04 .04],'string',Stimuli.threshV,'fontsize',12); % KHZZ 2011 Nov 4
FIG.edit.memReps = uicontrol(FIG.handle,'callback','SFR_pink_mask_tdt(''memReps'');','style','edit','Units','normalized','position',[.18 .49 .04 .04],'string',Stimuli.FFRmem_reps,'fontsize',12);

FIG.statText.status =  uicontrol(FIG.handle, 'style', 'text','Units','normalized', 'position', [.05 .9 .25 .03], 'string', ['STATUS (' interface_type '): free running...'],'fontsize',12,'BackgroundColor','w','horizontalalignment','left');   % added by GE 17Jan2003.

%% Speakers
FIG.radio.left   = uicontrol(FIG.handle,'callback','SFR_pink_mask_tdt(''left'');', 'style','radio','Enable','on','Units','normalized','position',[.125 .235 .08 .03],'string','Left Ear', 'fontsize',12,'BackgroundColor','w','value',0);
FIG.radio.right  = uicontrol(FIG.handle,'callback','SFR_pink_mask_tdt(''right'');','style','radio','Enable','on','Units','normalized','position',[.125 .205 .08 .03],'string','Right Ear','fontsize',12,'BackgroundColor','w','value',0);
FIG.radio.both   = uicontrol(FIG.handle,'callback','SFR_pink_mask_tdt(''both'');', 'style','radio','Enable','on','Units','normalized','position',[.125 .175 .08 .03],'string','Both Ears','fontsize',12,'BackgroundColor','w','value',1);

% zz 07nov11 added save now function
% FIG.push.save_now   = 
FIG.push.run_levels = uicontrol(FIG.handle,'callback','SFR_pink_mask_tdt(''run_levels'');','style','pushbutton','Units','normalized','position',[.1 .726 .125 .09],'string','Run levels...','fontsize',12,'fontangle','normal','fontweight','normal');
FIG.push.forget_now = uicontrol(FIG.handle,'callback','SFR_pink_mask_tdt(''forget_now'');','style','pushbutton','Units','normalized','position',[.07 .43 .125 .05],'string','Forget NOW','fontsize',12,'fontangle','normal','fontweight','normal','Userdata','');

% 28Apr2004 M.Heinz - Add Gain field, and Voltage-display choice
FIG.statText.gain = uicontrol(FIG.handle, 'style', 'text','Units','normalized', 'position', [.02 .11 .15 .03], 'string', 'Gain (Electode to AD):','fontsize',12,'BackgroundColor','w');
FIG.edit.gain     = uicontrol(FIG.handle,'callback','SFR_pink_mask_tdt(''Gain'');','style','edit','Units','normalized','position',[.17 .11 .07 .04],'string',Display.Gain,'fontsize',12);
FIG.statText.voltDisplay = uicontrol(FIG.handle, 'style', 'text','Units','normalized', 'position', [.003 .07 .15 .03], 'string', 'Display: voltage','fontsize',12,'BackgroundColor','w');
FIG.radio.atAD    = uicontrol(FIG.handle,'callback','SFR_pink_mask_tdt(''atAD'');', 'style','radio','Enable','on','Units','normalized','position',[.135 .07 .13 .03],'string','at AD;  YLim (AD): ', 'fontsize',12,'BackgroundColor','w','value',strcmp(Display.Voltage,'atAD'));
FIG.radio.atELEC  = uicontrol(FIG.handle,'callback','SFR_pink_mask_tdt(''atELEC'');','style','radio','Enable','on','Units','normalized','position',[.135 .04 .12 .03],'string','at Electrode','fontsize',12,'BackgroundColor','w','value',~strcmp(Display.Voltage,'atAD'));
FIG.edit.yscale     = uicontrol(FIG.handle,'callback','SFR_pink_mask_tdt(''YLim'');','style','edit','Units','normalized','position',[.265 .07 .05 .04],'string',Display.YLim_atAD,'fontsize',12);


% FIG.statText.spike_channel =  uicontrol(FIG.handle, 'callback', '', 'style', 'text','Units','normalized', 'position', [.1 .49 .13 .03], 'string', 'spike channel:','fontsize',12,'BackgroundColor','w');   % added by GE 17Jan2003.
% FIG.popup.spike_channel = uicontrol(FIG.handle, 'callback', 'SFR_pink_mask_tdt(''spike_channel'');', 'style', 'popup', 'Enable', 'on','Units','normalized', 'position', [.22 .5 .035 .03], 'string', '1|2|3|4|5|6','fontsize',12,'BackgroundColor','w','value',1);   % added by GE 17Jan2003.

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
   FFR_SNRenv_Gating=Stimuli.fast;
else
   FFR_SNRenv_Gating=Stimuli.slow;
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
