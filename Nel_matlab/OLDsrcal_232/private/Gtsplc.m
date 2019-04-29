function [error] = gtsplc
global Stimuli FIG CDATA FREQS SRdata

% Subroutine to get acoustic calibration file necessary to correct
% for microphone/probe tube characteristics.  This version will work
% with either PDP-11 or JJR(PC) format files.

% Calibration data stored in CDATA as ordered quadlets:
%    CDATA(:,1) - freq
%    CDATA(:,2) - dBSPL
%    CDATA(:,3) - RMS voltage 
%    CDATA(:,4) - phase
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



% Where
%     Stimuli.nmic   - string with number of microphone - NOTE: this value may change if the
%	       value at entry cannot be used to open a valid calibration file.

% Returns
%     CDATA  - array to hold calibration data
%				   col 1 = frequencies in kHz
%     			col 2 = SPL values in dB
%     			col 3 = RMS voltage values read
%     			col 4 = normalized phase values
%     ndat   - number of ordered quadlets read from calibration file
%     error  - 0 if O.K.
%	          - 1 if calib file can't be opened, set nmic to 0

% Define data arrays
error = 0;
% Open calibration file
data_file = strcat('mic',Stimuli.nmic,'.m');

command_line = sprintf('%s%s%c','[mic]=',strrep(lower(data_file),'.m',''),';');
eval(command_line);
FREQS.ndat   = length(mic.CalData);
SRdata.dBV   = mic.dBV;
SRdata.date  = mic.date;
CDATA(:,1:3) = mic.CalData;
