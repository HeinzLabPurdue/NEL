%% FIle: testBF.m
%
% to test by-hand BF estimate with tcdata

%clear

x=p0067_u1_07_tc;
tcdata=x.TcData;

figure(11); clf
run=min(find(tcdata(:,1)==0))-1;
semilogx(tcdata(1:run,1),-tcdata(1:run,2),'r-')
axis([.1 10 -100 -10])
hold on
h_line3 = plot(500,0,'bx','MarkerSize',12,'EraseMode','xor');

last_stim = run;    %%% HERE IS WHERE TO LET USER PICK BF
loc = find(tcdata(1:run,2)==max(tcdata(1:run,2)));
thresh = tcdata(loc(1),2);
bf = tcdata(loc(1),1);
fprintf('Estimated BF = %.4f   Threshold = %.4f\n', bf, thresh);
set(h_line3,'XData',bf,'YData',-thresh);

disp('Verify BF: Use L/R cursors OR Mouse; ENTER to END')
while 1==1
   w = waitforbuttonpress;
   if w == 0
      %   disp('Button press')
      clickpos=get(gca,'CurrentPoint');
      %  disp(sprintf('CurrentPoint: [%.3f %.3f]',clickpos(1,1),clickpos(1,2)));
      [yind,loc]=min(abs(tcdata(1:run,1)-clickpos(1,1)));  
   else
      %disp('Key press')
      keypress=get(gcf,'CurrentCharacter');
      switch double(keypress)
      case 13
         %   disp(sprintf('CurrentCharacter: %s','RETURN'));
         break;
      case 28
         %disp(sprintf('CurrentCharacter: %s','LEFT cursor'));
         loc=min(last_stim,loc+1);
      case 29
         %disp(sprintf('CurrentCharacter: %s','RIGHT cursor'));
         loc=max(1,loc-1);
      end
   end
   thresh = tcdata(loc,2);
   bf = tcdata(loc,1);
   set(h_line3,'XData',bf,'YData',-thresh);
end
fprintf('Estimated BF = %.4f   Threshold = %.4f\n', bf, thresh);



hold off
