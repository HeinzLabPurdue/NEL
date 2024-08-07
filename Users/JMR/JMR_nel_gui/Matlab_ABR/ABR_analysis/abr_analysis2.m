function abr_analysis2(command_str,parm_num)

%This function computes an ABR threshold based on series of AVERAGER files.

global abr_FIG abr_Stimuli abr_root_dir abr_data_dir abr3


host = lower(getenv('hostname'));
% switch (host)
% case {'north-chamber'}
abr_root_dir = [NelData.General.RootDir 'Users\MH\Matlab_ABR'];  % added by GE 04Mar2004.
abr_data_dir = [NelData.General.RootDir 'ExpData\']; % added by GE 04Mar2004.
% case {'south-chamber'}
% 	abr_root_dir = 'c:\Users\GE\Matlab_ABR';  % added by GE 04Mar2004.
% 	abr_data_dir = 'c:\ExpData\'; % added by GE 04Mar2004.
% end   
   
if nargin < 1

    %CREATING STRUCTURES HERE
    PROG = struct('name','ABR.m','date',date,'version','rp2 v2.0');
    
    push = cell2struct(cell(1,4),{'process','print','close','edit'},2);
    ax1  = cell2struct(cell(1,7),{'axes','line1','line2','line3','xlab','ylab','title'},2);
    ax2  = cell2struct(cell(1,3),{'axes','xlab','ylab'},2);
    abrs  = cell2struct(cell(1,10),{'abr1','abr2','abr3','abr4','abr5','abr6','abr7','abr8','abr9','abr10'},2);
    abr_FIG = struct('handle',[],'push',push,'ax1',ax1,'ax2',ax2,'abrs',abrs,'parm_text',[],'dir_text',[]);
    
    get_analysis_ins2; %script creates struct Stimuli
    if ~exist('abr_Stimuli')|~isfield(abr_Stimuli, 'cal_pic')
      % LQ 01/09/04 when get_analysis_ins is corrupted        
      instruct_error;
    end
    
    abr_FIG.handle = figure('NumberTitle','off','Name','XCORR ABR Analysis','Units','normalized','Visible','off','position',[0 0.03 1 0.92],'CloseRequestFcn','abr_analysis2(''close'');');
    colordef none;
    whitebg('w');
    
    abr_FIG.push.process = uicontrol(abr_FIG.handle,'callback','abr_analysis2(''process'');','style','pushbutton','Units','normalized','position',[.05 .4 .1 .05],'string','Process');
    abr_FIG.push.print   = uicontrol(abr_FIG.handle,'callback','abr_analysis2(''print'');','style','pushbutton','Units','normalized','position',[.2125 .4 .1 .05],'string','Print');
    abr_FIG.push.file   = uicontrol(abr_FIG.handle,'callback','abr_analysis2(''file'');','style','pushbutton','Units','normalized','position',[.375 .4 .1 .05],'string','Save as File');
%     abr_FIG.push.edit    = uicontrol(abr_FIG.handle,'style','edit','Units','normalized','position',[.32 .08 .1 .04],'string',[],'FontSize',12);								
    abr_FIG.push.edit    = uicontrol(abr_FIG.handle,'style','edit', 'callback', 'abr_analysis2(''edit'');', ...
       'Units','normalized','position',[.32 .08 .1 .04],'string',[],'FontSize',12);								

%    abr_FIG.ax1.axes = axes('Position',[.05 .43 .4 .4]);
%    abr_FIG.ax1.axes = axes('Position',[.1 .45 .35 .3])  KH;
%    abr_FIG.ax1.line1 = plot(0,0,'b-','LineWidth',2,'Visible','off');
%    hold on;
%    abr_FIG.ax1.line2 = plot(0,0,'ro','Visible','off');
%    abr_FIG.ax1.line3 = plot(0,0,'r--','LineWidth',2,'Visible','off');
%    abr_FIG.ax1.xlab = xlabel('Stimulus level (dB SPL)','FontSize',14);
%    abr_FIG.ax1.ylab = ylabel('ABR (\muVolts)','FontSize',14,'Interpreter','tex');
%    abr_FIG.ax1.title = title('ABR Analysis','FontSize',14);
    
    axes('Position',[.1 .1 .35 .4]);
    axis('off');
%    text(.2,.65,'Directory:','fontsize',10,'color','k','horizontalalignment','left','VerticalAlignment','middle');
    text(.2,.55,'Calibration File:','fontsize',10,'color','k','horizontalalignment','left','VerticalAlignment','middle');
    text(.2,.45,'ABR Files:','fontsize',10,'color','k','horizontalalignment','left','VerticalAlignment','middle');
    text(.2,.37,'ABR template start (ms):','fontsize',10,'color','k','horizontalalignment','left','VerticalAlignment','middle');
    text(.2,.32,'ABR template end (ms):','fontsize',10,'color','k','horizontalalignment','left','VerticalAlignment','middle');
    text(.2,.24,'Index of outlier 1:','fontsize',10,'color','k','horizontalalignment','left','VerticalAlignment','middle');
    text(.2,.19,'Index of outlier 2:','fontsize',10,'color','k','horizontalalignment','left','VerticalAlignment','middle');
    text(.2,.09,'N template components:','fontsize',10,'color','k','horizontalalignment','left','VerticalAlignment','middle');
    
	
	
    abr_FIG.parm_txt(1)  = text(.8,.55,num2str(abr_Stimuli.cal_pic),   'fontsize',10,'color','b','horizontalalignment','right','buttondownfcn','abr_analysis2(''stimulus'',1);');
    abr_FIG.parm_txt(2)  = text(.8,.45,num2str(abr_Stimuli.abr_pic),   'fontsize',10,'color','b','horizontalalignment','right','buttondownfcn','abr_analysis2(''stimulus'',2);');
    abr_FIG.parm_txt(3)  = text(.8,.37,num2str(abr_Stimuli.start_resp),'fontsize',10,'color','b','horizontalalignment','right','buttondownfcn','abr_analysis2(''stimulus'',3);');
    abr_FIG.parm_txt(4)  = text(.8,.32,num2str(abr_Stimuli.end_resp),  'fontsize',10,'color','b','horizontalalignment','right','buttondownfcn','abr_analysis2(''stimulus'',4);');
    abr_FIG.parm_txt(5)  = text(.8,.24,num2str(abr_Stimuli.start_back),'fontsize',10,'color','b','horizontalalignment','right','buttondownfcn','abr_analysis2(''stimulus'',5);');
    abr_FIG.parm_txt(6)  = text(.8,.19,num2str(abr_Stimuli.end_back),  'fontsize',10,'color','b','horizontalalignment','right','buttondownfcn','abr_analysis2(''stimulus'',6);');
    abr_FIG.parm_txt(7)  = text(.8,.09,num2str(abr_Stimuli.scale),     'fontsize',10,'color','b','horizontalalignment','right','buttondownfcn','abr_analysis2(''stimulus'',7);');
    
    abr_FIG.dir_txt = text(.8,.65,abr_Stimuli.dir,'fontsize',10,'color','r','horizontalalignment','right','buttondownfcn','abr_analysis2(''directory'');','Interpreter','none');

	left = .50; bottom = .05; width = .45; height = .9;  % added by KH 06/09/2010
%    left = .55; bottom = .2; width = .35; height = .7;  % added by GE 14Apr2004.
%KH    abr_FIG.a2.axesR = axes('Position',[left+width bottom 0.001 height]); % for labelling right axis
	set(gca, 'FontSize', 12);
	set(gca, 'XTickMode', 'manual');
	set(gca, 'YAxisLocation', 'right');
	set(gca, 'YTickMode', 'manual');

%    abr_FIG.ax2.axes = axes('Position',[left bottom width height]);  % modified by GE 14Apr2004
%    abr_FIG.abrs.abr1 = plot(0,0,'b-','LineWidth',2,'Visible','off');
%    hold on;
%KH    for i = 2:10
%KH        eval(['abr_FIG.abrs.abr' num2str(i) ' = plot(0,0,''b-'',''LineWidth'',2,''Visible'',''off'');']);
%KH    end
%KH    abr_FIG.ax2.xlab = xlabel('Time (msec)','FontSize',14);
%KH    abr_FIG.ax2.ylab = ylabel('Stimulus level (dB SPL)','FontSize',14,'Interpreter','tex');
%KH    abr_FIG.ax2.rect = rectangle;  % added by GE 04Mar2004.
%KH    abr_FIG.ax2.rect2 = rectangle;  % added by GE 14Apr2004.

    set(abr_FIG.handle,'Userdata',struct('handles',abr_FIG));
    set(abr_FIG.handle,'Visible','on');
    drawnow;
    
elseif strcmp(command_str,'stimulus')
% MH 27Apr2004:  We'll change the calib # if we want!
   %         if parm_num == 1
%             warndlg('Do not change calibration picture!','Analysis Error');
%             set(abr_FIG.push.edit,'string',[]);
%             
%             
         if length(get(abr_FIG.push.edit,'string'))
            new_value = get(abr_FIG.push.edit,'string');
            set(abr_FIG.push.edit,'string',[]);
            set(abr_FIG.parm_txt(parm_num),'string',upper(new_value));
            switch parm_num
                case 1,
                    abr_Stimuli.cal_pic = new_value;
                case 2,
                   abr_Stimuli.abr_pic = new_value;
%                    abr_analysis('process');  % added by GE 14Apr2004
                case 3,
                   abr_Stimuli.start_resp = str2num(new_value);
                case 4,
                   abr_Stimuli.end_resp = str2num(new_value);
                case 5,
                   abr_Stimuli.start_back = str2num(new_value);
                case 6,
                   abr_Stimuli.end_back = str2num(new_value);
                case 7,
                   abr_Stimuli.scale = str2num(new_value);
            end
         else
            set(abr_FIG.push.edit,'string','ERROR');
         end
    
elseif strcmp(command_str,'directory')
    abr_Stimuli.dir = get_directory;
    set(abr_FIG.dir_txt,'string',abr_Stimuli.dir);
    
elseif strcmp(command_str,'process')
	thresh_calc2 %added by KH 06/09/2010
	%     [error] = thresh_calc;
	%ABR_anal_New
	%[error] = thresh_calc;
    set(abr_FIG.handle, 'CurrentObject', abr_FIG.push.edit);
    
elseif strcmp(command_str,'print')
    set(gcf,'PaperOrientation','Landscape','PaperPosition',[0 0 11 8.5]);
    if ispc
        print('-dwinc','-r200','-noui');
    else
        print('-PNeptune','-dpsc','-r200','-noui');
    end
    
elseif strcmp(command_str,'file')
    pic_dir = fullfile(abr_data_dir,'pictures');
    if ~exist(pic_dir)
        mkdir(abr_data_dir,'pictures');
    end 
    
    filename = inputdlg('Name the file:','File Manager',1);
    if isempty(filename)
        warndlg('File not saved.');
    else
        set(gcf,'PaperOrientation','Portrait','PaperPosition',[0 0 11 8.5]);
        print('-depsc','-noui',fullfile(pic_dir,char(filename))); %crashes this computer!!!!
        uiwait(msgbox('File has been saved.','File Manager','modal'));
    end

elseif strcmp(command_str,'edit') % added by GE 15Apr2004
%    abr_analysis('stimulus',2);

elseif strcmp(command_str,'close')
    update_params2;
    closereq;
end
