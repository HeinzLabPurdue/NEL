function stim_info=mark_stim_invalid(stim_info,string)
% File: markSTIMinvalid.m
% MGH: 7/18/02
%
% marks all fields in a stim_info structure with NaN's and 'XXXX's (w/ length preserved) or string passed
% Used from data_aquisition_loop when stimulus detected as INVALID (e.g., not loaded in time)
% or to set the default to all 'XXXXX's
%
% stim_info must be a 1x1 structure

if(length(stim_info)~=1)
   nelerror('Unable to mark_STIM_invalid because passed stim_info was not 1x1');
else
   fnames=fieldnames(stim_info);
   for i=1:length(fnames)
      if iscell(getfield(stim_info,fnames{i}))  % Cell array of strings
         [Nj,Nk]=size(getfield(stim_info,fnames{i}));
         for j=1:Nj
            for k=1:Nk
               if (exist('string','var'))
                  stim_info=setfield(stim_info,fnames{i},{j,k},{string});
               else
                  stim_info=setfield(stim_info,fnames{i},{j,k}, ...
                     {repmat('X',1,length(char(getfield(stim_info,fnames{i}))))});
               end
            end
         end
      else  %% Otherwise assume numeric matrix
         [Nj,Nk]=size(getfield(stim_info,fnames{i}));
         stim_info=setfield(stim_info,fnames{i},NaN*ones(Nj,Nk));
      end
   end
end
