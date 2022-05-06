
%load stimuli files
if exist([prog_dir 'stimuli\'], 'dir')
    dirpath0=[prog_dir 'stimuli\'];
elseif exist([prog_dir 'stimuli/'], 'dir')
    dirpath0=[prog_dir 'stimuli/'];   
else
    dirpath0='';
end

[filenames, dirpath] = uigetfile([dirpath0 '*.json'],...
    'Select One or More Stimuli Json Files', ...
    'MultiSelect', 'on');

if (ishandle(FIG.ax.axis))
    delete(FIG.ax.axis);
end

if iscell(filenames) || length(filenames)>1 || filenames~=0
    %Check stim files
    %HACK case only one file
    if ~iscell(filenames)
        filenames = [{filenames}];
    end
    
    
    
    if length(filenames)>1
        shuffleButtonYesNo=questdlg('Shuffle files?', ...
            'Save Prompt', ...
            'Yes','No','Yes');
        
        switch shuffleButtonYesNo
            case 'Yes'
                RunLevels_params.shuffleFiles=1;
            case 'No'
                RunLevels_params.shuffleFiles=0;
        end
    else
        RunLevels_params.shuffleFiles=0;
    end
    
    
    if RunLevels_params.shuffleFiles
        filenames = filenames(randperm(numel(filenames)));
    end
    
    wavefilenames=cell(1, length(filenames));
    
    maskernames=cell(1, length(filenames));
    wavefile_durations=zeros(1, length(filenames));
    ind=0;
    for filename=filenames
        ind=ind+1;
        filename=filename{1};
        filepath=[dirpath filename];
        stim_json=fileread(filepath);
        stim_struct=jsondecode(stim_json);
        message= ['stimuli type not specified for file ', filepath];
        assert(isfield(stim_struct, 'type'), message )
        noWAV=true;
        if isfield(stim_struct, 'wavefiles')
            for stimVar= 1:length(stim_struct.wavefiles)
                wavefile= stim_struct.wavefiles(stimVar);
                if wavefile.fs == Stimuli.RPsamprate_Hz
                    noWAV=false;
                    wavefile_durations(ind)=wavefile.duration_s*1000; %in ms
                    wavefilenames(ind)={wavefile.filename};
                    break;
                end
            end
        end
        assert(~RunLevels_params.loadWavefiles || ~noWAV, ['wavefile not found for file ' , filepath])
        if isfield(stim_struct, 'name')
            maskernames(ind)={stim_struct.name};
        else
            
            maskernames(ind)={['masker ' int2str(ind)]};
        end
    end
    
    CAPButtonName=questdlg('Do you wish to save the CAP data after each run?', ...
        'Save Prompt', ...
        'Yes','No','Comment','Yes');
    
    switch CAPButtonName
        case 'Yes'
            CAPcomment='No comment.';
        case 'Comment'
            if ~noNEL
                CAPcomment=add_comment_line;	%add a comment line before saving data file
            else
                CAPcomment='no NEL, random data';
            end
    end
    
    clickAmp=5; 
    maskerAmp=5;
    
    set(FIG.listbox, 'Enable', 'on');
    if RunLevels_params.loadWavefiles
        set(FIG.listbox, 'String', wavefilenames);
    else
        set(FIG.listbox, 'String', filenames);
    end
    
    
    pushButton=FIG.push.run_stimuli;
    set(pushButton,'string','Abort');
    
    %set fig (from CAP_loop)
    FIG.ax.axis = axes('position',[.35 .32 .525 .62]);
    FIG.ax.line = plot(0,0,'-');
    set(FIG.ax.line,'MarkerSize',2,'Color','k');
    xlim([CAP_intervals.XstartPlot_ms/1000 CAP_intervals.XendPlot_ms/1000]);
    ylim([-Display.YLim Display.YLim]);  % ge debug: set large enough for A/D input range
    %   axis([CAP_intervals.XstartPlot_ms/1000 .010 -1 1]);  % ge debug: set large enough for A/D input range
    %    set(FIG.ax.axis,'XTick',[0:.25:1]);
    %    set(FIG.ax.axis,'YTick',[-5:1:5]);
    set(FIG.ax.axis,'XTickMode','auto');
    set(FIG.ax.axis,'YTickMode','auto');
    %    ylim('auto');
    xlabel('Time (sec)','fontsize',12,'FontWeight','Bold');
    if strcmp(Display.Voltage,'atELEC')
        FIG.ax.ylabel=ylabel('Voltage at Electrode (V)','fontsize',12,'FontWeight','Bold');
    else
        FIG.ax.ylabel=ylabel('Voltage at AD (V)','fontsize',12,'FontWeight','Bold');
    end
    text(CAP_intervals.period_ms/2000,-33,'Frequency (Hz)','fontsize',12,'horizontalalignment','center');
    text(CAP_intervals.period_ms/2000,-49,'Attenuation (dB)','fontsize',12,'horizontalalignment','center');
    box on;
    
    %New axes for showing maximum of each input waveform - KH 2011 Jun 08
    FIG.ax.axis2 = axes('position',[.925 .32 .025 .62]);
    FIG.ax.line2 = plot(0.5,0,'r*',[0 1],[Stimuli.threshV Stimuli.threshV],':r');
    xlim([0 1]); ylim([0 10]);
    set(FIG.ax.axis2,'XTickMode','auto');
    set(FIG.ax.axis2,'YTickMode','auto');
    ylabel('Max AD Voltage (1 rep)','fontsize',12,'FontWeight','Bold');
    box on;
    
    if ~noNEL   
        %run_invCalib(true);
    end
    
    CAPmaxArr= zeros(size(wavefilenames));
    
    if ~RunLevels_params.loadWavefiles
        %load config file and change duration
        config_json=fileread('fmaskedCAP_maskers_config.json');
        config_struct=jsondecode(config_json);
        config_struct.duration_s = min(CAP_intervals.duration_ms/1000*2*RunLevels_params.nPairs*1.5, 5);  %extra x1.5 factor
          
    end
    
    for ind_file=1:length(wavefilenames) %main loop
        firstrun= (ind_file==1);
        lastrun= (ind_file==length(wavefilenames));
        
        filename=filenames(ind_file);
        filename=filename{1};
        filepath=[dirpath filename];
        stim_json=fileread(filepath);
        stim_struct=jsondecode(stim_json);
        
        wavefilename=wavefilenames(ind_file);
        wavefilename=wavefilename{1};
        message1=['Running stimuli ' int2str(ind_file)];
        message2=[int2str(length(wavefilenames)-ind_file+1) ' remaining file(s)'];
        set(FIG.statText.status, 'String', sprintf('%s\n%s', message1, message2));
        
        Stimuli_adv = Stimuli;
        Stimuli_adv.masker=stim_struct; %info on masker
       
        
        if ~RunLevels_params.loadWavefiles  %Create wavefile on the fly 
           extra_atten_dB=0;
            if isfield(stim_struct, 'extra_atten_dB')
                extra_atten_dB=stim_struct.extra_atten_dB;
                if ~RunLevels_params.extraAttenuationOnWavefiles
                    %we need to remove extraAtten from stim_struct
                    stim_struct=rmfield(stim_struct, 'extra_atten_dB');
                end
            end
            
            
            if firstrun
                statText=get(FIG.statText.status, 'String');
                
                set(FIG.statText.status, 'String', 'Creating parallel pool');
                 if RunLevels_params.invFilterOnWavefiles && ~noNEL
                    cdd
                    temp = load('fmasked_coef_invCalib');
                    rdd
                    b_coeffs= temp.b_coeffs(:)';
                    future=parfeval(@fmaskedCAP_create_signal_func, 1, config_struct, stim_struct, b_coeffs);
                 else
                     future=parfeval(@fmaskedCAP_create_signal_func, 1, config_struct, stim_struct);
                 end
                set(FIG.statText.status, 'String', statText);
            end
            wait(future)
            sig = fetchOutputs(future);
            if any(sig>1.)
                warning([filename ': a value in the generated signal exceeds 1'])
            end
            
            if noNEL  %for test purpose
                path2= [prog_dir '\stimuli\current_masker.wav'];
                %soundsc(sig, config_struct.fs)
                audiowrite(path2, sig, config_struct.fs)
            end
            %create next stimulus asynchronously
            if ~lastrun
                next_filename=filenames(ind_file+1);
                next_filename=next_filename{1};
                next_filepath=[dirpath next_filename];
                next_stim_json=fileread(next_filepath);
                next_stim_struct=jsondecode(next_stim_json);
                clear future
                if RunLevels_params.invFilterOnWavefiles && ~noNEL
                    future=parfeval(@fmaskedCAP_create_signal_func, 1, config_struct,  next_stim_struct, b_coeffs);
                else
                    future=parfeval(@fmaskedCAP_create_signal_func, 1, config_struct,  next_stim_struct);
                end
            end
        end
        
        if ~noNEL
            
            path2= [prog_dir '\stimuli\current_masker.wav'];
            
            if RunLevels_params.loadWavefiles
                Stimuli_adv.masker.wavefilename_used=wavefilename;
                %copy WAV
                path1=[dirpath wavefilename];
                wavefile_duration=wavefile_durations(ind_file);
                
                [status, message]= copyfile(path1,path2);
                
               if status==0
                 warning(message);
                end
            
            else
                
                audiowrite(path2, sig, config_struct.fs)
                wavefile_duration=config_struct.duration_s*1000;
            end
            %TODO change in func of time of computation?
            %HACK, time to recover from masking,
            pause(0.05);
            
            %need to reload COF to reload wavefile
            invoke(RP1,'ClearCOF');
            if RunLevels_params.lpcInvFilterOnClick 
                invoke(RP1,'LoadCOF',[prog_dir '\object\fmasking_CAP_click_wav.rcx']);
            else
                invoke(RP1,'LoadCOF',[prog_dir '\object\fmasking_CAP.rcx']);
            end
            
            % invoke(RP1,'ConnectRP2','GB',1); %changed USB to GB, 5.8.13 MW/MH
            % if get(FIG.radio.tone,'value')
            invoke(RP1,'SetTagVal','FixedPhase',Stimuli.fixedPhase);
            invoke(RP1,'SetTagVal','clickAmp',clickAmp);
            invoke(RP1,'SetTagVal','maskerAmp',maskerAmp);
            
            invoke(RP1,'SetTagVal','StmOn',CAP_intervals.duration_ms);
            invoke(RP1,'SetTagVal','StmOff',CAP_intervals.period_ms-CAP_intervals.duration_ms+CAP_intervals.rftime_ms);
            invoke(RP1,'SetTagVal','gateTime',CAP_intervals.rftime_ms);  %NB: was called 'RiseFall' in CAP
            invoke(RP1,'SetTagVal','clickDelay', CAP_intervals.clickDelay);
            invoke(RP1,'SetTagVal','wavDur', wavefile_duration);
            

            
            
            if firstrun
                %set variables RP2/RP3 + run
                if NelData.General.RP2_3and4 && ~debugStimuliGeneration
                    % For bit select (RP2#3 is not connected to Mix/Sel). So have to use RP2#2. May use RP2#1?
                    invoke(RP2,'Run');
                    
                    % For ADC (data in)
                    invoke(RP3,'SetTagVal','ADdur', CAP_intervals.CAPlength_ms);
                    invoke(RP3,'SetTagVal','gateTime',CAP_intervals.rftime_ms);
                    invoke(RP3,'SetTagVal','clickDelay', CAP_intervals.clickDelay);
                    invoke(RP3,'Run');
                else
                    if (~NelData.General.RX8)
                        RP3= RP2;
                    else
                        invoke(RP2,'Run');
                    end
                    invoke(RP3,'SetTagVal','ADdur', CAP_intervals.CAPlength_ms);
                    invoke(RP3,'SetTagVal','gateTime',CAP_intervals.rftime_ms);
                    invoke(RP3,'SetTagVal','clickDelay', CAP_intervals.clickDelay);
                    invoke(RP3,'Run');
                    
                end
                    
            end
            
            
            Stimuli_adv.extra_atten_dB=extra_atten_dB;
            Stimuli_adv.extraAttenuationOnWavefiles=RunLevels_params.extraAttenuationOnWavefiles;

            attenLevel=Stimuli.atten_dB;
            CAPattens=attenLevel;
            
            
            Line_masker_atten_dB = Stimuli.masker_atten_dB;
            if ~RunLevels_params.extraAttenuationOnWavefiles
                Line_masker_atten_dB = Line_masker_atten_dB + extra_atten_dB;
            end
            
            invoke(RP1,'Run');
            fmaskedCAP_set_attns(attenLevel, Line_masker_atten_dB, Stimuli.channel,Stimuli.KHosc,RP1,RP2);
            
            invoke(RP3,'SoftTrg',2); %reset bufFlag if needed
            invoke(RP1,'SoftTrg',1);
            
        else
            pause(1);
        end
        
        Stimuli.KHosc = 0;    % added by GE/MH, 17Jan2003.  To force Krohn-Hite to disconnect.
        
        fmaskedCAP_RunLevels;
        
        if firstrun
            CAPdataAvgSynth=zeros(length(wavefilenames), CAPnpts);
        end
        CAPdataAvgSynth(ind_file, :) = CAPdataAvg-mean(CAPdataAvg);
        CAPmaxArr(ind_file)=CAPmaxAvg;
        
        if ~firstrun   %  && ~RunLevels_params.shuffleFiles
            
            CAPmaxFig = findobj('Tag','fmaskedCAP_Secondary_Fig');    %% Finds handle for TC-Figure
            if isempty(CAPmaxFig)
                CAPmaxFig=figure('Name', 'fmasked CAPs - Synthesis for last stimuli', 'Position', [10 10 900 500], 'Tag', 'fmaskedCAP_Secondary_Fig');
            end
            if length(CAPmaxFig)>2
                CAPmaxFig= CAPmaxFig(1);
            end

            %plot synthesis for all stimuli
            figure(CAPmaxFig)
            if ind_file == 2
                clf
            end
            
            beginind=max(1,ind_file-11);  %max 12
            subplot(1,2,1);
            t_arr=0:(1/Stimuli.RPsamprate_Hz):CAP_intervals.CAPlength_ms/1000;
            plot1=plot(t_arr*1000, CAPdataAvgSynth(beginind:ind_file, :)*Display.PlotFactor);
            xlabel('t (ms)');
            ylim([-Display.YLim +Display.YLim])
            if strcmp(Display.Voltage,'atELEC')
                ylabel('Voltage at Electrode (V)');
            else
                ylabel('Voltage at AD (V)');
            end
            
            
            legend(maskernames(beginind:ind_file), 'Interpreter', 'None' );
            
            subplot(1,2,2);
            colors = get(plot1,'Color');
            for j=beginind:ind_file
                
                plot(j, CAPmaxArr(j)*Display.PlotFactor, '*', 'Color', colors{1+mod(j-1, 12)});
                hold on;
            end
            xlabel('Stimuli');
            if strcmp(Display.Voltage,'atELEC')
                ylabel('Max voltage at Electrode (V)');
            else
                ylabel('Max voltage at AD (V)');
            end
            xlim([beginind-1, ind_file+1]); ylim([0, inf]); xticks(1:ind_file);
            xticks(beginind:ind_file);
            xticklabels(maskernames(beginind:ind_file));
            set(gca,'TickLabelInterpreter','none')
            xtickangle(70);
            
        end
        %Halt RP1
        if ~noNEL
            if lastrun
                fmaskedCAP_set_attns(120, 120, Stimuli.channel,Stimuli.KHosc,RP1,RP2);
                rc = PAset([120;120;120;120]); % added by GE/MH, 17Jan2003.  To force all attens to 120
            end
            invoke(RP1,'Halt');
        end
        if (strcmp(get(pushButton, 'Userdata'), 'abort'))
            break
        end
        
        set(FIG.listbox, 'Value', 1);
        if RunLevels_params.loadWavefiles
            set(FIG.listbox, 'String', wavefilenames(ind_file+1:end));
        else
            set(FIG.listbox, 'String', filenames(ind_file+1:end));
        end

    end
   
    
    
    
    if ~noNEL
        %HALT RPS (already done for RP1)
        if (NelData.General.RP2_3and4 && ~debugStimuliGeneration) || NelData.General.RX8
            invoke(RP2,'Halt');
        end
        invoke(RP3,'Halt');
        %run_invCalib(false);
    end
    
    % Reset to "Idle" mode:
    set(pushButton,'string','Run stimuli...');
    set(pushButton,'Userdata','');
    set(FIG.statText.status, 'String', ['STATUS (' interface_type '): Idle...']);
    set(FIG.statText.status2, 'String', '');
    set(FIG.listbox, 'Enable', 'off');
    set(FIG.listbox, 'String', '');
end


set(FIG.push.close,'Enable','on');
set(FIG.push.free_run,'Enable','on');
fmaskedCAP_loop_plot_enable_disable('on')

