function [P,units] = StructDlg(struct_def,title,dflt,visible,present_val,fig_pos)
% StructDlg - dialog box for filling in structure fields.
%     P = StructDlg(struct_def, 'title' dflt)
%     struct_def is a structure whose fields will be displayed and assigned to the returned P structure.
%     The values of each of struct_def fields serve as a definition for the type and GUI appearance of 
%     that field, as will be described below. 
%     The value of each of struct_def fields should be a cell array of the general structure:
%     { factory_default_value/special_def   units  limit  protected_flag  always_recalculate_flag }
%
%     Numeric values: Limited to row vectors of any length (including the empty matrix). 
%                     The default value can be a numeric vector, or a string that is a valid matlab
%                     expression, which its evaluation result is a numeric row vector.
%                     In the later case, you must specify a limits ([] is equivalent to [-Inf Inf]), 
%                     so 'StructDlg' will interprate the field as a numeric field.
%           Examples: S.center_frequency = { 2000 'Hz' [30 50000] }; -> default of 2000, allowed range:[30 50000].
%                     S.my_parameter     = { 43 } -> default of 43, no limits.
%                     S.size_of_matrix   = { [4 12] '' [1 Inf] }; -> default of [4 12], allowed range:[1 Inf].
%               Note: The values the user enters to the dialog box for numeric fields are being 'eval'-uated,
%                     so inputs such as (sin(0.34)+2)^my_func(34.2) are possible.
%                     A field's numeric limits can be displayed by placing the mouse over the field.
%
%       Free Strings: Limited to one line string (no string arrays). The value of the string in S.field 
%                     is the default string. For no default value use the empty string (''), otherwise
%                     the field will be treated as numeric.
%
% List of Strings(1): One string that contain all the options, separated by '|'. The options will be 
%                     presented as a radio buttons. The chosen string will be the value of that field in P.
%                     Default option can be specified by enclosing it with curly brackets. Chosen string is 
%                     converted to numeric values if possible.
%            Example: S.colormap = {'hsv|{gray}|hot|bone|pink'};
%
% List of Strings(2): One Cell-array of single strings. The options will be presented as pop-up menu.
%                     The chosen option will be the value of that field in P. Default option can be 
%                     specified by enclosing it with curly brackets. chosen string is converted
%                     to numeric values if possible.
%           Examples: S.RP_sampling_frequency = { {'12207' '24414' '48828' '{97656}'} };
%                     S.Quality_of_TDT_Equipment = { {'poor' 'medium' 'good' '{take the 5th amendment}'} };
%          
%      Boolean (0/1): Value of S field must be in the form: {'0' '1'}. Default value may be specified by
%                     the curly brackets.
%            Example: S.use_filter = { {'0','{1}'} };
%
%  File Name Dialogs: Value of S field is a cell of one string that must start with 'uigetfile' or
%                     'uiputfile'. The getfile commands can be followed by the default file name or
%                     search filter enclosed by brackets. The user will be able to specify the file
%                     name directly by typing it, or to push a small pushbutton that will pop-up 
%                     Matlab's uigetfile or uipufile.
%            Example: S.parameters_file = { {'uigetfile(''d:\my_dir\*.m'')'} };
%
%      Sub-Structure: S may contain substrucutres of the same format. The user will be able to push a
%                     push-button that will call 'StructDlg' recursively for the sub-structure. 
%                     The current values of the sub-structure can be viewed by placing the mouse over
%                     the push-button.
%
%     Field
%     Self-Reference: (For numeric fields only) A numeric field may include a reference to the value of 
%                     other numeric fields. This is done using a reserved word 'this' to refer to the
%                     structure.
%            Example: S.Duration_of_Tones = { 200 'ms' [10 1000] };
%                     S.Delay             = { 50  'ms' [0  500]  };
%                     S.Stimulus_Duration = {'this.Duration_of_Tones + this.Delay' '' [0 Inf]}; -> Note that
%                     a non-empty limit is needed in order to indicate that this is a numeric filed.
%                                          
%              Notes: The value of the dependent field will be automatically updated when the values
%                     of the referenced fields changes. The automatically changed value will blink twice
%                     to alert the user. The user is then able to undo the automatic change using the 
%                     mouse's right-click.
%                     It is not possile for a sub-structure field to reference fields in other sub-structures,
%                     or in other structure levels. It is possible for a field to reference fields in 
%                     sub-structures of lower levels; however, this is highly not recommended. 
%                     
%    
%     'title' is the title of the dialog-box. 'dflt' is a structure which contain default values for P. 
%     These values will override  the default values specified in struct_def. 
%     Note that the dflt should contain the default values ONLY, not the entire 
%     definition as specified in S. This is useful for enabling user-specific defaults that override the 
%     'factory defaults'.
%
%    Final Example:   
%                     S.Wav_file = { {'uigetfile(''c:\*.wav'')'} };
%                     S.Attenuations = { [100:-1:1] 'dB' [0 120] };
%                     S.Background_noise = { {'{0}' '1'} };
%                     S.Noise_specifications.Low_cutoff = { 1 'kHz' [0 50] };
%                     S.Noise_specifications.High_cutoff = { 'min(this.Low_cutoff*2, this.Low_cutoff+8)' 'kHz' [0 50] };
%                     S.Noise_specifications.Gating = { '{Positive}|Negative|Continuous' };
%                     P = StructDlg(S,'Rate-Level Parameters');
%                     % after doing some stuff, we can ask again for user input, 
%                     % but this time, the default values will be the one he specified previously.
%                     new_P = StructDlg(S,'Rate-Level Parameters',P);
%
%
%    See also: Struct2str, Browse_Struct



% AF 10/23/01

global rec_level

if ((isempty(rec_level)) | (rec_level <0))
   rec_level = 0;
end

if (exist('struct_def','var') ~= 1)
   rec_level = rec_level-1; % For delete function.
   return
end
if ((exist('title','var') ~= 1) | isempty(title))
   title = 'Input Form';
end
if (exist('dflt','var') ~= 1)
   dflt = struct([]);
end
if ((exist('visible','var') ~= 1) | isempty(visible))
   % 'Visible' is used mainly in recursive calls for the construction of a temporary hidden form for substructures.
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
   if (isequal(visible,'on'))
      dflt = rm_ignore_dflt(dflt,struct_def);
      present_val = rm_ignore_dflt(present_val,struct_def);
   else
      present_val = rm_ignore_dflt(present_val,struct_def);
   end
   [struct_def units limits protected] = split_def(struct_def);
   fnames = fieldnames(struct_def);
   fnames_lbl = build_labels(fieldnames(struct_def),units);
   max_width = (size(char(fnames_lbl),2) + 4) * font_size/9;
   tot_height = max(5,length(fnames_lbl)* (1+vert_spacing) + vert_spacing+2.5);
   recurssion_offset = 7*(rec_level-1);
   if ((exist('fig_pos','var') ~= 1) | isempty(fig_pos))
      fig_pos = [screen_size(3)/5+recurssion_offset  screen_size(4)-tot_height-4-recurssion_offset/aspec_ratio ...
            screen_size(3)*3/5  tot_height+2];
      specified_pos = 0;
   else
      if (tot_height+2 > fig_pos(4))
         height_addition = min(fig_pos(2)-0.5,(tot_height+2 -fig_pos(4)));
         fig_pos(2) = fig_pos(2) - height_addition;
         fig_pos(4) = fig_pos(4) + height_addition;
      end
      specified_pos = 1;
   end
   h_fig = figure( ...
      'NumberTitle',         'off',...
      'Name',                title, ...
      'Units',               'char', ...
      'position',            fig_pos, ...
      'keypress',            'StructDlg(get(gcbf,''CurrentCharacter''));', ...
      'color',               get(0,'DefaultuicontrolBackgroundColor'),... 
      'Visible',             visible,... 
      'DeleteFcn',           'StructDlg;', ...
      'WindowStyle',         'modal');
   
   lbl = zeros(1,length(fnames_lbl));
   for i = 1:length(fnames_lbl)
      vert_pos = fig_pos(4)-i*(1+vert_spacing)-0.5;
      lbl(i)  = uicontrol(h_fig, ...
         'style',            'text', ...
         'units',            'char', ...
         'position',         [2.0 vert_pos max_width 1.5],...
         'String',           [fnames_lbl{i} ':'], ... 
         'fontsize',         font_size, ...
         'Tag',              ['LBL_' fnames{i}], ...
         'ForegroundColor',  col, ...
         'horizon',          'right');
   end
   ud.error = [];
   ud.specified_pos = specified_pos;
   ud.col   = col;
   ud.width = 20;
   ud.units     = units;
   ud.dflt      = dflt;
   ud.limits    = limits;
   ud.protected = protected;
   ud = set_fields_ui(struct_def,h_fig,ud,[]);
   if (~isempty(present_val))
      ud.present_val = present_val;
      ud = set_fields_ui(struct_def,h_fig,ud,[]);
      ud = rmfield(ud,'present_val');
      set(h_fig,'UserData',ud);
   end
   
   OK_vert_pos = min(0.5,fig_pos(4)-tot_height);
   if (OK_vert_pos < 0)
      slider_step = fig_pos(4) / (abs(OK_vert_pos)+fig_pos(4));
      h_slider = uicontrol(h_fig, ...
         'style',         'slider', ...
         'callback',      'StructDlg(''slider_change'');', ...
         'Units',         'char', ...
         'position',      [0  0  3  fig_pos(4)], ...
         'SliderStep',    [slider_step/5 slider_step], ...
         'Max',           abs(OK_vert_pos), ...
         'value',         abs(OK_vert_pos), ...
         'Userdata',      abs(OK_vert_pos));
   end
   h_OK = uicontrol(h_fig, ...
      'style',         'pushbutton', ...
      'callback',      'StructDlg(''ok'');', ...
      'Units',         'char', ...
      'position',      [fig_pos(3)-35  OK_vert_pos  16  1.75], ...
      'String',        'ok', ...
      'FontName',      'Helvetica', ...
      'FontSize',      11, ...
      'FontWeight',    'normal');
   
   h_reset = uicontrol(h_fig, ...
      'style',         'pushbutton', ...
      'callback',      'StructDlg(''reset'');', ...
      'Units',         'char', ...
      'position',      [fig_pos(3)-17  OK_vert_pos  16  1.75], ...
      'String',        'reset', ...
      'FontName',      'Helvetica', ...
      'FontSize',      11, ...
      'FontWeight',    'normal');
   
   if (strcmp(visible,'on'))
      reorder_childs(h_fig)
      uiwait(h_fig);
   end
   ud    = get(h_fig,'UserData');
   P     = ud.vals;
   units = ud.units;
   delete(h_fig);
   
   % Following are callbacks from the form
elseif (iscell(struct_def) & ~isempty(struct_def)) 
   StructDlgCB(struct_def{1}); % Callback from one of the regular input fields. Processed in 'StructDlgCB'.
   
elseif (isstr(struct_def)) 
   % Other push buttons or context-menus in the form.
   [cmd args] = strtok(struct_def,'(');
   if (~isempty(args))
      args = {args(2:end-1)};
   end
   if (~isempty(cmd))
      switch (cmd)
      case 'unlock'
         unlockCB(args{1},gcbf);
         
      case 'undo'
         undoCB(args{1},gcbf);
         StructDlg(args);
         
      case {'reset', char(18)}
         ud    = get(gcbf,'UserData');
         set_fields_ui(ud.orig_def,gcbf,ud,[],args,1);
         
      case {'ok', char(15), char(10)}
         ud    = get(gcbf,'UserData');
         if (isempty(ud.error))
            uiresume(gcbf);
         else
            beep;
         end
      case {'slider_change'}
         hgcbo = gcbo;
         val = get(hgcbo,'Userdata') - get(hgcbo,'Value');
         set(hgcbo,'UserData', get(hgcbo,'Value'));
         chld = get(gcbf,'Children');
         for i = 1:length(chld)
            if (chld(i) ~= hgcbo)
               cur_pos = get(chld(i),'Position');
               if (length(cur_pos) == 4) % i.e. not a uicontextmenu
                  set(chld(i),'Pos',cur_pos + [0 val 0 0]);
                  drawnow;
               end
            end
         end
         
      end
      
   end
end
   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%      
%%                        SUB FUNCTIONS                        %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%      
%%
%% Short Utility functions first:
%%
%%%%%%%%%%%%%
function [struct_def,units,limits,protected] = split_def(struct_def)
units     = struct([]);
limits    = struct([]);
protected = struct([]);
fnames = fieldnames(struct_def);
fvals  = struct2cell(struct_def);
for i = 1:length(fnames)
   switch (class(fvals{i}))
   case 'cell'
      if (length(fvals{i}) >=1)
         struct_def = setfield(struct_def,fnames{i}, fvals{i}{1});
      else
         struct_def = setfield(struct_def,fnames{i}, '');
      end
      if (length(fvals{i}) >=2)
         units = setfield(units,{1},fnames{i}, fvals{i}{2});
      end
      if (length(fvals{i}) >=3)
         if (~isempty(fvals{i}{3}))
            limits = setfield(limits,{1},fnames{i}, fvals{i}{3});
         end
      end
      if (length(fvals{i}) >=4)
         if (~isempty(fvals{i}{4}) & fvals{i}{4} == 1)
            protected = setfield(protected,{1},fnames{i},1);
         end
      end
      
   case 'struct'
      
   otherwise
   end
end

%----------------------------------------------
function dflt = rm_ignore_dflt(dflt,struct_def)
fnames = fieldnames(struct_def);
fvals  = struct2cell(struct_def);
for i = 1:length(fnames)
   switch (class(fvals{i}))
   case 'cell'
      if (length(fvals{i}) >=5)
         if (~isempty(fvals{i}{5}) & fvals{i}{5} == 1 & isfield(dflt,fnames{i}))
            dflt = rmfield(dflt,fnames{i});
         end
      end

   case 'struct'
      % tmp = rm_ignore_dflt(getfield(dflt,fnames{i}),getfield(struct_def,fnames{i}));
      % dflt = setfield(dflt,fnames{i},tmp);
      
   otherwise
   end
end

%%%%%%%%%%%%%
function fnames_lbl = build_labels(fnames,units);
%
fnames_lbl = strrep(fnames,'_',' ');
f_units = fieldnames(units);
v_units = struct2cell(units);
for i = 1:length(f_units)
   if (ischar(v_units{i}) & ~isempty(v_units{i}))
      index = strmatch(f_units{i},fnames,'exact');
      if (~isempty(index))
         fnames_lbl{index} = [fnames_lbl{index} ' (' v_units{i} ')'];
      end
   end
end
return;

%%%%%%%
% So the tab will always bring you to the first editable field (a bug-fix for Matlab Ver 6.1)
function reorder_childs(h_fig)
chld = get(h_fig,'Children');
if (length(chld) ==1)
   return;
end
for i = length(chld):-1:1
   if (strcmp(get(chld(i),'Type'),'uicontrol') & ~strcmp(get(chld(i),'Style'),'text') & ...
         strcmp(get(chld(i),'Enable'),'on'))
      ind = i;
      break;
   end
end
chld = [chld([1:ind-1 ind+1:end]) ; chld(ind)];
set(h_fig,'Children',chld);
return

%%%%%%%%
function tooltipstr = struct_tooltip(S,units)
try 
   tooltipstr = char(struct2str(S,units,70));
catch
   tooltipstr = ['sub-structure info can not be displayed. ' lasterr];
end
tooltipstr = sprintf('%s', [tooltipstr repmat(char(10),size(tooltipstr,1),1)]');
return;

%%%%%%%%
function timer(t)
tic;
while(toc < t)
end
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%  CREATION AND RESET OF UI's  %%%%%%%%%%%%%%%%%%%%%%
function ud = set_fields_ui(def,h_fig,ud,present_val,fnames,ignore_defaults)
%
% vals = def;
if ((exist('fnames','var') ~= 1) | isempty(fnames))
   fnames = fieldnames(def);
end
if (exist('ignore_defaults') ~= 1)
   ignore_defaults = 0;
end
if (~isfield(ud,'vals'))
   ud.vals = [];
end
orig_def = def;
if (isfield(ud,'present_val'))
   dflt = ud.present_val;
else
   dflt = ud.dflt;
end
ud.orig_def = orig_def;
ud.def = def;
if (~isfield(ud,'auto_update')) % needed for self-reference fields
   ud.auto_update = cell2struct(cell(size(fieldnames(def))),fieldnames(def));
end
if (~isfield(ud,'undo_vals')) 
   ud.undo_vals = cell2struct(cell(size(fieldnames(def))),fieldnames(def));
end
set(h_fig,'UserData',ud);

fig_pos = get(h_fig, 'Position');
fig_width = fig_pos(3);
for i = 1:length(fnames)
   h_lbl = findobj(h_fig,'Tag',['LBL_' fnames{i}]);
   lbl_pos = get(h_lbl,'Position');
   h = findobj(h_fig,'Tag',fnames{i});
   val = getfield(def,fnames{i});
   if (iscell(val) & isempty(val))
      val = '';
   end
   if (isfield(ud.limits,fnames{i}))
      limits = getfield(ud.limits,fnames{i});
      if (isempty(limits))
         limits = [-Inf Inf];
         ud.limits = setfield(ud.limits,{1},fnames{i},limits);
      end
   elseif (isnumeric(val))
      limits = [-Inf Inf];
      ud.limits = setfield(ud.limits,{1},fnames{i},limits);
   else
      limits = [];
   end
   if (isfield(dflt,fnames{i}) & ~ignore_defaults)
      dflt_val = getfield(dflt,fnames{i});
   else
      dflt_val = [];
   end
   
   % val is a numeric or should be evaluated to a numeric value
   if (~isempty(limits) & ~isstruct(limits)) 
      ud = reset_numeric_field(h_fig,h,fnames{i},val,lbl_pos,limits,ud,dflt_val,ignore_defaults);
      
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
      if (isfield(ud.units,fnames{i}))
         sub_units = getfield(ud.units,fnames{i});
      else
         sub_units = struct([]);
      end
      ud = reset_sub_struct_field(h_fig,h,fnames{i},val,lbl_pos,ud,dflt_val,sub_units);
   end
   if (isempty(h) | ~ishandle(h))
      % h did not exist before. Now it is!
      h = findobj(h_fig,'Tag',fnames{i});
      if (isfield(ud.protected,fnames{i}))
         set(h,'Enable',    'off');
         cmenu = get(h,'UIContextMenu');
         if (iscell(cmenu))
            cmenu = unique([cmenu{:}]);
         end
         for hi = 1:length(cmenu)
            item = uimenu(cmenu(hi), ...
               'Label',         'Unlock', ...
               'Separator',     'on', ...
               'Tag',           [fnames{i} '_UnLock'], ...
               'Callback',      ['StructDlg(''unlock(' fnames{i} ')'')'] );
         end
      end
   end
end
set(h_fig,'UserData',ud);
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ud = auto_update(fnames,ud,hfig,ignore_defaults)
for i = 1:length(fnames)
   AU = getfield(ud.auto_update,fnames{i});
   if (~isempty(AU))
      old_vals = ud.vals;
      for i = 1:length(AU)
         ud = set_fields_ui(ud.orig_def,hfig,ud,[],AU(i),ignore_defaults);   
      end
      blink_auto_changes(AU, old_vals, ud.vals, hfig)
   end
end
return;

%%%%%%%%%%%%%%%%%
function blink_auto_changes(AU_fnames, old_vals, new_vals, hfig)
blink_period = 0.2;
h = NaN*zeros(1,length(AU_fnames));
col = cell(1,length(AU_fnames));
enbl = cell(1,length(AU_fnames));
for i = 1:length(AU_fnames)
   oldval = getfield(old_vals,AU_fnames{i});
   val    = getfield(new_vals,AU_fnames{i});
   if (~all(isnan(oldval)) & ((xor(isempty(oldval),isempty(val)) | any(size(oldval)~= size(val)) | oldval ~= val)))
      h(i) = findobj(hfig,'Tag',AU_fnames{i});
      col{i} = get(h(i),'ForegroundColor');
      enbl{i} = get(h(i),'Enable');
   end
end
reps = 2;
do_wait = 0;
for j = 1:reps
   for i = 1:length(AU_fnames)
      if (ishandle(h(i)))
         set(h(i),'enable','on');
         set(h(i),'ForegroundColor',[0 0.8 .4]);
         do_wait = 1;
      end
   end
   if (do_wait)
      drawnow;
      timer(blink_period);
   end
   for i = 1:length(AU_fnames)
      if (ishandle(h(i)))
         set(h(i),'Enable',enbl{i});
         set(h(i),'ForegroundColor',col{i});
      end
   end
   if (do_wait & j < reps)
      drawnow;
      timer(blink_period);
   end
end
drawnow;
return;

%%%%%%%%%%%%%%%%%
function ud = register_undo_info(fnames,vals,ud,h_fig)
for i = 1:length(fnames)
   prev_undo = getfield(ud.undo_vals,fnames{i});
   if (~strcmp(vals{i},'NaN') & ((xor(isempty(prev_undo),isempty(vals{i})) | strcmp(prev_undo,vals{i})==0)))
      ud.undo_vals = setfield(ud.undo_vals,fnames{i},vals{i});
      h_undo = findobj(h_fig,'Tag',[fnames{i} '_UNDO']);
      if (isempty(vals{i}))
         set(h_undo,'Enable','off');
      else
         set(h_undo,'Enable','on');
      end
   end
end
return

%%%%%%%%%%%%%%%%%
function undoCB(f,h_fig)
ud = get(h_fig,'Userdata');
undo_val = getfield(ud.undo_vals,f);
if (~isempty(undo_val))
   if (~ischar(undo_val))
      undo_val = num2str(undo_val);
   end
   h = findobj(h_fig,'Tag',f);
   set(h,'String',undo_val);
   h_undo = findobj(h_fig,'Tag',[f '_UNDO']);
   set(h_undo,'Enable','off');
end
return

%%%%%%%%%%%%%%%%%
function unlockCB(f,h_fig)
h = findobj(h_fig,'Tag',f);
for i = 1:length(h)
   set(h,'Enable','on');
end
set (gcbo,'Enable','off');
return;

%%%%%%%%%%%%%%%%%
function ud = prepare2evaluate(str,f,h,ud)
self_ref = struct_mfile_reference('','this',{str});
if (isempty(self_ref))
   return;
end
self_fields = fieldnames(self_ref);
if (~isempty(self_fields))
   h_fig = get(h,'Parent');
   ud.vals = setfield(ud.vals,f,NaN);
   set(h_fig,'Userdata',ud); % Prevent recursive loops when the user does stupid things.
   for i = 1:length(self_fields)
      if (isfield(ud.def,self_fields{i}) & ~isfield(ud.vals,self_fields{i}))
         % If the refered field was not set yet, NaN it. it will be evaluated later.
         ud.vals = setfield(ud.vals,self_fields{i},NaN);
      end
      cur_AU = getfield(ud.auto_update,self_fields{i});
      if (isempty(strmatch(f,cur_AU,'exact')) & ~strcmp(self_fields{i},f))
         ud.auto_update = setfield(ud.auto_update,self_fields{i},cat(1,cur_AU,{f}));
      end
   end
end
return

%%%%%%%%%%%%%
% Protect other variables from the evaluation results, and passing 'this' as a parameter
function retval = secure_eval(this,str)
retval = eval(['[' str ']']); 
return

%%%%%%%%%%%%%
function [ud,str] = checkNset_numeric_field(h,f,limits,ud,undo_val,dflt_val,ignore_defaults)
col   = ud.col;
str = get(h,'String');
h_fig = get(h,'Parent');
try 
   iserror = 0;
   ud = prepare2evaluate(str,f,h,ud);
   if (isempty(dflt_val))
      retval = secure_eval(ud.vals,str);
   else
      retval = dflt_val;
   end
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
ud = register_undo_info({f},{undo_val},ud,h_fig);
ud.vals = setfield(ud.vals,f,retval);
if (~iserror)
   ud = auto_update({f},ud,h_fig,ignore_defaults);
end
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
function ud = reset_numeric_field(h_fig,h,f,val,lbl_pos,limits,ud,dflt_val, ignore_defaults)
strval = val;
if (~ischar(strval))
   strval = num2str(strval);
end
if (isempty(h))
   prev_str = '';
   if (length(strval) > 60)
      item_label = ['Reset (to: ''' strval(1:60) '...'')'];
   else
      item_label = ['Reset (to: ''' strval ''')'];
   end
   cmenu = uicontextmenu;
   item1 = uimenu(cmenu, ...
      'Label',     item_label, ...
      'Callback',  ['StructDlg(''reset(' f ')'')'] );
   item2 = uimenu(cmenu, ...
      'Label',     'Undo', ...
      'Enable',    'off', ...
      'Separator', 'off', ...
      'Tag',       [f '_UNDO'], ...
      'Callback',  ['StructDlg(''undo(' f ')'')'] );

   h = uicontrol(h_fig, ...
      'style',      'edit', ...
      'Units',      'char', ...
      'position',   [lbl_pos(3)+lbl_pos(1)+0.5 lbl_pos(2) 20 1.5],...
      'string',     [], ...
      'FontName',   'Helvetica', ...
      'FontSize',   9, ...
      'BackgroundColor', [1 1 1], ...
      'TooltipString', ['Allowed range: [' num2str(limits) ']'], ...
      'horizon',    'left', ...
      'Tag',        f, ...
      'UIContextMenu', cmenu, ...
      'Callback',   ['StructDlg({''' f '''});']);	
   set(item2,'Userdata',struct('uicontrol',h));
   if (ischar(val))
      h1 = uicontrol(h_fig, ...
         'style',            'text', ...
         'units',            'char', ...
         'position',         [lbl_pos(3)+lbl_pos(1)+0.5+21.5 lbl_pos(2) length(val)+10 1.5],...
         'String',           ['=(''' val ''')'], ... 
         'FontName',         'Helvetica', ...
         'fontsize',         9, ...
         'ForegroundColor',  [0.15 0.15 0.15], ...
         'FontWeight',       'light', ...
         'FontAngle',        'normal', ...
         'Tag',              '', ...
         'horizon',          'left');
      set(h,'UserData', struct('related_h',h1));
   end
end 
prev_str = get(h,'String');
set(h,'String',strval);
[ud,str] = checkNset_numeric_field(h,f,limits,ud,prev_str,dflt_val,ignore_defaults);
% fprintf('reset_numeric_field: ''%s'': %s -> %s\n', f, strval, str);
update_uicontrol_width(h,length(str)+10);
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
      'Callback',  ['StructDlg(''reset(' f ')'')'] );
   
   h = uicontrol(h_fig, ...
      'style',      'edit', ...
      'Units',      'char', ...
      'position',   [lbl_pos(3)+lbl_pos(1)+0.5 lbl_pos(2) 20 1.5],...
      'string',     [], ...
      'FontName',   'Helvetica', ...
      'FontSize',   9, ...
      'horizon',    'left', ...
      'BackgroundColor', [1 1 1], ...
      'Tag',        f, ...
      'UIContextMenu', cmenu, ...
      'Callback',   ['StructDlg({''' f '''});']);	
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
      'Callback',  ['StructDlg(''reset(' f ')'')'] );
   
   if (~ishandle(h(val_i)))
      width = min(35, 10+length(options{val_i}));
      h(val_i) = uicontrol(h_fig, ...
         'style',          'radio', ...
         'Units',          'char', ...
         'position',       [lbl_pos(3)+lbl_pos(1)+0.5+sum_width lbl_pos(2) width 1.5],...
         'string',         options{val_i}, ...
         'FontName',       'Helvetica', ...
         'FontSize',       9, ...
         'horizon',        'left', ...
         'Value',          selected(val_i), ...
         'Tag',            f, ...
         'UIContextMenu',  cmenu, ...
         'Callback',       ['StructDlg({''' f '''});']);	
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
      'Callback',      ['StructDlg(''reset(' f ')'')'] );
   
   h = [0 0];
   h(2) = uicontrol(h_fig, ...
      'style',          'edit', ...
      'Units',          'char', ...
      'position',       [lbl_pos(3)+lbl_pos(1)+0.5 lbl_pos(2) width 1.5],...
      'string',         filter_spec, ...
      'FontName',       'Helvetica', ...
      'FontSize',       9, ...
      'horizon',        'left', ...
      'BackgroundColor', [1 1 1], ...
      'Tag',            f, ...
      'UIContextMenu',  cmenu, ...
      'Callback',       ['StructDlg({''' f '''});']);
   h(1) = uicontrol(h_fig, ...
      'style',          'pushbutton', ...
      'Units',          'char', ...
      'position',       [lbl_pos(3)+lbl_pos(1)+0.5+width+0.5 lbl_pos(2)  3  1.5], ...
      'string',         char(133), ...
      'FontName',       'Helvetica', ...
      'FontSize',       9, ...
      'Tag',            f, ...
      'UIContextMenu',  cmenu, ...
      'callback',       ['StructDlg({''' f '''});']);
   
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
      'Callback',      ['StructDlg(''reset(' f ')'')'] );
   
   h = uicontrol(h_fig, ...
      'style',          'checkbox', ...
      'Units',          'char', ...
      'position',       [lbl_pos(3)+lbl_pos(1)+0.5 lbl_pos(2) 2 1.5],...
      'string',         'test', ...
      'horizon',        'left', ...
      'value',          selected, ...
      'Tag',            f, ...
      'UIContextMenu',  cmenu, ...
      'Callback',       ['StructDlg({''' f '''});']);	
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
      'Callback',      ['StructDlg(''reset(' f ')'')'] );
   
   width = size(char(val),2) + 10;
   h = uicontrol(h_fig, ...
      'style',      'popupmenu', ...
      'Units',      'char', ...
      'position',   [lbl_pos(3)+lbl_pos(1)+0.5 lbl_pos(2) width 1.5],...
      'string',     val, ...
      'FontName',   'Helvetica', ...
      'FontSize',   9, ...
      'horizon',    'left', ...
      'BackgroundColor', [1 1 1], ...
      'Value',      selected, ...
      'Tag',        f, ...
      'UIContextMenu',  cmenu, ...
      'Callback',   ['StructDlg({''' f '''});']);	
else
   set(h,'Value',  selected);
end
return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%s
%% Implemenation of recursive call (for sub-structures)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ud = reset_sub_struct_field(h_fig,h,f,val,lbl_pos,ud,dflt_val,units);
if (isfield(ud.vals,f));
   [sub_vals,sub_units] = StructDlg(val,'',getfield(ud.vals,f),'off');
else
   [sub_vals,sub_units] = StructDlg(val,'',dflt_val,'off');
end
ud.vals  = setfield(ud.vals,f,sub_vals);
ud.units = setfield(ud.units,{1},f,sub_units);
tooltipstr = struct_tooltip(sub_vals,units);
if (isempty(h))
   h = uicontrol(h_fig, ...
      'style',          'pushbutton', ...
      'Units',          'char', ...
      'position',       [lbl_pos(3)+lbl_pos(1)+0.5 lbl_pos(2)  3  1.5], ...
      'string',         char(187), ...
      'FontName',       'Helvetica', ...
      'FontSize',       9, ...
      'Tag',            f, ...
      'TooltipString',  tooltipstr, ...
      'callback',       ['StructDlg({''' f '''});']);
   
   push_ud.cmd    = 'StructDlg';
   push_ud.params = units; % units are specified here for the tooltip string only
   set(h,'Userdata',push_ud);
end
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  MAIN CALL_BACK FUNCTION %%%%%%%%%%%%%%%%%%%%%%%%%
function StructDlgCB(f)
%
hgcbf = gcbf;
ud    = get(hgcbf,'UserData');
width = ud.width;
def   = getfield(ud.def,f);
v     = getfield(ud.vals,f);
hgcbo = gcbo;
if (isfield(ud.limits,f))
   limits = getfield(ud.limits,f);
else
   limits = [];
end
undo_flag = 0;
if (strcmp(get(hgcbo,'Type'), 'uimenu'))
   hgcbo = getfield(get(hgcbo,'Userdata'),'uicontrol');
   prev_val = '';
else
   prev_val = v;
end
switch (get(hgcbo,'Style'))
case 'edit'
   if (~isempty(limits) & isnumeric(limits))
      [ud,str] = checkNset_numeric_field(hgcbo,f,limits,ud,prev_val,[],1);
   elseif (ischar(def))
      str = get(hgcbo,'String');
      width = length(str)+10;
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
   if (str(1) == '{')
      str = str(2:end-1);
   end
   setval = str2double(str);
   if (isnan(setval))
      setval = str;
   end
   ud.vals = setfield(ud.vals,f,setval);

case 'radiobutton'
   str = get(hgcbo,'String');
   h = findobj(hgcbf,'Tag',get(hgcbo,'Tag'));
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
      
   case 'StructDlg'
      if (isempty(ud.error))
         title = [get(hgcbf,'Name') '->' f];
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
         if (ud.specified_pos)
            fig_pos = get(hgcbf,'Position');
            screen_size  = get_screen_size('char');
            aspec_ratio  = screen_size(3)/screen_size(4);
            recurssion_offset = 5;
            rec_pos = [fig_pos(1)+recurssion_offset  fig_pos(2)-recurssion_offset/aspec_ratio fig_pos(3:4)];
         else
            rec_pos = [];
         end
         ret_struct = StructDlg(getfield(ud.orig_def,f),title,dflt_val,'on',v,rec_pos);
         tooltipstr = struct_tooltip(ret_struct,push_ud.params);
         set(hgcbo,'TooltipString', tooltipstr);
         ud.vals = setfield(ud.vals,f,ret_struct);
      else
         beep;
      end
   end
end
set(hgcbf,'UserData',ud);
return;
