function [R, p] = Rtest(currentbin,nspikes,nbins,f);


T=1/f;
t=linspace(0,T,nbins);
theta=t*2*pi/T;   %convert t to phase angle in radians
%figure; polar(theta,currentbin);
sumx=0; sumy=0;
i=1;
for j=1:length(currentbin)
    x_component(j)=currentbin(j)*cos (theta(j));
    y_component(j)=currentbin(j)*sin (theta(j));
end;
xn=sum(x_component);
yn=sum(y_component);
cn=sqrt(xn^2+yn^2);
R=cn/nspikes; cn_phase=atan(yn/xn);

p=2*nspikes*(R^2); % Raleigh statistic.

