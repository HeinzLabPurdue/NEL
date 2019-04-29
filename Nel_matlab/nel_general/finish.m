function finish
% Nel finish function

% AF 11/30/01

global NelData
if (isempty(NelData))
   return;
end
if (NelData.run_mode ~= 0)
   errordlg('Can not quit MATLAB while the Nel program is in ''RUN'' mode');
   quit cancel;
else
   selection = questdlg('Really quit?',...
      'Exiting MATLAB',...
      'Yes','No','Yes');
   switch selection,
   case 'Yes'
      if (ishandle(NelData.General.main_handle))
         delete(NelData.General.main_handle);
      end
   case 'No'
      quit cancel;
   end
end
