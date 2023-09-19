function P = Struct2Form(struct_def,limits,title,f_units,dflt,visible,present_val)
% Struct2Form - dialog box for filling in structure fields.
%     P = Struct2Form(S, 'title', f_units, dflt)
%     S is a structure whose fields will be displayed and assigned to the returned P structure.
%     The values of each of S fields serve as a definition for the type, allowed-values, 
%     and GUI appearance of that field, as described below:
%
%     Numeric values: Limited to raw vectors. The first and last vector elements are the low 
%                     and high limits, respectively. The middle elements are the default values.
%           Examples: S.center_frequency = [30 2000 50000] -> default of 2000, allowed range:[30 50000].
%                     S.my_parameter     = [43] -> default of 43, no limits.
%                     S.size_of_matrix   = [1 4 12 Inf]    -> default of [4 12], allowed range:[1 Inf].
%               Note: The values the user enters to the dialog box for numeric fields are being 'eval'-uated,
%                     so inputs such as (sin(0.34)+2)^my_func(34.2) are possible.
%
%       Free Strings: Limited to one line string (no string arrays). The value of the string in S.field 
%                     is the default string. For no default value use the empty string (''), otherwise
%                     the field will be treated as numeric.
%
% List of Strings(1): One string that contain all the options, separated by '|'. The options will be 
%                     presented as a radio buttons. The chosen string will be the value of that field in P.
%                     Default option can be specified by enclosing it with curly brackets. Chosen string is 
%                     converted to numeric values if possible.
%            Example: S.colormap = 'hsv|{gray}|hot|bone|pink' 
%
% List of Strings(2): One Cell-array of single strings. The options will be presented as pop-up menu.
%                     The chosen option will be the value of that field in P. Default option can be 
%                     specified by enclosing it with curly brackets. chosen string is converted
%                     to numeric values if possible.
%           Examples: S.RP_sampling_frequency = {'12207' '24414' '48828' '{97656}'}
%                     S.Quality_of_TDT_Equipment = {'poor' 'medium' 'good' '{take the 5th amendment}'}
%          
%      Boolean (0/1): Value of S field must be in the form: {'0' '1'}. Default value may be specified by
%                     the curly brackets.
%            Example: S.use_filter = {'0','{1}'};
%
%  File Name Dialogs: Value of S field is a cell of one string that must start with 'uigetfile' or
%                     'uiputfile'. The getfile commands can be followed by the default file name or
%                     search filter enclosed by brackets. The user will be able to specify the file
%                     name directly by typing it, or to push a small pushbutton that will pop-up 
%                     Matlab's uigetfile or uipufile.
%            Example: S.parameters_file = {'uigetfile(''d:\my_dir\*.m'')'};
%
%      Sub-Structure: S may contain substrucutres of the same format. The user will be able to push a
%                     push-button that will call 'Struct2Form' recursively for the sub-structure.
%
%
%    
%     'title' is the title of the dialog-box. 'f_units' is a cell of strings which contain the 
%     unit-names for the fields in S. 'f_units' can be of length shorter than the number of fields in S.
%     'dflt' is a structure which contain default values for P. These values will override  the default 
%     values specified in S. Note that the dflt should contain the default values ONLY, not the entire 
%     definition as specified in S. This is useful for enabling user-specific defaults that override the 
%     'factory defaults'.
%
%    Final Example:   
%                     S.Frequency = 2;
%                     S.Attenuations = '[100:-1:1]';
%                     S.Background_noise = {'{0}' '1'};
%                     S.Noise_specifications.Low_cutoff = 1;
%                     S.Noise_specifications.High_cutoff = 3;
%                     S.Noise_specifications.Gating = '{Positive}|Negative|Continuous';
%                     S.Noise_specifications.Adaptation = 0;
%                     L.Frequency = [0.04 50];
%                     L.Attenuations = [0 120];
%                     L.Noise_specifications.Low_cutoff = [0 50];
%                     L.Noise_specifications.High_cutoff = [0 50];
%                     L.Noise_specifications.Adaptation = [0 20];
%                     f_units = {'kHz' 'dB' '' {'kHz' 'kHz' '' 'sec'}};
%                     P = Struct2Form(S,L,'Rate-Level Parameters',f_units);
%                     % after doing some stuff, we can ask again for user input, 
%                     % but this time, the default values will be the one he specified previously.
%                     new_P = Struct2Form(S,'Rate-Level Parameters',f_units,P);



% AF 10/23/01

global rec_level

if ((isempty(rec_level)) | (rec_level <0))
   rec_level = 0;
end

if (exist('struct_def','var') ~= 1)
   rec_level = rec_level-1; % For delete function.
   return
end
if (exist('limits','var') ~= 1)
   limits = [];
end
if (exist('title','var') ~= 1)
   title = 'Input Form';
end
if (exist('f_units','var') ~= 1)
   f_units = {};
end
if (exist('dflt','var') ~= 1)
   dflt = [];
end
if (exist('visible','var') ~= 1)
   % 'Visible' is used in recursive calls for the construction of a temporary hidden form for substructures.
   visible = 'on'; 
end
if (exist('present_val','var') ~= 1)
   present_val = []; % 'present_val' is used to pass the last value of sub-structure fields.
end

vert_spacing = 1;
font_size    = 11;
col          = 'k';
screen_size  = get_screen_size('char');
aspec_ratio  = screen_size(3)/screen_size(4);

if (isstruct(struct_def)) % Init
   rec_level = rec_level+1;
   fnames = fieldnames(struct_def);
   fnames_lbl = build_labels(fieldnames(struct_def),f_units);
   max_width = (size(char(fnames_lbl),2) + 4) * font_size/9;
   tot_height = max(7,length(fnames_lbl)* (1+vert_spacing) + vert_spacing+3);
   recurssion_offset = 7*(rec_level-1);
   fig_pos = [screen_size(3)/5+recurssion_offset  screen_size(4)-tot_height-4-recurssion_offset/aspec_ratio ...
         screen_size(3)*3/5  tot_height];
   h_fig = figure( ...
      'NumberTitle',         'off',...
      'Name',                title, ...
      'Units',               'char', ...
      'position',            fig_pos, ...
      'keypress',            'Struct2Form(get(gcbf,''CurrentCharacter''));', ...
      'color',               get(0,'DefaultuicontrolBackgroundColor'),... 
      'Visible',             visible,... 
      'DeleteFcn',           'Struct2Form;', ...
      'WindowStyle',         'modal');
   
   lbl = zeros(1,length(fnames_lbl));
   for i = 1:length(fnames_lbl)
      vert_pos = tot_height-i*(1+vert_spacing);
      lbl(i)  = uicontrol(h_fig, ...
         'style',            'text', ...
         'units',            'char', ...
         'position',         [0.5 vert_pos max_width 1.5],...
         'String',           [fnames_lbl{i} ':'], ... 
         'fontsize',         font_size, ...
         'Tag',              ['LBL_' fnames{i}], ...
         'ForegroundColor',  col, ...
         'horizon',          'right');
   end
   ud.error = [];
   ud.col   = col;
   ud.width = 20;
   % ud.lbl   = lbl;
   ud.f_units = f_units;
   ud.dflt    = dflt;
   ud.limits  = limits;
   set_fields_ui(struct_def,h_fig,ud,[]);
   if (~isempty(present_val))
      set_fields_ui(struct_def,h_fig,ud,present_val);
   end
   
   h_OK = uicontrol(h_fig, ...
      'style',         'pushbutton', ...
      'callback',      'Struct2Form(''ok'');', ...
      'Units',         'char', ...
      'position',      [fig_pos(3)-37  1  14  2], ...
      'String',        'ok', ...
      'FontName',      'Helvetica', ...
      'FontSize',      11, ...
      'FontWeight',    'normal');
   
   h_reset = uicontrol(h_fig, ...
      'style',         'pushbutton', ...
      'callback',      'Struct2Form(''reset'');', ...
      'Units',         'char', ...
      'position',      [fig_pos(3)-20  1  14  2], ...
      'String',        'reset', ...
      'FontName',      'Helvetica', ...
      'FontSize',      11, ...
      'FontWeight',    'normal');
   
if (strcmp(visible,'on'))
      uiwait(h_fig);
      ud    = get(h_fig,'UserData');
      P = ud.vals;
      delete(h_fig);
   else
      P = h_fig;
   end
   
   % Following are callbacks from the form
elseif (iscell(struct_def) & ~isempty(struct_def)) 
   Struct2FormCB(struct_def{1}); % Callback from one of the regular input fields. Processed in 'Struct2FormCB'.
   
elseif (isstr(struct_def)) 
   % Other push buttons in the form.
   [cmd args] = strtok(struct_def,'(');
   if (~isempty(cmd))
      switch (cmd)
      case {'reset', char(18)}
         ud    = get(gcbf,'UserData');
         if (~isempty(args))
            args = {args(2:end-1)};
         end
         set_fields_ui(ud.orig_def,gcbf,ud,[],args);
         
      case {'ok', char(15), char(10)}
         ud    = get(gcbf,'UserData');
         if (isempty(ud.error))
            uiresume(gcbf);
         end
      end
   end
end
   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%      
%%                        SUB FUNCTIONS                        %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%      
function fnames_lbl = build_labels(fnames,f_units);
%
fnames_lbl = strrep(fnames,'_',' ');
for i = 1:min(length(fnames_lbl),length(f_units))
   if (ischar(f_units{i}) & ~isempty(f_units{i}))
      fnames_lbl{i} = [fnames_lbl{i} ' (' f_units{i} ')'];
   end
end
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%  CREATION AND RESET OF UI's  %%%%%%%%%%%%%%%%%%%%%%
function set_fields_ui(def,h_fig,ud,present_val,fnames)
%
% vals = def;
if ((exist('fnames','var') ~= 1) | isempty(fnames))
   fnames = fieldnames(def);
end
if (~isfield(ud,'vals'))
   ud.vals = [];
end
orig_def = def;
if (~isempty(present_val))
   dflt = present_val;
else
   dflt = ud.dflt;
end
fig_pos = get(h_fig, 'Position');
fig_width = fig_pos(3);
ud.error    = [];
for i = 1:length(fnames)
   h_lbl = findobj(h_fig,'Tag',['LBL_' fnames{i}]);
   lbl_pos = get(h_lbl,'Position');
   h = findobj(h_fig,'Tag',fnames{i});
   val = getfield(def,fnames{i});
   if (isfield(ud.limits,fnames{i}))
      limits = getfield(ud.limits,fnames{i});
      if (isempty(limits))
         limits = [-Inf Inf];
         ud.limits = setfield(ud.limits,fnames{i},limits);
      end
   elseif (isnumeric(val))
      limits = [-Inf Inf];
      ud.limits = setfield(ud.limits,fnames{i},limits);
   else
      limits = [];
   end
   if (isfield(dflt,fnames{i}))
      dflt_val = getfield(dflt,fnames{i});
   else
      dflt_val = [];
   end
   
   % val is a numeric or should be evaluated to a numeric value
   if (~isempty(limits) & ~isstruct(limits)) 
      if (~isempty(dflt_val))
         val = dflt_val;
      end
      ud = reset_numeric_field(h_fig,h,fnames{i},val,lbl_pos,limits,ud);
      
   elseif (ischar(val))
      sep = findstr(val,'|');
      if (isempty(sep))
         if (~isempty(dflt_val))
            val = dflt_val;
         end
         ud = reset_char_field(h_fig,h,fnames{i},val,lbl_pos,ud);

      else
         ud = reset_radio_field(h_fig,h,fnames{i},val,lbl_pos,ud,sep,dflt_val);
      end
      
   elseif (iscell(val))
      % Special requests
      if ((length(val) == 1) & ischar(val{1})) 
         if (~isempty(strmatch('uigetfile',val{1})) | ~isempty(strmatch('uiputfile',val{1})))
            ud = reset_getfile_field(h_fig,h,fnames{i},val,lbl_pos,ud,dflt_val);
         end
      elseif ((length(val) == 2) & strmatch(val{1},{'0','{0}'},'exact') & strmatch(val{2},{'1','{1}'},'exact'))
         ud = reset_checkbox_field(h_fig,h,fnames{i},val,h_lbl,lbl_pos,ud,dflt_val);
      else
         ud = reset_popupmenu_field(h_fig,h,fnames{i},val,lbl_pos,ud,dflt_val);
      end
      
   elseif (isstruct(val))
      if (length(ud.f_units) >= i)
         sub_f_units = ud.f_units{i};
      else
         sub_f_units = {''};
      end
      ud = reset_sub_struct_field(h_fig,h,fnames{i},val,lbl_pos,ud,dflt_val,limits,sub_f_units);
   end
   
end
ud.orig_def = orig_def;
ud.def = def;
% ud.vals = vals;
set(h_fig,'UserData',ud);
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [ud,str] = checkNset_numeric_field(h,f,limits,ud)
col   = ud.col;
str = get(h,'String');
try 
   iserror = 0;
   retval = eval(['[' str ']']); 
   if (~isnumeric(retval))
      str = 'Numbers only!';
      iserror = 1;
   elseif (any(retval < limits(1) | retval > limits(2)))
      str = ['Allowed range: [' num2str(limits) ']'];
      iserror = 1;
   else
      str    = num2str(retval);
   end
catch
   iserror = 1; 
   str     = strrep(lasterr,char(10),': ');
end
if (iserror)
   ud.error = setfield(ud.error,f,1);
   retval = [];
   col = 'r';
elseif (isfield(ud.error,f))
   ud.error = rmfield(ud.error,f);
end
set(h,'String',str);
set(h,'ForegroundColor',col);
ud.vals = setfield(ud.vals,f,retval);
return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function update_uicontrol_width(h,width)
hud = get(h,'UserData');
if ((isfield(hud,'related_h')) & (ishandle(hud.related_h)))
   related_h = hud.related_h;
   related_pos = get(related_h,'Position');
   related_width = related_pos(3);
else
   related_h = [];
   related_width = 0;
end
fig_pos = get(get(h,'Parent'),'Position');
pos = get(h,'Position');
fig_width = fig_pos(3);
width = min(width, fig_width-related_width-pos(1)-1);
width_change = width - pos(3);
pos(3) = width;
set(h,'Position',pos);
if (~isempty(related_h))
   related_pos(1) = related_pos(1) + width_change;
   set(related_h,'Position',related_pos);
end
return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Implemetation of Numeric field (including function evaluation)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ud = reset_numeric_field(h_fig,h,f,val,lbl_pos,limits,ud)
strval = val;
if (~ischar(strval))
   strval = num2str(strval);
end
if (isempty(h))
   if (length(strval) > 60)
      item_label = ['Reset (to: ''' strval(1:60) '...'')'];
   else
      item_label = ['Reset (to: ''' strval ''')'];
   end
   cmenu = uicontextmenu;
   item1 = uimenu(cmenu, ...
      'Label',     item_label, ...
      'Callback',  ['Struct2Form(''reset(' f ')'')'] );

   h = uicontrol(h_fig, ...
      'style',      'edit', ...
      'Units',      'char', ...
      'position',   [lbl_pos(3)+1 lbl_pos(2) 20 1.5],...
      'string',     [], ...
      'FontName',   'Helvetica', ...
      'FontSize',   9, ...
      'TooltipString', ['Allowed range: [' num2str(limits) ']'], ...
      'horizon',    'left', ...
      'Tag',        f, ...
      'UIContextMenu', cmenu, ...
      'Callback',   ['Struct2Form({''' f '''});']);	
   
   if (ischar(val))
      h1 = uicontrol(h_fig, ...
         'style',            'text', ...
         'units',            'char', ...
         'position',         [lbl_pos(3)+1+21.5 lbl_pos(2) length(val)+10 1.5],...
         'String',           ['=(''' val ''')'], ... 
         'FontName',         'Helvetica', ...
         'fontsize',         9, ...
         'ForegroundColor',  [0.15 0.15 0.15], ...
         'FontWeight',       'light', ...
         'FontAngle',        'normal', ...
         'Tag',              '', ...
         'horizon',          'left');
      set(h,'UserData', struct('related_h',h1));
      % 'ForegroundColor',  , ...
   end
end 
set(h,'String',strval);
[ud,str] = checkNset_numeric_field(h,f,limits,ud);
update_uicontrol_width(h,length(str)+8);
return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Implementation of Open String field
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ud = reset_char_field(h_fig,h,f,val,lbl_pos,ud);
ud.vals = setfield(ud.vals,f,val);
if (isempty(h))
   cmenu = uicontextmenu;
   item1 = uimenu(cmenu, ...
      'Label',     ['Reset (to: ''' val ''')'], ...
      'Callback',  ['Struct2Form(''reset(' f ')'')'] );
   
   h = uicontrol(h_fig, ...
      'style',      'edit', ...
      'Units',      'char', ...
      'position',   [lbl_pos(3)+1 lbl_pos(2) 20 1.5],...
      'string',     [], ...
      'FontName',   'Helvetica', ...
      'FontSize',   9, ...
      'horizon',    'left', ...
      'Tag',        f, ...
      'UIContextMenu', cmenu, ...
      'Callback',   ['Struct2Form({''' f '''});']);	
end
set(h,'String',val);
pos = get(h,'Position');
pos(3) = length(val)+5;
set(h,'Position',pos);
set(h,'ForegroundColor',ud.col);
return
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Implemenation of Radio Buttons
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ud = reset_radio_field(h_fig,h,f,val,lbl_pos,ud,sep,dflt_val)
selected = 1;
sep = [0 sep length(val)+1];
options = cell(1,length(sep)-1);
if (isempty(h))
   h = NaN*zeros(1,length(options));
end
selected = zeros(1,length(options));
selected_str = '';
setval = '';
for sep_i = 1:length(sep)-1
   options{sep_i} = val(sep(sep_i)+1:sep(sep_i+1)-1);
   if ((~isempty(options{sep_i})) & (options{sep_i}(1) == '{' & options{sep_i}(end) == '}'))
      options{sep_i} = options{sep_i}(2:end-1);
      selected(sep_i) = 1;
      selected_str = options{sep_i};
      setval = str2double(options{sep_i});
      if (isnan(setval))
         setval = options{sep_i};
      end
   end
end
ud.vals = setfield(ud.vals,f,setval);
if (~isempty(dflt_val))
   if (isnumeric(dflt_val))
      dflt_val = num2str(dflt_val);
   end
   dflt_selected = strmatch(dflt_val,options,'exact');
   if (~isempty(dflt_selected))
      ud.vals = setfield(ud.vals,f,dflt_val);
      selected = zeros(1,length(options));
      selected(dflt_selected) = 1;
      selected_str = options{dflt_selected};
   end
end
sum_width = 0;
for val_i = 1:length(options)
   cmenu = uicontextmenu;
   item1 = uimenu(cmenu, ...
      'Label',     ['Reset (to: ''' selected_str ''')'], ...
      'Callback',  ['Struct2Form(''reset(' f ')'')'] );
   
   if (~ishandle(h(val_i)))
      width = min(35, 10+length(options{val_i}));
      h(val_i) = uicontrol(h_fig, ...
         'style',          'radio', ...
         'Units',          'char', ...
         'position',       [lbl_pos(3)+1+sum_width lbl_pos(2) width 1.5],...
         'string',         options{val_i}, ...
         'FontName',       'Helvetica', ...
         'FontSize',       9, ...
         'horizon',        'left', ...
         'Value',          selected(val_i), ...
         'Tag',            f, ...
         'UIContextMenu',  cmenu, ...
         'Callback',       ['Struct2Form({''' f '''});']);	
      sum_width = sum_width + width;
   else
      if (strcmp(get(h(val_i),'String'), selected_str))
         set(h(val_i),'Value',     1);
      else
         set(h(val_i),'Value',     0);
      end
   end
end
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Implementation of Getfile and Putfile
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ud = reset_getfile_field(h_fig,h,f,val,lbl_pos,ud,dflt_val)
lpar = min(findstr(val{1}, '('''));
rpar = max(findstr(val{1}, ''')'));
if (~isempty(dflt_val))
   filter_spec = dflt_val;
elseif (~isempty(lpar) & ~isempty(rpar))
   filter_spec = val{1}(lpar+2:rpar-1);
else
   filter_spec = '';
end
cmd = val{1}(1:9);
width = max(20,length(filter_spec)+10);
if (isempty(h))
   cmenu = uicontextmenu;
   item1 = uimenu(cmenu, ...
      'Label',         ['Reset (to: ''' filter_spec ''')'], ...
      'Callback',      ['Struct2Form(''reset(' f ')'')'] );
   
   h = [0 0];
   h(2) = uicontrol(h_fig, ...
      'style',          'edit', ...
      'Units',          'char', ...
      'position',       [lbl_pos(3)+1 lbl_pos(2) width 1.5],...
      'string',         filter_spec, ...
      'FontName',       'Helvetica', ...
      'FontSize',       9, ...
      'horizon',        'left', ...
      'Tag',            f, ...
      'UIContextMenu',  cmenu, ...
      'Callback',       ['Struct2Form({''' f '''});']);
   h(1) = uicontrol(h_fig, ...
      'style',          'pushbutton', ...
      'Units',          'char', ...
      'position',       [lbl_pos(3)+1+width+0.5 lbl_pos(2)  3  1.5], ...
      'string',         char(133), ...
      'FontName',       'Helvetica', ...
      'FontSize',       9, ...
      'Tag',            f, ...
      'UIContextMenu',  cmenu, ...
      'callback',       ['Struct2Form({''' f '''});']);
   
   push_ud.cmd    = cmd;
   push_ud.params = h(2);
   set(h(1),'Userdata',push_ud);
   set(h(2),'Userdata', struct('related_h', h(1)));
end
str_h = findobj(h, 'style', 'edit');
set(str_h,'string',filter_spec);
update_uicontrol_width(str_h,width);
ud.vals = setfield(ud.vals,f,filter_spec);
% ud.def = setfield(ud.def,f,filter_spec);
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Implemenation of Binary Check Box
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ud = reset_checkbox_field(h_fig,h,f,val,h_lbl,lbl_pos,ud,dflt_val)
if ((~isempty(dflt_val)) & (dflt_val == 0 | dflt_val == 1))
   selected = dflt_val;
else
   selected = min(strmatch('{',val)) - 1;
   if (isempty(selected))
      selected = 0;
   end
end
if (isempty(h))
   if (selected)
      opt_label = 'Checked';
   else
      opt_label = 'UnChecked';
   end
   cmenu = uicontextmenu;
   item1 = uimenu(cmenu, ...
      'Label',         ['Reset (to: ''' opt_label ''')'], ...
      'Callback',      ['Struct2Form(''reset(' f ')'')'] );
   
   h = uicontrol(h_fig, ...
      'style',          'checkbox', ...
      'Units',          'char', ...
      'position',       [lbl_pos(3)+1 lbl_pos(2) 2 1.5],...
      'string',         'test', ...
      'horizon',        'left', ...
      'value',          selected, ...
      'Tag',            f, ...
      'UIContextMenu',  cmenu, ...
      'Callback',       ['Struct2Form({''' f '''});']);	
end
set(h, 'value',      selected);
lbl_str = get(h_lbl,'String');
lbl_str(end) = '?';
set(h_lbl,'String',lbl_str);
ud.vals = setfield(ud.vals,f,selected);
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Implemenation of popupmenu
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ud = reset_popupmenu_field(h_fig,h,f,val,lbl_pos,ud,dflt_val)
selected = 1;
for val_i = 1:length(val)
   if (val{val_i}(1) == '{' & val{val_i}(end) == '}')
      val{val_i} = val{val_i}(2:end-1);
      selected = val_i;
   end
end
setval = str2double(val{selected});
if (isnan(setval))
   setval = val{selected};
end
ud.vals = setfield(ud.vals,f,setval);
if (~isempty(dflt_val))
   if (isnumeric(dflt_val))
      dflt_val = num2str(dflt_val);
   end
   dflt_selected = strmatch(dflt_val,val,'exact');
   if (~isempty(dflt_selected))
      ud.vals = setfield(ud.vals,f,dflt_val);
      selected = dflt_selected;
   end
end
if (isempty(h))
   opt_label = getfield(ud.vals,f);
   if (isnumeric(opt_label))
      opt_label = num2str(opt_label);
   end
   cmenu = uicontextmenu;
   item1 = uimenu(cmenu, ...
      'Label',         ['Reset (to: ''' opt_label ''')'], ...
      'Callback',      ['Struct2Form(''reset(' f ')'')'] );
   
   width = size(char(val),2) + 10;
   h = uicontrol(h_fig, ...
      'style',      'popupmenu', ...
      'Units',      'char', ...
      'position',   [lbl_pos(3)+1 lbl_pos(2) width 1.5],...
      'string',     val, ...
      'FontName',   'Helvetica', ...
      'FontSize',   9, ...
      'horizon',    'left', ...
      'Value',      selected, ...
      'Tag',        f, ...
      'UIContextMenu',  cmenu, ...
      'Callback',   ['Struct2Form({''' f '''});']);	
else
   set(h,'Value',  selected);
end
return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%s
%% Implemenation of recursive call (for sub-structures)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ud = reset_sub_struct_field(h_fig,h,f,val,lbl_pos,ud,dflt_val,limits,f_units);
if (isfield(ud.vals,f));
   hidden_fig = Struct2Form(val,limits,'',{},getfield(ud.vals,f),'off');
else
   hidden_fig = Struct2Form(val,limits,'',{},dflt_val,'off');
end
hidden_ud = get(hidden_fig,'Userdata');
ud.vals = setfield(ud.vals,f,hidden_ud.vals);
delete(hidden_fig);
if (isempty(h))
   h = uicontrol(h_fig, ...
      'style',          'pushbutton', ...
      'Units',          'char', ...
      'position',       [lbl_pos(3)+1 lbl_pos(2)  3  1.5], ...
      'string',         char(187), ...
      'FontName',       'Helvetica', ...
      'FontSize',       9, ...
      'Tag',            f, ...
      'callback',       ['Struct2Form({''' f '''});']);
   
   push_ud.cmd    = 'Struct2Form';
   push_ud.params = f_units;
   set(h,'Userdata',push_ud);
end
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  MAIN CALL_BACK FUNCTION %%%%%%%%%%%%%%%%%%%%%%%%%
function Struct2FormCB(f)
%
ud    = get(gcbf,'UserData');
width = ud.width;
def   = getfield(ud.def,f);
v     = getfield(ud.vals,f);
hgcbo = gcbo;
if (isfield(ud.limits,f))
   limits = getfield(ud.limits,f);
else
   limits = [];
end
switch (get(hgcbo,'Style'))
case 'edit'
   if (~isempty(limits) & isnumeric(limits))
      [ud,str] = checkNset_numeric_field(hgcbo,f,limits,ud);
   elseif (ischar(def))
      str = get(hgcbo,'String');
      width = length(str)+8;
      ud.vals = setfield(ud.vals,f,str);
   elseif (iscell(def)) %% special commands' edit window
      str = get(hgcbo,'String');
      retval = str2num(str);
      if (isempty(retval))
         retval = str;
      end
      ud.vals = setfield(ud.vals,f,retval);
   end
   update_uicontrol_width(hgcbo,length(str)+10)
   
case 'popupmenu'
   val = get(hgcbo,'Value');
   str = def{val};
   setval = str2double(str);
   if (isnan(setval))
      setval = str;
   end
   ud.vals = setfield(ud.vals,f,setval);

case 'radiobutton'
   str = get(hgcbo,'String');
   h = findobj(gcbf,'Tag',get(hgcbo,'Tag'));
   for h_i = 1:length(h)
      if (~strcmp(str,get(h(h_i),'String')))
         set(h(h_i),'Value',0);
      end
   end
   setval = str2double(str);
   if (isnan(setval))
      setval = str;
   end
   ud.vals = setfield(ud.vals,f,setval);
   
case 'checkbox'
   val = get(hgcbo,'Value');
   ud.vals = setfield(ud.vals,f,val);
   
case 'pushbutton'
   push_ud = get(hgcbo,'Userdata');
   switch (push_ud.cmd)
   case {'uigetfile','uiputfile'}
      filter_spec = get(push_ud.params,'String');
      eval(['[fname, pname] = ' push_ud.cmd '(filter_spec);'])
      if (fname)
         str = [pname fname];
         set(push_ud.params,'String',str);
         ud.vals = setfield(ud.vals,f,str);
         
         width = length(str)+14;
         update_uicontrol_width(push_ud.params, width)
      end
      
   case 'Struct2Form'
      if (isempty(ud.error))
         title = [get(gcbf,'Name') '->' f];
         if (isfield(ud.dflt,f))
            dflt_val = getfield(ud.dflt,f);
         else
            dflt_val = [];
         end
         if (isfield(ud.limits,f))
            limits = getfield(ud.limits,f);
         else
            limits = [];
         end
         ret_struct = Struct2Form(getfield(ud.orig_def,f),limits,title,push_ud.params,dflt_val,'on',v);
         ud.vals = setfield(ud.vals,f,ret_struct);
      end
   end
end
set(gcbf,'UserData',ud);
return;
