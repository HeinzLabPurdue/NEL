% make_CAP_text_file_subfunc2.m

rc = write_nel_data(fname,x,0);   
save(fname,'x') %save mat-file along side picture file JMR Sept 21
while (rc < 0)
	title_str = ['Choose a different file name! Can''t write to ''' fname ''''];
	[fname dirname] = uiputfile([fileparts(fname) filesep '*.m'],title_str);
	rc = write_nel_data(fullfile(dirname,fname),x,0);
end

% aux_x=x;
% aux_x.AD_Data=rmfield(aux_x.AD_Data,'AD_All_V');
% rc = write_nel_data(aux_fname,aux_x,0);
% while (rc < 0)
% 	title_str = ['Choose a different file name! Can''t write to ''' aux_fname ''''];
% 	[aux_fname dirname] = uiputfile([fileparts(aux_fname) filesep '*.m'],title_str);
% 	rc = write_nel_data(fullfile(dirname,aux_fname),aux_x,0);
% end

% NelData.File_Manager.picture = NelData.File_Manager.picture+1; % SP Changed 22 March 2016


