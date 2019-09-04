% function out_data=find_line_spectrum(in_data, fs_data, plotVar, fMax, x_output_spread)
% in_data = Vector input

% SP: Created using scripts from Mitra Lab (Chronux)
% Functional: can be simplified a lot
function [out_cos_amp, out_sin_amp, rem_dbSPL, freq_out, dbAmpVal, phiValRad, Fval_line]=find_line_spectrum(in_data, fs_data, plotVar, freq_out, pad)
if ~exist('plotVar', 'var')
    plotVar= 0;
end

in_data=in_data(:)-mean(in_data(:));
params.Fs=fs_data;
if ~exist('pad', 'var')
    params.pad=2;
else
    params.pad=pad;
end
params.tapers= [2 3];
N=length(in_data);
p=1-1/N;
[~,~,~,~,~,~,params]=getparams(params);

[Fval,~,f,~] = ftestc(in_data,params,p,'n');
if ~exist('freq_out', 'var')
    [~, line_ind]= max(Fval);
    freq_out=f(line_ind);
else 
    line_ind= dsearchn(f(:), freq_out);
end

[datafit,Amps,~,Fval,~]=fitlinesc(in_data,params,p/N,'n',freq_out);
% From ER-10 datasheet, 1uV = 0 dB SPL (1 pRef)
% So 1.0 V = 10^6*pRef
% So formula = 20*log10(curRMS*10^6*pRef/pRef)
% = 20*log10(curRMS*10^6)
elec_RMS= sqrt(2)*abs(Amps{1});
dbAmpVal= 20*log10(elec_RMS*1e6);




do_correction= 1;

if do_correction
    % Frequency correction for ER7C beyond 11 kHz
    correction_freq_low= 11e3; % 11 kHz
    correction_freq_high= 20e3;
    correction_max_dB= 10;
    
    if freq_out>correction_freq_low
        correction_dB= correction_max_dB*log10(freq_out/correction_freq_low)/log10(correction_freq_high/correction_freq_low);
        dbAmpVal= dbAmpVal+correction_dB;
    end
end
phiValRad= angle(Amps{1});


plotDebug= 0;
if plotDebug
    figure(11)
    clf;
    hold on;
    plot(f, Fval)
    plot(freq_out, Fval(line_ind), '*')
end

Fval_line= Fval(dsearchn(f(:),freq_out));

rem_dbSPL= 20*log10(rms(in_data-datafit)*10^6);


if plotVar
    xtick_vals= [50 100 500];
    xtick_labs= cellfun(@(x) num2str(x), num2cell(xtick_vals), 'UniformOutput', false);
    figure(12);
    clf;
    hold on;
    %     yrange=32;
    plot_dpss_psd(in_data, fs_data, 'nw', params.tapers(1));
    plot_dpss_psd(datafit, fs_data, 'nw', params.tapers(1));
    set(gca, 'XTick', xtick_vals, 'XTickLabel', xtick_labs);
end

out_cos_amp= elec_RMS*cos(phiValRad);
out_sin_amp= elec_RMS*sin(phiValRad);


end


function [tapers,pad,Fs,fpass,err,trialave,params]=getparams(params)
% Helper function to convert structure params to variables used by the
% various routines - also performs checks to ensure that parameters are
% defined; returns default values if they are not defined.
%
% Usage: [tapers,pad,Fs,fpass,err,trialave,params]=getparams(params)
%
% Inputs:
%       params: structure with fields tapers, pad, Fs, fpass, err, trialave
%           - optional
%             tapers : precalculated tapers from dpss or in the one of the following
%                       forms:
%                       (1) A numeric vector [TW K] where TW is the
%                           time-bandwidth product and K is the number of
%                           tapers to be used (less than or equal to
%                           2TW-1).
%                       (2) A numeric vector [W T p] where W is the
%                           bandwidth, T is the duration of the data and p
%                           is an integer such that 2TW-p tapers are used. In
%                           this form there is no default i.e. to specify
%                           the bandwidth, you have to specify T and p as
%                           well. Note that the units of W and T have to be
%			                consistent: if W is in Hz, T must be in seconds
% 			                and vice versa. Note that these units must also
%			                be consistent with the units of params.Fs: W can
%		    	            be in Hz if and only if params.Fs is in Hz.
%                           The default is to use form 1 with TW=3 and K=5
%
%	        pad		    (padding factor for the FFT) - optional (can take values -1,0,1,2...).
%                    -1 corresponds to no padding, 0 corresponds to padding
%                    to the next highest power of 2 etc.
%			      	 e.g. For N = 500, if PAD = -1, we do not pad; if PAD = 0, we pad the FFT
%			      	 to 512 points, if pad=1, we pad to 1024 points etc.
%			      	 Defaults to 0.
%           Fs   (sampling frequency) - optional. Default 1.
%           fpass    (frequency band to be used in the calculation in the form
%                                   [fmin fmax])- optional.
%                                   Default all frequencies between 0 and Fs/2
%           err  (error calculation [1 p] - Theoretical error bars; [2 p] - Jackknife error bars
%                                   [0 p] or 0 - no error bars) - optional. Default 0.
%           trialave (average over trials when 1, don't average when 0) - optional. Default 0
% Outputs:
% The fields listed above as well as the struct params. The fields are used
% by some routines and the struct is used by others. Though returning both
% involves overhead, it is a safer, simpler thing to do.

if ~isfield(params,'tapers') || isempty(params.tapers)  %If the tapers don't exist
    disp('tapers unspecified, defaulting to params.tapers=[3 5]');
    params.tapers=[3 5];
end
if ~isempty(params) && length(params.tapers)==3
    % Compute timebandwidth product
    TW = params.tapers(2)*params.tapers(1);
    % Compute number of tapers
    K  = floor(2*TW - params.tapers(3));
    params.tapers = [TW  K];
end

if ~isfield(params,'pad') || isempty(params.pad)
    params.pad=0;
end
if ~isfield(params,'Fs') || isempty(params.Fs)
    params.Fs=1;
end
if ~isfield(params,'fpass') || isempty(params.fpass)
    params.fpass=[0 params.Fs/2];
end
if ~isfield(params,'err') || isempty(params.err)
    params.err=0;
end
if ~isfield(params,'trialave') || isempty(params.trialave)
    params.trialave=0;
end

tapers=params.tapers;
pad=params.pad;
Fs=params.Fs;
fpass=params.fpass;
err=params.err;
trialave=params.trialave;
end

function [Fval,A,f,sig,sd] = ftestc(data,params,p,plt)
% computes the F-statistic for sine wave in locally-white noise (continuous data).
%
% [Fval,A,f,sig,sd] = ftestc(data,params,p,plt)
%
%  Inputs:
%       data        (data in [N,C] i.e. time x channels/trials or a single
%       vector) - required.
%       params      structure containing parameters - params has the
%       following fields: tapers, Fs, fpass, pad
%           tapers : precalculated tapers from dpss or in the one of the following
%                    forms:
%                    (1) A numeric vector [TW K] where TW is the
%                        time-bandwidth product and K is the number of
%                        tapers to be used (less than or equal to
%                        2TW-1).
%                    (2) A numeric vector [W T p] where W is the
%                        bandwidth, T is the duration of the data and p
%                        is an integer such that 2TW-p tapers are used. In
%                        this form there is no default i.e. to specify
%                        the bandwidth, you have to specify T and p as
%                        well. Note that the units of W and T have to be
%                        consistent: if W is in Hz, T must be in seconds
%                        and vice versa. Note that these units must also
%                        be consistent with the units of params.Fs: W can
%                        be in Hz if and only if params.Fs is in Hz.
%                        The default is to use form 1 with TW=3 and K=5
%
%	        Fs 	        (sampling frequency) -- optional. Defaults to 1.
%           fpass       (frequency band to be used in the calculation in the form
%                                   [fmin fmax])- optional.
%                                   Default all frequencies between 0 and Fs/2
%	        pad		    (padding factor for the FFT) - optional (can take values -1,0,1,2...).
%                    -1 corresponds to no padding, 0 corresponds to padding
%                    to the next highest power of 2 etc.
%			      	 e.g. For N = 500, if PAD = -1, we do not pad; if PAD = 0, we pad the FFT
%			      	 to 512 points, if pad=1, we pad to 1024 points etc.
%			      	 Defaults to 0.
%	    p		    (P-value to calculate error bars for) - optional.
%                           Defaults to 0.05/N where N is the number of samples which
%	                 corresponds to a false detect probability of approximately 0.05.
%       plt         (y/n for plot and no plot respectively)
%
%  Outputs:
%       Fval        (F-statistic in frequency x channels/trials form)
%  	    A		    (Line amplitude for X in frequency x channels/trials form)
%	    f		    (frequencies of evaluation)
%       sig         (F distribution (1-p)% confidence level)
%       sd          (standard deviation of the amplitude C)
if nargin < 1; error('Need data'); end
if nargin < 2 || isempty(params); params=[]; end
[tapers,pad,Fs,fpass,~,~,params]=getparams(params);
clear err trialave
data=data(:);
[N,C]=size(data);
if nargin<3 || isempty(p);p=0.05/N;end
if nargin<4 || isempty(plt); plt='n';end
tapers=dpsschk(tapers,N,Fs); % calculate the tapers
[N,K]=size(tapers);
nfft=max(2^(nextpow2(N)+pad),N);% number of points in fft
[f,findx]=getfgrid(Fs,nfft,fpass);% frequency grid to be returned

Kodd=1:2:K;
Keven=2:2:K;
J=mtfftc(data,tapers,nfft,Fs);% tapered fft of data - f x K x C
Jp=J(findx,Kodd,:); % drop the even ffts and restrict fft to specified frequency grid - f x K x C
tapers=tapers(:,:,ones(1,C)); % add channel indices to the tapers - t x K x C
H0 = squeeze(sum(tapers(:,Kodd,:),1)); % calculate sum of tapers for even prolates - K x C
if C==1;H0=H0';end
Nf=length(findx);% number of frequencies
H0 = H0(:,:,ones(1,Nf)); % add frequency indices to H0 - K x C x f
H0=permute(H0,[3 1 2]); % permute H0 to get dimensions to match those of Jp - f x K x C
H0sq=sum(H0.*H0,2);% sum of squares of H0^2 across taper indices - f x C
JpH0=sum(Jp.*squeeze(H0),2);% sum of the product of Jp and H0 across taper indices - f x C
A=squeeze(JpH0./H0sq); % amplitudes for all frequencies and channels
Kp=size(Jp,2); % number of even prolates
Ap=A(:,:,ones(1,Kp)); % add the taper index to C
Ap=permute(Ap,[1 3 2]); % permute indices to match those of H0
Jhat=Ap.*H0; % fitted value for the fft

num=(K-1).*(abs(A).^2).*squeeze(H0sq);%numerator for F-statistic
den=squeeze(sum(abs(Jp-Jhat).^2,2)+sum(abs(J(findx,Keven,:)).^2,2));% denominator for F-statistic
Fval=num./den; % F-statisitic
if nargout > 3
    sig=finv(1-p,2,2*K-2); % F-distribution based 1-p% point
    var=den./(K*squeeze(H0sq)); % variance of amplitude
    sd=sqrt(var);% standard deviation of amplitude
end
if nargout==0 || strcmp(plt,'y')
    [S,f]=mtspectrumc(detrend(data),params);subplot(211); plot(f,10*log10(S));xlabel('frequency Hz'); ylabel('Spectrum dB');
    subplot(212);plot(f,Fval); line(get(gca,'xlim'),[sig sig],'Color','r');xlabel('frequency Hz');
    ylabel('F ratio');
end
A=A*Fs;
end

function [tapers,eigs]=dpsschk(tapers,N,Fs)
% Helper function to calculate tapers and, if precalculated tapers are supplied,
% to check that they (the precalculated tapers) the same length in time as
% the time series being studied. The length of the time series is specified
% as the second input argument N. Thus if precalculated tapers have
% dimensions [N1 K], we require that N1=N.
% Usage: tapers=dpsschk(tapers,N,Fs)
% Inputs:
% tapers        (tapers in the form of:
%                                   (i) precalculated tapers or,
%                                   (ii) [NW K] - time-bandwidth product, number of tapers)
%
% N             (number of samples)
% Fs            (sampling frequency - this is required for nomalization of
%                                     tapers: we need tapers to be such
%                                     that integral of the square of each taper equals 1
%                                     dpss computes tapers such that the
%                                     SUM of squares equals 1 - so we need
%                                     to multiply the dpss computed tapers
%                                     by sqrt(Fs) to get the right
%                                     normalization)
% Outputs:
% tapers        (calculated or precalculated tapers)
% eigs          (eigenvalues)
if nargin < 3; error('Need all arguments'); end
sz=size(tapers);
if sz(1)==1 && sz(2)==2
    [tapers,eigs]=dpss(N,tapers(1),tapers(2));
    tapers = tapers*sqrt(Fs);
elseif N~=sz(1)
    error('seems to be an error in your dpss calculation; the number of time points is different from the length of the tapers');
end
end

function [f,findx]=getfgrid(Fs,nfft,fpass)
% Helper function that gets the frequency grid associated with a given fft based computation
% Called by spectral estimation routines to generate the frequency axes
% Usage: [f,findx]=getfgrid(Fs,nfft,fpass)
% Inputs:
% Fs        (sampling frequency associated with the data)-required
% nfft      (number of points in fft)-required
% fpass     (band of frequencies at which the fft is being calculated [fmin fmax] in Hz)-required
% Outputs:
% f         (frequencies)
% findx     (index of the frequencies in the full frequency grid). e.g.: If
% Fs=1000, and nfft=1048, an fft calculation generates 512 frequencies
% between 0 and 500 (i.e. Fs/2) Hz. Now if fpass=[0 100], findx will
% contain the indices in the frequency grid corresponding to frequencies <
% 100 Hz. In the case fpass=[0 500], findx=[1 512].
if nargin < 3; error('Need all arguments'); end
df=Fs/nfft;
f=0:df:Fs; % all possible frequencies
f=f(1:nfft);
if length(fpass)~=1
    findx=find(f>=fpass(1) & f<=fpass(end));
else
    [~,findx]=min(abs(f-fpass));
    clear fmin
end
f=f(findx);
end

function J=mtfftc(data,tapers,nfft,Fs)
% Multi-taper fourier transform - continuous data
%
% Usage:
% J=mtfftc(data,tapers,nfft,Fs) - all arguments required
% Input:
%       data (in form samples x channels/trials or a single vector)
%       tapers (precalculated tapers from dpss)
%       nfft (length of padded data)
%       Fs   (sampling frequency)
%
% Output:
%       J (fft in form frequency index x taper index x channels/trials)
if nargin < 4; error('Need all input arguments'); end
data=data(:);
[NC,C]=size(data); % size of data
[NK, K]=size(tapers); % size of tapers
if NK~=NC; error('length of tapers is incompatible with length of data'); end
tapers=tapers(:,:,ones(1,C)); % add channel indices to tapers
data=data(:,:,ones(1,K)); % add taper indices to data
data=permute(data,[1 3 2]); % reshape data to get dimensions to match those of tapers
data_proj=data.*tapers; % product of data with tapers
J=fft(data_proj,nfft)/Fs;   % fft of projected data
end

function [S,f,Serr]=mtspectrumc(data,params)
% Multi-taper spectrum - continuous process
%
% Usage:
%
% [S,f,Serr]=mtspectrumc(data,params)
% Input:
% Note units have to be consistent. See chronux.m for more information.
%       data (in form samples x channels/trials) -- required
%       params: structure with fields tapers, pad, Fs, fpass, err, trialave
%       -optional
%           tapers : precalculated tapers from dpss or in the one of the following
%                    forms:
%                    (1) A numeric vector [TW K] where TW is the
%                        time-bandwidth product and K is the number of
%                        tapers to be used (less than or equal to
%                        2TW-1).
%                    (2) A numeric vector [W T p] where W is the
%                        bandwidth, T is the duration of the data and p
%                        is an integer such that 2TW-p tapers are used. In
%                        this form there is no default i.e. to specify
%                        the bandwidth, you have to specify T and p as
%                        well. Note that the units of W and T have to be
%                        consistent: if W is in Hz, T must be in seconds
%                        and vice versa. Note that these units must also
%                        be consistent with the units of params.Fs: W can
%                        be in Hz if and only if params.Fs is in Hz.
%                        The default is to use form 1 with TW=3 and K=5
%
%	        pad		    (padding factor for the FFT) - optional (can take values -1,0,1,2...).
%                    -1 corresponds to no padding, 0 corresponds to padding
%                    to the next highest power of 2 etc.
%			      	 e.g. For N = 500, if PAD = -1, we do not pad; if PAD = 0, we pad the FFT
%			      	 to 512 points, if pad=1, we pad to 1024 points etc.
%			      	 Defaults to 0.
%           Fs   (sampling frequency) - optional. Default 1.
%           fpass    (frequency band to be used in the calculation in the form
%                                   [fmin fmax])- optional.
%                                   Default all frequencies between 0 and Fs/2
%           err  (error calculation [1 p] - Theoretical error bars; [2 p] - Jackknife error bars
%                                   [0 p] or 0 - no error bars) - optional. Default 0.
%           trialave (average over trials/channels when 1, don't average when 0) - optional. Default 0
% Output:
%       S       (spectrum in form frequency x channels/trials if trialave=0;
%               in the form frequency if trialave=1)
%       f       (frequencies)
%       Serr    (error bars) only for err(1)>=1

if nargin < 1; error('Need data'); end
if nargin < 2; params=[]; end
[tapers,pad,Fs,fpass,err,trialave,~]=getparams(params);
if nargout > 2 && err(1)==0
    %   Cannot compute error bars with err(1)=0. Change params and run again.
    error('When Serr is desired, err(1) has to be non-zero.');
end
data=change_row_to_column(data);
N=size(data,1);
nfft=max(2^(nextpow2(N)+pad),N);
[f,findx]=getfgrid(Fs,nfft,fpass);
tapers=dpsschk(tapers,N,Fs); % check tapers
J=mtfftc(data,tapers,nfft,Fs);
J=J(findx,:,:);
S=permute(mean(conj(J).*J,2),[1 3 2]);
if trialave
    S=squeeze(mean(S,2));
else
    S=squeeze(S);
end
if nargout==3
    Serr=specerr(S,J,err,trialave);
end
end

function [datafit,Amps,freqs,Fval,sig]=fitlinesc(data,params,p,plt,f0)
% fits significant sine waves to data (continuous data).
%
% Usage: [datafit,Amps,freqs,Fval,sig]=fitlinesc(data,params,p,plt,f0)
%
%  Inputs:
% Note that units of Fs, fpass have to be consistent.
%       data        (data in [N,C] i.e. time x channels/trials or a single
%       vector) - required.
%       params      structure containing parameters - params has the
%       following fields: tapers, Fs, fpass, pad
%           tapers : precalculated tapers from dpss or in the one of the following
%                    forms:
%                   (1) A numeric vector [TW K] where TW is the
%                       time-bandwidth product and K is the number of
%                       tapers to be used (less than or equal to
%                       2TW-1).
%                   (2) A numeric vector [W T p] where W is the
%                       bandwidth, T is the duration of the data and p
%                       is an integer such that 2TW-p tapers are used. In
%                       this form there is no default i.e. to specify
%                       the bandwidth, you have to specify T and p as
%                       well. Note that the units of W and T have to be
%                       consistent: if W is in Hz, T must be in seconds
%                       and vice versa. Note that these units must also
%                       be consistent with the units of params.Fs: W can
%                       be in Hz if and only if params.Fs is in Hz.
%                       The default is to use form 1 with TW=3 and K=5
%
%	        Fs 	        (sampling frequency) -- optional. Defaults to 1.
%               fpass       (frequency band to be used in the calculation in the form
%                                   [fmin fmax])- optional.
%                                   Default all frequencies between 0 and Fs/2
%	        pad		    (padding factor for the FFT) - optional (can take values -1,0,1,2...).
%                    -1 corresponds to no padding, 0 corresponds to padding
%                    to the next highest power of 2 etc.
%			      	 e.g. For N = 500, if PAD = -1, we do not pad; if PAD = 0, we pad the FFT
%			      	 to 512 points, if pad=1, we pad to 1024 points etc.
%			      	 Defaults to 0.
%	    p		    (P-value to calculate error bars for) - optional.
%                           Defaults to 0.05/N where N is data length.
%       plt         (y/n for plot and no plot respectively) - plots the
%       Fratio at all frequencies if y
%       f0          frequencies at which you want to remove the
%                   lines - if unspecified the program
%                   will compute the significant lines
%
%
%  Outputs:
%       datafit        (linear superposition of fitted sine waves)
%       Amps           (amplitudes at significant frequencies)
%       freqs          (significant frequencies)
%       Fval           (Fstatistic at all frequencies)
%       sig            (significance level for F distribution p value of p)
data=data(:);
[N,C]=size(data);
if nargin < 2 || isempty(params); params=[]; end
[tapers,~,Fs,~,~,~,params]=getparams(params);
clear pad fpass err trialave;
if nargin < 3 || isempty(p);p=0.05/N;end
if nargin < 4 || isempty(plt); plt='n'; end
if nargin < 5; f0=[]; end
params.tapers=dpsschk(tapers,N,Fs); % calculate the tapers
[Fval,A,f,sig] = ftestc(data,params,p,plt);
if isempty(f0)
    fmax=findpeaks(Fval,sig);
    freqs=cell(1,C);
    Amps=cell(1,C);
    datafit=data;
    for ch=1:C
        fsig=f(fmax(ch).loc);
        freqs{ch}=fsig;
        Amps{ch}=A(fmax(ch).loc,ch);
        datafit(:,ch)=exp(1i*2*pi*(0:N-1)'*fsig/Fs)*A(fmax(ch).loc,ch)+exp(-1i*2*pi*(0:N-1)'*fsig/Fs)*conj(A(fmax(ch).loc,ch));
    end
else
    indx = zeros( length(f0),1 );
    for n=1:length(f0)
        [~,indx(n)]=min(abs(f-f0(n)));
    end
    fsig=f(indx);
    freqs= cell(numel(C),1);
    Amps= cell(numel(C),1);
    datafit= nan(N,numel(C));
    for ch=1:C
        freqs{ch}=fsig;
        Amps{ch}=A(indx,ch);
        datafit(:,ch)=exp(1i*2*pi*(0:N-1)'*fsig/Fs)*A(indx,ch)+exp(-1i*2*pi*(0:N-1)'*fsig/Fs)*conj(A(indx,ch));
    end
end
end