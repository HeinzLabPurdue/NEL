function rc = fmaskedCAP_PAset(attn)
%
% from PAset in NEL (added bc invoke returns sometimes an error)
% AF 8/27/01

global PA
if ((length(attn) > 1) && (length(PA) ~= length(attn)))
    nelerror('PAset: incompatable number of PA devices and attenuations');
    rc = -1;
    return;
end
rc = 1;
for i = 1:length(PA)
    attnval = attn(min(i,length(attn)));
    if (attnval ~= PA(i).attn)
        PA(i).attn = attnval;
        lrc = invoke(PA(i).activeX,'SetAtten',attnval);
        n_attempts=3;
        attempt=1;
        while (lrc==0) && attempt<n_attempts
            pause(0.1)
            lrc = invoke(PA(i).activeX,'SetAtten',attnval);
            attempt=attempt+1;
        end
        if (lrc==0)
            nelerror(['PAset: Can''t set attenuation on PA #' int2str(PA(i).serial_no)]);
            rc = 0;
        end
    end
end

