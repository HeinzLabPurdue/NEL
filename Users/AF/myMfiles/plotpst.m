function [currentbin, binwidth, nspikes]=plotpst(sptimes,nspikes,nbins,f0,spwindow)

% binwidth=0.00001;  % 10 microseconds
% f0=100;
% T0=1/f0;
% nbins=T0/binwidth;    %calculate the no. of bins

inds=find((sptimes>spwindow(1))&(sptimes<=spwindow(2)));
sptimes=sptimes(inds);
nspikes=length(sptimes);
if (nargin <4)
    f0=100;
end

if (nargin <3)
    nbins=256;
    f0=100;
end

%f0=100;
T0=1/f0;
binwidth=T0/nbins;
%binwidth= 3.9063e-005;

for i=1:nspikes
    if (sptimes(i)> T0)
        newsptime=mod(sptimes(i),T0);
        if (newsptime==0)
            sptimes(i)=T0;          %put it into 10 ms bin
        else
            sptimes(i)=newsptime;
        end    
    end
end    

previous=0;
%for i=1:1000
for i=1:nbins
    time= binwidth*i;
    count=find(sptimes<=time);
    ntotalsp=length(count);
    currentbin(i)=ntotalsp-previous;
    previous=ntotalsp;
end

% t=linspace(0,T0,length(currentbin));
% t=linspace(0,T0,nbins);
% figure; plot(t,currentbin); grid on;
% xlabel('time(ms)');
% ylabel('no. of spikes');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%figure; plot(t,p_currentbin); grid on;
%hold on; plot(t,currentbin); grid on;
