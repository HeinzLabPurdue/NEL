function UpdateExplist(fnum)

%make_explist builds structure for file manager

global NelData root_dir data_dir

if nargin == 0
    d = dir(fullfile(data_dir,NelData.General.CurDataDir));
    fnum = length(d(find([d.isdir]==0)));
end

exp = fullfile(root_dir,'file_manager','explist.m');
bu = fullfile(root_dir,'file_manager','explist.old');
temp = fullfile(root_dir,'file_manager','temp.m');

fid = fopen(temp,'wt+');
if fid
    fprintf(fid,'%s\n\n','%EXPLIST builds structure for file manager');
    
    fprintf(fid,'%s%s%s\n','general = struct(''User'',''',[NelData.General.User],''', ...');
    fprintf(fid,'\t%s%s%s\n','''CurDataDir'',''',[NelData.General.CurDataDir],''', ...');
    fprintf(fid,'\t%s%3d%s\n','''fnum'',',fnum,', ...');
    fprintf(fid,'\t%s%5.2f%s\n\n','''Volts'',',[NelData.General.Volts],');');
    
    fprintf(fid,'%s','NelData = struct(''General'',general);');
    
    fclose(fid);
    
    if exist(exp),
        copyfile(exp,bu,'f');
    end
    copyfile(temp,exp,'f');
end
