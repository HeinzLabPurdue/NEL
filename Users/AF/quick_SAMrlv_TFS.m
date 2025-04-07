function [BML,BML_ind,Rate_sps,R,level]=quick_SAMrlv_TFS(picnum,calibpic,yesplot)


y=loadPic(calibpic);
calib_freq=y.CalibData(:,1);
calib_level=y.CalibData(:,2);
nbins=64;
%for i=1:length(n)
	x=loadPic(picnum);
	level=x.Stimuli.attens;%SAM
	lines=x.Line.attens.list(:,2); %SAM
	spt=x.spikes{1};
	spcount_per_line=spt(:,1);
	spt=spt(:,2);
	fm=x.Stimuli.condition.Modfrequency; fm=fm*1000;
	reps=x.Stimuli.repetitions;
	m=x.Stimuli.condition.Moddepth;
	fc=x.Stimuli.condition.Carrfreq;
	used_level=CalibInterp(fc,y.CalibData);
    fc=fc*1000;

	T0=1/fm;
	t=linspace(0,T0,nbins);
	%figure('Position',[50 100 950 650]);

	
	spwindow=[0.01,x.Hardware.Trigger.StmOn/1000];

	MAXPST =-999;

	for j=1:length(level)
		
		I1=find(ismember(lines,level(j)));%find on which presentation line a particular attennuastion level is presented
		I2=find(ismember(spcount_per_line,I1));%find all the spikes that occurred in response to that presentation
		sptime=spt(I2);
		nspikes=length(sptime);
		[currentbin, binwidth, nspikes]=plotpst(sptime,nspikes,nbins,fc,spwindow);

		MAXPST = max([MAXPST max(currentbin)]);

% 		subplot(4,5,j); plot(t,currentbin,'b'); grid on;
% 		ylabel('no. of spikes'); xlabel('time(sec)');
% 		xlim([0 T0])

		l2=used_level-level(j);
% 		title(strcat('SPL=',num2str(l2)));

		[R(j,1), R(j,2)]=Rtest(currentbin,nspikes,nbins,fc);

		Rate_sps(j) = nspikes/diff(spwindow)/length(I1);
	end

	% Same Ylimit for all plots
	% 	for j=1:length(level)
	% 		subplot(4,5,j)
	% 		ylim([0 MAXPST])
	% 	end

% 	subplot(4,5,j+1); plot((used_level-level),R(:,1)); grid on;
	% 	hold on;
	% 	plot((used_level-level),Rate_sps/max(Rate_sps),'r');
    %ldbSPL=(used_level-level);

    [sort_R sort_R_ind]=sort(R(:,1),'descend');
    if sort_R_ind(1)==1
        BML=sort_R(2);
    else
        BML=sort_R(1);  
    end
    r=find(R(:,1)==BML);
    BML_ind=r;
    if yesplot
        figure(102); clf; plot(level,R(:,1),'b'); grid on;
        hold on; plot(level(r),BML,'r*');
        ylim([0 1]);
        xlim([-15 100]);
        set(gca,'XTick',[-10:20:100],'Xdir','rev');
        ylabel('synch. R'); xlabel('dB atten');
        title(sprintf('TFS tone rate level function fm %0.4f, fc %0.2f, m %0.2f',fm/1000,fc,m));
    end
%     BML=level(r);
if numel(level)>=6

    BML=level(6);
else
    BML=level(end);
end
	

% 	title(sprintf('fm=%.2f,fc=%.2f,m=%.2f, %d reps,%d',fm,fc,m,reps,n(i)));
% 	clear R; clear sptime; clear Rate_sps
% 	clear level; clear lines; clear I1; clear I2;
% end

