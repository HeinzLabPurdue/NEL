function dirname = choose_data_dir(reactivate,recursive_flag)
% dirname = choose_data_dir(reactivate)

% AF 11/28/01

global NelData data_dir SKIPintro

if (exist('reactivate','var') ~= 1)
   reactivate = 'No';
end
if (exist('recursive_flag','var') ~= 1)
   recursive_flag = 0;
end

if (recursive_flag == 0)
    if SKIPintro
        reactivate = 'Yes';
    else
        reactivate = questdlg('Reactivate an existing data directory?', 'File Manager', 'Yes','No',reactivate);
    end
end
last_data_dir = user_profile_get('last_data_dir');
switch (reactivate)
case 'Yes'
    if SKIPintro
        dirname = 'MH-2019_04_30-modernNELsetup';
    else
        d = dir(data_dir);
        d = d(find([d.isdir]==1 & strncmp('.',{d.name},1)==0)); % Only directories which are not '.' nor '..'
        str = {d.name};
        user_dirs = sort(str(strmatch(NelData.General.User,str)));
        rest_dirs = sort(setdiff(str,user_dirs));
        str = [user_dirs(end:-1:1)  rest_dirs(end:-1:1)];
        if (~isempty(last_data_dir))
            init_val = strmatch(last_data_dir,str,'exact');
        else
            init_val = '';
        end
        [selection ok] = listdlg('Name', 'File Manager', ...
            'PromptString',   'Select an Existing Data Directory:',...
            'SelectionMode',  'single',...
            'ListSize',       [300,300], ...
            'OKString',       'Re-Activate', ...
            'CancelString',   'Create new Directory', ...
            'InitialValue',    init_val, ...
            'ListString',      str);
        if (ok==0 | isempty(selection))
            dirname = choose_data_dir('No',1);
        else
            dirname = str{selection};
        end
    end
case 'No'
   dirname = [NelData.Metadata.User, '-', datestr(date,29),'-', NelData.Metadata.ChinID,'-',NelData.Metadata.Exposure,'-',NelData.Metadata.Sedation];
NelData.Metadata.Dirname=dirname;
   
   %    descr = inputdlg({['Short Description' char(10) '(e.g. ''Chin1234_AN_normal'' ''Chin1234_AN_500OBN''):']},'Experiment''s Description',1,{''},200);
%    if (~isempty(descr) & ~isempty(descr{1}))
%       dflt_name = strrep([dflt_name '-' descr{1}],' ','_');
%    end
%    valid_dirname = 0;
%    while (valid_dirname == 0)
%       dirname = inputdlg({'New directory name:'},'File Manager',1,{dflt_name},180);
%       if (isempty(dirname) | isempty(dirname{1}))
%          dirname = choose_data_dir('Yes',1);
%          valid_dirname = 1;
%       else
%          dirname = dirname{1};
         if ( (nel_mkdir(data_dir,dirname) == 1) & (nel_mkdir([data_dir dirname],'Object') == 1) ...
               & (nel_mkdir([data_dir dirname],'Signals') == 1) )
            valid_dirname = 1;
         else
            waitfor(errordlg(['Can not create directory ''' data_dir dirname ''' or it''s sub directories']));
         end
%       end
%    end
end

if (recursive_flag == 0)
   user_profile_set('last_data_dir',dirname);
   NelData.File_Manager.dirname = [data_dir dirname filesep];
   get_dir_info(NelData.File_Manager.dirname);
end
