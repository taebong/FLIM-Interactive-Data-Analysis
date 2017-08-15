function mask = generateCircularMask(x,y,xc,yc,r)
mask = zeros(length(y),length(x));
Ncircle = length(xc);

[X,Y] = meshgrid(x,y);

for i = 1:Ncircle
    mask((X-xc(i)).^2+(Y-yc(i)).^2<=r(i)^2)=1;
end

