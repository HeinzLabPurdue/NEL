function strs = grep(fname,pattern)
%

% AF 9/23/01

buff = textread(fname,'%s','delimiter','\n','whitespace','');
strs = cell(size(buff));
counter = 0;
for i = 1:length(buff)
   if (~isempty(findstr(buff{i},pattern)))
      counter = counter+1;
      strs{counter} = buff{i};
   end
end
strs = strs(1:counter);
      