function make_explist

%make_explist builds structure for file archive

global EXPS root_dir

fm_dir = cd([root_dir 'file_manager\']);
error = 0;
fid = fopen([fm_dir 'temp.m'],'wt+');

fprintf(fid,'%s\n\n','%EXPLIST builds structure for file archive');

%writing owner data
[lastfile] = length(struct2cell(EXPS.owners));
fprintf(fid,'%s%s%s\n','owners = struct(''A'',''',EXPS.owners.A,''', ...');
for i = 2:lastfile -1
    prefix = char(64+i);
    eval(sprintf('%s%c%c','this_owner = EXPS.owners.',prefix,';'));
    ocount = fprintf(fid,'\t%c%c%s%s%s\n','''',prefix,''',''',this_owner,''', ...');
    if ~ocount
        ErrDlg = errordlg('EXPLIST: Trouble reading owners!','File Manager');
        uiwait(ErrDlg);
        error = 1;
        break
    end
end
if ~error
    prefix = char(64+lastfile);
    eval(sprintf('%s%c%c','this_owner = EXPS.owners.',prefix,';'));
    ocount = fprintf(fid,'\t%c%c%s%s%s\n\n','''',prefix,''',''',this_owner,''');');
    if ~ocount
        ErrDlg = errordlg('EXPLIST: Trouble reading owners!','File Manager');
        uiwait(ErrDlg);
        error = 1;
    end
end

%writing dates
if ~error
    fprintf(fid,'%s%s%s\n','dates = struct(''A'',''',EXPS.dates.A,''', ...');
    for i = 2:lastfile -1
        prefix = char(64+i);
        eval(sprintf('%s%c%c','this_date = EXPS.dates.',prefix,';'));
        dcount = fprintf(fid,'\t%c%c%s%s%s\n','''',prefix,''',''',this_date,''', ...');
        if ~dcount
            ErrDlg = errordlg('EXPLIST: Trouble reading dates!','File Manager');
            uiwait(ErrDlg);
            error = 1;
            break
        end
    end
end
if ~error
    prefix = char(64+lastfile);
    eval(sprintf('%s%c%c','this_date = EXPS.dates.',prefix,';'));
    dcount = fprintf(fid,'\t%c%c%s%s%s\n\n','''',prefix,''',''',this_date,''');');
    if ~dcount
        ErrDlg = errordlg('EXPLIST: Trouble reading dates!','File Manager');
        uiwait(ErrDlg);
        error = 1;
    end
end

%writing file numbers
if ~error
    fprintf(fid,'%s%s%s\n','files = struct(''A'',''',EXPS.files.A,''', ...');
    for i = 2:lastfile -1
        prefix = char(64+i);
        eval(sprintf('%s%c%c','this_file = EXPS.files.',prefix,';'));
        fcount = fprintf(fid,'\t%c%c%s%s%s\n','''',prefix,''',''',this_file,''', ...');
        if ~fcount
            ErrDlg = errordlg('EXPLIST: Trouble reading files!','File Manager');
            uiwait(ErrDlg);
            error = 1;
            break
        end
    end
end
if ~error
    prefix = char(64+lastfile);
    eval(sprintf('%s%c%c','this_file = EXPS.files.',prefix,';'));
    fcount = fprintf(fid,'\t%c%c%s%s%s\n\n','''',prefix,''',''',this_file,''');');
    if ~fcount
        ErrDlg = errordlg('EXPLIST: Trouble reading files!','File Manager');
        uiwait(ErrDlg);
        error = 1;
    end
end

%writing last unit ID
if ~error
    fprintf(fid,'%s%s%s\n','lastunit = struct(''A'',''',EXPS.lastunit.A,''', ...');
    for i = 2:lastfile -1
        prefix = char(64+i);
        eval(sprintf('%s%c%c','this_lu = EXPS.lastunit.',prefix,';'));
        ucount = fprintf(fid,'\t%c%c%s%s%s\n','''',prefix,''',''',this_lu,''', ...');
        if ~ucount
            ErrDlg = errordlg('EXPLIST: Trouble reading lastunit!','File Manager');
            uiwait(ErrDlg);
            error = 1;
            break
        end
    end
end
if ~error
    prefix = char(64+lastfile);
    eval(sprintf('%s%c%c','this_lu = EXPS.lastunit.',prefix,';'));
    ucount = fprintf(fid,'\t%c%c%s%s%s\n\n','''',prefix,''',''',this_lu,''');');
    if ~ucount
        ErrDlg = errordlg('EXPLIST: Trouble reading lastunit!','File Manager');
        uiwait(ErrDlg);
        error = 1;
    end
end

if ~error
    ccount = fprintf(fid,'%s%c%s%d%s%s%s%s%s%s%s\n\n','currunit = struct(''FilePrefix'',''',EXPS.currunit.FilePrefix,...
        ''',''fnum'',',EXPS.currunit.fnum,...
        ',''unit'',''',num2str(EXPS.currunit.unit),...
        ''',''volts'',',num2str(EXPS.currunit.volts),...
        ',''CurrentDataDir'',''',EXPS.currunit.CurrentDataDir,''');');
    if ~ccount
        ErrDlg = errordlg('EXPLIST: Trouble reading current unit!','File Manager');
        uiwait(ErrDlg);
        error = 1;
    end
end

if ~error
    ecount = fprintf(fid,'%s%s%s%s%s','EXPS = struct(''owners'',owners,',...
        '''dates'',dates,',...
        '''files'',files,',...
        '''lastunit'',lastunit,',...
        '''currunit'',currunit);');
    if ~ecount
        ErrDlg = errordlg('EXPLIST: Trouble building EXPS!','File Manager');
        uiwait(ErrDlg);
        error = 1;
    end
end
fclose(fid);

if ~error
    cur_dir = cd(fm_dir);
    dos('del explist.old');
    dos('ren explist.m explist.old');
    dos('ren temp.m explist.m');
    cd(cur_dir);
end

