function NelData = make_pABR_BIC_text_file( ...
    misc,Stimuli,invfiltdata,PROG,NelData,comment, ...
    RunLevels_params,FFR_Gating,rightResp,Display, ...
    pABRattens,pABRinterstim,pABR_EpochResp1,pABRstim)

[x,aux_fname,fname] = make_Bic_text_file_subfunc1( ...
    misc,pABRstim,invfiltdata,PROG,NelData,comment, ...
    RunLevels_params,FFR_Gating,Display,pABRattens, ...
    pABRinterstim,Stimuli.BIC_condition);

for ff = 1:length(rightResp)
    if RunLevels_params.decimateFact ~= 1
        rightResp{ff} = decimate( ...
            rightResp{ff}, ...
            RunLevels_params.decimateFact);
    end
end

x.Stimuli.BIC_condition = Stimuli.BIC_condition;
x.Stimuli.channel = Stimuli.channel;
x.Stimuli.channel2 = Stimuli.channel2;
x.Stimuli.rec_channel = 1;

x.AD_Data.RecordingChannel = 1;
x.AD_Data.Label{1} = Stimuli.BIC_condition;

x.AD_Data.AD_All_V{1} = pABR_EpochResp1;

x.AD_Data.AD_Avg_500Hz_V{1}  = rightResp{1};
x.AD_Data.AD_Avg_1000Hz_V{1} = rightResp{2};
x.AD_Data.AD_Avg_2000Hz_V{1} = rightResp{3};
x.AD_Data.AD_Avg_4000Hz_V{1} = rightResp{4};
x.AD_Data.AD_Avg_8000Hz_V{1} = rightResp{5};

NelData = make_FFRwav_text_file_subfunc2( ...
    fname,x,aux_fname,NelData);

end