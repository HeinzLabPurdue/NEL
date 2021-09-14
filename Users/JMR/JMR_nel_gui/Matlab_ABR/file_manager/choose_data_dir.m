function dirname = choose_data_dir(reactivate,recursive_flag)

global NelData data_dir

if (exist('reactivate','var') ~= 1)
   reactivate = 'No';
end
if (exist('recursive_flag','var') ~= 1)
   recursive_flag = 0;
end

if (recursive_flag == 0)
    reactivate = questdlg('Reactivate an existing data directory?','File Manager');
end

switch (reactivate)
case 'Yes'
    d = dir(data_dir);
    d = d(find([d.isdir]==1 & strncmp('.',{d.name},1)==0)); % Only directories which are not '.' nor '..'
    str = {d.name};
    user_dirs = sort(str(strmatch(NelData.General.User,str)));
    rest_dirs = sort(setdiff(str,user_dirs));
    str = [user_dirs(end:-1:1)  rest_dirs(end:-1:1)];
    last_data_dir = NelData.General.CurDataDir;
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
case 'No'
    dflt_name = [NelData.General.User '-' strrep(datestr(date,29),'-','_')];
    descr = inputdlg({['Short Description' char(10) '(e.g.; ABRs, CAL):']},'Experiment''s Description',1,{'ABR'});
    drawnow;
    if (~isempty(descr) & ~isempty(descr{1}))
        dflt_name = strrep([dflt_name '-' descr{1}],' ','_');
    end
    valid_dirname = 0;
    while (valid_dirname == 0)
        dirname = inputdlg({'New directory name:'},'File Manager',1,{dflt_name});
        drawnow;
        if (isempty(dirname) | isempty(dirname{1}))
            dirname = choose_data_dir('Yes',1);
            valid_dirname = 1;
        else
            dirname = dirname{1};
            if nel_mkdir(data_dir,dirname) == 1
                valid_dirname = 1;
            else
                waitfor(errordlg(['Cannot create directory ''' data_dir dirname ''' or it''s sub directories']));
                drawnow;
            end
        end
    end
end
