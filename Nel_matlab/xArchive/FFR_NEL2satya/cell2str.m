 function [s] = cell2str(cs,delim)
 % [s] = cell2str(cs,delim);
 %
 % Takes a cell array filled with strings and returns a concatenation in a
% single string. If delimiter is specified, it separates the individual strings
% with the delimiter.
 %
 % This function is useful in conjunction with sprintf statements
 %
 
 % 4/23/03 Petr Janata

 if nargin < 2
   delim = '';
 end
 
 s = '';
 nelem = length(cs);
 
 for ic = 1:(nelem-1)
  s = eval(['sprintf(''%s%s' delim ''',s,cs{ic})']);
 end
 
 s = sprintf('%s%s', s, cs{end});
 
 return