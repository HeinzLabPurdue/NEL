function sig_stat= run_synthesis_fun(in_params, doPlay)

if ~exist('doPlay', 'var')
    doPlay= false;
end

% nSamples= 188;
NFC= 4;
G0= 60;
fs= in_params.fsOrg;
NWS= 50;

vowel_params= handsy_init(in_params.dur_ms, NFC, G0, NWS, fs);

%% Stationary signal
vowel_params.av.ydata= [60 60];

vowel_params.f0.ydata= in_params.f0;
vowel_params.f1.ydata= in_params.f1;
vowel_params.f2.ydata= in_params.f2;
vowel_params.f3.ydata= in_params.f3;
% vowel_params.f4.ydata= [3500 3500];
% vowel_params.f5.ydata= [4500 4500];

vowel_params.b1.ydata= in_params.b1;
vowel_params.b2.ydata= in_params.b2;
vowel_params.b3.ydata= in_params.b3;

% vowel_params.a1.ydata= [40 40];
% vowel_params.a2.ydata= [40 40];
% vowel_params.a3.ydata= [40 40];
% vowel_params.a4.ydata= [-20 -20];

vowel_params.sw.ydata= in_params.sw;

sig_stat= synth(vowel_params);
sig_stat= sig_stat/max(abs(sig_stat))*.99;
sig_stat= sig_stat(1:ceil(in_params.dur_ms/1e3*in_params.fsOrg));

if doPlay
    sound(sig_stat, fs);
end
