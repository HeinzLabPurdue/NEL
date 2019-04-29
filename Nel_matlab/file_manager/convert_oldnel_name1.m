function convert_oldnel_name1(oldname)


startp = findstr('_p',oldname);
pic = sscanf(oldname,'p%d_%s');
if (~isempty(pic))
   newname = sprintf('p%04d_%s',pic(1),char(pic(2:end)'));
   dos(['rename ' oldname ' ' newname]);
end