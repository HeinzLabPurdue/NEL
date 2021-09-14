function x = merge_structs(x,y,lower_case_only);
%

% AF 10/31/01

if (exist('lower_case_only','var') ~= 1)
   lower_case_only = 0;
end

if (isempty(y))
   return;
end
fy = fieldnames(y)';
if (~isempty(x))
   fx = fieldnames(x)';
else   
   fx = {};
end

if (lower_case_only)
   for f = fx
      if (~isempty(strmatch(lower(f{1}),lower(fy))))
         x = rmfield(x,f{1});
      end
   end
end

for f = fy
   eval(['x.' lower(f{1}) ' = y.' f{1} ';']);
end
