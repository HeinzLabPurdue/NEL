RP1=actxcontrol('RPco.x',[0 0 1 1]);
invoke(RP1,'ConnectRP2','USB',1);
invoke(RP1,'ClearCOF');
invoke(RP1,'LoadCOF',[prog_dir '\object\search_left.rco']);

if get(FIG.radio.tone,'value')
    invoke(RP1,'SetTagVal','freq',Stimuli.freq_hz);
    invoke(RP1,'SetTagVal','tone',1);
elseif get(FIG.radio.noise,'value')
    invoke(RP1,'SetTagVal','tone',0);
elseif get(FIG.radio.khite,'value')
    invoke(RP1,'SetTagVal','tone',2);
end

invoke(RP1,'SetTagVal','StmOn',Stimuli.duration);
invoke(RP1,'SetTagVal','StmOff',Stimuli.period-Stimuli.duration);
invoke(RP1,'Run');

RP2=actxcontrol('RPco.x',[0 0 1 1]);
invoke(RP2,'ConnectRP2','USB',2);
invoke(RP2,'ClearCOF');
invoke(RP2,'LoadCOF',[prog_dir '\object\search_right.rco']);
invoke(RP2,'Run');

search_set_attns(Stimuli.atten,Stimuli.channel,Stimuli.KHosc,RP1,RP2);

while ~length(get(FIG.push.close,'Userdata')),
    if (ishandle(FIG.ax.axis))
        delete(FIG.ax.axis);
    end
    FIG.ax.axis = axes('position',[.35 .36 .525 .62]);
    FIG.ax.line = plot(0,0,'*','Erasemode','none');
    set(FIG.ax.line,'MarkerSize',2,'Color','k');
    axis([0 Stimuli.period/1000 0 100]);
    set(FIG.ax.axis,'XTick',[0:.25:1]);
    set(FIG.ax.axis,'YTick',[0:25:100]);
    xlabel('Time (msec)','fontsize',12,'FontWeight','Bold');
    ylabel('Stimulus number','fontsize',12,'FontWeight','Bold');
    text(Stimuli.period/2000,-33,'Frequency (Hz)','fontsize',12,'horizontalalignment','center');
    text(Stimuli.period/2000,-49,'Attenuation (dB)','fontsize',12,'horizontalalignment','center');
    box on;
    
%     msdl(1,1);
msdl(1,6);   % Modified by GE 17Jan2003.  Hard-code to read all six spike input channels.

    invoke(RP1,'SoftTrg',1);
    tspan = Stimuli.period/1000;
    seq = 1;
    prev_seq = 1;
    while (seq < 100)
        [spk seq] = msdl(2);
%         if (~isempty(spk{1}))
%             set(FIG.ax.line,'xdata',spk{1}(:,2),'ydata',spk{1}(:,1));
%         end
     % Modified by GE 17Jan2003.  To incorporate dynamic spike channel.
        if (~isempty(spk{Stimuli.spike_channel}))
            set(FIG.ax.line,'xdata',spk{Stimuli.spike_channel}(:,2),'ydata',spk{Stimuli.spike_channel}(:,1));
        end
        drawnow;
        
        if (prev_seq ~= seq)
            status = msdl(3);
            if (status(1) < 0)
                nelwarn(['ERROR from channel 1:' char([13 10]) nidaq_error_code(status(1))]);
            end
            prev_seq = seq;
        end
        
        if get(FIG.push.close,'Userdata'),
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
end

msdl(0); % Reset

Stimuli.KHosc = 0;    % added by GE/MH, 17Jan2003.  To force Krohn-Hite to disconnect.
search_set_attns(120,Stimuli.channel,Stimuli.KHosc,RP1,RP2);
rc = PAset([120;120;120;120]); % added by GE/MH, 17Jan2003.  To force all attens to 120

invoke(RP1,'Halt');
invoke(RP2,'Halt');

delete(FIG.handle);
clear FIG;

