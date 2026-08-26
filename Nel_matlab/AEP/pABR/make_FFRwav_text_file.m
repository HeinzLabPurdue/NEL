% Adapted from "make_tc_text_file.m" by GE/MH, 02Nov2003.
% ge debug ABR 26Apr2004: need to check boolean RunLevels_params.bMultiOutputFiles 
% and handle appropriately.
% removed multiple output files for FFR use - zz 04nov11
% if ~(RunLevels_params.bMultiOutputFiles)  % added by GE 26Apr2004.

% Edited by SP
% Edited by JMR

function NelData= make_FFRwav_text_file(misc, Stimuli, invfiltdata, PROG, NelData, comment, ...
    RunLevels_params, FFR_Gating,...
    rightResp, leftResp,...
    Display, pABRattens, pABRinterstim, pABR_EpochResp1, pABR_EpochResp2,pABRstim)

[x, aux_fname, fname]=make_FFRwav_text_file_subfunc1 ...
    (misc, pABRstim, invfiltdata, PROG, NelData, comment, RunLevels_params, FFR_Gating, Display,pABRattens,pABRinterstim,Stimuli );

% 	FFRdataReps_dec=cell(size(RunLevels_params.attenMask));  % All Reps
% chan 1
for i=1:length( rightResp)
    if (RunLevels_params.decimateFact~=1)
         rightResp{i} = decimate( rightResp{i}, RunLevels_params.decimateFact);
     
    end
end
% chan 2
for i=1:length(leftResp)
    if (RunLevels_params.decimateFact~=1)
         leftResp{i} = decimate( leftResp{i}, RunLevels_params.decimateFact);
     
    end
end

save_all_reps=1; % change to 0 to only save averages.


if save_all_reps==1
    if Stimuli.rec_channel > 2
        x.AD_Data.Label{1} = 'Channel 1';
        x.AD_Data.Label{2} = 'Channel 2';
        x.AD_Data.AD_All_V{1} =  pABR_EpochResp1;
        x.AD_Data.AD_All_V{2} =  pABR_EpochResp2;
    elseif Stimuli.rec_channel == 2
        x.AD_Data.Label{1} = ['Channel ' num2str(Stimuli.rec_channel)];
        x.AD_Data.AD_All_V{1} = pABR_EpochResp2;
    else % Ch 1 ONLY 
        x.AD_Data.Label{1} = ['Channel ' num2str(Stimuli.rec_channel)];
        x.AD_Data.AD_All_V{1} = pABR_EpochResp1; 
    end
end

if Stimuli.rec_channel > 2

    % Both channels
    x.AD_Data.Label{1} = 'Channel 1';
    x.AD_Data.Label{2} = 'Channel 2';

    x.AD_Data.AD_Avg_500Hz_V{1}  = rightResp(1,:);
    x.AD_Data.AD_Avg_1000Hz_V{1} = rightResp(2,:);
    x.AD_Data.AD_Avg_2000Hz_V{1} = rightResp(3,:);
    x.AD_Data.AD_Avg_4000Hz_V{1} = rightResp(4,:);
    x.AD_Data.AD_Avg_8000Hz_V{1} = rightResp(5,:);

    x.AD_Data.AD_Avg_500Hz_V{2}  = leftResp(1,:);
    x.AD_Data.AD_Avg_1000Hz_V{2} = leftResp(2,:);
    x.AD_Data.AD_Avg_2000Hz_V{2} = leftResp(3,:);
    x.AD_Data.AD_Avg_4000Hz_V{2} = leftResp(4,:);
    x.AD_Data.AD_Avg_8000Hz_V{2} = leftResp(5,:);

elseif Stimuli.rec_channel == 2

    % Left channel only
    x.AD_Data.Label{1} = 'Channel 2';

    x.AD_Data.AD_Avg_500Hz_V{1}  = leftResp(1,:);
    x.AD_Data.AD_Avg_1000Hz_V{1} = leftResp(2,:);
    x.AD_Data.AD_Avg_2000Hz_V{1} = leftResp(3,:);
    x.AD_Data.AD_Avg_4000Hz_V{1} = leftResp(4,:);
    x.AD_Data.AD_Avg_8000Hz_V{1} = leftResp(5,:);

else

    % Right channel only
    x.AD_Data.Label{1} = 'Channel 1';

    x.AD_Data.AD_Avg_500Hz_V{1}  = rightResp(1,:);
    x.AD_Data.AD_Avg_1000Hz_V{1} = rightResp(2,:);
    x.AD_Data.AD_Avg_2000Hz_V{1} = rightResp(3,:);
    x.AD_Data.AD_Avg_4000Hz_V{1} = rightResp(4,:);
    x.AD_Data.AD_Avg_8000Hz_V{1} = rightResp(5,:);

end

NelData= make_FFRwav_text_file_subfunc2(fname, x, aux_fname, NelData);