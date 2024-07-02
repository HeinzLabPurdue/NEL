function promptMetadata()
% Add functionality to handle a debug/test mode and a FPLprobe mode
% May be times when you dont have a chin/exposure/sedation

global NelData  SKIPintro
     user = {''}; title = 'NEL Login'; 
     Empty= 1;
     fieldsize = [1 45; 1 45; 1 45; 1 45; 1 45; 1 45; 1 45];
     if SKIPintro
                    user = {'MH'};
        else
           
   while (Empty)  
    definput = {NelData.Metadata.Otherusers,NelData.Metadata.ChinID,NelData.Metadata.Sex,NelData.Metadata.Exposure,NelData.Metadata.ExposureDate,NelData.Metadata.Branch, NelData.Metadata.Comments};
    expInfo_prompt = {'Additional Experimenters:', 'Animal ID: (required)','Sex: (required)','Exposure Type: (required)', 'Exposure Date:', 'Branch:','Comments:'};
    expInfo = inputdlg(expInfo_prompt,title,fieldsize,definput);
%     user = {expInfo{1}};
    % Assign to NEL Metadata
%     NelData.Metadata.User = expInfo{1};

    Empty= isempty(expInfo{2}) | isempty(expInfo{3}) | isempty(expInfo{4});
    
    NelData.Metadata.Otherusers = expInfo{1};
    NelData.Metadata.ChinID = expInfo{2};
    NelData.Metadata.Sex = expInfo{3};
    NelData.Metadata.Exposure = expInfo{4};
    NelData.Metadata.ExposureDate=expInfo{5};
    NelData.Metadata.Branch=expInfo{6};
    NelData.Metadata.Comments=expInfo{7};
    
    
    
   end 
    

    expInfo_prompt2 = {'Category of Sedation'};
    sedation_opts = {'Light','Ket+Xyl','Awake'}; 
    expInfo2 = listdlg('PromptString',expInfo_prompt2,'SelectionMode','single','ListString',sedation_opts,'ListSize',[160,100]);
    NelData.Metadata.Sedation = sedation_opts{expInfo2};  
        end
        
        
end

