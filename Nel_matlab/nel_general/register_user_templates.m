function register_user_templates(template_def_struct)
% register_user_templates(template_def_struct)
%    template_def_struct is a structure that should contain pairs of template names (as the structure field names)
%    and their coresponding m-files (as the fields values).
%
%    Example:   register_user_template(struct('BF','my_bf_template', ...
%                                             'T2, 'my_two_tomes_template'))

% AF 11/28/01

global NelData

if (~isstruct(template_def_struct))
   nelerror('register_user_templates: Argument must be a structure');
   return;
end
tmplts = struct2cell(template_def_struct);
fnames = fieldnames(template_def_struct);
for i = 1:length(tmplts)
   xst = exist(tmplts{i},'file');
   if (xst <2 | xst >6)  % the name is NOT a matlab executable file
      nelerror([tmplts{i} ' is not a valid m-file. Check the file name or Matlab''s path']);
      template_def_struct = rmfield(template_def_struct,fnames{i});
   end
end
NelData.General.User_templates = template_def_struct;
    
      
   