PAset([120 120 120 120]);
% RP1=actxcontrol('RPco.x',[0 0 1 1]);
% invoke(RP1,'ConnectRP2','USB',1);
RP1= connect_tdt('RP', 1);
invoke(RP1,'ClearCOF');
invoke(RP1,'LoadCOF',[prog_dir '\object\search_left.rco']);

if get(FIG.radio.tone,'value')
    invoke(RP1,'SetTagVal','freq',Stimuli.freq_hz);
    invoke(RP1,'SetTagVal','tone',1);
elseif get(FIG.radio.noise,'value')
    invoke(RP1,'SetTagVal','tone',0);
elseif get(FIG.radio.khite,'value')
    invoke(RP1,'SetTagVal','tone',2);  % Mark used 3, for KH straight into ADC1 on TDT, whereas we use 2 to shutoff MUX, since there is physical connection
end

invoke(RP1,'SetTagVal','StmOn',Stimuli.duration);
invoke(RP1,'SetTagVal','StmOff',Stimuli.period-Stimuli.duration);
invoke(RP1,'Run');

% RP2=actxcontrol('RPco.x',[0 0 1 1]);
% invoke(RP2,'ConnectRP2','USB',2);
RP2= connect_tdt('RP', 2);
invoke(RP2,'ClearCOF');
invoke(RP2,'LoadCOF',[prog_dir '\object\search_right.rco']);
invoke(RP2,'Run');

if (ishandle(FIG.ax.axis))
    delete(FIG.ax.axis);
end
FIG.ax.axis = axes('position',[.35 .36 .525 .62]);
axis([0 Stimuli.period/1000 0 100]);
set(FIG.ax.axis,'XTick',0:.25:1);
set(FIG.ax.axis,'YTick',0:25:100);
xlabel('Time (msec)','fontsize',12,'FontWeight','Bold');
ylabel('Stimulus number','fontsize',12,'FontWeight','Bold');
text(Stimuli.period/2000,-33,'Frequency (Hz)','fontsize',12,'horizontalalignment','center');
text(Stimuli.period/2000,-49,'Attenuation (dB)','fontsize',12,'horizontalalignment','center');
box on;
% starting new graphics after 2014b (MS)
hold on;drawnow;
hraster = animatedline(NaN,NaN);%MS 2017 - to reflect changes in matlab graphics from 2014b onwards
hraster.LineStyle ='none';
hraster.Marker ='*';
hraster.MarkerSize = 2;
hraster.Color = 'k';
tspan = Stimuli.period/1000;

invoke(RP1,'SoftTrg',1);
search_set_attns(Stimuli.atten,Stimuli.channel,Stimuli.KHosc,RP1,RP2); %open attens just before starting data collection 

while isempty(get(FIG.push.close,'Userdata'))
    msdl(0); msdl(1,1);   % Set to one channel, can use msdl(1,N) if want N chs.
    seq = 1;
    prev_seq = 1;
    while (seq < 100)
        [spk, seq] = msdl(2);
        if (~isempty(spk{Stimuli.spike_channel}))
            Xvals = spk{Stimuli.spike_channel}(:,2);   % May 3 2019 - simplified by SP and MH from MS odd vertical lines
            Yvals = spk{Stimuli.spike_channel}(:,1);
            addpoints(hraster,Xvals,Yvals);
        end
        drawnow;
        
        if (prev_seq ~= seq)
            status = msdl(3);
            if (status(1) < 0)
                nelwarn(['ERROR from channel 1:' char([13 10]) nidaq_error_code(status(1))]);
            end
            prev_seq = seq;
        end
        
        if get(FIG.push.close,'Userdata')
            break;
        elseif FIG.NewStim
            switch FIG.NewStim
                
            case 1
                invoke(RP1,'SetTagVal','freq',Stimuli.freq_hz);
                invoke(RP1,'SetTagVal','tone',1);
                search_set_attns(Stimuli.atten,Stimuli.channel,Stimuli.KHosc,RP1,RP2);
            case 2
                invoke(RP1,'SetTagVal','tone',0);
                search_set_attns(Stimuli.atten,Stimuli.channel,Stimuli.KHosc,RP1,RP2);
            case 3
                search_set_attns(Stimuli.atten,Stimuli.channel,Stimuli.KHosc,RP1,RP2);
            case 4
                invoke(RP1,'SetTagVal','StmOn',Stimuli.duration);
                invoke(RP1,'SetTagVal','StmOff',Stimuli.period-Stimuli.duration);
                FIG.NewStim = 0;
                break
            case 5
               search_set_attns(Stimuli.atten,Stimuli.channel,Stimuli.KHosc,RP1,RP2);
            case 6
                invoke(RP1,'SetTagVal','freq',Stimuli.freq_hz);
                if ~get(FIG.radio.tone,'value')
                    set(FIG.radio.tone,'value',1);
                    set(FIG.radio.noise,'value',0);
                    set(FIG.radio.khite,'value',0);
                    invoke(RP1,'SetTagVal','tone',1);
                end
            case 7
                search_set_attns(Stimuli.atten,Stimuli.channel,Stimuli.KHosc,RP1,RP2);
            end
            FIG.NewStim = 0;
        end
    end
    clearpoints(hraster);
end

msdl(0); % Reset

Stimuli.KHosc = 0;    % added by GE/MH, 17Jan2003.  To force Krohn-Hite to disconnect.
search_set_attns(120,Stimuli.channel,Stimuli.KHosc,RP1,RP2);
rc = PAset([120;120;120;120]); % added by GE/MH, 17Jan2003.  To force all attens to 120

invoke(RP1,'Halt');
invoke(RP2,'Halt');

delete(FIG.handle);
clear FIG;

