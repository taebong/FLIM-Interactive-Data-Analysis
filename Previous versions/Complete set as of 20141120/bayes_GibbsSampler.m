function [pmean,psig,psampled] = bayes_GibbsSampler(decay_struct,dp,pmin,pmax,nexpo,fitvar,fit_start,fit_end,Nsample,Nburn)

%[pmean,psig,psampled] = bayes_GibbsSampler(decay_struct,dp,pmin,pmax,nexpo,fitvar,fit_start,fit_end)

psampled = FLIMGibbsSampler(decay_struct,dp,pmin,pmax,nexpo,fitvar,fit_start,fit_end,Nsample,Nburn);

pmean = mean(psampled,2);
psig = std(psampled,1,2);
