function rc = fmaskedCAP_write_nel_data(fname, data_struct,save_spikes, saveMat)

    if saveMat
        [pathstr, name, ext]=fileparts(fname);
        rc=1-2*isfile([pathstr '\' name '.mat']);
        if rc>0
             save([pathstr '\' name '.mat'], 'data_struct')
        end
    else
        rc=write_nel_data(fname,data_struct,save_spikes);
    end

end