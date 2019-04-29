function [tmplt,DAL,stimulus_vals,units,errstr] = BBNlong_template(fieldname,stimulus_vals,units)


global signals_dir

used_devices.list         = 'L3';
tmplt = template_definition(fieldname);
if (exist('stimulus_vals','var') == 1)
    stim_dir=strcat(signals_dir,'KH\BBNlong');
    
    if isempty(stimulus_vals.Inloop.BaseUpdateRate)
        stimulus_vals.Inloop.BaseUpdateRate=33000;  % Will get through, and let you change later
    end
    Fs=stimulus_vals.Inloop.BaseUpdateRate;
    
    if isempty(stimulus_vals.Inloop.CF_kHz)
        stimulus_vals.Inloop.CF_kHz=0.01;
        CF_kHz=stimulus_vals.Inloop.CF_kHz; 
    else
        CF_kHz=stimulus_vals.Inloop.CF_kHz; 
    end
    
    %    if isempty(stimulus_vals.Inloop.OCTshift)
    %       stimulus_vals.Inloop.OCTshift=0.5;
    %       OCTshift=stimulus_vals.Inloop.OCTshift; 
    %    else
    %       OCTshift=stimulus_vals.Inloop.OCTshift;  
    %    end
    %    BFbelowCF_kHz=CF_kHz*2^-OCTshift
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    BASELINE_Duration = 2200; % (in ms based on specific WAV files used)
    OFFtime = stimulus_vals.Gating.Period - stimulus_vals.Gating.Duration;
    stimulus_vals.Gating.Duration = BASELINE_Duration;
    stimulus_vals.Gating.Period = BASELINE_Duration + OFFtime;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %    %    [TONEatCF,TONEbelowCF]=createCFtone(CF_kHz,BASELINE_Duration,Fs,OCTshift); %CF in Hz and Dur in seconds
    %    TONEwf=createTone(CF_kHz,BASELINE_Duration,Fs,OCTshift); %CF in Hz and Dur in seconds
    %    
    %    wavwrite(TONEwf,Fs,fullfile(stim_dir,'TONEatCF'));
    %    wavwrite(-TONEwf,Fs,fullfile(stim_dir,'TONEatCF_N'));
    %    
    %    %    wavwrite(TONEbelowCF,Fs,fullfile(stim_dir,'TONEbelowCF'));
    %    %    wavwrite(-TONEbelowCF,Fs,fullfile(stim_dir,'TONEbelowCF_N'));
    %    
    %    if (exist(stimulus_vals.Inloop.List_File,'file') ~= 0)
    %       [Llist,Rlist] = read_rotate_list_file(stimulus_vals.Inloop.List_File);
    %       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %       [data fs] = wavread(Llist{1});
    %       [stimulus_vals units] = NI_check_gating_params(stimulus_vals, units);%optional??
    %       [stimulus_vals.Mix units.Mix] = structdlg(tmplt.IO_def.Mix,'',stimulus_vals.Mix,'off');
    %       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%       
    %    else
    %       Llist = [];
    %       Rlist = [];
    %       prev_maxlen = 0;
    %    end
    
    count=0;
    for i=1:5
        count=count+1;
        Llist{count}=[signals_dir '\KH\BBNlong\BBN' num2str(i) '_P'];
        count=count+1;
        Llist{count}=[signals_dir '\KH\BBNlong\BBN' num2str(i) '_N'];
    end
    Rlist=[];
    %    if (isempty(stimulus_vals.Inloop.CalibPicNum))
    %       CalibPic=inputdlg('Enter Calibration picture number');
    %       stimulus_vals.Inloop.CalibPicNum=str2double(CalibPic);
    %    end
    
    %    %%% Account for Calibration    
    %    if ~isempty(stimulus_vals.Inloop.CalibPicNum)
    %       if stimulus_vals.Inloop.CalibPicNum==0
    %          min_dBatten=20;
    %       else
    %          cdd
    %          if ~isempty(dir(sprintf('p%04d_calib.m',stimulus_vals.Inloop.CalibPicNum)))
    %             x=loadpic(stimulus_vals.Inloop.CalibPicNum);
    %             CalibData=x.CalibData(:,1:2);
    %             CalibData(:,2)=trifilt(CalibData(:,2)',5)';
    %             Inloop.params.CalibPicNum= stimulus_vals.Inloop.CalibPicNum;
    %             LevelatCF_dBSPL=CalibInterp(CF_kHz,CalibData);
    %             %LevelatBF=CalibInterp(BFbelowCF_kHz,CalibData);
    %             min_dBatten=round(abs(LevelatCF_dBSPL-85));
    %          else
    %             %max_dBSPL=[];
    %             %Inloop.params.CalibPicNum=NaN;
    %             nelerror('CalibPic not found');
    %          end
    %          rdd
    %       end
    %    else
    %       min_dBatten=20;
    %    end
    %    
    
%     AttensList=[stimulus_vals.Inloop.High_Attenuation :-stimulus_vals.Inloop.dBstep_Atten:stimulus_vals.Inloop.Low_Attenuation];
%     
%     if stimulus_vals.Inloop.High_Attenuation==stimulus_vals.Inloop.Low_Attenuation
%         AttensList=stim_vals.Inloop.High_Attenuation;
%     end
    AttensList=stimulus_vals.Inloop.High_Attenuation;
    
    condIND=0;
    for AttenInd=1:length(AttensList)
        for ListInd=1:length(Llist)
            condIND=condIND+1;
            List{condIND}=Llist{ListInd};
            Atten_dB_List(condIND)=AttensList(AttenInd); 
            Used_UpdateRate_Hz(condIND)=NI6052UsableRate_Hz(Fs);
        end
    end
    
    %    condIND=0;
    %    
    %    for AttenIND=1:length(AttensList)
    %       %       for ListIND=1:length(Llist)
    %       condIND=condIND+1;
    %       List{condIND}=Llist{1};
    %       Atten_dB_List(condIND)=AttensList(AttenIND);   
    %       Used_UpdateRate_Hz(condIND)=NI6052UsableRate_Hz(Fs);
    %       %       end
    %    end
    
    
    
    stimulus_vals.Inloop.Used_UpdateRate_Hz=Used_UpdateRate_Hz;
    stimulus_vals.Inloop.List=List;
    stimulus_vals.Inloop.Atten_dB_List=Atten_dB_List;
    
    list=stimulus_vals.Inloop.List;
    
    [stimulus_vals units] = NI_check_gating_params(stimulus_vals, units);
    [stimulus_vals.Mix units.Mix] = structdlg(tmplt.IO_def.Mix,'',stimulus_vals.Mix,'off');
    
    
    
    if (isempty(list))
        tmplt.IO_def.Mix = rmfield(tmplt.IO_def.Mix,'list');
    end
    
    %    Inloop.Name                                = 'DALinloop_NI_SCCi_wavfiles';
    Inloop.Name                               = 'DALinloop_NI_HTCi_wavfiles';
    
    Inloop.params.list                        = list;
    Inloop.params.Rlist                       = []; 
    Inloop.params.Rattens                     = []; 
    Inloop.params.attens                      = stimulus_vals.Inloop.Atten_dB_List;
    Inloop.params.Condition.ToneFreq_kHz      = stimulus_vals.Inloop.CF_kHz;
    Inloop.params.repetitions                 = stimulus_vals.Inloop.Repetitions;
    Inloop.params.updateRate_Hz               = stimulus_vals.Inloop.Used_UpdateRate_Hz;
    Inloop.params.Condition.InvertPolarity    = 'no';
    DAL.funcName = 'data_acquisition_loop_NI'; 
    DAL.Inloop = Inloop;
    DAL.Gating = stimulus_vals.Gating;
    DAL.short_description   = 'BBNlong';
    
    
    DAL.Mix         = mix_params2devs(stimulus_vals.Mix,used_devices);
    
    DAL.description = build_description(DAL,stimulus_vals);
    errstr = check_DAL_params(DAL,fieldname);
    
    %%%%%%%
    % If parameters are NOT correct for this template, Take away this template name
    %    if((stimulus_vals.Inloop.Frequency ~= 2)|(length(DAL.Inloop.params.main.attens) == 1))
    %       DAL.short_description   = '';
    %    end
    %latest_user_attn(stimulus_vals.Inloop.High_Attenuation);
end

%----------------------------------------------------------------------------------------
function str = build_description(DAL,stimulus_vals)
% p = DAL.Inloop.params;
p=stimulus_vals.Inloop;
str{1} = sprintf('CF %1.2f kHz ', p.CF_kHz);

if (length(DAL.Inloop.params.attens) > 1)
    str{1} = sprintf('%s @ %1.1f - %1.1f dB Attn.', str{1}, DAL.Inloop.params.attens(1), DAL.Inloop.params.attens(end));
else
    str{1} = sprintf('%s @ %1.1f dB Attn.', str{1}, DAL.Inloop.params.attens(1));
end
% str{1} = sprintf('%s (%s)', str{1}, stimulus_vals.Mix.Tone);

%----------------------------------------------------------------------------------------
function errstr = check_DAL_params(DAL,fieldname)
% Some extra error checks
errstr = '';
% if (isequal(fieldname,'Inloop'))
%    if (isempty(DAL.Inloop.params.main.attens))
%       errstr = 'Attenuations are not set correctly! (high vs. low mismatch?)';
%    end
%    if (isempty(DAL.Inloop.params.main.tone.freq))
%       errstr = 'Tone Frequency is empty!)';
%    end
% end

%----------------------------------------------------------------------------------------
function tmplt = template_definition(fieldname)
%% DEFS: {Value Units Allowed-range Locked ??}
global signals_dir
persistent prev_unit_bf prev_unit_thresh
%%%%%%%%%%%%%%%%%%%%
%% Inloop Section 
%%%%%%%%%%%%%%%%%%%%
IO_def.Inloop.List_File         = { {['uigetfile(''' signals_dir 'Lists\SK\BBNatCF\BBNrlv.m'')']} };
% IO_def.Inloop.CalibPicNum       = {[]   ''       [0 6000]};

IO_def.Inloop.Low_Attenuation   = {60  'dB'   [0    120] 0 0};
IO_def.Inloop.High_Attenuation  = {60  'dB'   [0    120] 0 0};
IO_def.Inloop.CF_kHz            = {'current_unit_bf'   'kHz'      [0.01  50] };
% IO_def.Inloop.OCTshift          = {0   ''       [0 1]};
IO_def.Inloop.dBstep_Atten      = {5                'dB'       [1    10]   };
IO_def.Inloop.Repetitions       = {100                 ''       [1 600]};
IO_def.Inloop.BaseUpdateRate    = {33000                  'Hz'      [1    NI6052UsableRate_Hz(Inf)]      };
%IO_def.Inloop.Noise_Attenuation =  {10               'dB'    [0    120]      };
if (~isequal(current_unit_bf, prev_unit_bf) & isequal(fieldname,'Inloop'))
    %    IO_def.Inloop.CF_kHz{5}            = 1; % ignore dflt. Always recalculate.
    prev_unit_bf = current_unit_bf;
end
if (~isequal(current_unit_thresh, prev_unit_thresh) & isequal(fieldname,'Inloop'))
    IO_def.Inloop.High_Attenuation{5}           = 1; % ignore dflt. Always recalculate.
    IO_def.Inloop.Low_Attenuation{5}            = 1; % ignore dflt. Always recalculate.
    prev_unit_thresh = current_unit_thresh;
end
%%%%%%%%%%%%%%%%%%%%
%% Gating Section 
%%%%%%%%%%%%%%%%%%%%
IO_def.Gating.Duration             = {2200      'ms'    [20 2500]};
IO_def.Gating.Period               = {2700      'ms'    [50 5000]};
IO_def.Gating.Rise_fall_time       = {'default_rise_time(this.Duration)' 'ms'   [0  1000]}; 
%%%%%%%%%%%%%%%%%%%%
%% Mix Section 
%%%%%%%%%%%%%%%%%%%%
IO_def.Mix.list        =  {'Left|Both|{Right}'};

tmplt.tag         = 'BBNlong_tmplt';
tmplt.IO_def = IO_def;
