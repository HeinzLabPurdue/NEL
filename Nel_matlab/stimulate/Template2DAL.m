function [DAL,vars,tmplt,units,errstr] = Template2DAL(tmplt_mfile,vars,units,fieldname)
% [DAL,vars,units,tmplt] = Template2DAL(tmplt_mfile,vars)

% AF 11/14/01

if (exist('fieldname','var') ~= 1)
   fieldname = '';
end
try
   % units  = [];
   % IO_def = [];
   if (exist('vars','var') ~= 1)
      tmplt  = feval(tmplt_mfile,fieldname);
      dflt = user_profile_get(tmplt.tag);
      if (isempty(dflt) | ~isstruct(dflt))
         dflt.Inloop = [];
         dflt.Gating = [];
         dflt.Mix =    [];
      end
      % merge user defaults with tmplt defaults. this enables addition or removal of tmplt fields 
      % without conflicts with the saved user profile.
      [vars.Inloop units.Inloop] = structdlg(tmplt.IO_def.Inloop,'',dflt.Inloop,'off');
      [vars.Gating units.Gating] = structdlg(tmplt.IO_def.Gating,'',dflt.Gating,'off');
      [vars.Mix    units.Mix   ] = structdlg(tmplt.IO_def.Mix,'',dflt.Mix,'off'); %%%%%
   end
   
   [tmplt,DAL,vars,units,errstr] = eval([tmplt_mfile '(fieldname,vars,units);']);
   
catch
   disp(['''' tmplt_mfile ''' : ' lasterr]);
   DAL.Inloop = [];
   DAL.Gating = [];
   DAL.Mix = [];
   vars = [];
   return;
end
