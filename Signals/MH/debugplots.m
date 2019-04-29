load timing_debug_102803;
figure(1);
plot(DALinloop_lines,DALinloop_times(1,:),'b*',DALinloop_lines,DALinloop_times(2,1:end),'ro');
ylim([0 1]);
figure(2);
plot(msdl_lines,msdl_times(1,:),'k*',msdl_lines,msdl_times(2,1:end),'ko');
hold on
plot(DALinloop_lines,DALinloop_times(1,:),'b*',DALinloop_lines,DALinloop_times(2,1:end),'ro');
hold off
ylim([0 1]);
figure(3);
plot(DALinloop_lines,DALinloop_times(2,:)- DALinloop_times(1,1:end),'ko');
figure(4);
plot(msdl_lines,msdl_times(2,:)- msdl_times(1,1:end),'ko');
