function z = JointGaussianModel_v01(x,y,param,c)
% z = JointGaussianModel(x,y,param)
% Make a joint gaussian model that represents a image of multiple
% fluorescent particles.
% 
% z: nx x ny intensity map
% XY: XY{1}: x and XY{2}: y coordinates
% param: (6*N+1)x1 array where N is the number of Gaussians and
%    param(1:N), param(N+1:2N) : x and y coordinates of the center of Gaussians,
%    repectively.
%    param(2N+1:3N), param(3N+1:4N) : std of Gaussian in x and y direction,
%    respectively
%    param(4N+1:5N) : N x 1 array, angle of long std axis
%    param(5N+1:6N) : N x 1 array, peak height of gaussian
%    param(6N+1) : background level

% constants
% c(1): resolution
% c(2): 1 if you want to couple sigx and sigy, 0 if not
% c(3): 1 if the array of all the possible combinations of x,y coordinates
% and the reformation matrix R are already constructed and stored 
% as a global variable and 0 otherwise.
% c(4): Ngauss, number of gaussian in the mixture model

if length(c) ~= 4
    error('Insufficient constant c');
end

resol = c(1);
Ngauss = c(4);  %number of gaussian features

if length(param) ~= 6*Ngauss+1
    error('The length of param should be 6*Ngauss+1');
end

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

h = param(5*Ngauss+1:6*Ngauss)/resol^2;  %peak height
SigX = reshape(param(2*Ngauss+1:4*Ngauss),[Ngauss,2]);
Xc = reshape(param(1:2*Ngauss),[Ngauss,2]);  %gaussian x,y center position
theta = param(4*Ngauss+1:5*Ngauss);

if c(2)==1
   SigX(:,2) = SigX(:,1); 
end

z = param(end)/resol^2*ones(ny,nx);


for i = 1:Ngauss
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
