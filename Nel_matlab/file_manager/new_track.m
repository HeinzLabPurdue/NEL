function new_track(cur_track_no)
% new_track(cur_track_no)

% AF 12/2/01

global NelData

if (exist('cur_track_no','var') ~= 1 | isempty(cur_track_no))
   cur_track_no = NelData.File_Manager.track.No + 1;
end
if (cur_track_no == 0)
   track.No    = 0;
   track.depth = 0;
   track.comment = '';
   NelData.File_Manager.track = track;
   new_unit(0);
   return;
end
   
if (cur_track_no == NelData.File_Manager.track.No) 
   def.Track_No       = {cur_track_no '' [1 99]  1}; % protect field
   def.Starting_depth = {NelData.File_Manager.track.depth 'micr.' [0 Inf]};
   def.Comment        = {[NelData.File_Manager.track.comment repmat(' ',1,60-length(NelData.File_Manager.track.comment))]};
   title = 'Edit Current Track';
else
   def.Track_No       = {cur_track_no '' [1 99]}; 
   def.Starting_depth = {0 'micr.' [0 Inf]};
   def.Comment        = {repmat(' ',1,60)};
   title = ['New Track (Current Track #' int2str(NelData.File_Manager.track.No) ')'];
end

inp = structdlg(def, title);
while (length(inp.Track_No) ~= 1 | inp.Track_No ~= round(inp.Track_No))
   inp = structdlg(def, ['TRACK # MUST BE A SINGLE INTEGER (Current Track #' int2str(NelData.File_Manager.track.No) ')']);
end
track.No    = inp.Track_No;
track.depth = inp.Starting_depth;
track.comment = deblank(inp.Comment);
if (track.No ~= NelData.File_Manager.track.No)
   % Init new unit
   new_unit(0);
end
NelData.File_Manager.track = track;

fname = [NelData.File_Manager.dirname 'Track_' int2str(track.No)];
rc = write_nel_data(fname,track,0);
if (rc ~= 1)
   nelerror(['Can''t save track info to ''' fname '''']);
end
