function varargout = RssStd_template(varargin)
%

% AF 12/6/01
global signals_dir lraf_TF_flag__

lraf_TF_flag__ = 'STD';
if (nargout)
   [varargout{1:nargout}] = feval('CheckerBoard_template',varargin{:}); 
else
   feval('CheckerBoard_template',varargin{:}); % FEVAL switchyard
end
% lraf_TF_flag__ = 'CB';