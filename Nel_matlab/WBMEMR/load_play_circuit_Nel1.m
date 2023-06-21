
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [f1,RP,FS]=load_play_circuit_Nel1(FS_tag,fig_num,GB_ch)
% Loads the TDT circuit and makes actx links necessary
% The TDT matlab syntax has now changed to look more
% like OOPS but this old style is still supported.
%
%------------
% Hari Bharadwaj, September 6, 2010
%------------
warning('off'); 

global NelData
CIR_PATH='C:\NEL\Nel_matlab\WBMEMR\BasicPlay_OAE_Nel1.rcx'; %The *.rco circuit used to play the files

% DPOAE - Build config structures [1st number is LEFT channel; 2nd number is RIGHT channel in TDT]
% RP2-1-out1 is NOT USED
% RP2-1-out2 is NOT USED
% RP2-2-out1 is routed through PA5-1&3
% RP2-2-out2 is routed through PA5-2&4
% RP2-2-in1 is microphone
% DPOAE - Set left/right SwitchBox (SB) parameters [ear not USED]
left_SB  = 1;
right_SB = 2;
config = struct('atten',[1 1],'sel',[5 0],'conn',[2 1]); %[1st number is lEFT channel; 2nd number is RIGHT channel in TDT]

%Generate the actx control window in a specified figure:
%-------------------------------------------------------
f1=figure(fig_num);
set(f1,'Position',[0 0 1 1],'Visible','off'); %places and hides the ActX Window
RP=actxcontrol('RPco.x',[0 0 1 1],f1); %loads the actx control for using rco circuits
rc = invoke(RP,'ConnectRP2',NelData.General.TDTcommMode,2); 
% The rco circuit can be run at the following set of discrete sampling
% frequencies (in Hz): 0=6k, 1=12k, 2=25k, 3=50k, 4=100k, 5=200k.
% Use the tags listed above to specify below:
%--------------------------------------------------------------------------
rc = rc & invoke(RP,'LoadCOF',CIR_PATH); %loads the circuit using the specified sampling freq.
FS_vec=[6 12 24.4140625 48.828125 100 200]*1e3; %NOT EXACT!!!!!!!!!!!!!!!!!!!
FS=FS_vec(FS_tag+1);
rc = rc & invoke(RP,'SetTagVal','Select_R',config.sel(right_SB));
rc = rc & invoke(RP,'SetTagVal','Connect_R',config.conn(right_SB));
invoke(RP,'Run'); %start running the circuit

Status = double(invoke(RP,'GetStatus'));
if bitget(double(Status),1)==0
    error('Error connecting to RP2');
elseif bitget(double(Status),2)==0
    error('Error loading circuit');
elseif bitget(double(Status),3)==0
    error('Error running circuit');
end

% LOAD control circuit
% Set up the other RP2-1
% rc = 1;
% RPco1=actxcontrol('RPco.x',[0 0 1 1]);
% invoke(RPco1, 'ConnectRP2',NelData.General.TDTcommMode,1);
[RPco1, rc]= connect_tdt('RP2', 1);
rc = rc & invoke(RPco1,'LoadCof',['C:\NEL\Nel_matlab\WBMEMR\blank_left.rcx']);
rc = rc & invoke(RPco1,'SetTagVal','Select_L',config.sel(left_SB));
rc = rc & invoke(RPco1,'SetTagVal','Connect_L',config.conn(left_SB));
rc = rc & invoke(RPco1,'Run');
if (rc ~= 1)
    nelerror('dpoae.m: can''t load circuit to 1st RP2');
end

% End of load_play_circuit
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%