function rc = load_raw_samples(rp_num,data,sr)
% LOAD_RAW_SAMPLES    Loads stimulus samples to the specified RP structure. 
%                     The data is not actually sent to the device (Use RPset_params for this purpose).
%                     'load_raw_samples' warns if the data sampling rate does not match the RP 
%                     sampling rate.
%
%           USAGE:    rc = load_raw_samples(rp_num,data,sr);
%                     where 'rp_num' is the RP number (currently 1 or 2),
%                     'data' is the samples vercor, and 'sr' is the data sampling rate.
%                     'rc' is 1 (success) or -1 (failure).
%
%           EXAMPLE:  [data,sr] = wavread('bla.wav');
%                     rc  = load_raw_samples(1,data,sr);
%                     if (rc), RPset_params(RP(1)); end


% AF 9/21/01

global RP

tolerance = 1e-4;
rc = 1;
if (rp_num < 1  |  rp_num > length(RP))
   waitfor(errordlg(['LOAD_RAW_SAMPLES: Illegal ''rp_num'' (' int2str(rp_num) ')']));
   rc = 0;
   return
end
sr_ratio = RP(rp_num).sampling_rate / sr;
if (abs(round(sr_ratio)/sr_ratio -1) > tolerance)
   waitfor(warndlg(sprintf('Data sampling rate (%.1f) doesn''t match\nRP(%d)''s sampling rate (%.1f)', ...
      sr, rp_num, RP(rp_num).sampling_rate),'LOAD_RAW_SAMPLES'));
   rc = 0;
end
if (max(abs(data)) >1)
   waitfor(warndlg(sprintf('Data will be clipped during write to RP(%d)\nLimit you data to the range of [-1 1]', rp_num), ...
      'LOAD_RAW_SAMPLES'));
   rc = 0;
   data(data >  1) =  1.0;
   data(data < -1) = -1.0;
end
      
RP(rp_num).params.samp_ratio = round(sr_ratio);
RP(rp_num).params.samp_comp  = round(sr_ratio);
RP(rp_num).params.buff_data  = data(:)';

