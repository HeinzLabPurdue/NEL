function [error, converge, ADdata_V_raw] = TDTdaq
% Modified SP on 8/22/19 to return TDT buffer data: so that we can test new
% line detection algorithm and compare old/new amplitude and phase
% calculation
% Modified: 6/22/07 to speed up
% M. Heinz
% Waiting for convergence doesn't seem to help, and it sure slows things down.
% Try to optimize speed of calibration.
% ALSO, take out lots of old code (NEL) [see Copy of TDTdaq - 062207.m if any questions.
%
% Modified: 7/19/06 to get data from TDT
% M. Heinz/J. Swaminathan

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%% OLD SR530 code
% Function to read complex data values from lock-in and average
% them until magnitude/(std.err.mean) exceeds a criterion.

% This routine assumes srgain() has set gain for no overload.  Reads
% data and checks for gain too small, i.e. |datum|<0.4*full scale.
% If so, resets gain and calls srgain() to check.

% Inputs:
%	crit - ratio (full scale voltage)/(std.err.mean) at which data
%	       are acceptable.
%	igain - current gain value.  Used to look-up full scale data
%	       value for crit test (also an output).

%Outputs:
%	igain - may be changed in this routine.  Is value of gain at exit.
%	[COMM.SRdata.rmag,COMM.SRdata.rph] - magnitude and phase of data.  Magnitude is in
%	       volts, phase in radians.
%	COMM.SRdata.sem - std. err. of mean of COMM.SRdata.rmag, in volts
% 	COMM.SRdata.ndata - number of data points in output average
%	error = 0 - O.K.
%	       =1 - data overload the lock-in A/D at this gain
%   converge = 0 - criterion not achieved after nmax iterations.

global COMM FIG FREQS Stimuli
%Initialize:

%%%%%%%%% INITIALIZE TDT
SR_Hz=48828.125;  % 25e6/2^9
ADdur_ms = 50;
ADdur_pts = floor(ADdur_ms/1000*SR_Hz);
time_ms=(1:ADdur_pts)/SR_Hz*1000;

seterror = invoke(COMM.handle.RP2_2,'SetTagVal','freq_Hz',1000*FREQS.freq);
seterror = invoke(COMM.handle.RP2_2,'SetTagVal','ADdur_ms', ADdur_ms);

% invoke(RP,'Run')

pause(.05) % Wait for tone to get to steady state

%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% TO ADD: SETUP TDT CIRCUIT HERE
%%%%%%%%%%%%%%%%%%%%%%%%%%


%%% TODO: HERE 7/19/06
% 1) take out all restart/cycle for resetting gain - we don't need to reset gain
% 2) cut and paste TDT RPX circuit load
% 3) cut and past in TDT get 1 data set to get xval and yval
% 4) criterion will be based on sqrt(Magnitude), rather than fulls, as in testToneSEM
% 5) rest of code should flow from there.


% fulscl = [1e-8 2e-8 5e-8 1e-7 2e-7 5e-7 1e-6 2e-6 5e-6 1e-5 2e-5 5e-5 1e-4 2e-4 5e-4 1e-3 2e-3 5e-3 1e-2 2e-2 5e-2 1e-1 2e-1 5e-1];
% restart = 1;
% cycle   = 0;

%% We can probably get rid of this while loop - it seems to be entered again only on restarts after gain is reset
% while restart & ~length(get(FIG.push.stop,'userdata'))
%    restart = 0;  %XX
%    cycle = cycle + 1; %XX
%    igmin = 4;		% min gain for lock-in
%    igmax = 24;		% max gain for lock-in
COMM.SRdata.rmag =   0;
COMM.SRdata.rph =    0;
COMM.SRdata.sem =    0;
xavg =   0;
yavg =   0;
rsqrd =  0;
plot_pnts = zeros(50,2);
%    fulls = fulscl(FREQS.gain);
converge = 0;
error = 0;
%    if cycle == 5, break; end
neltimer(0.01);


%    fprintf(COMM.handle.SR530,'%s\n','QX')
%    xval = str2num(fscanf(COMM.handle.SR530,'%s'));
%    fprintf(COMM.handle.SR530,'%s\n','QY')
%    yval = str2num(fscanf(COMM.handle.SR530,'%s'));

%    % Gain is too large, increase predicted gain setting.
%    if vmag > 1.05*fulls,
%       FREQS.gprd = FREQS.gain + 1;
%       if FREQS.gprd > igmax,
%          error = 1;
%       else
%          [error] = srgain;
%          if error == 0,
%             restart = 1;
%          end
%       end
%
%       % Gain is too small, decrease predicted gain setting.
%    elseif vmag < 0.18*fulls,
%       FREQS.gprd = FREQS.gain;
%       while FREQS.gprd > igmin & vmag < 0.2*fulscl(FREQS.gprd)
%          FREQS.gprd = FREQS.gprd - 1;
%       end
%       if FREQS.gprd < igmin,
%          error = 3;
%       else
%          [error] = srgain;
%          if error == 0,
%             restart = 1;
%          end
%       end
%    end

%    if ~restart & ~error,
% for index = 1:50,   % THIS IS THE LOOP TO RUN UNTIL VALUES CONVERGE
for index = 1:15   % THIS IS THE LOOP TO RUN UNTIL VALUES CONVERGE
    COMM.SRdata.ndata = index;
    
    display_message = sprintf('%s%6.3f%s\n%s%d%s','Frequency:',FREQS.freq,' kHz','(Collecting Data - REP ',index,')');
    set(FIG.ax2.ProgMess,'String',display_message);
    
    invoke(COMM.handle.RP2_2,'SoftTrg',1);  % Data Collection Trigger
    
    DataIndex = invoke(COMM.handle.RP2_2, 'GetTagVal', 'Index'); % read the value of index
    while DataIndex < ADdur_pts % read the value of index until the buffer is full
        DataIndex = invoke(COMM.handle.RP2_2, 'GetTagVal', 'Index');
    end
    
    ADdata_V_raw = invoke(COMM.handle.RP2_2,'ReadTagV','ADbuf',0,ADdur_pts);
    ADsignal_V = invoke(COMM.handle.RP2_2,'ReadTagV','ADbuf2',0,ADdur_pts);
    
    %% Save ADdata_V here to test line spectrum detection algorithm 
    
    
    % Clean up data to look only at signal frequency
    % LATER - maybe cross corr with tone signal
    ADdata_V=ADdata_V_raw-mean(ADdata_V_raw);
    
    
    %%
    useXcorr0_useMT1=1;
    if useXcorr0_useMT1==0
        ADsignal_V=ADsignal_V-mean(ADsignal_V);
        
        %---Cross correlate the signal and acquired data-------
        nsignal=0:length(ADsignal_V);
        ndata=0:length(ADdata_V);
        [ADsignal,nsignal]=sigfold(ADsignal_V,nsignal);
        %%% CONVOLUTION METHOD
        %    [rxy,nrxy]=conv_m(ADdata_V,ndata,ADsignal,nsignal);
        %    rxy=rxy./length(rxy);
        
        %% FFT METHOD
        nyb = nsignal(1)+ndata(1); nye=nsignal(length(ADsignal))+ndata(length(ADdata_V));
        nrxy=nyb:nye;
        X = fft([ADsignal zeros(1,length(ADdata_V)-1)]);
        Y = fft([ADdata_V zeros(1,length(ADsignal)-1)]);
        rxy = real(ifft(X.*Y));
        rxy=rxy./length(rxy);
        %---To get the peak indices--------
        kk=find(nrxy==0);
        newrxy=rxy(kk:length(rxy));
        [Amp,Ang]=max(newrxy);
        %     Amp=Amp/(sqrt(mean(ADsignal.^2)))^2%/length(ADsignal);  % Cross-correlation
        Amp=2*Amp/(sqrt(mean(ADsignal.^2)))^2; %/length(ADsignal);  % Cross-correlation  %% Factor of 2 seems to be needed - WHY???
        RMSout=Amp*sqrt(mean(ADsignal.^2)); % RMS value of microphone waveform correlated with signal
        %     Ang
        %----------------------------------
        
        %---To calculate real and img part of calibration----
        phasecalib=Ang*FREQS.freq*1000*360/SR_Hz;  % in degrees
        %     realcalib(j)=cos(phasecalib)*RMSout;
        %     imgcalib(j)=sin(phasecalib)*RMSout;
        xval=cos(phasecalib)*RMSout;  % Real part
        yval=sin(phasecalib)*RMSout; % Imag part
        %     magsqrd(j)=realcalib(j)^2+imgcalib(j)^2;  % vmag^2
        %--------------------------------------------------
        
    elseif useXcorr0_useMT1==1
        plotVar= 0;
        cur_freq= FREQS.freq*1e3;
        [xval, yval]= find_line_spectrum(ADdata_V, SR_Hz, plotVar, cur_freq);
    end
    
    
    % Compute magnitude of this reading.
    vmag = xval*xval + yval*yval;
    if vmag > 0
        vmag = sqrt(vmag);
    end
    
    
    
    % Cumulate new data with previous data
    xavg = xavg + xval;
    yavg = yavg + yval;
    rsqrd = rsqrd + vmag*vmag;
    
    plot_pnts(COMM.SRdata.ndata,1) = xval*1000;
    plot_pnts(COMM.SRdata.ndata,2) = yval*1000;
    
    dBVEC(COMM.SRdata.ndata) = 20*log10(sqrt(xval^2+yval^2));
    phaseVEC(COMM.SRdata.ndata) = -atan2(yval, xval);
    
    %% Plot each rep
    lim1 = max([abs(min(plot_pnts(1:COMM.SRdata.ndata,1))) max(plot_pnts(1:COMM.SRdata.ndata,1)) abs(min(plot_pnts(1:COMM.SRdata.ndata,2))) max(plot_pnts(1:COMM.SRdata.ndata,2))]);
    lim  = ceil(lim1/9)*10;
    set(FIG.ax3.axes,'XLim',[-lim lim],'YLim',[-lim lim]);
    set(FIG.ax3.axes,'XTick',[-lim 0 lim],'YTick',[-lim 0 lim]);
    set(FIG.ax3.line1,'XData',plot_pnts(1:COMM.SRdata.ndata,1),'YData',plot_pnts(1:COMM.SRdata.ndata,2));
    drawnow;
    
    % XXXIf 3 datapoints, compute average and check quitting criterion:
    % If 1 datapoints, compute average and check quitting criterion:
    
    
    %%
    if COMM.SRdata.ndata >= 1
        xval = xavg/COMM.SRdata.ndata;  % mean real part
        yval = yavg/COMM.SRdata.ndata;  % mean imag part
        COMM.SRdata.rmag = xval*xval + yval*yval;
        COMM.SRdata.sem = max(0, (rsqrd - COMM.SRdata.ndata*COMM.SRdata.rmag)/((COMM.SRdata.ndata-1)*COMM.SRdata.ndata));
        if COMM.SRdata.sem > 0, COMM.SRdata.sem = sqrt(COMM.SRdata.sem); end
        semNORMVEC(COMM.SRdata.ndata) = COMM.SRdata.sem/sqrt(COMM.SRdata.rmag);
        
        %         COMM.SRdata.rmag = mean(20*log10(sqrt(plot_pnts(:,1).^2+plot_pnts(:,2).^2)))
        
        %         if COMM.SRdata.sem/sqrt(COMM.SRdata.rmag) <= 1/Stimuli.crit,  % Use rmag as our fulls
        if 1==1
            converge = 1;
            if COMM.SRdata.ndata > 3
                hwarn2 = warndlg('Paused to review REPS','TROUBLE CONVERGING','modal');
                pause(.5)
                CONTINUE=0;
                %% Wait for warning to be closed
                while ~CONTINUE
                    if ~ishandle(hwarn2)
                        CONTINUE=1;
                    end
                    pause(1)   % WHY does MATLAB need these???
                end
                %         input('Press Enter to Continue');
                if ishandle(999)
                    close(999);
                end
            end
            break;
        end
    else
        semNORMVEC(COMM.SRdata.ndata) = NaN;
    end
    
    drawnow;
    if length(get(FIG.push.stop,'userdata')), break; end
end

% invoke(PA5,'SetAtten',120)
% invoke(RP,'Halt');

COMM.SRdata.rmag = sqrt(COMM.SRdata.rmag);
COMM.SRdata.rph = -atan2(yval, xval);

switch error
    case 0
        if converge
            lim1 = max([abs(min(plot_pnts(1:COMM.SRdata.ndata,1))) max(plot_pnts(1:COMM.SRdata.ndata,1)) abs(min(plot_pnts(1:COMM.SRdata.ndata,2))) max(plot_pnts(1:COMM.SRdata.ndata,2))]);
            lim  = ceil(lim1/9)*10;
            set(FIG.ax3.axes,'XLim',[-lim lim],'YLim',[-lim lim]);
            set(FIG.ax3.axes,'XTick',[-lim 0 lim],'YTick',[-lim 0 lim]);
            set(FIG.ax3.line1,'XData',plot_pnts(1:COMM.SRdata.ndata,1),'YData',plot_pnts(1:COMM.SRdata.ndata,2));
            drawnow;
        else  % DID NOT CONVERGE - TAKE AVG of rmags for all REPS, and set PHASE to
            set(FIG.ax2.ProgMess,'String','SRDAQ: Values do not converge.');
            
            %% calculate rmag based on AVG dB value of all REPS, rather than on xavg^2+yavg^2
            %% set phase to NaN and SEM to Inf
            COMM.SRdata.rmag = 10^(mean(dBVEC)/20);
            COMM.SRdata.rph = NaN;
            COMM.SRdata.sem = Inf;
            
            hwarn = warndlg(sprintf('Paused to review REPS (AVG dB = %.2f)',mean(dBVEC)),'TROUBLE CONVERGING','modal');
            pause(.5)
            CONTINUE=0;
            %% Wait for warning to be closed
            while ~CONTINUE
                if ~ishandle(hwarn)
                    CONTINUE=1;
                end
                pause(1)   % WHY does MATLAB need these???
            end
            %         input('Press Enter to Continue');
            if ishandle(999)
                close(999);
            end
            
            
        end
    case 1
        set(FIG.ax2.ProgMess,'String','SRDAQ: Overload!');
    case 2
        set(FIG.ax2.ProgMess,'String','SRDAQ: Not communicating with lock-in!');
    case 3
        set(FIG.ax2.ProgMess,'String','SRDAQ: Signal too small!');
end
