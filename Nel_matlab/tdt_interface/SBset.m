function rc = SBset(select,connect)
%

% AF 8/24/01

global SwitchBox

if (isempty(select) | isempty(connect))
   % reset prev_params;
   for i = 1:length(SwitchBox)
      SwitchBox(i).prev_params.BitOut3_7 = -1;
   end
end

if (any(isnan(select)) | any(isnan(connect)))
   rc = -1;
   return;
end
if (length(select)~= length(SwitchBox) | length(connect)~= length(SwitchBox))
   rc = -2;
   return;
end

rc = 1;
for i = 1:length(SwitchBox)
   SwitchBox(i).params.BitOut3_7 = bitshift(select(i),3) + bitshift(connect(i),6);
   if (SwitchBox(i).params.BitOut3_7 ~= SwitchBox(i).prev_params.BitOut3_7)
      SwitchBox(i).prev_params.BitOut3_7 = SwitchBox(i).params.BitOut3_7;
      if (RPset_params(SwitchBox(i)) ~= 1)
         rc = 0;
      end
   end
end
   