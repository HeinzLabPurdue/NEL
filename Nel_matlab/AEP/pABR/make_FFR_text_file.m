% make_FFR_text_file.m
% Adapted from "make_tc_text_file.m" by GE/MH, 02Nov2003.

% ge debug ABR 26Apr2004: need to check boolean RunLevels_params.bMultiOutputFiles and handle appropriately.

% removed multiple output files for FFR use - zz 04nov11
% if ~(RunLevels_params.bMultiOutputFiles)  % added by GE 26Apr2004.

make_FFR_text_file_subfunc1;
x.Line.attens_dB = FFRattens; % cell array(3)
x.Stimuli.atten_dB = Stimuli.atten_dB + RunLevels_params.stepdB*RunLevels_params.attenMask; % added by GE 26Apr2004.

%  Removing all reps zz 04nov2011
% 	FFRdataReps_dec=cell(size(RunLevels_params.attenMask));  % All Reps
for i=1:length(FFRdataAvg_NP)
   if (RunLevels_params.decimateFact~=1)
      FFRdataAvg_NP{i} = decimate(FFRdataAvg_NP{i}, RunLevels_params.decimateFact);
      FFRdataAvg_PO{i} = decimate(FFRdataAvg_PO{i}, RunLevels_params.decimateFact);
      if strcmp(interface_type,'SPIKES')
            FFRdataStoreNP{i} = decimate(FFRdataStoreNP{i}, RunLevels_params.decimateFact);
            FFRdataStorePO{i} = decimate(FFRdataStorePO{i}, RunLevels_params.decimateFact);
      end
      
%       
%       FFRdataReps_dec{i} = zeros(2*RunLevels_params.nPairs,length(FFRdataAvg{i}));
%       %       MH 18Nov2003: Add code to save all Reps
%       %       zz 04nov2011: removed code for all reps
%       for j=1:2*RunLevels_params.nPairs
%           FFRdataReps_dec{i}(j,:) = decimate(FFRdataReps{i}(j,:), RunLevels_params.decimateFact);
%       end     
%   else
%       FFRdataReps_dec{i} = FFRdataReps{i};
%       
   end
end
%    for i=1:length(FFRdataAvg)
%        if (RunLevels_params.decimateFact~=1)
%           FFRdataAvg{i} = decimate(FFRdataAvg{i}, RunLevels_params.decimateFact);
%           FFRdataReps_dec{i} = zeros(2*RunLevels_params.nPairs,length(FFRdataAvg{i}));
%           % MH 18Nov2003: Add code to save all Reps
%           for j=1:2*RunLevels_params.nPairs
%              FFRdataReps_dec{i}(j,:) = decimate(FFRdataReps{i}(j,:), RunLevels_params.decimateFact);
%           end     
%        else
%           FFRdataReps_dec{i} = FFRdataReps{i};
%        end
% 	  end
save_all_reps=1; % change to 0 to only save averages.

if save_all_reps==1
	x.AD_Data.AD_All_V = FFRdataReps; % _dec removed from end of FFRdataReps % modified by GE 26Apr2004. Removed zz 04nov2011. Added DA 7/25/13
end
    % 	x.AD_Data.AD_Avg_V = FFRdataAvg;
x.AD_Data.AD_Avg_NP_V = FFRdataAvg_NP;
x.AD_Data.AD_Avg_PO_V = FFRdataAvg_PO;
if strcmp(interface_type,'SPIKES')
    x.AD_Data.AD_StoreNP_V = FFRdataStoreNP;
    x.AD_Data.AD_StorePO_V = FFRdataStorePO;
end

make_FFR_text_file_subfunc2;
	
% else
%    for attenInd = 1:length(RunLevels_params.attenMask)
% 
%       make_FFR_text_file_subfunc1;
% 	
%       x.Line.attens_dB = FFRattens{attenInd}; % ge debug ABR 26Apr2004.
%       x.Stimuli.atten_dB = Stimuli.atten_dB + RunLevels_params.stepdB*RunLevels_params.attenMask(attenInd); % added by GE 26Apr2004.
% 		
% % 		i = attenInd; % ge debug ABR 26Apr2004.
% 		if (RunLevels_params.decimateFact~=1)
%           FFRdataAvg{attenInd} = decimate(FFRdataAvg{attenInd}, RunLevels_params.decimateFact);
%           FFRdataReps_dec = zeros(2*RunLevels_params.nPairs,length(FFRdataAvg{attenInd}));
%           for j=1:2*RunLevels_params.nPairs
%              FFRdataReps_dec(j,:) = decimate(FFRdataReps{attenInd}(j,:), RunLevels_params.decimateFact);
%           end     
%        else
%           FFRdataReps_dec = FFRdataReps{attenInd};
% 		end
% 		
% 		x.AD_Data.AD_All_V = FFRdataReps_dec;  % modified by GE 26Apr2004.
% 		x.AD_Data.AD_Avg_V = FFRdataAvg{attenInd}; 
% 
%       make_FFR_text_file_subfunc2;
%    end
% end