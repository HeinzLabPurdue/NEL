%set default parameters

click.Attenuation = 35; %60;
click.Vref  = 1;
click.BufferSize = 2048;
click.RespDur = 1024;
click.SamplingRate = 48.828125; %kHz
click.Averages =  2048; %2048;
click.ThrowAway = 8;
click.doFilt = 1;
click.StimWin = 128;
click.driver = 1; % ch1 or ch2

%% Make the click
nsampsclick = 4; % 82 microsecond
initbuff =  2;
y = zeros(1, click.BufferSize + click.StimWin);
y(initbuff + (1:nsampsclick)) = 0.95;
click.y = y(:); % Just in case

%% Other things to save
click.mic_sens = 50e-3; % mV/Pa. TO DO: change after calibration
click.mic_gain = db2mag(40);
click.P_ref = 20e-6;
click.DR_onesided = 1;