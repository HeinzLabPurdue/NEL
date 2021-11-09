function varargout = abr_checkbox(varargin)
% ABR_CHECKBOX Application M-file for abr_checkbox.fig
%    FIG = ABR_CHECKBOX launch abr_checkbox GUI.
%    ABR_CHECKBOX('callback_name', ...) invoke the named callback.

% Last Modified by GUIDE v2.0 02-Feb-2016 13:07:19
if nargin == 0  % LAUNCH GUI

	fig = openfig(mfilename,'reuse');

	% Use system color scheme for figure:
	set(fig,'Color',get(0,'defaultUicontrolBackgroundColor'));

	% Generate a structure of handles to pass to callbacks, and store it. 
	handles = guihandles(fig);
	guidata(fig, handles);

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
		disp(lasterr);
	end

end

global rerunSPLs 

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
function varargout = checkbox5_Callback(h, eventdata, handles, varargin)
global rerunSPLs 

if get(h,'Value')
    rerunSPLs=[rerunSPLs,5];
else 
    rerunSPLs=setdiff(rerunSPLs,5);
end


% --------------------------------------------------------------------
function varargout = checkbox10_Callback(h, eventdata, handles, varargin)
global rerunSPLs 

if get(h,'Value')
    rerunSPLs=[rerunSPLs,10];
else 
    rerunSPLs=setdiff(rerunSPLs,10);
end


% --------------------------------------------------------------------
function varargout = checkbox15_Callback(h, eventdata, handles, varargin)
global rerunSPLs 

if get(h,'Value')
    rerunSPLs=[rerunSPLs,15];
else 
    rerunSPLs=setdiff(rerunSPLs,15);
end


% --------------------------------------------------------------------
function varargout = checkbox20_Callback(h, eventdata, handles, varargin)
global rerunSPLs 

if get(h,'Value')
    rerunSPLs=[rerunSPLs,20];
else 
    rerunSPLs=setdiff(rerunSPLs,20);
end


% --------------------------------------------------------------------
function varargout = checkbox25_Callback(h, eventdata, handles, varargin)
global rerunSPLs 

if get(h,'Value')
    rerunSPLs=[rerunSPLs,25];
else 
    rerunSPLs=setdiff(rerunSPLs,25);
end


% --------------------------------------------------------------------
function varargout = checkbox30_Callback(h, eventdata, handles, varargin)
global rerunSPLs 

if get(h,'Value')
    rerunSPLs=[rerunSPLs,30];
else 
    rerunSPLs=setdiff(rerunSPLs,30);
end


% --------------------------------------------------------------------
function varargout = checkbox35_Callback(h, eventdata, handles, varargin)
global rerunSPLs 

if get(h,'Value')
    rerunSPLs=[rerunSPLs,35];
else 
    rerunSPLs=setdiff(rerunSPLs,35);
end


% --------------------------------------------------------------------
function varargout = checkbox40_Callback(h, eventdata, handles, varargin)
global rerunSPLs 

if get(h,'Value')
    rerunSPLs=[rerunSPLs,40];
else 
    rerunSPLs=setdiff(rerunSPLs,40);
end


% --------------------------------------------------------------------
function varargout = checkbox45_Callback(h, eventdata, handles, varargin)
global rerunSPLs 

if get(h,'Value')
    rerunSPLs=[rerunSPLs,45];
else 
    rerunSPLs=setdiff(rerunSPLs,45);
end


% --------------------------------------------------------------------
function varargout = checkbox50_Callback(h, eventdata, handles, varargin)
global rerunSPLs 

if get(h,'Value')
    rerunSPLs=[rerunSPLs,50];
else 
    rerunSPLs=setdiff(rerunSPLs,50);
end


% --------------------------------------------------------------------
function varargout = checkbox55_Callback(h, eventdata, handles, varargin)
global rerunSPLs 

if get(h,'Value')
    rerunSPLs=[rerunSPLs,55];
else 
    rerunSPLs=setdiff(rerunSPLs,55);
end


% --------------------------------------------------------------------
function varargout = checkbox60_Callback(h, eventdata, handles, varargin)
global rerunSPLs 

if get(h,'Value')
    rerunSPLs=[rerunSPLs,60];
else 
    rerunSPLs=setdiff(rerunSPLs,60);
end


% --------------------------------------------------------------------
function varargout = checkbox65_Callback(h, eventdata, handles, varargin)
global rerunSPLs 

if get(h,'Value')
    rerunSPLs=[rerunSPLs,65];
else 
    rerunSPLs=setdiff(rerunSPLs,65);
end


% --------------------------------------------------------------------
function varargout = checkbox70_Callback(h, eventdata, handles, varargin)
global rerunSPLs 

if get(h,'Value')
    rerunSPLs=[rerunSPLs,70];
else 
    rerunSPLs=setdiff(rerunSPLs,70);
end


% --------------------------------------------------------------------
function varargout = checkbox75_Callback(h, eventdata, handles, varargin)
global rerunSPLs 

if get(h,'Value')
    rerunSPLs=[rerunSPLs,75];
else 
    rerunSPLs=setdiff(rerunSPLs,75);
end


% --------------------------------------------------------------------
function varargout = checkbox80_Callback(h, eventdata, handles, varargin)
global rerunSPLs 

if get(h,'Value')
    rerunSPLs=[rerunSPLs,80];
else 
    rerunSPLs=setdiff(rerunSPLs,80);
end


% --------------------------------------------------------------------
function varargout = checkbox85_Callback(h, eventdata, handles, varargin)
global rerunSPLs 

if get(h,'Value')
    rerunSPLs=[rerunSPLs,85];
else 
    rerunSPLs=setdiff(rerunSPLs,85);
end


% --------------------------------------------------------------------
function varargout = checkbox90_Callback(h, eventdata, handles, varargin)
global rerunSPLs 

if get(h,'Value')
    rerunSPLs=[rerunSPLs,90];
else 
    rerunSPLs=setdiff(rerunSPLs,90);
end


% --------------------------------------------------------------------
function varargout = checkbox95_Callback(h, eventdata, handles, varargin)
global rerunSPLs 

if get(h,'Value')
    rerunSPLs=[rerunSPLs,95];
else 
    rerunSPLs=setdiff(rerunSPLs,95);
end



% --------------------------------------------------------------------
function varargout = checkbox100_Callback(h, eventdata, handles, varargin)
global rerunSPLs 

if get(h,'Value')
    rerunSPLs=[rerunSPLs,100];
else 
    rerunSPLs=setdiff(rerunSPLs,100);
end


% --------------------------------------------------------------------
function varargout = checkbox105_Callback(h, eventdata, handles, varargin)
global rerunSPLs 

if get(h,'Value')
    rerunSPLs=[rerunSPLs,105];
else 
    rerunSPLs=setdiff(rerunSPLs,105);
end


% --------------------------------------------------------------------
function varargout = checkbox110_Callback(h, eventdata, handles, varargin)
global rerunSPLs 

if get(h,'Value')
    rerunSPLs=[rerunSPLs,110];
else 
    rerunSPLs=setdiff(rerunSPLs,110);
end


% --------------------------------------------------------------------
function varargout = checkbox115_Callback(h, eventdata, handles, varargin)
global rerunSPLs 

if get(h,'Value')
    rerunSPLs=[rerunSPLs,115];
else 
    rerunSPLs=setdiff(rerunSPLs,115);
end



% --------------------------------------------------------------------
function varargout = checkbox120_Callback(h, eventdata, handles, varargin)
global rerunSPLs 

if get(h,'Value')
    rerunSPLs=[rerunSPLs,120];
else 
    rerunSPLs=setdiff(rerunSPLs,120);
end


% --------------------------------------------------------------------
function varargout = pushbutton1_Callback(h, eventdata, handles, varargin)
delete(handles.figure1);
