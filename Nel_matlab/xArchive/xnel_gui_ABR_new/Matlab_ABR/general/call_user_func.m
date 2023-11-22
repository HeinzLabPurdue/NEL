function varargout = call_user_func(func_name,varargin)
%

% AF 8/24/01

rc = 1;
varargout = cell(1,nargout);
if (nargout > 0)
   eval(['[varargout{:}] = ' func_name '(varargin{:});'], 'rc=0;');
else
   eval([func_name '(varargin{:});'], 'rc=0;');
end
if (rc==0)
   waitfor(errordlg(['call_user_func: Error in evaluation of ''' func_name ''': ' lasterr]));
end
