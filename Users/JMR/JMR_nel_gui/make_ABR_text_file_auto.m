% make_CAP_text_file.m
% Adapted from "make_tc_text_file.m" by GE/MH, 02Nov2003.

% ge debug ABR 26Apr2004: need to check boolean AutoLevel_params.bMultiOutputFiles and handle appropriately.

if ~(AutoLevel_params.bMultiOutputFiles)  % added by GE 26Apr2004.
    
    make_CAP_text_file_subfunc1;
    
    x.Line.attens_dB = CAPattens; % cell array(3)
    if FIG.NewStim==17
        x.Stimuli.atten_dB = Stimuli.atten_dB + AutoLevel_params.stepdB*AutoLevel_params.attenMask; % added by GE 26Apr2004.
    else FIG.NewStim==10
        x.Stimuli.atten_dB = Stimuli.atten_dB
    end
    CAPdataReps_dec=cell(size(AutoLevel_params.attenMask));  % All Reps COMMENTED OUT: KH 10Jan2012
    for i=1:size(CAPdataAvg,1) % changed from i=1:length(CAPdataAvg)- Dave 4/9/15
        for m=1:size(CAPdataAvg,2) %m loop added to account for multiple frequencies in audiogram -Dave
            if (AutoLevel_params.decimateFact~=1)
                CAPdataAvg{i,m} = decimate(CAPdataAvg{i,m}, AutoLevel_params.decimateFact);
                CAPdataReps_dec{i,m} = zeros(2*AutoLevel_params.nPairs,length(CAPdataAvg{i,m}));
                % MH 18Nov2003: Add code to save all Reps
                for j=1:2*AutoLevel_params.nPairs
                    CAPdataReps_dec{i,m}(j,:) = decimate(CAPdataReps{i,m}(j,:), AutoLevel_params.decimateFact);
                end
            else
                CAPdataReps_dec{i,m} = CAPdataReps{i,m};
            end
        end
    end
    
    x.AD_Data.AD_All_V = CAPdataReps_dec; % modified by GE 26Apr2004.
    x.AD_Data.AD_Avg_V = CAPdataAvg{1};
    
    make_CAP_text_file_subfunc2;
    
    %remove all data and save the average data only! 
    temp_struct=x.AD_Data;
    temp_struct1=rmfield(temp_struct,'AD_All_V');
    x.AD_Data=temp_struct1;
    
    make_CAP_text_file_subfunc3;
    x.AD_Data=temp_struct;
    
else
    for attenInd = 1:length(AutoLevel_params.dBs2RUN)
        
        make_CAP_text_file_subfunc1;
        
        x.Line.attens_dB = CAPattens{attenInd}; % ge debug ABR 26Apr2004.
%         x.Stimuli.atten_dB = Stimuli.atten_dB + AutoLevel_params.stepdB*AutoLevel_params.attenMask(attenInd); % added by GE 26Apr2004.
%         error('Change the next line in make_ABR_text_file_auto.m L54');
        x.Stimuli.atten_dB = Atten_dBs(attenInd); %% change it 
                
        % 		i = attenInd; % ge debug ABR 26Apr2004.
        if (AutoLevel_params.decimateFact~=1)
            CAPdataAvg{attenInd} = decimate(CAPdataAvg{attenInd}, AutoLevel_params.decimateFact);
            CAPdataReps_dec = zeros(2*AutoLevel_params.nPairs,length(CAPdataAvg{attenInd}));
            for j=1:2*AutoLevel_params.nPairs
                CAPdataReps_dec(j,:) = decimate(CAPdataReps{attenInd}(j,:), AutoLevel_params.decimateFact);
            end     
        else
            CAPdataReps_dec = CAPdataReps{attenInd};
        end
        
        x.AD_Data.AD_All_V = CAPdataReps_dec;  % modified by GE 26Apr2004.
        x.AD_Data.AD_Avg_V = CAPdataAvg{attenInd}; 
        
        make_CAP_text_file_subfunc2;
        
        %remove all data and save the average data only! 
        temp_struct=x.AD_Data;
        temp_struct1=rmfield(temp_struct,'AD_All_V');
        x.AD_Data=temp_struct1;
        
        make_CAP_text_file_subfunc3;
        x.AD_Data=temp_struct;
        
    end
end