
function Lt = FillEdgeHoles(Lt)
% If edges of an ISOLATED mask are touching the boundary, connect the edges
% and fill holes

xdim = size(Lt,2);
ydim = size(Lt,1);
[y,x] = find(Lt);
% Left edge
if length(find(x==1))>1
    Left = find(x==1); yLeft = y(Left);
    LeftUp = find(yLeft==min(yLeft));
    LeftDown = find(yLeft==max(yLeft));
    Lt(yLeft(LeftUp):yLeft(LeftDown),1) = 1;
end
% Right edge
if length(find(x==xdim))>1
    Right = find(x==xdim); yRight = y(Right);
    RightUp = find(yRight==min(yRight));
    RightDown = find(yRight==max(yRight));
    Lt(yRight(RightUp):yRight(RightDown),xdim) = 1;
end
% Up edge
if length(find(y==1))>1
    Up = find(y==1); xUp = x(Up);
    UpLeft = find(xUp==min(xUp));
    UpRight = find(xUp==max(xUp));
    Lt(1,xUp(UpLeft):xUp(UpRight)) = 1;
end
% Down edge
if length(find(y==ydim))>1
    Down = find(y==ydim); xDown = x(Down);
    DownLeft = find(xDown==min(xDown));
    DownRight = find(xDown==max(xDown));
    Lt(ydim,xDown(DownLeft):xDown(DownRight)) = 1;
end

Lt = imfill(Lt,'holes');

