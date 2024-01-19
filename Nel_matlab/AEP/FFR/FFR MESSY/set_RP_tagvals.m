function set_RP_tagvals(RP1,RP2,FFR_Gating, Stimuli)

PAset(120.0);  % Added SP (5Jun19) to stop onset 

invoke(RP1, 'SetTagVal','StmOn', FFR_Gating.duration_ms);
invoke(RP1, 'SetTagVal', 'StmOff', FFR_Gating.period_ms-FFR_Gating.duration_ms);
invoke(RP1, 'SetTagVal','RiseFall', FFR_Gating.rftime_ms);
% invoke(RP1, 'Run');

invoke(RP2,'SetTagVal','ADdur', FFR_Gating.FFRlength_ms);
% invoke(RP2,'Run');

% FFR_set_attns(Stimuli.atten_dB,-120,Stimuli.channel,Stimuli.KHosc,RP1,RP2);
if isfield(Stimuli, 'SNR_at_pink_0dB_atten')
    FFR_set_attns(Stimuli.atten_dB, max(-120, Stimuli.SNR_at_pink_0dB_atten-Stimuli.SNR_dB), Stimuli.channel,Stimuli.KHosc,RP1,RP2);
else
    FFR_set_attns(Stimuli.atten_dB,-120,Stimuli.channel,Stimuli.KHosc,RP1,RP2);
end