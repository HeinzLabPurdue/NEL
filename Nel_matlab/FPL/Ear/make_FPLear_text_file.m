global NelData 

%% General NEL data saving
x.General.program_name  = PROG;
x.General.version = VERSION;
x.General.picture_number = NelData.File_Manager.picture+1;
x.General.date          = date;
x.General.time          = datestr(now,13);
x.General.comment       = calib.comment;

x.Stimuli = [];  % general NEL structures - NOT used here, but keep for generality 
x.Line    = [];
x.User = [];
x.Hardware.NELmaxvolts_V = VOLTS;   % max volts in NEL circuit design
%x.Hardware.CalibPICnum2use = calib.CalibPICnum2use;  % Save Calib file to use for these data - based on how hardware is setup (run-invCalib)

x.CalibData = CalibData;
x.CalibData2 = CalibData2;

x.chan_ord = [{'Left'}, {'Right'}]; % check value of ddata_struct_ear;
x.MetaData=NelData.Metadata;

x.NELdelay.delay_samps = [measuredDelay_1, measuredDelay_2]; 
x.NELdelay.delay_ms = [measuredDelay_1, measuredDelay_2]./calib.SamplingRate; 

%% saving specific FPL specific data
x.FPLearData = calib;

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
