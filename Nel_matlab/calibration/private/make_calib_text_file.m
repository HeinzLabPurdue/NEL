function NelData=make_calib_text_file(fname, NelData, Stimuli, comment, PROG, DDATA, SRdata)


x.General.program_name   = PROG;
x.General.picture_number = NelData.File_Manager.picture+1;
x.General.date           = date;
x.General.time           = datestr(now,13);
x.General.comment        = comment;

%store the parameter block

x.Stimuli.frqlo  = Stimuli.frqlo;
x.Stimuli.frqhi  = Stimuli.frqhi;

% fstlin  = 0.000;			%linear frequency step (in kHz) (set = 0 for log steps)
% fstoct  =10.000;			%log frequency step (in octaves) (set = 0 for lin steps)

x.Stimuli.fstlin = Stimuli.fstlin;
x.Stimuli.fstoct = Stimuli.fstoct;
x.Stimuli.bplo   = Stimuli.bplo;
x.Stimuli.bphi   = Stimuli.bphi;
x.Stimuli.n60lo  = Stimuli.n60lo;
x.Stimuli.n60hi  = Stimuli.n60hi;
x.Stimuli.n120lo = Stimuli.n120lo;
x.Stimuli.n120hi = Stimuli.n120hi;

x.Stimuli.ear   = Stimuli.ear;

x.Stimuli.BaseAtten  = Stimuli.syslv;
x.Stimuli.SlopeAtten = Stimuli.lvslp;
x.Stimuli.BeginSlope = Stimuli.frqcnr;
x.Stimuli.is_dBSPL   = Stimuli.cal;
x.Stimuli.crit       = Stimuli.crit;

x.Line    = [];
%store the data in three columns (freq SPL phase)
% DDATA = DDATA(1:min(find(DDATA(:,1)<=0))-1,1:3);

DDATA = DDATA(1:find(DDATA(:,1)<=0, 1)-1,:);
x.CalibData = DDATA;
% x.RawData= cell2mat(raw_data(cellfun(@(x) ~isempty(x), raw_data)));
% x.calib_time= calib_time;
x.User = [];

x.Hardware.mic        = Stimuli.nmic;
if Stimuli.cal
   x.Hardware.MicDate    = SRdata.date;
end

rc = write_nel_data(fname,x,0);
while (rc < 0)
   title_str = ['Choose a different file name! Can''t write to ''' fname ''''];
   [fname, dirname] = uiputfile([fileparts(fname) filesep '*.m'],title_str);
   rc = write_nel_data(fullfile(dirname,fname),x,0);
end
NelData.File_Manager.picture = NelData.File_Manager.picture+1;
