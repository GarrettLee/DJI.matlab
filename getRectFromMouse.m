function [x, y, w, h  ] = getRectFromMouse(  )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
k = waitforbuttonpress;
point1 = get(gca,'CurrentPoint');    % button down detected
finalRect = rbbox;                   % return figure units
point2 = get(gca,'CurrentPoint');    % button up detected
point1 = point1(1,1:2);              % extract x and y
point2 = point2(1,1:2);
p1 = min(point1,point2);             % calculate locations
offset = abs(point1-point2);         % and dimensions
x1 = [p1(1) p1(1)+offset(1) p1(1)+offset(1) p1(1) p1(1)];
y1 = [p1(2) p1(2) p1(2)+offset(2) p1(2)+offset(2) p1(2)];
x = round(p1(1));
y = round(p1(2));
w = round(offset(1));
h = round(offset(2));
if(w == 0)||(h==0)
   fprintf('w,h,error');
end
hold on
axis manual

plot(x1,y1);

end

