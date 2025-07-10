
function [samtone,fs,filename]=amtone_LF(fc,fm,M)

%x=(1+Msin 2pifmt)cos 2pifct

% fc=1500;
% fm=10;

% if (nargin <4)
%     C=1;
% end
fs=81900;%81920;



%T=1/fm;
%t = [0:T*fs]'/fs;
t = [0:(1.2*fs)-1]'/fs;
wc=2*pi*fc;
wm=2*pi*fm;

%y=C*(1+M*sin (wm*t)).*cos (wc*t);
y=(1+M*sin (wm*t)).*sin (wc*t);

%Y=C*cos(wc*t)+(M/2)*(sin((wc+wm)*t)+sin((wm-wc)*t));


% x=sin(2*pi*fm*t);
% y = modulate(x,fc,fs,'am');

 %Y=(1+M*sin (2*pi*fm*t)).*cos (2*pi*fc*t);
filename=sprintf('SAMtone_CF%0.3f_MD%0.4f_fm%0.4f.wav',fc/1000,M,fm/1000);
%RMS=sqrt(mean(y.^2));
% samtone=(y*(10^(level/20)*20e-6))/RMS;

samtone=y/max(abs(y))*0.99; %changed on 06/25/2007 

% y2=y/max(y);
% y2(find(y2>=1))=0.95*y2(find(y2>=1));
% y2(find(y2<=-1))=-0.95*y2(find(y2<=-1));
% samtone=y2;



