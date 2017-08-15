function [mux,muy,sigx,sigy,theta,A,bg,converged] = GaussianMixture2DLMMLE(image,x,y,mux_init,muy_init,sigx_init,sigy_init,theta_init,A_init,bg_init,c,mask)

if nargin < 12
    mask = ones(size(image));
end

image = image.*mask;

Ngauss = length(mux_init);

sizeimg = size(image);

pinit = [mux_init(:);muy_init(:);sigx_init(:);sigy_init;theta_init(:);A_init(:);bg_init];

option = optimset('Display','final','TolX',5E-3,'TolFun',1E-3);
[pfit,fval,converged] = fminsearch(@(p) -JointGaussianPoissonLikelihood(x,y,p,c,image,mask),pinit,option);

bg = pfit(end);
pfit(end) = [];
pfit = reshape(pfit,[Ngauss,6]);

mux = pfit(:,1);
muy = pfit(:,2);
sigx = pfit(:,3);
sigy = pfit(:,4);
theta = pfit(:,5);
A = pfit(:,6);



function loglik = JointGaussianPoissonLikelihood(x,y,param,c,image,mask)
z = JointGaussianModel_v01(x,y,param,c);
z = z.*mask;
probpix = z.^image.*exp(-z)./factorial(image);
loglik = sum(log(probpix(:)));
%exponential prior distribution on ellipticity 
lambda = 0.5;
ra = max(param(3),param(4));
rb = min(param(3),param(4));
ellip = sqrt(ra^2-rb^2)/ra;
logprior = -ellip/lambda;
loglik = loglik+logprior;