function [A,mu,sig,rho] = GaussianMixture2DMLE(image,A_init,mu_init,sig_init,rho_init)

sizeimg = size(image);

A_current = A_init;
mu_current = mu_init;
sig_current = sig_init;
rho_current = rho_init;
Ngauss = length(A_init);

maxiter = 10000;
iter = 1;
%standard deviation of normal proposal distribution
Asig0 = sqrt(A_init);
musig0 = 0.5;
sigsig0 = 0.5;
rhosig0 = 0.1;


while iter<maxiter
    prob = GaussianMixtureModel2D(A_current,mu_current,sig_current,rho_current,sizeimg);
    
    %assume Poisson photon generation, calculate likelihood
    probpix = prob.^image.*exp(-prob)./factorial(image);
    log_lik = sum(log(probpix(:)));
    
    %proposal state
    A_new = A_current+Asig0.*randn([Ngauss,1]);
    mu_new = mu_current+musig0*randn([Ngauss,2]);
    
    sig_new = zeros(Ngauss,2);
    rho_new = zeros(Ngauss,1); 
    for i = 1:Ngauss
        sig_new(i,1) = sampleTruncNorm(sig_current(i,1),sigsig0,[0,Inf],1);
        sig_new(i,2) = sampleTruncNorm(sig_current(i,2),sigsig0,[0,Inf],1);
        rho_new(i) = sampleTruncNorm(rho_current(i),rhosig0,[0,1],1);
    end
    
    %likelihood of proposed state
    prob_new = GaussianMixtureModel2D(A_new,mu_new,sig_new,rho_new,sizeimg);
    probpix_new = prob_new.^image.*exp(-prob_new)./factorial(image);
    log_lik_new = sum(log(probpix_new(:)));
    
    %probability ratio between the proposed state and the previous state
    a1 = exp(log_lik_new-log_lik);
    %jumping prob ratio
    a2 = calcJumpingProbRatio(sig_current,rho_current,sig_new,rho_new,sigsig0,rhosig0);
    
    a = a1*a2;
    
    if a >= 1
        A_current = A_new;
    
    iter = iter+1;
end


function ratio = calcJumpingProbRatio(sig,rho_current,sigp,rhop,sigsig0,rhosig0)
%jumping ratio is basically the ratio of the normalization constants of
%truncated normal dists. 

normconst_sig = 1-normcdf(0,sig_current,sigsig0);
normconst_sigp = 1-normcdf(0,sigp,sigsig0);
normconst_rho = 1-normcdf(0,rho_current,rhosig0);
normconst_rhop = 1-normcdf(0,rhop,rhosig0);

ratio = prod(normconst_sig(:))*prod(normconst_rho(:))*prod(normconst_sigp(:))*prod(normconst_rhop(:));

end
