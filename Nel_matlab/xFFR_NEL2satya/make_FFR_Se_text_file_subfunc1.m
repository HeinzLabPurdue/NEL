% Edited by SP

function [x, aux_fname, fname]=make_FFR_Se_text_file_subfunc1 ...
    (misc, Stimuli, PROG, NelData, comment, RunLevels_params, FFR_Gating, Display, FFRattens)

if isfield(Stimuli, 'SNR_dB')
    fname = current_data_file(...
        [ ...
        [misc.fileExtension strrep(Stimuli.filename(1:end-4),'-','_m')] ...
        ['_snr_' strrep(num2str(Stimuli.SNR_dB), '-', 'm')] ...
        ['_atn' num2str(Stimuli.atten_dB)] ...
        ],1);
else 
    fname = current_data_file(...
        [ ...
        [misc.fileExtension strrep(Stimuli.filename(1:end-4),'-','_m')] ...
        ['_atn' num2str(Stimuli.atten_dB)] ...
        ],1);
    
end

% for pink SFR
if contains(fname, 'pink')
    fname= strrep(fname, 'pinkSSN_Stim_', 'pink_'); % Short name for SFR in pink
    fname= strrep(fname, '_P_', '_'); % Both polarities are played, no need to add _P_ or _N_
end

% for harmonic complex EFR
fname= strrep(fname, 'high', '_H'); % SP Nov 8, 18: Filename too long, so file doesn't load. 
fname= strrep(fname, 'low', 'L'); % SP Nov 8, 18: Filename too long, so file doesn't load. 
fname= strrep(fname, 'complex_', '');


[pathstr, name, ~]=fileparts(fname); %MW 04-2017 removed 4th argument versn, unused and threw obscelence warning
aux_fname = fullfile(pathstr,['a' name(2:end)]);

x.General.program_name  = PROG.name;
x.General.picture_number = NelData.File_Manager.picture+1;
x.General.date          = date;
x.General.time          = datestr(now,13);
x.General.comment       = comment;
x.General.host = lower(getenv('hostname'));

x.Stimuli=Stimuli;
x.Stimuli.RunLevels_params = RunLevels_params;
x.Stimuli.FFR_Gating = FFR_Gating;
% x.Line.freq_Hz = Stimuli.fc; % zz 04nov11 original only had one frequency, updated to carrier frequency

x.AD_Data.Gain=Display.Gain;

% stimuli_fname = fullfile(pathstr,'Signals');

x.Stimuli.atten_dB = Stimuli.atten_dB + RunLevels_params.stepdB*RunLevels_params.attenMask;
x.Line.attens_dB = FFRattens;