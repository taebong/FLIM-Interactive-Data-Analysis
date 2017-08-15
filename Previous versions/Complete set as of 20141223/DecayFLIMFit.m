function outputDecayStruct = DecayFLIMFit(inputDecayStruct,fitsetting,fitmethod,nexpo,fitvar,fitstart,fitend,noisefrom,noiseto,prior)

% outputDecayStruct = DecayFLIMFit(inputDecayStruct,fitsetting,fitmethod,nexpo,fitvar,fitstart,fitend,noisefrom,noiseto,prior)


if nargin < 10
    prior = 0;
end

time = inputDecayStruct.time;
dt = time(2)-time(1);

%IRF
irf = inputDecayStruct.irf;
time_irf = inputDecayStruct.time_irf;

% data to fit
decay = inputDecayStruct.decay;
counts = sum(decay(fitstart:fitend));

%weight on residual
%weight = (fitend-fitstart+1)/sqrt(decay(fitstart:fitend)'*decay(fitstart:fitend));
nonzeroDecay = decay;
nonzeroDecay(decay==0)=1;
sigy = sqrt(nonzeroDecay);
weight = 1./sigy(fitstart:fitend);

% rough estimate of noise in noise region
estNoise = mean(decay(noisefrom:noiseto));

Nparam = 2*nexpo+1;

% initial guess, lower and upper bounds of parameters
% P(t|param) (not normalized)
% if one expo:
% P = param(2)*exp(-t/param(3))+(1-param(2))
% param(2): fractional amp of expo decay
% param(3): lifetime of the first decay
%
% if two expo & fitvar = E:
% P = param(2)*param(4)*exp(-t/param(3))+param(2)*(1-param(4))*exp(-t/(param(3)*param(5)))+(1-param(2));
% param(4) : fraction of the first decay
% param(5) : ratio of tau2 to tau1
%
% if two expo & fitvar = tau2:
% P = param(2)*param(4)*exp(-t/param(3))+param(2)*(1-param(4))*exp(-t/param(3))+(1-param(2));
% param(4) : fraction of the first decay
% param(5) : lifetime of second decay
%
% param(1) : shift of decay model from IRF (usually ranges from -10 to 10)
pmin = fitsetting(1:Nparam,4);
pmax = fitsetting(1:Nparam,5);
pinit = (pmin+pmax)/2;
pinit(2) = 1-estNoise/max(decay);

% Parameters to fix
free= ~fitsetting(1:Nparam,3);

for i = find(free==0)
    pinit(i) = fitsetting(i,1);
    pmax(i) = pinit(i);
    pmin(i) = pinit(i);
end

pvec = [];
post = [];
margpost = [];
converged = [];
cvghst = [];

tic
if fitmethod == 1  %LS Fit
    dp = zeros(Nparam,1);
    dp(2:Nparam) = 0.001*free(2:Nparam);
    dp(1) = 1*free(1);

    [pfit,~,sigmap,~,~,~,cvghst,converged] = ...
        lm(@lm_decay_model,pinit,time,decay,time_irf,irf,weight,dp,pmin,pmax,[nexpo,counts,fitstart,fitend,fitvar],fitstart,fitend);
elseif fitmethod == 2  %Bayes fit (Gibbs Sampler)
    if nexpo == 1
        dp = [1,0.00025,0.01]';
    elseif nexpo == 2
        dp = [1,0.001,0.01,0.01,0.01]';
    else
        dp = [1,0.001,0.01,0.01,0.01,0.01,0.01]';
    end
    
    answer = inputdlg('Enter sample size','Gibbs Sampler Setting',1,{'1600'});
    if isempty(answer)
        return;
    end
    Nsample = round(str2double(answer{1}));
    Nburn = 100;
    
    %post is sampled parameters in this case
    [pfit,sigmap,post] = bayes_GibbsSampler(inputDecayStruct,dp,pmin,pmax,nexpo,fitvar,fitstart,fitend,Nsample,Nburn);
elseif fitmethod == 3  %Bayes fit (Grid)
    if nexpo == 1
        dp = [1,0.00025,0.01]';
    elseif nexpo == 2
        dp = [1,0.001,0.01,0.01,0.01]';
    else
        dp = [1,0.0025,0.02,0.02,0.02,0.02,0.02]';
    end
    [pfit,sigmap,pvec,post,margpost] = bayes_fit(time,decay,time_irf,irf,dp,pmin,pmax,nexpo,fitvar,prior,fitstart,fitend,0,0);
elseif fitmethod == 4 %Bayes fit (Metropolis-Hastings)
end
toc

% model
yhat = lm_decay_model(time,pfit,[nexpo,counts,fitstart,fitend,fitvar],time_irf,irf);
yhat = yhat(fitstart:fitend);

%returning decay structure
outputDecayStruct = inputDecayStruct;

outputDecayStruct.fit = yhat;

ydat = decay;
ydat = ydat(fitstart:fitend);

weighted_residual = weight.*(ydat-yhat);
outputDecayStruct.residual = zeros(size(decay));
outputDecayStruct.residual(fitstart:fitend) = weighted_residual;

Chisq = sum(weighted_residual.^2)/(fitend-fitstart-2*nexpo-1+sum(~free(1:(2*nexpo+1))));

fit_result = fitsetting;
fit_result(1:7,1:2) = zeros(7,2);
fit_result(1:(nexpo*2+1),1) = real(pfit);
fit_result(1:(nexpo*2+1),2) = real(sigmap);

outputDecayStruct.fit_result = fit_result;
outputDecayStruct.Chi_sq = Chisq;

outputDecayStruct.cvg_hst = cvghst;
outputDecayStruct.converged = converged;
outputDecayStruct.marg_post = margpost;
outputDecayStruct.post = post;
outputDecayStruct.p_vec = pvec;
    
outputDecayStruct.fit_region = [fitstart,fitend];
outputDecayStruct.noise_region = [noisefrom,noiseto];
outputDecayStruct.fitting_method = fitmethod;
outputDecayStruct.nexpo = nexpo;
outputDecayStruct.fitvar = fitvar;
outputDecayStruct.dp = dp;

