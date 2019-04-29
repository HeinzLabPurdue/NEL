function Attn_at90dBSPLcalc(calibpic)
cdd
x=loadpic(calibpic);xx = [];for i = [.5 1 2 4 8]
xx=[xx CalibInterp(i,x.CalibData)-90];
end
xx