function thresh=main_abr_bb(dataDIR,CalibPIC,PIClist)

global abr_Stimuli

abr_Stimuli.start=4;
abr_Stimuli.end=20;
abr_Stimuli.start_template=6.2;
abr_Stimuli.end_template=14;
abr_Stimuli.num_templates=2;

cur_dir=pwd;
addpath([cur_dir filesep 'Matlab_ABR' filesep 'ABR_analysis']);
thresh=abr_analysis_blackbox(dataDIR,CalibPIC,PIClist);

