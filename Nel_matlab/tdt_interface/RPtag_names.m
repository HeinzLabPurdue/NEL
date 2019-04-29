function tags = RPtag_names(X)
%

% AF 25/10/01


if (isfield(X,'activeX') == 0)
   nelerror('RPtag_names: No ''activeX'' field','RPtag_names');
   return;
end

ntags = double(invoke(X.activeX,'GetNumOf','ParTag'));
tags = cell(1,ntags);
for i = 1:ntags
   tags{i} = invoke(X.activeX,'GetNameOf','ParTag',i);
end
