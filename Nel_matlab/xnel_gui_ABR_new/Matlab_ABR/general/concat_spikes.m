function concat_spikes(new_spikes)
%  concat_spikes: SHOULD BE A SUBFUNCTIOPN OF STM AS SOON AS STM WILL BECOME A FUNCTION

% AF 10/16/01

global spikes

if (length(new_spikes) ~= length(spikes.times))
   waitrot(errordlg('Inconcistent number of channels. Spikes are not stored!', 'concat_spikes'));
   return;
end
for i = 1:length(spikes.times)
   new_spikes_len = size(new_spikes{i},1);
   spikes.times{i}(spikes.last(i)+1:spikes.last(i)+new_spikes_len,:) = new_spikes{i};
   spikes.last(i) = spikes.last(i) + new_spikes_len;
end
   