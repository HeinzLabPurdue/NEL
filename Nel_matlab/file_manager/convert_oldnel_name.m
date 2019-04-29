function convert_oldnel_name(oldname)


startp = findstr('_p',oldname);
if (~isempty(startp))
   i = startp+2;
   while ((i<=length(oldname)) & ~isnan(str2double(oldname(i))))
      i = i+1;
   end
   if (oldname(i) == '_' | ~isnan(str2double(oldname(i))))
      endp = i;
      extra_ = '';
      unit   = oldname(1:startp);
   else
      endp = i-1;
      extra_ = '_';
      unit   = oldname(1:startp-1);
   end
   newname = [oldname(startp+1) '0' oldname(startp+2:endp) extra_ unit oldname(endp+1:end)];
   dos(['rename ' oldname ' ' newname]);
end