% cd(fullfile(strtok(matlabroot,filesep),SaveDirXYZ));
cdd
filterspec = '*.*';
if strcmp(computer,'MAC2'), filterspec = '*'; end
[data_file dat_dir] = uigetfile(filterspec,'Calibration Files');
eval(data_file(1:findstr(data_file,'.m')-1));

if findstr(file_prog,'DPOAErp2'),
   set(h_push_start,'Userdata',file_data);
   h_ax1 = axes('position',[.2 .4 .6 .5]);
   h_line1 = plot(file_data(:,1),file_data(:,2),'-');
   set(h_line1,'Color',[1 1 1],'LineWidth',2,'EraseMode','none');
   axis([file_frqlo file_frqhi file_attlo-5 file_atthi+5]);
   if ~file_fstlin,
      set(h_ax1,'XScale','log');
   end
   
   set(h_ax1,'XTick',[file_frqlo file_frqhi],'FontSize',12);
   set(h_ax1,'YTick',[0:10:120],'FontSize',12);
   set(h_ax1,'YDir','reverse');
   xlabel('Frequency (kHz)','fontsize',18,'fontangle','normal','fontweight','normal');
   ylabel('Attenuation (dB)','fontsize',18,'fontangle','normal','fontweight','normal');
   set(h_ax1,'Color','k');
   
   set(h_text2,'String',{file_prog file_date data_file});
   if file_fstlin,
      step_txt = 'linear';
   else
      step_txt = 'log';
   end
	set(h_text4,'String',{file_frqlo; file_frqhi; step_txt; max(file_fstlin,file_fstoct)});
	set(h_text6,'String',{file_attlo; file_atthi; file_attstp});
   set(h_text7,'String','Inspecting data file...');
else
   txt_str = sprintf('%s %s\n\n%s',data_file,'is not a DPOAE file.','Waiting for input.');
   set(h_text7,'String',txt_str);
end
drawnow;
cd(fullfile(strtok(matlabroot,filesep),'matlab_user','DPOAE','functions'));
