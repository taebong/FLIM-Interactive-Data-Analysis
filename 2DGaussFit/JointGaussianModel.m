function z = JointGaussianModel(x,y,param,c)
% z = JointGaussianModel(x,y,param)
% Make a joint gaussian model that represents a image of multiple
% fluorescent particles.
% 
% z: nx x ny intensity map
% XY: XY{1}: x and XY{2}: y coordinates
% param: N x 7 array where N is the number of Gaussians and
%    param(:,1), param(:,2) : x and y coordinates of the center of Gaussians,
%    repectively. x, y are N x 1 arrays
%    param(:,3), param(:,4) : std of Gaussian in x and y direction,
%    respectively
%    param(:,5) : N x 1 array, angle of long std axis
%    param(:,6) : N x 1 array, peak height of gaussian
%    param(:,7) : background level

% constants
% c(1): resolution
% c(2): 1 if you want to couple sigx and sigy, 0 if not
% c(3): 1 if the array of all the possible combinations of x,y coordinates
% and the reformation matrix R are already constructed and stored 
% as a global variable and 0 otherwise.


if size(param,2) ~= 7;
    param = reshape(param,[],7);
end
    
resol = c(1);

N = length(param(:,1));  %number of gaussian features
% 
% x = XY{1};
% y = XY{2};
dx = (x(2)-x(1))/resol;
dy = (y(2)-y(1))/resol;
% finer x position
xf = (x(1)-(resol/2-1)*dx):dx:x(end)+resol/2*dx;
yf = (y(1)-(resol/2-1)*dy):dy:y(end)+resol/2*dx;

nx = length(xf);
ny = length(yf);

if c(3)==0
    Xcoord = allcomb(xf,yf); %coordinates of points
    Np = size(Xcoord,1); %number of all points
    %reform matrix
    ind = (1:Np)';
    Rmatrix = [ceil((mod(ind-1,ny)+1)/resol),ceil(ind/(ny*resol))];
else
    GlobalVarTracking;
%    Np = size(Xcoord,1); %number of all points
end

h = param(:,6)/resol^2;  %peak height
SigX = param(:,3:4);
Xc = param(:,1:2);  %gaussian x,y center position
theta = param(:,5);

if c(2)==1
   SigX(:,2) = SigX(:,1); 
end

z = param(1,7)/resol^2*ones(ny,nx);


for i = 1:N
    if theta(i)~=0
        %rotation matrix
        %        M = [cos(theta(i)),sin(theta(i));-sin(theta(i)),cos(theta(i))];
        %rotated coordinate
        %        Xr = [Xcoord(:,1)-Xc(i,1),Xcoord(:,2)-Xc(i,2)]*M;

        Xrmat = (Xmatrix-Xc(i,1))*cos(theta(i))-(Ymatrix-Xc(i,2))*sin(theta(i));
        Yrmat = (Xmatrix-Xc(i,1))*sin(theta(i))+(Ymatrix-Xc(i,2))*cos(theta(i));
    else
        Xrmat = Xmatrix-Xc(i,1);
        Yrmat = Ymatrix-Xc(i,2);
    end        
    
    %repmat is too slow!
    z_i = h(i)*exp(-1/2*(Xrmat.^2/SigX(i,1)^2+Yrmat.^2/SigX(i,2)^2));
%     size(z_i)
%     size(z)
    
    z = z+z_i;
end

z = z(:);
z = accumarray(Rmatrix,z);
% xedge = [x-0.4,max(x)+0.6];
% yedge = [y-0.4,max(y)+0.6];
% z = bindata2(z,xf',yf',xedge',yedge');

% 
% [X,Y] = meshgrid(xf,yf);
% 

% 

% reshapedz = zeros(length(y),length(x),resol^2);
% idx = 1:length(x);
% idy = 1:length(y);
% idresol = 1:resol;
% 
% tempz = zeros(length(y),length(x));
% for i = 1:resol
%     for j = 1:resol
%         tempz = tempz + z(resol(
%     end
% end
% reshapedz = z(resol*(idy-1),resol*(id);
% z = sum(reshapedz,3);
% 
