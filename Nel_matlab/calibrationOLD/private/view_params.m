function view_params(command_str,txt_num)
global Stimuli View

if nargin < 1	
   
   %CREATING STRUCTURES HERE
   push = cell2struct(cell(1,7),{'default','update','close','steps','chan','calib','edit'},2);
   View = struct('handle',[],'push',push,'parm_txt',[]);
   
   %MAKING FIGURE AND INTERFACE
   View.handle = figure('NumberTitle','off','Name','Parameters','Units','normalized','position',[.25 .2 .5 .6]);
   axes('Position',[0 0 1 1]);
   axis('off');
   
   text(.445,.75,'Name','fontsize',16,'color','k','horizontalalignment','right','VerticalAlignment','middle','EraseMode','none');
   text(.6,.75,'Value','fontsize',16,'color','k','horizontalalignment','right','VerticalAlignment','middle','EraseMode','none');
   text(.445,.70,'Low Freq:','fontsize',10,'color','k','horizontalalignment','right','VerticalAlignment','middle','EraseMode','none');
   text(.445,.67,'High Freq:','fontsize',10,'color','k','horizontalalignment','right','VerticalAlignment','middle','EraseMode','none');
   text(.445,.61,'Low BP:','fontsize',10,'color','k','horizontalalignment','right','VerticalAlignment','middle','EraseMode','none');
   text(.445,.58,'High BP:','fontsize',10,'color','k','horizontalalignment','right','VerticalAlignment','middle','EraseMode','none');
   text(.445,.55,'Low Notch60:','fontsize',10,'color','k','horizontalalignment','right','VerticalAlignment','middle','EraseMode','none');
   text(.445,.52,'High Notch60:','fontsize',10,'color','k','horizontalalignment','right','VerticalAlignment','middle','EraseMode','none');
   text(.445,.49,'Low Notch120:','fontsize',10,'color','k','horizontalalignment','right','VerticalAlignment','middle','EraseMode','none');
   text(.445,.46,'High Notch120:','fontsize',10,'color','k','horizontalalignment','right','VerticalAlignment','middle','EraseMode','none');
   text(.445,.43,'Base Attenuation:','fontsize',10,'color','k','horizontalalignment','right','VerticalAlignment','middle','EraseMode','none');
   text(.445,.40,'Slope:','fontsize',10,'color','k','horizontalalignment','right','VerticalAlignment','middle','EraseMode','none');
   text(.445,.37,'Corner Freq:','fontsize',10,'color','k','horizontalalignment','right','VerticalAlignment','middle','EraseMode','none');
   text(.445,.34,'Mic Num:','fontsize',10,'color','k','horizontalalignment','right','VerticalAlignment','middle','EraseMode','none');
   text(.445,.31,'Criterion:','fontsize',10,'color','k','horizontalalignment','right','VerticalAlignment','middle','EraseMode','none');
   text(.445,.64,'Step Size:','fontsize',10,'color','k','horizontalalignment','right','VerticalAlignment','middle','EraseMode','none');
   
   View.parm_txt(1)  = text(.6,.70,num2str(Stimuli.frqlo), 'fontsize',10,'color',[.1 .1 .6],'horizontalalignment','right','VerticalAlignment','middle','EraseMode','normal','buttondownfcn','view_params(''stimulus'',1);');
   View.parm_txt(2)  = text(.6,.67,num2str(Stimuli.frqhi), 'fontsize',10,'color',[.1 .1 .6],'horizontalalignment','right','VerticalAlignment','middle','EraseMode','normal','buttondownfcn','view_params(''stimulus'',2);');
   View.parm_txt(3)  = text(.6,.61,num2str(Stimuli.bplo), 'fontsize',10,'color',[.1 .1 .6],'horizontalalignment','right','VerticalAlignment','middle','EraseMode','normal','buttondownfcn','view_params(''stimulus'',3);');
   View.parm_txt(4)  = text(.6,.58,num2str(Stimuli.bphi), 'fontsize',10,'color',[.1 .1 .6],'horizontalalignment','right','VerticalAlignment','middle','EraseMode','normal','buttondownfcn','view_params(''stimulus'',4);');
   View.parm_txt(5)  = text(.6,.55,num2str(Stimuli.n60lo), 'fontsize',10,'color',[.1 .1 .6],'horizontalalignment','right','VerticalAlignment','middle','EraseMode','normal','buttondownfcn','view_params(''stimulus'',5);');
   View.parm_txt(6)  = text(.6,.52,num2str(Stimuli.n60hi), 'fontsize',10,'color',[.1 .1 .6],'horizontalalignment','right','VerticalAlignment','middle','EraseMode','normal','buttondownfcn','view_params(''stimulus'',6);');
   View.parm_txt(7)  = text(.6,.49,num2str(Stimuli.n120lo), 'fontsize',10,'color',[.1 .1 .6],'horizontalalignment','right','VerticalAlignment','middle','EraseMode','normal','buttondownfcn','view_params(''stimulus'',7);');
   View.parm_txt(8)  = text(.6,.46,num2str(Stimuli.n120hi),'fontsize',10,'color',[.1 .1 .6],'horizontalalignment','right','VerticalAlignment','middle','EraseMode','normal','buttondownfcn','view_params(''stimulus'',8);');
   View.parm_txt(9)  = text(.6,.43,num2str(Stimuli.syslv),'fontsize',10,'color',[.1 .1 .6],'horizontalalignment','right','VerticalAlignment','middle','EraseMode','normal','buttondownfcn','view_params(''stimulus'',9);');
   View.parm_txt(10) = text(.6,.40,num2str(Stimuli.lvslp),'fontsize',10,'color',[.1 .1 .6],'horizontalalignment','right','VerticalAlignment','middle','EraseMode','normal','buttondownfcn','view_params(''stimulus'',10);');
   View.parm_txt(11) = text(.6,.37,num2str(Stimuli.frqcnr),'fontsize',10,'color',[.1 .1 .6],'horizontalalignment','right','VerticalAlignment','middle','EraseMode','normal','buttondownfcn','view_params(''stimulus'',11);');
   View.parm_txt(12) = text(.6,.34,Stimuli.nmic,'fontsize',10,               'color',[.1 .1 .6],'horizontalalignment','right','VerticalAlignment','middle','EraseMode','normal','buttondownfcn','view_params(''stimulus'',12);');
   View.parm_txt(13) = text(.6,.31,num2str(Stimuli.crit),'fontsize',10,'color',[.1 .1 .6],'horizontalalignment','right','VerticalAlignment','middle','EraseMode','normal','buttondownfcn','view_params(''stimulus'',13);');
   View.parm_txt(14) = text(.6,.64,num2str(max(Stimuli.fstlin,Stimuli.fstoct)),'fontsize',10,'color',[.1 .1 .6],'horizontalalignment','right','VerticalAlignment','middle','EraseMode','normal','buttondownfcn','view_params(''stimulus'',14);');
   
   
   View.push.default= uicontrol(View.handle,'callback','view_params(''defs'');','style','pushbutton','Units','normalized','position',[.2 .85 .15 .075],'string','Defaults');
   View.push.update = uicontrol(View.handle,'callback','view_params(''update'');','style','pushbutton','Units','normalized','position',[.425 .85 .15 .075],'string','Update','Enable','off','ForeGroundColor','r');
   View.push.close  = uicontrol(View.handle,'callback','view_params(''close'');','style','pushbutton','Units','normalized','position',[.65 .85 .15 .075],'string','Close');
   View.push.steps  = uicontrol(View.handle,'callback','view_params(''steps'');','style','pushbutton','Units','normalized','position',[.23 .1 .14 .05]);
   View.push.chan   = uicontrol(View.handle,'callback','view_params(''chan'');','style','pushbutton','Units','normalized','position',[.43 .1 .14 .05]);								
   View.push.calib  = uicontrol(View.handle,'callback','view_params(''calib'');','style','pushbutton','Units','normalized','position',[.63 .1 .14 .05]);								
   View.push.edit   = uicontrol(View.handle,'style','edit','Units','normalized','position',[.70 .5 .14 .05],'string',[],'FontSize',12);								
   
   if Stimuli.fstoct == 0,
      set(View.push.steps,'string','Linear Steps');
   else
      set(View.push.steps,'string','Log Steps');
   end
   
   if Stimuli.ear == 1,
      set(View.push.chan,'string','Left Channel');
   else
      set(View.push.chan,'string','Right Channel');
   end
   
   if Stimuli.cal == 1,
      set(View.push.calib,'string','Plot in SPL');
   else
      set(View.push.calib,'string','Plot in Volts');
   end
   
   set(View.handle,'Userdata',struct('handles',View));    
   
elseif strcmp(command_str,'stimulus')
   if length(get(View.push.edit,'string'))
      set(View.push.update,'Enable','on');
      input_txt = lower(get(View.push.edit,'string'));
      switch txt_num
      case 1,
         Stimuli.frqlo = str2num(input_txt);
      case 2,
         Stimuli.frqhi = str2num(input_txt);
      case 3,
         Stimuli.bplo = str2num(input_txt);
      case 4,
         Stimuli.bphi = str2num(input_txt);
      case 5,
         Stimuli.n601o = str2num(input_txt);
      case 6,
         Stimuli.n60hi = str2num(input_txt);
      case 7,
         Stimuli.n120lo = str2num(input_txt);
      case 8,
         Stimuli.n120hi = str2num(input_txt);
      case 9,
         Stimuli.syslv = str2num(input_txt);
      case 10,
         Stimuli.lvslp = str2num(input_txt);
      case 11,
         Stimuli.frqcnr = str2num(input_txt);
      case 12,
         filename = ['mic' input_txt '.m'];
         if exist(filename,'file')
            Stimuli.nmic = input_txt;
         else
            input_txt = Stimuli.nmic;
            warndlg('Microphone file not found!','File Manager');
         end
      case 13,
         Stimuli.crit = str2num(input_txt);
      case 14,
         if Stimuli.fstlin == 0
            Stimuli.fstoct = str2num(input_txt);
         else
            Stimuli.fstlin = str2num(input_txt);
         end
      end
      set(View.parm_txt(txt_num),'String',input_txt);
      set(View.push.edit,'String',[]);
   else
      set(View.push.edit,'String','ERROR');
   end
   
elseif strcmp(command_str,'steps')
   set(View.push.update,'Enable','on');
   if Stimuli.fstoct == 0
      Stimuli.fstoct = str2num(get(View.parm_txt(14),'string'));
      Stimuli.fstlin = 0;
      set(View.push.steps,'string','Log Steps');
   elseif Stimuli.fstlin == 0
      Stimuli.fstlin = str2num(get(View.parm_txt(14),'string'));
      Stimuli.fstoct = 0;
      set(View.push.steps,'string','Linear Steps');
   end
   
elseif strcmp(command_str,'chan')
   set(View.push.update,'Enable','on');
   if Stimuli.ear == 2
      Stimuli.ear = 1;
      set(View.push.chan,'string','Left Channel');
   elseif Stimuli.ear == 1
      Stimuli.ear = 2;
      set(View.push.chan,'string','Right Channel');
   end
   
elseif strcmp(command_str,'calib')
   set(View.push.update,'Enable','on');
   if Stimuli.cal == 1
      Stimuli.cal = 0;
      set(View.push.calib,'string','Plot in Volts');
   elseif Stimuli.cal == 0
      Stimuli.cal = 1;
      set(View.push.calib,'string','Plot in SPL');
   end
   
elseif strcmp(command_str,'defs')
   set(View.push.update,'Enable','on');
   Stimuli = struct('frqlo', 2.000, ...
      'frqhi', 40.000, ...
      'fstlin', 0.000, ...
      'fstoct',10.000, ...
      'bplo',   0.125, ...
      'bphi',  64.000, ...
      'n60lo',  2.000, ...
      'n60hi', 64.000, ...
      'n120lo', 2.000, ...
      'n120hi',64.000, ...
      'ear',    1.000, ...
      'syslv', 20.000, ...
      'lvslp',  0.000, ...
      'frqcnr', 4.000, ...
      'cal',    1.000, ...
      'nmic',  '067g', ...
      'crit',  50.000);
   set(View.parm_txt(1),'String',num2str(Stimuli.frqlo));
   set(View.parm_txt(2),'String',num2str(Stimuli.frqhi));
   set(View.parm_txt(3),'String',num2str(Stimuli.bplo));
   set(View.parm_txt(4),'String',num2str(Stimuli.bphi));
   set(View.parm_txt(5),'String',num2str(Stimuli.n60lo));
   set(View.parm_txt(6),'String',num2str(Stimuli.n60hi));
   set(View.parm_txt(7),'String',num2str(Stimuli.n120lo));
   set(View.parm_txt(8),'String',num2str(Stimuli.n120hi));
   set(View.parm_txt(9),'String',num2str(Stimuli.syslv));
   set(View.parm_txt(10),'String',num2str(Stimuli.lvslp));
   set(View.parm_txt(11),'String',num2str(Stimuli.frqcnr));
   set(View.parm_txt(12),'String',Stimuli.nmic);
   set(View.parm_txt(13),'String',num2str(Stimuli.crit));
   set(View.parm_txt(14),'String',num2str(Stimuli.fstoct));
   set(View.push.steps,'string','Log Steps');
   set(View.push.chan,'string','Left Channel');
   set(View.push.calib,'string','Plot in SPL');
   
elseif strcmp(command_str,'update')
   close('Parameters');
   update_params;
   calibrate('return from parameter change');
   
elseif strcmp(command_str,'close')
   close('Parameters');
   calibrate('return from parameter change');
end
