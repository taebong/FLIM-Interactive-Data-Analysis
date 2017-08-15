function psampled = FLIMGibbsSampler(decay_struct,dp,pmin,pmax,nexpo,fitvar,fit_start,fit_end,Nsample,Nburn)

%psampled = FLIMGibbsSampler(decay_struct,dp,pmin,pmax,nexpo,fitvar,fit_start,fit_end,Nsample,Nburn)

decay = decay_struct.decay;
time = decay_struct.time;
irf = decay_struct.irf;
time_irf = decay_struct.time_irf;

%starting point
pstart = (pmin+pmax)/2;
pcurrent = pstart;

Nparam = 2*nexpo+1;
psampled = zeros(Nparam,Nsample);

n = 1;
while n <= Nsample+Nburn
    for i = 1:Nparam
        ptry = pmin(i):dp(i):pmax(i);
        param_mat = repmat(pcurrent,1,length(ptry));
        param_mat(i,:) = ptry;
        %conditional posterior on p_i
        condpost = calclikelihood(time,decay,time_irf,irf,param_mat,nexpo,fitvar,fit_start,fit_end,0,0);
        
        %sample from the conditional posterior
        ind = randsample(length(ptry),1,true,condpost);
        pcurrent(i) = ptry(ind);
    end
    if n>Nburn
        psampled(:,n-Nburn) = pcurrent;
    end
    n = n+1;

    switch n
        case 1
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
end
