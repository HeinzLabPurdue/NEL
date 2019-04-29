function [error] = srgain

% Function adjusts gain of Lock-in to largest value that doesn't
% give overload.  Simplified algorithm: assumes gain is O.K., turns
% gain down if overload.  Does not check if gain is too small (see
% SRDAQ() for this).

% Input:
%	igprd - predicted gain.  Starts with this.  Usually this is
%		gain at previous frequency.

% Outputs:
%	igain - new gain (can be same variable as igprd)
%	error  = 2 overload at lowest gain DON'T PROCEED
%	       = 0 if O.K.

global COMM FIG FREQS

error = 0;

igmin = 4;
igmax = 24;
nread = 4;
FREQS.gain = min(igmax, max(igmin, FREQS.gprd));
% ---> Start of gain loop <---
% Set current gain, check:
display_message = sprintf('%s%6.3f%s\n%s','Frequency:',FREQS.freq,' kHz','(Checking gain)');
set(FIG.ax2.ProgMess,'String',display_message);

while ~length(get(FIG.push.stop,'userdata'))
   strcom = sprintf('%c%d','G',FREQS.gain);
   fprintf(COMM.handle.SR530,'%s\n',strcom)
   fprintf(COMM.handle.SR530,'%s\n','G')
   resp = fscanf(COMM.handle.SR530,'%d');
   if resp ~=FREQS.gain
      set(FIG.ax2.ProgMess,'String','SRGAIN: Not communicating with Lock-In!');
      return
   end
   timer(0.01);
   overload = 0;
   % Read the overload status byte nread times.  If set any one of these,
   % this is an overload.
   for j=1:nread,
      fprintf(COMM.handle.SR530,'%s\n','Y4')				        % check ref status bit (=0, if not ref)
      overload = fscanf(COMM.handle.SR530,'%d');
      if overload
         if FREQS.gain < igmax,
            FREQS.gain = FREQS.gain + 1;
            display_message = sprintf('%s%6.3f%s\n%s','Frequency:',FREQS.freq,' kHz','(Adjusting gain)');
            set(FIG.ax2.ProgMess,'String',display_message);
            break
         else
            error = 2;
            set(FIG.ax2.ProgMess,'String','Overload error generated');
            return
         end
      end
   end
   
   if ~overload
      display_message = sprintf('%s%6.3f%s\n%s','Frequency:',FREQS.freq,' kHz','(Gain set)');
      set(FIG.ax2.ProgMess,'String',display_message);
      return
   end
   
   drawnow;
   
end


