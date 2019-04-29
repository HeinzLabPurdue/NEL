function attn = latest_user_attn(newval)
% attn = latest_user_attn(newval)

% AF 12/20/01

persistent latest_attn

if (exist('newval','var') == 1)
    latest_attn = newval;
end
attn = latest_attn;
