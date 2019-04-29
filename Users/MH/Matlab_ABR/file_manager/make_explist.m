function update_explist

%make_explist builds structure for file manager

global NelData root_dir

fm_dir = cd([root_dir 'file_manager']);
fid = fopen([fm_dir filesep 'temp.m'],'wt+');

if fid
    fprintf(fid,'%s\n\n','%EXPLIST builds structure for file manager');
    
    fprintf(fid,'%s%s%s\n','general = struct(''User'',''',[NelData.General.User],''', ...');
    fprintf(fid,'\t%s%s%s\n','''CurDataDir'',''',[NelData.General.CurDataDir],''', ...');
    fprintf(fid,'\t%s%3d%s\n','''fnum'',',[NelData.General.fnum],', ...');
    fprintf(fid,'\t%s%5.2f%s\n\n','''Volts'',',[NelData.General.Volts],');');
    
    fprintf(fid,'%s','NelData = struct(''General'',general);');
    
    fclose(fid);
    
    if exist('explist.old'), delete('explist.old'); end
    if exist('explist.m'), dos('ren explist.m explist.old'); end
    dos('ren temp.m explist.m');
end

