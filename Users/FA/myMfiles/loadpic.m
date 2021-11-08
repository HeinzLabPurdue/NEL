function x = loadpic(picNum, preFix)     % Load picture
if ~exist('preFix', 'var')
    preFix= 'p';
end
picSearchString = sprintf('%s%04d*.m', preFix, picNum);
picMFile = dir(picSearchString);
if (~isempty(picMFile))
   eval( strcat('x = ',picMFile.name(1:length(picMFile.name)-2),';') );
else
   error = sprintf('Picture file p%04d*.m not found.', picNum)
   x = [];
   return;
end
