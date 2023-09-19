function addExtraAtten_SingleFolder(path, extra_atten_dB, add_mode, recursive_mode, newfolder_path)
    % Add a field 'extra_atten_dB' to stim files (.json) in a folder
    % path: folder path
    % extra_atten_dB: extra attenuation
    % add_mode: if 0, overwrites extra atten, if 1 adds to existing atten.
    % (default: 0)
    % recursive_mode: if 1, looks for json files recursively (default:0)
    % newfolder_path (opt): if not given or empty, changes files in place
    
    
    if ~exist('add_mode', 'var')
        add_mode=0;
    end
    if ~exist('recursive_mode', 'var')
        recursive_mode=0;
    end
    
    if recursive_mode
        pattern='**/*.json';
    else
        pattern='*.json';
    end
    
    files=dir(fullfile(path, pattern));
     for i=1:length([files])
        file=files(i);
        filename=[file.folder '/' file.name];
        
        stim_json=fileread(filename);
        stim_struct=jsondecode(stim_json);
        
        extra_atten_dB0=0;
        if add_mode && isfield(stim_struct, 'extra_atten_dB')
            extra_atten_dB0=stim_struct.extra_atten_dB;
        end
        stim_struct.extra_atten_dB=extra_atten_dB0+extra_atten_dB;

        


        [FILEPATH,NAME,EXT] = fileparts(filename);
        
    
        if exist('newfolder_path', 'var') && ~isempty(newfolder_path)
           FILEPATH=newfolder_path;
        end
        
        newname=NAME;
        %stim_struct.name=NAME;
        stim_json_new=jsonencode(stim_struct);
        %HACK makes the code more readable
        stim_json_new=prettyjson.prettyjson(stim_json_new);

        newfilename = [FILEPATH '/' newname EXT];
        fileID = fopen(newfilename,'w');
        fprintf(fileID, stim_json_new);
        fclose(fileID);
    end
end
