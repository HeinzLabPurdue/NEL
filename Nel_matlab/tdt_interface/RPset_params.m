function [rc,X] = RPset_params(X,varargin)
%

% AF 23/8/01

rc = 1;
if (length(X) > 1)
   for ii = 1:length(X)
      if (isempty(varargin))
         [lrc,X(ii)] = RPset_params(X(ii));
      else
         [lrc,X(ii)] = RPset_params(X(ii),varargin);
      end
      rc = rc & lrc;
   end
   return;
end
     
if (isfield(X,'activeX') == 0)
   nelerror('RPset_params: No ''activeX'' field');
   rc = 0;
   return;
end
if (nargin == 1) % get the params from the X structure
   if (isfield(X,'params') == 0)
      nelerror('RPset_params: No ''params'' field');
      rc = 0;
      return;
   end
   if (isstruct(X.params))
      for f = fieldnames(X.params)'
         eval(['val = X.params.' f{1} ';']);
         if (~isempty(val))
            if (do_invoke(X.activeX, f{1}, val) == 0)
               rc = 0;
            else
               eval(['X.params.' f{1} '=[];']);
            end
         end
      end
   end
else
   i = 2;
   while (i < nargin)
      rc = rc * do_invoke(X.activeX, varargin{i-1}, varargin{i});
      i = i+2;
   end
end
return

%%%%%%%%%%  S U B   F U N C T I O N S  %%%%%%%%%%%
function rc = do_invoke(actvX, tagname, tagval)
%
if (length(tagval) == 1)
   rc = invoke(actvX, 'SetTagVal', tagname, tagval);
else
   if (min(size(tagval)) == 1)
      rc = invoke(actvX, 'WriteTagV', tagname, 0, tagval);
   elseif (min(size(tagval)) == 2)  % AF - added on 4/3/2002 for sending comp16 data
      rc = invoke(actvX, 'WriteTagVEX', tagname, 0, 'I16', tagval);
   else
      rc = 0;
      nelwarn(['RPset_params: can not set matrix ''' tagname '''']);
   end
end
if (rc == 0)
   nelwarn(['RPset_params: can not set ''' tagname '''']);
end
rc = double(rc);
      
