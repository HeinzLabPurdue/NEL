function rc = RPprepare(rp_num)
%

% AF 8/24/01

global RP NelData

if (exist('rp_num') ~= 1)
    %    rp_num = 1:length(RP);
    rp_num = 1:2; % 2 instead of length(RP) because only top 2 RP2s control are needed for sound playing
    % RP2 #3 and 4 if present are handled outside during data collection
    % (e.g., in the function run_invCalib)
end
PAset(120);

for i = rp_num(:)'
    %% Locate the RPD file, check dates and save them under the data directory
    [pname fname ext] = fileparts(RP(i).rco_file);
    rpd_name = [pname filesep fname '.rpd'];
    rpd_dat = dir(rpd_name);
    
    % LQ 07/15/04
    % The new RPVDS software saves '.rpx' files instead of the old
    % '.rpd' ones. So when check existence of rpd file, and compare
    % the date with rco file, should also consider '.rpx' file
    % When there are both rpd and rpx files, use rpd files.
    if (isempty(rpd_dat))
        rpd_name = [pname filesep fname '.rpx'];
        rpd_dat = dir(rpd_name);
    end
    
    if (isempty(rpd_dat))
        nelwarn(['RPprepare: Can''t find rpd file that matches '''  RP(i).rco_file ...
            '''. Stimulus will be presented normally, but we would like to backup the rpd file']);
    else
        rco_dat = dir(RP(i).rco_file);
        if (datenum(rco_dat.date) < datenum(rpd_dat.date))
            waitfor(warndlg(['''' rco_dat.name ...
                ''' is older than it''s rpd. Recompile the rpd and only then hit the OK button'],'RPprepare'));
        end
        dest_backup = [NelData.File_Manager.dirname 'Object' filesep rpd_dat.name];%LQ 07/24/03
        if (~exist(dest_backup,'file'))
            if (copyfile(rpd_name,dest_backup) ~= 1)
                nelwarn(['RPprepare: Can''t save rpd file in  ''' NelData.File_Manager.dirname 'Object\''']);
            end
        end
    end
    %% Load the rco file
    rc = invoke(RP(i).activeX,'ClearCOF');
    if (rc)
        rc = invoke(RP(i).activeX,'LoadCof',RP(i).rco_file);
    end
    if (rc)
        rc = invoke(RP(i).activeX,'run');
    end
    if (rc==0)
        nelerror(['RPprepare: Can''t load and run ''' RP(i).rco_file ''' on RP #' int2str(i)]);
        return;
    else
        RP(i).sampling_rate = double(invoke(RP(i).activeX,'GetSFreq'));
        RP(i).cycle_usage   = double(invoke(RP(i).activeX,'GetCycUse'));
        min_usage = 19 / (97656 / RP(i).sampling_rate);
        if (RP(i).cycle_usage > 92 | (RP(i).cycle_usage < min_usage))
            nelwarn(['Over cycle usage (' num2str(RP(i).cycle_usage) ') of ''' RP(i).rco_file ''' on RP #' int2str(i)]);
        end
    end
end
