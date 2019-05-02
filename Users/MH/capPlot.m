function capThresholdSPL=capPlot(picNum,calibPicNum)

srWindow=[0 0.006];
drWindow=[0.0075 0.0135];
thresh_mag=10;
capWavesYes=1; %produce a figure plotting the CAP waveforms

x=loadpic(picNum);
xx=loadpic(calibPicNum);
capData=x.AD_Data.AD_Avg_V;
gain=x.AD_Data.Gain;
sf=x.Stimuli.RPsamprate_Hz;
t=0:1/sf:1/sf*(length(capData{1,1})-1);
srWindowInds=find(t>=srWindow(1) & t<=srWindow(2));
drWindowInds=find(t>=drWindow(1) & t<=drWindow(2));
[stims,attens]=size(capData);
atten=x.Stimuli.atten_dB;
stimFreq=x.Stimuli.RunLevels_params.audiogramFreqs;

maxY=0;
arb=0;
for attenNow=1:attens
	for stimNow=1:stims
		workingCap=capData{stimNow,attenNow};
		workingCap=workingCap/gain*1e6; % uVolts
		workingCap=butter_filt(workingCap,sf,100,4,'high');
		maxY=max([maxY max(abs(workingCap))]);
		capAmp(stimNow,attenNow)=max(workingCap(1,drWindowInds))-min(workingCap(1,drWindowInds));
		capNull(stimNow,attenNow)=max(workingCap(1,srWindowInds))-min(workingCap(1,srWindowInds));
		arb=arb+1;
		capAmp2(1,arb)=max(workingCap(1,drWindowInds))-min(workingCap(1,drWindowInds)); %for mean and std
		capNull2(1,arb)=max(workingCap(1,srWindowInds))-min(workingCap(1,srWindowInds)); %for mean and std
		capData{stimNow,attenNow}=workingCap;
	end
end
%meanNull=mean(capNull2);
%stdvNull=std(capNull2);
%thresh_mag=meanNull+2*stdvNull;



for stimNow=1:stims   %calculate threshold
	ABRmag(1:attens,1)=-atten';
	ABRmag(1:attens,2)=capAmp(stimNow,:)';
	ABRmag(1:attens,3)=capNull(stimNow,:)';
	ABRmag(1:attens,4)=thresh_mag;
	ABRmag=sortrows(ABRmag,1);
	yes_thresh = 0;
	for index = 1:attens-1,
		if (ABRmag(index,2) <= thresh_mag) & (ABRmag(index+1,2) >= thresh_mag), %find points that bracket 50% hit rate
			pts = index;
			yes_thresh = 1;
		end
	end
	if yes_thresh,
		hi_loc  = ABRmag(pts,  1);
		lo_loc  = ABRmag(pts+1,1);
		hi_resp = ABRmag(pts,  2);
		lo_resp = ABRmag(pts+1,2);
		slope  = (thresh_mag - lo_resp) / (hi_resp - lo_resp);
		capThreshold(stimNow) = slope * (hi_loc - lo_loc) + lo_loc;
		capThresholdSPL(stimNow) = CalibInterp(stimFreq(stimNow)/1000,xx.CalibData)+capThreshold(stimNow);
	else
		capThreshold(stimNow) = NaN;
		capThresholdSPL(stimNow) = NaN;
	end
end



if x.Stimuli.clickYes==1  %stimulus names
	stimNames{1,1}='click';
	nColumns=2; nRows=ceil(attens/2);
else
	stimNames{1,1}=[num2str(x.Stimuli.freq_hz) 'HzTone'];
	nColumns=2; nRows=ceil(attens/2);
end
if x.General.runAudiogram==1
	for i=1:stims
		stimNames{1,i}=[num2str(stimFreq(1,i)) 'HzTone'];
		nColumns=stims; nRows=attens;
	end
end

if capWavesYes==1
	figure(888); clf;
	thePlot=0;
	for attenNow=1:attens
		
		for stimNow=1:stims
			thePlot=thePlot+1;
			subplot(nRows,nColumns,thePlot);
			plot(t,capData{stimNow,attenNow},'k-',[srWindow(1) srWindow(1)],[-500 500],':r',...
				[srWindow(2) srWindow(2)],[-500 500],':r',[drWindow(1) drWindow(1)],[-500 500],':b',...
				[drWindow(2) drWindow(2)],[-500 500],':b');
			set(gca,'Ylim',[-maxY maxY],'Xlim',[min(t) max(t)]);
			if attenNow==1
				title(stimNames{stimNow});
			end
			if stimNow==1 | x.General.runAudiogram ~= 1
				ylabel([num2str(atten(attenNow)) 'dBatten'])
			end
		end
	end
end

figure(777); clf;

if x.General.runAudiogram == 1
	nSubPlots=stims+1; nColumns=2;
else
	nSubPlots=stims; nColumns=1;
end
nRows=ceil(nSubPlots/nColumns);
thePlot=0;
for stimNow=1:stims
	thePlot=thePlot+1;
	subplot(nRows,nColumns,thePlot);
	plot(-atten,capAmp(stimNow,:),'.k-',-atten,capNull(stimNow,:),'.b',...
		[-120 capThreshold(stimNow) 0],[1 1 1]*thresh_mag,':r*');
	set(gca,'Ylim',[0 maxY*2]);
	title(stimNames{stimNow});
	xlabel('dB atten'); ylabel('CAP amplitude (uV)');
	text(-110,maxY*1.75,[num2str(capThresholdSPL(stimNow),'%10.1f') 'dBSPL']);
end
if x.General.runAudiogram==1
	subplot(nRows,nColumns,thePlot+1);
	semilogx(stimFreq/1000,capThresholdSPL,'b*-');
	title('CAP Audiogram');
	set(gca,'Ylim',[0 80],'Xlim',[0.25 10],'XTick',stimFreq/1000);
	xlabel('Stimulus frequency (kHz)');	ylabel('dB SPL');
end