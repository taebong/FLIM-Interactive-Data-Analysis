function [avep,sigp,pvec] = BayesLocalization(x,y,img,pguess,dp,pmin,pmax,parallel)


%Number of parameters
Nparam = 7;

%Number of kinetochore 
Nkin = size(pmin,1);

%size of each parameter variable
n = zeros(Nparam,1);


%parameter vector
pvec = cell(Nparam,1);

for kin = 1:Nkin
    for i = 1:Nparam
        pvec{i} = p_min(kin,i):dp(i):p_max(kin,i);
        %number of entries in a param vector
        n(i) = length(pvec{i});
    end
       
    %Number of subscripts sets
    Nsubs = prod(n);
    
    %parameter sets and subscripts set that corresponds to each index
    [pmat,subsc] = ParamMatrix(pvec);
    
    disp(['fine search start, loop size = ' num2str(Nsubs)])
    %log-likelihood function vector
    
    tic
    
    for j = 1:Nsubs
        param = pguess;
        param(kin,:) = pmat(:,j)';
        zhat = JointGaussianModel(x,y,param);
        llikvec = zeros(Nsubs,1);
        llikvec = sum(img.*log(zhat));
        
    end
    toc

end
