function addExtraAtten(root)

%script to change extra_atten_dB in a folder (extra_atten_dB is defined
% for each subfolder)


    if ~exist('root','var')
     % third parameter does not exist, so default it to something
      root = './stimFiles/';
    end
    
    files = dir(root);
    % Get a logical vector that tells which is a directory.
    dirFlags = [files.isdir];
    % Extract only those that are directories.
    subFolders = files(dirFlags);
    
    
    new_folder = input('New folder name (if not given, changes files in place): ', 's');
    if ~isempty(new_folder)
        new_folder=fullfile([root '/' new_folder]);
        mkdir(new_folder)
    end

    mode_add = input('Extra attenuation mode: ADD TO EXISTING (1)/ overwrites (0) ');
    if isempty(mode_add)
     mode_add = 1;
    end
    
    
    rec_mode = input('Apply recursively? (Y/n) ', 's');
    if isempty(rec_mode) || rec_mode =='Y' || rec_mode =='y'  || strcmp(rec_mode, 'Yes' ) || strcmp(rec_mode, 'yes' )
     rec_mode = 1;
    elseif rec_mode == 'n'  || rec_mode =='N' || strcmp(rec_mode, 'No' ) || strcmp(rec_mode, 'no' )
       rec_mode=0;
     end
    
    
    for k=1:length(subFolders)
        if not(strcmp(subFolders(k).name, '.') || strcmp(subFolders(k).name, '..') ) 
            
            subfolder=fullfile([root '/' subFolders(k).name]);
            subfolder_st=strrep(subfolder, '\', '\\'); %for Windows...
            include_folder = input(['Include subfolder ' subfolder_st ' ? : (Y/n) '], 's');
            
            if isempty(include_folder) || include_folder =='Y' || include_folder =='y'  || strcmp(include_folder, 'Yes' ) || strcmp(include_folder, 'yes' )
             include_folder = 1;
            elseif include_folder == 'n'  || include_folder =='N' || strcmp(include_folder, 'No' ) || strcmp(include_folder, 'no' )
               include_folder=0;
            end

            if include_folder
                attn_dB = input(['Extra attenuation (in dB) for subfolder (default: 0) ' subfolder_st ' : ']);
                if isempty(attn_dB)
                    attn_dB=0;
                end
                utils.addExtraAtten_SingleFolder(subfolder, attn_dB, mode_add, rec_mode, new_folder)
            end
        end
    end

end
