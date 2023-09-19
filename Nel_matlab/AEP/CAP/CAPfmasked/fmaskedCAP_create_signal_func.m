function sig = fmaskedCAP_create_signal_func(config_struct,stim_struct, b_coeffs)
%CREATE_SIGNAL_FUNC Returns array corresponding to stim with audio
%parameters in config.
%b_coeffs: opt FIR filter

%Note: a filter can be added to config_struct for inverse filtering done
%directly on the signal, with tranfer function defined in the frequency domain
% (config_struct.calib, first column freq., 
% second amplitudes)

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
    margin=10000;
    sig=zeros(1, n_pts+margin);
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
        sig2=randn(1, n_pts+margin);
        sig2=sosfilt(sos, sig2);
        sig=sig+amp*g*sig2;
    end
    
    if exist('b_coeffs', 'var')
        sig=fftfilt(b_coeffs, sig);
    end
    
    sig=sig(margin+1:end);
    
    
    if isfield(stim_struct, 'extra_atten_dB')
       amp=10^(- stim_struct.extra_atten_dB/20);
       sig=amp*sig;
    end
end

