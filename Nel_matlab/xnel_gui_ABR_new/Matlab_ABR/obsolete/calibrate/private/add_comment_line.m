function [comment]=add_comment_line(command_str)		%function to create comment line for single unit data file

if nargin < 1						
   command_str = 'initialize';
end

if ~strcmp(command_str,'initialize'),
   handles        = get(gcf,'userdata');	
   h_edit         = handles(1);
end


if strcmp(command_str,'initialize'),
   h_fig = figure('NumberTitle','off','Name','Comments','Units','normalized','position',[.23 .4 .5 .25]);
   h_frm = uicontrol(h_fig,'style','frame','position',[0 0 1 1]);
   h_edit        = uicontrol(h_fig,'style','edit','callback','add_comment_line(''reply'');','Units','normalized','position',[.1 .2 .8 .2],'userdata',[],'FontSize',14);								
	uicontrol(h_fig,'style','text','string','Enter text and hit return...','position',[.2 .8 .6 .1]);   
   
   handles = [h_edit];
   set(h_fig,'userdata',handles);
   
	while ~length(get(h_edit,'userdata')), drawnow; end %waiting for input
   
   comment = get(h_edit,'string');
   if length(comment)>60,
      comment = comment(1:60);
   end
   close('Comments');
   
elseif strcmp(command_str,'reply'),
   set(h_edit,'userdata',1);
end
