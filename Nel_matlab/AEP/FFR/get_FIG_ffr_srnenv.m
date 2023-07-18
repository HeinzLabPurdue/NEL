function [FIG, h_fig]=get_FIG_ffr_srnenv()

push = cell2struct(cell(1,5),{'forget_now', 'run_levels', 'Close', 'prev_stim', 'next_stim'},2);
radio = cell2struct(cell(1,7),{'fast', 'slow', 'left', 'right', 'both', 'atAD', 'atELEC'},2);
%radio = cell2struct(cell(1,8),{'fast','slow','left','right','both','chan_1','chan_2','Simultaneous','atAD', 'atELEC'},2);
statText  = cell2struct(cell(1,5),{'memReps', 'status', 'threshV', 'gain', 'voltDisplay'},2);
bg  = cell2struct(cell(1,3),{'spl','stim','nt'},2);
edit= cell2struct(cell(1,4),{'threshV','memReps','gain', 'yscale'},2);
asldr = cell2struct(cell(1,4),{'slider', 'min', 'max', 'val'},2);
ax = cell2struct(cell(1,7),{'axis', 'axis2', 'line', 'line2', 'line3', 'line4', 'ylabel'},2);
NewStim=0;
popup=cell2struct(cell(1,1),{'stims'},2);

FIG = struct('handle',[],'push',push,'radio',radio,'statText', statText,'bg',bg,'edit',edit,'asldr',asldr,'ax',ax, ...
    'NewStim',NewStim, 'popup', popup);


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