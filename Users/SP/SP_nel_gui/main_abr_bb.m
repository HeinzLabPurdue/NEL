function thresh=main_abr_bb(dataDIR,CalibPIC,PIClist)

global abr_Stimuli

cur_dir=pwd;
cdd
if contains(getFileName(CalibPIC), 'inv')
    coef_file= load(sprintf('coef_%04d_calib.mat', CalibPIC-1));
    invFIRdelay= mean(grpdelay(coef_file.b, 1, 2^12))/48e3*1e3;
else
    invFIRdelay= 0;
end
cd(cur_dir)

abr_Stimuli.start=4 + invFIRdelay;
abr_Stimuli.endval=20 + invFIRdelay;
abr_Stimuli.start_template=6.2 + invFIRdelay;
abr_Stimuli.end_template=14 + invFIRdelay;
abr_Stimuli.num_templates=2;

cur_dir=pwd;
addpath([cur_dir filesep 'Matlab_ABR' filesep 'ABR_analysis']);
thresh=abr_analysis_blackbox(dataDIR,CalibPIC,PIClist);