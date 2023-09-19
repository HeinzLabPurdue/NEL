% Adapted from "make_tc_text_file.m" by GE/MH, 02Nov2003.
% ge debug ABR 26Apr2004: need to check boolean RunLevels_params.bMultiOutputFiles 
% and handle appropriately.
% removed multiple output files for FFR use - zz 04nov11
% if ~(RunLevels_params.bMultiOutputFiles)  % added by GE 26Apr2004.

% Edited by SP
% Edited by JMR

function NelData= make_FFR_Se_text_file(misc, Stimuli, PROG, NelData, comment, ...
    RunLevels_params, FFR_Gating, FFRdataAvg_PO, FFRdataAvg_NP, FFRdataStoreNP, ...
    FFRdataStorePO, Display, FFRattens, FFRdataReps, interface_type)

[x, aux_fname, fname]=make_FFR_Se_text_file_subfunc1 ...
    (misc, Stimuli, PROG, NelData, comment, RunLevels_params, FFR_Gating, Display, FFRattens);

% 	FFRdataReps_dec=cell(size(RunLevels_params.attenMask));  % All Reps
for i=1:length(FFRdataAvg_NP)
    if (RunLevels_params.decimateFact~=1)
        FFRdataAvg_NP{i} = decimate(FFRdataAvg_NP{i}, RunLevels_params.decimateFact);
        FFRdataAvg_PO{i} = decimate(FFRdataAvg_PO{i}, RunLevels_params.decimateFact);
        if strcmp(interface_type,'SPIKES')
            FFRdataStoreNP{i} = decimate(FFRdataStoreNP{i}, RunLevels_params.decimateFact);
            FFRdataStorePO{i} = decimate(FFRdataStorePO{i}, RunLevels_params.decimateFact);
        end        
    end
end

save_all_reps=1; % change to 0 to only save averages.

if save_all_reps==1
    x.AD_Data.AD_All_V = FFRdataReps; 
    % _dec removed from end of FFRdataReps % modified by GE 26Apr2004. 
    %  Removed zz 04nov2011. Added DA 7/25/13
end
% 	x.AD_Data.AD_Avg_V = FFRdataAvg;
x.AD_Data.AD_Avg_NP_V = FFRdataAvg_NP;
x.AD_Data.AD_Avg_PO_V = FFRdataAvg_PO;
if strcmp(interface_type,'SPIKES')
    x.AD_Data.AD_StoreNP_V = FFRdataStoreNP;
    x.AD_Data.AD_StorePO_V = FFRdataStorePO;
end

NelData= make_FFR_Se_text_file_subfunc2(fname, x, aux_fname, NelData);