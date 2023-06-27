function fmaskedCAP_loop_plot_enable_disable(on_or_off)
    global FIG
    % UNIT = sprintf('%1d.%02d', NelData.File_Manager.track.No, NelData.File_Manager.unit.No);

    set(FIG.radio.fast, 'Enable',on_or_off)
    set(FIG.radio.slow, 'Enable',on_or_off)

    set(FIG.checkbox.fixedPhase, 'Enable',on_or_off)

    set(FIG.asldr.slider, 'Enable',on_or_off)
    set(FIG.asldr2.slider, 'Enable',on_or_off)

    set(FIG.asldr.val, 'Enable',on_or_off)
    set(FIG.asldr2.val, 'Enable',on_or_off)


    set(FIG.radio.atAD, 'Enable',on_or_off)
    set(FIG.radio.atELEC, 'Enable',on_or_off)

    set(FIG.radio.left, 'Enable',on_or_off)
    set(FIG.radio.right, 'Enable',on_or_off)
    set(FIG.radio.both, 'Enable',on_or_off)

    set(FIG.edit.gain, 'Enable', on_or_off)
    set(FIG.edit.yscale, 'Enable', on_or_off)
    
    set(FIG.edit.memReps, 'Enable', on_or_off)
    set(FIG.edit.threshV, 'Enable', on_or_off)
end
