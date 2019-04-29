function [RMS_Noise,LOWsideINDs,HIGHsideINDs] = EstimateNoise(CurrentAmpVec, FreqV_Hz, DPFreq_Hz, F1_Freq_Hz, SearchDPIndices)
% Modified by M. Heinz 7/19/06
%   fixed LOWsideINDs calc
%   took out un-needed params

DP_to_F1_Indices=find(FreqV_Hz > DPFreq_Hz & FreqV_Hz < F1_Freq_Hz);
OctBelowDP_to_DP_Indices=find(FreqV_Hz > DPFreq_Hz/2 & FreqV_Hz < DPFreq_Hz);
DP_to_F1Slope=diff(CurrentAmpVec(DP_to_F1_Indices));
OctBelow_to_DPSlope=diff(CurrentAmpVec(OctBelowDP_to_DP_Indices));

index = 1;
SlopeChangeH=[]; % added 2/27 to prevent empty SlopeChangeH variable.
for c = 2:length(DP_to_F1Slope)
	if DP_to_F1Slope(c) > 0 & DP_to_F1Slope(c-1) < 0
		SlopeChangeH(index) = c;
		index=index+1;
	else
	end
end
if isempty(SlopeChangeH) % added 2/27 to prevent empty SlopeChangeH variable.
    SlopeChangeH(1)= c;
end

index = 1;
for c = 2:length(OctBelow_to_DPSlope)
	if OctBelow_to_DPSlope(c) > 0 & OctBelow_to_DPSlope(c-1) < 0
		SlopeChangeL(index) = c;
		index=index+1;
	else
	end
end

Low_Win_Cutoff_H = DP_to_F1_Indices(SlopeChangeH(1)); % Low side cutoff for the window above the DP
High_Win_Cutoff_H = Low_Win_Cutoff_H + 2*length(SearchDPIndices);
HIGHsideINDs=Low_Win_Cutoff_H:High_Win_Cutoff_H;

High_Win_Cutoff_L = OctBelowDP_to_DP_Indices(SlopeChangeL(end));% High side cutoff for the window below the DP
Low_Win_Cutoff_L = High_Win_Cutoff_L - 2*length(SearchDPIndices);
LOWsideINDs=Low_Win_Cutoff_L:High_Win_Cutoff_L;

Amp_N_High=CurrentAmpVec(Low_Win_Cutoff_H:min(High_Win_Cutoff_H,end));
Amp_N_Low=CurrentAmpVec(Low_Win_Cutoff_L:High_Win_Cutoff_L);

RMS_N_Low=sqrt(mean(Amp_N_Low.^2));
RMS_N_High= sqrt(mean(Amp_N_High.^2));
RMS_Noise = (RMS_N_Low+RMS_N_High)/2;
