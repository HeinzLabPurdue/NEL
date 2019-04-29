function neltext2mat(fname)
%

% AF 4/18/02

[path,name,ext,ver] = fileparts(fname);

if (strcmp(ext,'.m')~= 1)
   return;
end
if (exist('mac') ~= 7)
   mkdir('mac');
end

x = eval(name);
save(['mac' filesep name], 'x');
fid = fopen(['mac' filesep name '.m'],'w');
if (fid < 0)
   error(['can''t open file ' name]);
end

fprintf(fid,'function x = %s\n', name);
fprintf(fid,'x = load(mfilename);\n');
fprintf(fid,'x = x.x;\n');
fclose(fid);
