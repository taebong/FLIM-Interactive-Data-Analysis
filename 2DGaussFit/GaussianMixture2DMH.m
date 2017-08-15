function [A,mu,sig,rho,bg] = GaussianMixture2DMH(image,A_init,mu_init,sig_init,rho_init,bg_init,X,Y,Nsubgrid)

sizeimg = size(image);

A_current = A_init;
mu_current = mu_init;
sig_current = sig_init;
rho_current = rho_init;
bg_current = bg_init;
Ngauss = length(A_init);

maxiter = 10000;
burn = 100;
iter = 1;
%standard deviation of normal proposal distribution
Asig0 = sqrt(A_init);
musig0 = 0.1;
sigsig0 = 0.2;
rhosig0 = 0.05;
bgsig0 = 0.3;

A = cell(maxiter,1);
mu = cell(maxiter,1);
sig = cell(maxiter,1);
rho = cell(maxiter,1);
bg = cell(maxiter,1);

tic
while iter<=maxiter+burn
    prob = GaussianMixtureModel2D(A_current,mu_current,sig_current,rho_current,bg_current,X,Y,Nsubgrid);
    
    %assume Poisson photon generation, calculate likelihood
    probpix = prob.^image.*exp(-prob)./factorial(image);
    log_lik = sum(log(probpix(:)));
    
    %proposal state
    A_new = A_current+Asig0.*randn([Ngauss,1]);
    mu_new = mu_current+musig0*randn([Ngauss,2]);
    bg_new = bg_current+bgsig0*randn;
    
    sig_new = zeros(Ngauss,2);
    rho_new = zeros(Ngauss,1);
    for i = 1:Ngauss
        sig_new(i,1) = sampleTruncNorm(sig_current(i,1),sigsig0,[0,Inf],1);
        sig_new(i,2) = sampleTruncNorm(sig_current(i,2),sigsig0,[0,Inf],1);
        rho_new(i) = sampleTruncNorm(rho_current(i),rhosig0,[0,1],1);
    end
    
    %likelihood of proposed state
    prob_new = GaussianMixtureModel2D(A_new,mu_new,sig_new,rho_new,bg_new,X,Y,Nsubgrid);
    probpix_new = prob_new.^image.*exp(-prob_new)./factorial(image);
    log_lik_new = sum(log(probpix_new(:)));
    
    %probability ratio between the proposed state and the previous state
    a1 = exp(log_lik_new-log_lik);
    %jumping prob ratio
    a2 = calcJumpingProbRatio(sig_current,rho_current,sig_new,rho_new,sigsig0,rhosig0);
    
    a = a1*a2;
    
    if iter>burn
        A{iter-burn} = A_current;
        mu{iter-burn} = mu_current;
        sig{iter-burn} = sig_current;
        rho{iter-burn} = rho_current;
        bg{iter-burn} = bg_current;
    end
    
    accept = 0;
    if a >= 1
        accept = 1;
    else
        u = rand;
        if u<a
            accept = 1;
        end
    end
    if accept
        A_current = A_new;
        mu_current = mu_new;
        sig_current = sig_new;
        rho_current = rho_new;
        bg_current = bg_new;
    end
    
    iter = iter+1;
    
    if iter>=(burn+maxiter)/5 & iter<(burn+maxiter)/5+1
        disp('20% done');
    elseif iter>=(burn+maxiter)*2/5 & iter<(burn+maxiter)*2/5+1
        disp('40% done');
    elseif iter>=(burn+maxiter)*3/5 & iter<(burn+maxiter)*3/5+1
        disp('60% done');
    elseif iter>=(burn+maxiter)*4/5 & iter<(burn+maxiter)*4/5+1
        disp('80% done');
    elseif iter>=(burn+maxiter)*5/5 & iter<(burn+maxiter)*5/5+1
        disp('100% done');
    end
end
toc

end


function ratio = calcJumpingProbRatio(sig,rho,sigp,rhop,sigsig0,rhosig0)
%jumping ratio is basically the ratio of the normalization constants of
%truncated normal dists.

normconst_sig = 1-normcdf(0,sig,sigsig0);
normconst_sigp = 1-normcdf(0,sigp,sigsig0);
normconst_rho = 1-normcdf(0,rho,rhosig0);
normconst_rhop = 1-normcdf(0,rhop,rhosig0);

ratio = prod(normconst_sig(:))*prod(normconst_rho(:))*prod(normconst_sigp(:))*prod(normconst_rhop(:));

end
