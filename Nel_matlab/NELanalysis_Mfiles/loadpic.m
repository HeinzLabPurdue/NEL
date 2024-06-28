function [x,errorMSG]=loadpic(picNum, prefix)
% function x=loadpic(picIND)
% Created: M. Heinz 18Mar2004
% Modified from GE version, 29Jul2004
%
% Loads picture based on picture number
global NelData
if ~exist('prefix', 'var')
    prefix= 'p';
end
if strcmp(NelData.Metadata.calib_type,'SPL')
    picSearchString = sprintf('%s%04d*.m', prefix, picNum);
elseif strcmp(NelData.Metadata.calib_type,'FPL')
    picSearchString = sprintf('%s%04d*.mat', prefix, picNum);
end
picMFile = dir(picSearchString);
errorMSG = '';
if isempty(picMFile)
    errorMSG = sprintf('Picture file p%04d*.m not found.', picNum);
    x = [];
    return;
elseif length(picMFile)>1
    errorMSG = sprintf('More than 1 file with this picture number (p%04d)', picNum);
    x = [];
    return;
else
    if strcmp(NelData.Metadata.calib_type,'SPL')
        eval(['x = ' picMFile.name(1:end-2) ';']);  % Load data for this picture
    elseif strcmp(NelData.Metadata.calib_type,'FPL')
        load([ picMFile.name ]);  % Load data for this picture
        % standardize FPL and SPL ear info
        if strcmp(x.FPLearData.ear, 'R') || strcmp(x.FPLearData.ear, 'r')
            x.FPLearData.ear = 'right';
        elseif strcmp(x.FPLearData.ear, 'L') || strcmp(x.FPLearData.ear, 'l')
            x.FPLearData.ear = 'left';
        end
    end
end
