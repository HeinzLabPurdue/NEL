%% FPL inverse based on NEL standard SPL calibration

function h_fig = FPLinv(command_str)

% August 11, 2023 Samantha Hauser

global PROG FIG Stimuli FREQS COMM  doInvCalib coefFileNum SRdata DDATA NelData PROTOCOL

PROTOCOL = 'calib'; 

if nargin < 1
    
    % Set up figure
    push = cell2struct(cell(1,5),{'stop','close','calib','params','recall'},2);
    ax1  = cell2struct(cell(1,4),{'axes','line1','line2','ord_text'},2);
    ax2  = cell2struct(cell(1,4),{'axes','ProgHead','ProgData','ProgMess'},2);
    ax3  = cell2struct(cell(1,10),{'axes','line1','line2','line3',... 
        'ParamHead1','ParamData1','ParamHead2','ParamData2','abs_text','ord_text'},2);
    FIG = struct('handle',[],'push',push,'ax1',ax1,'ax2',ax2,'ax3',ax3);
    
    %Stimuli structure is found in get_calib_ins
    Stimuli = FPLinv_ins;
    
    %MAKING FIGURE AND USER INTERFACE
    FIG.handle = figure('NumberTitle','off','Name','FPL-Calib Interface','Units','normalized','Visible','off', ...
        'position',[0.045  0.045  0.9502  0.7474],'MenuBar','none');
    h_fig = FIG.handle;
    
    colordef none;
    whitebg('w');
    
    %the following text handles are display parameters
    textStruct= struct('log', ''); % initialize the structure
    if Stimuli.fstlin == 0
        textStruct.log= 'yes';
    elseif Stimuli.fstoct == 0
        textStruct.log= 'no';
    end
    
    textStruct.step= max(Stimuli.fstlin, Stimuli.fstoct);
    
    if Stimuli.chan == 1
        textStruct.chan= 'left';
    else
        textStruct.chan= 'right';
    end
    
    if Stimuli.cal == 1
        textStruct.spl= 'yes';
    else
        textStruct.spl= 'no';
    end
    
    FIG = FPLinv_plot(FIG, Stimuli, textStruct);
    
    set(FIG.handle,'Visible','on');
    drawnow;
    
elseif strcmp(command_str,'return from parameter change') % called in FPLinv_sr530_ins 
    [FREQS, COMM, ~] = FPLinv_ReturnCal(FIG, Stimuli);
    set(FIG.push.stop,'Enable','off');
    set(FIG.push.recall,'Enable','on');
    set(FIG.push.calib,'Enable','on');
    set(FIG.push.close,'Enable','on');
    set(FIG.push.params,'Enable','on');
    
    %perform calibration, plot results
elseif strcmp(command_str,'calibrate')
%     [FREQS, COMM, ~]= ReturnCal(FIG, Stimuli);
    set(FIG.ax3.axes,'XTick',-50:50:50,'YTick',-50:50:50);
    set(FIG.ax3.axes,'XLim',[-50 50],'YLim',[-50 50]);
    set(FIG.ax3.ParamHead1,'Visible','off');
    set(FIG.ax3.ParamData1,'Visible','off');
    set(FIG.ax3.ParamHead2,'Visible','off');
    set(FIG.ax3.ParamData2,'Visible','off');
    set(FIG.ax3.abs_text,'Visible','on');
    set(FIG.ax3.ord_text,'Visible','on');
    set(FIG.push.params,'Visible','off');
    set(FIG.push.calib,'Visible','off');
    set(FIG.ax3.line1,'Visible','on');
    set(FIG.ax3.line2,'Visible','on');
    set(FIG.ax3.line3,'Visible','on');
    set(FIG.push.stop,'Enable','on');
    set(FIG.push.recall,'Enable','off');
    set(FIG.push.calib,'Enable','off');
    set(FIG.push.close,'Enable','off');
    set(FIG.push.params,'Enable','off');
    error = 0;
    DDATA = zeros(1000,5);
    set(FIG.push.stop,'Userdata',[]);
    set(FIG.push.close,'Userdata',DDATA);
    set(FIG.ax1.line1,'XData',DDATA(:,1),'YData',DDATA(:,2));
    set(FIG.ax1.line2,'XData',DDATA(:,1),'YData',DDATA(:,2));

    % Print Title and description.
    set(FIG.ax2.ProgMess,'String','Configuring calibration system...');
    drawnow;

    if isempty(get(FIG.push.stop,'userdata'))
        % Remaining lock-in parameters are set separately for each frequency (notch
        % filters, bandpass filter, and gain).
        % Initialize for data acquisition:
        %    frqlst = last frequency presented
        %    gprd = predicted gain for SRGAIN()
        %    ndpnts = number of frequencies done so far
        
        % Get SPL calibration data if requested.
        if Stimuli.cal
            [error] = FPLinv_get_micdata;
        end
        
        % *** Main Data Collection Loop ***
        set(FIG.ax2.ProgMess,'String','Starting data collection...');
        drawnow;
    end
    
    %% Main data collection Loop
    
    chans = [1,2];
    %1 = left, 2 = right; %ALWAYS START WITH 1
    
    cdd;
    calibs = findPics('*calib_FPL_raw');
    lastfile = max(calibs);
    if ~isempty(lastfile)
        p = loadpic(lastfile);
        default = p.chan_ord;
        if length(default)==2
            default = 'Both L/R';
        else
            default = p.chan_ord{1};
        end
    else
        default = 'Both L/R';
    end
    rdd;
    
    Stimuli.completeRun = 1; %used by make_tone() to check completeness of two channel.
    for e = 1:length(chans)
        Stimuli.chan = chans(e);
        
        [FREQS, COMM, ~] = FPLinv_ReturnCal(FIG, Stimuli); %SRdata here
        DDATA = zeros(1000,5);

        if Stimuli.chan == 1
            chan_name = 'Left';
        elseif Stimuli.chan ==2
            chan_name = 'Right';
        end
        
        % FPLinv_update_params(Stimuli);
        
        set(FIG.push.stop,'Userdata',[]); 
        
        error = 0;
        
        %calib loop
        while ~error && isempty(get(FIG.push.stop,'userdata'))
            %Set up TDT system for next stimulus:
            [error] = FPLinv_setlab;
            FREQS.isinit = 0;

            % Read amplitude of response
            if ~error && isempty(get(FIG.push.stop,'userdata'))
                %             tic;
                [error,converge, ~] = FPLinv_TDTdaq;
                %             temp_calib_time=toc;
            end
            
            % Correct for probe microphone calibration IF a calibration file was
            % loaded
            %   If error in CALSPL, current point must be deleted, since it cannot
            %   be calibrated for some reason.  If this is the first point in the
            %   frequency range, must crash.  ndpnts decremented to delete this
            %   point, ndad incremented to go on to next frequency (see SETLAB()
            %   and COMFRQ().
            
            if ~error && isempty(get(FIG.push.stop,'userdata'))
                
                % Track number of completed data points.
                FREQS.ndpnts = FREQS.ndpnts + 1;
                
                % Save data in buffer arrays.
                DDATA(FREQS.ndpnts,1) = FREQS.freq;  % current frequency in kHz
                if isfinite(COMM.SRdata.rmag)
                    DDATA(FREQS.ndpnts,2) = 20 * log10(max(COMM.SRdata.rmag,1.0e-09)) + FREQS.atnn; % COMM.SRdata.rmag corrected to 0 dB system atten
                else
                    DDATA(FREQS.ndpnts,2) = NaN;
                end
                DDATA(FREQS.ndpnts,3) = COMM.SRdata.rph / pi;								  % is phase re pi radians
                DDATA(FREQS.ndpnts,4) = COMM.SRdata.sem;                                     % error of COMM.SRdata.rmag sample
                if FREQS.ndpnts == 1, iseq = 1; end
                if Stimuli.cal
                    [error] = calspl(iseq);
                    if ~isempty(COMM.SRdata.dbspl)
                        DDATA(FREQS.ndpnts,2) = COMM.SRdata.dbspl;
                    else
                        DDATA(FREQS.ndpnts,2) = NaN;
                    end
                    if isempty(COMM.SRdata.ophs)
                        DDATA(FREQS.ndpnts,3) = COMM.SRdata.ophs;
                    else
                        DDATA(FREQS.ndpnts,3) = NaN;
                    end
                    if error
                        FREQS.ndpnts = FREQS.ndpnts - 1;
                        FREQS.ndad = FREQS.ndad + 1;
                        if FREQS.ndpnts <= 0, break, end
                        error = 0;
                    end
                end
                
                %predicted gain is same as last gain
                FREQS.gprd = FREQS.gain;
                FREQS.frqlst = FREQS.freq;
                
                low_lim = floor(min(DDATA(1:FREQS.ndpnts,2))/20)*20;
                up_lim  = ceil(max(DDATA(1:FREQS.ndpnts,2))/20)*20;
                if low_lim < up_lim
                    set(FIG.ax1.axes,'YLim',[low_lim up_lim]);
                end
                
                
                switch Stimuli.chan
                    case 1 %left
                        set(FIG.ax1.line1,'XData',DDATA(:,1),'YData',DDATA(:,2));
                    case 2 %right
                        set(FIG.ax1.line2,'XData',DDATA(:,1),'YData',DDATA(:,2));
                end
                
                if Stimuli.cal
                    display_message = sprintf('%s%6.3f%s\n%s%6.2f%s\n\n%s%2d%s','Frequency:',DDATA(FREQS.ndpnts,1),' kHz','SPL:',DDATA(FREQS.ndpnts,2),' dB','Criterion reached in ',COMM.SRdata.ndata,' tries.');
                else
                    display_message = sprintf('%s%6.3f%s\n%s%6.2f%s\n\n%s%2d%s','Frequency:',DDATA(FREQS.ndpnts,1),' kHz','Signal:',DDATA(FREQS.ndpnts,2),' RMS V, dB re 1V','Criterion reached in ',COMM.SRdata.ndata,' tries.');
                end
                
                set(FIG.ax2.ProgMess,'String',display_message);
                drawnow;
            end
            
            if ~isempty(get(FIG.push.stop,'userdata'))
                set(FIG.ax2.ProgMess,'String','Program stopped...');
                set(FIG.push.close,'Userdata',DDATA);
            end
            
        end
        % end data collection
        ddata_struct{e} = DDATA;
        ddata_struct_chan{e} = chan_name;
        
        Stimuli.completeRun = floor(e/length(chans)); %used by make_tone() to check completeness of two channel.
    end
    
    %set up for next calib to be run
    Stimuli.completeRun = 0;
    doInvCalib = false;
    
    %%
    for i = 1:4
        attenuator(i,120);
    end
    
    set(FIG.push.stop,'Userdata',[]);
    invoke(COMM.handle.RP2_1,'Halt');
    invoke(COMM.handle.RP2_2,'Halt');
    
    if ~isempty(instrfind)
        fprintf(COMM.handle.SR530,'%s\n','G24'); %sensitivity 500 mV
        fprintf(COMM.handle.SR530,'%s\n','I2');  %activate panel inputs
        fclose(COMM.handle.SR530);
        delete(COMM.handle.SR530)
        clear COMM.handle.SR530
    end
    %************ Saving Data ******************
    ButtonName=questdlg('Do you wish to save these data?', ...
        'Save Prompt', ...
        'Yes','No','Comment','Yes');
    
    switch ButtonName
        case 'Yes'
            comment='No comment.';
        case 'Comment'
            comment=add_comment_line;	%add a comment line before saving data file
    end
    
    if strcmp(ButtonName,'Yes') ||  strcmp(ButtonName,'Comment')
        fname = current_data_file('calib_FPL',1);  % MH/GE 11/03/03 added suppress_unitno flag to generalize
        fname= sprintf('%s_inv%d', fname, coefFileNum);

        NelData=make_FPLinv_text_file(fname, NelData, Stimuli, comment, PROG, ddata_struct, ddata_struct_ear, SRdata);
        %update_params;
        %         filename = current_data_file('calib'); %strcat(FILEPREFIX,num2str(FNUM),'.m');
        uiresume; % Allow Nel's main window to update the Title

    end
    
    %****** End of data collection loop ********
    %****** End of data collection loop ********
    set(FIG.ax3.axes,'XTick',[],'YTick',[]);
    set(FIG.ax3.axes,'XLim',[0 1],'YLim',[0 1]);
    
    set(FIG.ax3.line1,'Visible','off');
    set(FIG.ax3.line2,'Visible','off');
    set(FIG.ax3.line3,'Visible','off');
    set(FIG.ax3.ParamHead1,'Visible','on');
    set(FIG.ax3.ParamData1,'Visible','on');
    set(FIG.ax3.ParamHead2,'Visible','on');
    set(FIG.ax3.ParamData2,'Visible','on');
    set(FIG.ax3.abs_text,'Visible','off');
    set(FIG.ax3.ord_text,'Visible','off');
    set(FIG.push.params,'Visible','on');
    set(FIG.push.calib,'Visible','on');
    set(FIG.push.stop,'Enable','off');
    set(FIG.push.recall,'Enable','on');
    set(FIG.push.calib,'Enable','on');
    set(FIG.push.close,'Enable','on');
    set(FIG.push.params,'Enable','on');
    set(FIG.ax2.ProgMess,'String','Ready for input...');
    drawnow;
    % end calibrate
    
elseif strcmp(command_str,'stop')
    set(FIG.push.stop,'Userdata',1);
    
elseif strcmp(command_str,'recall')
    eval('read_text_file');
    set(FIG.push.stop,'Enable','off');
    set(FIG.push.recall,'Enable','on');
    set(FIG.push.calib,'Enable','on');
    set(FIG.push.close,'Enable','on');
    set(FIG.push.params,'Enable','on');
    drawnow;
    
elseif strcmp(command_str,'close')
    if NelData.General.RP2_3and4 || NelData.General.RX8
%         coefFileNum= run_invCalib(false);
        %set back to allpass
        filttype = {'allpass','allpass'};
        RawCalibPicNum = NaN;
        invfilterdata = set_invFilter(filttype, RawCalibPicNum, true);
    end
    
    delete(FIG.handle);
end
