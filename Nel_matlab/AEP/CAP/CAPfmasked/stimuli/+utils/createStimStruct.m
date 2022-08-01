function stimStruct = createStimStruct(nbands, bandParamsArr)
    stimStruct=struct('type', 'noise-bands', 'comment', ['created with noiseBandMaskerDesigner.m ' date]);
    stimStruct.n_bands=nbands;
    stimStruct.bands=cell(1, nbands);
    for i=1:nbands
       bandParams0=bandParamsArr{i};
       amp=10^(bandParams0.amp/20.);
       amp=round(amp,4,'significant');
       bandParams=struct('amplitude', amp, 'fc_low', bandParams0.fleft*1000, 'fc_high', bandParams0.fright*1000);
       stimStruct.bands{i}=bandParams; 
       
    end
end

