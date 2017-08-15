function [avg_p,sigma_p,p_vec,post,marg_post,mle] = bayes_fit(time,data,time_irf,irf,dp,p_min,p_max,nexpo,fitvar,prior,fit_start,fit_end,alpha,parallel)


% [avg_p,sigma_p,p_vec,post,marg_post,mle] = bayes_fit(time,data,time_irf,irf,dp,p_min,p_max,nexpo,fitvar,prior,fit_start,fit_end,alpha,parallel)
%
% Bayesian analysis to get posterior distribution
% ------ INPUT VAR -------
% time      = time vector
% data      = data vector, which has to be in the same dimension as time
% dp        = parameter step size when calculating likelihood function (has
%               to be row vector)
% p_min, p_max = parameter minimum, maximum value (row vectors)
% nexpo     = # of exponentials
% prior     = 1 if uniform between p_min and p_max
% fit_start, fit_end = these indexes specify the region where you want to fit
% parallel  = whether or not you want to use parallel computing
%
% -------- OUTPUT VAR -------
% avg_p     = posterior mean of parameter
% sigma_p   = posteior standard deviation of paramter
% p         = parameter vectors (cell)
% post      = posterior distribution  size(post) = n;
% marg_post = marginal posterior distribution   marg_post = cell(N_param)


% edited on 7/8/2013 to make it faster (crude search -> finer search)
% Optimized as of 8/6/13 (FFT convolution, circshift)
% Exponential prior is added 8/7/13
% MLE added, Error in posterior distribution calculation fixed 8/17/13
% Use parfor in calclikelihood, 8/26/13
% Modified on 8/6/2014: irf, time_irf are inputs, rather than loaded from a
% file.

if nargin < 13
    alpha = 0;
end
if nargin < 14
    parallel = 0;
end

irf = double(irf);

%Number of parameters
N_param = 2*nexpo+1;

%size of each parameter variable
n = zeros(N_param,1);


%parameter vector
p_vec = cell(N_param,1);


for i = 1:N_param
    p_vec{i} = p_min(i):dp(i):p_max(i);
    %number of entries in a param vector
    n(i) = length(p_vec{i});
end

%Number of subscripts sets
N_subs = prod(n);

%parameter sets and subscripts set that corresponds to each index
[pmat,subsc] = ParamMatrix(p_vec);

disp(['fine search start, loop size = ' num2str(N_subs)])

%log-likelihood function vector
lik_vec = calclikelihood(time,data,time_irf,irf,pmat,nexpo,fitvar,fit_start,fit_end,parallel);

switch prior
    case 1
        %uniform prior (vectorized)
        p_prior_vec = ones(size(lik_vec));
    case 2
        %exponential prior on first lifetime parameter (param(3))
        %hyperparameter (=approximate lifetime)  
        tau1vec = p_vec{3}(subsc(3,:));
        tau1vec = tau1vec';
        p_prior_vec = 1/alpha*exp(-tau1vec/alpha);
    case 3
        % alpha is a vector in the same length as fluorescence fraction
        % parameter (param(2), a);
        p_prior_vec = alpha(subsc(2,:));
end

%posterior distribution (vectorized)
post_vec=lik_vec.*p_prior_vec;
%normalize posterior distribution (vectorized)
post_vec = post_vec/sum(post_vec(:));


%marginalize posterior distribution
marg_post = cell(N_param,1);
avg_p = zeros(N_param,1);
sigma_p = zeros(N_param,1);

for i = 1:N_param
    marg_post{i} = zeros(n(i),1);
    for j = 1:n(i)
        idx = (subsc(i,:)==j);
        marg_post{i}(j) = sum(post_vec(idx'));
    end
    marg_post{i} = marg_post{i}/sum(marg_post{i});
    avg_p(i) = sum(marg_post{i}.*p_vec{i}');
    %posterior standard deviation of parameter
    sigma_p(i) = sqrt(sum(marg_post{i}.*(p_vec{i}'.^2))-avg_p(i)^2);
end

[m,ind] = max(post_vec);
mle = pmat(:,ind);

post = zeros(n');
if nexpo == 1
    for i = 1:N_subs
        post(subsc(1,i),subsc(2,i),subsc(3,i)) = post_vec(i);
    end
elseif nexpo == 2
    for i = 1:N_subs
        post(subsc(1,i),subsc(2,i),subsc(3,i),subsc(4,i),subsc(5,i)) = post_vec(i);
    end
elseif nexpo == 3
    for i = 1:N_subs
        post(subsc(1,i),subsc(2,i),subsc(3,i),subsc(4,i),subsc(5,i),subsc(6,i),subsc(7,i)) = post_vec(i);
    end
end
