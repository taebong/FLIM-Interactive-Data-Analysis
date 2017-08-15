function y = GaussianMixtureModel2D(A,mu,sig,rho,bg,X,Y,Nsubgrid)
%prob = GaussianMixtureModel(A,mu,Sig,size)
%
% A: Amplitudes of gaussian, Nx1 vector, where N is the number of gaussians
% mu: mean position of gaussian, Nx2 matrix. 
% sig: variance in each direction, Nx2 matrix
% rho: correlation parameter between x and y. Nx1 vector
% sizeimg: size of the image, [a,b]

% xlin = linspace(0,sizeimg(2),Nsubgrid*sizeimg(2))+0.5;
% ylin = linspace(0,sizeimg(1),Nsubgrid*sizeimg(1))+0.5;
% [X,Y] = meshgrid(xlin,ylin);

Ngauss = length(A);
A = A/Nsubgrid^2;

pp = zeros(size(X));
for i = 1:Ngauss
    gauss = A(i)*exp(-1/(2*(1-rho(i)^2))*((X-mu(i,1)).^2/sig(i,1)^2+(Y-mu(i,2)).^2/sig(i,2)^2)-2*rho(i)*(X-mu(i,1)).*(Y-mu(i,2))/(sig(i,1)*sig(i,2)));
    pp = pp + gauss;
end

y = downsamp2d(pp,[Nsubgrid,Nsubgrid]);
y = y + bg;