function plot_data_abr()

global 	han line_width abr_Stimuli reff

[pic] = ParseInputPicString_V2(abr_Stimuli.abr_pic_all);
num_of_pic_used_for_analysis=length(ParseInputPicString_V2(abr_Stimuli.abr_pic));
num=length(pic);

data=struct([]);

data(1).threshold=NaN; 
data.z.intercept=NaN; 
data.z.slope=NaN; 
data.z.score=NaN*ones(1,num); 
data.amp_thresh=NaN;
data.amp=NaN*ones(1,num); 
data.x=NaN*ones(8,num); 
data.y=NaN*ones(8,num); 
data.y_forfig=NaN*ones(8,num);
data.amp_null=NaN*ones(1,num);


%% Read all the ABR data
abr=[];
freqs=NaN*ones(1,num);
attn=NaN*ones(1,num);
hhh=dir(sprintf('a%04d*',pic(1)));
if exist(hhh.name,'file')
    for i=1:num
        fname=dir(sprintf('a%04d*',pic(i)));
        filename=fname.name(1:end-2);
        eval(['x=' filename ';'])
        freqs(1,i)=x.Stimuli.freq_hz;
        attn(1,i)=-x.Stimuli.atten_dB;
        abr(:,i)=x.AD_Data.AD_Avg_V(1:end-1)'-mean(x.AD_Data.AD_Avg_V(1:end-1)); % removes DC offset
    end
else
    for i=1:num
        fname=dir(sprintf('p%04d*',pic(i)));
        filename=fname.name(1:end-2);
        eval(['x=' filename ';'])
        freqs(1,i)=x.Stimuli.freq_hz;
        attn(1,i)=-x.Stimuli.atten_dB;
        if iscell(x.AD_Data.AD_Avg_V)
            abr(:,i)=(x.AD_Data.AD_Avg_V{1}(1:end-1)-mean(x.AD_Data.AD_Avg_V{1}(1:end-1)))'; % removes DC offset
        else
            abr(:,i)=x.AD_Data.AD_Avg_V(1:end-1)'-mean(x.AD_Data.AD_Avg_V(1:end-1)); % removes DC offset
        end
        
    end
end

dt=500/x.Stimuli.RPsamprate_Hz; %sampling period after oversampling

%% sort abrs in order of increasing attenuation
[aa, order]=sort(-attn);
abr2=abr(:,order);
attn=attn(:,order);
freqs=freqs(:,order);

abr3=-abr2/20000*1000000;% in uV, invert to make waveforms look "normal"
abr=resample(abr3,2,1); %double sampling frequency of ABRs
freq_mean=mean(freqs); 
abr_time=(0:dt:time_of_bin(length(abr)));

%% Determine SPL of stimuli
CalibFile  = dir(sprintf('p%04d_calib*',str2num(abr_Stimuli.cal_pic)));
% if ~exist(CalibFile, 'file')
%     CalibFile  = sprintf('p%04d_calib_raw',str2num(abr_Stimuli.cal_pic));
% end
command_line = sprintf('%s%s%c','[xcal]=',CalibFile.name(1:end-2),';');
eval(command_line);
freq_loc = find(xcal.CalibData(:,1)>=(freq_mean/1000));
freq_level = xcal.CalibData(freq_loc(1),2);
spl=freq_level+attn;

%% some variables for plotting abrs in abr_panel
pp_amp=zeros(1,num);
for i=1:num
    pp_amp(1,i)=max(abr(:,i))-min(abr(:,i));
end;
total_volts=sum(pp_amp(1,:));
total_padvolts=0.5*total_volts;
padvoltage=total_padvolts/num/2;

y_shift=zeros(1,num);
lower_y_bound=zeros(1,num);
upper_y_bound=zeros(1,num);
for i=1:num-1
    y_shift(1,i)=sum(pp_amp(1,i+1:num))+padvoltage*(2*num+1-2*i)+mean(abr(:,i))-min(abr(:,i));
    lower_y_bound(1,i)=sum(pp_amp(1,i+1:num))+padvoltage*(2*num-2*i);
    upper_y_bound(1,i)=sum(pp_amp(1,i:num))+padvoltage*(2*num+2-2*i);
end
y_shift(1,num)=padvoltage+(mean(abr(:,num))-min(abr(:,num)));
lower_y_bound(1,num)=0; 
upper_y_bound(1,num)=2*padvoltage+pp_amp(1,num);



%% abr panel
axes(han.abr_panel);
set(han.abr_panel,'NextPlot','Add');
set(han.abr_panel,'NextPlot','Add','XTick',[abr_Stimuli.start:1:abr_Stimuli.end],...
	'XGrid','on','YGrid','on','YTick',[0:0.5:total_volts+total_padvolts],'YTickLabel',[])
axis(han.abr_panel,[abr_Stimuli.start abr_Stimuli.end 0 total_volts+total_padvolts]);


%% clear out contents of all axes
set([han.abr_panel],'NextPlot','replacechildren');
axes(han.abr_panel); plot(0,0,'-w');

%% The red window
plot([abr_Stimuli.start_template abr_Stimuli.start_template abr_Stimuli.end_template abr_Stimuli.end_template...
    abr_Stimuli.start_template],[upper_y_bound(1,1)-padvoltage lower_y_bound(1,1)+padvoltage lower_y_bound(1,1)+padvoltage...
    upper_y_bound(1,1)-padvoltage upper_y_bound(1,1)-padvoltage],'-r','LineWidth',line_width); 

for i=1:num
    if i<=(num-num_of_pic_used_for_analysis)
        plot(abr_time,abr(:,i)+y_shift(1,i),'-k',[abr_Stimuli.start abr_Stimuli.end],[upper_y_bound(1,i) upper_y_bound(1,i)],'-k',...
            'LineWidth',line_width); 
        hold on
    else 
        plot(abr_time,abr(:,i)+y_shift(1,i),'-r',[abr_Stimuli.start abr_Stimuli.end],[upper_y_bound(1,i) upper_y_bound(1,i)],'-r',...
            'LineWidth',line_width); 
        hold on
    end
    text(abr_Stimuli.start+(abr_Stimuli.end-abr_Stimuli.start)*0.01,upper_y_bound(1,i)-0.5*padvoltage,num2str(spl(i),'%10.1f'),...
        'fontsize',10,'horizontalalignment','left','VerticalAlignment','middle','color','b')
    text(abr_Stimuli.start+(abr_Stimuli.end-abr_Stimuli.start)*0.15,upper_y_bound(1,i)-0.5*padvoltage,...
        ['(' num2str(-attn(i),'%10.1f') ')'],'fontsize',10,'horizontalalignment','left','VerticalAlignment','middle','color','k')
    if get(han.cbh,'Value')==get(han.cbh,'Max') & ~isempty(reff)
        for ii=1:length(reff.abrs.waves(:,1))
            reffattn=reff.abrs.waves(ii,2)+reff.abrs.thresholds(1,4);
            if reffattn==attn(1,i)
                plot(abr_time,reff.abrs.waves(ii,3:end)+y_shift(1,i),'-m','LineWidth',line_width);
            end;
        end;
    end;
end;
hold off;