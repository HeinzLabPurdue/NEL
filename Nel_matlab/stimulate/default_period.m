function period = default_period(stm_duration)
%

% AF 11/12/01

if (stm_duration > 500)
   %   period = 500*(round(stm_duration*2/500)+1);
   % Changed: 7/31/02: MH/EDY 
   period = stm_duration*2;
elseif (stm_duration >= 100 )
   period = 1000;
elseif (stm_duration >= 50 )
   period = 250;
elseif (stm_duration >= 25 )
   period = 100;
else
   period = 50;
end   
