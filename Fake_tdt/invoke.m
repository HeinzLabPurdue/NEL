function varargout = invoke(varargin)
%

% AF 11/8/01

global Trigger fake_tdt_block_start

if (0)
   fprintf('FAKE_TDT: invoke(')
   for i = 1:nargin
      switch (class(varargin{i}))
      case 'char'
         fprintf('%s,', varargin{i});
      case 'double'
         if (length(varargin{i} == 1))
            fprintf('%1.2f,', varargin{i});
         else
            fprintf('%s,', inputname(i));
         end
      end
   end
   fprintf(');\n');
end


if (nargin >1)
   switch (varargin{2})
   case 'GetTagType'
      switch (varargin{3})
      case {'Stage', 'CurN'}
         varargout{1} = 'I';
         
      end
      
   case 'GetTagVal'
      switch (varargin{3})
      case {'Stage' 'CurN'}
         time_re_block = etime(clock, fake_tdt_block_start)*1000;
         index    = time_re_block / (Trigger.params.StmOn+Trigger.params.StmOff);
         time_re_line  = (index-floor(index)) * (Trigger.params.StmOn+Trigger.params.StmOff);
         index         = floor(index)+1;
         if (index > Trigger.params.StmNum)
            index = 1;
            stage = 0;
         else
            if (time_re_line <= Trigger.params.StmOn)
               stage = 1;
            else
               stage = 2;
            end
         end
         curN = Trigger.params.StmNum - index+1; 
         switch (varargin{3})
         case 'Stage'
            varargout{1} = stage;
         case 'CurN'
            varargout{1} = curN;
         end
         
      end
      
   case 'SetTagVal'
      switch (varargin{3})
      case {'StmOn' 'StmOff' 'StmNum'}
         Trigger.params  = setfield(Trigger.params, varargin{3}, varargin{4});
      end
      
   case 'SoftTrg'
      if (varargin{3} == 1)
         fake_tdt_block_start = clock;
      end
      
   end
end
if (exist('varargout','var') ~= 1)
   varargout = {};
end
for i = length(varargout)+1:nargout
   varargout{i} = 1;
end
      

