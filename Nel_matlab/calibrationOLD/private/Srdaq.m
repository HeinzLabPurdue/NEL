function [error,converge] = srdaq

% Function to read complex data values from lock-in and average
% them until magnitude/(std.err.mean) exceeds a criterion.

% This routine assumes srgain() has set gain for no overload.  Reads
% data and checks for gain too small, i.e. |datum|<0.4*full scale.
% If so, resets gain and calls srgain() to check.

% Inputs:
%	crit - ratio (full scale voltage)/(std.err.mean) at which data
%	       are acceptable.
%	igain - current gain value.  Used to look-up full scale data
%	       value for crit test (also an output).

%Outputs:
%	igain - may be changed in this routine.  Is value of gain at exit.
%	[COMM.SRdata.rmag,COMM.SRdata.rph] - magnitude and phase of data.  Magnitude is in
%	       volts, phase in radians.
%	COMM.SRdata.sem - std. err. of mean of COMM.SRdata.rmag, in volts
% 	COMM.SRdata.ndata - number of data points in output average
%	error = 0 - O.K.
%	       =1 - data overload the lock-in A/D at this gain
%   converge = 0 - criterion not achieved after nmax iterations.

global COMM FIG FREQS Stimuli
%Initialize:
fulscl = [1e-8 2e-8 5e-8 1e-7 2e-7 5e-7 1e-6 2e-6 5e-6 1e-5 2e-5 5e-5 1e-4 2e-4 5e-4 1e-3 2e-3 5e-3 1e-2 2e-2 5e-2 1e-1 2e-1 5e-1];
restart = 1;
cycle   = 0;
while restart & ~length(get(FIG.push.stop,'userdata'))
   restart = 0;
   cycle = cycle + 1;
   igmin = 4;		% min gain for lock-in
   igmax = 24;		% max gain for lock-in
   COMM.SRdata.rmag =   0;
   COMM.SRdata.rph =    0;
   COMM.SRdata.sem =    0;
   xavg =   0;
   yavg =   0;
   rsqrd =  0;
   plot_pnts = zeros(50,2);
   fulls = fulscl(FREQS.gain);
   converge = 0;
   error = 0;
   if cycle == 5, break; end
   
   neltimer(0.01);
   fprintf(COMM.handle.SR530,'%s\n','QX')
   xval = str2num(fscanf(COMM.handle.SR530,'%s'));
   fprintf(COMM.handle.SR530,'%s\n','QY')
   yval = str2num(fscanf(COMM.handle.SR530,'%s'));
   
   % Compute magnitude of this reading.
   vmag = xval*xval + yval*yval;
   if vmag > 0, vmag = sqrt(vmag); end
   % Gain is too large, increase predicted gain setting.
   if vmag > 1.05*fulls,
      FREQS.gprd = FREQS.gain + 1;
      if FREQS.gprd > igmax,
         error = 1;
      else
         [error] = srgain;
         if error == 0,
            restart = 1;
         end
      end
      
      % Gain is too small, decrease predicted gain setting.   
   elseif vmag < 0.18*fulls,
      FREQS.gprd = FREQS.gain;
      while FREQS.gprd > igmin & vmag < 0.2*fulscl(FREQS.gprd)
         FREQS.gprd = FREQS.gprd - 1;
      end
      if FREQS.gprd < igmin,
         error = 3;
      else
         [error] = srgain;
         if error == 0,
            restart = 1;
         end
      end
   end
   
   if ~restart & ~error,
      for index = 1:50,
         COMM.SRdata.ndata = index;
         % Cumulate new data with previous data
         xavg = xavg + xval;
         yavg = yavg + yval;
         rsqrd = rsqrd + vmag*vmag;
         
         plot_pnts(COMM.SRdata.ndata,1) = xval*1000;
         plot_pnts(COMM.SRdata.ndata,2) = yval*1000;
         
         % If 3 datapoints, compute average and check quitting criterion:
         if COMM.SRdata.ndata >= 3,
            xval = xavg/COMM.SRdata.ndata;
            yval = yavg/COMM.SRdata.ndata;
            COMM.SRdata.rmag = xval*xval + yval*yval;
            COMM.SRdata.sem = max(0, (rsqrd - COMM.SRdata.ndata*COMM.SRdata.rmag)/((COMM.SRdata.ndata-1)*COMM.SRdata.ndata));
            if COMM.SRdata.sem > 0, COMM.SRdata.sem = sqrt(COMM.SRdata.sem); end
            if COMM.SRdata.sem <= fulls/Stimuli.crit,
               converge = 1;
               break;
            end
         end
         fprintf(COMM.handle.SR530,'%s\n','QX')
         xval = str2num(fscanf(COMM.handle.SR530,'%s'));
         fprintf(COMM.handle.SR530,'%s\n','QY')
         yval = str2num(fscanf(COMM.handle.SR530,'%s'));
         % Compute magnitude of this reading.
         vmag = xval*xval + yval*yval;
         if vmag > 0, vmag = sqrt(vmag); end
         drawnow;
         if length(get(FIG.push.stop,'userdata')), break; end
         end
      end
   end
   
   COMM.SRdata.rmag = sqrt(COMM.SRdata.rmag);
   COMM.SRdata.rph = -atan2(yval, xval);
   
   switch error
   case 0
      if converge
         lim1 = max([abs(min(plot_pnts(1:COMM.SRdata.ndata,1))) max(plot_pnts(1:COMM.SRdata.ndata,1)) abs(min(plot_pnts(1:COMM.SRdata.ndata,2))) max(plot_pnts(1:COMM.SRdata.ndata,2))]);
         lim  = ceil(lim1/9)*10;
         set(FIG.ax3.axes,'XLim',[-lim lim],'YLim',[-lim lim]);
         set(FIG.ax3.axes,'XTick',[-lim 0 lim],'YTick',[-lim 0 lim]);
         set(FIG.ax3.line1,'XData',plot_pnts(1:COMM.SRdata.ndata,1),'YData',plot_pnts(1:COMM.SRdata.ndata,2));
         drawnow;
      else
         set(FIG.ax2.ProgMess,'String','SRDAQ: Values do not converge.');
      end
   case 1
      set(FIG.ax2.ProgMess,'String','SRDAQ: Overload!');
   case 2
      set(FIG.ax2.ProgMess,'String','SRDAQ: Not communicating with lock-in!');
   case 3
      set(FIG.ax2.ProgMess,'String','SRDAQ: Signal too small!');
   end
