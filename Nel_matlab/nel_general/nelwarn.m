function nelwarn(strs)
% nelwarn(strs) -  Displays warning message in Nel's main window, if exists, or in a standard warndlg dialog box.
%                  strs may be a string, string array or a cell of strings.
%
%          See Also:  nelerror, errordlg, warndlg.

% AF 12/1/01
ding()
nel('nelerror',strs,1);
disp('FIX nelerror.m');
%toAppDesignerTag
%nel_App('nelerror',strs,1);
