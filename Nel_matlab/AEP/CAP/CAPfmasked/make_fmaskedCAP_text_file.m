% make_CAP_text_file.m
% Adapted from "make_tc_text_file.m" by GE/MH, 02Nov2003.

% ge debug ABR 26Apr2004: need to check boolean RunLevels_params.bMultiOutputFiles and handle appropriately.

%if ~(RunLevels_params.bMultiOutputFiles)  %only mode available

make_fmaskedCAP_text_file_subfunc1;

x.Line.atten_dB = CAPattens; % cell array(3)
x.Line.masker_atten_dB = Line_masker_atten_dB;
x.Line.clickAmp= clickAmp;
x.Line.maskerAmp= maskerAmp;

if (RunLevels_params.decimateFact~=1)
    CAPdataAvg_dec = decimate(CAPdataAvg, RunLevels_params.decimateFact);
    CAPdataReps_dec = zeros(2*RunLevels_params.nPairs, length(CAPdataAvg_dec) );
    % MH 18Nov2003: Add code to save all Reps
    for j=1:2*RunLevels_params.nPairs
        CAPdataReps_dec(j, :) = decimate(CAPdataReps(j, :), RunLevels_params.decimateFact);
    end
else
    CAPdataAvg_dec= CAPdataAvg;
    CAPdataReps_dec = CAPdataReps;
end

if (RunLevels_params.saveRepsYes==1)
    x.AD_Data.AD_All_V = CAPdataReps_dec; % modified by GE 26Apr2004.
end

x.AD_Data.AD_Avg_V = CAPdataAvg_dec;

make_fmaskedCAP_text_file_subfunc2;
	