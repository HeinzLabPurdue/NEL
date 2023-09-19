files=dir(fullfile('./stimFiles/10-various-maskers/', '*.json'));  %**/*.json recursive
 for i=1:length([files])
    file=files(i);
    filename=[file.folder '/' file.name];
    stim_json=fileread(filename);
    stim_struct=jsondecode(stim_json);

    for i=1:length(stim_struct.bands)
        band=stim_struct.bands(i);
        band.amplitude=band.amplitude*0.5623; %-5db 0.5623
        stim_struct.bands(i)=band;
    end
    
    
    [FILEPATH,NAME,EXT] = fileparts(filename);
    if ~contains(NAME, '_attn10dB')
        newname=[NAME '_attn5dB'];
        stim_struct.name=NAME;
        stim_json_new=jsonencode(stim_struct);
        %HACK makes the code more readable
        stim_json_new=prettyjson.prettyjson(stim_json_new);

        newfilename = [FILEPATH '/' newname '.' EXT];
        fileID = fopen(newfilename,'w');
        fprintf(fileID, stim_json_new);
        fclose(fileID);
    end
end
