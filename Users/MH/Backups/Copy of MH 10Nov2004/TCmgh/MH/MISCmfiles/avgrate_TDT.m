function [drat,srat,abval,nlines,titletext,legtext,timeX]=avgrate_TDT(RLfile,plotYES,acceptYES)
% File: avgrate_TDT.m
%
% calculates rate-levels from TDT data (calls RATEcommon.m)
% Shows raster and False-trigger analysis (based on ISIs) if plotYES==1
% Also, if acceptYES==1, then it lets you discard lines from the end (or beginning) if artifacts detected
%
% %% Determines: timeX, titletext, and legtext 
% %% RATEcommon needs: nlines, abval, x.spikes, timew

eval(['x=' RLfile ';'])  % Load data for this picture

% Find out how many lines were presented
%%% THIS IS CURRENTLY PRESENTED AT ALL, need a way ?? to know how many TOTALLY PRESENTED? 
%%% Not possible with data up to now (12/12/01), but future versions will have variable: TOTALLY PRESENTED LINES
names=fieldnames(x.Line.attens);
nlines=size(getfield(x.Line.attens,names{1}),1);

if(max(x.spikes{1}(:,1)>nlines))
    warndlg('Spike sequence greater than nlines!!!!')  % This should never happen
end 
abval=-x.Stimuli.attens(1:nlines);     %%% Need to fill in abscissa values (Attens)

% Compute rate windows using default values
dur=x.Hardware.Trigger.StmOn;
per=x.Hardware.Trigger.StmOn+x.Hardware.Trigger.StmOff;
%	timew = [10, dur+10, (dur + pb.mode_line(4))/2., pb.mode_line(4)];  % OLD VERSION
timew = [10, dur+10, dur + 200, per];  %Enlarged SR window re OLD version

%% Get titletext and legtext
titletext=sprintf('%s, %s',x.General.date, x.General.unit);

if(isfield(x.Line.attens,'noise'))
    legtext={sprintf('%s: %s; f=%.2f; T=%.f; N:%d[%.1f,%.1f]; R[%.f,%.f]&[%.f,%.f]', ...
            RLfile, x.Stimuli.short_description,x.Stimuli.freqs/1000,x.Hardware.Trigger.StmOn, ...
            x.Line.attens.noise(1,2),x.Stimuli.noise_low_cutoff/1000,x.Stimuli.noise_high_cutoff/1000, ...
            timew(1),timew(2),timew(3),timew(4))};
elseif(isfield(x.Line.attens,'tone'))
    legtext={sprintf('%s: %s; f=%.2f; T=%.f; R[%.f,%.f]&[%.f,%.f]', ...
            RLfile, x.Stimuli.short_description,x.Stimuli.freqs/1000,x.Hardware.Trigger.StmOn, ...
            timew(1),timew(2),timew(3),timew(4))};
elseif(isfield(x.Line.attens,'file'))
    [path,name,ext]=fileparts(char(x.Stimuli.list));
    legtext={sprintf('%s: %s; %s; T=%.f; R[%.f,%.f]&[%.f,%.f]', ...
            RLfile, x.Stimuli.short_description,strcat(name,ext),x.Hardware.Trigger.StmOn, ...
            timew(1),timew(2),timew(3),timew(4))};  
end

% Return time
if(isfield(x.General,'time'))
    timeX=x.General.time;
else
    timeX='NOT SAVED';
end

%%% Need to determine: timeX, titletext, and legtext
%%%      from PDP and TDT separetely
%%% RATEcommon Needs: nlines, abval, x.spikes, timew, per

RATEcommon


return

