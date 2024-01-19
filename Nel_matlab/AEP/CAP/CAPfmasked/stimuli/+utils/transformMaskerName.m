function newName = transformMaskerName(name, bandParams, npic)
 %replace {fields} with their values
    for i=1:length(bandParams)
        params=bandParams{i};
        istr=int2str(i);
        name=strrep(name, ['{fl' istr '}'], int2str(round(params.fleft*1000)));
        name=strrep(name, ['{fr' istr '}'], int2str(round(params.fright*1000)));
        name=strrep(name, ['{fc' istr '}'], int2str(round((params.fright+params.fleft)/2*1000)));
        
        name=strrep(name, ['{f_c' istr '}'], int2str(round((params.fright+params.fleft)/2*1000)));
        for deltastr={'d', 'D', 'Delta', 'delta', 'Delta_','delta_'}
            name=strrep(name, ['{' deltastr{1} 'f' istr '}'], int2str(round((params.fright-params.fleft)*1000)));
        end
        name=strrep(name, ['{bw' istr '}'], int2str(round((params.fright-params.fleft)*1000)));
        for ampstr={'amp', 'dB'}
            name=strrep(name, ['{' ampstr{1} istr '}'], [int2str(round(params.amp)) 'dB']);
        end
        for ampstr={'atten', 'attn'}
            name=strrep(name, ['{' ampstr{1} istr '}'], [int2str(round(-params.amp)) 'dB']);
        end
    end
    for picstr={'pic', 'npic'}
        name=strrep(name, ['{' picstr{1} '}'], int2str(npic));
    end
    newName=name;
end