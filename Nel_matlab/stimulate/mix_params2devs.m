function devs = mix_params2devs(mix,devices)
%

% AF 11/13/01

desc = fieldnames(mix);
devs = [nel_devices_vector([]) nel_devices_vector([])];

for i = 1:length(desc)
   speakers = [NaN NaN];
   switch (lower(getfield(mix,desc{i})))
   case 'left'
      speakers = [1 NaN];
   case 'right'
      speakers = [NaN 1];
   case 'both'
      speakers = [1 1];
   end
   these_devs = nel_devices_vector(getfield(devices,desc{i}));   
   these_devs = [speakers(1)*these_devs speakers(2)*these_devs];
   devs = max(devs,these_devs);
end
   
   