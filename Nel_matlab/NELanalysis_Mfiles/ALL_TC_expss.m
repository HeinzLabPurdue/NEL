% FILE: ALL_TC_exps.m

ChinExps={'MH-2006_09_21-AN-norm','MH-2006_10_19-ANnorm', ...
   'MH-2006_11_03-ANnorm','MH-2006_11_16-ANnorm','MH-2007_01_26-ANnorm-ABR', ...
   'MH-2007_02_23-ANnorm','MH-2007_03_02-ANnorm','MH-2007_03_09-ANnorm','MH-2007_03_23-ANnorm', ...
   'MH-2007_04_13-ANnorm_wABR','MH-2007_04_20-ANnorm_wABRs'};

path('C:\Documents and Settings\Mike\My Documents\Work\Research\R03 Experiments\Data Analysis\New Chin Analyses',path)
for i = 1:length(ChinExps)
   PlotExpThresholds(ChinExps{i})
   pause
end

