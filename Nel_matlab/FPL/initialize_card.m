%TDT initialization params
function card = initialize_card()

fig_num=99;
GB_ch=2; % SH?: my default is GB_ch=1;
FS_tag = 3;
Fs = 48828.125;

%TODO: Make this a conditional to handle NEL1 vs NEL2 ??
[f1RP,RP,~]=load_play_circuit_Nel1(FS_tag,fig_num,GB_ch);
disp('circuit loaded');

card.f1RP = f1RP; 
card.RP = RP; 
end 