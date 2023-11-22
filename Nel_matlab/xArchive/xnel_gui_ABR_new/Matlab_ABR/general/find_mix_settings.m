function [select,connect,PAattns] = find_mix_settings(attns)
% find_mix_settings finds a combination of select, connect and attenuation values to route 
%              the desired RP channels at the requested attenuations to the speakers. 
%
%       [select,connect,PAattns] = find_mix_settings(attns)
%              where attns is a nx2 matrix that describe the speakers input 
%              and n is the number of possible devices (currently 9).
%              The device order is:  L6  L3  R6  R3  KH-oscilator RP1-ch1 RP1-ch2 RP2-ch1 RP2-ch2
%       Example:  [select,connect,PAattns] = find_mix_settings([[NaN NaN NaN NaN NaN 40 40 20 20]' [NaN NaN NaN NaN NaN 40 40 20 20]'])
%              will retrn the select, connect and attenuation parameters for connecting both channels of RP1 to
%              both speakers at attenuation of 40 dB and both channels of RP2 to both speakers at attenuation 
%              of 20 dB. The result will be:
%              select = [1 1], connect = [3 3], PAattns = [20 0 20 20]'.
%       Usage:
%                 [select,connect] = SBfind_route([ [0 1 1 0 0]' [1 0 0 0 0]' ]);
%                 rc = SBset(select,connect);
%
%       See also: SBset, PAfind_attns


% AF 9/3/01

min_i = -1;
min_pre_attn = Inf;
if (all(isnan(attns)))
   warndlg('Are you sure you don''t want to hear anything?','find_mix_settings');
end
[select,connect] = SBfind_route(~isnan(attns));
for i = 1:length(select)
   PAattns{i} = PAfind_attns(attns,select{i},connect{i});
   if (~isempty(PAattns{i}))
      pre_attn = sum(PAattns{i}(1:2));
      if (pre_attn < min_pre_attn)
         min_pre_attn = pre_attn;
         min_i = i;
      end
   end
end
if (min_i > 0)
   select = select{min_i};
   connect = connect{min_i};
   PAattns = round(100*PAattns{min_i})/100;
else
   select = [];
   connect = [];
   PAattns = [];
end
