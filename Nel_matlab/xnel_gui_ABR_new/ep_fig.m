function varargout = EP_fig(varargin)
% EP_FIG Application M-file for EP_fig.fig
%    FIG = EP_FIG launch EP_fig GUI.
%    EP_FIG('callback_name', ...) invoke the named callback.

% Last Modified by GUIDE v2.0 27-Feb-2002 13:04:18

global ep_fig_handles

if ((nargin  == 0) | isnumeric(varargin{1}))
   if (nargin == 0)
      figs_num = 1;
   else
      figs_num = varargin{1};
   end
   if (isempty(ep_fig_handles))
      ep_fig_handles = cell(1,10);
   end

%    figs_pos = calc_positions(figs_num);   %% implement later: should be done in conjunction with an update to spikes_fig
   Nactivated = figs_num;
   for i = 1:figs_num
     if (isempty(ep_fig_handles{i}) | ~ishandle(ep_fig_handles{i}))

         ep_fig_handles{i} = openfig(mfilename,'new');
         set(ep_fig_handles{i},'Visible','off');
         set(ep_fig_handles{i},'Name',['EP Channel #' int2str(i)]);
         cur_pos = get(ep_fig_handles{i},'Position');
         set(ep_fig_handles{i},'Userdata',struct( ...
            'i_ep',  i, ...
            'prev_pos',  cur_pos ));

        % Generate a structure of handles to pass to callbacks, and store it. 
         handles = guihandles(ep_fig_handles{i});
         guidata(ep_fig_handles{i}, handles);

%          set(ep_fig_handles{i},'Position',figs_pos{i});   %% implement later
         set(ep_fig_handles{i},'Resize','off');
         set(ep_fig_handles{i},'Visible','on');
         
     end

     if isequal(get(ep_fig_handles{i},'visible'), 'on')
         figure(ep_fig_handles{i}); % raise it, if it is visible:
     end
     
   end
   
   if nargout > 0
      varargout{1} = ep_fig_handles;
   end
   update_fig_handles;
   return;

elseif ischar(varargin{1}) % INVOKE NAMED SUBFUNCTION OR CALLBACK

	try
		if (nargout)
			[varargout{1:nargout}] = feval(varargin{:}); % FEVAL switchyard
		else
			feval(varargin{:}); % FEVAL switchyard
		end
	catch
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
function varargout = ep_fig_CloseRequestFcn(h, eventdata, handles, varargin)
global NelData
if (isfield(NelData,'run_mode') & NelData.run_mode ~= 0)
   errordlg('Can not exit while in ''RUN'' mode');
   return;
else
   ep_fig_DeleteFcn(h, eventdata, handles, varargin);
%    delete(h);
end
return

% --------------------------------------------------------------------
function varargout = ep_fig_DeleteFcn(h, eventdata, handles, varargin)
global ep_fig_handles
delete(h);
ep_fig_handles = [];     % will need to be updated for multiple ep channels, see "spikes_fig.m"
update_fig_handles;
return

% --------------------------------------------------------------------
function varargout = ep_fig_KeyPressFcn(h, eventdata, handles, varargin)
global NelData
ch = get(h,'CurrentCharacter');
if (~isempty(ch))
   switch (double(ch))
   case 19 % CTRL+s
      NelData.Stop_request = 1;
   end
end
return

% --------------------------------------------------------------------
function update_fig_handles
global ep_fig_handles NelData
NelData.Related_Handles.ep_fig_handles = ep_fig_handles;
return


% --------------------------------------------------------------------
function varargout = Menu_Stop_Callback(h, eventdata, handles, varargin)
global NelData
NelData.Stop_request = 1;
return

% --------------------------------------------------------------------
function varargout = ep_fig_ResizeFcn(h, eventdata, handles, varargin)
global NelData


% handles = guihandles(h);
data = get(h, 'Userdata');
i_ep = data.i_ep;

cur_pos = get(h,'Position');
data.prev_pos = cur_pos;
set(h, 'Userdata', data);

% fontSizeBase = min(18, max(6, 0.3*sqrt(prod(cur_pos(3:4)))));
XfontSizeBase = min(18, max(4, 0.5*cur_pos(3)));
YfontSizeBase = min(18, max(4, 0.5*cur_pos(4)));
fontSizeBase = min(XfontSizeBase, YfontSizeBase);
newFontSize = 3*floor(fontSizeBase/3);
leftMargin = min(10, max(5, cur_pos(3)*0.10));
rightMargin = max(2, min(8, cur_pos(3)*0.10));
newWidth = cur_pos(3) - (rightMargin+leftMargin);

%% Update axes sizing:
axY = [min(3, max(newFontSize/7, cur_pos(4)*0.085)) cur_pos(4)*0.50];
axIndex = 1;
for hs = [handles.currPlot handles.avePlot]
	clear props;
	pos(1) = leftMargin;  % x-position of bottom left corner
	pos(2) = axY(axIndex);  % y-position of bottom left corner
	pos(3) = newWidth;  % width
	pos(4) = cur_pos(4) * 0.35;  % height
	props.Position = pos;
   props.FontSize = newFontSize;
	set(hs,props);
	axIndex = axIndex+1;
end

%% Update labels sizing:
labelY = [0.43 0.90];
lblIndex = 1;
for hs = [handles.lastText handles.aveText]
	clear props;
	pos(1) = leftMargin;  % x-position of bottom left corner
	pos(2) = cur_pos(4) * labelY(lblIndex);  % y-position of bottom left corner
	pos(3) = cur_pos(3) * 0.4;  % width
	pos(4) = cur_pos(4) * 0.04;  % height
	props.Position = pos;
    props.FontSize = newFontSize;
	set(hs, props);
	lblIndex = lblIndex+1;
end

return
