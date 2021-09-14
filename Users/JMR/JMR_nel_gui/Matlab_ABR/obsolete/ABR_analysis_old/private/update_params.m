function update_params;	
global Stimuli root_dir

filename = fullfile(root_dir,'ABR_analysis','private','get_analysis_ins.m');
fid = fopen(filename,'wt+');

fprintf(fid,'%s\n\n','%ABR Analysis Instruction Block');
fprintf(fid,'%s%d%s\n','Stimuli = struct(''cal_pic'',',double(Stimuli.cal_pic),', ...');
fprintf(fid,'\t%s%s%s\n','''abr_pic'',''',Stimuli.abr_pic,''', ...');
fprintf(fid,'\t%s%5.2f%s\n','''start_resp'',',Stimuli.start_resp,', ...');
fprintf(fid,'\t%s%5.2f%s\n','''end_resp'',',Stimuli.end_resp,', ...');
fprintf(fid,'\t%s%5.2f%s\n','''start_back'',',Stimuli.start_back,', ...');
fprintf(fid,'\t%s%5.2f%s\n','''end_back'',',Stimuli.end_back,', ...');
fprintf(fid,'\t%s%s%s\n','''dir'',''',Stimuli.dir,''');');

fclose(fid);
