function [drivenSpikes_BINS, drivenSpikes_radians, PERhist]=quick_PERhist(drivenSpikes,fm,PERhist_window_sec)


K=64;  %% # bins/cycle
fm=fm*1000;
binWidth_sec=1/fm/K;
M=floor(diff(PERhist_window_sec)*fm);  % Integer number of cycles to include in driven-spike window
PERhist_window_sec(2)=PERhist_window_sec(1)+M/fm; % Reset EndTime to limit to integer number of cycles of F0


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Make Period Histogram
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
drivenSpikes_BINS=rem(floor(drivenSpikes/binWidth_sec),K)+1; %Convert times to PERhist bins (1:K)
drivenSpikes_radians=rem((drivenSpikes),K*binWidth_sec)*fm*2*pi; %Convert times to PERhist bins (1:K)
[PERhist,xxx]=hist(drivenSpikes_BINS,(1:K));  % Make Histogram from BINS (1:K)
% This is the actual number of recorded spikes used to create this PERhist
% (use this for stats, etc ...)
NumDrivenSpikes=sum(PERhist);


% %%% Convert PERhist to spikes per second
% PERhist=PERhist/M/binWidth_sec; % Convert to sp/sec
% 
% % Store calcs
% PIC.PERhist.NumDrivenSpikes=NumDrivenSpikes;
% PIC.PERhist.PERhist=PERhist;
% PIC.PERhist.PERhist_X_sec=(0.5:K)*binWidth_sec;
% 
% % Store parameters used for calcs
% PIC.PERhist.params.binWidth_sec=binWidth_sec;
% PIC.PERhist.params.PERhist_window_sec=PERhist_window_sec;

return;
