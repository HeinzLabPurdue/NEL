function ding
% DING  plays the MS ding.wav (as Matlab's 'beep' except that ding WORKS)

% AF 11/30/01

global DING__ DINGSR__

if (isempty(DING__))
   if (exist('c:\winnt\media\ding.wav','file')==2)
      [DING__ DINGSR__] = audioread('c:\winnt\media\ding.wav');
   else
      if (exist('c:\windows\media\ding.wav','file')==2)
         [DING__ DINGSR__] = audioread('c:\windows\media\ding.wav');
      end
   end
end

try
   soundsc(DING__,DINGSR__);
catch
   beep;
end