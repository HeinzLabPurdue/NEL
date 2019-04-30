function [spk,index,status] = msdl(mode,nch)
%

% AF 11/8/01

global fake_prevTimeReLine line fake_msdl_nch fake_tdt_block_start 
global Trigger

switch (mode)
case 0
   fake_prevTimeReLine = 0;

case 1
   fake_prevTimeReLine = 0;
   fake_msdl_nch = nch;

case 3
   spk = 0;
   
case 4
   spk = 0;
   
case 2
   ISI = Trigger.params.StmOn+Trigger.params.StmOff;
   nch = fake_msdl_nch;
   status = zeros(1,nch);
   spk = cell(1,nch);
   current_clock = clock;
         
   time_re_block = etime(current_clock, fake_tdt_block_start)*1000;
   index    = time_re_block / ISI;
   fake_time_re_line  = (index-floor(index)) * ISI;
   index         = floor(index)+1;
   spike_rate = 0.;
   if (fake_time_re_line <= fake_prevTimeReLine & fake_time_re_line+61 > fake_prevTimeReLine )
      fake_time_re_line =  fake_prevTimeReLine +15;
   end
   if (index > Trigger.params.StmNum)
      % index = 1;
      index = Trigger.params.StmNum;
   else
      if (fake_time_re_line <= Trigger.params.StmOn)
         spike_rate = 0.1;
      else
         spike_rate = 0.01;
      end
   end
   dur = max(15,fake_time_re_line - fake_prevTimeReLine);
   Nspikes = round(dur * spike_rate);
   for i = 1:nch
      % [x,sr,times] = rand_spike_train(dur,lambda);
      times = dur * min(1,cumsum(rand(Nspikes,1)/(Nspikes*0.65)));
      % fprintf('dur=%.3f fake_time_re_line=%.3f\n', dur, fake_time_re_line);
      times =  min(ISI,times+fake_prevTimeReLine)/1000;
      spk{i} = [repmat(index,length(times),1)  times];
   end
   fake_prevTimeReLine = fake_time_re_line;
   
end
   
