function outputDecayStruct = DecayFLIMFit(inputDecayStruct,fitmethod,nexpo,fitvar,fitstart,fitend,noisefrom,noiseto,prior,Nsample,Nburn,printbool)

% outputDecayStruct = DecayFLIMFit(inputDecayStruct,fitmethod,nexpo,fitvar,fitstart,fitend,noisefrom,noiseto,prior)

%update decay_struct
inputDecayStruct.fitting_method = fitmethod;
inputDecayStruct.nexpo = nexpo;
inputDecayStruct.fitvar = fitvar;
inputDecayStruct.fit_region = [fitstart,fitend];
inputDecayStruct.noise_region = [noisefrom,noiseto];

%get laser rep period
%default value (in ns)
if isfield(inputDecayStruct,'laserT') == 0
    if isfield(inputDecayStruct,'setting')
        setting = inputDecayStruct.setting;
        if isfield(inputDecayStruct,'flimblock')
            flimblock = inputDecayStruct.flimblock;
        else
            flimblock = 2;
        end
        measdesc = bh_getmeasdesc(setting,flimblock);
        inputDecayStruct.laserT = mean([1/measdesc.min_sync_rate,1/measdesc.max_sync_rate])*10^9;
    else
        inputDecayStruct.laserT = 12.5; %default
    end
end
laserT = inputDecayStruct.laserT;

if nargin < 9
    prior = 0;
end
if nargin <12
    printbool = 0;
end

time = inputDecayStruct.time;

%IRF
irf = inputDecayStruct.irf;
time_irf = inputDecayStruct.time_irf;

% data to fit
decay = inputDecayStruct.decay;
counts = sum(decay(fitstart:fitend));

Nparam = 2*nexpo+1;

%paramter setting
fitsetting = inputDecayStruct.fit_result;
% Parameters to fix
free= ~fitsetting(1:Nparam,3);
inputDecayStruct.fit_detail = struct;

if printbool
    tic
end
if fitmethod == 1  %LS Fit
   
    dp = zeros(Nparam,1);
    dp(2:Nparam) = 0.001*free(2:Nparam);
    dp(1) = 1*free(1);
    
    inputDecayStruct.fit_detail.dp = dp;

    [pfit,~,sigmap,~,~,~,cvg_hst,converged] = lmFLIM(inputDecayStruct);
    inputDecayStruct.fit_detail.cvg_hst = cvg_hst;
    inputDecayStruct.fit_detail.converged = converged;
    
elseif fitmethod == 2  %Bayes fit (Gibbs Sampler)
    if nexpo == 1
        dp = [1,0.00025,0.01]';
    elseif nexpo == 2
        dp = [1,0.001,0.01,0.01,0.01]';
    else
        dp = [1,0.001,0.01,0.01,0.01,0.01,0.01]';
    end
    
    inputDecayStruct.fit_detail.dp = dp;
    inputDecayStruct.fit_detail.Nsample = Nsample;
    inputDecayStruct.fit_detail.Nburn = Nburn;
    
    %post is sampled parameters in this case
    [pfit,sigmap,post] = FLIMGibbsSampler(inputDecayStruct,Nsample,Nburn);
    
    inputDecayStruct.fit_detail.post = post;
elseif fitmethod == 3  %Bayes fit (Grid)
    if nexpo == 1
        dp = [1,0.00025,0.01]';
    elseif nexpo == 2
        dp = [1,0.001,0.01,0.01,0.01]';
        %dp = [1,0.001,0.01,0.02,0.01]';
    else
        dp = [1,0.0025,0.02,0.02,0.02,0.02,0.02]';
    end
    
    inputDecayStruct.fit_detail.prior = prior;
    inputDecayStruct.fit_detail.dp = dp;
    [pfit,sigmap,p_vec,post,marg_post] = FLIMGridSampler(inputDecayStruct,printbool);
    
    inputDecayStruct.fit_detail.marg_post = marg_post;
    inputDecayStruct.fit_detail.p_vec = p_vec;
    inputDecayStruct.fit_detail.post = post;
    
elseif fitmethod == 4 %Bayes fit (Metropolis-Hastings)
    [pfit,sigmap,post] = FLIMMHSampler(inputDecayStruct,Nsample,Nburn);
    
    inputDecayStruct.fit_detail.post = post;
end

if printbool
    toc
end
    
% model
if isfield(inputDecayStruct,'refcurve')==0 || isempty(inputDecayStruct.refcurve)
    refcurve = ones(length(irf),1);
else
    refcurve = inputDecayStruct.refcurve;    
end

yhat = lm_decay_model(time,pfit,[nexpo,counts,fitstart,fitend,fitvar,laserT],time_irf,irf,refcurve);
yhat = yhat(fitstart:fitend);

%returning decay structure
outputDecayStruct = inputDecayStruct;

outputDecayStruct.fit = yhat;

ydat = decay;
ydat = ydat(fitstart:fitend);

%weight on residual
%weight = (fitend-fitstart+1)/sqrt(decay(fitstart:fitend)'*decay(fitstart:fitend));
nonzeroDecay = decay;
nonzeroDecay(decay==0)=1;
sigy = sqrt(nonzeroDecay);
weight = 1./sigy(fitstart:fitend);

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

