function varargout = DALinloop_noisebands(varargin)
%
%   The input and output arguments are structure with the following fields
%   varargin{1} (common)   : index, left, right
%   varargin{2} (specific) : see list below
%
%   varargout{1} (stim_info)  : attens_devices 
%   varargout{2} (block_info) : nstim, nlines, stm_lst,  list,attens,Rlist,Rattens
%   varargout{3} (plot_info) : var_name, var_unit, var_vals, var_frmt, XYprops
%
%  specific->
%               list: []
%             attens: []
%     resample_ratio: []
%     playback_slowdown: []
%              Rlist: []
%            Rattens: []
%        repetitions: []

% AF 9/22/01
% comments added by LR 11/6/02 for clarity - this inloop is run several times from data_acquisition function

global static_bi static_pi; % Static variable
global RP root_dir home_dir
global noisebands_root_dir
global my_root_dir
global NelData

noisebands_root_dir = [ home_dir 'Users\tmp_for_noisebands\']; 
preadapt=5;

rc = 1;
if (nargin == 0)
   static_bi = [];
   static_pi = [];
   clear static_bi static_pi cached_samples;
   return
elseif (nargin >=1)
   common = varargin{1};
end
if (nargin == 2)
   specific = varargin{2};
end

if (common.index == 0)  %case preloop
   disp('presenting 5 preadapting stimuli...');
   return;
end
if (common.index == 1)  %case starting first loop

   %missing? 
   %static_pi.dispStatus = common.dispStatus;

   %%%% Initialize and set specific values to the static block info structure
   static_pi = default_inloop_plot_info;
   static_bi = specific;
   nstim = floor(log(static_bi.f_end/specific.f_start)/log(2)/static_bi.f_step)+1;
   nlines = nstim * static_bi.repetitions;
   nlines=nlines+preadapt;

   static_bi.fcen=static_bi.f_start*2.^(static_bi.f_step*[0:nstim-1]); %center frequency in kHz instead of fname   
   %*******************************************************************
   %generate stimulus matrix on-line using MATLAB instead of TDT - LR
   [stim_matrix,static_bi]=noiseband_spectrum(static_bi,nstim,NelData); %stimulus values in dB - each row is diff stim
                                                      % and each column is different frequency
   %*******************************************************************
   fcen0=[static_bi.fcen(1)*(2.^([-1:-1:-1*preadapt]*0.01)) static_bi.fcen];
   static_bi.fcen=[static_bi.fcen(1)*ones(1,5) static_bi.fcen];
   stim_matrix=[repmat(stim_matrix(1,:),5,1); stim_matrix];
   static_bi.atten_adjust=[static_bi.atten_adjust(1)*ones(5,1); static_bi.atten_adjust];

   
   %case different stimuli and reps at same attenuation - plotting stuff only
   if (nstim > 1)
      static_pi.var_name = 'File';
      static_pi.var_unit = '';
      static_pi.var_frmt = '%s';
      var_labels = cell(1,nlines);
      counter = 1+preadapt;
      for ii = 1:static_bi.repetitions
         for jj = 1:nstim
            %[dummypath fname] = fileparts(static_bi.list{jj});   %specify fname for rep ii, stim jj
%             static_bi.fcen(jj)=static_bi.f_start*2^(static_bi.f_step*(jj-1)); %center frequency in kHz instead of fname
%             var_labels{counter} = static_bi.fcen(jj);     %center freq in sequence of stim to be presented
            var_labels{counter} = sprintf('%i (%i stim)',jj,nstim);     %center freq in sequence of stim to be presented
            if (ii > 1)
               var_labels{counter} = [var_labels{counter} ' (Repetition #' int2str(ii) ')']; 
            end
            counter = counter+1;
         end   
      end
      for ii=1:preadapt
         var_labels{ii}=var_labels{1+preadapt};
      end
%       %new code added by LR for interleaving
%       veccen=floor(length(static_bi.fcen)/2);   
%       temp1=[veccen:-1:1]; temp2=[veccen+1:length(static_bi.fcen)];
%       intlvvec = reshape([temp2(1:length(temp1)); temp1],length(temp1)*2,1);
%       if length(temp2)>length(temp1),intlvvec=[intlvvec; temp2(end)]; end
%       static_bi.interleave=intlvvec;
%       fcen0=static_bi.fcen;   %keep in order for tick label
%       static_bi.fcen = static_bi.fcen(static_bi.interleave);
      if static_bi.repetitions==1   %for 1 rep, plot actual frequencies
         static_pi.var_labels   = var_labels;
         static_pi.var_vals     = static_bi.fcen;  %need to set axis, interleave
         static_pi.XYprops.Lim  = [min(static_bi.fcen)*0.9 max(static_bi.fcen)*1.1];
         tickspacing=ceil(length(static_bi.fcen)/10);
         static_pi.XYprops.Tick = fcen0(preadapt+1:tickspacing:end);      
         static_pi.XYprops.Scale  = 'log';
         static_pi.XYprops.Dir  = 'normal';
      elseif static_bi.repetitions>1   %for >1 rep, plot by line number (former default)
         static_pi.var_labels   = var_labels;
         static_pi.var_vals     = 1:nlines;
         static_pi.XYprops.Lim  = [0 nlines+1];
         static_pi.XYprops.Tick = [0:10:120];
         static_pi.XYprops.Dir  = 'normal';
      end
   else
      static_pi.var_name = 'Repetition #';
   end

   
   %%%%% Load rco to RP
   rconame = [root_dir 'stimulate\object\raw_samples16_100.rco']; 
   %needed?
%    main_rco = [root_dir 'stimulate\object\pedestal.rco'];
%    params.freq  = static_bi.freq;
%    params.RampDur = static_bi.ramp_dur;
%    params.PedDur  = static_bi.ped_dur;
%    params.PedDelay = static_bi.ped_delay;
tic
  %this step is SLOW - takes about a second to load
   rc = RPload_rco(rconame) & (rc==1); %problem but this occurs for cmr too
%toc
   % RPload_rco clears the RP's params;
   %needed?
%    RP(1).params = params;
   dev_description = nel_devices_vector('RP1.1','noiseband');
   if (rc == 0)
      return;
   end
   
   description = 'Band Pass Noises';
   short_description = 'NB';
   if (isfield(common,'short_description'))
      short_description = common.short_description;
   end
   if (isfield(common,'description'))
      description = common.description;
   end

   %%%%% These fields should be set in ANY inloop function %%%%%%
   static_bi.nstim           = nstim;
   static_bi.nlines          = nlines;
   static_bi.description     = description;
   static_bi.short_description  = short_description;
   static_bi.dev_description = dev_description;
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   static_bi.stim_matrix   = stim_matrix;  %added by LR
%    static_bi.stim_matrix   = stim_matrix(static_bi.interleave,:);  %changed to be interleaved
%    static_bi.atten_adjust  = static_bi.atten_adjust(static_bi.interleave);  %changed to be interleaved
end   


% load new stimuli (if necessary) 
if (common.index == 1) | (length(static_bi.fcen) > 1) %case first loop or more than one stimulus
   ind = mod(common.index-1,length(static_bi.fcen))+1; %set ind to current stim index 
   %read wav file
   %[data,sr,rc] = nel_wavread(static_bi.list{min(ind,end)});
   %read stimulus matrix generated in first loop instead of reading wav file - LR
   sr=static_bi.sr;     
   data=static_bi.stim_matrix(min(ind,end),:);
   if ~isempty(data) & ~isempty(sr)
      rc=1;
   end
   
   if (rc == 0)
      %nelerror(['Can''t read wavfile ''' static_bi.list{min(ind,end)} '''']);
      disp('stim read unsuccessful...');  %added by LR
   else %case read successful, load file to RP structure which will later be loaded to device
      rc = load_raw_samples_compressed(1,data,sr) & (rc==1);   %problem
   end
   if (length(static_bi.fcen) > 1)
      stim_info.file{1}                    = sprintf('Stim %i, %.5f kHz',min(max(1,ind-preadapt),static_bi.nstim),static_bi.fcen(min(ind,end))/1000);
   end
else
   RP(1).params = []; % Clear params to avoid sending the same old data again to the RP!
end

%needed?
% if (common.index == 2)
%    %remove parameters that do not change to save inloop time
%    if (isfield(RP(1).params,'freq'))
%       RP(1).params = rmfield(RP(1).params,'freq');
%    end
%    % TODO: clean up more const params
% end
% % Update 
% ind_step = floor((ind-1)/length(static_bi.ped_steps))+1;
% ind_rt   = mod(ind-1,length(static_bi.ped_rts))+1;
% [ramp_amp,ped_amp,main_attn] = pedestal_amps(static_bi.ramp_attn,static_bi.ped_steps(ind_step));
% RP(1).params.RampAttn   = ramp_amp;
% RP(1).params.PedAttn    = ped_amp;
% RP(1).params.PedRT      = static_bi.ped_rts(ind_rt);
% stim_info.ramp_amp      = ramp_amp;
% stim_info.pedestal_amp  = ped_amp;
% stim_info.pedestal_rt   = static_bi.ped_rts(ind_rt);


% Set attenuations and devices
%ind = mod(common.index-1,length(static_bi.nstim))+1;
%atten = static_bi.atten - static_bi.atten_adjust;
atten = static_bi.atten - static_bi.atten_adjust(min(ind,end));  %for MULTIPLE attens
%ind,atten
main_dev =  atten * nel_devices_vector('RP1.1');
stim_info.attens_devices = [main_dev main_dev];


if (nargout >=1)
   varargout{1} = stim_info;    %returns stimulus parameters
end
if (nargout >=2)
   varargout{2} = static_bi;
end
if (nargout >=3)
   varargout{3} = static_pi;
end

return

%-------------------------------------------------------------------
function [stim_matrix,static_bi] = noiseband_spectrum(static_bi,nstim,NelData)

global noisebands_root_dir

[stim_load_flag]=check_if_can_load_prev_stimulus(static_bi,nstim);
%stim_load_flag=0;
if stim_load_flag==1
   eval(sprintf('load %sstimsaved.mat;',noisebands_root_dir));
else  
   %define params in short names and in units of Hz, sec
   ntype=static_bi.n_type;     %bandpass or notch noise
   sr=static_bi.sr;         %sampling rate, in Hz
   dur=static_bi.dur/1e3;     %duration of signal in sec
   rt=static_bi.rt*1e-3;      %rise time in sec for ramping onsets and offsets
   f_start=static_bi.f_start*1e3;   %start frequency in Hz
   f_step=static_bi.f_step;   %frequency step in oct
   hbw=str2num(static_bi.band_hbw);   %half-bandwidth, oct
   slope=static_bi.band_slope;   %slope, dB/octave
   ht=static_bi.band_ht;   %height, dB
   noiseceil=30;    %noise floor, dB
   calibfile=static_bi.calib_file;  %if not 'none', flag to correct stimulus with calibration
   symmetry=static_bi.symmetry;  %log or linear symmetry of bands
   % ntype='Notch';     %bandpass or notch noise
   % sr=1e5;         %sampling rate, in Hz
   % dur=0.4;     %duration of signal in sec
   % rt=10*1e-3;      %rise time in sec for ramping onsets and offsets
   % f_start=5*1e3;   %start frequency in Hz
   % f_step=1/2;   %frequency step in oct
   % hbw=1/16;   %half-bandwidth, oct
   % slope=inf;   %slope, dB/octave
   % ht=30;   %height, dB
   % noisefloor=0;    %noise floor, dB
   % calibfile='none';  %if not 'none', flag to correct stimulus with calibration
   % nstim=1;

   %define stimuli in spectral domain
   noctrise=ht/slope;   %frequency range of band rise or fall, oct
   dt=1/sr;   %time between samples in sec
   nptvec=2.^[10:17];   npts=nptvec(max(find(nptvec<=dur/dt)));   %find multiple of 2 for faster ifft
   %t=[0:dt:npts*dt-1];   %time vector in sec
   f=[0:sr/npts:sr/2];     %freq vector in Hz
   stim_matrix_f=zeros(nstim,length(f));
   fcen=f_start*2.^(f_step*[0:nstim-1]');%center frequency in Hz ___/---\___
   if strcmp(symmetry,'log')==1
      fband(:,2)=fcen*2^(-hbw);   %low cutoff (top) in Hz               <-
      fband(:,3)=fcen*2^(hbw);     %high cutoff (top) in Hz              ->
      fband(:,1)=fband(:,2)*2^(-noctrise); %low cutoff (bottom) in Hz  <---
      fband(:,4)=fband(:,3)*2^(noctrise); %high cutoff (bottom) in Hz   --->
   elseif strcmp(symmetry,'linear')==1
      hbw_lin=fcen(round(nstim/2))*(2^hbw-2^(-hbw))/2;  %linear half bandwidth
      fband(:,2)=max(0,fcen-hbw_lin);   %low cutoff (top) in Hz               <-
      fband(:,3)=fcen+hbw_lin;     %high cutoff (top) in Hz              ->
      noctrise_lin=fcen(round(nstim/2))*(2^noctrise-1);  %linear freq range of slope
      fband(:,1)=max(0,fband(:,2)-noctrise_lin); %low cutoff (bottom) in Hz  <---
      fband(:,4)=fband(:,3)+noctrise_lin; %high cutoff (bottom) in Hz   --->
   end
   fbandind(:,1)=floor(fband(:,1)*npts/sr)+1;
   fbandind(:,2)=ceil(fband(:,2)*npts/sr)+1;
   fbandind(:,3)=floor(fband(:,3)*npts/sr)+1;
   fbandind(:,4)=ceil(fband(:,4)*npts/sr)+1;
   n1=fbandind(:,1)-1;
   n2=fbandind(:,3)-fbandind(:,2)-1;
   n3=length(f)-fbandind(:,4);
   if strcmp(ntype,'Notch')
      for jj=1:nstim
         %define spectral shape
         bandrise=[0:(fbandind(jj,2)-fbandind(jj,1))]/(fbandind(jj,2)-fbandind(jj,1));      %rise in fraction of max
         bandfall=[(fbandind(jj,4)-fbandind(jj,3)):-1:0]/(fbandind(jj,4)-fbandind(jj,3));  %fall in fraction of max
         stim_matrix_f(jj,:)=noiseceil-ht*[zeros(1,n1(jj)) bandrise ones(1,n2(jj)) bandfall zeros(1,n3(jj))];  %matrix in dB
      end
   elseif strcmp(ntype,'BandPass')
      for jj=1:nstim
         %define spectral shape
         bandfall=[(fbandind(jj,2)-fbandind(jj,1)):-1:0]/(fbandind(jj,2)-fbandind(jj,1));  %fall in fraction of max
         bandrise=[0:(fbandind(jj,4)-fbandind(jj,3))]/(fbandind(jj,4)-fbandind(jj,3));      %rise in fraction of max
         stim_matrix_f(jj,:)=noiseceil-ht*[ones(1,n1(jj)) bandfall zeros(1,n2(jj)) bandrise ones(1,n3(jj))];  %matrix in dB
      end
   end
   
   %adjust stimuli by calibration if file specified
   if strcmp(calibfile,'none')==0
      [calibi]=read_calib_interpolated(calibfile,f/1000);
      calibi=calibi-calibi(673);   %0 dB atten corresponds to SPL at each freq.  choose ref at specific freq.
      stim_matrix_f=stim_matrix_f-repmat(calibi,nstim,1);
   end
   
   %add negative frequencies and random phase
   stim_matrix_f=[stim_matrix_f stim_matrix_f(:,end-1:-1:2)];  %add amplitudes for negative freq, in dB
   f=[f -1*f(end-1:-1:2)];       %add negative freqs
   %phaseset=(rand(1,length(f)/2-1)*2-1)*pi;   %random phase between -pi:pi for all frequency components in spectrum
   %phase=[0 phaseset pi -phaseset(end:-1:1)];   %assign phase=0 to f=0, phase=pi to f=sr/2, negative of phase to negative freq
   checkstr=sprintf('%sphasesaved.mat',noisebands_root_dir);
   if exist(checkstr)==2
       eval(sprintf('load %sphasesaved.mat phaseset;',noisebands_root_dir)); %load same phase set for all stimuli, assume signal length<=32768, 01/10/03 LR (all expts after this date have same phase set)
   else
       phaseset=(rand(1,length(f)/2-1)*2-1)*pi;   %random phase between -pi:pi for all frequency components in spectrum
       eval(sprintf('save %sphasesaved.mat phaseset;',noisebands_root_dir)); %save/re-use same phase set for all stimuli, assume signal length<=32768, 01/10/03 LR (all expts after this date have same phase set)
   end
   phasesetlen=length(f)/2-1; %number of phases to be read, in case signal length<32768
   phase=[0 phaseset(1:phasesetlen) pi -phaseset(phasesetlen:-1:1)];   %assign phase=0 to f=0, phase=pi to f=sr/2, negative of phase to negative freq
   
   %define stimuli in amplitude and phase
   clear i
   tic
   stim_matrix_fAP=(10.^(stim_matrix_f/20)).*repmat(exp(i*phase),nstim,1);   %stimulus=Amplitude*e(i*phase) 
   %toc
   
   tic
   %define stimuli in time domain using IFFT
   stim_matrix=real(ifft(stim_matrix_fAP,[],2));   %imaginary component is 10e-15 smaller
   %toc
   % %window stimuli to reduce side lobes
   % tic
   % stim_matrix=stim_matrix.*repmat(hamming(npts)',nstim,1);
   % toc
   
   % %normalize all stimuli by same factor to ensure that |s|<1
   % attendiff=20*log10(max(max(abs(stim_matrix),[],2))/min(max(abs(stim_matrix),[],2)));
   % fprintf(1,'Difference in sound level across spectra is on order of %0.2f dB (should be <18 dB)\n\n',attendiff);
   % if abs(attendiff)>=18
   %    fprintf(1,'Difference too large!  Break...');
   %    %errstr=sprintf('Difference too large!  Break...');
   %    break;
   % end
   % max_amplitude=max(max(abs(stim_matrix)))*1.05;
   % stim_matrix=stim_matrix/max_amplitude; 
   % atten_adjust=20*log10(max_amplitude);
   % fprintf(1,'Effective attenuation is %.2f dB\n',static_bi.atten-atten_adjust);
   
   %normalize all stimuli by DIFFERENT factors to ensure that |s|<1
   max_amplitude=max(abs(stim_matrix),[],2)*1.05;
   stim_matrix=stim_matrix./repmat(max_amplitude,1,npts); 
   atten_adjust=20*log10(max_amplitude);
   fprintf(1,'Effective attenuations:\n');
   
   %add onset and offset ramps
   [stim_matrix]=stimulus_add_ramps(stim_matrix,static_bi);
   
   evalstr=sprintf('save(''%sstimsaved.mat'', ''nstim'', ''ntype'', ''sr'', ''dur'', ''rt'', ''f_start'', ''f_step'', ''hbw'', ''slope'', ''ht'', ''noiseceil'', ''calibfile'', ''symmetry'', ''npts'', ''f'', ''stim_matrix_f'', ''phase'', ''stim_matrix'', ''atten_adjust'');',noisebands_root_dir);
   eval(evalstr);
   xx=NelData.File_Manager;
   %evalstr=sprintf('save %sstimU%i_%i_P%i.mat nstim static_bi noiseceil stim_matrix atten_adjust;',xx.dirname,xx.track.No,xx.unit.No,xx.picture+1);
   %evalstr=sprintf('save %sSignals\\U%i_%i_P%i_nb.mat nstim static_bi noiseceil stim_matrix atten_adjust;',xx.dirname,xx.track.No,xx.unit.No,xx.picture+1);
   %eval(evalstr);
end
static_bi.atten-atten_adjust'

%plot spectra of stimuli with corrections
figure(50); clf;
plot(f/1000,stim_matrix_f([1:10:end end],:)); %axis([f_start/3/1000 static_bi.f_end*3 0 50]);
title('Every 10th stimuli is plotted here (complete stimulus set not shown!)');
ylabel('Sound level, dB'); xlabel('Frequency, kHz');
%axis([f(min(n1))/1e3 f(npts/2-min(n3))/1e3 0 40])
axis([0 f(npts/2)/1e3 -ht-5 noiseceil+5])
%hold on;

%plot stimuli in time domain
% figure(51); clf;
% t=[0:1/sr:(length(f)-1)/sr];
% for k=1:10:min(20,nstim)
%    subplot(2,1,ceil(k/10)); hold on;
%    plot(t,stim_matrix(k,:));
% end

%plot_frequency_response(stim_matrix(1,:),sr,f_start,hbw,atten_adjust,'m');

% stim_matrix_ftest=fft(stim_matrix,[],2);
% figure(50); 
% plot(f/1000,20*log10(abs(stim_matrix_ftest([1:10:end],:))),'m'); %axis([f_start/3/1000 static_bi.f_end*3 0 50]);
% max(max(stim_matrix))

%save as unramped .wav file for testing sound level
% save stimtestnw_60 stim_matrix stim_matrix_f f
% eval(sprintf('cd %s%s;',NelData.File_Manager.dirname));
 %wavwrite(stim_matrix(1,:),sr,16,'stimtestnw1_60.wav');
% wavwrite(stim_matrix(51,:),sr,'stimtestn51_60.wav');
% wavwrite(stim_matrix(100,:),sr,'stimtestb100.wav');
% pwd
% [stest,sr2,nbits]=audioread('stimtestnw1_60.wav'); stest=stest';

%test if errors due to roundoff to 16 bit - no.  8 bit - possibly!
%  note: need to comment out when not debugging, because causes system to miss stimuli
%  stest=floor(stim_matrix(1,:)*(2^11-1))/(2^11-1); %conversion to 16 bit
%  plot_frequency_response(stest,sr,f_start,hbw,atten_adjust,'g');
% 
%  plot_frequency_response(stim_matrix(1,:),sr,f_start,hbw,atten_adjust,'m');

%static_bi.phase=phase; %not necc to save if same for all stimuli
static_bi.atten_adjust=atten_adjust;

return

%----------------------------------------------------------------
function [s]=stimulus_add_ramps(s,static_bi)

sr=static_bi.sr;         %sampling rate, in sec
rt=static_bi.rt*1e-3;      %rise time in sec for ramping onsets and offsets

[nstim,npts]=size(s);
t=[0:1/sr:(npts-1)/sr];
indten=max(find(t<=rt));  %find 10 msec point using north chamber sampling rate
ramp=[1:indten]/indten;    %shaping function
s(:,1:indten)=s(:,1:indten).*repmat(ramp,nstim,1);
s(:,npts-indten+1:end)=s(:,npts-indten+1:end).*repmat(ramp(end:-1:1),nstim,1);

% figure(51);
% for k=1:10:min(20,nstim)
%    subplot(2,1,ceil(k/10)); hold on;
%    plot(t,s(k,:),'r');
% end
% s_ftest=fft(s,[],2);
% figure(50); hold on;
% f=[0:sr/npts:sr/2];     %freq vector in Hz
% f=[f -1*f(end-1:-1:2)];       %add negative freqs
% plot(f/1000,20*log10(abs(s_ftest(1,:)))+static_bi.atten_adjust,'g'); %axis([f_start/3/1000 static_bi.f_end*3 0 50]);

%use below code to look at spectrum after ramps added
%%plot_frequency_response(s(1,:),sr,static_bi.f_start*1e3,static_bi.band_hbw,static_bi.atten_adjust,'m');
%plot_frequency_response(s(1,:),sr,static_bi.f_start*1e3,static_bi.band_hbw,0,'m');

% s_ftest2=fft(s(:,indten+1:end-indten),[],2);
% nfftnew=length(f)-indten*2;
% f2=[0:sr/nfftnew:sr/2 -1*[(sr/2-sr/nfftnew):-sr/nfftnew:sr/nfftnew]];
% plot(f2/1000,20*log10(abs(s_ftest2(1,:))),'r'); %axis([f_start/3/1000 static_bi.f_end*3 0 50]);

% % nfftnew=4000;
% % s_ftest2=fft(s(:,3001+[1:nfftnew]),[],2);
% % f2=[0:sr/nfftnew:sr/2 -1*[(sr/2-sr/nfftnew):-sr/nfftnew:sr/nfftnew]];
% % plot(f2/1000,20*log10(abs(s_ftest2(1,:))),'r');
return


%----------------------------------------------------------------
%function plot_frequency_response(sf,sr);
function plot_frequency_response(s,sr,f_start,hbw,atten_adjust,cplot);

[nstim,N]=size(s);
s=s(1,:);
%s=s(1,:).*hamming(N)';

% chunksize_nom=160;   %use 80 for full w, 160 for w=[0:5e-5:pi/4]
% %w=[0:5e-6:pi/4];
% w=[f_start/sr*pi*2*2^(-2*hbw):5e-6:f_start/sr*pi*2*2^(2*hbw)];
% Ht=zeros(1,length(w));
% for n=0:chunksize_nom:N-1 %chunks of 40 lines
%    if chunksize_nom<=N-n
%       chunksize=chunksize_nom;
%    else
%       chunksize=N-n;
%       disp('here');
%    end
%    wmat=repmat(w,chunksize,1);
%    nmat=repmat(n+[0:chunksize-1]',1,length(w));
%    clear j
%    tic
%    Hm=exp(-j*wmat.*nmat);
%    toc
%    clear nmat, clear wmat
%    tic
%    smat=repmat(s(1,n+[1:chunksize])',1,length(w));
%    toc
%    tic
%    Hm=smat.*Hm;
%    toc
%    tic
%    Ht=Ht+sum(Hm,1);
%    toc
%    %pause
% end
% figure(50); hold on;
% HtdB=20*log10(abs(Ht));
% plot(w/2/pi*sr/1e3,HtdB-max(HtdB)+30,'m');
% 
% HtdBsmooth=10*log10(conv(Ht.^2,triang(5)));
% plot(w/2/pi*sr/1e3,HtdBsmooth(3:end-2)-max(HtdBsmooth)+32,'k');

urate=20;
f=[0:sr/N/urate:sr/2];     %freq vector in Hz
f=[f -1*f(end-1:-1:2)];       %add negative freqs
%yf=fft([s zeros(1,N*(urate-1))]);   %zero pad in time domain
%yf=fft([zeros(1,N*(urate-1)/2) s zeros(1,N*(urate-1)/2)].*hamming(N*urate)');   %zero pad in time domain
yf=fft(repmat(s/urate,1,urate));   %test if errors due to discontinuity in wave analyzer signal - no.
%yf=fft(repmat(s,1,urate).*hamming(N*urate)');   %test if errors due to discontinuity in wave analyzer signal - no.
figure(50); hold on;
yfdB=20*log10(max(abs(yf),1e-15));
plot(f/1000,yfdB+atten_adjust,cplot);

return

%*********************************************************************
function [stim_load_flag]=check_if_can_load_prev_stimulus(static_bi,nstim0);

global noisebands_root_dir

%checks to see if params same as previous stimulus, if same then flag is set to load stimulus

checkstr=sprintf('%sstimsaved.mat',noisebands_root_dir);

stim_load_flag=0;   %default: assume stimulus different from previous
if exist(checkstr)==2  %check if stimulus same as previous
    eval(sprintf('load %s nstim ntype f_start f_step hbw sr dur rt slope ht calibfile symmetry;',checkstr));
    if nstim==nstim0 & strcmp(ntype,static_bi.n_type)   %likely params to change
        if f_start==static_bi.f_start*1e3 & f_step==static_bi.f_step & hbw==str2num(static_bi.band_hbw)
            if sr==static_bi.sr & dur==static_bi.dur/1e3 & rt==static_bi.rt*1e-3 
                if slope==static_bi.band_slope & ht==static_bi.band_ht  %no noiseceil check b/c not changeable param 
                    if strcmp(calibfile,static_bi.calib_file) & strcmp(symmetry,static_bi.symmetry)
                        stim_load_flag=1;
                    end
                end
            end
        end
    end
end

return

