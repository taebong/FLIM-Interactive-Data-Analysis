function h = DrawCircle(xc,yc,radius,color)
% Making a circle the size of the feature around each feature.
% h = DrawCircle(xc,yc,radius)

if nargin < 4
   color = 'g'; 
end

if length(radius) == 1
   radius = ones(length(xc),1)*radius; 
end
theta = 0:0.25:(2*pi+0.25);
h = zeros(length(xc),1);
for i = 1:length(xc)
    x = xc(i) + radius(i)*cos(theta);
    y = yc(i) + radius(i)*sin(theta);
    h(i) = plot(x,y,'-','Color',color,'LineWidth',1.5);
end