function [stimulus_vals, units] = NI_check_gating__params(stimulus_vals, units)


% The minimum allowed period incorporates "overhead" time for pre-processing
%  and loading to the NI 6052 board.  GE debug: will need similar implementation
%  in "nel_rot_NI_wavfile_template".
playdur_msec = stimulus_vals.Gating.Duration; % "on" duration for stimulus.
min_overhead_time_msec = 150;  % Minimum overhead time is hard-coded.
min_period_msec = min_overhead_time_msec + playdur_msec;
if (stimulus_vals.Gating.Period < min_period_msec)
    tmplt.IO_def.Gating.Duration{1}  = playdur_msec;
    tmplt.IO_def.Gating.Period{1}    = min_period_msec;
    tmplt.IO_def.Gating.Rise_fall_time{1} = stimulus_vals.Gating.Rise_fall_time;
     % Call 'structdlg' in its non-interactive invisible mode, to load 'Gating' fields:
    [stimulus_vals.Gating units.Gating] = structdlg(tmplt.IO_def.Gating,'',[],'off');
    nelwarn(['In ''NI_check_gating__params'': gating period extended.']);
end

% Rise/fall time should not be more than half of duration:
if (2*stimulus_vals.Gating.Rise_fall_time > playdur_msec)
    tmplt.IO_def.Gating.Duration{1}  = playdur_msec;
    tmplt.IO_def.Gating.Period{1}    = stimulus_vals.Gating.Period;
    tmplt.IO_def.Gating.Rise_fall_time{1} = playdur_msec/2;
     % Call 'structdlg' in its non-interactive invisible mode, to load 'Gating' fields:
    [stimulus_vals.Gating units.Gating] = structdlg(tmplt.IO_def.Gating,'',[],'off');
    nelwarn(['In ''NI_check_gating__params'': rise/fall time reduced.']);
end   
