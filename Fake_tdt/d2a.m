function [statCodes, retVals, actualUpdateRate_Hz] = d2a(mode, requestedRate_Hz, samplesMatrix)
% 10Feb2005 M.Heinz
% from msdl.m (fakeTDT)
%
% To allow d2a WAVfiles to be used with fakeTDT

switch (mode)
case 0
   statCodes=[0 0 0];
   retVals=[0 0 0];
   %    actualUpdateRate_Hz

case 1
   statCodes=[0 0 0];
   retVals=[0 0 0];
   boardUpdateRate_Hz = 20e6;  % assumes that board is called in 20MHz update mode (see "d2a.c")
   actualUpdateRate_Hz = boardUpdateRate_Hz./(round(boardUpdateRate_Hz./requestedRate_Hz));
   sound(samplesMatrix,actualUpdateRate_Hz)

case 2
   statCodes=[0 0 0];
   retVals=[0 0 0];
   %    actualUpdateRate_Hz

case 3
   statCodes=[0 0 0];
   retVals=[0 0 0];
   boardUpdateRate_Hz = 20e6;  % assumes that board is called in 20MHz update mode (see "d2a.c")
   actualUpdateRate_Hz = boardUpdateRate_Hz/(round(boardUpdateRate_Hz/requestedRate_Hz));
  
end
   
