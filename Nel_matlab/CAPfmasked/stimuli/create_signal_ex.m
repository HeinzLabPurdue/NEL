%Generate signal for one file

plot_freq_sig=true; %plot spectrum
create_wavefile=true; %create WAV file

%load config file
config_json=fileread('config.json');
config_struct=jsondecode(config_json);

%load stimulus file
filename='./nomasker.json'; %'stim_ex2.json';
stim_json=fileread(filename);
stim_struct=jsondecode(stim_json);


sig = create_signal_func(config_struct, stim_struct);

%useful params
fs=config_struct.fs;
T=config_struct.duration_s; %duration in sec
n_pts=floor(T*fs);
filter_order=config_struct.filter_order;
n_casc=config_struct.filter_order_mult;

X = fftshift(fft(sig));

if plot_freq_sig
    N=n_pts;
    Fs=fs;
    %%Frequency specifications:
    dF = Fs/N;                      % hertz
    f = -Fs/2:dF:Fs/2-dF;           % hertz

    figure;
    plot(f,abs(X)/N);
    xlim([0 15000]);
    xlabel('Frequency (Hz)');
    title('Magnitude Response');
end
%soundsc(sig, fs);

if create_wavefile
    [filepath,name,ext] = fileparts(filename);
    assert(~any(sig>1.), 'a value in the generated signal exceeds 1')
    wav_filename=[name '_' int2str(round(fs)) '_' int2str(filter_order*n_casc) '_' int2str(round(T)) '.wav'];

    if isfile([filepath wav_filename])
        warning('wavefile already exists, not saving new signal')
    else
        audiowrite([filepath '/' wav_filename], sig, fs)

        if ~isfield(stim_struct, 'wavefiles')
            stim_struct.wavefiles=[];
        end

        wav_struct=config_struct;
        wav_struct.filename=wav_filename;
        stim_struct.wavefiles = [stim_struct.wavefiles; wav_struct];

        stim_json_new=jsonencode(stim_struct);
        %HACK makes the code more readable
        stim_json_new=prettyjson.prettyjson(stim_json_new);

        fileID = fopen(filename,'w');
        fprintf(fileID, stim_json_new);
        fclose(fileID);
    end
end