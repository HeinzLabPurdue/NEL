%% FIle: testQstep.m
%
% to test Qsteps

clear

frqhi=10000; 
frqlo=100;

Nlog=20;
NQ=9;

octaves = log2(frqhi/frqlo);
linstps = Nlog;
logstps = Nlog;

frqlstLOG=logspace(log10(frqhi),log10(frqlo),octaves*logstps);
frqnumLOG = length(frqlstLOG);
frqlstLIN=linspace(frqhi,frqlo,octaves*linstps);
frqnumLIN = length(frqlstLIN);
frqlstQ=Qspace(frqhi,frqlo,NQ);
frqnumQ = length(frqlstQ);


BW=8.8308*frqlstQ.^(0.5292);
for i=1:frqnumQ
   freq=frqlstQ(i);
   NQact3(i)=length(find((frqlstQ>=freq)&(frqlstQ<=(freq+BW(i)))));
   NQact2(i)=length(find((frqlstQ>=(freq-BW(i)/2))&(frqlstQ<=(freq+BW(i)/2))));
   NQact1(i)=length(find((frqlstQ>=(freq-BW(i)))&(frqlstQ<=freq)));
end
   
   
figure(1); clf
subplot(211)
plot(frqlstLOG,'r')
hold on
plot(frqlstLIN,'b')
plot(frqlstQ,'g')
hold off
ylabel('Frequency (Hz)')
subplot(212)
semilogy(frqlstLOG,'r')
hold on
semilogy(frqlstLIN,'b')
semilogy(frqlstQ,'g')
hold off
ylabel('Frequency (Hz)')

figure(2); clf
semilogx(frqlstQ,NQact1,'y-*',frqlstQ,NQact2,'g-x',frqlstQ,NQact3,'r-o')
hleg=legend('<f','f+-BW/2','>f');
set(hleg,'Position',[0.621339 0.384127 0.171735 0.125],'Units','norm')
