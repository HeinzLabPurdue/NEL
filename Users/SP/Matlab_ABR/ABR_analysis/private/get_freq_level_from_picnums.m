function get_freq_level_from_picnums()

global abr_data_dir abr_Stimuli han abr_FIG

ExpDir=fullfile(abr_data_dir,abr_Stimuli.dir);
cd(ExpDir);

hhh=dir('*ABR*');
ABRpics=zeros(1,length(hhh));
ABRfreqs=zeros(1,length(hhh));

for i=1:length(hhh)
    ABRpics(i)=str2double(hhh(i).name(2:5));
    ABRfreqs(i)=str2double(hhh(i).name(11:14));
end

if strcmp(get(han.abr_panel,'Box'),'on') & max(ParseInputPicString_V2(abr_Stimuli.abr_pic))>= min(ABRpics)
    firstPic=max(ParseInputPicString_V2(abr_Stimuli.abr_pic))+1;
else
    firstPic=min(ABRpics);
end

pic_nums=intersect(ABRpics,ParseInputPicString_V2(abr_Stimuli.abr_pic));
cur_freq=unique(ABRfreqs(pic_nums-min(ABRpics)+1));

if length(cur_freq)==1
    % All pics from same frequency. Update ABR Files all, ABR Files Calc,
    % dB Above thresh!
    picnums_all_for_cur_freq=ABRpics(ABRfreqs==cur_freq);
    new_value_for_abr_files=[num2str(min(pic_nums)) '-' num2str(max(pic_nums))];
    new_value_for_abr_files_all=[num2str(min(picnums_all_for_cur_freq)) '-' num2str(max(picnums_all_for_cur_freq))];
    
    set(abr_FIG.parm_txt(2),'string',upper(new_value_for_abr_files));
    set(abr_FIG.parm_txt(8),'string',upper(new_value_for_abr_files_all));
    
    abr_Stimuli.abr_pic = new_value_for_abr_files;
    abr_Stimuli.abr_pic_all= new_value_for_abr_files_all;
    
else
    % No point in doing any analysis. Please re-enter the pic vals for calc
    error(['The files selected correspond to different frequencies.' ...
    'No point in doing that analysis. So, please select files of same frequency.');
end


