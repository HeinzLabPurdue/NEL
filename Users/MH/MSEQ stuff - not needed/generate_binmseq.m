function m=generate_binmseq(n,varargin)

% USAGE:  m=generate_binmseq(order, {polynomial})
%
% This program will generate and return a binary m-sequence of length 2^n (includes an
% appended 0 at the end).  Does this via a linear feedback shift register (LFSR) initialized with
% the optional seed input.  Taps of the LFSR can be specified with the optional polynomial input
% which may only consist of a vector of zeros and ones of length order (and seed).


if nargin<2
    switch n
    case {1}
        p=1;
    case {2}
        p=3;
    case {3}
        p=3;
    case {4}
        p=3;
    case {5}
        p=5;
    case {6}
        p=3;
    case {7}
        p=3;
    case {8}
        p=29;
    case {9}
        p=17;
    case {10}
        p=9;
    case {11}
        p=5;
    case {12}
        p=83;
    case {13}
        p=27;
    case {14}
        p=43;
    case {15}
        p=3;
    case {16}
        p=45;
    case {17}
        p=9;
    case {18}
        p=39;
    case {19}
        p=39;
    case {20}
        p=9;
    end
else
    if ischar(varargin{2})
        p=bin2dec(varargin{2});
    else
        p=varargin{2};
    end
end

seed=2^(n-1);
reg=seed;
m=0;
for i=1:2^n-1
    m(i)=bitget(reg,1);
    newbit=mod(length(find(dec2bin(bitand(p,reg))==49)),2);
    % A bit complicated, but essentially, newbit is the result of a binary sum of the register
    % bits specified by p.  bitand(p,reg) picks out the values of the register bins specified by p,
    % dec2bin turns that number into a binary string, find(==49) finds the ones in the binary str
    % (49 is the ASCII number for '1'), and the length finds how many ones there are.  Mod by 2
    % performs the sum.  
    reg=bitshift(reg,-1);
    reg=reg+2^(n-1)*newbit;
end
m=m(end:-1:1);
m(end+1)=0;
return