function nelerror(strs)
% nelerror(strs) - Displays error message in Nel's main window, if exists, or in a standard errordlg dialog box.
%                  strs may be a string, string array or a cell of strings.
%
%          See Also:  nelwarn, errordlg, warndlg.

% AF 12/1/01

nel('nelerror',strs,0);