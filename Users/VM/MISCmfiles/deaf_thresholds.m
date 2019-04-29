% FILE: deaf_thresholds.m
%
% To track thresholds and Q10 during deafcat experiment

clear

MaxdBSPL=120;

% [ BF (kHz) thresh_atten Q10 SR ]
data=[
.5 90 2 75
.5 80 2 10
.5 70 2 .3
1 90 4 75
1 80 4 10
1 70 4 .3
4 90 6 75
4 80 6 10
4 70 6 .3
8 90 9 75
8 80 9 10
8 70 9 .3
];


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
load normema.mat

thresh_HSR=data(find(data(:,4)>=18),1:2)
thresh_MSR=data(find((data(:,4)<18)&(data(:,4)>=0.5)),1:2)
thresh_LSR=data(find(data(:,4)<.5),1:2)
    
Q10_HSR=data(find(data(:,4)>=18),1:2:3)
Q10_MSR=data(find((data(:,4)<18)&(data(:,4)>=0.5)),1:2:3)
Q10_LSR=data(find(data(:,4)<.5),1:2:3)

    
figure(11); clf
subplot(311)
semilogx(thresh_HSR(:,1),MaxdBSPL-thresh_HSR(:,2),'x')
hold on
semilogx(thresh_MSR(:,1),MaxdBSPL-thresh_MSR(:,2),'s')
semilogx(thresh_MSR(:,1),MaxdBSPL-thresh_LSR(:,2),'^')
semilogx(normt(1,:),normt(2,:),'k')
ylabel('Threshold (roughly dB SPL)')
xlabel('Frequency (kHz)')
title(sprintf('Based on Max dB SPL = %.f dB SPL',MaxdBSPL))
xlim([.1 10])

subplot(312)
semilogx(Q10_HSR(:,1),Q10_HSR(:,2),'x')
hold on
semilogx(Q10_MSR(:,1),Q10_MSR(:,2),'s')
semilogx(Q10_MSR(:,1),Q10_LSR(:,2),'^')
ylabel('Q10')
xlabel('Frequency (kHz)')
xlim([.1 10])

subplot(313)
[Nunits,fbins]=hist(data(:,1),50)
semilogx(fbins,Nunits,'*')
xlabel('Frequency (kHz)')
ylabel('# Units')
xlim([.1 10])

