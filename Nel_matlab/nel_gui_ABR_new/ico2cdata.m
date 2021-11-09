function [cdata, bgmat] = ico2cdata(ico_fname,bg_color)
%

% AF 11/17/01

global icon_dir
if (exist('bg_color') ~= 1)
   bg_color = get(0,'defaultUicontrolBackgroundColor');
end
   
[im,map,alpha] = imread([icon_dir ico_fname]);
cdata = zeros([size(im) 3]);
for i = 1:size(im,1)
   for j = 1:size(im,2)
      if (alpha(i,j))
         cdata(i,j,:) = bg_color;
      else
         cdata(i,j,:) = map(double(im(i,j))+1,:);
      end
   end
end
if (nargout > 1)
   col(1,1,:) = bg_color;
   bgmat = repmat(col,size(im));
end

