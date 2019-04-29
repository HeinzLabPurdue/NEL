function [error] = setlab

% This function:
%	1) Sets switches in lab interface if this is the 1st call (isinit ~= 0)
%	2) Computes next frequency and sets in digital oscillator
%	3) Adjusts filter settings in lock-in
%	4) Checks that lock-in amp is locked into new frequency.

% Inputs:
%     isinit ~= 0 to initialize all lab switches.  Must be done first
%	     time called, after that set only to change ears, etc.  Not
%	     reset in this.
%     ndpnts - index of next frequency to be presented.  Starts at 0 for
%	     frqlo.
%     frqlst - last frequency presented, kHz.  If current frequency
%	     equals frqlst after being set in digital oscillator,
%	     this routine will skip to the next frequency.
%     Other inputs are stimulus parameters, entered as global parameters

% Returns:
%     ndad - internal counter used to advance ndpnts in frequency comput.
%	     (see comfrq()).
%     rfreq - reference frequency returned by lock-in.  NOTE: afreq is
%	      a more accurate measure of the actual frequency!
%     iatnn - actual attenuation used (+dB)
%     ierror = -1 - whole frequency range covered, i.e. afreq>frqhi.
%		    NOTHING IS SET IN THIS CASE.  Stimuli are turned off.
%	     = 0 - O.K.
%	     = 1 - lock-in not locked-in.  Perhaps ref. is not conn.?
%		   OR freq set in oscillator is more than erfmax away
%	 	   from frequency acquired by lock-in.
%	     = 2 - error in lab system hardware
%	     = 3 - error setting params in lock-in.
%	     = 4 - ^C abort
% Exits with stimulus turned on if all is O.K.  Exits with stimulus off
% and SR530 gain set to minimum (500 mV) if error or finished.

% If this is first time, configure TDT system.  iear=1 for LE, 2 for RI.
% Connect dig.osc. to channel being used, other channel is off.
% Set attenuators for first frequency.

global FIG Stimuli COMM FREQS

error = 0;
no_ref = 0;
no_lock = 0;

if FREQS.isinit == 1,
   getatn;
   [error] = make_tone;
   attenuator(Stimuli.ear,0);
end

% Compute next stimulus frequency. 
% On first trial, initialize ndad. Set freq. into digital oscillator. If this
% frequency equals previous, advance to next by incrementing ndad.  If new freq
% is beyond frqhi, return done flag (ierror=-1) and exit, WITHOUT CHANGING SETTINGS.
if ~error & ~length(get(FIG.push.stop,'userdata'))
   if FREQS.ndpnts <= 0, FREQS.ndad = 0; end
   comfrq;
   if FREQS.freq <= Stimuli.frqhi
      FREQS.ndad = FREQS.ndad + 1;
      invoke(COMM.handle.RP2_2,'SetTagVal','freq',FREQS.freq*1000);
      getatn;
      attenuator(Stimuli.ear+2,FREQS.atnn);
      invoke(COMM.handle.RP2_1,'SoftTrg',1);
   else
      error = -1; 
      set(FIG.ax2.ProgMess,'String','Finished collecting data.');
      return
   end
   
   % Set up notch and bandpass filters in lock-in.
   if FREQS.freq >= Stimuli.bplo & FREQS.freq<=Stimuli.bphi,
      fprintf(COMM.handle.SR530,'%s\n','B1')     % set bandpass filter
      fprintf(COMM.handle.SR530,'%s\n','B')
      resp = fscanf(COMM.handle.SR530,'%d');
      if resp ~=1, error=1; end
   else
      fprintf(COMM.handle.SR530,'%s\n','B0')
      fprintf(COMM.handle.SR530,'%s\n','B')
      resp = fscanf(COMM.handle.SR530,'%d');
      if resp ~=0, error=1; end
   end
   
   if ~error
      if FREQS.freq >= Stimuli.n60lo & FREQS.freq<=Stimuli.n60hi,
         fprintf(COMM.handle.SR530,'%s\n','L1,1')     % set 1x filter
         fprintf(COMM.handle.SR530,'%s\n','L1')
         resp = fscanf(COMM.handle.SR530,'%d');
         if resp ~=1, error=1; end
      else
         fprintf(COMM.handle.SR530,'%s\n','L1,0')
         fprintf(COMM.handle.SR530,'%s\n','L1')
         resp = fscanf(COMM.handle.SR530,'%d');
         if resp ~=0, error=1; end
      end
   end
   
   if ~error
      if FREQS.freq>=Stimuli.n120lo & FREQS.freq<=Stimuli.n120hi,
         fprintf(COMM.handle.SR530,'%s\n','L2,1')     % set 2x filter
         fprintf(COMM.handle.SR530,'%s\n','L2')
         resp = fscanf(COMM.handle.SR530,'%d');
         if resp ~=1, error=1; end
      else
         fprintf(COMM.handle.SR530,'%s\n','L2,0')
         fprintf(COMM.handle.SR530,'%s\n','L2')
         resp = fscanf(COMM.handle.SR530,'%d');
         if resp ~=0, error=1; end
      end
   else
      set(FIG.ax2.ProgMess,'String','SETLAB: Not communicating with lock-in!');
      return
   end
   
   % Everything should be set up.  Wait briefly and then check that
   % lock-in is locked in (unless suppressed).  stbyte() gets status
   % byte from lock-in.  Bits 2 and 3 should be off, if the lock-in has
   % groked the reference signal.  Once the lock-in is locked, does it have
   % the correct frequency?
   % The wait is done in 100 msec chunks, for up to 10 seconds (nleft):
   display_message = sprintf('%s%6.3f%s\n%s','Frequency:',FREQS.freq,' kHz','(Getting lock)');
   set(FIG.ax2.ProgMess,'String',display_message);
   for i=1:100,
      if length(get(FIG.push.stop,'userdata')), return; end
      timer(.01);
      no_ref = 0;
      no_lock = 0;
      fprintf(COMM.handle.SR530,'%s\n','Y2')				        % check ref status bit (=0, if not ref)
      resp = fscanf(COMM.handle.SR530,'%d');
      if resp == 1, no_ref = 1; end
      fprintf(COMM.handle.SR530,'%s\n','Y3')				        % check ref status bit (=0, if not ref)
      no_lock = fscanf(COMM.handle.SR530,'%d');
      if no_ref == 0 & no_lock == 0
         display_message = sprintf('%s%6.3f%s\n%s','Frequency:',FREQS.freq,' kHz','(Aquired lock)');
         set(FIG.ax2.ProgMess,'String',display_message);
         return;
      end
      drawnow;
   end
   
   % Error exits. Close com port and TDT interface.
   if no_ref == 1 | no_lock == 1
      error=2;
      set(FIG.ax2.ProgMess,'String','SETLAB: Has failed to lock!');
   end
end
