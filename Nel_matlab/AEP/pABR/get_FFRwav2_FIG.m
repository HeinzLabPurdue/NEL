function [FIG, h_fig]=get_FFRwav2_FIG()


%%% AF/MH: Mar8 2024 - come back here to clean up with new objects


% Set up with 2 recording channel radio buttons
push = cell2struct(cell(1,7),{'forget_now', 'run_levels', 'Close', 'prev_stim', 'next_stim', 'prev_stim2', 'next_stim2'},2);
radio = cell2struct(cell(1,14),{'fast','slow','left','right','both','left2','right2','both2','no_audio2','chan_1','chan_2','Simultaneous','atAD', 'atELEC'},2);
statText  = cell2struct(cell(1,5),{'memReps', 'status', 'threshV', 'gain', 'voltDisplay'},2);
bg  = cell2struct(cell(1,3),{'spl','stim','nt'},2);
bg2  = cell2struct(cell(1,3),{'spl','stim','nt'},2);
edit= cell2struct(cell(1,4),{'threshV','memReps','gain', 'yscale'},2);
asldr = cell2struct(cell(1,4),{'slider', 'min', 'max', 'val'},2);
% AF 3-12-2024 try to add the second slider
asldr2 = cell2struct(cell(1,4),{'slider', 'min', 'max', 'val'},2);

ax = cell2struct(cell(1,7),{'axis', 'axis2', 'line', 'line2', 'line3', 'line4', 'ylabel'},2);
NewStim=0;
popup=cell2struct(cell(1,1),{'stims'},2);
popup2=cell2struct(cell(1,1),{'stims'},2);



FIG = struct('handle',[],'push',push,'radio',radio,'statText', statText,'bg',bg,'bg2',bg2,'edit',edit,'asldr',asldr,'asldr2',asldr2,'ax',ax, ...
    'NewStim',NewStim, 'popup', popup,'popup2', popup2);
% AF 3-12-24 added the handle for second slide in the struct 
% FIG = struct('handle',[],'push',push,'radio',radio,'statText', statText,'bg',bg,'edit',edit,'asldr',asldr,'asldr2',asldr2,'ax',ax, ...
%     'NewStim',NewStim, 'popup', popup);

FIG.handle = figure('NumberTitle','off','Name','FFR Interface','Units','normalized',...
    'position',[0.045  0.013  0.9502  0.7474],'Visible','off','MenuBar','none','Tag','FFR_Main_Fig');
set(FIG.handle,'CloseRequestFcn','FFR(''close'');')

colordef none;
whitebg('w');

h_fig = findobj('Tag','FFR_Main_Fig');    %% Finds handle for TC-Figure

if length(h_fig)>2
    h_fig=h_fig(1);
    warning('h_fig is not properly assigned!'); %#ok<WNTAG>
end