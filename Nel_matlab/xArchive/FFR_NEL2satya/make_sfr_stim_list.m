% Looks like not called from any function
fprintf('--------------------------------------- \n Running %s \n ---------------------------------------\n',  mfilename);

% xxxx= dir('C:\NEL2\Users\SP\SNRenv_stimuli\FFRSNRenv_short_stationary_org\*.wav');
xxxx= dir([NelData.General.RootDir 'Users\SP\SNRenv_stimuli\FFRSNRenv_short_ssn_pink_masker\*.wav']);

SNRenv_stimlist= repmat(struct('name', []), length(xxxx), 1); 

for i=1:length(xxxx)
    SNRenv_stimlist(i).name= xxxx(i).name;
end

{SNRenv_stimlist.name}'

save([NelData.General.RootDir 'Users\SP\SNRenv_stimuli\SNRenv_stimlist_pink_masker.mat'], 'SNRenv_stimlist');