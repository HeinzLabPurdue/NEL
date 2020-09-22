files=dir(fullfile('./stimFiles/', '**/*.json'));
for i=1:length([files])
    file=files(i);
    filename=[file.folder '/' file.name];
    stim_json=fileread(filename);
    stim_struct=jsondecode(stim_json);

%     for i=1:length(stim_struct.bands)
%         band=stim_struct.bands(i);
%         band.amplitude=band.amplitude*0.1;
%         stim_struct.bands(i)=band;
%     end
    
    [FILEPATH,NAME,EXT] = fileparts(filename);
    stim_struct.name=NAME;
    stim_json_new=jsonencode(stim_struct);
    %HACK makes the code more readable
    stim_json_new=prettyjson.prettyjson(stim_json_new);
    
    
    fileID = fopen(filename,'w');
    fprintf(fileID, stim_json_new);
    fclose(fileID);
end
