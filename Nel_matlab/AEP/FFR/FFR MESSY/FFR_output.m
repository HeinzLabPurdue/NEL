clear all; close all; clc; warning off;

%--------------------------------------------------------------------------
% Matrix for storing envelopes at different frequencies, hearing loss, and
%  noise levels
% Consider commenting if unused
HI_1 = {};
HI_1l = [0 0 0 0];
NH_1 = {};
NH_1l = [0 0 0 0];

HI_2 = {};
HI_2l = [0 0 0 0];
NH_2 = {};
NH_2l = [0 0 0 0];

HI_4 = {};
HI_4l = [0 0 0 0];
NH_4 = {};
NH_4l = [0 0 0 0];

HI_8 = {};
HI_8l = [0 0 0 0];
NH_8 = {};
NH_8l = [0 0 0 0];
%--------------------------------------------------------------------------

base_dir = pwd;
dir1 = dir;

out = fopen('output.txt','w');
fprintf(out,'Animal\tFreq\tNSR\tGroup\tfftENV\tfftENVp1\tfftTFS\tfftTFScf\tfftTFSsb\n');
for j = 1:length(dir1)
    if (dir1(j).isdir && length(dir1(j).name) > 2)

        curdir = strcat(base_dir,'\',dir1(j).name);
        i = strfind(curdir,'\');
        i = i(length(i));
        
        animal = curdir(i+15:i+22);
        grp = curdir(i+24:i+25);
        month = str2num(curdir(i+9:i+10));
        day = str2num(curdir(i+12:i+13));
        
        fprintf('%s %s\n', animal,grp);     % tracking progress
        
        isOLD = (month < 4 || (month == 4 && day < 20));    %incorrectly collected data
        
        dir_str = dir(curdir);

        for i = 1:length(dir_str)
            n = dir_str(i).name;
            if  length(n) > 9 && strncmp('p00_FFR',strcat(n(1:3),n(6:9)),7)

                scpt = strcat(curdir,'\', n(1:(length(n)-2)),'.m');
                run (scpt);
                x = ans;
                fc = x.Stimuli.fc;
                fm = x.Stimuli.fm;
                
                % PLOT vs NO PLOT
%                 [AD_Data env_amp tfs_amp fm_sum fc_sum fm_p1 fc_p1 fc_sb noise_lvl] = ffr_analysis(x,isOLD);                
                [AD_Data env_amp tfs_amp fm_sum fc_sum fm_p1 fc_p1 fc_sb noise_lvl] = ffr_analysis_noplot(x,isOLD); 
%                 pause;
                
%--------------------------------------------------------------------------
                % SWITCH is for sorting and storing envelope averages for 
                %  plotting at different frequencies, noise levels, and
                %  whether the hearing loss is present or not
                
                % CONSIDER commenting if 'plot_after_running_output.m'
                %  will not be run to improve performance
                switch(fc)
                    case(1000)
                        if isnan(noise_lvl)
                            i_n = 1;
                        else
                            i_n = noise_lvl/5 + 2;
                        end

                        if strcmp(grp,'NH')
                            NH_1l(i_n) = NH_1l(i_n) + 1;
                            NH_1{i_n,NH_1l(i_n)} = AD_Data;
                        else
                            HI_1l(i_n) = HI_1l(i_n) + 1;
                            HI_1{i_n,HI_1l(i_n)} = AD_Data;
                        end
                    case(2000)
                        if isnan(noise_lvl)
                            i_n = 1;
                        else
                            i_n = noise_lvl/5 + 3;
                        end
                        if i_n < 1
                            i_n = 10;
                        end
                        if i_n < 5 && strcmp(grp,'NH')
                            NH_2l(i_n) = NH_2l(i_n) + 1;
                            NH_2{i_n,NH_2l(i_n)} = AD_Data;
                        elseif i_n < 5
                            HI_2l(i_n) = HI_2l(i_n) + 1;
                            HI_2{i_n,HI_2l(i_n)} = AD_Data;
                        end
                    case(4000)
                        if isnan(noise_lvl)
                            i_n = 1;
                        else
                            i_n = noise_lvl/5 + 4;
                        end
                        if i_n < 1
                            i_n = 10;
                        end
                        if i_n < 5 && strcmp(grp,'NH')
                            NH_4l(i_n) = NH_4l(i_n) + 1;
                            NH_4{i_n,NH_4l(i_n)} = AD_Data;
                        elseif i_n < 5
                            HI_4l(i_n) = HI_4l(i_n) + 1;
                            HI_4{i_n,HI_4l(i_n)} = AD_Data;
                        end
                    case(8000)
                        if isnan(noise_lvl)
                            i_n = 1;
                        else
                            i_n = noise_lvl/5 + 4;
                        end
                        if i_n < 1
                            i_n = 10;
                        end
                        if i_n < 5 && strcmp(grp,'NH')
                            NH_8l(i_n) = NH_8l(i_n) + 1;
                            NH_8{i_n,NH_8l(i_n)} = AD_Data;
                        elseif i_n < 5
                            HI_8l(i_n) = HI_8l(i_n) + 1;
                            HI_8{i_n,HI_8l(i_n)} = AD_Data;
                        end
                end
%--------------------------------------------------------------------------
                                

                % IF Normalized output is desired, uncomment
                % HEADER also needs to be fixed if uncommented
%                 if isnan(noise_lvl)
%                     org = 1;
%                     org_env_amp = env_amp;
%                     org_tfs_amp = tfs_amp;
%                     org_fm_sum = fm_sum;
%                     org_fc_sum = fc_sum;
%                     org_fm_p1 = fm_p1;
%                 end
%                 fprintf(out,'%s\t%d\t%d\t%s\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\n',...
%                     animal,fc,noise_lvl,grp,...
%                     env_amp,            tfs_amp,            fm_sum,           fc_sum,           fm_p1, fc_p1, fc_sb,...
%                     env_amp/org_env_amp,tfs_amp/org_tfs_amp,fm_sum/org_fm_sum,fc_sum/org_fc_sum,fm_p1/org_fm_p1);

                fprintf(out,'%s\t%d\t%d\t%s\t%f\t%f\t%f\t%f\t%f\n',...
                    animal,fc,noise_lvl,grp,...
                    fm_sum, fm_p1, fc_sum, fc_p1, fc_sb);
            end
        end
    end
end
fclose('all');