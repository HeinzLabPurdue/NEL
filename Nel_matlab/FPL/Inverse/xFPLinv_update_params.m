function FPLinv_update_params(Stimuli)					%function to rewrite parameter file
							
clear get_sr530_ins;
%parameter files are stored under the subject's name in the subjects directory
file_name = ['get_sr530_ins.m'];

fid = fopen(file_name,'wt');					%open file ID as as a writeable text file (text files are easy to read and portable)

fprintf(fid,'%s\n\n','%SR530 Lock-In Amplifier Instruction Block');		%the following print statements convert parameters to lines of text in parameter file

fprintf(fid,'%s%6.3f%s\n','Stimuli = struct(''frqlo'',',Stimuli.frqlo,', ...');
fprintf(fid,'\t%s%6.3f%s\n'  ,'''frqhi'', ',Stimuli.frqhi,', ...');
fprintf(fid,'\t%s%6.3f%s\n'  ,'''fstlin'',',Stimuli.fstlin,', ...');
fprintf(fid,'\t%s%6.3f%s\n'  ,'''fstoct'',',Stimuli.fstoct,', ...');
fprintf(fid,'\t%s%6.3f%s\n'  ,'''bplo'',  ',Stimuli.bplo,', ...');
fprintf(fid,'\t%s%6.3f%s\n'  ,'''bphi'',  ',Stimuli.bphi,', ...');
fprintf(fid,'\t%s%6.3f%s\n'  ,'''n60lo'', ',Stimuli.n60lo,', ...');
fprintf(fid,'\t%s%6.3f%s\n'  ,'''n60hi'', ',Stimuli.n60hi,', ...');
fprintf(fid,'\t%s%6.3f%s\n'  ,'''n120lo'',',Stimuli.n120lo,', ...');
fprintf(fid,'\t%s%6.3f%s\n'  ,'''n120hi'',',Stimuli.n120hi,', ...');
fprintf(fid,'\t%s%6.3f%s\n'  ,'''ear'',   ',Stimuli.chan,', ...');
fprintf(fid,'\t%s%6.3f%s\n'  ,'''syslv'', ',Stimuli.syslv,', ...');
fprintf(fid,'\t%s%6.3f%s\n'  ,'''lvslp'', ',Stimuli.lvslp,', ...');
fprintf(fid,'\t%s%6.3f%s\n'  ,'''frqcnr'',',Stimuli.frqcnr,', ...');
fprintf(fid,'\t%s%6.3f%s\n'  ,'''cal'',   ',Stimuli.cal,', ...');
fprintf(fid,'\t%s%s%s\n'     ,'''nmic'',   ''',Stimuli.nmic,''', ...');
fprintf(fid,'\t%s%6.3f%s\n'  ,'''crit'',  ',Stimuli.crit,');');

fclose(fid);	%close the file and return to parameter change function

FPLinv('return from parameter change');
