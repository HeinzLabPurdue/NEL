function tc_data = TC_analysis(varargin)
if numel(varargin)==3
    PicNum=varargin{1};
    CALIBpic=varargin{2};
    PLOTyes=varargin{3};
    hstat=0;
elseif numel (varargin)==4
    PicNum=varargin{1};
    CALIBpic=varargin{2};
    PLOTyes=varargin{3};
    hstat=varargin{4};
end

% function tc_data = TC_analysis(PicNum,CALIBpic,PLOTyes)
% FILE: TC_analysis
% modified from: plotTCs on 09/09/2007
% Modified from : verifyBFQ10.m
% Usgae: [Thresh_dBSPL_ret,BF_kHz_ret,Q10_ret] =
% plotTCs(PIClist,CALIBpic,PLOTyes)
% Just a simple way to plot TCs from a given list of TC pics
%
% Modified on: 10May2007 M. Heinz for SAC_XAC Analysis
%
% Modified 11Feb2005 M. Heinz for NOHR Data
%
% Created 7/31/02: for choosing BF and verofying Q10
%
% 1) Picks BF & Threshold from actual data points
% 2) Generates a smoothed TC (without bias at BF) and saves as unit.tcdata(:,3)
% 3) Finds Q10 based on smoothed TC
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% if ~exist('PIClist')
%    % EXP:
%    PIClist = [63];
%    CALIBpic = 2;
%
%    % EXP: 110306
%    PIClist = [29 39 40 41 42 43 44 45 49];
%    CALIBpic = 2;
%
%
% end
global redflag
redflag=0;
if ~exist('PLOTyes','var')
	PLOTyes=1;
end
x=loadPic(PicNum);

%%% READ in Calib Data
xCAL=loadPic(CALIBpic);
CalibData = xCAL.CalibData(:,1:2);

% numTCs=length(PIClist);
% TrackUnit=getTrackUnit(getFileName(PIClist(1)));
% TRACK=TrackUnit(1);   UNIT=TrackUnit(2);

TFiltWidthTC=5;

if PLOTyes
	set(0,'DefaultTextInterpreter','none');
	set(0,'DefaultTextUnits','data')
	
	%colors = {'b','r','k','g','m','c','b','r','k','g','m','c'};
	h14=figure(14); clf;
	set(h14,'Position',[50 50 650 600])
	
	TextFontSize=9;
	DataMarkerSize=12;
	DataMarkStyle='.';
	DataFitStyle='-';
	
	xmin=0.03; xmax=39; ymin=-10; ymax=115;
	legtext='';
end

% for ind=1:numTCs
%    PICind=PIClist(ind);
%    x=loadPic(PICind);
TCdata=x.TcData;
TCdata=TCdata(find(TCdata(:,1)),:);   % Get rid of all 0 freqs
TCdata=TCdata(TCdata(:,2)~=x.Stimuli.file_attlo,:);  % Get rid of all 'upper atten limit points'
%% TCdata:
%     col 1: freq;
%     col 2: raw ATTENS;
%     col 3: raw dB SPL;
%     col 4: smoothed SPLS
for i=1:size(TCdata,1)
	TCdata(i,3)=CalibInterp(TCdata(i,1),CalibData)-TCdata(i,2);
end
TCdata(:,4)=trifilt(TCdata(:,3)',TFiltWidthTC)';

% store unit BF/Threshold based on min value (just for record)
[minThresh_dBSPL,loc]=min(abs(TCdata(:,4)));
minBF_kHz=TCdata(loc,1);

% Set unit BF/Threshold to picked (during EXPERIMENT) BF/Threshold
BF_kHz=x.Thresh.BF;
BookBF_kHz=BF_kHz;
Thresh_dBSPL=TCdata(TCdata(:,1)==BF_kHz,4);

% % %% Generate smoothed TC, but avoiding upward bias at BF (tip)
% % % Fits each side separately, and then sets equal to actual data point at BF
% % % i.e., smoothes sides (e.g., 10 dB up) without biasing threshold at BF upward
% % TCdata(1:loc,4)=trifilt(TCdata(1:loc,3)',TFiltWidthTC)';
% % TCdata(loc:end,4)=trifilt(TCdata(loc:end,3)',TFiltWidthTC)';
% % TCdata(loc,4)=TCdata(loc,3);

% pass smoothed tcdata for q10 calculation (based on actual data point at BF, and smoothed TC otherwise
% This avoids the bias in smoothing at the tip, i.e., raising threshold at BF
[Q10,Q10fhi,Q10flo,Q10lev] = findQ10(TCdata(:,1),TCdata(:,4),BF_kHz);
% [Q20,Q20fhi,Q20flo,Q20lev] = findQ(TCdata(:,1),TCdata(:,4),BF_kHz,20);
% [Q30,Q30fhi,Q30flo,Q30lev] = findQ(TCdata(:,1),TCdata(:,4),BF_kHz,30);
% [Q40,Q40fhi,Q40flo,Q40lev] = findQ(TCdata(:,1),TCdata(:,4),BF_kHz,40);


if PLOTyes
	%%%%% PLOT TUNING CURVE
	% 	  figure('Position',[20 50 500 450]);
	h_line1 = semilogx(TCdata(:,1),TCdata(:,3),DataMarkStyle,'MarkerSize',DataMarkerSize,'Color','b');
	hold on
	h_line2 = semilogx(TCdata(:,1),TCdata(:,4),DataFitStyle,'Color','k');
	if (length(Q10)>1)
		h_lineQ10lo=semilogx([Q10flo(1) Q10fhi],Q10lev*ones(1,2), ...
			'-','linewidth',2,'Color','b');
		h_lineQ10hi=semilogx([Q10flo(2) Q10fhi],Q10lev*ones(1,2), ...
			'-','linewidth',2,'Color','k');
	else
		h_lineQ10=semilogx([Q10flo Q10fhi],Q10lev*ones(1,2), ...
			'-','linewidth',2,'Color','b');
	end
	ylabel('dB SPL'); xlabel('Frequency (kHz)');
    if hstat==1
    title 'NORMAL';
    elseif hstat==2
        title 'IMPAIRED';
    end
	axis([xmin xmax ymin ymax]);
	set(gca,'YTick',[0 20 40 60 80 100])
	set(gca,'XTick',[.1 1 10],'XTickLabel',[.1 1 10])
	%title(sprintf('Unit: %d.%d; (Cal: P%d)',TRACK,UNIT,CALIBpic))
	if geomean(TCdata(:,1)) < 1
		Xtext=.55;
	else
		Xtext=.05;
	end
	% mark min and book BFs
	h_minTC = semilogx(minBF_kHz*ones(1,2),minThresh_dBSPL+[5 30],'m:','LineWidth',2);
	% 		text(.1,.2,'minTC','FontSize',TextFontSize,'Units','Norm','HorizontalAlignment','center','Color','m','units','data')
	text(minBF_kHz,minThresh_dBSPL+32,'minTC','FontSize',TextFontSize,'Units','Norm','HorizontalAlignment','center', ...
		'VerticalAlignment','bottom','Color','m','units','data')
	h_bookTC = semilogx(BF_kHz*ones(1,2),Thresh_dBSPL+[-5 -20],'g:','LineWidth',2);
	% 		text(.1,.1,'bookTC','FontSize',TextFontSize,'Units','Norm','HorizontalAlignment','center','VerticalAlignment','bottom','Color','c','units','data')
	text(BF_kHz,Thresh_dBSPL-22,'bookTC','FontSize',TextFontSize,'Units','Norm','HorizontalAlignment','center', ...
		'VerticalAlignment','top','Color','g','units','data')
	% 		legtext = sprintf('BF=%.3f kHz; Thr=%.1f dB SPL\nQ10=%.1f',BF_kHz,Thresh_dBSPL,Q10);
	% 		text(Xtext,0.1,legtext,'Units','norm','Color','k');
	BookBF_kHz=BF_kHz;
	
	% setup for user to pick
	pickThr = Thresh_dBSPL;
	pickBF = BF_kHz;
	
	text_str = sprintf('%s %6.3f %s\n%s %4.2f %s','BF:',pickBF,'kHz.','Thresh:',pickThr,'dB SPL');
	h_textBF= text(.05,.98,text_str,'Units','norm','FontSize',TextFontSize,'VerticalAlignment','top');
	h_pickBF=text(pickBF,pickThr,'\uparrow','Interpreter','tex','FontSize',16, ...
		'VerticalAlignment','top','HorizontalAlignment','center');
	
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%%% Loop to wait for verifying BF
	x15=get(h14,'Position');  % These commands insure mouse is over Figure so that cursor keys work
	set(0,'PointerLocation',x15(1:2)+[10 x15(4)/2])
	set(gcf,'CurrentCharacter','x')
	loc = find(TCdata(:,1)==pickBF);
	if isempty(loc)
		[yy,loc]=min(abs(TCdata(:,1)-pickBF));
		disp('unit.BF NOT chosen from data points')
		pickThr = TCdata(loc,4);
		pickBF = TCdata(loc,1);
		set(h_pickBF,'Position',[pickBF pickThr]);
		text_str = sprintf('%s %6.3f %s\n%s %4.2f %s','BF:',pickBF,'kHz.','Thresh:',pickThr,'dB SPL');
		set(h_textBF,'String',text_str);
	end
	
	while 1==1      % Wait for verifying BF to complete
		pause(.1)
		w = waitforbuttonpress;
		if w ~= 0   %%%%   ('Mouse-Button press')
			keypress=get(gcf,'CurrentCharacter');
			
			switch double(keypress)
				case 13  %%% 'RETURN'
					break;
				case 28  %%% 'LEFT cursor'
					loc=min(length(TCdata(:,1)),loc+1);
				case 29  %%% 'RIGHT cursor'
					loc=max(1,loc-1);
			end
		end
		
		pickThr = TCdata(loc,4);
		pickBF = TCdata(loc,1);
		% recompute Q10 from new threshold
		[Q10,Q10fhi,Q10flo,Q10lev] = findQ10(TCdata(:,1),TCdata(:,4),pickBF);
        [Q20,Q20fhi,Q20flo,Q20lev] = findQ(TCdata(:,1),TCdata(:,4),pickBF,20);
        [Q30,Q30fhi,Q30flo,Q30lev] = findQ(TCdata(:,1),TCdata(:,4),pickBF,30);
        [Q40,Q40fhi,Q40flo,Q40lev] = findQ(TCdata(:,1),TCdata(:,4),pickBF,40);
		
		set(h_pickBF,'Position',[pickBF pickThr]);
		if (length(Q10)>1)
			text_str = sprintf('%s %6.3f %s\n%s %4.2f %s\n%s %.1f','BF:', ...
				pickBF,'kHz.','Thresh:',pickThr,'dB SPL','Q10lo:',Q10(1),'Q10hi:',Q10(2));
		else
			
			text_str = sprintf('%s %6.3f %s\n%s %4.2f %s\n%s %.1f','BF:', ...
				pickBF,'kHz.','Thresh:',pickThr,'dB SPL','Q10:',Q10);
		end
		set(h_textBF,'String',text_str);
		% 			h_lineQ10=semilogx([Q10flo Q10fhi],Q10lev*ones(1,2),'-','linewidth',2,'Color',colors{mod(ind,7)+1});
		
		if (length(Q10)>1)
			if (~exist('h_lineQ10lo','var'))
				h_lineQ10lo=semilogx([Q10flo(1) Q10fhi],Q10lev*ones(1,2), ...
					'-','linewidth',2,'Color','b');
				h_lineQ10hi=semilogx([Q10flo(2) Q10fhi],Q10lev*ones(1,2), ...
					'-','linewidth',2,'Color','k');
			end
			set(h_lineQ10lo,'XData',[Q10flo(1) Q10fhi],'YData',Q10lev*ones(1,2));
			set(h_lineQ10hi,'XData',[Q10fhi(1) Q10fhi],'YData',Q10lev*ones(1,2));
		else
			if (~exist('h_lineQ10','var'))
				h_lineQ10=semilogx([Q10flo Q10fhi],Q10lev*ones(1,2), ...
					'-','linewidth',2,'Color','b');
			end
			set(h_lineQ10,'XData',[Q10fhi(1) Q10fhi],'YData',Q10lev*ones(1,2));
		end
		
	end  % End wait for verifying BF
	% Set unit BF/Threshold to picked BF/Threshold
	BF_kHz=pickBF;
	Thresh_dBSPL=pickThr;
	if (length(Q10)>1)
		legtext = sprintf('Final Values:\n BF=%.3f kHz; Thr=%.1f dB SPL\nQ10lo=%.2f, Q10hi=%.2f\nBWlo=%.2f, BWhi=%.2f', ...
			BF_kHz,Thresh_dBSPL,Q10(1),Q10(2),BF_kHz/Q10(1),BF_kHz/Q10(2));
	else
		legtext = sprintf('Final Values:\n BF=%.3f kHz; Thr=%.1f dB SPL\nQ10=%.2f\nBW=%.2f', ...
			BF_kHz,Thresh_dBSPL,Q10,BF_kHz/Q10);
	end
	
	if (Xtext>0.5)
		text(Xtext,0.90,legtext,'Units','norm','FontSize',TextFontSize,'Color','k')
	else
		text(Xtext,0.80,legtext,'Units','norm','FontSize',TextFontSize,'Color','k')
	end
end

%    if (strcmp(hearingtype,'impaired'))
% 	   if (Q10>=10)
% 		   reply=input('Do you want to recompute BW? y/n: ','s');
% 		   if (strcmp(reply,'y'))
% 			   BW_corrected=Q10fhi-min(TCdata(:,1));
% 		   else
% 			   BW_corrected=NaN;
% 		   end
% 	   else
% 		   BW_corrected=NaN;
% 	   end
%    else
% 	   BW_corrected=NaN;
%    end
%    if (~isnan(BW_corrected))
% 	   Q10_corrected=BF_kHz/BW_corrected;
%    else
% 	   Q10_corrected=NaN;
%    end
BW=BF_kHz./Q10;
Thresh_dBSPL_ret = Thresh_dBSPL;
BF_kHz_ret = BF_kHz;
Q10_ret = Q10;

if (redflag)
	BW_corrected=BW;
	Q10_corrected=Q10;
else
	BW_corrected=NaN;
	Q10_corrected=NaN;
end

%just for book-keeping store all the TC data for later use
tc_data.freq=TCdata(:,1);
tc_data.rawData=TCdata(:,3);
tc_data.smoothData=TCdata(:,4);

tc_data.TCdata=TCdata; %save all four columns (mainly for NOHR stuff)
tc_data.Book_BF=BookBF_kHz;

tc_data.Q10flo=Q10flo;
tc_data.Q10fhi=Q10fhi;
tc_data.Q10lev=Q10lev;
tc_data.Q10_ret=Q10_ret;
tc_data.Q10_corrected=Q10_corrected;
% tc_data.Q20flo=Q20flo;
% tc_data.Q20fhi=Q20fhi;
% tc_data.Q20lev=Q20lev;
% tc_data.Q20_ret=Q20;
% tc_data.Q30flo=Q30flo;
% tc_data.Q30fhi=Q30fhi;
% tc_data.Q30lev=Q30lev;
% tc_data.Q30_ret=Q30;
% tc_data.Q40flo=Q40flo;
% tc_data.Q40fhi=Q40fhi;
% tc_data.Q40lev=Q40lev;
% tc_data.Q40_ret=Q40;
tc_data.BF=BF_kHz_ret;
tc_data.Th=Thresh_dBSPL_ret;
tc_data.minBF_kHz=minBF_kHz;
tc_data.minThresh_dBSPL=minThresh_dBSPL;
tc_data.BW=BW;
tc_data.BW_corrected=BW_corrected;
tc_data.redflag=redflag;

%end
% hold off;


return;
