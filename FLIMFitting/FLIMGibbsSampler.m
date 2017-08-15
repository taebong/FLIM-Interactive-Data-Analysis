function [pmean,psig,psampled] = FLIMGibbsSampler(decay_struct,Nsample,Nburn)

% [pmean,psig,psampled] = FLIMGibbsSampler(decay_struct,Nsample,Nburn)

decay = decay_struct.decay;
time = decay_struct.time;
irf = decay_struct.irf;
time_irf = decay_struct.time_irf;

nexpo = decay_struct.nexpo;
fitvar = decay_struct.fitvar;
fit_start = decay_struct.fit_region(1);
fit_end = decay_struct.fit_region(2);
laserT = decay_struct.laserT;

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
dp = decay_struct.fit_detail.dp;

% Parameters to fix
free= ~fitsetting(1:Nparam,3);
pmin(~free) = fitsetting(~free,1);
pmax(~free) = pmin(~free);

%starting point
pstart = (pmin+pmax)/2;
pcurrent = pstart;

psampled = zeros(Nparam,Nsample);

n = 1;
while n <= Nsample+Nburn
    for i = 1:Nparam
        ptry = pmin(i):dp(i):pmax(i);
        param_mat = repmat(pcurrent,1,length(ptry));
        param_mat(i,:) = ptry;
        %conditional posterior on p_i
        condpost = calclikelihood(time,decay,time_irf,irf,param_mat,nexpo,fitvar,fit_start,fit_end,refcurve,laserT);
        
        %sample from the conditional posterior
        ind = randsample(length(ptry),1,true,condpost);
        pcurrent(i) = ptry(ind);
    end
    if n>Nburn
        psampled(:,n-Nburn) = pcurrent;
    end

    switch n
        case 1
            disp('Gibbs Sampling Started')
            disp('progress: 0%')
        case round((Nsample+Nburn)/5)
            disp('progress: 20%')
        case round(2*(Nsample+Nburn)/5)
            disp('progress: 40%')
        case round(3*(Nsample+Nburn)/5)
            disp('progress: 60%')
        case round(4*(Nsample+Nburn)/5)
            disp('progress: 80%')
        case round(5*(Nsample+Nburn)/5)
            disp('progress: 100%, fine search complete')
    end
    
    n = n+1;
end


pmean = mean(psampled,2);
psig = std(psampled,1,2);

