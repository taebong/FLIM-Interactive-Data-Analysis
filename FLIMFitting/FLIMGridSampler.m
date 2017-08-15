function [avg_p,sigma_p,p_vec,post,marg_post,mle] = FLIMGridSampler(decay_struct,printbool)


% [avg_p,sigma_p,p_vec,post,marg_post,mle] = FLIMGridSampler(decay_struct)
%
% Bayesian grid sampler to get posterior distribution
% ------ Fields in decay_struct -------
% time      = time vector
% data      = data vector, which has to be in the same dimension as time
% time_irf, irf = time and curve of IRF
% dp        = parameter step size when calculating likelihood function (has
%               to be row vector)
% pmin, pmax = parameter minimum, maximum value (row vectors)
% nexpo     = # of exponentials
% firvar  = indicator to choose the FLIM equation
% prior     = 1 if uniform between pmin and pmax, 2 if exponential
% fit_start, fit_end = these indexes specify the region where you want to fit
% refcurve = reference curve to correct ripples
%
% -------- OUTPUT VAR -------
% avg_p     = posterior mean of parameter
% sigma_p   = posteior standard deviation of paramter
% p         = parameter vectors (cell)
% post      = posterior distribution  size(post) = n;
% marg_post = marginal posterior distribution   marg_post = cell(Nparam)


% edited on 7/8/2013 to make it faster (crude search -> finer search)
% Optimized as of 8/6/13 (FFT convolution, circshift)
% Exponential prior is added 8/7/13
% MLE added, Error in posterior distribution calculation fixed 8/17/13
% Use parfor in calclikelihood, 8/26/13
% Modified on 8/6/2014: irf, time_irf are inputs, rather than loaded from a
% file.
% Modifed on 2/25/2015, input decay struct instead of many variables

if nargin <2
    printbool = 0;
end

time = decay_struct.time;
data = decay_struct.decay;
time_irf = decay_struct.time_irf;
irf = decay_struct.irf;
dp = decay_struct.fit_detail.dp;

nexpo = decay_struct.nexpo;
fitvar = decay_struct.fitvar;
fit_start = decay_struct.fit_region(1);
fit_end = decay_struct.fit_region(2);
laserT = decay_struct.laserT;
prior = decay_struct.fit_detail.prior;

%Number of parameters
Nparam = 2*nexpo+1;

if isfield(decay_struct,'refcurve')==0 || isempty(decay_struct.refcurve)
    refcurve = ones(length(irf),1);
else
    refcurve = decay_struct.refcurve;    
end

%paramter setting
fitsetting = decay_struct.fit_result;
pmin = fitsetting(1:Nparam,4);
pmax = fitsetting(1:Nparam,5);

% Parameters to fix
free= ~fitsetting(1:Nparam,3);
pmin(~free) = fitsetting(~free,1);
pmax(~free) = pmin(~free);


%size of each parameter variable
n = zeros(Nparam,1);


%parameter vector
p_vec = cell(Nparam,1);


for i = 1:Nparam
    p_vec{i} = pmin(i):dp(i):pmax(i);
    %number of entries in a param vector
    n(i) = length(p_vec{i});
end

%Number of subscripts sets
N_subs = prod(n);

%parameter sets and subscripts set that corresponds to each index
[pmat,subsc] = ParamMatrix(p_vec);

if printbool
    disp(['Bayes Grid Sampling Start, loop size = ' num2str(N_subs)])
    tstart = tic;
end

%log-likelihood function vector
lik_vec = calclikelihood(time,data,time_irf,irf,pmat,nexpo,fitvar,fit_start,fit_end,refcurve,laserT);

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

if printbool
    disp(['Bayes Grid Sampling done, elapsed time = ', num2str(toc(tstart)), 'sec']);
end

%posterior distribution (vectorized)
post_vec=lik_vec.*p_prior_vec;
%normalize posterior distribution (vectorized)
post_vec = post_vec/sum(post_vec(:));


%marginalize posterior distribution
marg_post = cell(Nparam,1);
avg_p = zeros(Nparam,1);
sigma_p = zeros(Nparam,1);

for i = 1:Nparam
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
