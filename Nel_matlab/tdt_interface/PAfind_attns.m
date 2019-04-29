function PAattns = PAfind_attns(attns,select,connect)
%

% AF 9/3/01

global SwitchBox PA

Nattns = length(PA);
attns = attns(:);
sel_key1 = SwitchBox(1).select_key;
sel_key2 = SwitchBox(2).select_key;
sel1 = SwitchBox(1).select_res(:,find(sel_key1 == select(1)));
sel2 = SwitchBox(2).select_res(:,find(sel_key2 == select(2)));
n = length(sel1);

con_key1 = SwitchBox(1).connect_key;
con_key2 = SwitchBox(2).connect_key;
con1 = SwitchBox(1).connect_res(:,find(con_key1 == connect(1)));
con2 = SwitchBox(2).connect_res(:,find(con_key2 == connect(2)));

attn_coef = zeros(2*n,Nattns);
attn_coef(:,1) = [sel1 ; sel1];
attn_coef(:,2) = [sel2 ; sel2];
linprog_f      = [1 1]';
if (Nattns == 4)
   attn_coef(:,3) = [con1(2)*sel1 + con1(1)*sel2 ; zeros(n,1)];
   attn_coef(:,4) = [zeros(n,1) ; con2(2)*sel1 + con2(1)*sel2];
   linprog_f      = [1 1 0 0]';
   
   ind = find(isnan(attns));
   if (any(attn_coef(ind,3:4) ~= 0))
      nelerror('Internal Error in PAfind_attns: SwitchBox and PA settings may be erroneous!');
   end
end
ind = find(~isnan(attns));
attn_coef = attn_coef(ind,:);
attns     = attns(ind);

% Use options are Display, Diagnostics, TolFun, LargeScale, MaxIter. 
if (~isempty(attns))
   options = optimset('Display','off','LargeScale','off');
   PAattns = linprog(linprog_f, -eye(Nattns), zeros(Nattns,1), attn_coef, attns, [],[],[], options);
   if (~isempty(PAattns))
      if (any(abs(attns - attn_coef*PAattns) > 0.01) | any(PAattns<-1e-6))
	% LQ 06/15/05
	PAattns = [];
      end
   end
   PAattns = round(PAattns*100)/100;    %MWMSMH - 08/30/2016 rounds linprog ~epsilon outputs near zero to 0.1dB 
else
   PAattns = repmat(120,Nattns,1);
end
