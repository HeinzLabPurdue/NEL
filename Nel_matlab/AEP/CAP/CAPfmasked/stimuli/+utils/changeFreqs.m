files=dir(fullfile('./stimFiles/5khz-new', '*.json'));  %**/*.json recursive

%change all freqs between mix and max by freq_ratio
freq_min=2000;
freq_max=8000;
freq_ratio=0.95; %or 0.95

move_new_folder=true;
folder2='./stimFiles/5khz-new_lowered2';

if move_new_folder && ~exist(folder2, 'dir') 
   disp(['Creating ' folder2]);
   mkdir(folder2);
end

for i=1:length([files])
    file=files(i);
    filename=[file.folder '/' file.name];
    stim_json=fileread(filename);
    stim_struct=jsondecode(stim_json);

    for i=1:length(stim_struct.bands)
        band=stim_struct.bands(i);
        if band.fc_low>=freq_min && band.fc_low<=freq_max
           band.fc_low=round(freq_ratio*band.fc_low, -1);
        end
        
        if band.fc_high>=freq_min && band.fc_high<=freq_max
           band.fc_high=round(freq_ratio*band.fc_high, -1);
        end       
        
        stim_struct.bands(i)=band;
    end
    
    
    [FILEPATH,NAME,EXT] = fileparts(filename);
    
    newname=[NAME '_lowered'];
    stim_struct.name=NAME;
    stim_struct.comment=[stim_struct.comment '. Frequency bands lowered using script.'];
    stim_json_new=jsonencode(stim_struct);
    %HACK makes the code more readable
    stim_json_new=prettyjson.prettyjson(stim_json_new);

    newfilename = [folder2 '/' newname EXT];
    if move_new_folder
        fileID = fopen(newfilename,'w');
        fprintf(fileID, stim_json_new);
        fclose(fileID);
    end
end
