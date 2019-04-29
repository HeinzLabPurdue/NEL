function h_fig = CAP(command_str)

global PROG FIG Stimuli root_dir prog_dir NelData devices_names_vector
global data_dir 

h_fig = findobj('Tag','CAP_Main_Fig');    %% Finds handle for TC-Figure

if nargin < 1
    prog_dir = [root_dir 'CAP\'];
    
    PROG = struct('name','CAP(v1.0).m');
    
%     push  = cell2struct(cell(1,4),{'close','x1','x10','x100'},2);
    push  = cell2struct(cell(1,5),{'run_levels','close','x1','x10','x100'},2);
%     radio = cell2struct(cell(1,8),{'noise','tone','khite','fast','slow','left','right','both'},2);
    radio = cell2struct(cell(1,5),{'fast','slow','left','right','both'},2);
    checkbox = cell2struct(cell(1,1), {'fixedPhase'},2);
    statText  = cell2struct(cell(1,2),{'memReps','status'},2);
%     popup = cell2struct(cell(1,1),{'spike_channel'},2);   % added by GE 17Jan2003.
    fsldr = cell2struct(cell(1,4),{'slider','min','max','val'},2);
    asldr = cell2struct(cell(1,4),{'slider','min','max','val'},2);
    ax = cell2struct(cell(1,2),{'axis','line'},2);
     FIG   = struct('handle',[],'edit',[],'push',push,'radio',radio,'checkbox',checkbox,'statText', statText, 'fsldr',fsldr,'asldr',asldr,'NewStim',0,'ax',ax);
%    FIG   = struct('handle',[],'edit',[],'push',push,'radio',radio,'fsldr',fsldr,'asldr',asldr,'NewStim',0,'ax',ax,'popup',popup, 'statText', statText);  % modified by GE 17Jan2003.
  
    CAP_ins;
    
    FIG.handle = figure('NumberTitle','off','Name','CAP Interface','Units','normalized','position',[0.045  0.013  0.9502  0.7474],'Visible','off','MenuBar','none','Tag','CAP_Main_Fig');
    colordef none;
    whitebg('w');
    CAP_loop_plot;
    CAP_loop;
    
%  elseif strcmp(command_str,'tone')
%      FIG.NewStim = 1;
%      Stimuli.KHosc = 0;
%      set(FIG.fsldr.val,'string',num2str(Stimuli.freq_hz));
%     set(FIG.radio.khite,'value',0);
%      set(FIG.radio.noise,'value',0);
% 
%  elseif strcmp(command_str,'noise')
%      FIG.NewStim = 2;
%      Stimuli.KHosc = 0;
%      set(FIG.fsldr.val,'string','noise');
%      set(FIG.radio.khite,'value',0);
%      set(FIG.radio.tone,'value',0);
% 
%  elseif strcmp(command_str,'khite')
%      FIG.NewStim = 3;
%      Stimuli.KHosc = 2;
%      set(FIG.fsldr.val,'string','Osc');
%      set(FIG.radio.tone,'value',0);
% %         set(FIG.radio.noise,'value',0);
        
elseif strcmp(command_str,'fast')
   if get(FIG.radio.fast, 'value') == 1
      FIG.NewStim = 4;
      set(FIG.radio.slow,'value',0);
      Stimuli.duration_ms =  50;
      Stimuli.period_ms   = 250;
   else
      set(FIG.radio.fast,'value',1);
   end
   
elseif strcmp(command_str,'slow')
   if get(FIG.radio.slow, 'value') == 1
      FIG.NewStim = 4;
      set(FIG.radio.fast,'value',0);
      Stimuli.duration_ms =  200;
      Stimuli.period_ms   = 1000;
   else
      set(FIG.radio.slow,'value',1);
   end
    
elseif strcmp(command_str,'left')
   if get(FIG.radio.left, 'value') == 1
      FIG.NewStim = 5;
      Stimuli.channel = 2;
      Stimuli.ear='left';
      set(FIG.radio.right,'value',0);
      set(FIG.radio.both,'value',0);
   else
      set(FIG.radio.left,'value',1);
   end
     
elseif strcmp(command_str,'right')
   if get(FIG.radio.right, 'value') == 1
      FIG.NewStim = 5;
      Stimuli.channel = 1;
      Stimuli.ear='right';
      set(FIG.radio.left,'value',0);
      set(FIG.radio.both,'value',0);
   else
      set(FIG.radio.right,'value',1);
   end
     
elseif strcmp(command_str,'both')
   if get(FIG.radio.both, 'value') == 1
      FIG.NewStim = 5;
      Stimuli.channel = 3;
      Stimuli.ear='both';
      set(FIG.radio.left,'value',0);
      set(FIG.radio.right,'value',0);
   else
      set(FIG.radio.both,'value',1);
   end
     
elseif strcmp(command_str,'slide_freq')
     FIG.NewStim = 6;
     Stimuli.freq_hz = floor(get(FIG.fsldr.slider,'value')*Stimuli.fmult);
     set(FIG.fsldr.val,'string',num2str(Stimuli.freq_hz));

elseif strcmp(command_str,'mult_1x')
     Stimuli.fmult = 1;
     set(FIG.push.x1,'foregroundcolor',[1 1 1]);
     set(FIG.push.x10,'foregroundcolor',[0 0 0]);
     set(FIG.push.x100,'foregroundcolor',[0 0 0]);
     FIG.NewStim = 6;
     Stimuli.freq_hz = floor(get(FIG.fsldr.slider,'value')*Stimuli.fmult);
     set(FIG.fsldr.val,'string',num2str(Stimuli.freq_hz));
     
elseif strcmp(command_str,'mult_10x')
     Stimuli.fmult = 10;
     set(FIG.push.x1,'foregroundcolor',[0 0 0]);
     set(FIG.push.x10,'foregroundcolor',[1 1 1]);
     set(FIG.push.x100,'foregroundcolor',[0 0 0]);
     FIG.NewStim = 6;
     Stimuli.freq_hz = floor(get(FIG.fsldr.slider,'value')*Stimuli.fmult);
     set(FIG.fsldr.val,'string',num2str(Stimuli.freq_hz));
     
elseif strcmp(command_str,'mult_100x')
     Stimuli.fmult = 100;
     set(FIG.push.x1,'foregroundcolor',[0 0 0]);
     set(FIG.push.x10,'foregroundcolor',[0 0 0]);
     set(FIG.push.x100,'foregroundcolor',[1 1 1]);
     FIG.NewStim = 6;
     Stimuli.freq_hz = floor(get(FIG.fsldr.slider,'value')*Stimuli.fmult);
     set(FIG.fsldr.val,'string',num2str(Stimuli.freq_hz));
     
elseif strcmp(command_str,'slide_atten')
     FIG.NewStim = 7;
     Stimuli.atten_dB = floor(-get(FIG.asldr.slider,'value'));
     set(FIG.asldr.val,'string',num2str(-Stimuli.atten_dB));
     
elseif strcmp(command_str,'memReps')
    FIG.NewStim = 9;
    oldMemReps = Stimuli.CAPmem_reps;
    Stimuli.CAPmem_reps = str2num(get(FIG.edit.memReps,'string'));
    if (isempty(Stimuli.CAPmem_reps))  % check is empty
       Stimuli.CAPmem_reps = oldMemReps;
    elseif ( Stimuli.CAPmem_reps<0 )  % check range
       Stimuli.CAPmem_reps = oldMemReps;
    end
    set(FIG.edit.memReps,'string', num2str(Stimuli.CAPmem_reps));
    
elseif strcmp(command_str,'fixedPhase')
   Stimuli.fixedPhase = get(FIG.checkbox.fixedPhase,'value');
%      Stimuli.fixedPhase = str2num(get(FIG.checkbox.fixedPhase,'value'));
   FIG.NewStim = 8;
   
elseif strcmp(command_str,'run_levels')
   FIG.NewStim = 10;
   if (strcmp(get(FIG.push.run_levels,'string'), 'Abort'))  % In Run-levels mode, go back to free-run
      set(FIG.push.run_levels,'Userdata','abort');
      set(FIG.push.close,'Enable','on');
   else
      set(FIG.push.close,'Enable','off');
   end
   
elseif strcmp(command_str,'close');
   set(FIG.push.close,'Userdata',1);
end

