function [error] = make_tone()

global object_dir COMM FIG Stimuli newCalib

error = 0;


%%
useInvFIR= 1;
if useInvFIR
    % SP Implement inverse calib if coef file exists for the current.
    COMM.handle.RP2_4= actxcontrol('RPco.x',[0 0 5 5]);
    status3 = invoke(COMM.handle.RP2_4,'Connect',4, 4);
    invoke(COMM.handle.RP2_4,'LoadCof',[object_dir '\calib_invFIR_right.rcx']);
    isDebug= 0;
    cdd;
    
    all_Calib_files= dir('p*calib*');
    if isempty(all_Calib_files)
        newCalib= true;
    else
        if isDebug
            newCalib= true;x
        else
            inStr= questdlg('Calib files already exists - run new calib or use latest FIR coeffs?', 'New or Rerun?', 'New Calib', 'FIR Calib', 'FIR Calib');
            if strcmp(inStr, 'New Calib')
                newCalib= true;
            elseif strcmp(inStr, 'FIR Calib')
                newCalib= false;
            end
        end
    end
    if newCalib
        % new calib, so no filter
        b= [1 zeros(1, 255)];
    else
        % Check if last calib file is the same as last coef file
        all_Coefs_Files= dir('coef*');
        all_Coefs_picNums= cell2mat(cellfun(@(x) sscanf(x, 'coef_%04f_calib*'), {all_Coefs_Files.name}', 'UniformOutput', false));
        all_calib_picNums= cell2mat(cellfun(@(x) getPicNum(x), {all_Calib_files.name}', 'UniformOutput', false));
        
        if max(all_calib_picNums)~=max(all_Coefs_picNums)
            warning('Last Calib file does not match last coef-file');
        end
        [~, max_ind] = max(all_Coefs_picNums);
        
        temp = load(all_Coefs_Files(max_ind).name);
        b= temp.b(:)';
    end
    
    e1= COMM.handle.RP2_4.WriteTagV('FIR_Coefs', 0, b);
    if e1
        fprintf('FIR_Coefs loaded successfully \n');
    else
        fprintf('Could not load FIR_Coefs\n');
    end
    invoke(COMM.handle.RP2_4,'Run');
    rdd;
end

%%
if Stimuli.ear == 1 %left ear
    
    
    %%
    
    COMM.handle.RP2_1 = actxcontrol('RPco.x',[0 0 5 5]);
    status1 = invoke(COMM.handle.RP2_1,'Connect',4,1);
    invoke(COMM.handle.RP2_1,'LoadCof',[object_dir '\make_tone_left.rco']);
    invoke(COMM.handle.RP2_1,'SetTagVal','Select',160);
    invoke(COMM.handle.RP2_1,'Run');
    
    COMM.handle.RP2_2 = actxcontrol('RPco.x',[0 0 5 5]);
    status2 = invoke(COMM.handle.RP2_2,'Connect',4, 2);
    invoke(COMM.handle.RP2_2,'LoadCof',[object_dir '\make_tone_right_PU.rco']);
    invoke(COMM.handle.RP2_2,'SetTagVal','Select', 56);
    invoke(COMM.handle.RP2_2,'Run');
else
    %    COMM.handle.RP2_1 = actxcontrol('RPco.x',[0 0 5 5]);
    %    status1 = invoke(COMM.handle.RP2_1,'Connect',4,2);
    %    invoke(COMM.handle.RP2_1,'LoadCof',[object_dir '\make_tone_left.rco']);
    %    invoke(COMM.handle.RP2_1,'SetTagVal','Select',160);
    %    invoke(COMM.handle.RP2_1,'Run');
    %
    %    COMM.handle.RP2_2 = actxcontrol('RPco.x',[0 0 5 5]);
    %    status2 = invoke(COMM.handle.RP2_2,'Connect',4,1);
    %    invoke(COMM.handle.RP2_2,'LoadCof',[object_dir '\make_tone_right_PU.rco']);
    %    invoke(COMM.handle.RP2_2,'SetTagVal','Select',4);
    %    invoke(COMM.handle.RP2_2,'Run');
    
    COMM.handle.RP2_1 = actxcontrol('RPco.x',[0 0 5 5]);
    status1 = invoke(COMM.handle.RP2_1,'Connect',4,1);
    invoke(COMM.handle.RP2_1,'LoadCof',[object_dir '\make_tone_left.rco']);
    invoke(COMM.handle.RP2_1,'SetTagVal','Select',56);
    invoke(COMM.handle.RP2_1,'Run');
    
    COMM.handle.RP2_2 = actxcontrol('RPco.x',[0 0 5 5]);
    status2 = invoke(COMM.handle.RP2_2,'Connect',4,2);
    invoke(COMM.handle.RP2_2,'LoadCof',[object_dir '\make_tone_right_PU.rco']);
    invoke(COMM.handle.RP2_2,'SetTagVal','Select',64);
    invoke(COMM.handle.RP2_2,'Run');
end
if ~status1 | ~status2,
    set(FIG.ax2.ProgMess,'String','TONE: Not communicating with TDT system!');
    error = 1;
end
