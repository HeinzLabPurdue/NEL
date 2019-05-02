function threshold=capPlot(picNum,calibPicNum)

x=loadpic(picNum);
xx=loadpic(calibPicNum);
capData=x.AD_Data.AD_Avg_V/x.AD_Data.Gain;

[columns,rows]=size(capData);
theEnd='isNear';
