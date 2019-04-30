function varargout = actxcontrol(varargin)
%

% AF 11/8/01

fprintf('FAKE_TDT: actxcontrol(')
for i = 1:nargin-1
   fprintf('%s,', inputname(i));
end
fprintf('%s);\n', inputname(nargin));

for i = 1:nargout
   varargout{i} = 0;
end