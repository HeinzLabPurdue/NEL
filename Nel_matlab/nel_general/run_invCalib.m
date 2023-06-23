%TODO FIX THIS AS/MH

% if doInvCalib= 0, all pass
% if doInvCalib= 1, inverse calib based on last coef* file
% if doInvCalib= -1, query allpass or invFIR
% if doInvCalib= -2, return b required from invFIR

function [coefFileNum, calibPicNum, b]= run_invCalib(doInvCalib)

%% Connecting to TDT modules
global COMM root_dir
object_dir = [root_dir 'calibration\object'];

[COMM.handle.RP2_4, status_rp2]= connect_tdt('RP2', 4);
[COMM.handle.RX8, status_rx8]= connect_tdt('RX8', 1);

if status_rp2 && status_rx8
    error('How are RP2#4 and RX8 both in the circuit?');
end

if doInvCalib~=-2
    if status_rp2
        invoke(COMM.handle.RP2_4,'LoadCof',[object_dir '\calib_invFIR_right.rcx']);
    elseif status_rx8 % Most call for run_invCalib are from NEL1. For NEL2 (with RX8), only needed for calibrate and dpoae.
        invoke(COMM.handle.RX8,'LoadCof',[object_dir '\calib_invFIR_right_RX8.rcx']);
    end
end


%% Define appropriate b for invCalib or allPass
curDir= pwd;
cdd;
all_Calib_files= dir('p*calib*raw*');
all_calib_picNums= cell2mat(cellfun(@(x) getPicNum(x), {all_Calib_files.name}', 'UniformOutput', false));

if doInvCalib==1
    all_Coefs_Files= dir('coef*');
    all_Coefs_picNums= cell2mat(cellfun(@(x) sscanf(x, 'coef_%04f_calib*'), {all_Coefs_Files.name}', 'UniformOutput', false));
    
    % Check if last calib file is the same as last coef file
    if max(all_calib_picNums)~=max(all_Coefs_picNums)
        %         warning('Last Calib file does not match last coef-file. Rerunning invCalib?');
        warning('All raw-files should have corresponding coef files?? Something wrong???');
    end
    [coefFileNum, max_ind] = max(all_Coefs_picNums); % Output#1
    allINVcalFiles= dir(['p*' num2str(coefFileNum) '*calib*']);
    
    if ~isempty(allINVcalFiles) % There's both rawCalib and invCalib
        all_invCal_picNums= cell2mat(cellfun(@(x) sscanf(x, 'p%04f_calib*'), {allINVcalFiles.name}', 'UniformOutput', false));
        calibPicNum= max(all_invCal_picNums); % Output#2
        
        temp = load(all_Coefs_Files(max_ind).name);
        b= temp.b(:)';
        doINVcheck= true;
    else % There's rawCalib but no invCalib
        % Output #1-2
        doINVcheck= false;
        coefFileNum= nan;
        calibPicNum= max(all_calib_picNums);
        b= [1 zeros(1, 255)];
    end
elseif doInvCalib==0
    % Output #1-2
    coefFileNum= nan;
    calibPicNum= max(all_calib_picNums);
    b= [1 zeros(1, 255)];
elseif doInvCalib==-1
    warning('Work in progress- does''t work after delete(FIG.handle) is evaluated');
    % Output #1-2
    coefFileNum= nan;
    calibPicNum= nan;
    coef_stored= COMM.handle.RP2_4.ReadTagV('FIR_Coefs', 0, 256);
    b= coef_stored;
    if max(abs((coef_stored-[1 zeros(1, 255)])))<1e-6 % if within quantization error, then equal
        fprintf('Using Allpass Coefs (%s) \n', datestr(datetime));
    else
        fprintf('Using invFIR Coefs (%s) \n', datestr(datetime));
    end
    cd(curDir);
    return;
elseif doInvCalib== -2 % return
    all_Coefs_Files= dir('coef*');
    all_Coefs_picNums= cell2mat(cellfun(@(x) sscanf(x, 'coef_%04f_calib*'), {all_Coefs_Files.name}', 'UniformOutput', false));
    
    % Check if last calib file is the same as last coef file
    if max(all_calib_picNums)~=max(all_Coefs_picNums)
        %         warning('Last Calib file does not match last coef-file. Rerunning invCalib?');
        warning('All raw-files should have corresponding coef files?? Something wrong???');
    end
    [coefFileNum, max_ind] = max(all_Coefs_picNums); % Output#1
    allINVcalFiles= dir(['p*calib*' num2str(coefFileNum) '*']);
    
    if ~isempty(allINVcalFiles) % There's both rawCalib and invCalib
        all_invCal_picNums= cell2mat(cellfun(@(x) sscanf(x, 'p%04f_calib*'), {allINVcalFiles.name}', 'UniformOutput', false));
        calibPicNum= max(all_invCal_picNums); % Output#2
        
        temp = load(all_Coefs_Files(max_ind).name);
        b= temp.b(:)';
    else
        b= nan;
    end
end
cd(curDir);

%% Run the circuit
if status_rp2
    e1= COMM.handle.RP2_4.WriteTagV('FIR_Coefs', 0, b);
    invoke(COMM.handle.RP2_4,'Run');
elseif status_rx8
    e1= COMM.handle.RX8.WriteTagV('FIR_Coefs', 0, b);
    invoke(COMM.handle.RX8,'Run');
else 
    e1= false;
end
if e1
    if doInvCalib==1
        if doINVcheck
            fprintf('most recent invFIR Coefs loaded successfully (%s) \n', datestr(datetime));
        else
            fprintf('Running allpass as no invCalib. allpass Coefs loaded successfully (%s) \n', datestr(datetime));
            warn_handle= warndlg('Running allpass as no invCalib', 'Run invCalib maybe?');
            uiwait(warn_handle);
        end
    else
        fprintf('Allpass Coefs loaded successfully (%s) \n', datestr(datetime));
    end
elseif (~e1) && (doInvCalib ~= -2)
    fprintf('Could not connect to RP2/RX8 or load FIR_Coefs (%s) \n', datestr(datetime));
end

