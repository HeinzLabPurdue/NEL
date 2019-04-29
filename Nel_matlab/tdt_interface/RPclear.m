function rc = RPclear(X)
%

% AF 17/9/01

rc = 1;
for i = 1:length(X)
    if (isfield(X,'rco_file') == 0)
        nelerror('RPclear: No ''rco_file'' field');
        rc = 0;
        return;
    end
    X(i).rco_file = '';
end

