UNIT = sprintf('%1d.%02d', NelData.File_Manager.track.No, NelData.File_Manager.unit.No);

FIG.radio.noise  = uicontrol(FIG.handle,'callback','search(''noise'');','style','radio','Enable','on','Units','normalized','position',[.125 .425 .08 .03],'string','Noise','fontsize',12,'BackgroundColor','w','value',0);
FIG.radio.tone   = uicontrol(FIG.handle,'callback','search(''tone'');','style','radio','Enable','on','Units','normalized','position',[.125 .395 .08 .03],'string','Tone','fontsize',12,'BackgroundColor','w','value',1);
FIG.radio.khite  = uicontrol(FIG.handle,'callback','search(''khite'');','style','radio','Enable','on','Units','normalized','position',[.125 .365 .08 .03],'string','KH Osc','fontsize',12,'BackgroundColor','w','value',0);
FIG.radio.fast   = uicontrol(FIG.handle,'callback','search(''fast'');','style','radio','Enable','on','Units','normalized','position',[.125 .315 .08 .03],'string','Fast','fontsize',12,'BackgroundColor','w','value',1);
FIG.radio.slow   = uicontrol(FIG.handle,'callback','search(''slow'');','style','radio','Enable','on','Units','normalized','position',[.125 .285 .08 .03],'string','Slow','fontsize',12,'BackgroundColor','w');
FIG.push.close   = uicontrol(FIG.handle,'callback','search(''close'');','style','pushbutton','Units','normalized','position',[.1 .6 .125 .09],'string','Close','fontsize',12,'fontangle','normal','fontweight','normal');
FIG.fsldr.slider = uicontrol(FIG.handle,'callback','search(''slide_freq'');','style','slider','SliderStep',[0.001 0.01],'Enable','on','min',100,'max',1000,'Units','normalized','position',[.35 .175 .525 .04],'Value',Stimuli.freq_hz/Stimuli.fmult);
FIG.fsldr.min    = uicontrol(FIG.handle,'style','text','string',num2str(get(FIG.fsldr.slider,'min')),'backgroundcolor',[1 1 1],'Units','normalized','position',[.33 .14 .05 .03],'fontsize',10);
FIG.fsldr.max    = uicontrol(FIG.handle,'style','text','string',num2str(get(FIG.fsldr.slider,'max')),'backgroundcolor',[1 1 1],'Units','normalized','position',[.835 .14 .05 .03],'fontsize',10,'horizontalalignment','right');
% LQ 01/28/05 add callback
%FIG.fsldr.val    = uicontrol(FIG.handle,'style','edit','Units','normalized','position',[.5825 .175 .06 .04],'string','noise','fontsize',12);
FIG.fsldr.val    = uicontrol(FIG.handle,'style','edit','Units', 'normalized','position',[.5825 .175 .06 .04],'string','tone','fontsize',12, 'callback', 'search(''slide_freq_text'');');
FIG.asldr.slider = uicontrol(FIG.handle,'callback','search(''slide_atten'');','style','slider','SliderStep',[0.00833 0.0833],'Enable','on','min',-120,'max',0,'Units','normalized','position',[.35 .075 .525 .04],'Value',-Stimuli.atten);
FIG.asldr.min    = uicontrol(FIG.handle,'style','text','string',num2str(get(FIG.asldr.slider,'min')),'backgroundcolor',[1 1 1],'Units','normalized','position',[.33 .04 .05 .03],'fontsize',10);
FIG.asldr.max    = uicontrol(FIG.handle,'style','text','string',num2str(get(FIG.asldr.slider,'max')),'backgroundcolor',[1 1 1],'Units','normalized','position',[.825 .04 .05 .03],'fontsize',10,'horizontalalignment','right');
% LQ 01/28/05 add callback
%FIG.asldr.val    = uicontrol(FIG.handle,'style','edit','Units','normalized','Userdata',Stimuli.atten,'position',[.5825 .075 .06 .04],'string',num2str(-Stimuli.atten),'fontsize',12);
FIG.asldr.val    = uicontrol(FIG.handle,'style','edit','Units', 'normalized','Userdata', Stimuli.atten,'position',[.5825 .075 .06 .04],'string',num2str(-Stimuli.atten),'fontsize',12, 'callback', 'search(''slide_atten_text'');');
FIG.edit         = uicontrol(FIG.handle,'Visible','off','style','edit','Units','normalized','position',[.12 .75 .1 .04],'string',num2str(UNIT),'fontsize',14);

FIG.push.x1      = uicontrol(FIG.handle,'callback','search(''mult_1x'');','style','pushbutton','Enable','on','Units','normalized','position',[.5 .23 .05 .037],'string','1X','fontsize',12,'fontangle','normal','fontweight','normal','foregroundcolor',[0 0 0]);
FIG.push.x10     = uicontrol(FIG.handle,'callback','search(''mult_10x'');','style','pushbutton','Enable','on','Units','normalized','position',[.585 .23 .05 .037],'string','10X','fontsize',12,'fontangle','normal','fontweight','normal','foregroundcolor',[.7 .7 .7]);
FIG.push.x100    = uicontrol(FIG.handle,'callback','search(''mult_100x'');','style','pushbutton','Enable','on','Units','normalized','position',[.67 .23 .05 .037],'string','100X','fontsize',12,'fontangle','normal','fontweight','normal','foregroundcolor',[.7 .7 .7]);

FIG.radio.left   = uicontrol(FIG.handle,'callback','search(''left'');', 'style','radio','Enable','on','Units','normalized','position',[.125 .235 .08 .03],'string','Left Ear', 'fontsize',12,'BackgroundColor','w','value',1);
FIG.radio.right  = uicontrol(FIG.handle,'callback','search(''right'');','style','radio','Enable','on','Units','normalized','position',[.125 .205 .08 .03],'string','Right Ear','fontsize',12,'BackgroundColor','w','value',0);
FIG.radio.both   = uicontrol(FIG.handle,'callback','search(''both'');', 'style','radio','Enable','on','Units','normalized','position',[.125 .175 .08 .03],'string','Both Ears','fontsize',12,'BackgroundColor','w','value',0);

FIG.statText.spike_channel =  uicontrol(FIG.handle, 'callback', '', 'style', 'text','Units','normalized', 'position', [.1 .49 .13 .03], 'string', 'spike channel:','fontsize',12,'BackgroundColor','w');   % added by GE 17Jan2003.
FIG.popup.spike_channel = uicontrol(FIG.handle, 'callback', 'search(''spike_channel'');', 'style', 'popup', 'Enable', 'on','Units','normalized', 'position', [.22 .5 .035 .03], 'string', '1|2|3|4|5|6','fontsize',12,'BackgroundColor','w','value',1);   % added by GE 17Jan2003.

if (isempty(strmatch('KH-oscillator', devices_names_vector,'exact')))
    set(FIG.radio.khite,'Enable','off');
end
if (search_set_attns(0,1,0) == 0)
    set(FIG.radio.left,'Enable','off');
end    
if (search_set_attns(0,2,0) == 0)
    set(FIG.radio.right,'Enable','off');
end
set(FIG.handle,'Userdata',struct('handles',FIG));
set(FIG.handle,'Visible','on');
drawnow;
