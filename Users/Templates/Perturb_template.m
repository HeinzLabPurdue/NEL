function varargout = Perturb_template(varargin)
%

% AF 12/6/01
global signals_dir lraf_TF_flag__ %lr_list_unit_str

lraf_TF_flag__ = 'PERTURB';
if (nargout)
   [varargout{1:nargout}] = feval('CheckerBoard_template',varargin{:}); 
else
   feval('CheckerBoard_template',varargin{:}); % FEVAL switchyard
end
% lraf_TF_flag__ = 'CB';