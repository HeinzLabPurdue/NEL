function finish
% Nel finish function

global NelData

%AF  3/14/2025  backup to DD


if (isempty(NelData))
   return;
end


selection_save = questdlg('Save Data?',...
      'Any real Data should be Saved to Raw Archive',...
      'Yes','No','Yes');
switch selection_save
    case 'Yes'
        %Datapath='C:\NEL\ExpData\';
        FolderName =NelData.Metadata.Dirname;
        sourceFolder=NelData.File_Manager.dirname;%fullfile(Datapath,FolderName);
        DD_Path='\\datadepot.rcac.purdue.edu\depot\heinz\data\Raw Data Archived\';
        DDFolder=fullfile(DD_Path,string(year(datetime('now'))));
        DDFolder=fullfile(DDFolder,FolderName);
        copyfile(sourceFolder,DDFolder);
    case 'No'
        warning('Data will not be Saved')
end
% AF 11/30/01


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
