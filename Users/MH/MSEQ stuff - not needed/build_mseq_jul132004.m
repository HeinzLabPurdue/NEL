function [successfulbuild,y,act_dur_ms,act_frame_dur]=build_mseq(freq,frame_dur,order,varargin)

% This is the function I used for the 7/15/04 experiment.  It calculates the actual_frame_dur incorectly -
% off by a fraction of a sample.  build_mseq.m now does things correctly.  I will have to make fake pics to
% save the 7/15/04 data - essentially just recalculate the actual frame duration.


% USAGE:  [successfulbuild,y,act_dur_ms,act_frame_dur]=build_mseq(freq[kHz],frame_dur[msec],order,{write directory})
% USES: generate_binmseq.m
%
% This program will build a tone at frequency freq (in kHz) modulated by an m-sequency of order 'order'.
% Each bit of the m-sequence will correspond to a stimulus time of frame_dur (in msec).  Note that frame_dur
% will be adjusted to the nearest half-cycle of the tone, so that it is as close to zero as possible when the
% frame ends, and that the tone always starts at zero sin-phase inside an 'on' phase.  
%
% successfulbuild is a flag that indicates if everything executed, y is the output file.  If you want this
% program to write the .wav file, simply input a write directory.   The blank string '' will write the file
% to the current directory.  

if nargin>3
    writeflag=1;
    sigdir=varargin{1};
else
    writeflag=0;
end
fs=97656.25;
successfulbuild=1;
act_frame_dur=round(frame_dur*2*freq)/2/freq;
act_dur_ms=act_frame_dur*2^order;
frame_dur_samps=floor(act_frame_dur/1000*fs);
dur_samps=2^order*frame_dur_samps;

tempfreqstr=num2str(freq);
freqstr=strrep(tempfreqstr,'.','pt');
tempframedurstr=num2str(frame_dur);
framedurstr=strrep(tempframedurstr,'.','pt');
orderstr=num2str(order);

if ~isequal(sigdir,'')
   filename=[sigdir filesep 'mseq' freqstr 'kHz_f' framedurstr '_o' orderstr '.wav'];
else
   filename=['mseq' freqstr 'kHz_f' framedurstr '_o' orderstr '.wav'];
end

fn=dir(filename);
if ~isempty(fn) % We've already built one of these, just read it and return
   [y,sr]=audioread(filename);
   if ~isempty(y) & round(sr)==round(fs) % sampling rates are equal, we're done!
      return
   end
end
% If we get this far, we need to generate m-sequence from scratch.
y=zeros(dur_samps,1);
m=generate_binmseq(order);
ton=.99*sin(2*pi*freq*1000*[1:order*frame_dur_samps]/fs);
tonplace=0;
for i=1:2^order
    if m(i)==1
        y(frame_dur_samps*(i-1)+1:frame_dur_samps*i)=ton(tonplace+1:tonplace+frame_dur_samps);
        tonplace=tonplace+frame_dur_samps;
    else % Reset tonplace so that when we get to an 'on' portion, tone starts in phase
        tonplace=0;
    end
end

if writeflag
    try
        wavwrite(y,fs,16,filename);
    catch
        successfulbuild=0;
    end
end

return