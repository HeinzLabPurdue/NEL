function [error] = Calspl(iseq)
% Modified for TDT system at Purdue
% July 20, 2006
% M. Heinz/J. Swaminathan
%
% Calibration file:
% CDATA:  column 1 is frequency in kHz.
%         column 2 is SPL at which probe microphone calibration data was taken.
%         column 3 is phase correction, phase = phase from lockin + column 3.
%			    (note, no unwrapping has been done.)
%         column 4 is phase correction (if we had one)
%
% dBSPL measured = 20*log10(RMS_V/1uV) - ProbeCalibData(col3) + dBSPL for ProbeCalibData(col2)

%%%%%%%%%%%%%% OLD SR530 %%%%%%%%%%%%%%%%%%%%
% Subroutine to compute sound pressure level from voltage data collected
% by the SR530 lockin amplifier.
%	Modified for behavioral systems on 10/13/1999 by BJM

% Program expects a four column calibration data arrays (JJR format):
% These correct for probe, microphone, and amplifier characteristics.
% There should be one such file for each microphone/probe/amplifier
% combination (called MICxxx.CAL).  These data are loaded by subroutine
% GTSPLC() called exterior to this.
%	CDATA(:,1) - frequencies, kHz at which calibration data taken
%	CDATA(:,2) - dB SPL at corresp. cfreq() and cdbvolt() for the
%		microphone and probe tube.
%	CDATA(:,3) - 20*log10(volts rms) from probe microphone in calib.
%		run.
%	CDATA(:,4) - phase correction for probe system.
%	ncdim - number of points in calibration arrays

% With these data, the SPL corresponding to a given RMS voltage rmag from
% the probe microphone can be determined as
%	COMM.SRdata.dbspl = 20*log10(rmag) + CDATA(:,2) - CDATA(:,3)
% RMS voltages are provided to this subroutine in dB form, i.e. as
% 20*log10(rmag).  Note that correction for attenuator settings must be
% done externally.  The calibration file data are expected to be corrected
% to apply at 0 dB attenuation.
%
% The phase correction is applied as below.  Phases are represented
% in units of PI radians (e.g. phase = 0.5 corresponds to 90 degrees).
%	phase = rph + cphase

% Inputs:
%	CDATA calibration arrays as above
%	ndat - number of points in each calibration array
%	iseq - index at which search for frequency freq is started in
%		calibration arrays.
%	ddata(:,1) - frequency of data to convert to SPL, kHz
%	rmag - 20*log10(RMS voltages) to convert
%	rphs - phase of signal, units of PI radians

% Outputs:
%	COMM.SRdata.dbspl() - corrected signal magnitude (may be same as rmag())
%	ophs() - corrected phase (may be same as rphs())
%	error = 0 if O.K.
% 	      = 1 if ddata(:,1). can't be found in calibration array.  In this case,
%		       should not use the current point.

global FIG DDATA CDATA FREQS COMM SRdata

% Program looks for frequency freq(j) in calibration array CDATA(:,1), starting
% at CDATA(iseq,1).  If freq(j) doesn't match to within tolerance slop, i.e.
%	 abs(freq - CDATA(iseq,1))/freq < slop
% then calibration data are linearly interpolated.

% FUNCTIOM WORKS MUCH MORE EFFICIENTLY IF DATA IN freq() are in ascending
% order.


% Assign a slop value i.e. fractional diff between freq() and CDATA(:,1) that
% will be tolerated without interpolation.  NOTE: it doesn't make sense for
% this number to be larger than the ratio of successive freqs in the calib-
% ration file (typically 0.05-0.1 octave).
slop = .05;

% Assume no error to start, make sure iseq is within range.  iseq is
% pointer to calibration data.
out_of_range = 0;
error = 0;
if iseq < 1 || iseq > FREQS.ndat; iseq = 1; end

% Loop through all data:  j and j1 index data points.
% slop1 used to decide if current frequency is outside range of next
% calibration frequency.
slop1 = 1 / (1 + slop);

%   Find calibration frequency at or just below data frequency.  Assume that
%   a frequency match will be found (isntrp=0)
%   If frequency isn't found set out_of_range flag and break out of loop
thfreq = round(DDATA(FREQS.ndpnts,1)*1000)/1000;
isntrp = 0;
if thfreq < 0.01 || thfreq > 100.0, out_of_range = 1; end

if ~out_of_range
   while round(thfreq*1000)/1000 < round(CDATA(iseq,1)*1000)/1000
      if iseq <= 1, out_of_range = 1; break; end
      iseq = iseq - 1;
   end
end
%   Is frequency goes out of range in while loop, you'll need to break again
%   Is this frequency near enough a calibration frequency?
%   If not, then have to interpolate; is this frequency between CDATA(iseq,1)
%   and CDATA(iseq+1,1)?
if ~out_of_range
   if abs(thfreq-CDATA(iseq,1))/thfreq > slop
      if iseq < FREQS.ndat
         while thfreq >= slop1*CDATA(iseq+1,1) && iseq+1<FREQS.ndat
            iseq = iseq + 1;
         end
         isntrp = 1;
      end
   end
   %Current frequency matches CDATA(iseq,1) if isntrp=0 or is between
   %   CDATA(iseq,1) and CDATA(iseq+1,1) if isntrp=1.
   %   crmag and crphs are magnitude and phase correction.
   
   crmag = CDATA(iseq,2) - CDATA(iseq,3);
   crphs = CDATA(iseq,4);
   if isntrp
      factor = (thfreq - CDATA(iseq,1))/(CDATA(iseq+1,1) - CDATA(iseq,1));
      crmag = crmag + factor*(CDATA(iseq+1,2) - CDATA(iseq+1,3) - crmag);
      crphs = crphs + factor*(CDATA(iseq+1,4) - crphs);
   end
   COMM.SRdata.dbspl = DDATA(FREQS.ndpnts,2) + 120 + crmag;  % DDATA is in dBre1V, and we need dB re 1uV for mic*.m file
   COMM.SRdata.ophs = DDATA(FREQS.ndpnts,3) + crphs;
   
   %frequency is out of range, display error
else
   errmsg = sprintf('%s%10.5f%s','CALSPL: freq=',thfreq',' kHz is not in calib. table.');
   set(FIG.ax2.ProgMess,'String',errmsg);    
   COMM.SRdata.dbspl = DDATA(FREQS.ndpnts,2);
   COMM.SRdata.ophs = DDATA(FREQS.ndpnts,3);
   error = 1;
end
