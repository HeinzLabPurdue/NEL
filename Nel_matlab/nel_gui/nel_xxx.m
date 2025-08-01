function varargout = nel(varargin)
% NEL Application M-file for nel.fig
%    FIG = NEL launch nel GUI.
%    NEL('callback_name', ...) invoke the named callback.

% Last Modified by GUIDE v2.5 28-Feb-2014 15:44:12
% disp('testing');
global NelData

if nargin == 0  % LAUNCH GUI
    beep on;
    if (NelData.run_mode ~= 0)
        resp = questdlg('Nel is currently collecting data. Are you sure you want to abort and restart Nel?', 'Nel Init', ...
            'Yes','No','No');
        if (strcmp(resp,'No'))
            return;
        end
        if (ishandle(NelData.General.main_handle))
            delete(NelData.General.main_handle)
        end
    end
    NelData.run_mode = 0;
    fig = openfig(mfilename,'reuse');
    NelData.General.main_handle = fig;
    % Generate a structure of handles to pass to callbacks, and store it.
    handles = guihandles(fig);
    guidata(fig, handles);
    if (Get_User_Info(fig,handles)) % check for abort request
        return;
    end
    Refresh_Template_List(handles); % TODO: include the user templates (NelData.User_block_templates)
    Set_Menu_Accelerators(handles);
    Set_Global_Handles_Lists(handles);
    %     tdtinit(fig); % SP on Aug 12, 2020
    if (isempty(NelData.UnSaved))
        set(handles.Menu_Save_pic,'Enable','off');
    end
    set(handles.Menu_Open,'Enable','off'); % Untill this option is implemented
    set(fig,'Visible','on');
    set(NelData.General.main_handle,'handlevisib','on'); % SP added on Aug 12, 2020
    tdtinit(NelData.General.main_handle);
    
    if nargout > 0
        varargout{1} = fig;
    end
    
elseif ischar(varargin{1}) % INVOKE NAMED SUBFUNCTION OR CALLBACK
    try
        if (nargout)
            [varargout{1:nargout}] = feval(varargin{:}); % FEVAL switchyard
        else
            feval(varargin{:}); % FEVAL switchyard
        end
    catch
        ding;
        disp(lasterr);
    end
end


%| ABOUT CALLBACKS:
%| GUIDE automatically appends subfunction prototypes to this file, and
%| sets objects' callback properties to call them through the FEVAL
%| switchyard above. This comment describes that mechanism.
%|
%| Each callback subfunction declaration has the following form:
%| <SUBFUNCTION_NAME>(H, EVENTDATA, HANDLES, VARARGIN)
%|
%| The subfunction name is composed using the object's Tag and the
%| callback type separated by '_', e.g. 'slider2_Callback',
%| 'figure1_CloseRequestFcn', 'axis1_ButtondownFcn'.
%|
%| H is the callback object's handle (obtained using GCBO).
%|
%| EVENTDATA is empty, but reserved for future use.
%|
%| HANDLES is a structure containing handles of components in GUI using
%| tags as fieldnames, e.g. handles.figure1, handles.slider2. This
%| structure is created at GUI startup using GUIHANDLES and stored in
%| the figure's application data using GUIDATA. A copy of the structure
%| is passed to each callback.  You can store additional information in
%| this structure at GUI startup, and you can change the structure
%| during callbacks.  Call guidata(h, handles) after changing your
%| copy to replace the stored original so that subsequent callbacks see
%| the updates. Type "help guihandles" and "help guidata" for more
%| information.
%|
%| VARARGIN contains any extra arguments you have passed to the
%| callback. Specify the extra arguments by editing the callback
%| property in the inspector. By default, GUIDE sets the property to:
%| <MFILENAME>('<SUBFUNCTION_NAME>', gcbo, [], guidata(gcbo))
%| Add any extra arguments after the last argument, before the final
%| closing parenthesis.


% --------------------------------------------------------------------
function abort = Get_User_Info(hfig,handles)
global NelData home_dir SKIPintro
user = {''}; title = 'Nel Login'; abort = 0;
while ((isempty(user) | isempty(user{1})))
    
    if SKIPintro
        user = {'MH'};
    else
        user = inputdlg({'User Name:'},title,1,{NelData.General.User},180);
    end
    if (isempty(user))
        Nel_Main_CloseRequestFcn(handles.Nel_Main, [], handles,{});
        if (~ishandle(hfig))
            abort = 1;
            return;
        end
    end
    title = 'Please enter NON-EMPTY login name';
end
if (strcmp(NelData.General.User,user{1}))
    reactivate = 'Yes';
else
    reactivate = 'No';
end
NelData.General.User = user{1};
user_profile_load(user{1});
activate_data_dir(handles,reactivate);
if (exist([home_dir 'Users\' user{1}],'dir') ~= 0)
    addpath([home_dir 'Users\' user{1}]);
    if (exist('my_startup','file') == 2)
        my_startup; % Allow people to update the path and to init their own stuff.
        % Especially, the user should register his/her templates using 'register_user_templates'
    end
end
if (user_profile_get('use_user_templates_tag'))
    switch2user_templates(handles.Menu_nel_tmplts,handles);
else
    switch2nel_templates(handles.Menu_nel_tmplts,handles);
end

% --------------------------------------------------------------------
function Update_Unit_Info(handles)
global NelData
str = cell(5,1);
if (NelData.File_Manager.track.No > 0)
    str{1} = sprintf('%d',NelData.File_Manager.track.No);
else
    str{1} = '--';
end
if (NelData.File_Manager.unit.No > 0)
    str{2} = sprintf('%02d',NelData.File_Manager.unit.No);
else
    str{2} = '--';
end
if (NelData.File_Manager.unit.BF > 0)
    str{3} = sprintf('%1.2f',NelData.File_Manager.unit.BF);
else
    str{3} = '--';
end
if (NelData.File_Manager.unit.Th > 0)
    str{4} = sprintf('%1.1f',NelData.File_Manager.unit.Th);
else
    str{4} = '--';
end
% SP om 8May19: Adding SR as basic param
if (NelData.File_Manager.unit.SR > 0)
    str{5} = sprintf('%1.1f',NelData.File_Manager.unit.SR);
else
    str{5} = '--';
end

set(handles.Unit_Info,'String',str);

% --------------------------------------------------------------------
function Update_AcqInfo(handles)
global NelData
i_ep = 1;   % for now, hard-coded to include only 1 acquisition channel
str = cell(4,1);
str{1} = '';
if (NelData.General.EP(i_ep).record == 0)
    str{2} = 'no';
else
    str{2} = 'yes';
end
str{3} = sprintf('%d', NelData.General.EP(i_ep).start);
str{4} = sprintf('%d', NelData.General.EP(i_ep).duration);
if (NelData.General.EP(i_ep).saveALLtrials == 0)
    str{5} = 'no';
else
    str{5} = 'yes';
end
if (NelData.General.EP(i_ep).decimate == 0)
    str{6} = 'no';
else
    str{6} = 'yes';
end
str{7} = sprintf('%d', NelData.General.EP(i_ep).decimateFactor);
set(handles.AcqInfo,'String',str);

% --------------------------------------------------------------------
function Toggle_Show_AcqInfo(handles)
global NelData
if (NelData.General.EP.show == 1)
    set(handles.MenuToggleAcqParams,'Label','Hide Acquisition Info');
    set(handles.AcqInfo, 'Visible', 'on');
    set(handles.AcqInfoStatic, 'Visible', 'on');
    Update_AcqInfo(handles);
else
    NelData.General.EP.record = 0;   % force to not record
    set(handles.MenuToggleAcqParams,'Label','Show Acquisition Info');
    set(handles.AcqInfo, 'Visible', 'off');
    set(handles.AcqInfoStatic, 'Visible', 'off');
end

% --------------------------------------------------------------------
function Toggle_Show_PulseInfo(handles)
global NelData
if (NelData.General.Pulse.show == 1)
    set(handles.MenuTogglePulseParams,'Label','Hide Pulse Info');
    set(handles.PulseInfo, 'Visible', 'on');
    set(handles.PulseInfoStatic, 'Visible', 'on');
    Update_PulseInfo(handles);
else
    NelData.General.Pulse.enabled = 0;   % force to not deliver pulse
    set(handles.MenuTogglePulseParams,'Label','Show Pulse Info');
    set(handles.PulseInfo, 'Visible', 'off');
    set(handles.PulseInfoStatic, 'Visible', 'off');
end

% --------------------------------------------------------------------
function Update_PulseInfo(handles)
global NelData
str = cell(5,1);
str{1} = '';
if (NelData.General.Pulse.enabled == 0)
    str{2} = 'no';
else
    str{2} = 'yes';
end
str{3} = sprintf('%d', NelData.General.Pulse.delay);
str{4} = sprintf('%d', NelData.General.Pulse.nPulses);
str{5} = sprintf('%d', NelData.General.Pulse.interPulse);
set(handles.PulseInfo,'String',str);

% --------------------------------------------------------------------
function varargout = Template_popup_Callback(h, eventdata, handles, varargin)
Update_Selected_Template(handles)


% --------------------------------------------------------------------
function varargout = Template_next_Callback(h, eventdata, handles, varargin)
val = get(handles.Template_popup,'Value');
if (val < length(get(handles.Template_popup,'String')))
    val = val+1;
    set(handles.Template_popup,'Value',val);
    Update_Selected_Template(handles);
else
    ding;
end

% --------------------------------------------------------------------
function varargout = Template_prev_Callback(h, eventdata, handles, varargin)
val = get(handles.Template_popup,'Value');
if (val > 1)
    val = val-1;
    set(handles.Template_popup,'Value',val);
    Update_Selected_Template(handles)
else
    ding;
end


%if (NelData.General.use_nel_templates)
% --------------------------------------------------------------------
function Refresh_Template_List(handles)
global NelData
templates = fieldnames(NelData.Block_templates);
if (isempty(templates))
    nelwarn('No templates defined');
end
set(handles.Template_popup,'Value',1);
set(handles.Template_popup,'String',templates);
Update_Selected_Template(handles);

% --------------------------------------------------------------------
function Update_Selected_Template(handles)
global NelData
set(handles.Template_ShortName,'String', 'Please Wait...'); drawnow;
val = get(handles.Template_popup,'Value');
strings = get(handles.Template_popup,'String');
val = min(val,length(strings));
template_mfile = getfield(NelData.Block_templates,strings{val});
[DAL vars template units] = Template2DAL(template_mfile);
set(handles.Inloop_browser,    'String', struct2str(vars.Inloop,units.Inloop));
set(handles.Gating_browser,    'String', struct2str(vars.Gating,units.Gating));
set(handles.Mix_browser,       'String', struct2str(vars.Mix,units.Mix));
Update_Template_shortname(DAL,handles);
handles.template_mfile = template_mfile;
handles.template = template;
handles.vars   = vars;
handles.units  = units;
NelData.DAL = DAL;
guidata(handles.Template_popup,handles);
user_profile_set(handles.template.tag,handles.vars); % AF 6/20/02:  to save the automatically updated fields in the dflt struct.

% --------------------------------------------------------------------
function Update_Template_shortname(DAL,handles)
set(handles.Template_ShortName,'String', DAL.short_description);
if (isempty(DAL.short_description))
    set(handles.Template_ShortName,'Enable', 'on','BackgroundColor','y');
else
    set(handles.Template_ShortName,'Enable', 'off','BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --------------------------------------------------------------------
function varargout = Template_ShortName_Callback(h, eventdata, handles, varargin)
if (isempty(get(h,'String')))
    set(handles.Template_ShortName,'BackgroundColor','y');
else
    set(handles.Template_ShortName,'BackgroundColor','w');
end

% --------------------------------------------------------------------
function varargout = Inloop_browser_ButtonDownFcn(h, eventdata, handles, varargin)
update_template_vars(handles.Inloop_browser, handles, 'Inloop','Stimulus Parameters');

% --------------------------------------------------------------------
function varargout = Gating_browser_ButtonDownFcn(h, eventdata, handles, varargin)
update_template_vars(handles.Gating_browser, handles, 'Gating', 'Gating');

% --------------------------------------------------------------------
function varargout = Mix_browser_ButtonDownFcn(h, eventdata, handles, varargin)
update_template_vars(handles.Mix_browser, handles, 'Mix', 'Mix');

% --------------------------------------------------------------------
function update_template_vars(h_browser, handles, fieldname, title)
global NelData
if (~isequal(get(handles.Nel_Main,'SelectionType'),'open'))
    return;
end
vars    = handles.vars;
units   = handles.units;
dlg_pos = template_dlg_pos(h_browser, handles);
% Allow Template2Dal to update the template before struct2dlg is being called.
[NelData.DAL handles.vars handles.template handles.units errstr] = Template2DAL(handles.template_mfile,vars,units,fieldname);
eval(['[vars.' fieldname ' units.' fieldname '] = structdlg(handles.template.IO_def.' fieldname ...
    ', title, handles.vars.' fieldname ',''on'',[],dlg_pos);']);
[NelData.DAL handles.vars handles.template handles.units errstr] = Template2DAL(handles.template_mfile,vars,units,fieldname);
while (~isempty(errstr))
    nelwarn(errstr);
    title = [title ': ''' errstr ''''];
    eval(['[vars.' fieldname ' units.' fieldname '] = structdlg(handles.template.IO_def.' fieldname ...
        ', title, handles.vars.' fieldname ',''on'',[],dlg_pos);']);
    [NelData.DAL handles.vars handles.template handles.units errstr] = Template2DAL(handles.template_mfile,vars,units,fieldname);
end
Update_Template_shortname(NelData.DAL,handles);
set(handles.Inloop_browser, 'String', struct2str(handles.vars.Inloop,handles.units.Inloop));
set(handles.Gating_browser, 'String', struct2str(handles.vars.Gating,handles.units.Gating));
set(handles.Mix_browser, 'String', struct2str(handles.vars.Mix,handles.units.Mix));
guidata(h_browser,handles);
user_profile_set(handles.template.tag,handles.vars);

% --------------------------------------------------------------------
function dlg_pos = template_dlg_pos(h_browser, handles)
fig_pos    = get(handles.Nel_Main,'Position');
browse_pos = get(h_browser, 'Position');
dlg_pos(1) = browse_pos(1) + fig_pos(1)+0.5;
dlg_pos(2) = browse_pos(2) + fig_pos(2)+0.5;
dlg_pos(3) = browse_pos(3)-0.5;
dlg_pos(4) = browse_pos(4)-0.5;

% --------------------------------------------------------------------
function set_PB_enable(hs,state)
for h = hs(:)'
    ud = get(h,'Userdata');
    switch (state)
        case {'inactive' 'off'}
            cdata = (ud.cdata + ud.bgmat)/2;
            cdata(2:2:end,1:2:end,:) = ud.bgmat(2:2:end,1:2:end,:);
            set(h, 'Enable',state)
            % set(h,'CData', (ud.cdata + 2.5*ud.bgmat)/3.5);
            set(h,'CData', cdata);
            
        case {'on'}
            set(h, 'Enable', 'on')
            set(h,'CData', ud.cdata);
            
        otherwise
            disp(['toggle_PB_enable: state = ' state '. This should not have happend!']);
    end
end

% --------------------------------------------------------------------
function varargout = Go_PB_Callback(h, eventdata, handles, varargin)
global NelData
if (NelData.File_Manager.unit.No == 0)
    nelerror('Can''t collect data for Unit #0. Open new Unit first');
    return;
end
NelData.UnSaved = [];
set(handles.Menu_Save_pic,'Enable','off');
ud = get(handles.Nel_Main,'Userdata');
set(ud.stimulus_def_handles,'Visible','off');
change_fig_height(handles, 44);
set(ud.run_status_handles,'Visible','on');
set(ud.run_inactive_handles,'Enable','off');
set_PB_enable(ud.run_inactive_PB_handles,'inactive');
set_PB_enable(handles.Stop_PB,'on');
set(handles.Menu_run_stop,'Label','&Stop','Accelerator','s');
set([handles.Menu_File handles.Menu_Block handles.Menu_Channels handles.Menu_Log handles.Menu_Tools] ,'Enable','off')
NelData.Stop_request = 0;
NelData.run_mode = 2;
act_on_related_handles([], 'spikes_fig_prepare2run');
set(handles.Status_Block_info,'String',NelData.DAL.description);
clear_Error_LB(handles.Error_LB);
set(handles.Comment,'String','');
%%
try
    if (isfield(NelData.DAL, 'funcName'))  % added by GE 30oct2003 to allow for alternate DAL functions.
        [block_info,stim_info] = call_user_func(NelData.DAL.funcName, NelData.DAL,NelData.General.nChannels,handles.Status_Line_info);
    else  % call default "data_acquisition_loop".
        [block_info,stim_info] = data_acquisition_loop(NelData.DAL,NelData.General.nChannels,handles.Status_Line_info);
    end
    not_successful_flag = 0;
catch
    not_successful_flag = 1;
end
set(handles.Menu_run_stop,'Label','&Run','Accelerator','r');
if (not_successful_flag)
    nelerror(['Error in data_acquisition_loop. Check your parameters (' lasterr ')']);
else
    Save_collected_data(handles,block_info,stim_info);
end
NelData.run_mode = 0;
set(ud.run_status_handles,'Visible','off');
change_fig_height(handles, -44)
set(ud.stimulus_def_handles,'Visible','on');
set(ud.run_inactive_handles,'Enable','on');
set_PB_enable(handles.Stop_PB,'inactive');
set_PB_enable(ud.run_inactive_PB_handles,'on');
figure(handles.Nel_Main);
act_on_related_handles([], 'set', 'Resize','on','MenuBar','figure','ToolBar','figure')
set([handles.Menu_File handles.Menu_Block handles.Menu_Channels handles.Menu_Log handles.Menu_Tools] ,'Enable','on');
set(handles.Status_Block_info,'String','');
set(handles.Triggering_popup,'Value',1);

% --------------------------------------------------------------------
function spikes_fig_prepare2run(h)
set(h,'Resize',            'off', ...
    'MenuBar',              'none', ...
    'ToolBar',              'none', ...
    'WindowButtonDownFcn',  '', ...
    'WindowButtonUpFcn',    '');

% --------------------------------------------------------------------
function Save_collected_data(handles,block_info,stim_info,saved_errors)
global NelData spikes Trigger
figure(handles.Nel_Main);
[~, short_fname] = current_data_file(block_info.short_description);
set_PB_enable(handles.SaveData_PB,'on');
set_PB_enable(handles.NoSaveData_PB,'on');
set([handles.SaveData_PB handles.NoSaveData_PB handles.SaveDlg_txt handles.SaveDlg_Frame] ,'Visible', 'on');
set(handles.Menu_run_stop,'Enable','off');
set([handles.Stop_PB handles.Go_PB handles.ShortCuts_BG_dummy],'Visible','off');
if (get(handles.Triggering_popup,'Value') == 1)
    for ii = 1:2
        set(handles.Triggering_popup,'BackgroundColor','r');
        drawnow
        if (ii <2)
            neltimer(0.1); %Fixed M.Sayles. 20/11/15
            %          neltimer(0.1);
            set(handles.Triggering_popup,'BackgroundColor','w');
            drawnow
            neltimer(0.1); %Fixed M.Sayles. 20/11/15
            %          neltimer(0.1);
        end
    end
end
% Present save/nosave question while allowing the user to edit the comment and triggering
set(handles.SaveDlg_txt,'UserData',NaN);
set(handles.SaveDlg_txt,'String',{'Save Data to:'  ['''' short_fname '''?']});
NelData.run_mode = 3;
% Wait for answer
% beep;   % ge modification %% AF 06/11/02: commented out and put at the end of data_acquisition_loop
waitfor(handles.SaveDlg_txt,'UserData');
% Prepare trig, comment and errors for save (or back up in NelData.UnSaved struct).
trig_ind = get(handles.Triggering_popup,'Value');
trig_str = get(handles.Triggering_popup,'String');
comment  = get(handles.Comment,'String');
if (exist('saved_errors','var') == 1)
    error_strs = saved_errors;
else
    error_ud = get(handles.Error_LB,'UserData');
    if (error_ud.index > 0)
        error_strs = get(handles.Error_LB,'String');
    else
        error_strs = '';
    end
end
do_save = get(handles.SaveDlg_txt,'UserData');
if (do_save)
    try
        make_text_file(block_info,stim_info,comment,trig_str{trig_ind},error_strs);
        saved = 1;
        
        %% SP on 8May19
        if strcmp(block_info.short_description, 'SR')
            % compute SR
            % -----------------
            cdd;
            temp_data = spikes.times{1}(spikes.times{1}(:,1)~=0, :);
            nLines= block_info.fully_presented_lines;
            stimDur= (Trigger.params.StmOn+Trigger.params.StmOff)/1e3; % seconds
            SRvalue= sum(temp_data(:,1)<=nLines)/nLines/stimDur;
            rdd;
            % -----------------

            NelData.File_Manager.unit.SR= SRvalue;
            nel('Update_Unit_Info', handles)
        end
        
    catch
        nelerror('Failed to save data file');
        saved = 0;
    end
end
if (do_save == 0 | saved == 0)
    NelData.UnSaved.block_info = block_info;
    NelData.UnSaved.stim_info  = stim_info;
    NelData.UnSaved.trig_ind   = trig_ind;
    NelData.UnSaved.comment    = comment;
    NelData.UnSaved.error_strs = error_strs;
    set(handles.Menu_Save_pic,'Enable','on');
else
    NelData.UnSaved = [];
    set(handles.Menu_Save_pic,'Enable','off');
    update_nel_title(handles);
end
set(handles.Triggering_popup,'BackgroundColor','w');
set([handles.SaveData_PB handles.NoSaveData_PB handles.SaveDlg_txt handles.SaveDlg_Frame] ,'Visible', 'off');
set(handles.Menu_run_stop,'Enable','on');
set([handles.Stop_PB handles.Go_PB handles.ShortCuts_BG_dummy],'Visible','on');
NelData.run_mode = 0;

% --------------------------------------------------------------------
function varargout = Go_PB_CreateFcn(h, eventdata, handles, varargin)
[ud.cdata ud.bgmat] = ico2cdata('TRFFC10A.ICO');
set(h,'Userdata', ud);
set(h,'CData', ud.cdata);


% --------------------------------------------------------------------
function varargout = Stop_PB_Callback(h, eventdata, handles, varargin)
global NelData
NelData.Stop_request = 1;

% --------------------------------------------------------------------
function varargout = Stop_PB_CreateFcn(h, eventdata, handles, varargin)
[ud.cdata ud.bgmat] = ico2cdata('TRFFC14.ICO');
set(h,'Userdata', ud);
set_PB_enable(h, 'inactive');

% --------------------------------------------------------------------
function change_fig_height(handles, change)
orig_pos = get(handles.Nel_Main,'Position');
new_pos = [orig_pos(1) orig_pos(2)+change  orig_pos(3) orig_pos(4)-change];
%set(handles.Nel_Main,'Visible', 'off');
set(handles.Nel_Main,'Position',[new_pos]);
chld = get(handles.Nel_Main,'Children');
for i = 1:length(chld)
    if (strcmp(get(chld(i),'Type'),'uicontrol'))
        pos = get(chld(i),'Position');
        pos(2) = pos(2)-change;
        set(chld(i),'Position',pos);
    end
end
%set(handles.Nel_Main,'Visible', 'on');


% --------------------------------------------------------------------
function Bring2Front(hfig,h) % TODO: this function should be deleted later
chld = get(hfig,'Children');
ind = find(chld == h);
chld = chld([ind 1:ind-1 ind+1:end]);
set(hfig,'Children',chld);

% --------------------------------------------------------------------
function varargout = Error_LB_CreateFcn(h, eventdata, handles, varargin)
ud.length        = 400;
ud.index         = 0;
ud.log.length    = 6000;
ud.log.str       = cell(ud.log.length,1);
ud.log.index     = 1;
% buff             = cell(ud.length,1);
buff             = cell(1,1);
ud.log.str{1}    = [datestr(now) ' - Start'];
set(h,'String',buff);
set(h,'Userdata', ud);

% --------------------------------------------------------------------
function varargout = Error_LB_ButtonDownFcn(h, eventdata, handles, varargin)
global NelData
if (NelData.run_mode ~= 0)
    return;
end
if (~isequal(get(handles.Nel_Main,'SelectionType'),'open'))
    return;
end
ud = get(h,'UserData');
if (ud.index > 0)
    strs = get(h,'String');
    waitfor(strdlg(strs, 'Recent Errors', [], struct('WindowStyle','modal')));
    clear_Error_LB(h);
end

% --------------------------------------------------------------------
function clear_Error_LB(h);
ud = get(h,'UserData');
strs = get(h,'String');
strs(1:ud.index) = cell(ud.index,1);
strs = cell(1,1);
ud.index = 0;
set(h,'String',strs);
set(h,'ListboxTop',1);
set(h,'Userdata',ud);
set(h,'Visible','off');
update_error_tooltip(h);

% --------------------------------------------------------------------
function update_error_tooltip(h)
headerstr = {'Double-Click to Confirm and Clear Error Window'; ...
    '-----------------------------------------------------------'};
if (isequal(get(h,'Visible'),'on'))
    strs = get(h,'String');
    strs = cat(1,headerstr,strs);
else
    strs = '';
end
tooltipstr = char(strs);
tooltipstr = sprintf('%s', [tooltipstr repmat(char(10),size(tooltipstr,1),1)]');
set(h,'ToolTipString',tooltipstr);

% --------------------------------------------------------------------
function ud = logerror(strs, iswarning,ud)
if (iswarning)
    err_header = [datestr(now) ' - Warning: '];
else
    err_header = [datestr(now) ' - Error: '];
end
strs{1} = [err_header strs{1}];
[ud.log.str ud.log.index] = cat_str_buffer(ud.log.str, ud.log.index, strs,0,ud.log.length);

% --------------------------------------------------------------------
function [buff,index] = cat_str_buffer(buff, index,strs,tmp_flag,max_len)
buff(index+1:index+length(strs)) = strs;
if (tmp_flag == 0)
    index = index + length(strs);
end
if (index >= max_len)
    new_start = round(max_len*0.25);
    buff = buff(new_start:end);
    index = index - new_start+1;
end
% --------------------------------------------------------------------
function varargout = nelerror(strs, iswarning,tmp_flag)
global NelData
if (~ishandle(NelData.General.main_handle))
    if (iswarning)
        warndlg(strs, 'Nel Warning');
    else
        errordlg(strs, 'Nel Error');
    end
    return;
end
handles = guidata(NelData.General.main_handle);
if (exist('iswarning','var') ~= 1)
    iswarning = 0;
end
if (exist('tmp_flag','var') ~= 1)
    tmp_flag = 0;
end
if (ischar(strs))
    strs = cellstr(strs);
end
ud   = get(handles.Error_LB,'Userdata');
ud   = logerror(strs,iswarning,ud);
strs = textwrap(handles.Error_LB,strs,54);
buff = get(handles.Error_LB,'String');
already_exist = 1;
tmp_buff = buff;
for ii = 1:length(strs)
    ind = strmatch(strs(ii), tmp_buff,'exact');
    if isempty(ind)
        already_exist = 0;
        break;
    else
        tmp_buff = tmp_buff(ind+1:end);
    end
end
if (already_exist == 0)
    [buff ud.index] = cat_str_buffer(buff, ud.index, strs, tmp_flag, ud.length);
    set(handles.Error_LB,'String',buff);
    set(handles.Error_LB,'ListboxTop',max(1,ud.index-1));
    if (iswarning)
        set(handles.Error_LB,'ForegroundColor','k')
    else
        set(handles.Error_LB,'ForegroundColor','r')
    end
    if (strcmp(get(handles.Error_LB,'Visible'),'off'))
        set(handles.Error_LB,'Visible','on');
        if (~iswarning)
            ding;  % MH/GE 12Nov2003 only dings for real error, not warnings!
        end
    end
end
set(handles.Error_LB,'Userdata',ud);
update_error_tooltip(handles.Error_LB);
if (NelData.run_mode ~= 9) % Quick & dirty. TODO: save search, tc, calibrate figure handles
    % and 'figure(saved_handle)' at the end of the function.
    figure(NelData.General.main_handle); % Ensure that the figure is visible;
end

% --------------------------------------------------------------------
function varargout = Menu_Block_Callback(h, eventdata, handles, varargin)

% --------------------------------------------------------------------
function varargout = Menu_Stimulus_Callback(h, eventdata, handles, varargin)
set(handles.Nel_Main,'SelectionType','open'); % Fake a double click
Inloop_browser_ButtonDownFcn(handles.Inloop_browser, eventdata, handles, varargin);


% --------------------------------------------------------------------
function varargout = Menu_Gating_Callback(h, eventdata, handles, varargin)
set(handles.Nel_Main,'SelectionType','open'); % Fake a double click
Gating_browser_ButtonDownFcn(handles.Gating_browser, eventdata, handles, varargin);


% --------------------------------------------------------------------
function varargout = Menu_Acq_Params_Callback(h, eventdata, handles, varargin)   %GE MODIFICATION
global NelData
i_ep = 1;   % for now, hard-coded to include only 1 acquisition channel
def.record = { {'0','{1}'} };
def.start = { NelData.General.EP(i_ep).start 'ms' [0 1000] };
def.duration = { NelData.General.EP(i_ep).duration 'ms' [10 5000] };
def.saveALLtrials = { {'{0}','1'} };
def.decimate = { {'{0}','1'} };
def.decimateFactor = { NelData.General.EP(i_ep).decimateFactor '' [1 100] };
dflt.record  = NelData.General.EP(i_ep).record;
dflt.saveALLtrials = NelData.General.EP(i_ep).saveALLtrials;
dflt.decimate = NelData.General.EP(i_ep).decimate;
dflt = structdlg(def,'Acquisition Setup', dflt);
NelData.General.EP(i_ep).record = dflt.record;
NelData.General.EP(i_ep).start = dflt.start;
NelData.General.EP(i_ep).duration = dflt.duration;
NelData.General.EP(i_ep).saveALLtrials = dflt.saveALLtrials;
NelData.General.EP(i_ep).decimate = dflt.decimate;
NelData.General.EP(i_ep).decimateFactor = dflt.decimateFactor;
Update_AcqInfo(handles);

% --------------------------------------------------------------------
function varargout = Menu_Pulse_Params_Callback(h, eventdata, handles, varargin)
global NelData
def.enabled = { {'0','{1}'} };
def.delay = { 100 'ms' [0 5000] };
def.nPulses = { 4 '' [1 1000]};
def.interPulse = { 50 'ms' [2 5000] };
dflt.enabled = NelData.General.Pulse.enabled;
dflt.delay = NelData.General.Pulse.delay;
dflt.nPulses = NelData.General.Pulse.nPulses;
dflt.interPulse = NelData.General.Pulse.interPulse;
dflt = structdlg(def,'Pulse Setup',dflt);
NelData.General.Pulse.enabled = dflt.enabled;
NelData.General.Pulse.delay = dflt.delay;
NelData.General.Pulse.nPulses = dflt.nPulses;
NelData.General.Pulse.interPulse = dflt.interPulse;
Update_PulseInfo(handles);

% --------------------------------------------------------------------
function varargout = Menu_Toggle_AcqParams_Callback(h, eventdata, handles, varargin)   %GE MODIFICATION
global NelData
if (NelData.General.EP.show == 0)
    NelData.General.EP.show = 1;
else
    NelData.General.EP.show = 0;
end
Toggle_Show_AcqInfo(handles);

% --------------------------------------------------------------------
function varargout = Menu_Toggle_PulseParams_Callback(h, eventdata, handles, varargin)   %GE MODIFICATION
global NelData
if (NelData.General.Pulse.show == 0)
    NelData.General.Pulse.show = 1;
else
    NelData.General.Pulse.show = 0;
end
Toggle_Show_PulseInfo(handles);

% --------------------------------------------------------------------
function varargout = Menu_Mix_Callback(h, eventdata, handles, varargin)
set(handles.Nel_Main,'SelectionType','open'); % Fake a double click
Mix_browser_ButtonDownFcn(handles.Mix_browser, eventdata, handles, varargin)


% --------------------------------------------------------------------
function Set_Menu_Accelerators(handles)
set(handles.Menu_Stimulus,'Accelerator','p');
set(handles.Menu_Gating,'Accelerator','g');
set(handles.Menu_Mix,'Accelerator','m');
set(handles.Menu_run_stop,'Accelerator','r');
set(handles.Menu_Tools_search,'Accelerator','f');

% --------------------------------------------------------------------
function varargout = Triggering_popup_Callback(h, eventdata, handles, varargin)

% --------------------------------------------------------------------
function varargout = Status_Block_info_Callback(h, eventdata, handles, varargin)

% --------------------------------------------------------------------
function varargout = Status_Line_info_Callback(h, eventdata, handles, varargin)

% --------------------------------------------------------------------
function Set_Global_Handles_Lists(handles)
ud = get(handles.Nel_Main,'Userdata');
ud.stimulus_def_handles   = [ ...
    handles.Inloop_browser ...
    handles.Mix_browser ...
    handles.Template_ShorName_LBL ...
    handles.Template_ShortName ...
    handles.Mix_title ...
    handles.Gating_title ...
    handles.Gating_browser ...
    handles.Template_prev ...
    handles.Template_next ...
    handles.Template_popup ...
    handles.Template_title ...
    handles.Inloop_title ...
    handles.Template_Frame ...
    ];

ud.run_status_handles   = [ ...
    handles.Status_Line_info ...
    handles.Status_Block_info ...
    handles.Status_frame ...
    handles.Triggering_popup ...
    handles.Comment ...
    handles.Comment_title ...
    handles.Triggering_title ...
    handles.TrigComment_frame ...
    ];

ud.run_inactive_handles = [ ...
    handles.Menu_Mix ...
    handles.Menu_Gating ...
    handles.Menu_Stimulus ...
    ];

ud.run_inactive_PB_handles = [ ...
    handles.Go_PB ...
    handles.Tuning_Curve_PB ...
    handles.DPOAE_PB ...
    handles.Search_PB ...
    handles.New_Unit_PB ...
    handles.CAP_PB ...
    handles.Inhibit_PB ...
    ];

set(handles.Nel_Main,'Userdata',ud);

% --------------------------------------------------------------------
function varargout = Menu_File_Callback(h, eventdata, handles, varargin)


% --------------------------------------------------------------------
function varargout = Menu_new_Callback(h, eventdata, handles, varargin)


% --------------------------------------------------------------------
function varargout = Menu_Open_Callback(h, eventdata, handles, varargin)


% --------------------------------------------------------------------
function varargout = Menu_Exit_Callback(h, eventdata, handles, varargin)
Nel_Main_CloseRequestFcn(handles.Nel_Main, eventdata, handles, varargin)

% --------------------------------------------------------------------
function varargout = Menu_nel_tmplts_Callback(h, eventdata, handles, varargin)
global NelData
if (isequal(get(h,'Checked'),'off'))
    switch2nel_templates(h,handles);
else
    switch2user_templates(h,handles);
end

% --------------------------------------------------------------------
function switch2nel_templates(hmenu,handles)
global NelData
rc = 1;
try
    NelData.Block_templates = NelData.General.Nel_Templates;
catch
    rc = 0;
end
if (rc==0)
    nelerror('Nel Templates are not defined or empty. Check ''nelinit.m''');
    return;
end
Refresh_Template_List(handles);
user_profile_set('use_user_templates_tag',0);
set(hmenu,'checked','on');

% --------------------------------------------------------------------
function switch2user_templates(hmenu,handles)
global NelData
rc = 1;
try
    if (~isempty(NelData.General.User_templates))
        NelData.Block_templates = NelData.General.User_templates;
    else
        rc = 0;
    end
catch
    rc = 0;
end
if (rc==0)
    nelerror('User Templates are not defined or empty.');
    return;
end
Refresh_Template_List(handles);
user_profile_set('use_user_templates_tag',1);
set(hmenu,'checked','off');

% --------------------------------------------------------------------
function varargout = Menu_run_stop_Callback(h, eventdata, handles, varargin)
global NelData
if (NelData.run_mode == 0)
    Go_PB_Callback(handles.Go_PB, eventdata, handles, varargin)
else
    Stop_PB_Callback(handles.Stop_PB, eventdata, handles, varargin)
end

% --------------------------------------------------------------------
function varargout = Nel_Main_CloseRequestFcn(h, eventdata, handles, varargin)
global NelData
if (NelData.run_mode ~= 0)
    errordlg('Can not exit while in ''RUN'' mode');
    return;
else
    selection = questdlg('Really quit?',...
        'Nel Close',...
        'Yes','No','Yes');
    switch selection,
        case 'Yes',
            delete(h);
        case 'No'
            return
    end
end

% --------------------------------------------------------------------
function varargout = Nel_Main_DeleteFcn(h, eventdata, handles, varargin)
global NelData
act_on_related_handles([],'delete');

user_profile_save(NelData.General.User);
error_ud = get(handles.Error_LB,'Userdata');
if (error_ud.log.index > 0)
    error_str = error_ud.log.str(1:error_ud.log.index);
    try
        fname = [NelData.File_Manager.dirname 'ErrorLog.txt'];
        fid = fopen(fname,'a');
        while (fid < 0)
            title_str = ['Choose a different file name! Can''t write to ''' fname ''''];
            [fname, dirname] = uiputfile([fileparts(fname) filesep '*.txt'],title_str);
            fid = fopen(fullfile(dirname,fname),'a');
        end
        for i = 1:length(error_str)
            fprintf(fid,'%s\n',error_str{i});
        end
        fclose(fid);
    catch
        disp('NEL FAILED TO SAVE THE ERROR LOG!!!!!');
    end
end
save(NelData.General.save_fname, 'NelData');

% --------------------------------------------------------------------
function varargout = act_on_related_handles(related_h, cmd, varargin)
global NelData
if (isempty(related_h))
    if (isfield(NelData,'Related_Handles') & isstruct(NelData.Related_Handles))
        related_h = struct2cell(NelData.Related_Handles);
    else
        return;
    end
end
for i = 1:length(related_h)
    if (ishandle(related_h{i}))
        feval(cmd,related_h{i},varargin{:})
    elseif (iscell(related_h{i}))
        for j = length(related_h{i}):-1:1
            if (ishandle(related_h{i}{j}))
                feval(cmd,related_h{i}{j},varargin{:})
            end
        end
    end
end

% --------------------------------------------------------------------
function varargout = Nel_Main_KeyPressFcn(h, eventdata, handles, varargin)
global NelData
ch = get(h,'CurrentCharacter');
% double(ch)
% return
if (~isempty(ch))
    switch (double(ch))
        case 13 % Enter
            if (NelData.run_mode == 3) % In Save DLG
                SaveData_PB_Callback(handles.SaveData_PB, eventdata, handles, varargin)
            end
            
        case 27 % Esc
            if (NelData.run_mode == 3) % In Save DLG
                NoSaveData_PB_Callback(handles.NoSaveData_PB, eventdata, handles, varargin)
            end
            
        case 19 % CTRL+s
            if (NelData.run_mode ~= 0)
                Stop_PB_Callback(handles.Stop_PB, eventdata, handles, varargin)
            end
            
        case 18 % CTRL+r
            if (NelData.run_mode == 0)
                Go_PB_Callback(handles.Go_PB, eventdata, handles, varargin)
            end
            
        case {29,31} % Right and Down arrows
            Template_next_Callback(handles.Template_next, eventdata, handles, varargin);
            
        case {28,30} % Left and Up arrows
            Template_prev_Callback(handles.Template_prev, eventdata, handles, varargin);
            
    end
end


% --------------------------------------------------------------------
function varargout = Menu_Channels_Callback(h, eventdata, handles, varargin)

% --------------------------------------------------------------------
function varargout = Menu_Ch_set_number_Callback(h, eventdata, handles, varargin)
global NelData
def.Number_of_Channels = { 1 '' [1 6] };
dflt.Number_of_Channels = NelData.General.nChannels;
dflt = structdlg(def,'Channels Setup',dflt);
if (dflt.Number_of_Channels ~= NelData.General.nChannels)
    Menu_Ch_closeall_Callback(handles.Menu_Ch_closeall, eventdata, handles, varargin);
end
NelData.General.nChannels = dflt.Number_of_Channels;

% --------------------------------------------------------------------
function varargout = Menu_Ch_bring2front_Callback(h, eventdata, handles, varargin)
act_on_related_handles([], 'figure');

% --------------------------------------------------------------------
function varargout = Menu_Ch_closeall_Callback(h, eventdata, handles, varargin)
act_on_related_handles([], 'delete');

% --------------------------------------------------------------------
function varargout = Menu_Ch_rearrange_Callback(h, eventdata, handles, varargin)
spikes_fig('rearrange');
act_on_related_handles([], 'figure');

% --------------------------------------------------------------------
function varargout = Menu_Log_Callback(h, eventdata, handles, varargin)

% --------------------------------------------------------------------
function varargout = Menu_Log_Error_Callback(h, eventdata, handles, varargin)
ud = get(handles.Error_LB,'Userdata');
strdlg(ud.log.str(1:ud.log.index), 'Nel Error Log');

% --------------------------------------------------------------------
function varargout = Menu_New_track_Callback(h, eventdata, handles, varargin)
new_track;
Update_Unit_Info(handles);

% --------------------------------------------------------------------
function varargout = Menu_New_unit_Callback(h, eventdata, handles, varargin)
new_unit;
Update_Unit_Info(handles);

% --------------------------------------------------------------------
function varargout = Menu_Edit_Callback(h, eventdata, handles, varargin)

% --------------------------------------------------------------------
function varargout = Menu_Edit_track_Callback(h, eventdata, handles, varargin)
global NelData
if (NelData.File_Manager.track.No == 0)
    nelwarn('No Track to Edit. Use ''File->New->Track'' first');
    return;
end
new_track(NelData.File_Manager.track.No);
Update_Unit_Info(handles);

% --------------------------------------------------------------------
function varargout = Menu_Edit_unit_Callback(h, eventdata, handles, varargin)
global NelData
if (NelData.File_Manager.unit.No == 0)
    nelwarn('No Unit to Edit. Use ''File->New->Unit'' first');
    return;
end
new_unit(NelData.File_Manager.unit.No);
Update_Unit_Info(handles);

% --------------------------------------------------------------------
function varargout = Menu_File_cd_Callback(h, eventdata, handles, varargin)
activate_data_dir(handles,'No');

% --------------------------------------------------------------------
function activate_data_dir(handles,reactivate)
global NelData
dirname = choose_data_dir(reactivate); % choose_data_dir updates NelData and the user-profiles
update_nel_title(handles);
% set(handles.Nel_Main,'Name',['Nel   -  ''' dirname '''   (' int2str(NelData.File_Manager.picture) ' Saved Pictures)']);
Update_Unit_Info(handles);
Update_AcqInfo(handles);
Toggle_Show_AcqInfo(handles);
Update_PulseInfo(handles);
Toggle_Show_PulseInfo(handles);

% --------------------------------------------------------------------
function update_nel_title(handles)
global data_dir NelData ProgName
if (strncmp(data_dir,NelData.File_Manager.dirname,length(data_dir)))
    display_dir = strrep(NelData.File_Manager.dirname(length(data_dir)+1:end),'\','');
else
    display_dir = NelData.File_Manager.dirname;
end
set(handles.Nel_Main,'Name',[ProgName '  -  ''' display_dir '''   (' int2str(NelData.File_Manager.picture) ' Saved Pictures)']);

% --------------------------------------------------------------------
function varargout = Menu_Tools_Callback(h, eventdata, handles, varargin)
% --------------------------------------------------------------------
function varargout = Menu_Tools_search_Callback(h, eventdata, handles, varargin)
external_run_checkin(handles);
search; % AF 5/20/02 - using BJM's new search version
% h_search = search;
% delete(h_search);
external_run_checkout(handles);

% --------------------------------------------------------------------
function varargout = Menu_Tools_TC_Callback(h, eventdata, handles, varargin)
global NelData
if (NelData.File_Manager.unit.No == 0)
    nelerror('Can''t collect data for Unit #0. Open new Unit first');
    return;
end
external_run_checkin(handles);
h_tc = tuning_curve;
if strcmp(NelData.TC.rc,'stopNOSAVE')
    uiwait(h_tc);
end
update_nel_title(handles);
Update_Unit_Info(handles);

NelData = rmfield(NelData,'TC');
external_run_checkout(handles);

% --------------------------------------------------------------------
function varargout = Menu_Tools_Inhibit_Callback(h, eventdata, handles, varargin)
global NelData
if (NelData.File_Manager.unit.No == 0)
    nelerror('Can''t collect data for Unit #0. Open new Unit first');
    return;
end
external_run_checkin(handles);
h_inhibit = inhibit_curve;
if strcmp(NelData.inhibit.rc,'stopNOSAVE')
    uiwait(h_inhibit);
end
update_nel_title(handles);
Update_Unit_Info(handles);

NelData = rmfield(NelData,'inhibit');
external_run_checkout(handles);
%% TO RUN SEARCH STRAIGHT FROM TC BREAK: (can use NelData.TC.rc)
%%% Menu_Tools_search_Callback(h, eventdata, handles, varargin)

% --------------------------------------------------------------------
% --------------------------------------------------------------------
% function varargout = Menu_Tools_TC_Callback(h, eventdata, handles, varargin)
% global NelData
% if (NelData.File_Manager.unit.No == 0)
%    nelerror('Can''t collect data for Unit #0. Open new Unit first');
%    return;
% end
% external_run_checkin(handles);
% h_tc = tuning_curve;
% while (ishandle(h_tc))
%    uiwait(h_tc);
%    update_nel_title(handles);
% end
% update_nel_title(handles);
% new_unit(NelData.File_Manager.unit.No,[],NelData.TC);
% NelData = rmfield(NelData,'TC');
% Update_Unit_Info(handles);
% external_run_checkout(handles);

% --------------------------------------------------------------------
function varargout = Menu_Tools_calibrate_Callback(h, eventdata, handles, varargin)
external_run_checkin(handles);
h_calib = calibrate;
while (ishandle(h_calib))
    uiwait(h_calib);
    update_nel_title(handles);
end
external_run_checkout(handles);

function varargout = Menu_Tools_calibrateOLD_Callback(h, eventdata, handles, varargin)
global NelData
external_run_checkin(handles);
currDIR=pwd;
cd([NelData.General.RootDir 'Nel_matlab\calibrationOLD']) 
h_calib = calibrate;
while (ishandle(h_calib))
    uiwait(h_calib);
    update_nel_title(handles);
end
external_run_checkout(handles);
cd(currDIR)

% --------------------------------------------------------------------
function varargout = Menu_Tools_CAP_Callback(h, eventdata, handles, varargin)
external_run_checkin(handles);
h_cap=CAP;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
while (ishandle(h_cap))
    uiwait(h_cap);
    update_nel_title(handles);
end
update_nel_title(handles);
% h_search = search;
% delete(h_search);
external_run_checkout(handles);


% --------------------------------------------------------------------
function external_run_checkin(handles)
global NelData
ud = get(handles.Nel_Main,'Userdata');
set(ud.stimulus_def_handles,'Visible','off');
change_fig_height(handles, 44);
set(ud.run_inactive_handles,'Enable','off');
set_PB_enable(ud.run_inactive_PB_handles,'inactive');
set_PB_enable(handles.Stop_PB,'inactive');
set([handles.Menu_File handles.Menu_Block handles.Menu_Channels handles.Menu_Log handles.Menu_run_stop ...
    handles.Menu_Tools] ,'Enable','off');
NelData.run_mode = 9;
drawnow


% --------------------------------------------------------------------
function external_run_checkout(handles)
global NelData
ud = get(handles.Nel_Main,'Userdata');
NelData.run_mode = 0;
set([handles.Menu_File handles.Menu_Block handles.Menu_Channels handles.Menu_Log handles.Menu_run_stop ...
    handles.Menu_Tools] ,'Enable','on');
set(handles.Status_Block_info,'String','');
change_fig_height(handles, -44)
set(ud.stimulus_def_handles,'Visible','on');
set(ud.run_inactive_handles,'Enable','on');
set_PB_enable(ud.run_inactive_PB_handles,'on');
set_PB_enable(handles.Stop_PB,'inactive');
figure(handles.Nel_Main);
set([handles.Menu_File handles.Menu_Block handles.Menu_Channels handles.Menu_Log] ,'Enable','on');


% --------------------------------------------------------------------
function varargout = SaveData_PB_Callback(h, eventdata, handles, varargin)
set(handles.SaveDlg_txt,'UserData',1);

% --------------------------------------------------------------------
function varargout = NoSaveData_PB_Callback(h, eventdata, handles, varargin)
set(handles.SaveDlg_txt,'UserData',0);

% --------------------------------------------------------------------
function varargout = SaveData_PB_CreateFcn(h, eventdata, handles, varargin)
% [ud.cdata ud.bgmat] = ico2cdata('SAVEFIL1.ICO');
[ud.cdata ud.bgmat] = ico2cdata('CHECKMRK.ICO');
set(h,'Userdata', ud);
%set_PB_enable(h, 'inactive');
set(h,'Visible', 'off');

% --------------------------------------------------------------------
function varargout = NoSaveData_PB_CreateFcn(h, eventdata, handles, varargin)
% [ud.cdata ud.bgmat] = ico2cdata('Trash.ICO');
[ud.cdata ud.bgmat] = ico2cdata('W95MBX01.ICO');
set(h,'Userdata', ud);
%set_PB_enable(h, 'inactive');
set(h,'Visible', 'off');

% --------------------------------------------------------------------
function varargout = Unit_Info_ButtonDownFcn(h, eventdata, handles, varargin)
global NelData
if (NelData.run_mode ~= 0)
    return;
end
if (~isequal(get(handles.Nel_Main,'SelectionType'),'open'))
    return;
end
Menu_Edit_unit_Callback(handles.Menu_Edit_unit, eventdata, handles, varargin);

% --------------------------------------------------------------------
function varargout = Unit_info_lbl_ButtonDownFcn(h, eventdata, handles, varargin)
Unit_Info_ButtonDownFcn(handles.Unit_Info, eventdata, handles, varargin)

% --------------------------------------------------------------------
function varargout = AcqInfo_ButtonDownFcn(h, eventdata, handles, varargin)
global NelData
if (NelData.run_mode ~= 0)
    return;
end
if (~isequal(get(handles.Nel_Main,'SelectionType'),'open'))
    return;
end
Menu_Acq_Params_Callback(handles.Menu_Acq_Params, eventdata, handles, varargin);

% --------------------------------------------------------------------
function varargout = AcqInfo_lbl_ButtonDownFcn(h, eventdata, handles, varargin)
AcqInfo_ButtonDownFcn(handles.AcqInfo, eventdata, handles, varargin)

% --------------------------------------------------------------------
function varargout = PulseInfo_ButtonDownFcn(h, eventdata, handles, varargin)
global NelData
if (NelData.run_mode ~= 0)
    return;
end
if (~isequal(get(handles.Nel_Main,'SelectionType'),'open'))
    return;
end
Menu_Pulse_Params_Callback(handles.Menu_Pulse_Params, eventdata, handles, varargin);

% --------------------------------------------------------------------
function varargout = PulseInfo_lbl_ButtonDownFcn(h, eventdata, handles, varargin)
PulseInfo_ButtonDownFcn(handles.PulseInfo, eventdata, handles, varargin);

% --------------------------------------------------------------------
function varargout = Menu_Save_pic_Callback(h, eventdata, handles, varargin)
global NelData
if (isempty(NelData.UnSaved))
    return;
end
ud = get(handles.Nel_Main,'Userdata');
external_run_checkin(handles);
set(ud.run_status_handles,'Visible','on');
set([handles.Status_Line_info handles.Status_Block_info], 'Visible', 'off');
set(handles.Status_Block_info,'String',NelData.DAL.description);
set(handles.Triggering_popup,'Value',NelData.UnSaved.trig_ind);
set(handles.Comment,'String', NelData.UnSaved.comment);
if (~isempty(NelData.UnSaved.error_strs))
    waitfor(strdlg(NelData.UnSaved.error_strs, 'These Errors messages will be saved with the picture data', [], struct('WindowStyle','modal')));
end
Save_collected_data(handles, NelData.UnSaved.block_info, NelData.UnSaved.stim_info, NelData.UnSaved.error_strs);
set(ud.run_status_handles,'Visible','off');
external_run_checkout(handles)
if (isempty(NelData.UnSaved))
    set(h,'Enable','off');
end

% --------------------------------------------------------------------
function varargout = New_Unit_PB_CreateFcn(h, eventdata, handles, varargin)
[ud.cdata ud.bgmat] = ico2cdata('NEWU.ICO');
set(h,'Userdata', ud);
set(h,'CData', ud.cdata);

% --------------------------------------------------------------------
function varargout = New_Unit_PB_Callback(h, eventdata, handles, varargin)
new_unit([],[],[],'off');
Update_Unit_Info(handles);

% --------------------------------------------------------------------
function varargout = Search_PB_CreateFcn(h, eventdata, handles, varargin)
[ud.cdata ud.bgmat] = ico2cdata('SEARCH.ICO');
set(h,'Userdata', ud);
set(h,'CData', ud.cdata);

% --------------------------------------------------------------------
function varargout = Search_PB_Callback(h, eventdata, handles, varargin)
Menu_Tools_search_Callback(handles.Search_PB, eventdata, handles, varargin);

% --------------------------------------------------------------------
function varargout = Tuning_Curve_PB_CreateFcn(h, eventdata, handles, varargin)
[ud.cdata ud.bgmat] = ico2cdata('TUNING.ICO');
set(h,'Userdata', ud);
set(h,'CData', ud.cdata);

% --------------------------------------------------------------------
function varargout = Tuning_Curve_PB_Callback(h, eventdata, handles, varargin)
Menu_Tools_TC_Callback(handles.Tuning_Curve_PB, eventdata, handles, varargin);

% --------------------------------------------------------------------
function varargout = Inhibit_PB_CreateFcn(h, eventdata, handles, varargin)
[ud.cdata ud.bgmat] = ico2cdata('Inhibit.ICO');
set(h,'Userdata', ud);
set(h,'CData', ud.cdata);

% --------------------------------------------------------------------
function varargout = Inhibit_PB_Callback(h, eventdata, handles, varargin)
Menu_Tools_Inhibit_Callback(handles.Inhibit_PB, eventdata, handles, varargin);

%-----------------------------------------------------------------------

function varargout = CAP_PB_CreateFcn(h, eventdata, handles, varargin)
[ud.cdata ud.bgmat] = ico2cdata('CAP.ICO');
set(h,'Userdata', ud);
set(h,'CData', ud.cdata);

% --------------------------------------------------------------------
function varargout = CAP_PB_Callback(h, eventdata, handles, varargin)
Menu_Tools_CAP_Callback(handles.CAP_PB, eventdata, handles, varargin);

% --------------------------------------------------------------------
% AF 5/20/02
function varargout = Convert2Mac_Callback(h, eventdata, handles, varargin)
global NelData
ud = get(handles.Nel_Main,'Userdata');
external_run_checkin(handles);
descr{1} = 'Creating Mac-friendly version of data files';
descr{2} = ['in directory ''' NelData.File_Manager.dirname ''''];
set(ud.run_status_handles,'Visible','on');
set(handles.Status_Block_info,'String',descr);
dir_traverse(NelData.File_Manager.dirname,'neltext2mat',0,handles.Status_Line_info);
set(ud.run_status_handles,'Visible','off');
external_run_checkout(handles)
%%%%%%%%%%%%%%%%%%


%% AF 5/20/02 - make this backup the data folder.
% [s r] = dos('net use \\nelpc1\nchamb nchamb11 /USER:nchamb');
% ls \\nelpc1\nchamb\expdata




% --------------------------------------------------------------------
function varargout = DPOAE_PB_Callback(h, eventdata, handles, varargin)
Menu_Tools_DPOAE_Callback(handles.DPOAE_PB, eventdata, handles, varargin);

% --------------------------------------------------------------------
function varargout = DPOAE_PB_CreateFcn(h, eventdata, handles, varargin)
[ud.cdata ud.bgmat] = ico2cdata('DPOAE.ICO');
set(h,'Userdata', ud);
set(h,'CData', ud.cdata);

% --------------------------------------------------------------------
function varargout = Menu_Tools_DPOAE_Callback(h, eventdata, handles, varargin)
global NelData
external_run_checkin(handles);

% Here's where you call the function
h_dpoae = distortion_product;

if strcmp(NelData.DPOAE.rc,'stopNOSAVE')
    uiwait(h_dpoae);
end
update_nel_title(handles);

NelData = rmfield(NelData,'DPOAE');
external_run_checkout(handles);
