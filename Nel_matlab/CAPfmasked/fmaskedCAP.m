function h_fig = fmaskedCAP(command_str)
global noNEL CAP_intervals debugStimuliGeneration
global RP1 RP2 RP3 PA
noNEL=false; %true: emulator, false: in lab
debugStimuliGeneration=false; %true: data during masker + click will be collected , false:normal mode

% ge debug ABR 26Apr2004: replace "CAP" with more generalized nomenclature, throughout entire system.

global PROG FIG Stimuli root_dir prog_dir NelData...
    devices_names_vector RunLevels_params Display interface_type misc 
global data_dir


h_fig = findobj('Tag','fmaskedCAP_Main_Fig');    %% Finds handle for TC-Figure
if length(h_fig)>2
    h_fig= h_fig(1);
end
    
if nargin < 1
    if ~noNEL
        run_invCalib(false);
        prog_dir = [root_dir 'CAPfmasked\'];
        addpath(prog_dir);
    else
        prog_dir='./';   %depends on file system
        %prog_dir = [root_dir 'CAPfmasked\'];
        addpath(prog_dir);
    end
    
    
    PROG = struct('name','forward_masked_CAPs(fd-aug-2020).m');
    
    
     push  = cell2struct(cell(1,2),{'run_levels','close'},2); %removed:  'forget_now'
%     radio = cell2struct(cell(1,8),{'noise','tone','khite','fast','slow','left','right','both'},2);
      % ge debug ABR 26Apr2004: need to add buttons to select between tone/noise/click
    radio = cell2struct(cell(1,5),{'fast','slow','left','right','both'},2);  
    checkbox = cell2struct(cell(1,1), {'fixedPhase'},2);
    statText  = cell2struct(cell(1,3),{'memReps','status', 'status2'},2);
%     popup = cell2struct(cell(1,1),{'spike_channel'},2);   % added by GE 17Jan2003.
    % fsldr = cell2struct(cell(1,4),{'slider','min','max','val'},2);
     asldr = cell2struct(cell(1,4),{'slider','min','max','val'},2);
     asldr2 = cell2struct(cell(1,4),{'slider','min','max','val'},2);
    ax = cell2struct(cell(1,2),{'axis','line'},2);
     FIG   = struct('handle',[],'edit',[],'push',push,'radio',radio,'checkbox',checkbox,'statText', statText, ...
         'asldr',asldr,'asldr2',asldr2,'NewStim',0,'ax',ax, 'listbox', []);
%    FIG   = struct('handle',[],'edit',[],'push',push,'radio',radio,'fsldr',fsldr,'asldr',asldr,'NewStim',0,'ax',ax,'popup',popup, 'statText', statText);  % modified by GE 17Jan2003.


    fmaskedCAP_ins;
   
    FIG.handle = figure('NumberTitle','off','Name','forward-masked CAP Interface','Units','normalized','position',[0.045  0.013  0.9502  0.7474],'Visible','off','MenuBar','none','Tag','fmaskedCAP_Main_Fig');
    set(FIG.handle,'CloseRequestFcn','fmaskedCAP(''close'');')
    colordef none;
    whitebg('w');

    fmaskedCAP_loop_plot;

    
    %init actx controls
    if ~noNEL 
        RP1=actxcontrol('RPco.x',[0 0 1 1]);
        if NelData.General.RP2_3and4
            % For bit select (RP2#3 is not connected to Mix/Sel). So have to use RP2#2. May use RP2#1?
            RP2=actxcontrol('RPco.x',[0 0 1 1]);
            RP3=actxcontrol('RPco.x',[0 0 1 1]);
        else
            RP2=actxcontrol('RPco.x',[0 0 1 1]);
            RP3= RP2;
        end
    end
    
    
    
    %inv filters (LPC for click/invCalib for maskers)
    if ~noNEL
         computeLPCYesNo=questdlg('Use LPC coeffs for inverse filtering on click?', ...
            'Save Prompt', ...
            'Yes','No','Yes');
        
        switch computeLPCYesNo
            case 'Yes'
                RunLevels_params.lpcInvFilterOnClick=1;
            case 'No'
                RunLevels_params.lpcInvFilterOnClick=0;
        end
        
        fmaskedCAP_compute_inv_filters;       
    end
        
    
    %Set RPs    
    if ~noNEL 
        invoke(RP1,'ConnectRP2',NelData.General.TDTcommMode,1);
        invoke(RP1,'ClearCOF');
        if RunLevels_params.lpcInvFilterOnClick  %NB: rcx is loaded again at each new stimulus anyway for RP1    
            invoke(RP1,'LoadCOF',[prog_dir '\object\fmasking_CAP_click_wav.rcx']);
        else
            invoke(RP1,'LoadCOF',[prog_dir '\object\fmasking_CAP.rcx']);
        end
        
        if NelData.General.RP2_3and4 && ~debugStimuliGeneration
            % For bit select (RP2#3 is not connected to Mix/Sel). So have to use RP2#2. May use RP2#1?
            invoke(RP2,'ConnectRP2',NelData.General.TDTcommMode,2);
            invoke(RP2,'ClearCOF');
%             invoke(RP2,'Run');            
            

            % For ADC (data in)
            invoke(RP3,'ConnectRP2',NelData.General.TDTcommMode,3);
            invoke(RP3,'ClearCOF');

            invoke(RP2,'LoadCOF',[prog_dir '\object\CAP_BitSet.rcx']);
            invoke(RP3,'LoadCOF',[prog_dir '\object\fmasking_CAP_ADC.rcx']);
            % Only difference w/ ABR: Input Channel number
            % For CAP: AD chan #1
            
        else
            invoke(RP2,'ConnectRP2',NelData.General.TDTcommMode,2);
            invoke(RP2,'ClearCOF');
            RP3=RP2;
            if debugStimuliGeneration
                invoke(RP3,'LoadCOF',[prog_dir '\object\fmasking_CAP_right_debug.rcx']);
                CAP_intervals.CAPlength_ms=CAP_intervals.period_ms;
                CAP_intervals.XendPlot_ms=CAP_intervals.period_ms;
                CAP_intervals.period_ms=CAP_intervals.period_ms*2;
            else
                invoke(RP3,'LoadCOF',[prog_dir '\object\fmasking_CAP_right.rcx']);
            end
        end
        
        Stimuli.RPsamprate_Hz = 48828;
        fmaskedCAP_set_attns(Stimuli.atten_dB, Stimuli.masker_atten_dB, Stimuli.channel,Stimuli.KHosc,RP1,RP2);  %% debug deal with later Khite
    else
        Stimuli.RPsamprate_Hz=48828;
    end

    %fmaskedCAP_loop;   %'free run' is started by user  
    
    
   
elseif strcmp(command_str,'fast')
   if get(FIG.radio.fast, 'value') == 1
      set(FIG.radio.slow,'value',0);
      CAP_intervals=Stimuli.fast;
      FIG.NewStim = 4;
      
  else
      set(FIG.radio.fast,'value',1);
   end
   
elseif strcmp(command_str,'slow')
   if get(FIG.radio.slow, 'value') == 1
      set(FIG.radio.fast,'value',0);
      CAP_intervals=Stimuli.slow;
      FIG.NewStim = 4;
   else
      set(FIG.radio.slow,'value',1);
   end
    
elseif strcmp(command_str,'left')
   if get(FIG.radio.left, 'value') == 1
      Stimuli.channel = 2;
      Stimuli.ear='left';
      set(FIG.radio.right,'value',0);
      set(FIG.radio.both,'value',0);
      FIG.NewStim = 5;
   else
      set(FIG.radio.left,'value',1);
   end
     
elseif strcmp(command_str,'right')
   if get(FIG.radio.right, 'value') == 1
      Stimuli.channel = 1;
      Stimuli.ear='right';
      set(FIG.radio.left,'value',0);
      set(FIG.radio.both,'value',0);
      FIG.NewStim = 5;
   else
      set(FIG.radio.right,'value',1);
   end
     
elseif strcmp(command_str,'both')
   if get(FIG.radio.both, 'value') == 1
      Stimuli.channel = 3;
      Stimuli.ear='both';
      set(FIG.radio.left,'value',0);
      set(FIG.radio.right,'value',0);
      FIG.NewStim = 5;
   else
      set(FIG.radio.both,'value',1);
   end
     
elseif strcmp(command_str,'slide_atten')
     Stimuli.atten_dB = floor(-get(FIG.asldr.slider,'value'));
     Stimuli.masker_atten_dB = floor(-get(FIG.asldr2.slider,'value'));
          
     set(FIG.asldr.val,'string',num2str(-Stimuli.atten_dB));
     set(FIG.asldr2.val,'string',num2str(-Stimuli.masker_atten_dB));
     FIG.NewStim = 7;
% LQ 01/31/05    
elseif strcmp(command_str, 'slide_atten_text')     
     new_atten = get(FIG.asldr.val, 'string');        
     if new_atten(1) ~= '-'
         new_atten = ['-' new_atten];
         set(FIG.asldr.val,'string', new_atten);         
     end                
     new_atten = str2num(new_atten);
     if new_atten < get(FIG.asldr.slider,'min') | new_atten > get(FIG.asldr.slider,'max')        
         set( FIG.asldr.val, 'string', num2str(-Stimuli.atten_dB));	  	
     else            
         Stimuli.atten_dB = -new_atten;	  
         set(FIG.asldr.slider, 'value', new_atten);
     end
     
     new_atten2 = get(FIG.asldr2.val, 'string');   
     if new_atten2(1) ~= '-'
         new_atten2 = ['-' new_atten2];
         set(FIG.asldr2.val,'string', new_atten2);         
     end                
     new_atten2 = str2num(new_atten2);
     if new_atten2 < get(FIG.asldr2.slider,'min') | new_atten2 > get(FIG.asldr2.slider,'max')        
         set( FIG.asldr2.val, 'string', num2str(-Stimuli.masker_atten_dB));	  	
     else            
         Stimuli.masker_atten_dB = -new_atten2;	  
         set(FIG.asldr2.slider, 'value', new_atten2);
     end

    FIG.NewStim = 7;	
    
elseif strcmp(command_str,'fixedPhase')
   Stimuli.fixedPhase = get(FIG.checkbox.fixedPhase,'value');
%      Stimuli.fixedPhase = str2num(get(FIG.checkbox.fixedPhase,'value'));
   FIG.NewStim = 8;
   
    
elseif strcmp(command_str,'memReps')
    oldMemReps = Stimuli.CAPmem_reps;
    Stimuli.CAPmem_reps = str2num(get(FIG.edit.memReps,'string'));
    if (isempty(Stimuli.CAPmem_reps))  % check is empty
       Stimuli.CAPmem_reps = oldMemReps;
    elseif ( Stimuli.CAPmem_reps<0 )  % check range
       Stimuli.CAPmem_reps = oldMemReps;
    end
    set(FIG.edit.memReps,'string', num2str(Stimuli.CAPmem_reps));

    FIG.NewStim = 9;
    
elseif strcmp(command_str,'threshV')   %KH 2011 Jun 08, for artifact rejection
    FIG.NewStim = 13;
    oldThreshV = Stimuli.threshV;
    Stimuli.threshV = str2num(get(FIG.edit.threshV,'string'));
    if (isempty(Stimuli.threshV))  % check is empty
       Stimuli.threshV = oldThreshV;
    elseif ( Stimuli.threshV<0 )  % check range
       Stimuli.threshV = oldThreshV;
    end
    set(FIG.edit.threshV,'string', num2str(Stimuli.threshV));    
    
elseif strcmp(command_str,'free_run')
   if (strcmp(get(FIG.push.free_run,'string'), 'Abort'))  % In free run mode, go back to Idle
      set(FIG.push.free_run,'Userdata','abort');  % so that "CAP_loop" knows an abort was requested.
      set(FIG.push.close,'Enable','on');
      %set(FIG.push.forget_now,'Enable','on');
      %fmaskedCAP_loop_plot_enable_disable('on')
      set(FIG.push.run_stimuli,'Enable','on');
   else
      set(FIG.push.close,'Enable','off');
      set(FIG.push.run_stimuli,'Enable','off');
      %fmaskedCAP_loop_plot_enable_disable('off')
      fmaskedCAP_loop;
   end
   %FIG.NewStim = 10;  %old 'run levels' mode
   
elseif strcmp(command_str, 'plotFactor')
     if strcmp(Display.Voltage,'atELEC')
         Display.PlotFactor=1/Display.Gain;
         Display.YLim=Display.YLim_atAD/Display.Gain;
     else
         Display.PlotFactor=1;
         Display.YLim=Display.YLim_atAD;
     end
      
elseif strcmp(command_str,'Gain')
    oldGain = Display.Gain;
    Display.Gain = str2num(get(FIG.edit.gain,'string'));
    if (isempty(Display.Gain))  % check is empty
       Display.Gain = oldGain;
    elseif (Display.Gain<0)  % check range
       Display.Gain = oldGain;
    end
    set(FIG.edit.gain,'string', num2str(Display.Gain));
    fmaskedCAP('plotFactor');
    FIG.NewStim = 12;
    
elseif strcmp(command_str,'atAD')
   if get(FIG.radio.atAD, 'value') == 1
      
      Display.Voltage = 'atAD';
      set(FIG.radio.atELEC,'value',0);
   else
      set(FIG.radio.atAD,'value',1);
   end
   fmaskedCAP('plotFactor');
   FIG.NewStim = 12;
     
elseif strcmp(command_str,'atELEC')
   if get(FIG.radio.atELEC, 'value') == 1
      
      Display.Voltage = 'atELEC';
      set(FIG.radio.atAD,'value',0);
   else
      set(FIG.radio.atELEC,'value',1);
   end
   
   fmaskedCAP('plotFactor');
   FIG.NewStim = 12;
     
elseif strcmp(command_str,'YLim')
   oldYLim = Display.YLim_atAD;
   Display.YLim_atAD = str2num(get(FIG.edit.yscale,'string'));
   if (isempty(Display.YLim_atAD))  % check is empty
      Display.YLim_atAD = oldYLim;
   elseif (Display.YLim_atAD<0)  % check range
      Display.YLim_atAD = oldYLim;
   end
   set(FIG.edit.yscale,'string', num2str(Display.YLim_atAD));
   
   fmaskedCAP('plotFactor');
   FIG.NewStim = 12;

elseif strcmp(command_str,'run_stimuli')
   if (strcmp(get(FIG.push.run_stimuli,'string'), 'Abort'))

      set(FIG.push.run_stimuli,'Userdata','abort');  % so that "CAP_RunStimuli" knows that an abort was requested"
      set(FIG.push.close,'Enable','on');
      %set(FIG.push.forget_now,'Enable','on');
      fmaskedCAP_loop_plot_enable_disable('on')
      set(FIG.push.free_run,'Enable','on');
   else
      set(FIG.push.close,'Enable','off');
      %set(FIG.push.forget_now,'Enable','off');
      fmaskedCAP_loop_plot_enable_disable('off')
      set(FIG.push.free_run,'Enable','off');
      runLevelsMode='run_stimuli'; %single level when calling runLevels
      fmaskedCAP_RunStimuli;
   end
   %FIG.NewStim = 17;  %button not enabled in free run mode
   
elseif strcmp(command_str,'close')
   set(FIG.push.close,'Userdata',1);
   delete(FIG.handle);
   clear FIG;
   rmpath(prog_dir);
 end

