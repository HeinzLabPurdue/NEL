function thresh_to_return=abr_analysis_blackbox(dataDIR,CalibPIC,PIClist)

global abr_Stimuli abr_root_dir abr_data_dir  data han %num dt line_width abr freq attn spl upper_y_bound lower_y_bound y_shift %animal

User_Dir=pwd;

abr_root_dir = [User_Dir filesep 'Matlab_ABR' filesep 'ABR_analysis'];
abr_data_dir = [fileparts(fileparts(User_Dir)) filesep 'ExpData'];


get_noise

abr_Stimuli.dir =dataDIR;%get_directory; %PASS
han.abr_panel=0;


abr_Stimuli.cal_pic= CalibPIC;%input('Enter the calibration file Number: ','s'); %PASS
abr_Stimuli.abr_pic=PIClist;%input('Enter the ABR file Numbers: ','s'); %PASS


ExpDir=dataDIR;%fullfile(abr_data_dir,abr_Stimuli.dir); 
cd(ExpDir);
% hhh=dir('*ABR*');
% ABRpics=zeros(length(hhh),1);
% ABRfreqs=zeros(length(hhh),1);

% for i=1:length(hhh)
%     ABRpics(i)=str2double(hhh(i).name(2:5));
%     ABRfreqs(i)=str2double(hhh(i).name(11:14));
% end

% if han.abr_panel
%     firstPic=max(ParseInputPicString_V2(abr_Stimuli.abr_pic))+1;
% else
%     firstPic=min(ABRpics);
% end

% if firstPic <= max(ABRpics)
%     freqTarget=ABRfreqs(ABRpics==firstPic);
%     picNow=firstPic;
%     
%     while ABRfreqs(ABRpics==picNow)==freqTarget & picNow <= max(ABRpics)
%         lastPic=picNow;
%         picNow=picNow+1;
%     end
%     new_value=[num2str(firstPic) '-' num2str(lastPic)];
% else
%     new_value=abr_Stimuli.abr_pic;
% end


% abr_Stimuli.abr_pic = new_value;

% if ~han.abr_panel
%     currentDirectory=cd;
%     has_chin = [strfind(currentDirectory,'chin') strfind(currentDirectory,'Chin')];
%     if ~isempty(has_chin)
%         suggestedID={currentDirectory(has_chin+(4:7))};
%     else
%         suggestedID={''};
%     end
%     animal = inputdlg('Animal ID number:','',1,suggestedID);
% end;

zzz;
thresh_to_return=data.threshold;
cd (User_Dir);