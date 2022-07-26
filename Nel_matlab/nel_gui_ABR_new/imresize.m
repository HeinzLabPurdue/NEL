function varargout = imresize(varargin)
%IMRESIZE Resize image.
%   IMRESIZE resizes an image of any type using the specified
%   interpolation method. Supported interpolation methods
%   include:
%
%        'nearest'  (default) nearest neighbor interpolation
%
%        'bilinear' bilinear interpolation
%
%        'bicubic'  bicubic interpolation
%
%   B = IMRESIZE(A,M,METHOD) returns an image that is M times the
%   size of A. If M is between 0 and 1.0, B is smaller than A. If
%   M is greater than 1.0, B is larger than A. If METHOD is
%   omitted, IMRESIZE uses nearest neighbor interpolation.
%
%   B = IMRESIZE(A,[MROWS MCOLS],METHOD) returns an image of size
%   MROWS-by-MCOLS. If the specified size does not produce the
%   same aspect ratio as the input image has, the output image is
%   distorted.
%
%   When the specified output size is smaller than the size of
%   the input image, and METHOD is 'bilinear' or 'bicubic',
%   IMRESIZE applies a lowpass filter before interpolation to
%   reduce aliasing. The default filter size is 11-by-11.
%
%   You can specify a different order for the default filter
%   using:
%
%        [...] = IMRESIZE(...,METHOD,N)
%
%   N is an integer scalar specifying the size of the filter,
%   which is N-by-N. If N is 0, IMRESIZE omits the filtering
%   step.
%
%   You can also specify your own filter H using:
%
%        [...] = IMRESIZE(...,METHOD,H)
%
%   H is any two-dimensional FIR filter (such as those returned
%   by FTRANS2, FWIND1, FWIND2, or FSAMP2).
%
%   Class Support
%   -------------
%   The input image can be of class uint8, uint16, or
%   double. The output image is of the same class as the input
%   image.
%
%   See also IMROTATE.

%   Grandfathered Syntaxes:
%
%   [R1,G1,B1] = IMRESIZE(R,G,B,M,'method') or 
%   [R1,G1,B1] = IMRESIZE(R,G,B,[MROWS NCOLS],'method') resizes
%   the RGB image in the matrices R,G,B.  'bilinear' is the
%   default interpolation method.

[A,m,method,h] = parse_inputs(varargin{:});

threeD = (ndims(A)==3); % Determine if input includes a 3-D array

if threeD,
   r = resizeImage(A(:,:,1),m,method,h);
   g = resizeImage(A(:,:,2),m,method,h);
   b = resizeImage(A(:,:,3),m,method,h);
   B = cat(3,r,g,b);
else 
   B = resizeImage(A,m,method,h);
end

if (nargout == 0)
    imshow(B);
elseif (threeD & (nargout == 3))
    varargout{1} = B(:,:,1);
    varargout{2} = B(:,:,2);
    varargout{3} = B(:,:,3);
else
    varargout{1} = B;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Function: resizeImage
%

function b = resizeImage(A,m,method,h)
% Inputs:
%         A       Input Image
%         m       resizing factor or 1-by-2 size vector
%         method  'nearest','bilinear', or 'bicubic'
%         h       the anti-aliasing filter to use.
%                 if h is zero, don't filter
%                 if h is an integer, design and use a filter of size h
%                 if h is empty, use default filter

inputClass = class(A);
classChanged = 0;
logicalIn = islogical(A);

if isa(A, 'uint16') % Make sure uint16's are not binary
  logicalIn = 0; 
end

if prod(size(m))==1,
   bsize = floor(m*size(A));
else
   bsize = m;
end

if any(size(bsize)~=[1 2]),
   error('M must be either a scalar multiplier or a 1-by-2 size vector.');
end

% values in bsize must be at least 1.
bsize = max(bsize, 1);

if (any((bsize < 4) & (bsize < size(A))) & ~strcmp(method, 'nea'))
   fprintf('Input is too small for bilinear or bicubic method;\n');
   fprintf('using nearest-neighbor method instead.\n');
   method = 'nea';
end

if isempty(h),
   nn = 11; % Default filter size
else
   if prod(size(h))==1, 
      nn = h; h = []; 
   else 
      nn = 0;
   end
end

[m,n] = size(A);

if nn>0 & method(1)=='b',  % Design anti-aliasing filter if necessary
   if bsize(1)<m, h1 = DesignFilter(nn-1,bsize(1)/m); else h1 = 1; end
   if bsize(2)<n, h2 = DesignFilter(nn-1,bsize(2)/n); else h2 = 1; end
   if length(h1)>1 | length(h2)>1, 
       if (~isa(A,'double'))
           A = im2double(A);
           classChanged = 1;
       end
       a = filter2(h1',filter2(h2,A)); 
   else 
       a = A; 
   end
elseif method(1)=='b' & (prod(size(h)) > 1),
    if (~isa(A,'double'))
        A = im2double(A);
        classChanged = 1;
    end
    a = filter2(h,A);
else
    a = A;
end

if method(1)=='n', % Nearest neighbor interpolation
    dx = n/bsize(2); 
    dy = m/bsize(1); 
    uu = (dx/2+.5):dx:n+.5; 
    vv = (dy/2+.5):dy:m+.5;
    uu(uu<1) = 1;
    uu(uu>n) = n;
    vv(vv<1) = 1;
    vv(vv>m) = m;
    b = a(round(vv),round(uu));
elseif all(method == 'bil') | all(method == 'bic'),

    if (all(method == 'bil'))
        filterFun = 'triangle';
    else
        filterFun = 'cubic';
    end

    udata = [1 size(a,2)] - 1;
    vdata = [1 size(a,1)] - 1;
    hScale = (bsize(2) - 1) / (size(a,2) - 1);
    vScale = (bsize(1) - 1) / (size(a,1) - 1);
    T = [hScale 0 0; 0 vScale 0; 0 0 1];

    b = imtransform(udata, vdata, a, 0:(bsize(2)-1), ...
        (0:(bsize(1)-1))', 'affine', T, filterFun);
       
else
   error(['Unknown interpolation method: ',method]);
end

% Be careful with binary images:
if logicalIn 
  if strcmp(inputClass, 'uint8')  
    % output should be uint8 binary
    if isa(b, 'uint8') 
      b = (b~=0);
    else % b became double
      b = uint8(b>0.5);
    end
  end
elseif (classChanged)
    b = changeclass(inputClass, b);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Function: parse_inputs
%

function [A,m,method,h] = parse_inputs(varargin)
% Outputs:  A       the input image
%           m       the resize scaling factor or the new size
%           method  interpolation method (nearest,bilinear,bicubic)
%           h       if 0, skip filtering; if non-zero scalar, use filter 
%                   of size h; otherwise h is the anti-aliasing filter.

switch nargin
case 2,                        % imresize(A,m)
   A = varargin{1};
   m = varargin{2};
   method = 'nearest';
   h = [];
case 3,                        % imresize(A,m,method)
   A = varargin{1};
   m = varargin{2};
   method = varargin{3};
   h = [];
case 4,
   if isstr(varargin{3})       % imresize(A,m,method,h)
      A = varargin{1};
      m = varargin{2};
      method = varargin{3};
      h = varargin{4};
   else                        % imresize(r,g,b,m)
      for i=1:3
         if ~isa(varargin{i},'double')
            error('Please use 3-d RGB array syntax with nondouble image data');
         end
      end
      A = zeros([size(varargin{1}),3]);
      A(:,:,1) = varargin{1};
      A(:,:,2) = varargin{2};
      A(:,:,3) = varargin{3};
      m = varargin{4};
      method = 'nearest';
      h = [];
   end
case 5,                        % imresize(r,g,b,m,'method')
   for i=1:3
      if ~isa(varargin{i},'double')
         error('Please use 3-d RGB array syntax with nondouble image data');
      end
   end
   A = zeros([size(varargin{1}),3]);
   A(:,:,1) = varargin{1};
   A(:,:,2) = varargin{2};
   A(:,:,3) = varargin{3};
   m = varargin{4};
   method = varargin{5};
   h = [];
case 6,                        % imresize(r,g,b,m,'method',h)
   for i=1:3
      if ~isa(varargin{i},'double')
         error('Please use 3-d RGB array syntax with nondouble image data');
      end
   end
   A = zeros([size(varargin{1}),3]);
   A(:,:,1) = varargin{1};
   A(:,:,2) = varargin{2};
   A(:,:,3) = varargin{3};
   m = varargin{4};
   method = varargin{5};
   h = varargin{6};
otherwise,
   error('Invalid input arguments.');
end

method = [lower(method),'   ']; % Protect against short method
method = method(1:3);


function b = DesignFilter(N,Wn)
% Code from SPT v3 fir1.m and hanning.m

N = N + 1;
odd = rem(N,2);
wind = .54 - .46*cos(2*pi*(0:N-1)'/(N-1));
fl = Wn(1)/2;
c1 = fl;
if (fl >= .5 | fl <= 0)
    error('Frequency must lie between 0 and 1')
end 
nhlf = fix((N + 1)/2);
i1=1 + odd;

if odd
   b(1) = 2*c1;
end
xn=(odd:nhlf-1) + .5*(1-odd);
c=pi*xn;
c3=2*c1*c;
b(i1:nhlf)=(sin(c3)./c);
b = real([b(nhlf:-1:i1) b(1:nhlf)].*wind(:)');
gain = abs(polyval(b,1));
b = b/gain;

%%%
%%% Contributions
%%%
function [idx,weights] = Contributions(Na, Nb, fun, width)
% Compute indices and weight vectors to resample an Na-length
% vector into and Nb-length vector, given the name of the
% interpolating kernel and its width.

scale = (Nb - 1) / (Na - 1);

% if (s < 1)
%     width = fwidth / s;
%    fscale = 1 / s;
% else
%     width = fwidth;
%     fscale = 1;
% end

P = width + 2;

k = (0:Nb-1)';
center = k/scale;
left = floor(center - width/2);
idx = repmat(left, [1 P]) + repmat(0:P-1, [Nb 1]);
weights = feval(fun, repmat(center, [1 P]) - idx);

% Make indices one-based instead of zero-based
idx = idx + 1;

% Clamp out-of-range indices
idx = min(max(1, idx), Na);

% If a column in w is all zero, get rid of it.
kill = find(~any(weights,1));
if (~isempty(kill))
    weights(:,kill) = [];
    idx(:,kill) = [];
end

%%%
%%% Triangle
%%%
function f = Triangle(x)
% Interpolating kernel for linear interpolation.
absx = abs(x);
f = (1 - absx) .* ((0 <= absx) & (absx <= 1));

%%%
%%% Cubic
%%%
function f = Cubic(x)
% Interpolating kernel for cubic interpolation.
%
% See Keys, "Cubic Convolution Interpolation for Digital Image
% Processing," IEEE Transactions on Acoustics, Speech, and Signal
% Processing, Vol. ASSP-29, No. 6, December 1981, p. 1155.

absx = abs(x);
absx2 = absx.^2;
absx3 = absx.^3;

f = (1.5*absx3 - 2.5*absx2 + 1) .* (absx <= 1) + ...
                (-0.5*absx3 + 2.5*absx2 - 4*absx + 2) .* ...
                ((1 < absx) & (absx <= 2));
