function UpdateVolts(volts)

global root_dir

temp = fullfile(root_dir,'general','temp.m');
cv   = fullfile(root_dir,'general','CurrV.m');
bu   = fullfile(root_dir,'general','CurrV.old');
fid = fopen(temp,'wt+');

if fid
    fprintf(fid,'%s\n\n','%CurrV holds current amp setting for behavioral programs');
    
    fprintf(fid,'%s%c\n',volts,';');
    
    fclose(fid);
    
    if exist(cv)
        copyfile(cv,bu,'f');
    end
    copyfile(temp,cv,'f');
end
