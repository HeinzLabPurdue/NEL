global FIG;

PAset([120 120 120 120]);
RP1=actxcontrol('RPco.x',[0 0 1 1]);
invoke(RP1,'ConnectRP2','USB',1);
invoke(RP1,'ClearCOF');
invoke(RP1,'LoadCOF',[prog_dir '\object\search_left.rcx']);

if get(FIG.radio.tone,'value')
    invoke(RP1,'SetTagVal','freq',Stimuli.freq_hz);
    invoke(RP1,'SetTagVal','tone',1);
elseif get(FIG.radio.noise,'value')
    invoke(RP1,'SetTagVal','tone',0);
elseif get(FIG.radio.khite,'value')
    invoke(RP1,'SetTagVal','tone',3);
elseif get(FIG.radio.tonesweep,'value')
    invoke(RP1,'SetTagVal','tone',1);
end

invoke(RP1,'SetTagVal','StmOn',Stimuli.duration);
invoke(RP1,'SetTagVal','StmOff',Stimuli.period-Stimuli.duration);
invoke(RP1,'Run');

RP2=actxcontrol('RPco.x',[0 0 1 1]);
invoke(RP2,'ConnectRP2','USB',2);
invoke(RP2,'ClearCOF');
invoke(RP2,'LoadCOF',[prog_dir '\object\search_right.rcx']);
invoke(RP2,'Run');
PAset(120.0);


if (ishandle(FIG.ax.axis))
    delete(FIG.ax.axis);
end
FIG.ax.axis = axes('position',[.35 .36 .525 .62],'color','k');
axis([0 Stimuli.period/1000 0 26]);
set(FIG.ax.axis,'XTick',0:.25:Stimuli.period/1000);
set(FIG.ax.axis,'YTick',0:25:25);
xlabel('Time (msec)','fontsize',12,'FontWeight','Bold');
ylabel('Stimulus number','fontsize',12,'FontWeight','Bold');
text(Stimuli.period/2000,-33,'Frequency (Hz)','fontsize',12,'horizontalalignment','center');
text(Stimuli.period/2000,-49,'Attenuation (dB)','fontsize',12,'horizontalalignment','center');
box on;
hold on;drawnow;
hraster = animatedline(NaN,NaN);%MS 2017 - to reflect changes in matlab graphics from 2014b onwards
hraster.Color = 'g';
invoke(RP1,'SoftTrg',1);
tspan = Stimuli.period/1000;
FIG.NewStim = 2;
FIG.OldStim = 2;%Starts off with some stimulus:  tone =1, noise = 2, kh = 3, sweep = 8
isset = 0;
search_set_attns(Stimuli.atten,Stimuli.channel,Stimuli.KHosc,RP1,RP2);
while isempty(get(FIG.push.close,'Userdata'))
    msdl(0);msdl(1,6);
    seq = 1;
    prev_seq = 1;
    tonecount = 1;
    prev_trig_state = 1;
    while (seq <= 26)
        [spk,seq] = msdl(2);%MS/A 2017 new msdl setup
        if seq>=26
            if (~isempty(spk{Stimuli.spike_channel}))
                Xvals = reshape([spk{Stimuli.spike_channel}(:,2) spk{Stimuli.spike_channel}(:,2) NaN(size(spk{Stimuli.spike_channel},1),1)]',1,size(spk{Stimuli.spike_channel},1)*3);
                Yvals = reshape([spk{Stimuli.spike_channel}(:,1)-0.5 spk{Stimuli.spike_channel}(:,1)+0.5 NaN(size(spk{Stimuli.spike_channel},1),1)]',1,size(spk{Stimuli.spike_channel},1)*3);
                addpoints(hraster,Xvals,Yvals);
                drawnow;
            end
            break;
        end
        if (~isempty(spk{Stimuli.spike_channel}))
            Xvals = reshape([spk{Stimuli.spike_channel}(:,2) spk{Stimuli.spike_channel}(:,2) NaN(size(spk{Stimuli.spike_channel},1),1)]',1,size(spk{Stimuli.spike_channel},1)*3);
            Yvals = reshape([spk{Stimuli.spike_channel}(:,1)-0.5 spk{Stimuli.spike_channel}(:,1)+0.5 NaN(size(spk{Stimuli.spike_channel},1),1)]',1,size(spk{Stimuli.spike_channel},1)*3);
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
                    invoke(RP1,'SetTagVal','tone',3);%M. Sayles 2017 - added as part of the changes needed to make the KH Osc input from the RP1.1 ADC channel 1
                    search_set_attns(Stimuli.atten,Stimuli.channel,Stimuli.KHosc,RP1,RP2);
                case 4
                    if ~isset
                        search_set_attns(Stimuli.atten,Stimuli.channel,Stimuli.KHosc,RP1,RP2);
                        isset = 1;
                    end
                    invoke(RP1,'SetTagVal','StmOn',Stimuli.duration);
                    invoke(RP1,'SetTagVal','StmOff',Stimuli.period-Stimuli.duration);
                    FIG.NewStim = 0;
                    break
                case 5
                    search_set_attns(Stimuli.atten,Stimuli.channel,Stimuli.KHosc,RP1,RP2);
                case 6
                    if ~isset
                        search_set_attns(Stimuli.atten,Stimuli.channel,Stimuli.KHosc,RP1,RP2);
                        isset = 1;
                    end
                    invoke(RP1,'SetTagVal','freq',Stimuli.freq_hz);
                    if ~get(FIG.radio.tone,'value')
                        set(FIG.radio.tone,'value',1);
                        set(FIG.radio.noise,'value',0);
                        set(FIG.radio.khite,'value',0);
                        invoke(RP1,'SetTagVal','tone',1);
                    end
                case 7
                    search_set_attns(Stimuli.atten,Stimuli.channel,Stimuli.KHosc,RP1,RP2);
                case 8
                    if ~isset
                        search_set_attns(Stimuli.atten,Stimuli.channel,Stimuli.KHosc,RP1,RP2);
                        isset = 1;
                    end                    
                    trig_state = invoke(RP1, 'GetTagVal', 'Stage');
                    if trig_state==2 && (prev_trig_state~=trig_state)
                        pause(.02);%Trigger off is the start of the off ramp - so give it a small pause to avoid changing freq during the ramp off
                        invoke(RP1,'SetTagVal','tone',1);
                        if tonecount>length(Stimuli.freq_list)
                            tonecount = 1;
                        end
                        invoke(RP1,'SetTagVal','freq',Stimuli.freq_list(tonecount));
                        if Stimuli.freq_list(tonecount) <=1000
                            Stimuli.fmult = 1;
                            set(FIG.push.x1,'foregroundcolor',[0 0 0]);
                            set(FIG.push.x10,'foregroundcolor',[.6 .6 .6]);
                            set(FIG.push.x100,'foregroundcolor',[.6 .6 .6]);
                        elseif Stimuli.freq_list(tonecount) >1000 && Stimuli.freq_list(tonecount) <=10000
                            Stimuli.fmult = 10;
                            set(FIG.push.x1,'foregroundcolor',[.6 .6 .6]);
                            set(FIG.push.x10,'foregroundcolor',[0 0 0]);
                            set(FIG.push.x100,'foregroundcolor',[.6 .6 .6]);
                        elseif Stimuli.freq_list(tonecount) >10000
                            Stimuli.fmult = 100;
                            set(FIG.push.x1,'foregroundcolor',[.6 .6 .6]);
                            set(FIG.push.x10,'foregroundcolor',[.6 .6 .6]);
                            set(FIG.push.x100,'foregroundcolor',[0 0 0]);
                        end
                        set(FIG.fsldr.val,'string',num2str(Stimuli.freq_list(tonecount)));
                        set(FIG.fsldr.slider, 'value', Stimuli.freq_list(tonecount)/Stimuli.fmult);
                        tonecount = tonecount+1;
                    end
                    prev_trig_state = trig_state;
                case 9
                    if ~isset
                        search_set_attns(Stimuli.atten,Stimuli.channel,Stimuli.KHosc,RP1,RP2);
                        isset = 1;
                    end
                    trig_state = invoke(RP1, 'GetTagVal', 'Stage');
                    if trig_state==2 && (prev_trig_state~=trig_state)
                        pause(.02);%Trigger off is the start of the off ramp - so give it a small pause to avoid changing freq during the ramp off
                        invoke(RP1,'SetTagVal','tone',1);
                        if tonecount>length(Stimuli.freq_list)
                            tonecount = 1;
                        end
                        invoke(RP1,'SetTagVal','freq',Stimuli.freq_list(tonecount));
                        invoke(RP1,'SetTagVal','freq2',Stimuli.freq_list(tonecount)+4);
                        if Stimuli.freq_list(tonecount) <=1000
                            Stimuli.fmult = 1;
                            set(FIG.push.x1,'foregroundcolor',[0 0 0]);
                            set(FIG.push.x10,'foregroundcolor',[.6 .6 .6]);
                            set(FIG.push.x100,'foregroundcolor',[.6 .6 .6]);
                        elseif Stimuli.freq_list(tonecount) >1000 && Stimuli.freq_list(tonecount) <=10000
                            Stimuli.fmult = 10;
                            set(FIG.push.x1,'foregroundcolor',[.6 .6 .6]);
                            set(FIG.push.x10,'foregroundcolor',[0 0 0]);
                            set(FIG.push.x100,'foregroundcolor',[.6 .6 .6]);
                        elseif Stimuli.freq_list(tonecount) >10000
                            Stimuli.fmult = 100;
                            set(FIG.push.x1,'foregroundcolor',[.6 .6 .6]);
                            set(FIG.push.x10,'foregroundcolor',[.6 .6 .6]);
                            set(FIG.push.x100,'foregroundcolor',[0 0 0]);
                        end
                        set(FIG.fsldr.val,'string',num2str(Stimuli.freq_list(tonecount)));
                        set(FIG.fsldr.slider, 'value', Stimuli.freq_list(tonecount)/Stimuli.fmult);
                        tonecount = tonecount+1;
                    end
                    prev_trig_state = trig_state;
            end
            if (FIG.NewStim~=FIG.OldStim)
                isset = 0;
            end
            if ismember(FIG.NewStim,1:7)
                FIG.NewStim = 0;
            elseif FIG.OldStim==9
                FIG.NewStim = 9;
            elseif FIG.OldStim==8
                FIG.NewStim = 8;
            end
        end
        FIG.OldStim = FIG.NewStim;%update record of last choice
    end
    clearpoints(hraster);
end

msdl(0);% Reset - Added MS 2017

Stimuli.KHosc = 0;    % added by GE/MH, 17Jan2003.  To force Krohn-Hite to disconnect.
search_set_attns(120,Stimuli.channel,Stimuli.KHosc,RP1,RP2);
rc = PAset([120;120;120;120]); % added by GE/MH, 17Jan2003.  To force all attens to 120

invoke(RP1,'Halt');
invoke(RP2,'Halt');

delete(FIG.handle);
clear FIG;

