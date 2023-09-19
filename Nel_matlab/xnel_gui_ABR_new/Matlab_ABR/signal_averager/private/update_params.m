function update_params;	
global Stimuli root_dir					

fid = fopen(fullfile(root_dir,'signal_averager','private','get_averaging_ins.m'),'wt');

fprintf(fid,'%s\n\n','%Signal Averager Instruction Block');
fprintf(fid,'%s%6.3f%s\n','Stimuli = struct(''freq_hz'',',Stimuli.freq_hz,', ...');
fprintf(fid,'\t%s%6.3f%s\n'  ,'''play_duration'', ',Stimuli.play_duration,', ...');
fprintf(fid,'\t%s%6.3f%s\n'  ,'''record_duration'',',Stimuli.record_duration,', ...');
fprintf(fid,'\t%s%6.3f%s\n'  ,'''SampRate'',',Stimuli.SampRate,', ...');
fprintf(fid,'\t%s%6.3f%s\n'  ,'''pulses_per_sec'',  ',Stimuli.pulses_per_sec,', ...');
fprintf(fid,'\t%s%6.3f%s\n'  ,'''rise_fall'',  ',Stimuli.rise_fall,', ...');
fprintf(fid,'\t%s%6.3f%s\n'  ,'''naves'', ',Stimuli.naves,', ...');
fprintf(fid,'\t%s%6.3f%s\n'  ,'''db_atten'', ',Stimuli.db_atten,', ...');
fprintf(fid,'\t%s%6.3f%s\n'  ,'''amp_gain'',  ',Stimuli.amp_gain,');');

fclose(fid);

signal_averager('return');
