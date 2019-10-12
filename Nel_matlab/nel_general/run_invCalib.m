% newCalib= run_invCalib()
% if doInvCalib= 0, all pass
% if doInvCalib= 1, inverse calib based on last coef* file
% if doInvCalib= -1, query allpass or invFIR
% forceDO: should be set to 1 for only when running invCalib after rawCalib


function [coefFileNum, calibPicNum]= run_invCalib(doInvCalib, forceDO)

if ~exist('forceDO', 'var')
    forceDO= false;
end

%% Connecting to RP2_4
global COMM root_dir NelData
object_dir = [root_dir 'calibration\object'];

COMM.handle.RP2_4= actxcontrol('RPco.x',[0 0 5 5]);
status3 = invoke(COMM.handle.RP2_4,'ConnectRP2', NelData.General.TDTcommMode, 4);
invoke(COMM.handle.RP2_4,'LoadCof',[object_dir '\calib_invFIR_right.rcx']);

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
    allINVcalFiles= dir(['p*calib*' num2str(coefFileNum) '*']);
    
    if ~isempty(allINVcalFiles)|| forceDO % There's both rawCalib and invCalib
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
    if max(abs((coef_stored-[1 zeros(1, 255)])))<1e-6 % if within quantization error, then equal
        fprintf('Using Allpass Coefs (%s) \n', datestr(datetime));
    else
        fprintf('Using invFIR Coefs (%s) \n', datestr(datetime));
    end
    cd(curDir);
    return;
end
cd(curDir);

%% Run the circuit
e1= COMM.handle.RP2_4.WriteTagV('FIR_Coefs', 0, b);
if e1 && status3
    if doInvCalib
        if doINVcheck
            fprintf('invFIR Coefs loaded successfully (%s) \n', datestr(datetime));
        else 
            fprintf('Running allpass as no invCalib. allpass Coefs loaded successfully (%s) \n', datestr(datetime));
            warn_handle= warndlg('Running allpass as no invCalib', 'Run invCalib?');
            uiwait(warn_handle);
        end
    else
        fprintf('Allpass Coefs loaded successfully (%s) \n', datestr(datetime));
    end
else
    fprintf('Could not connect to RP2 or load FIR_Coefs (%s) \n', datestr(datetime));
end
invoke(COMM.handle.RP2_4,'Run');
