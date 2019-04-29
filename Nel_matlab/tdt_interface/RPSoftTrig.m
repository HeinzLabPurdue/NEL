function rc = RPSoftTrig(X,number)
%

% AF 3/29/02

if (isfield(X,'activeX') == 0)
   nelerror('RPSoftTrig: No ''activeX'' field');
   return;
end

rc = invoke(X.activeX,'SoftTrg',number);