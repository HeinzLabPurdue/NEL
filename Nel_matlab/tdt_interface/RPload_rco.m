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
% for i = 1:length(RP)
for i = 1:2 % SP (5.25.21): 2 instead of length(RP) because only top 2 RP2s control are needed for sound playing 
    % RP2 #3 and 4 if present are handled outside during data collection
    % (e.g., in the function run_invCalib)
   if ((i > length(rco_fnames)) | isempty(rco_fnames{i}))
      RP(i).rco_file = default_rco;
   else
      RP(i).rco_file = rco_fnames{i};
   end
   RP(i).params = []; %% unCommented out - AF 11/26/01
end
rc = RPprepare;