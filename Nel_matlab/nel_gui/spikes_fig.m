function varargout = spikes_fig(varargin)
% SPIKES_FIG Application M-file for spikes_fig.fig
%    FIG = SPIKES_FIG launch spikes_fig GUI.
%    SPIKES_FIG('callback_name', ...) invoke the named callback.

% Last Modified by GUIDE v2.0 11-Dec-2001 10:28:15

global spikes_fig_handles Nactivated cont_plot_func

if ((nargin  == 0) | isnumeric(varargin{1}))
   if (nargin == 0)
      figs_num = 1;
   else
      figs_num = varargin{1};
   end
   if (isempty(spikes_fig_handles))
      spikes_fig_handles = cell(1,10);
   end
   figs_pos = calc_positions(figs_num);
   Nactivated = figs_num;
   for i = 1:figs_num
      if (isempty(spikes_fig_handles{i}) | ~ishandle(spikes_fig_handles{i}))
         spikes_fig_handles{i} = openfig(mfilename,'new');
         set(spikes_fig_handles{i},'Visible','off');
         set(spikes_fig_handles{i},'GraphicsSmoothing','off');  % Added from MS - newgraphics
         set(spikes_fig_handles{i},'Name',['Channel #' int2str(i)]);
         cur_pos = get(spikes_fig_handles{i},'Position');
         set(spikes_fig_handles{i},'Userdata',struct( ...
            'channel',  i, ...
            'single_fig_pos',  cur_pos, ...
            'orig_pos',        figs_pos{i}, ...
            'prev_size',       cur_pos(3:4)));
         % Generate a structure of handles to pass to callbacks, and store it. 
         handles = guihandles(spikes_fig_handles{i});
         guidata(spikes_fig_handles{i}, handles);
         %%
         set(spikes_fig_handles{i},'Position',figs_pos{i});
         set(spikes_fig_handles{i},'Resize','off');
         set(spikes_fig_handles{i},'Visible','on');
      end
      if isequal(get(spikes_fig_handles{i},'visible'), 'on')
         figure(spikes_fig_handles{i}); % raise it, if it is visible:
      end
   end
   
   if nargout > 0
      varargout{1} = spikes_fig_handles;
   end
   update_fig_handles;
   return;
end

if ((nargin > 0) & ischar(varargin{1})) % INVOKE NAMED SUBFUNCTION OR CALLBACK
   try
      if (nargout)
         [varargout{1:nargout}] = feval(varargin{:}); % FEVAL switchyard
      else
         feval(varargin{:}); % FEVAL switchyard
      end
   catch
      set(0,'ShowHiddenHandles','off');
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

function figs_pos = calc_positions(N)
orig_size = [870 500];
reserved = 240; % pixels, For Nel's Main window
Nrow = round(sqrt(N));
Ncol = ceil(N/Nrow);
screen_size = get_screen_size;
max_width = screen_size(3)/Ncol;
max_height = (screen_size(4)-reserved)/Nrow;
if (N>1)
   scale_factor = 1.1*max(orig_size(1)/max_width, orig_size(2)/max_height);
else
   scale_factor = max(orig_size(1)/max_width, orig_size(2)/max_height);
end  
fig_size = floor(orig_size / scale_factor);
figs_pos = cell(1,N);
x_offset = (screen_size(3)-(Ncol)*(fig_size(1)+0))/2;
for i = 1:N
   row = ceil(i/Ncol);
   col = i - (row-1)*Ncol;
   % figs_pos{i} = [ (col-1)*(fig_size(1)+8)+5  (Nrow-row)*(fig_size(2)+30)+5  fig_size];
   figs_pos{i} = [ (col-1)*(fig_size(1)+6)+x_offset  (screen_size(4)-reserved)-(row*(fig_size(2)+42)-45)  fig_size];
end
return;

% % -----------------------------------------------------------------------------------
% function varargout = reset_raster_axes(raster_params,plot_info);
% global reset_raster_params reset_rate_params
% reset_raster_params = raster_params;
% if (~isempty(reset_rate_params))
%    [raster_params rate_params] = reset_axes(reset_raster_params,reset_rate_params,plot_info);
%    reset_raster_params = []; 
%    reset_rate_params = [];
% end
% if (nargout >=1)
%    varargout{1} = raster_params;
% end
% if (nargout >=2)
%    varargout{2} = rate_params;
% end   
% return
%          
% % -----------------------------------------------------------------------------------
% function varargout = reset_rate_axes(rate_params,plot_info);
% global reset_raster_params reset_rate_params
% reset_rate_params = rate_params;
% if (~isempty(reset_raster_params))
%    [raster_params rate_params] = reset_axes(reset_raster_params,reset_rate_params,plot_info);
%    reset_raster_params = []; 
%    reset_rate_params = [];
% end
% if (nargout >=1)
%    varargout{1} = raster_params;
% end
% if (nargout >=2)
%    varargout{2} = rate_params;
% end   
% return
         
% -----------------------------------------------------------------------------------
function varargout = rearrange
global spikes_fig_handles Nactivated
for i = 1:Nactivated
   hfig = spikes_fig_handles{i};
   if (ishandle(hfig))
      ud = get(hfig,'Userdata');
      if (isfield(ud,'orig_pos'))
         set(spikes_fig_handles{i},'Position',ud.orig_pos);
      end
   end
end

% -----------------------------------------------------------------------------------
function varargout = reset_axes(raster_params,rate_params,plot_info,channels)
global spikes_fig_handles Nactivated cont_plot_func
set(0,'ShowHiddenHandles','on'); % to allow subfunctions which are not callbacks to access the figure easily.
if ((exist('channels','var') ~= 1) | isempty(channels))
   channels = 1:Nactivated;
end

%%%% Set stimulus related properties 
if (isempty(plot_info))
   plot_info = default_inloop_plot_info;
end   
label = plot_info.var_name;
if (~isempty(plot_info.var_unit))
   label = [label ' (' plot_info.var_unit ')'];
end

% Store in the params structures some usefule information
if (~isempty(raster_params))
   cont_plot_func = raster_params.func; % We may want eventually to remove this global variable!
   raster_params.var_vals = plot_info.var_vals; 
end
if (~isempty(rate_params))
   rate_params.var_vals = plot_info.var_vals;
   [xdata order] = sort(plot_info.var_vals);
   [dummy rate_params.plot_order] = sort(order);
end

% Set axes and lines for each channel. Return handles via the params structures
set([spikes_fig_handles{channels}],'Visible','off');
for i = channels(:)'
   hfig = spikes_fig_handles{i};
   ud = get(hfig,'Userdata');
   cur_pos = get(hfig,'Position');
   set(hfig,'Position',ud.single_fig_pos); % All the reset defaults applies for single channel size!
   handles = guidata(hfig);
   %%% Raster
   if (~isempty(raster_params))
      cont.haxes = handles.Cont_Axes;
      axes(cont.haxes);
      %       delete(findobj(cont.haxes,'Type','line'));  %
      delete(findobj(cont.haxes,'Type','animatedline'));
      %       cont.hraster = line(NaN,NaN);
      cont.hraster = animatedline(NaN,NaN);%MS 2017 - to reflect changes in matlab graphics from 2014b onwards
      cont.hxlabel = xlabel('Time (sec)');
      cont.hylabel = ylabel('');	
      if (~isfield(raster_params,'props'))
         dflt_params = default_plot_raster_params;
         raster_params.props = dflt_params.props;
      end   
      props = raster_params.props;
      for f = {'axes','raster','xlabel','ylabel'}
         if (isfield(props,f{1}))
            eval(['set(cont.h' f{1} ', props.' f{1} ');']);
         end
      end
      set(cont.hylabel,'String',label);
      if (~isempty(plot_info.XYprops))
         set(cont.haxes, strcat('Y',fieldnames(plot_info.XYprops))', struct2cell(plot_info.XYprops)');
      end
      raster_params.cache(i) = cont;
   end
   
   %%% Rate
   if (~isempty(rate_params))
      perline.haxes = handles.Line_Axes;
      axes(perline.haxes);
      delete(findobj(perline.haxes,'Type','line'));
      perline.hdriven = line(NaN,NaN);
      hold on;
      perline.hspont  = line(NaN,NaN);
      perline.hylabel = ylabel('');
      perline.hxlabel = xlabel('Discharge rate (sp/s)');
      if (~isfield(rate_params,'props'))
         dflt_params = default_plot_rate_params;
         rate_params.props = dflt_params.props;
      end   
      props = rate_params.props;
      for f = {'axes','driven','spont','xlabel','ylabel'}
         if (isfield(props,f{1}))
            eval(['set(perline.h' f{1} ', props.' f{1} ');']);
         end
      end
      set(perline.hylabel,'String',label);
      if (~isempty(plot_info.XYprops))
         set(perline.haxes, strcat('Y',fieldnames(plot_info.XYprops))', struct2cell(plot_info.XYprops)');
      end
      set(perline.hdriven,'Ydata',xdata, 'Xdata', NaN(size(rate_params.var_vals)));
      set(perline.hspont, 'Ydata',xdata, 'Xdata', NaN(size(rate_params.var_vals)));
      rate_params.cache(i) = perline;
   end

   set(hfig,'Position',cur_pos); % All the reset defaults applies for single channel size!
end

set([spikes_fig_handles{channels}],'Visible','on');
set(0,'ShowHiddenHandles','off');
if (nargout >=1)
   varargout{1} = raster_params;
end
if (nargout >=2)
   varargout{2} = rate_params;
end   
return

% --------------------------------------------------------------------
function varargout = Spikes_fig_DeleteFcn(h, eventdata, handles, varargin)
global spikes_fig_handles
ud = get(h,'Userdata');
spikes_fig_handles{ud.channel} = [];
update_fig_handles;
return



% --------------------------------------------------------------------
function varargout = Spikes_fig_ResizeFcn(h, eventdata, handles, varargin)
global NelData cont_plot_func

font_ratio_power = 0.25;
ud = get(h,'Userdata');
cur_pos = get(h,'Position');
%% Update axes positions
ratios = cur_pos(3:4)./ ud.prev_size;
for hs = [handles.Cont_Axes  handles.Line_Axes]
   ax_pos = get(hs,'Position');
   for i = 1:2
      if (ratios(i) >= 1)
         ax_change = (ratios(i)-1) * 0.05;
      else
         ax_change = (1 - 1/ratios(i)) * 0.05;
      end
      ax_pos(i)   = ax_pos(i)   - ax_change;
      ax_pos(2+i) = ax_pos(2+i) + ax_change;
   end
   set(hs,'Position',ax_pos);
   %% Update font size (axes and lables)
   set(hs,'FontSize',get(hs,'FontSize') * sqrt(prod(ratios))^font_ratio_power);
   hxl = get(hs,'Xlabel');
   hyl = get(hs,'Ylabel');
   if (ishandle(hxl))
      set(hxl,'FontSize',get(hxl,'FontSize') * ratios(1)^font_ratio_power);
   end
   if (ishandle(hyl))
      set(hyl,'FontSize',get(hyl,'FontSize') * ratios(2)^font_ratio_power);
   end
end
ud.prev_size = cur_pos(3:4);
set(h,'Userdata',ud);
return

% --------------------------------------------------------------------
function update_fig_handles
global spikes_fig_handles NelData
NelData.Related_Handles.spikes_fig_handles = spikes_fig_handles;
return


% --------------------------------------------------------------------
function varargout = Spikes_fig_CloseRequestFcn(h, eventdata, handles, varargin)
global NelData
if (isfield(NelData,'run_mode') & NelData.run_mode ~= 0)
   errordlg('Can not exit while in ''RUN'' mode');
   return;
else
   delete(h);
end
return

% --------------------------------------------------------------------
function varargout = Spikes_fig_KeyPressFcn(h, eventdata, handles, varargin)
global NelData
ch = get(h,'CurrentCharacter');
if (~isempty(ch))
   switch (double(ch))
   case 19 % CTRL+s
      NelData.Stop_request = 1;
      
   end
end




% --------------------------------------------------------------------
function varargout = Menu_Stop_Callback(h, eventdata, handles, varargin)
global NelData
NelData.Stop_request = 1;

