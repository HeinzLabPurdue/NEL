function new_unit(cur_unit,cur_track_no,new_bf_thresh,show_dlg,dlg_pos,no_lock)
% new_track(cur_track_no)

% AF 12/2/01
% MH 6/6/02

global NelData

if (exist('cur_unit','var') ~= 1 || isempty(cur_unit))
    cur_unit = NelData.File_Manager.unit.No +1;
end
if (exist('cur_track_no','var') ~= 1 || isempty(cur_track_no))
    cur_track_no = NelData.File_Manager.track.No;
end
if (exist('new_bf_thresh','var') ~= 1)
    new_bf_thresh = [];
end
if (exist('show_dlg','var') ~= 1)
    show_dlg = 'on';
end
if (exist('dlg_pos','var') ~= 1)
    dlg_pos = [];
end
if (exist('no_lock','var') ~= 1)
    no_lock=0;
elseif (no_lock>0)
    no_lock=1;
end
if (cur_unit == 0)
    unit.No = 0;
    unit.depth = Inf;
    unit.comment = '';
    unit.BF      = 0;
    unit.Th      = 0;
    unit.SR      = -1;
    NelData.File_Manager.unit = unit;
    return;
end
if (cur_track_no == 0)
    nelwarn('Can''t add new unit for track #0!');
    return;
end
if (cur_unit == NelData.File_Manager.unit.No)
    if no_lock
        def.Unit_No        = {cur_unit sprintf('Track #%d',cur_track_no)  [1 999]}; % don't `protect field
    else
        def.Unit_No        = {cur_unit sprintf('Track #%d',cur_track_no)  [1 999]  1}; % protect field
    end
    def.Depth          = {NelData.File_Manager.unit.depth 'micr.' [NelData.File_Manager.track.depth Inf]};
    def.Comment        = {[NelData.File_Manager.unit.comment repmat(' ',1,60-length(NelData.File_Manager.unit.comment))]};
    def.BF             = {NelData.File_Manager.unit.BF 'kHz' [0.04 100] };
    def.Th             = {NelData.File_Manager.unit.Th 'dB Attn' [0 120] };
    def.SR             = {NelData.File_Manager.unit.SR 'per sec' [0 200] };
    title = 'Edit Current Unit';
else 
    def.Unit_No        = {cur_unit '' [1 999]};
    def.Depth          = {Inf 'micr.' [NelData.File_Manager.track.depth Inf]};
    def.Comment        = {repmat(' ',1,60)};
    def.BF             = {[] 'kHz' [0.04 100] };
    def.Th             = {[] 'dB Attn' [0 120] };
    def.SR             = {[] 'per sec' [0 200] };
    title = ['New Unit (Current Track #' int2str(NelData.File_Manager.track.No) ' Unit #' int2str(cur_unit-1) ')'];
end

inp = structdlg(def, title, new_bf_thresh,show_dlg,[],dlg_pos);
while (length(inp.Unit_No) ~= 1 || inp.Unit_No ~= round(inp.Unit_No))
    inp = structdlg(def, ['UNIT # MUST BE A SINGLE INTEGER (Current Track #' int2str(NelData.File_Manager.track.No) ' Unit #' int2str(cur_unit) ')']);
end
unit.No      = inp.Unit_No;
unit.depth   = inp.Depth;
unit.comment = strtrim(inp.Comment);
unit.BF      = inp.BF;
unit.Th      = inp.Th;
unit.SR      = inp.SR;
NelData.File_Manager.unit = unit;
fname = sprintf('%sUnit_%d_%02d',NelData.File_Manager.dirname,NelData.File_Manager.track.No,unit.No);
unit.track = NelData.File_Manager.track.No;
rc = write_nel_data(fname,unit,0);
if (rc ~= 1)
    nelerror(['Can''t save unit info to ''' fname '''']);
end
