function [x,sr,times] = rand_spike_train(dur,lambda,spike_dur,sr)
%

% Alon Fishbach 27/9/01

if (exist('sr') ~= 1)
   sr = 97656.25;
end
if (exist('spike_dur') ~= 1)
   spike_dur = 0.8;
end
ref_dur   = 1;

if (spike_dur >= ref_dur)
   error(sprintf('spike duration (%1.2f) should be shorter than the refractory period (%1.2f)',...
      spike_dur, ref_dur));
end
len = round(dur*sr/1000);
spike_len = round(spike_dur*sr/1000);
isi = gamrnd(lambda,1,1,len);
isi(isi< ref_dur) = ref_dur;
times = cumsum(isi);
times = times(1:max(find(times<=(dur-ref_dur))));
x = zeros(1,len);
locs = round(times*sr/1000);

for i = 1:length(locs)
   x(locs(i):(locs(i)+spike_len)) = 1;
end
