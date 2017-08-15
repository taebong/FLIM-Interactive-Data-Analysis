function [avg_p,sigma_p,p_vec,post,marg_post] = bayes_fit(model,time,data,dp,p_min,p_max,nexpo,prior,fit_start,fit_end)

% [avg_p,X2,sigma_p,p,post] = bayes_fit(model,time,data,dp,p_min,p_max,consts,prior,fit_start,fit_end)
%
% Bayesian analysis to get posterior distribution
% ------ INPUT VAR -------
% model     = will be bayes_decay_model, which is a function of time,
%           parameter, nexpo 
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


% Threshold, if likelihood function is above this do fine search
% e.g. if thres = 0.01, neighborhood of points where lik/max(lik)>0.01 
% is subject to fine search
thres = 10^-3;

% step size ratio of crude to fine search
step_r = 5;

% want to skip crude search?
skip_crude = 1;


%load irf
loaded_irf = load('currentIRF.mat');
irf = loaded_irf.decay;
time_irf = loaded_irf.time;

if nargin < 9, fit_start = 1; end
if nargin < 10, fit_end = length(data); end

t = time(fit_start:fit_end);
y_dat = data(fit_start:fit_end);

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


if skip_crude == 0
    %% crude search
    %size of each parameter variable
    n_c = zeros(N_param,1);
    %parameter vector
    p_c_vec = cell(N_param,1);
    
    % crude searching step size;
    dp_c = dp*step_r;
    
    for i = 1:N_param
        p_c_vec{i} = p_min(i):dp_c(i):p_max(i);
        %number of entries in a param vector
        n_c(i) = length(p_c_vec{i});
    end
    
    %Number of subscripts sets
    N_subs_c = prod(n_c);
    
    %parameter sets and subscripts set that corresponds to each index
    [p_c,subs_c] = ParamMatrix(p_c_vec);
    
    
    disp(['crude search start, loop size = ' num2str(N_subs_c)])
    %log-likelihood function vector
    llik_vec_c = zeros(N_subs_c,1);
    
    for i = 1:N_subs_c
        %model distribution (use bayes_decay_model)
        p_model = feval(model,time,p_c(:,i),nexpo,irf,time_irf);
        p_model = p_model(fit_start:fit_end);
        %model normalization (max to total counts)
        p_model = p_model/sum(p_model)*sum(y_dat);
        
        %likelihood function calculation
        %vectorized N-param-dimensional likelihood function
        llik_vec_c(i) = sum((y_dat).*log(p_model));
        
        switch i
            case 1
                disp('progress: 0%')
            case round(N_subs_c/5)
                disp('progress: 20%')
            case round(2*N_subs_c/5)
                disp('progress: 40%')
            case round(3*N_subs_c/5)
                disp('progress: 60%')
            case round(4*N_subs_c/5)
                disp('progress: 80%')
            case round(5*N_subs_c/5)
                disp('progress: 100%, crude search complete')
        end
    end
    
    lik_vec_c = exp(llik_vec_c-max(llik_vec_c));
    % set the max to 1
    lik_vec_c = lik_vec_c/max(lik_vec_c);
    
    %parameter sets subject to fine search
    p_c_thres = p_c(:,lik_vec_c>thres);
    p_c_thres_min = min(p_c_thres,[],2);
    p_c_thres_max = max(p_c_thres,[],2);

else
    llik_vec_c = [];
    subs_c = [];
    N_subs_c = 0;
    p_c = [];
    
end


%% fine search 
%size of each parameter variable
n_f = zeros(N_param,1);

% fine searching step size;
dp_f = dp;

%parameter vector
p_f_vec = cell(N_param,1);

% fine searching region
if skip_crude
    p_f_max = p_max;
    p_f_min = p_min;
else
    p_f_max = min([p_max,p_c_thres_max+dp_c],[],2);
    p_f_min = max([p_min,p_c_thres_min-dp_c],[],2);
end
    
for i = 1:N_param
%     if p_c_thres_min(i) == p_c_thres_max(i)
%         p_f_vec{i} = p_c_thres(i);
%     else
%         p_f_vec{i} = p_f_min(i):dp_f(i):p_f_max(i);
%         p_f_vec{i} = setdiff(p_f_vec{i},p_c_vec{i});
%     end
    p_f_vec{i} = p_f_min(i):dp_f(i):p_f_max(i);
    %number of entries in a param vector
    n_f(i) = length(p_f_vec{i});
end

%Number of subscripts sets
N_subs_f = prod(n_f);

%parameter sets and subscripts set that corresponds to each index
[p_f,subs_f] = ParamMatrix(p_f_vec);


disp(['fine search start, loop size = ' num2str(N_subs_f)])
%log-likelihood function vector
llik_vec_f = zeros(N_subs_f,1);
tic
for i = 1:N_subs_f
    %model distribution (use bayes_decay_model)
    p_model = feval(model,time,p_f(:,i),nexpo,irf,time_irf);
%    p_model = bayes_decay_model(time,p_f(:,i),nexpo,irf,time_irf);
    p_model = p_model(fit_start:fit_end);
    %model normalization (max to total counts) 
    p_model = p_model/sum(p_model)*sum(y_dat);
    
    %likelihood function calculation
    %vectorized N-param-dimensional likelihood function
    llik_vec_f(i) = sum((y_dat).*log(p_model));
    
    switch i
        case 1
            disp('progress: 0%')
        case round(N_subs_f/5)
            disp('progress: 20%')
        case round(2*N_subs_f/5)
            disp('progress: 40%')
        case round(3*N_subs_f/5)
            disp('progress: 60%')
        case round(4*N_subs_f/5)
            disp('progress: 80%')
        case round(5*N_subs_f/5)
            disp('progress: 100%, fine search complete')
    end
end
toc


% %% Integrate crude and fine search results
% llik_vec = [llik_vec_c;llik_vec_f];
% subsc = [subs_c,subs_f+repmat(max(subs_c,[],2),1,N_subs_f)]; 
% N_subs = N_subs_c + N_subs_f;
% p = [p_c,p_f];
% p_vec = cell(N_param,1);
% 
% %unique and sort
% IU = cell(N_param,1);
% IP = cell(N_param,1);
% 
% n = zeros(N_param,1);
% for i = 1:N_param
%     p_vec{i} = [p_c_vec{i},p_f_vec{i}];
%     [p_vec{i},IU{i},IP{i}] = unique(p_vec{i});
%     subsc(i,:) = IP{i}(subsc(i,:));
%     n(i) = length(p_vec{i});
% end

llik_vec = llik_vec_f;
subsc = subs_f;
N_subs = N_subs_f;
p = p_f;
p_vec = p_f_vec;
n = n_f;
    
lik_vec = exp(llik_vec-max(llik_vec));


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

