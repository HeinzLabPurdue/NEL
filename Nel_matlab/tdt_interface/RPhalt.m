function rc = RPhalt(X)
%

% AF 17/9/01

rc = 1;
for i = 1:length(X)
    if (isfield(X,'activeX') == 0)
        nelerror('RPhalt: No ''activeX'' field');
        rc = 0;
        return;
    end
    if (invoke(X(i).activeX,'Halt') == 0)
        nelerror(['RPhalt: Can not Halt RP #' int2str(X(i).serial)]);
        rc = 0;
    end
end

