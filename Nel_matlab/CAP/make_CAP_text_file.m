% make_CAP_text_file.m
% Adapted from "make_tc_text_file.m" by GE/MH, 02Nov2003.

% ge debug ABR 26Apr2004: need to check boolean RunLevels_params.bMultiOutputFiles and handle appropriately.

if ~(RunLevels_params.bMultiOutputFiles)  % added by GE 26Apr2004.

	make_CAP_text_file_subfunc1;
   
	x.Line.attens_dB = CAPattens; % cell array(3)
    x.Stimuli.atten_dB = Stimuli.atten_dB + RunLevels_params.stepdB*RunLevels_params.attenMask; % added by GE 26Apr2004.
	
	CAPdataReps_dec=cell(size(RunLevels_params.attenMask));  % All Reps COMMENTED OUT: KH 10Jan2012
	for i=1:size(CAPdataAvg,1) % changed from i=1:length(CAPdataAvg)- Dave 4/9/15
        for m=1:size(CAPdataAvg,2) %m loop added to account for multiple frequencies in audiogram -Dave
            if (RunLevels_params.decimateFact~=1)
                CAPdataAvg{i,m} = decimate(CAPdataAvg{i,m}, RunLevels_params.decimateFact);
                CAPdataReps_dec{i,m} = zeros(2*RunLevels_params.nPairs,length(CAPdataAvg{i,m}));
                % MH 18Nov2003: Add code to save all Reps
                for j=1:2*RunLevels_params.nPairs
                    CAPdataReps_dec{i,m}(j,:) = decimate(CAPdataReps{i,m}(j,:), RunLevels_params.decimateFact);
                end
            else
                CAPdataReps_dec{i,m} = CAPdataReps{i,m};
            end
        end
	end
	
    if (RunLevels_params.saveRepsYes==1)
	    x.AD_Data.AD_All_V = CAPdataReps_dec; % modified by GE 26Apr2004.
    end
    x.AD_Data.AD_Avg_V = CAPdataAvg;
	
   make_CAP_text_file_subfunc2;
	
else
   for attenInd = 1:length(RunLevels_params.attenMask)

      make_CAP_text_file_subfunc1;
	
      x.Line.attens_dB = CAPattens{attenInd}; % ge debug ABR 26Apr2004.
      x.Stimuli.atten_dB = Stimuli.atten_dB + RunLevels_params.stepdB*RunLevels_params.attenMask(attenInd); % added by GE 26Apr2004.
		
% 		i = attenInd; % ge debug ABR 26Apr2004.
		if (RunLevels_params.decimateFact~=1)
          CAPdataAvg{attenInd} = decimate(CAPdataAvg{attenInd}, RunLevels_params.decimateFact);
          CAPdataReps_dec = zeros(2*RunLevels_params.nPairs,length(CAPdataAvg{attenInd}));
          for j=1:2*RunLevels_params.nPairs
             CAPdataReps_dec(j,:) = decimate(CAPdataReps{attenInd}(j,:), RunLevels_params.decimateFact);
          end     
       else
          CAPdataReps_dec = CAPdataReps{attenInd};
		end
		
		x.AD_Data.AD_All_V = CAPdataReps_dec;  % modified by GE 26Apr2004.
		x.AD_Data.AD_Avg_V = CAPdataAvg{attenInd}; 

      make_CAP_text_file_subfunc2;
   end
end