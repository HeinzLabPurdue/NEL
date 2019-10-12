function varargout = wiring_test(command)
% This function is used to test whether the hardware connection of
% the selecter and mixer is correct. Nel users can use this program
% to make sure the system wiring is working correctly before doing
% experiment. 
global NelData
if ~nargin
  handles.fig = figure('NumberTitle','off','Name','Wiring Test For Nel', ...
		       'Units','normalized','position',[.25 .2 .5 ...
		    .3],'Menubar','none', 'color', get(0,'DefaultuicontrolBackgroundColor'), 'DeleteFcn','wiring_test(''delete'')');
   axes('Position',[0 0 1 1]);
   axis('off');
   text(.15,.8,'RP2.1:','color','k', ...
      'horizontalalignment','right','VerticalAlignment','bottom', ...
      );
   text(.15,.4,'RP2.2:','color','k', ...
      'horizontalalignment','right','VerticalAlignment','bottom', ...
      );
   text(.25,.8,'OUT1','color','b', ...
      'horizontalalignment','right','VerticalAlignment','bottom', ...
      );
   text(.25,.65,'OUT2','color','b', ...
      'horizontalalignment','right','VerticalAlignment','bottom', ...
      );
   text(.25,.4,'OUT1','color','b', ...
      'horizontalalignment','right','VerticalAlignment','bottom', ...
      );
   text(.25,.25,'OUT2','color','b', ...
      'horizontalalignment','right','VerticalAlignment','bottom', ...
      );
   text(.35,.9,'Left Ear','color','b', ...
      'horizontalalignment','center','VerticalAlignment','bottom', ...
      );
   text(.55,.9,'Right Ear','color','b', ...
      'horizontalalignment','center','VerticalAlignment','bottom', ...
      );
   handles.error = text(.15,.1,['Error:The chosen mixing combination' ...
		    ' is not possible!!!'],'color','r', ...
      'horizontalalignment','left','VerticalAlignment','bottom', ...
      'visible','off');
   
   % 128,64,32,16 stands for LE receives stimuli from RP2_1 out1,
   % RP2_1 out2, RP2_2 out1, RP2_2 out2. and 8,4,2,1 stands for RE
   % respectively. 
   new_checkbox(handles.fig, [.35 .8 .15 .1], 128,1,'Left');
   new_checkbox(handles.fig, [.35 .65 .15 .1],64, 0,'Left');
   new_checkbox(handles.fig, [.35 .4 .15 .1], 32, 0,'Left');
   new_checkbox(handles.fig, [.35 .25 .15 .1],16, 0,'Left');
   new_checkbox(handles.fig, [.55 .8 .15 .1], 8,  0,'Right');
   new_checkbox(handles.fig, [.55 .65 .15 .1],4,  0,'Right');
   new_checkbox(handles.fig, [.55 .4 .15 .1], 2,  1,'Right');
   new_checkbox(handles.fig, [.55 .25 .15 .1],1,  0,'Right');

   handles.mix = 130 ; % LE with RP2_1 out1, RE with RP2_2 out1

   % TDT setup
   handles.RP2_1 = actxcontrol('RPco.x',[0 0 1 1],handles.fig);
   if (invoke(handles.RP2_1,'ConnectRP2',NelData.General.RP2_3and4,1) == 0)
     msgbox('can''t connect to RP2_1');
   end
   invoke(handles.RP2_1,'ClearCOF');
   invoke(handles.RP2_1,'LoadCof',which('wiring_test.rco'));
   invoke(handles.RP2_1, 'SetTagVal', 'BitOut3_7', 16); %16 means select=0&connect=2
   loadwav(handles.RP2_1,'1',which('RP2_1Out1.wav'));   
   loadwav(handles.RP2_1,'2',which('RP2_1Out2.wav'));   
   handles.RP2_2 = actxcontrol('RPco.x',[0 0 1 2],handles.fig);
   if (invoke(handles.RP2_2,'ConnectRP2',NelData.General.TDTcommMode,2) == 0)
     msgbox('can''t connect to RP2_2');
   end
   invoke(handles.RP2_2,'ClearCOF');
   invoke(handles.RP2_2,'LoadCof',which('wiring_test.rco'));
   invoke(handles.RP2_2, 'SetTagVal', 'BitOut3_7', 8);%8 means select=0&connect=1
   loadwav(handles.RP2_2,'1',which('RP2_2Out1.wav'));   
   loadwav(handles.RP2_2,'2',which('RP2_2Out2.wav'));   
   for i = 1:4
     handles.PA(i).h = actxcontrol('PA5.x',[0 0 1 1],handles.fig);
     if (invoke(handles.PA(i).h,'ConnectPA5',NelData.General.TDTcommMode,i) == 0)
       msgbox(['Failed to connect to PA #' int2str(i)]);       
     end
     invoke(handles.PA(i).h, 'SetAtten', 0); 
   end
   invoke(handles.RP2_1,'run');
   invoke(handles.RP2_2,'run');  
   handles.table = build_table;
   guidata(gcf, handles);
   return;
end
  
switch(command)
 case {'Left','Right'}
  % new mixing information is set
  handles = guidata(gcbf);
  weight = get(gcbo, 'UserData');
  change = sign( get(gcbo,'value')-0.5 ); % 1 for check, -1 for uncheck
  handles.mix = handles.mix + change*weight;
  bit3_7 = lookup_table(handles.table, handles.mix);
  if any(bit3_7<0)
    set(handles.error,'visible','on');
    bit3_7 = [7 7];
  else
    set(handles.error,'visible','off');
  end

  invoke(handles.RP2_1,'SetTagVal', 'BitOut3_7',bit3_7(1) );
  invoke(handles.RP2_2,'SetTagVal', 'BitOut3_7',bit3_7(2) );
  guidata(gcbf, handles);
 case 'delete'
  handles = guidata(gcbf);  
  invoke(handles.RP2_1, 'Halt');
  invoke(handles.RP2_2, 'Halt');
  delete(handles.RP2_1);
  delete(handles.RP2_2);
  for i = 1:4
     %invoke(handles.PA(i).h, 'SetAtten', 120); 
     delete(handles.PA(i).h);
  end
end
  

%************  END OF MAIN FUNCTION  ****************
function h = new_checkbox(fig, position, userdata, value, tag)
h = uicontrol(fig, ...
	      'style',          'checkbox', ...
	      'Units',          'normalized', ...
	      'position',       position,...
	      'UserData',       userdata, ...
	      'horizon',        'left', ...
	      'Value',          value, ...
	      'Tag',            tag, ...
	      'Callback',       ['wiring_test(''' tag ''');']);


function loadwav(RP2,out,wavfile)
% load wav file
[data,sr] = audioread(wavfile);   
ratio = round(double(invoke(RP2,'GetSFreq'))/sr);
invoke(RP2,'SetTagVal',['length' out],length(data));
invoke(RP2,'SetTagVal',['ratio' out],ratio);   
invoke(RP2,'WriteTagV', ['buff_data' out], 0, data(:)');



function table = build_table
select_L = [0 1 7 4 5];
select_L_stimuli = {[1 0 0 0], [1 1 0 0], [0 0 0 0], [0 0 1 0], [0 0 0 1]};
select_R = [0 1 7 4 5];
select_R_stimuli = {[0 0 1 0], [0 0 1 1], [0 0 0 0], [1 0 0 0], [0 1 0 0]};

connect_L = [0 2 1 3];
connect_L_se = {[0 0], [1 0], [0 1], [1 1]};
connect_R = [0 1 2 3];
connect_R_se = {[0 0], [0 1], [1 0], [1 1]};

table= - ones(2^8,2);

for i1 = 1:length(select_L)
    for i2 = 1:length(select_R)
        for j1 = 1:length(connect_L)
            for j2 = 1:length(connect_R)
                LE = connect_L_se{j1}*[select_L_stimuli{i1};select_R_stimuli{i2}];
                RE = connect_R_se{j2}*[select_L_stimuli{i1};select_R_stimuli{i2}];
                any_sel = any( [select_L_stimuli{i1};select_R_stimuli{i2}], 2);
                any_con = any( [connect_L_se{j1};connect_R_se{j2}] );
                if any(LE>1) | any(RE>1) | ~isequal(any_sel, any_con')
                    continue;
                end
                mix = LE*2.^[7 6 5 4]' + RE*2.^[3 2 1 0]';
                if table(mix+1,1) < 0
                    table(mix+1,:) = [select_L(i1)+connect_L(j1)*8,select_R(i2)+connect_R(j2)*8];
                end
            end
        end
    end
end


function bit3_7 = lookup_table(table, mix)
bit3_7 = table(mix+1,:);
