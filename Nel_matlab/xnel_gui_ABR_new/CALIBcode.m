   %%% Account for Calibration to set Level in dB SPL
%    if ~isempty(stimulus_vals.Inloop.CalibPicNum)
%       if stimulus_vals.Inloop.CalibPicNum==0
%          max_dBSPL=-999;
%       else
%          cdd
%          if ~isempty(dir(sprintf('p%04d_calib.m',Inloop.params.CalibPicNum)))
%             x=loadpic(stimulus_vals.Inloop.CalibPicNum);
%             CalibData=x.CalibData(:,1:2);
%             CalibData(:,2)=trifilt(CalibData(:,2)',5)';
%             max_dBSPL=CalibInterp(stimulus_vals.Inloop.BaseFrequency,CalibData);
%          else
%             max_dBSPL=[];
%             Inloop.params.CalibPicNum=NaN;
%          end
%          rdd
%       end
%    else
%       max_dBSPL=[];
