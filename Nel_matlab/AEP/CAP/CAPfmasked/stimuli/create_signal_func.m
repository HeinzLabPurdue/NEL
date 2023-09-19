function sig = create_signal_func(config_struct,stim_struct)
%CREATE_SIGNAL_FUNC Returns array corresponding to stim with audio
%parameters in config

    fs=config_struct.fs;
    T=config_struct.duration_s; %duration in sec
    filter_order=config_struct.filter_order;
    n_casc=config_struct.filter_order_mult;
    %the real filter order is filter_order x n_casc (x 2 <- bandpass filters)

    nb_bands=stim_struct.n_bands;
    assert(strcmp(stim_struct.type,'noise-bands'), "script generates only noise bands maskers for now")
    assert(nb_bands==length(stim_struct.bands), "n_bands does not match the number of bands in json file")

    %Generation signal
    f_ny=fs/2;
    n_pts=floor(T*fs);
    sig=zeros(1, n_pts);
    for k=1:nb_bands
        band_info=stim_struct.bands(k);
        f_low=band_info.fc_low;
        f_high=band_info.fc_high;
        amp=band_info.amplitude;
        [z, p, g]=butter(filter_order,[f_low f_high]/f_ny);
        [sos,g] = zp2sos(z,p,g);
        sos = repmat(sos, n_casc, 1);
        g=power(g, n_casc);
        %fvt = fvtool(sos,'Fs',fs);
        sig2=randn(1, n_pts);
        sig2=sosfilt(sos, sig2);
        sig=sig+amp*g*sig2;
    end
end

