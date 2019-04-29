randn('state',0);
x = randn(500000,1);
dir = 'c:\matlab_user\srcal_232\functions\';
error = 0;
fid = fopen([dir 'noise.TXT'],'wt+');
fprintf(fid,'%10.7f\n',x);
fclose(fid)