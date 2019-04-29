function useRate_Hz = NI6052UsableRate_Hz(requestedRate_Hz)
% MH/GE 04Nov2003.

% GE debug 10Nov2003: get max update rate from a "d2a.c" call:
% Maximum rate allowed for Eseries NI boards is 20e6/2
% GE debug 08Apr2004: Max rate needs to checked in case of 2 channel output: max rate is then 1/2 of 
%   rate usable for single channel output????
MAX_DAC_UPDATE_RATE_HZ=20e6/60;  % says 333Ksps/sec in NIDAC 6052E manual specifications (MH/GE 07Nov2003)
requestedRate_Hz = min([MAX_DAC_UPDATE_RATE_HZ requestedRate_Hz]);

% Get valid update rate for NI6052e board by calling d2a.c in mode 3.  We want the computation done in
%  only one place, so this matlab wrapper function calls the board implementation code ("d2a.c") directly.

[dummy1 dummy2 useRate_Hz] = d2a(3, requestedRate_Hz);   % dummy1 and dummy2 are status and retVal codes.

% The computation in d2a.c is equivalent to the following:
%boardUpdateRate_Hz = 20e6;  % assumes that board is called in 20MHz update mode (see "d2a.c")
%useRate_Hz = boardUpdateRate_Hz/(round(boardUpdateRate_Hz/requestedRate_Hz))

%#% MH/GE 05Nov2003: 
%#  used the following code to show that discrepancy at Fs=100kHz is less than 1/128-octave,
%#  and resolution (in octaves) gets better at lower sampling frequencies
% lowRate_Hz = boardUpdateRate_Hz/(ceil(boardUpdateRate_Hz/requestedRate_Hz));
% highRate_Hz = boardUpdateRate_Hz/(ceil(boardUpdateRate_Hz/requestedRate_Hz)-1);
% disp(num2str(log2(highRate_Hz/lowRate_Hz)))