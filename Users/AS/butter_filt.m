function [filt_signal,b,a]=butter_filt(signal,fs,f,order,type)

fn=fs/2;
wn=f/fn;
if (wn>=1)
	wn=0.998;
end	
[b,a]=butter(order,wn,char(type));
%freqz(b,a,512,fs);

filt_signal=filtfilt(b,a,signal);