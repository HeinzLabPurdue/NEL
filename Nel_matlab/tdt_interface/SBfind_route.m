function [select,connect] = SBfind_route(speaker_desc)
% SBfind_route finds all possible combinations of select and connect values to route 
%              the desired RP channels to the speakers. 'select' and 'connect' are cell arrays.
%              SBfind_route should not be used directly. Use 'find_mix_settings' to determine 
%              both the desired connections and attenuations of the PA's.
%
%       [select,connect] = SBfind_route(speaker_desc)
%              where speaker_desc is a nx2 binary matrix that describe the speakers input 
%              and n is the number of possible devices (currently 5).
%              The device order is:  KH-oscillator RP1-ch1 RP1-ch2 RP2-ch1 RP2-ch2
%       Example:  [select,connect] = SBfind_route([ [0 1 1 0 0]' [1 0 0 0 0]' ]);
%              will retrn the select and connect parameters for connecting both channels of RP1 to the
%              left speaker and the KH-oscillator to the right speaker.
%       Usage:
%                 [select,connect] = SBfind_route([ [0 1 1 0 0]' [1 0 0 0 0]' ]);
%                 rc = SBset(select{1},connect{1});
%
%       See also: find_mix_settings

% AF 9/3/01

global SwitchBox

sel_key1 = SwitchBox(1).select_key;
sel_key2 = SwitchBox(2).select_key;
sel_alt1 = SwitchBox(1).select_res;
sel_alt2 = SwitchBox(2).select_res;

con_key1 = SwitchBox(1).connect_key;
con_key2 = SwitchBox(2).connect_key;
con_alt1 = SwitchBox(1).connect_res;
con_alt2 = SwitchBox(2).connect_res;

select = {};
connect = {};
counter = 0;
for s1 = 1:size(sel_alt1,2)-1
   for s2 = 1:size(sel_alt2,2)-1
      for c1 = 1:size(con_alt1,2)
         res1 = con_alt1(2,c1)*sel_alt1(:,s1)  +  con_alt1(1,c1)*sel_alt2(:,s2);
         if (all(res1 == speaker_desc(:,1)))
            for c2 = 1:size(con_alt2,2)
               res2 = con_alt2(2,c2)*sel_alt1(:,s1)  +  con_alt2(1,c2)*sel_alt2(:,s2);
               if (all(res2 == speaker_desc(:,2)))
                  %% Match Found!
                  if (con_alt1(2,c1) + con_alt2(2,c2) == 0)
                     sel1 = sel_key1(end); % Ground!
                  else 
                     sel1 = sel_key1(s1);
                  end
                  if (con_alt1(1,c1) + con_alt2(1,c2) == 0)
                     sel2 = sel_key2(end); % Ground!
                  else 
                     sel2 = sel_key2(s2);
                  end
                  sel = [sel1 sel2];
                  con = [con_key1(c1) con_key2(c2)];
                  route_exist = 0;
                  for i = 1:counter
                     if (all(select{i}==sel) & all(connect{i}==con))
                        route_exist = 1;
                     end
                  end
                  if (~route_exist)
                     counter = counter+1;
                     select{counter}  = sel;
                     connect{counter} = con;
                  end
               end
            end
         end
      end
   end
end
