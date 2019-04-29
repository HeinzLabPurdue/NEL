function varargout = CompResamp_template(varargin)
%

% AF 12/6/01
global signals_dir lr_list_bf_str lraf_RESAMP_flag__

lraf_RESAMP_flag__ = 'COMP';
if (nargout)
   [varargout{1:nargout}] = feval('LR_resamp_template',varargin{:}); 
else
   feval('LR_resamp_template',varargin{:}); % FEVAL switchyard
end
% lraf_TF_flag__ = 'CB';