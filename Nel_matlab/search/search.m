function search(command_str)

global PROG FIG Stimuli root_dir prog_dir NelData 

if nargin < 1
    prog_dir = [root_dir 'search' filesep]; %LQ 07/24/03
    
    PROG = struct('name','Search(v2.0).m','date',date);
    
    push  = cell2struct(cell(1,4),{'close','x1','x10','x100'},2);
    radio = cell2struct(cell(1,8),{'noise','tone','khite','fast','slow','left','right','both'},2);
    statText  = cell2struct(cell(1,1),{'spike_channel'},2);   % added by GE 17Jan2003.
    popup = cell2struct(cell(1,1),{'spike_channel'},2);   % added by GE 17Jan2003.
    fsldr = cell2struct(cell(1,4),{'slider','min','max','val'},2);
    asldr = cell2struct(cell(1,4),{'slider','min','max','val'},2);
    ax = cell2struct(cell(1,2),{'axis','line'},2);
    %     FIG   = struct('handle',[],'edit',[],'push',push,'radio',radio,'fsldr',fsldr,'asldr',asldr,'NewStim',0,'ax',ax);
    FIG   = struct('handle',[],'edit',[],'push',push,'radio',radio,'fsldr',fsldr,'asldr',asldr,'NewStim',0,'ax',ax,'popup',popup, 'statText', statText);  % modified by GE 17Jan2003.
    
    search_ins;
    
    FIG.handle = figure('NumberTitle','off','Name','Search Interface','Units','normalized','position',[0.045  0.013  0.9502  0.7474],'Visible','off','MenuBar','none','Tag','Search_Main_Fig');
    colordef none;
    whitebg('w');
    nuplot;
    search('invCalib'); % Initialize RP2_4 with InvFilter
    nu;
    
elseif strcmp(command_str,'tone')
    FIG.NewStim = 1;
    Stimuli.KHosc = 0;
    set(FIG.fsldr.val,'string',num2str(Stimuli.freq_hz));
    set(FIG.radio.khite,'value',0);
    set(FIG.radio.noise,'value',0);
    
elseif strcmp(command_str,'noise')
    FIG.NewStim = 2;
    Stimuli.KHosc = 0;
    set(FIG.fsldr.val,'string','noise');
    set(FIG.radio.khite,'value',0);
    set(FIG.radio.tone,'value',0);
    
elseif strcmp(command_str,'khite')
    FIG.NewStim = 3;
    Stimuli.KHosc = 2;
    set(FIG.fsldr.val,'string','Osc');
    set(FIG.radio.tone,'value',0);
    set(FIG.radio.noise,'value',0);
    
elseif strcmp(command_str,'fast')
    FIG.NewStim = 4;
    set(FIG.radio.slow,'value',0);
    Stimuli.duration =  50;
    Stimuli.period   = 250;
    
elseif strcmp(command_str,'slow')
    FIG.NewStim = 4;
    set(FIG.radio.fast,'value',0);
    Stimuli.duration =  200;
    Stimuli.period   = 1000;
    
elseif strcmp(command_str,'left')
    FIG.NewStim = 5;
    Stimuli.channel = 2;
    set(FIG.radio.right,'value',0);
    set(FIG.radio.both,'value',0);
    
elseif strcmp(command_str,'right')
    FIG.NewStim = 5;
    Stimuli.channel = 1;
    set(FIG.radio.left,'value',0);
    set(FIG.radio.both,'value',0);
    
elseif strcmp(command_str,'both')
    FIG.NewStim = 5;
    Stimuli.channel = 3;
    set(FIG.radio.left,'value',0);
    set(FIG.radio.right,'value',0);
    
elseif strcmp(command_str,'slide_freq')
    FIG.NewStim = 6;
    Stimuli.freq_hz = floor(get(FIG.fsldr.slider,'value')*Stimuli.fmult);
    set(FIG.fsldr.val,'string',num2str(Stimuli.freq_hz));
    
    % LQ 01/28/05
elseif strcmp(command_str,'slide_freq_text')
    FIG.NewStim = 6;
    new_freq = str2double(get(FIG.fsldr.val, 'string'));
    if new_freq < get(FIG.fsldr.slider,'min')*Stimuli.fmult || ...
            new_freq > get(FIG.fsldr.slider,'max')*Stimuli.fmult
        set(FIG.fsldr.val,'string',num2str(Stimuli.freq_hz));
    else
        Stimuli.freq_hz = new_freq;
        set(FIG.fsldr.slider, 'value', Stimuli.freq_hz/Stimuli.fmult);
    end
    
elseif strcmp(command_str,'mult_1x')
    Stimuli.fmult = 1;
    set(FIG.push.x1,'foregroundcolor',[0 0 0]);
    set(FIG.push.x10,'foregroundcolor',[.6 .6 .6]);
    set(FIG.push.x100,'foregroundcolor',[.6 .6 .6]);
    FIG.NewStim = 6; %LQ 01/31/05
    Stimuli.freq_hz = floor(get(FIG.fsldr.slider,'value')*Stimuli.fmult);
    set(FIG.fsldr.val,'string',num2str(Stimuli.freq_hz));
    
elseif strcmp(command_str,'mult_10x')
    Stimuli.fmult = 10;
    set(FIG.push.x1,'foregroundcolor',[.6 .6 .6]);
    set(FIG.push.x10,'foregroundcolor',[0 0 0]);
    set(FIG.push.x100,'foregroundcolor',[.6 .6 .6]);
    FIG.NewStim = 6;
    Stimuli.freq_hz = floor(get(FIG.fsldr.slider,'value')*Stimuli.fmult);
    set(FIG.fsldr.val,'string',num2str(Stimuli.freq_hz));
    
elseif strcmp(command_str,'mult_100x')
    Stimuli.fmult = 100;
    set(FIG.push.x1,'foregroundcolor',[.6 .6 .6]);
    set(FIG.push.x10,'foregroundcolor',[.6 .6 .6]);
    set(FIG.push.x100,'foregroundcolor',[0 0 0]);
    FIG.NewStim = 6;
    Stimuli.freq_hz = floor(get(FIG.fsldr.slider,'value')*Stimuli.fmult);
    set(FIG.fsldr.val,'string',num2str(Stimuli.freq_hz));
    
elseif strcmp(command_str,'slide_atten')
    FIG.NewStim = 7;
    Stimuli.atten = floor(-get(FIG.asldr.slider,'value'));
    set(FIG.asldr.val,'string',num2str(-Stimuli.atten));
    % LQ 01/28/05
elseif strcmp(command_str, 'slide_atten_text')
    FIG.NewStim = 7;
    new_atten = get(FIG.asldr.val, 'string');
    if new_atten(1) ~= '-'
        new_atten = ['-' new_atten];
        set(FIG.asldr.val,'string', new_atten);
    end
    new_atten = str2double(new_atten);
    if new_atten < get(FIG.asldr.slider,'min') || new_atten > get(FIG.asldr.slider,'max')
        set( FIG.asldr.val, 'string', num2str(-Stimuli.atten));
    else
        Stimuli.atten = -new_atten;
        set(FIG.asldr.slider, 'value', new_atten);
    end
    
    % added by GE 17Jan2003.
elseif strcmp(command_str,'spike_channel')
    Stimuli.spike_channel = get(FIG.popup.spike_channel,'value');
    
    
elseif strcmp(command_str,'invCalib')
    if NelData.General.RP2_3and4 || NelData.General.RX8
%  OLD:       [~, Stimuli.calibPicNum]= run_invCalib(get(FIG.radio.invCalib,'value'));
        
        
        % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        cdd;
        allCalibs= dir('p*calib*raw*');
        all_calib_picNums= cell2mat(cellfun(@(x) getPicNum(x), {allCalibs.name}', 'UniformOutput', false));
        CalibPicNum = inputdlg('Enter RAW Calibration Pic number:                [Cancel]=Use average calibration','Calibration Pic',1,{num2str(max(all_calib_picNums))});
        if ~isempty(CalibPicNum)
            CalibPicNum = str2double(CalibPicNum{1});
        else
            CalibPicNum = 1;
        end
        
        %AS/MP | inverse filtering,
        % send the raw calib pic num to set_invFilter
        % pull the inv calibration coefficients from
        
        filttype = {'inversefilt','inversefilt'};
        invfiltdata = set_invFilter(filttype, CalibPicNum);
%           raw_pic_file = CalibPicNum;
        
        %Now loading INVERSE calib.
        Stimuli.calibPicNum = invfiltdata.CalibPICnum2use;
        rdd;
        
    elseif isnan(Stimuli.calibPicNum)
        cdd;
        allCalibFiles= dir('*calib*raw*');
        Stimuli.calibPicNum= getPicNum(allCalibFiles(end).name);
        Stimuli.calibPicNum= str2double(inputdlg('Enter Calibration File Number','Load Calib File', 1,{num2str(Stimuli.calibPicNum)}));
        rdd;
    end
    
elseif strcmp(command_str,'close')
    if NelData.General.RP2_3and4 || NelData.General.RX8
        filttype = {'allstop','allstop'};
        invfiltdata = set_invFilter(filttype,1);
%         run_invCalib(false); % Initialize with allpass RP2_3
    end
    set(FIG.push.close,'Userdata',1);
end