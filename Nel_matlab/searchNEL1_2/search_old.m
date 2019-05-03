function search(command_str)

%THIS IS THE MAIN PROGRAM FOR FINDING AND NAMING NEW UNITS
%     WAS CALLED NU.SAV IN OLD SYSTEM:


%THE FOLLOWING GLOBAL PARAMETERS ARE SHARED ACROSS FUNCTIONS

global SCREEN_SIZE PARAMS PROG root_dir NelData

if nargin < 1						   %program should be called without a command string
    PROG = 'search.v1';				   %program name is recorded in the data file
    DATE = date;
    
    PARAMS(1) =    50;    %attenuation dB
    PARAMS(2) =  5000;    %frequency Hz
%     PARAMS(3) =   200;    %on duration msec
%     PARAMS(4) =  1000;	  %off duration msec
    PARAMS(3) =    50;    %on duration msec
    PARAMS(4) =   250;	  %off duration msec
    PARAMS(5) =     0;	  %set to 0 for noise, 1 for tone
    PARAMS(6) =    10;    %freq multiplier
    
    command_str = 'initialize';
end
if ~strcmp(command_str,'initialize')
    handles = get(gcf,'Userdata');			
    h_text1 = handles(1);
    h_text2 = handles(2);
    h_text3 = handles(3);
    h_ax1   = handles(4);
    h_line1 = handles(5);
    h_ax2   = handles(6);   
    h_push_start = handles(7);
    h_push_stop  = handles(8);
    h_push_noise = handles(9);
    h_push_tone  = handles(10);
    h_push_khite = handles(11);
    h_push_fast  = handles(12);
    h_push_slow  = handles(13);
    h_push_analog= handles(14);
    h_push_close = handles(15);
    h_freq_sldr  = handles(16);
    h_min_freq   = handles(17);
    h_max_freq   = handles(18);
    h_val_freq   = handles(19);
    h_atten_sldr = handles(20);
    h_min_att    = handles(21);
    h_max_att    = handles(22);
    h_val_att    = handles(23);
    h_unit       = handles(24);
    h_push_update= handles(25);
    h_push_1x    = handles(26);
    h_push_10x   = handles(27);
    h_push_100x  = handles(28);
    h_push_left  = handles(29);
    h_push_right = handles(30);
    h_push_both  = handles(31);
end

if strcmp(command_str,'initialize');		   %initialize and display GUI
   h_fig = findobj('Tag','Search_Main_Fig');
   if (ishandle(h_fig))
      delete(h_fig);
   end
    h_fig = figure('NumberTitle','off','Name','Search Interface','Units','normalized','position',[0.045  0.013  0.9502  0.7474],'Visible','off','MenuBar','none','Tag','Search_Main_Fig');
    colordef none;
    whitebg('w');
    eval('nuplot');	
    feval('save',fullfile(root_dir,'search','workspace','nubjm'),'PARAMS','PROG');
    % PAco1=actxcontrol('PA5.x',[0 0 1 1]);
    %     invoke(PAco1,'Connect',4,1);
    %     invoke(PAco1,'SetAtten',120.0);
    set(h_fig,'Visible','on');
    eval('nu');
    
elseif strcmp(command_str,'start')
    PARAMS(1) = get(h_val_att,'Userdata');
    PARAMS(2) = get(h_val_freq,'Userdata');
    PARAMS(3) = get(h_push_fast,'Userdata');
    PARAMS(4) = get(h_push_slow,'Userdata');
    PARAMS(5) = get(h_push_noise,'Userdata');
    PARAMS(6) = get(h_push_1x,'Userdata');
    eval('nu');
    
elseif strcmp(command_str,'stop')
    set(h_push_stop,'Userdata',1);
    
elseif strcmp(command_str,'tone')
    PARAMS(5)=1;
    set(h_val_freq,'string',num2str(PARAMS(2)));
    set(h_push_khite,'value',0);
    set(h_push_noise,'value',0);
    set(h_push_khite,'Userdata',0);
    set(h_push_noise,'Userdata',1);
    set(h_push_10x,'Userdata',4);
    
elseif strcmp(command_str,'noise')
    PARAMS(5)=0;
    set(h_val_freq,'string','noise');
    set(h_push_khite,'value',0);
    set(h_push_tone,'value',0);
    set(h_push_khite,'Userdata',0);
    set(h_push_noise,'Userdata',0);
    set(h_push_10x,'Userdata',4);
    
elseif strcmp(command_str,'khite')
    PARAMS(5)=0;
    set(h_val_freq,'string','KH Osc');
    set(h_push_noise,'value',0);
    set(h_push_tone,'value',0);
    set(h_push_khite,'Userdata',2);
    set(h_push_noise,'Userdata',-1);
    set(h_push_10x,'Userdata',4);
    
elseif strcmp(command_str,'fast')
    PARAMS(3) =  50;
    PARAMS(4) = 250;
    set(h_push_fast,'Userdata',PARAMS(3));
    set(h_push_slow,'value',0);
    set(h_push_slow,'Userdata',PARAMS(4));
    set(h_push_10x,'Userdata',3);
    
elseif strcmp(command_str,'slow')
    PARAMS(3) = 200;
    PARAMS(4) =1000;
    set(h_push_fast,'value',0);
    set(h_push_fast,'Userdata',PARAMS(3));
    set(h_push_slow,'Userdata',PARAMS(4));
    set(h_push_10x,'Userdata',3);
    
elseif strcmp(command_str,'left')
    set(h_push_left,'Userdata',1);
    set(h_push_right,'value',0);
    set(h_push_both,'value',0);
    set(h_push_10x,'Userdata',5);
    
elseif strcmp(command_str,'right')
    set(h_push_left,'Userdata',2);
    set(h_push_left,'value',0);
    set(h_push_both,'value',0);
    set(h_push_10x,'Userdata',5);
    
elseif strcmp(command_str,'both')
    set(h_push_left,'Userdata',3);
    set(h_push_left,'value',0);
    set(h_push_right,'value',0);
    set(h_push_10x,'Userdata',5);
    
elseif strcmp(command_str,'slide_freq')
    if ~PARAMS(5),
        PARAMS(5)=1;
        set(h_push_noise,'Userdata',1);
    end
    PARAMS(2) = floor(get(h_freq_sldr,'value')*PARAMS(6));
    set(h_val_freq,'string',num2str(PARAMS(2)));
    set(h_val_freq,'Userdata',PARAMS(2));
    set(h_push_10x,'Userdata',2);
    
elseif strcmp(command_str,'mult_1x')
    PARAMS(6) = 1;
    set(h_push_1x,'Userdata',PARAMS(6));
    set(h_push_1x,'foregroundcolor',[0 0 0]);
    set(h_push_10x,'foregroundcolor',[.6 .6 .6]);
    set(h_push_100x,'foregroundcolor',[.6 .6 .6]);
    
elseif strcmp(command_str,'mult_10x')
    PARAMS(6) = 10;
    set(h_push_1x,'Userdata',PARAMS(6));
    set(h_push_1x,'foregroundcolor',[.6 .6 .6]);
    set(h_push_10x,'foregroundcolor',[0 0 0]);
    set(h_push_100x,'foregroundcolor',[.6 .6 .6]);
    
elseif strcmp(command_str,'mult_100x')
    PARAMS(6) = 100;
    set(h_push_1x,'Userdata',PARAMS(6));
    set(h_push_1x,'foregroundcolor',[.6 .6 .6]);
    set(h_push_10x,'foregroundcolor',[.6 .6 .6]);
    set(h_push_100x,'foregroundcolor',[0 0 0]);
    
elseif strcmp(command_str,'slide_atten')
    PARAMS(1) = floor(-get(h_atten_sldr,'value'));
    set(h_val_att,'string',num2str(-PARAMS(1)));
    set(h_val_att,'Userdata',PARAMS(1));
    set(h_push_10x,'Userdata',1);
    
elseif strcmp(command_str,'update')
   %     UNIT = get(h_unit,'string');
   %     set(h_text2,'string',{PROG DATE UNIT});
   %     % cd(fullfile(strtok(matlabroot,filesep),'matlab_user','file_manager',''));
   %     make_explist;
   %     % cd(fullfile(strtok(matlabroot,filesep),'matlab_user','search','functions',''));	
    
elseif strcmp(command_str,'analog')
   %     set(h_push_stop,'Userdata',1);
   %     atten = (get(h_val_att,'Userdata'));
   %     if get(h_push_noise,'Userdata');
   %         freq = (get(h_val_freq,'Userdata'));
   %     else
   %         freq = 0;
   %     end
   %     analog_record(freq,atten); disp('ANALOG_REC?????!!!!!!')
   %     PARAMS(1) = get(h_val_att,'Userdata');
   %     PARAMS(2) = get(h_val_freq,'Userdata');
   %     PARAMS(3) = get(h_push_fast,'Userdata');
   %     PARAMS(4) = get(h_push_slow,'Userdata');
   %     PARAMS(5) = get(h_push_noise,'Userdata');
   %     PARAMS(6) = get(h_push_1x,'Userdata');
   %     eval('nu');
    
elseif strcmp(command_str,'close')
    close('Search Interface');
    % clear all
end

