function varargout = RPget_params(X,varargin)
%

% AF 23/8/01

if (isfield(X,'activeX') == 0)
   nelerror('RPset_params: No ''activeX'' field');
   return;
end
if (nargin == 1) % get the params from the X structure
   if (isfield(X,'params_in') == 0)
      nelerror('RPget_params: No ''params_in'' field');
      return;
   end
   if (isstruct(X.params_in))
      for f = fieldnames(X.params_in)'
         val = do_invoke(X.activeX, f{1});
         eval(['X.params_in.' f{1} ' = val;']);
      end
      varargout{1} = X;
   end
else
   i = 2;
   while (i <= nargin)
      varargout{i-1} = do_invoke(X.activeX, varargin{i-1});
      i = i+1;
   end
end
return

%%%%%%%%%%  S U B   F U N C T I O N S  %%%%%%%%%%%
function val = do_invoke(actvX, tagname)
%

rc = 1;
tag_type = char(invoke(actvX,'GetTagType',tagname));
switch (tag_type)
case {'I', 'L', 'S'}
   val = double(invoke(actvX, 'GetTagVal', tagname));
case 'D'
   sz  = invoke(actvX,'GetTagSize',tagname);
   val = invoke(actvX,'ReadTagV',tagname,0,sz);
otherwise
   rc = 0;
end
if (rc == 0)
   nelwarn(['RPget_params: can not get ''' tagname '''']);
end
      

   
