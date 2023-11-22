function res = nan_equal(a,b,dim)
%

% AF 16/10/01

if (exist('dim','var') ~= 1)
   dim = 1;
end
res = all( (isnan(a) & isnan(b)) | (a==b) ,dim);