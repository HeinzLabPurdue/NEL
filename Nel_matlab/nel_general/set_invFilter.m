%Sprint 2023 | AS/MH/MP | Attempt to condense/cleanup what was formerly known as
%run_invCalib. A 2 channel version of this is soon to come.

%Good practice should save in each data file the filter type and relevant
%picture numbers. Important! Forces programs that call this function to previously
%have considered which calibration pic num to call. Otherwise will default
%to allstop.

%Change input to string
% 'allpass' = allpass
% 'allstop' = allstop
% 'inversefilt' = inverse calib based on specfied 

%inversefilterdata:
% 1. CalibPICnum2use
% 2. filttype (cell array dim 2)
% 3. coefFileNum 
% 4. b (cell array dim 2)

function invfilterdata = set_invFilter(filttype, RawCalibPicNum)

if ~exist('RawCalibPicNum','var') && ~strcmp(filttype,{'allstop','allstop'})
    warndlg('Missing Calibration File Number. Running allstop.','WARNING!!!','modal');
    filttype = {'allstop','allstop'};
    RawCalibPicNum = NaN;
    coefFileNum = NaN;
end

%% Connecting to TDT modules
global COMM root_dir
object_dir = [root_dir 'calibration\object'];

[COMM.handle.RP2_4, status_rp2]= connect_tdt('RP2', 4);
[COMM.handle.RX8, status_rx8]= connect_tdt('RX8', 1);

if status_rp2 && status_rx8
    error('How are RP2#4 and RX8 both in the circuit?');
end


%Always setting something
if status_rp2
    invoke(COMM.handle.RP2_4,'LoadCof',[object_dir '\calib_invFIR_right.rcx']);
elseif status_rx8 % Most call for run_invCalib are from NEL1. For NEL2 (with RX8), only needed for calibrate and dpoae.
    invoke(COMM.handle.RX8,'LoadCof',[object_dir '\calib_invFIR_right_RX8.rcx']);
end

curDir= pwd;
cdd;

pic_str = sprintf('p%04d_%s',RawCalibPicNum,'calib_raw*');
fname = dir(pic_str);

if isempty(fname)
    warndlg('Invalid Calibration File. Running allstop.');
    RawCalibPicNum = NaN;
    coefFileNum = NaN;
    filttype = {'allstop','allstop'};
else
    coefFileNum = RawCalibPicNum;
end

% all_calib_picNums= cell2mat(cellfun(@(x) getPicNum(x), {all_Calib_files.name}', 'UniformOutput', false));

%check for missing coeff file and missing inv file

switch filttype{1}
    case 'allpass'
        %needs valid calib file
        b_chan1 = [1 zeros(1, 255)];        
    case 'allstop'
        %doesn't need anything
        b_chan1 = zeros(1, 256);
    case 'inversefilt'
        %need 2 checks
        % inverse and coeffs
        
        
    otherwise 
        warning('Invalid filter type specified in set_invFilter()...defaulting to ALLPASS')        
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
    elseif doInvCalib==0
        fprintf('Allpass Coefs loaded successfully (%s) \n', datestr(datetime));
    end
elseif (~e1) && (doInvCalib ~= -2)
    fprintf('Could not connect to RP2/RX8 or load FIR_Coefs (%s) \n', datestr(datetime));
end

