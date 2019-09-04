% Subroutine to get acoustic calibration file necessary to correct
% for microphone/probe tube characteristics.  This version will work
% with either PDP-11 or JJR(PC) format files.

% Calibration data stored in cdata as ordered quadlets:
%    cdata(:,1) - freq
%    cdata(:,2) - dBSPL
%    cdata(:,3) - RMS voltage 
%    cdata(:,4) - phase
% where RMS voltage is the output of the probe tube, microphone, and preamp
% ensemble at the given frequency (kHz) and dB SPL.  To correct a dB voltage
% from the same equipment to dB SPL,
%	dB SPL = dB voltage - RMS voltage + dBSPL
% To correct the phase, add phase to the phase reading.
% This file created by program MICCAL.FOR and is stored as MICnnn.CAL,
% where nnn is the mic identifying number (nmic); should be last 3 digits
% of serial number (for B&K mics) or any 3 digits for other mics, but should
% uniquely identify the microphone/probe tube/preamp combination.  NOTE:
% 000 SHOULD NOT BE USED AS A MIC NUMBER, SINCE IT IS THE NUMBER USED IF
% THERE IS NO CALIBRATION.
% Frequencies should be in ascending order.


%function [cdata,ndat,error] = gtsplc(NMIC)

% Where
%     nmic   - string with number of microphone - NOTE: this value may change if the
%	       value at entry cannot be used to open a valid calibration file.

% Returns
%     cdata  - array to hold calibration data
%				   col 1 = frequencies in kHz
%     			col 2 = SPL values in dB
%     			col 3 = RMS voltage values read
%     			col 4 = normalized phase values
%     ndat   - number of ordered quadlets read from calibration file
%     error  - 0 if O.K.
%	          - 1 if calib file can't be opened, set nmic to 0

% Define data arrays
cdata = zeros(300,4);
error = 0;
% Open calibration file
fname = strcat('mic',NMIC,'.m');
fid = fopen(fname,'rt');   

% Read header lines and check that file is actually microphone calib.
% file.  Use contents of second line (format in PDP-11 files, 'Version . .
% in JJR(PC) files) to identify file type.  isjjr=0 (PDP-11) or 1 (JJR-PC).
% PDP-11 files may have first line empty.
if fid == -1,
	% Handle errors in calibration file.  Most likely, is no file or file
	% is corrupted.
	set(h_text7,'String','Microphone file didn''t open.');
	NMIC = '000';
	error = 1;
else
   isjjr = 0;
   while 1,
   	if strncmp(fgetl(fid),'Microphone Calibration File',27)
			isjjr = 1;
			break;
		end
	end
	if ~isjjr, 
		% Calibration file is not in jjr format.
		set(h_text7,'String','Microphone file has wrong format.');
		NMIC = '000';
		error = 1;
	end
end

if ~error,
	line = fgetl(fid); %ignore format lines
	line = fgetl(fid); %ignore probe mic data
	line = fgetl(fid); %ignore field mic data
	line = fgetl(fid); %ignore header for data columns	
	
	ndat = 0;
	while 1     % Loop to read data until end of file is reached
		[line] = fgetl(fid);
		if ~isstr(line), break, end
		ndat = ndat + 1;
 		cdata(ndat,1) = str2num(line( 1:10));
		cdata(ndat,2) = str2num(line(11:20));
		cdata(ndat,3) = str2num(line(21:30));
		cdata(ndat,4) = str2num(line(31:40));
	end

	if ndat < 3,    % Check that at least three lines have been read
		set(h_text7,'String','Error reading microphone file.');
		error = 1;
	end
end
fclose(fid);
