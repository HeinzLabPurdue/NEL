function rc = RPload_rco(rco_fnames)
% RPload_rco   Loads rco_files to the appropriate RP devices and clears RP.params
%
%      Usage: rc = RPload_rco(rco_fnames)
%                   where rco_fnames is cell array of strings.
%
%      Example:  RPload_rco({[],'d:\blabla\bla.rco'});
%                  loads 'bla.rco' to the second RP, and load the default_rco
%                  (currently 'control.rco') to the first RP. 
%
%                RPload_rco('d:\blabla\bla.rco');
%            or
%                RPload_rco({'d:\blabla\bla.rco'});
%                  loads 'bla.rco' to the first RP, and load the default_rco to the second

% AF 9/21/01

global RP default_rco

if (~iscell(rco_fnames))
   rco_fnames = {rco_fnames};
end
for i = 1:length(RP)
   if ((i > length(rco_fnames)) | isempty(rco_fnames{i}))
      RP(i).rco_file = default_rco;
   else
      RP(i).rco_file = rco_fnames{i};
   end
   RP(i).params = []; %% unCommented out - AF 11/26/01
end
rc = RPprepare;