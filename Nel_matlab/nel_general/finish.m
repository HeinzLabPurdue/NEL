function finish
% Nel finish function

global NelData

%AF  3/14/2025  backup to DD



Datapath='C:\NEL\ExpData\';
FolderName =NelData.Metadata.Dirname;
sourceFolder=fullfile(Datapath,FolderName);
DD_Path='Z:\data\Data Archived\2025\';
DDFolder=fullfile(DD_Path,FolderName);
copyfile(sourceFolder,DDFolder);

% AF 11/30/01

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
