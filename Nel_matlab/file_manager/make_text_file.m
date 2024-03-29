function make_text_file(block_info,stim_info,comment,trigger,error_strs)
% make_text_file(block_info,stim_info,comment,trigger)

% AF 11/13/01

global RP PA Trigger SwitchBox 
global ProgName NelData EPdata

if (exist('EP_nChannels','var') ~= 1)   % will need to be supplied if more than 1 channel is acquired
   EP_nChannels = 1;
end

fname = current_data_file(block_info.short_description);

MAXerrlines=60;  
if (length(error_strs) > MAXerrlines)
   error_strs{MAXerrlines+1} = 'Too many errors for data file. For complete listing use the error log file.';
   error_strs = error_strs(1:MAXerrlines+1);
end
x.General.WinHostName    = NelData.General.WindowsHostName;
x.General.WinUserName    = NelData.General.WindowsUserName;
x.General.RootDir        = NelData.General.RootDir;
x.General.program_name   = ProgName;
x.General.picture_number = NelData.File_Manager.picture+1;
x.General.track          = NelData.File_Manager.track.No;
x.General.unit           = NelData.File_Manager.unit.No;
x.General.date           = date;
x.General.time           = datestr(now,13);
x.General.spike_res      = 1e-5;
x.General.spike_unit     = 'sec';
x.General.timing_unit    = 'ms';
x.General.comment        = comment;
x.General.trigger        = trigger;
x.General.run_errors     = error_strs;

%Remove notch noise sweep stimulus files from data to be saved when running notchnoise_frequency_sweep
if (isfield(block_info,'stim_matrix'));         %added by LR 14Nov2003
   disp('removing stim_matrix');
   block_info=rmfield(block_info,'stim_matrix');
end

x.Stimuli = block_info;
x.Line    = compress_stim_info(stim_info, block_info);

% x.User = [];

x.Hardware.RP = rmfield(RP,{'activeX','params_in'});
x.Hardware.Trigger  = Trigger.params;

% include EP collection parameters:     % added by GE 01Mar2002.
save_EP_data = 0;
meanEPdata = cell(1, EP_nChannels);
nRows = 0;
for i_ep = 1:EP_nChannels
    x.EP(i_ep).record = NelData.General.EP(i_ep).record;
   	if ( x.EP(i_ep).record == 1);
        save_EP_data = 1;
        % Add the mean EP data to "meanEPs.mat" in current data directory.
             % will need to be further modified when multiple EP channels are allowed
             %   because EP_nChannels could change from picture to picture.
        meanEP_filename = sprintf ('%smeanEPs.mat', NelData.File_Manager.dirname);
        fid = fopen(meanEP_filename);
        if ( fid ~= -1 )
            fclose(fid);
            load(meanEP_filename, 'meanEPdata');
            nRows = size(meanEPdata{1,i_ep},1);
        end
        meanEPdata{1,i_ep}{nRows+1,1} = NelData.General.EP(i_ep).sampleInterval*[1:NelData.General.EP(i_ep).lineLength];
        meanEPdata{1,i_ep}{nRows+1,2} = EPdata.aveY;
        meanEPdata{1,i_ep}{nRows+1,3} = x.General.picture_number;
        save(meanEP_filename, 'meanEPdata');
    end
   
	x.EP(i_ep).start = NelData.General.EP(i_ep).start;
	x.EP(i_ep).duration = NelData.General.EP(i_ep).duration;
	x.EP(i_ep).sampleInterval = NelData.General.EP(i_ep).sampleInterval;
	x.EP(i_ep).lineLength = NelData.General.EP(i_ep).lineLength;
	x.EP(i_ep).lastN = NelData.General.EP(i_ep).lastN;
   x.EP(i_ep).nClipped = NelData.General.EP(i_ep).nClipped;  
   x.EP(i_ep).saveALLtrials = NelData.General.EP(i_ep).saveALLtrials;
   x.EP(i_ep).decimate = NelData.General.EP(i_ep).decimate;
   x.EP(i_ep).decimateFactor = NelData.General.EP(i_ep).decimateFactor;
end

% Pulse output info.  Added by GE, 04Feb2003.
x.General.pulse.enabled          = NelData.General.Pulse.enabled;
x.General.pulse.delay_msec       = NelData.General.Pulse.delay;
x.General.pulse.nPulses          = NelData.General.Pulse.nPulses;
x.General.pulse.interPulse_msec  = NelData.General.Pulse.interPulse;

% rc = write_nel_data(fname,x,1);
rc = write_nel_data(fname,x,1,save_EP_data);   % modified to include saving EP data, if necessary
while (rc < 0)
   title_str = ['Choose a different file name! Can''t write to ''' fname ''''];
   [fname dirname] = uiputfile([fileparts(fname) filesep '*.m'],title_str);
   rc = write_nel_data(fullfile(dirname,fname),x,1,save_EP_data);   % modified by GE 04Mar2002.
end
NelData.File_Manager.picture = NelData.File_Manager.picture+1;