function [avg_p,sigma_p,p_vec,post,marg_post] = bayes_fit(time,data,dp,p_min,p_max,nexpo,prior,fit_start,fit_end)

% Optimized as of 8/6/13

% [avg_p,X2,sigma_p,p,post] = bayes_fit(model,time,data,dp,p_min,p_max,consts,prior,fit_start,fit_end)
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
%
% -------- OUTPUT VAR -------
% avg_p     = posterior mean of parameter
% sigma_p   = posteior standard deviation of paramter
% p         = parameter vectors (cell)
% post      = posterior distribution  size(post) = n;
% marg_post = marginal posterior distribution   marg_post = cell(N_param)

% edited on 7/8/2013 to make it faster (crude search -> finer search)





%load irf
loaded_irf = load('currentIRF.mat');
irf = loaded_irf.decay;
time_irf = loaded_irf.time;


%Number of parameters
if nexpo ==1
    N_param = 3;
elseif nexpo ==2
    N_param = 5;
else
    %return error
    avg_p = -999;
    return
end

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

savepmat = pmat(:);
dlmwrite('paramfile.txt',savepmat',',');

disp(['fine search start, loop size = ' num2str(N_subs)])
%log-likelihood function vector


tic

lik_vec = calclikelihood(time,data,time_irf,irf,pmat,nexpo,fit_start,fit_end);

toc


switch prior
    case 1
        %uniform prior (vectorized)
        p_prior_vec = ones(size(lik_vec));
    case 2
        %exponential prior on lifetime parameters
        %hyperparameter 
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

post = zeros(n');
for i = 1:N_subs
    post(subsc(i)') = post_vec(i);
end

