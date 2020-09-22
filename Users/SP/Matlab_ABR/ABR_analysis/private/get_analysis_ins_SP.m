%ABR Analysis Instruction Block
function abr_Stimuli= get_analysis_ins_SP(abr_Stimuli_old)
CalibFileNum= abr_Stimuli_old.cal_pic; 
if isfield(abr_Stimuli_old, 'start_template')
    start_template= abr_Stimuli_old.start_template; 
else 
    start_template= 6.20;
end
if isfield(abr_Stimuli_old, 'end_template')
    end_template= abr_Stimuli_old.end_template; 
else 
    end_template= 14;
end

abr_Stimuli = struct(...
    'cal_pic','1', ...
    'abr_pic','20-25', ... % These will be used for analysis
    'start', 4.00, ...
    'end',20.00, ...
    'start_template', start_template, ...
    'end_template',end_template, ...
    'num_templates', 2.00, ...
    'ClickToUpdateABR', 'ClickToUpdate', ...
    'dir','MH-2015_10_28-Q226_TTS_followup2wk_ABR_DP_DPIO', ...
    'abr_pic_all','20-27');  % these plots will be shown----------------------------------------------------------------------------------------------

if ~isempty(CalibFileNum)
    if isnumeric(CalibFileNum)
        abr_Stimuli.cal_pic= num2str(CalibFileNum);
    elseif isstring(CalibFileNum)
        abr_Stimuli.cal_pic= CalibFileNum;
    elseif iscell(CalibFileNum)
        abr_Stimuli.cal_pic= CalibFileNum{1};
    end
end