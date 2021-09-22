% Adapted from "make_tc_text_file.m" by GE/MH, 02Nov2003.
% ge debug ABR 26Apr2004: need to check boolean RunLevels_params.bMultiOutputFiles 
% and handle appropriately.
% removed multiple output files for FFR use - zz 04nov11
% if ~(RunLevels_params.bMultiOutputFiles)  % added by GE 26Apr2004.

% Edited by SP
% Edited by JMR

function NelData= make_FFR_Se_text_file_2chan(misc, Stimuli, PROG, NelData, comment, ...
    RunLevels_params, FFR_Gating,...
    FFRdataAvg_PO1,FFRdataAvg_PO2,...
    FFRdataAvg_NP1,FFRdataAvg_NP2,...
    FFRdataStoreNP1,FFRdataStoreNP2, ...
    FFRdataStorePO1,FFRdataStorePO2,...
    Display, FFRattens, FFRdataReps1,FFRdataReps2, interface_type)

[x, aux_fname, fname]=make_FFR_Se_text_file_subfunc1 ...
    (misc, Stimuli, PROG, NelData, comment, RunLevels_params, FFR_Gating, Display, FFRattens);

% 	FFRdataReps_dec=cell(size(RunLevels_params.attenMask));  % All Reps
% chan 1
for i=1:length(FFRdataAvg_NP1)
    if (RunLevels_params.decimateFact~=1)
        FFRdataAvg_NP1{i} = decimate(FFRdataAvg_NP1{i}, RunLevels_params.decimateFact);
        FFRdataAvg_PO1{i} = decimate(FFRdataAvg_PO1{i}, RunLevels_params.decimateFact);
        if strcmp(interface_type,'SPIKES')
            FFRdataStoreNP1{i} = decimate(FFRdataStoreNP1{i}, RunLevels_params.decimateFact);
            FFRdataStorePO1{i} = decimate(FFRdataStorePO1{i}, RunLevels_params.decimateFact);
        end        
    end
end
% chan 2
for i=1:length(FFRdataAvg_NP2)
    if (RunLevels_params.decimateFact~=1)
        FFRdataAvg_NP2{i} = decimate(FFRdataAvg_NP2{i}, RunLevels_params.decimateFact);
        FFRdataAvg_PO2{i} = decimate(FFRdataAvg_PO2{i}, RunLevels_params.decimateFact);
        if strcmp(interface_type,'SPIKES')
            FFRdataStoreNP2{i} = decimate(FFRdataStoreNP2{i}, RunLevels_params.decimateFact);
            FFRdataStorePO2{i} = decimate(FFRdataStorePO2{i}, RunLevels_params.decimateFact);
        end        
    end
end

save_all_reps=1; % change to 0 to only save averages.

if save_all_reps==1
    x.AD_Data.AD_All_V_chan1 = FFRdataReps1; 
    x.AD_Data.AD_All_V_chan2 = FFRdataReps2;     
    % _dec removed from end of FFRdataReps % modified by GE 26Apr2004. 
    %  Removed zz 04nov2011. Added DA 7/25/13
end
% 	x.AD_Data.AD_Avg_V = FFRdataAvg;
x.AD_Data.AD_Avg_NP_V_chan1 = FFRdataAvg_NP1;
x.AD_Data.AD_Avg_PO_V_chan1 = FFRdataAvg_PO1;
x.AD_Data.AD_Avg_NP_V_chan2 = FFRdataAvg_NP2;
x.AD_Data.AD_Avg_PO_V_chan2 = FFRdataAvg_PO2;


NelData= make_FFR_Se_text_file_subfunc2_2chan(fname, x, aux_fname, NelData);