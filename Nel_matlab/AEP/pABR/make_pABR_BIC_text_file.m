function NelData=make_pABR_BIC_text_file(misc,Stimuli,invfiltdata,PROG,NelData,...
    comment,RunLevels_params,FFR_Gating,BICResp,Display,pABRattens,...
    pABRinterstim,pABR_EpochResp1,pABRstim,...
    conditionChannels,conditionLabels)
% Save one processed stimulus-train response for each BIC condition.

[x,aux_fname,fname]=make_Bic_text_file_subfunc1(misc,pABRstim,...
    invfiltdata,PROG,NelData,comment,RunLevels_params,FFR_Gating,Display,...
    pABRattens,pABRinterstim);

nConditions=numel(conditionLabels);
nFreq=size(BICResp,2);
nLevels=size(BICResp,3);
if RunLevels_params.decimateFact~=1
    for cc=1:nConditions
        for ff=1:nFreq
            for ll=1:nLevels
                if ~isempty(BICResp{cc,ff,ll})
                    BICResp{cc,ff,ll}=decimate(BICResp{cc,ff,ll},...
                        RunLevels_params.decimateFact);
                end
            end
        end
    end
end

x.AD_Data.RecordingChannel=Stimuli.rec_channel;
x.AD_Data.ResponseLabel={'StimulusTrain'};
x.AD_Data.ConditionChannels=conditionChannels;
freqNames={'500Hz','1000Hz','2000Hz','4000Hz','8000Hz'};
for cc=1:nConditions
    % Label{cc} identifies the complete separately acquired condition.
    x.AD_Data.Label{cc}=conditionLabels{cc};
    x.AD_Data.AD_All_V{cc}=squeeze(pABR_EpochResp1(cc,:,:));
    for ff=1:nFreq
        fieldName=['AD_Avg_' freqNames{ff} '_V'];
        x.AD_Data.(fieldName){cc,1}=reshape(BICResp(cc,ff,:),1,[]);
    end
end

NelData=make_FFRwav_text_file_subfunc2(fname,x,aux_fname,NelData);
end
