function [FREQS, COMM, textStruct]= FPLinv_ReturnCal(FIG, Stimuli)

FREQS = struct('ndat',0,'isinit',1,'ndpnts',0,'ndad',0,'frqlst',0.0,'gprd',12,'gain',12,'freq',Stimuli.frqlo,'atnn',Stimuli.syslv);        
%Communication handles and data returns for SR530
% comhandle = cell2struct(cell(1,3),{'SR530','RP2_1','RP2_2'},2);
comhandle = cell2struct(cell(1,3),{'TDT_Calib','RP2_1','RP2_2'},2);
SRdata = cell2struct(cell(1,7),{'rmag','rph','sem','ndata','dbspl','ophs','dBV'},2);
COMM = struct('handle',comhandle,'SRdata',SRdata);

if Stimuli.fstlin == 0
   textStruct.log= 'yes';
elseif Stimuli.fstoct == 0
   textStruct.log= 'no';
end

textStruct.step= max(Stimuli.fstlin, Stimuli.fstoct);

if Stimuli.chan == 1
   textStruct.chan= 'left';
else
   textStruct.chan= 'right';
end

if Stimuli.cal == 1
   set(FIG.ax1.ord_text,'string','Gain (dB SPL)');
   set(FIG.ax1.axes,'YLim',[100 120]);
   textStruct.spl= 'yes';
else
   set(FIG.ax1.ord_text,'string','RMS volts, dB re 1V');
   set(FIG.ax1.axes,'YLim',[-40 -20]);
   textStruct.spl= 'no';
end
set(FIG.ax1.axes,'XLim',[Stimuli.frqlo Stimuli.frqhi]);
set(FIG.ax1.axes, 'XTick', ...
   unique(min(Stimuli.frqhi,max(Stimuli.frqlo, [Stimuli.frqlo++.000001 0.1 0.2 0.4 1 2 4 7 10 15 20:10:50 100 Stimuli.frqhi]))));
set(FIG.ax1.axes, 'XMinorTick', 'off');

set(FIG.ax3.ParamData1,'Color',[.1 .1 .6],'string', {Stimuli.frqlo; Stimuli.frqhi; textStruct.log; textStruct.step; Stimuli.bplo; Stimuli.bphi; Stimuli.n60lo; Stimuli.n60hi});
set(FIG.ax3.ParamData2,'Color',[.1 .1 .6],'string', {Stimuli.n120lo; Stimuli.n120hi; textStruct.chan; Stimuli.syslv; Stimuli.lvslp; Stimuli.frqcnr; textStruct.spl; Stimuli.nmic});
