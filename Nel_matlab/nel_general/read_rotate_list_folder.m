function [LFileList,RFileList,rotfolder_name] = read_rotate_list_folder(stimulus_vals)
% SP on 10/16/19: Original file = read_rotate_list_file
% [LFileList,RFileList,rotlist_name] = read_rotate_list_file(rotlist_name)

% AF 12/4/01
global cache_stim_data

rotfolder_name= stimulus_vals.Inloop.List_Folder;
try
    allWavFiles= dir([rotfolder_name '*.wav']);
    Lchannel.file_list= cellfun(@(x, y) [x filesep y], {allWavFiles.folder}', {allWavFiles.name}', 'UniformOutput', false);
    Lchannel.file_list= Lchannel.file_list(randperm(numel(Lchannel.file_list)));
    
    cache_stim_data= cell(length(Lchannel.file_list), 1);
    for fileVar=1:length(Lchannel.file_list)
        [cache_stim_data{fileVar}, fs]= audioread(Lchannel.file_list{fileVar});
        if stimulus_vals.Inloop.UpdateRate~=fs
            warning('Should be the same');
        end
        cache_stim_data{fileVar}= window_waveform(cache_stim_data{fileVar}, stimulus_vals);
        % Assuming Fs= 100e3;
        % Need to add this check somewhere.
    end
    
catch
    nelerror(['Error in ''' rotfolder_name ''': ' lasterr  'No stimulus will be generated.']);
    RFileList = [];   LFileList = [];
    return
end

if (exist('Rchannel','var') ~= 1)
    Rchannel = [];
end
if (exist('Lchannel','var') ~= 1)
    Lchannel = [];
end

if (isempty(Rchannel) && isempty(Lchannel))
    nelerror(['''' rotfolder_name ''' contains no definition for ''Rchannel'' and ''Lchannel''. '  ...
        'No stimulus will be generated.']);
    RFileList = [];   LFileList = [];
    return
end
try
    eval('RFileList = expand_file_list(Rchannel);');
catch
    nelerror(['Error while expanding Rchannel file list: ''' lasterr ''' No stimulus will be generated.']);
    RFileList = [];   LFileList = [];
    return
end
try
    eval('LFileList = expand_file_list(Lchannel);');
catch
    nelerror(['Error while expanding Lchannel file list: ''' lasterr ''' No stimulus will be generated.']);
    RFileList = [];   LFileList = [];
    return
end

return
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function flist = expand_file_list(spec)
%%
if (isempty(spec))
    flist = [];
    return;
end
flist = cell(1,100);
counter = 0;
for i = 1:length(spec.file_list)
    a = dir(spec.file_list{i});
    dirname = [fileparts(spec.file_list{i}) filesep];
    for j = 1:length(a)
        counter = counter+1;
        flist{counter} = [dirname a(j).name];
    end
end
flist = flist(1:counter);
if ((isfield(spec,'sort')) && (spec.sort == 1))
    flist = sort(flist);
end
if (isfield(spec,'shift'))
    N = length(flist);
    if (spec.shift > 0)
        flist = flist([N-(spec.shift-1:-1:0) 1:N-spec.shift]);
    else
        flist = flist([-spec.shift+1:N 1:-spec.shift]);
    end
end
return
end

function out_wave = window_waveform(in_wave, stimulus_vals)

ur_Hz = stimulus_vals.Inloop.UpdateRate;
rf_time_sec = stimulus_vals.Gating.Rise_fall_time / 1000;
ramp_nSamples = ceil(ur_Hz * rf_time_sec);
end_sample = size(in_wave, 1);
windowing_vector = zeros(size(in_wave));
windowing_vector(1:ramp_nSamples) = (0:(ramp_nSamples-1))/ramp_nSamples;
windowing_vector((ramp_nSamples+1):(end_sample-ramp_nSamples)) = 1;
windowing_vector(((end_sample-ramp_nSamples)+1):end) = ((ramp_nSamples-1):-1:0)/ramp_nSamples;
out_wave = windowing_vector .* in_wave;
end
