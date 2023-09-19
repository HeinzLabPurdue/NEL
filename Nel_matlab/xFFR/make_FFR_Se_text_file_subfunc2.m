% Edited by SP

function NelData= make_FFR_Se_text_file_subfunc2(fname, x, aux_fname, NelData)

rc = write_nel_matdata(fname,x,0);
while (rc < 0)
	title_str = ['Choose a different file name! Can''t write to ''' fname ''''];
	[fname, dirname] = uiputfile([fileparts(fname) filesep '*.m'],title_str);
	rc = write_nel_matdata(fullfile(dirname,fname),x,0); % Updated by SP
end

% ADDED DA 7/25/13
% REMOVED as there is no longer storing of all data zz 04nov2011
aux_x=x;
aux_x.AD_Data=rmfield(aux_x.AD_Data,'AD_All_V');
rc = write_nel_matdata(aux_fname,aux_x,0);

while (rc < 0)
	title_str = ['Choose a different file name! Can''t write to ''' aux_fname ''''];
	[aux_fname, dirname] = uiputfile([fileparts(aux_fname) filesep '*.m'],title_str);
	rc = write_nel_matdata(fullfile(dirname,aux_fname),aux_x,0);
end

NelData.File_Manager.picture = NelData.File_Manager.picture+1;