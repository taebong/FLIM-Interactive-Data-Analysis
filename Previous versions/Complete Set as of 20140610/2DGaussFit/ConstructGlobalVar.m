function ConstructGlobalVar(x,y,c)
GlobalVarTracking;

resol = c(1);
% 
% x = XY{1};
% y = XY{2};
dx = (x(2)-x(1))/resol;
dy = (y(2)-y(1))/resol;
% finer x position
xf = (x(1)-(resol/2-1)*dx):dx:x(end)+resol/2*dx;
yf = (y(1)-(resol/2-1)*dy):dy:y(end)+resol/2*dx;

%Xcoord = allcomb(xf,yf); %coordinates of points
[Xmatrix,Ymatrix] = meshgrid(xf,yf);

%Np = size(Xcoord,1); %number of all points
% 
nx = length(xf);
ny = length(yf);

%reform matrix
ind = (1:(nx*ny))';
Rmatrix = [ceil((mod(ind-1,ny)+1)/resol),ceil(ind/(ny*resol))];