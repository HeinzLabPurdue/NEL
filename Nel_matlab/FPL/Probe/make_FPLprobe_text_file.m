global NelData 

fname = current_data_file('FPLprobe',1);

%% General NEL data saving
x.General.program_name  = PROG;
x.General.version = VERSION;
x.General.picture_number = NelData.File_Manager.picture+1;
x.General.track          = NelData.File_Manager.track.No;
x.General.unit           = NelData.File_Manager.unit.No;
x.General.date          = date;
x.General.time          = datestr(now,13);
x.General.spike_res     = 1e-5;
x.General.spike_unit    = 'sec';
x.General.timing_unit   = 'ms';
x.General.comment       = calib.comment;

x.Stimuli = [];  % general NEL structures - NOT used here, but keep for generality 
x.Line    = [];
x.User = [];
x.Hardware.NELmaxvolts_V   = VOLTS;   % max volts in NEL circuit design
x.invfilterdata = invfilterdata;  

%% saving specific MEMR data
x.FPLprobeData.calib = calib;

% Save to ProbeCal_Data folder for use later since general for that day
curdir = pwd; 
cd('C:\NEL\Nel_matlab\FPL\Probe\ProbeCal_Data')

generalfname = ['FPLprobe_' date '*.mat'];
if isempty(dir(generalfname))
    numFiles = 0; 
else 
    numFiles = max(size((dir(generalfname)))); 
end 
mainfilename = sprintf('%s_%d', generalfname(1:end-5), numFiles+1); 
save(mainfilename,'x');  % std mat file
fprintf('%s %s.mat\n','Saved data file to general folder: ',mainfilename);
cd(curdir); 

%% Save data file
MfileSAVE=0;
if MfileSAVE
    rc = write_nel_data(fname,x,0);
    while (rc < 0)
        title_str = ['Choose a different file name! Can''t write to ''' fname ''''];
        [fname, dirname] = uiputfile([fileparts(fname) filesep '*.m'],title_str);
        rc = write_nel_data(fullfile(dirname,fname),x,0);
    end
    fprintf('%s %s.m\n','Saved data file: ',fname);
else
    save(fname,'x');  % std mat file
    fprintf('%s %s.mat\n','Saved data file: ',fname);
end
NelData.File_Manager.picture = NelData.File_Manager.picture+1;  % update pic num
