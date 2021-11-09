function QuickCal(command_str)

%THIS IS THE MAIN PROGRAM FOR THE SR530 LOCK-IN AMP

%THE FOLLOWING STRUCTURES ARE SHARED ACROSS FUNCTIONS

global PROG FIG Stimuli DDATA NelData data_dir root_dir home_dir

if nargin < 1			
    
    %CREATING STRUCTURES HERE
    PROG = struct('name','QuickCal.m','date',date,'version','rp2 v1.0');
    
    push = cell2struct(cell(1,3),{'stop','calib','recall'},2);
    ax1  = cell2struct(cell(1,3),{'axes','line1','ord_text'},2);
    ax2  = cell2struct(cell(1,4),{'axes','ProgHead','ProgData','ProgMess'},2);
    ax3  = cell2struct(cell(1,2),{'ParamData1','ParamData2'},2);
    FIG = struct('handle',[],'push',push,'ax1',ax1,'ax2',ax2,'ax3',ax3);
    %Stimuli structure is found in get_cal_ins
    get_cal_ins;
    
    %NelData file structure is found in explist
    explist;
    
    %MAKING FIGURE AND USER INTERFACE
    FIG.handle = figure('NumberTitle','off','Name','Calibration Interface','Units','normalized','Visible','off','position',[0 0 1 .95],'CloseRequestFcn','QuickCal(''abort'')');
    colordef none;
    whitebg('w');
    
    CalPlot;	
    
    set(FIG.handle,'Visible','on');
    drawnow;
    
elseif strcmp(command_str,'stop')
    set(FIG.push.stop,'Userdata',1);
    
elseif strcmp(command_str,'calibrate')
    ReturnCal;
    set(FIG.push.stop,'Enable','on');
    set(FIG.push.recall,'Enable','off');
    set(FIG.push.calib,'Enable','off');
    error = 0;
    % Print Title and description.
    
    % *** Main Data Collection Loop ***
    DDATA = noise_cal;
    if ~length(get(FIG.push.stop,'Userdata'))
        low_lim = floor(min(DDATA(:,2))/20)*20;
        up_lim  = ceil( max(DDATA(:,2))/20)*20;
        set(FIG.ax1.axes,'YLim',[low_lim up_lim]);
        set(FIG.ax1.line1,'XData',DDATA(:,1),'YData',DDATA(:,2));
        drawnow;
        
        %************ Saving Data ******************
        if error<=0    
            ButtonName=questdlg('Do you wish to save these data?', ...
                'Save Prompt', ...
                'Yes','No','Comment','Yes');
            
            switch ButtonName,
                case 'Yes',
                    comment='No comment.';
                case 'Comment'
                    comment=add_comment_line;	%add a comment line before saving data file
            end
            
            if strcmp(ButtonName,'Yes') |  strcmp(ButtonName,'Comment'),
                NelData.General.fnum = make_calib_text_file(comment);
                UpdateExplist(NelData.General.fnum);
            end
        end
    end
    
    %****** End of data collection loop ********
    
    set(FIG.push.stop,'Userdata',[]);
    set(FIG.push.stop,'Enable','off');
    set(FIG.push.recall,'Enable','on');
    set(FIG.push.calib,'Enable','on');
    set(FIG.ax2.ProgMess,'String','Ready for input...');
    drawnow;
    
elseif strcmp(command_str,'mic')
    new_value = inputdlg({'Enter 3 digit microphone number:'},'Microphone Editor',1,{'168'});
    if length(new_value),
        Stimuli.nmic = char(new_value);
        update_params;
        set(FIG.ax3.ParamData1,'String',Stimuli.nmic);
        drawnow;
    end
    
elseif strcmp(command_str,'params')
    fighandle = view_params;
    uiwait(fighandle);
    ReturnCal;
    
elseif strcmp(command_str,'recall')
    eval('read_cal_file');
    set(FIG.push.recall,'Enable','on');
    set(FIG.push.calib,'Enable','on');
    drawnow;
    
elseif strcmp(command_str,'abort')
    if strcmp(get(FIG.push.stop,'Enable'),'on')
        set(FIG.push.stop,'Userdata',1);
    else
        delete(FIG.handle);
    end
    
end
