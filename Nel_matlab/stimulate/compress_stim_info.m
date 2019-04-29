function cmp_info = compress_stim_info(stim_info, block_info)
%

% AF 9/26/01

if (isempty(stim_info))
   cmp_info = [];
   return;
end
temp_info = rmfield(stim_info,'attens_devices');

% Find all devices that were in use at least once
devs = logical(zeros(size(stim_info(1).attens_devices,1),1));
for i = 1:length(stim_info)
   devs = devs | any(~isnan(stim_info(i).attens_devices),2);
end

cmp_info.attens = [];
for i = find(devs(:)')
   if (isempty(block_info.dev_description{i}))
      desc = ['dev' int2str(i)]; % In case the programmer fails to supply dev_description
   else
      desc = block_info.dev_description{i};
   end
   if (isfield(cmp_info.attens,desc))
      block_info.dev_description{i} = [block_info.dev_description{i} int2str(i)];
      desc = block_info.dev_description{i};
   end
   eval(['cmp_info.attens.' desc ' = repmat(NaN,length(stim_info),2);']);
end
      
for i = 1:length(stim_info)
   ind = find(any(~isnan(stim_info(i).attens_devices),2));
   for j = ind(:)'
      f = block_info.dev_description{j};
      vals = stim_info(i).attens_devices(j,:);
      eval(['cmp_info.attens.' f '(i,:) = vals;']);
   end
end

if (~isempty(temp_info))
   for f = fieldnames(temp_info)'
      if (length(getfield(temp_info(1),f{1})) == 1)
         eval(['cmp_info.' f{1} ' = [temp_info.' f{1} '];']);
      else
         eval(['cmp_info.' f{1} ' = {temp_info.' f{1} '};']);
      end
   end
end

      
