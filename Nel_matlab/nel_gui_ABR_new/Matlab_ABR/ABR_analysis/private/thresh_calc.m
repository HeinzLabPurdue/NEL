function [error] = thresh_calcglobal abr_FIG abr_Stimuli ABRmag abr_root_dir abr_data_direrror = 0;make_table = 0;for i = 1:10   eval(['set(abr_FIG.abrs.abr' num2str(i) ' ,''Visible'',''off'');']);end%%%%%% MH_GE 27Apr2004% FIGURE OUT which type of data you have% MouseLabMode=1 if data is from MouseLab (i.e., names: EPavg*); =0 if data from NELeval(['MouseLabMode=~isempty(dir(''EPavg*''));'])cur_dir = cd(fullfile(abr_data_dir,abr_Stimuli.dir));%%% Build correct Calib_file_name based on MouseLabModeif MouseLabMode   CalibFile = ['cal_p00' num2str(abr_Stimuli.cal_pic)];   while length(CalibFile) > 8,      CalibFile = strrep(CalibFile,'p0','p');   endelse   CalibFile  = sprintf('p%04d_calib', str2num(abr_Stimuli.cal_pic));endif isempty(dir([CalibFile '*']))   error_report = sprintf('Picture file p%04d*.m not found.', str2num(abr_Stimuli.cal_pic))   xcal = [];   return;endcommand_line = sprintf('%s%s%c','[xcal]=',CalibFile,';');eval(command_line);%parse ABR picture sequence[picnums] = ParseInputPicString(abr_Stimuli.abr_pic);num_files = length(picnums);ABRmag = zeros(num_files,3);max_resp = 0;for file = 1:num_files   index = picnums(file);          %%% MH: 27Apr2004 Build correct file name based on MouseLabMode   if MouseLabMode      EPfile = ['EPavg_p00' num2str(index)];      while length(EPfile) > 10,         EPfile = strrep(EPfile,'p0','p');      end      command_line = sprintf('%s%s%c','[xdat]=',EPfile,';');   else      % MH_GE 29Apr2004: Changed filename to a0001...'m, which is a auxiliary file with only AVG waveforms, p0001....m has all reps      if (~isempty(dir(sprintf('a%04d*.m', index))))         picMFile = dir(sprintf('a%04d*.m', index));         eval( strcat('x = ', picMFile.name(1:length(picMFile.name)-2),';') );      else         error_report = sprintf('Auxiliary Picture file a%04d*.m not found.', index)         x = [];         return;      end      % xdat.AverageData(:,1)=time; (:,4)=volts      xdat.AverageData(:,4)=x.AD_Data.AD_Avg_V';      xdat.AverageData(:,1) =(1:length(xdat.AverageData(:,4)))*1000/(x.Stimuli.RPsamprate_Hz/x.Stimuli.RunLevels_params.decimateFact);      xdat.Stimuli.freq_hz=x.Stimuli.freq_hz;      xdat.General.date=x.General.date;      xdat.Stimuli.db_atten=x.Stimuli.atten_dB;            %%MH_GE: 27Apr2004: rescale - expected that Data is Voltage at electrode (in microVolts)      % Our data is at AD, in Volts      xdat.AverageData(:,4)=xdat.AverageData(:,4)/x.AD_Data.Gain*1e6;      %       disp('NEED TO FIX GAIN!!!')        end      eval(command_line);   if file == 1      set(abr_FIG.ax2.axes,'xlim',[0 max(xdat.AverageData(:,1))]);      freq_check = xdat.Stimuli.freq_hz;      DATE_STR = xdat.General.date;      if freq_check,         freq_loc = find(xcal.CalibData(:,1)>=(freq_check/1000));         freq_lev = xcal.CalibData(freq_loc(1),2);      else         %click calibration on 10/24/00 indicates click is 5.8 dB down from 14.6k tone output	         %freq_lev = interp1(xcal.CalibData(:,1),xcal.CalibData(:,2),14.6) - 5.8;                  %click calibration on 08/21/03 indicates click is 93.25 dB SPL         %at 0 dB attenuation         freq_lev = 93.25;      end   end   if xdat.Stimuli.freq_hz ~= freq_check,      warndlg('Different frequencies in file list.');      return   end      plotx(:,file) =  xdat.AverageData(:,1);   ploty(:,file) =  xdat.AverageData(:,4);   fstrsp = max(find(xdat.AverageData(:,1)<=abr_Stimuli.start_resp));   lstrsp = min(find(xdat.AverageData(:,1)>=abr_Stimuli.end_resp));   fstbck = max(find(xdat.AverageData(:,1)<=abr_Stimuli.start_back));   lstbck = min(find(xdat.AverageData(:,1)>=abr_Stimuli.end_back));   ABRmag(file,1) = freq_lev - xdat.Stimuli.db_atten;   ABRmag(file,2) = max(xdat.AverageData(fstrsp:lstrsp,4)) - min(xdat.AverageData(fstrsp:lstrsp,4));   ABRmag(file,3) = max(xdat.AverageData(fstbck:lstbck,4)) - min(xdat.AverageData(fstbck:lstbck,4));endmax_resp = max(ABRmag(:,2));max_resp = abr_Stimuli.scale;[y,stack] = sort(ABRmag(:,1));for file = 1:num_files   index = stack(file);   offset = max_resp * file - mean(mean(ploty)); %remove DC and shift by max response   xdat = plotx(:,index);   ydat = ploty(:,index) + offset;   eval(['set(abr_FIG.abrs.abr' num2str(file) ',''xdata'',xdat,''ydata'',ydat,''Visible'',''on'');']);endset(abr_FIG.ax2.axes,'XTick',[0:5:100]);set(abr_FIG.ax2.axes,'YLim',[0 max_resp*(num_files+1)],'YTick',[max_resp:max_resp:max_resp*num_files],'YTickLabel',round(y));% right labelling: added by GE 14Apr2004.set(get(abr_FIG.a2.axesR,'YLabel'),'String','Stimulus level (dB atten)', 'FontSize', 18);set(abr_FIG.a2.axesR, 'FontSize', 10);set(abr_FIG.a2.axesR,'YLim',[0 max_resp*(num_files+1)],'YTick',[max_resp:max_resp:max_resp*num_files],'YTickLabel',-1*round(y-freq_lev));hold off;% add a rectangle to indicate response window.% added by GE.  04 March 2004.axes(abr_FIG.ax2.axes);a = axis;% set(abr_FIG.ax2.rect, 'Position', [abr_Stimuli.start_resp a(3) (abr_Stimuli.end_resp-abr_Stimuli.start_resp) a(4)-a(3)]);% shad = 0.85;% set(abr_FIG.ax2.rect, 'EraseMode', 'xor', 'FaceColor', [shad shad 0.7], 'EdgeColor', [shad shad 0.7]);% set(abr_FIG.ax2.rect2, 'Position', [abr_Stimuli.start_back a(3) (abr_Stimuli.end_back-abr_Stimuli.start_back) a(4)-a(3)]);% set(abr_FIG.ax2.rect2, 'EraseMode', 'xor', 'FaceColor', [shad shad shad], 'EdgeColor', [shad shad shad]);thresh_mag = mean(ABRmag(:,3)) + 2*std(ABRmag(:,3));ABRmag(1:num_files,4) = thresh_mag;ABRmag = sortrows(ABRmag,1);yes_thresh = 0;for index = 1:num_files-1,   if (ABRmag(index,2) <= thresh_mag) & (ABRmag(index+1,2) >= thresh_mag), %find points that bracket 50% hit rate      pts = index;      yes_thresh = 1;   endend%calculate thresholdif yes_thresh,   hi_loc  = ABRmag(pts,  1);   lo_loc  = ABRmag(pts+1,1);   hi_resp = ABRmag(pts,  2);   lo_resp = ABRmag(pts+1,2);   slope  = (thresh_mag - lo_resp) / (hi_resp - lo_resp);   thresh_lev = slope * (hi_loc - lo_loc) + lo_loc;else   thresh_lev = NaN;end%plot mag functionsset(abr_FIG.ax1.axes,'ylim',[0 abr_Stimuli.scale]);set(abr_FIG.ax1.line1,'xdata',ABRmag(:,1),'ydata',ABRmag(:,2),'Visible','on');set(abr_FIG.ax1.line2,'xdata',ABRmag(:,1),'ydata',ABRmag(:,3),'Visible','on');set(abr_FIG.ax1.line3,'xdata',ABRmag(:,1),'ydata',ABRmag(:,4),'Visible','on');if freq_check,   txt_str = sprintf('%s %s%c %s\n%s %4.1f %s %c%4.1f %s','Files',abr_Stimuli.abr_pic,',',DATE_STR,...      'Threshold is',thresh_lev,'dB SPL','(',freq_check/1000,'kHz)');else   txt_str = sprintf('%s %s%c %s\n%s %4.1f %s %s','Files',abr_Stimuli.abr_pic,',',DATE_STR, ...      'Threshold is',thresh_lev,'dB SPL','(Clicks)');endset(abr_FIG.ax1.title,'string',txt_str);set(abr_FIG.ax1.xlab,'string','Stimulus level (dB SPL)');drawnow;if make_table,   fid = fopen('temp.m','wt+');   fprintf(fid,'%s %s %s %s\n','atten','abr','back','crit');   for i = 1:num_files,      fprintf(fid,'%d %6.3f %6.3f %6.3f\n',ABRmag(i,:));   end   fclose(fid);end% end GetAllPics subfunction%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~function [picnums] = ParseInputPicString(picst)% Takes the input number string (eg, '5-7,9') and turns it into an array% of picture numbers, picnums=[5,6,7,9]c='0';i=0;j=1;numpics=1;dashflag=0;while i<length(picst)   while c~='-' & c~=',' & i+j~=length(picst)+1      b(j)=picst(i+j);      c=b(j);      j=j+1;   end   if c=='-' | c==','      b=b(1:end-1);   end   if dashflag==1      try         upto=str2num(b);      catch         error('Can''t parse picture numbers.');      end      numdash=upto-picnums(numpics-1);      for k=1:numdash         picnums(k+numpics-1)=picnums(numpics-1)+k;      end      numpics=length(picnums);   else  % if dashflag==1      try         picnums(numpics)=str2num(b);      catch         error('Can''t parse picture numbers!\n');      end   end   clear b;   i=i+j-1;   j=1;   if c=='-'      dashflag=1;   else      dashflag=0;   end   c='0';   numpics=numpics+1;end  % while i<length(picst)