function psampled = FLIMMHSampler(decay_struct,pmin,pmax,nexpo,fitvar,fit_start,fit_end,Nsample)

decay = decay_struct.decay;
time = decay_struct.time;
irf = decay_struct.irf;
time_irf = decay_struct.time_irf;

Nparam = 2*nexpo+1;
psampled = zeros(Nparam,Nsample);

counts = sum(decay(fit_start:fit_end));

%estimate the size of jumping
free = (pmin<pmax);
dp = zeros(Nparam,1);
scalefactor = sqrt(70000)/sqrt(counts)*3/sqrt(sum(free));
dp(1) = 1;
dp(2) = 0.002*scalefactor;
dp(3) = 0.1*scalefactor;
dp(4) = 0.025*scalefactor;
dp(5) = 0.05*scalefactor;

dp(~free) = 0;

%starting point
pstart = (pmin+pmax)/2;
pstart(1) = round(pstart(1));
pcurrent = pstart;

Nburn = 100;

n = 1;
iter = 1;
while n<=Nsample+Nburn
    %proposed point
    ptry = ptrySampler(pcurrent,dp,pmin,pmax,Nparam);
    
    alpha = calcAlpha(time,decay,time_irf,irf,pcurrent,ptry,pmin,pmax,dp,nexpo,fitvar,fit_start,fit_end);
    
    u = rand(1);
    
    if u<=alpha
        pcurrent = ptry;
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
    iter = iter+1;
end

iter

end


function alpha = calcAlpha(time,data,time_irf,irf,pcurrent,ptry,pmin,pmax,dp,nexpo,fitvar,fit_start,fit_end)
param_mat = [pcurrent,ptry];
lik = calclikelihood(time,data,time_irf,irf,param_mat,nexpo,fitvar,fit_start,fit_end,0,0);
%Since the proposal distribution is a truncated gaussian, jumping is
%asymetric.
%jumping_ratio = Jt(pcurrent|ptry)/Jt(ptry|pcurrent)
jumping_ratio = calcJumpingRatio(pcurrent,ptry,dp,pmin,pmax);
alpha = lik(2)/lik(1)*jumping_ratio;
alpha = min(1,alpha);
end

function jumping_ratio = calcJumpingRatio(pcurrent,ptry,dp,pmin,pmax)
%Jt(pcurrent|ptry)/Jt(ptry|pcurrent) = ratio of normalization constant of
%truncated normal distributions centered at pcurrent to that at ptry
jumping_ratio = 1;

free = (pmin<pmax);

if free(1)
    shift = round(pmin(1))-2:round(pmax(1))+2;
    ShiftProb = zeros(length(shift),1);
    %shift jumping distributuion centered at current shift
    ShiftProb_pcurrent(shift>=pcurrent(1)-2 & shift<=pcurrent(1)+2) = ...
        [0.05,0.2,0.5,0.2,0.05];
    ShiftProb_pcurrent = ShiftProb_pcurrent(shift>=pmin(1) & shift<=pmax(1));
    ShiftProb_pcurrent = ShiftProb_pcurrent/sum(ShiftProb_pcurrent);
    
    %shift jumping distributuion centered at trial shift
    ShiftProb_ptry(shift>=ptry(1)-2 & shift<=ptry(1)+2) = ...
        [0.05,0.2,0.5,0.2,0.05];
    ShiftProb_ptry = ShiftProb_ptry(shift>=pmin(1) & shift<=pmax(1));
    ShiftProb_ptry = ShiftProb_ptry/sum(ShiftProb_ptry);
    
    shift = pmin(1):pmax(1);
    
    jumping_ratio = jumping_ratio*ShiftProb_ptry(shift==pcurrent(1))/ShiftProb_pcurrent(shift==ptry(1));
end

freeind = find(free);
freeind(freeind == 1) = [];
for i = 1:length(freeind)
    ind = freeind(i);
    
    normconst_pcurrent = normcdf(pmax(ind),pcurrent(ind),dp(ind)) ...
        - normcdf(pmin(ind),pcurrent(ind),dp(ind));
    normconst_ptry = normcdf(pmax(ind),ptry(ind),dp(ind)) ...
        - normcdf(pmin(ind),ptry(ind),dp(ind));

    jumping_ratio = jumping_ratio*normconst_pcurrent/normconst_ptry;
end

end


function ptry = ptrySampler(pcurrent,dp,pmin,pmax,Nparam)
%proposal distribution setting (multivariate normal for every parameters except shift)
ptry = pcurrent;

free = (pmin<pmax);

if free(1)
    shift = round(pmin(1))-2:round(pmax(1))+2;
    ShiftProb = zeros(length(shift),1);
    ShiftProb(shift>=pcurrent(1)-2 & shift<=pcurrent(1)+2) = ...
        [0.05,0.2,0.5,0.2,0.05];
    ShiftProb = ShiftProb(shift>=pmin(1) & shift<=pmax(1));
    ShiftProb = ShiftProb/sum(ShiftProb);
    ptry(1) = randsample(pmin(1):pmax(1),1,true,ShiftProb);
end

freeind = find(free);
freeind(freeind == 1) = [];
for i = 1:length(freeind)
    %     pd = makedist('Normal','mu',pcurrent(freeind(i)),'sigma',dp(freeind(i)));
    %     trunc_pd = truncate(pd,pmin(freeind(i)),pmax(freeind(i)));
    %     ptry(freeind(i)) = random(trunc_pd);
    %     ptry(freeind(i)) = pmax(freeind(i))+0.5;
    %     while ptry(freeind(i))>pmax(freeind(i)) | ptry(freeind(i))<pmin(freeind(i))
    %         ptry(freeind(i)) = randn*dp(freeind(i))+pcurrent(freeind(i));
    %     end
    %ptry(freeind(i)) = randn*dp(freeind(i))+pcurrent(freeind(i));
    
    ind = freeind(i);
    
    u = rand;
    u_bar = u*normcdf(pmin(ind),pcurrent(ind),dp(ind))...
        +(1-u)*normcdf(pmax(ind),pcurrent(ind),dp(ind));
    ptry(freeind(i)) = norminv(u_bar,pcurrent(ind),dp(ind));
    
end

end