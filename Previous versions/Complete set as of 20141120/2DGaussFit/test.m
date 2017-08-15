clear all;
clc;
close all;

x = 36:44;
y = 16:24;

%sigtrial = 0.5:0.2:2.5;
%htrial = (1.5./sigtrial).^2*40;
%bgtrial = [0,1,2,5,10,20,40];
%bintrial = floor(1.5./sigtrial*50);
Nsim = 500;
xtrial = 40:0.5:42;

% xmintrial = 40-sigtrial*2;
% xmaxtrial = 40+sigtrial*2;
% ymintrial = 20-sigtrial*2;
% ymaxtrial = 20+sigtrial*2;

for k = 1:length(xtrial)
    GlobalVarTracking;
    c = [50,1,1];
%     x = xmintrial(k):xmaxtrial(k);
%     y = ymintrial(k):ymaxtrial(k);
    ConstructGlobalVar(x,y,c);
    param(1,:)= [xtrial(k),20,1.5,1.5,0,40,10];
    %param(2,:) = [40,26,1.5,1.5,0,40,10];
    
    %param = [40,20,2,2,0,40,10,40,28,2,2,0,30,10]';
    
    
    z = JointGaussianModel(x,y,param,c);
    %
    % h1 = figure;
    % imagesc(z);
    % axis image;
    
    pfit = zeros(Nsim,size(param,2));
    Ntot = zeros(Nsim,1);
    cm = zeros(Nsim,2);
    xrms = zeros(Nsim,1);
    X2 = zeros(Nsim,1);
    %%
    %matlabpool open
    totsimz = zeros(size(z,1),size(z,2));
    
    tic
    
    pmin = param;
    pmax = param;
    pmin(1,1:2) = pmin(1:2)-2;
    pmax(1,1:2) = pmax(1:2)+2;
    pmin(1,3:4) = pmin(1,3:4)-1;
    pmax(1,3:4) = pmax(1,3:4)+1;
    
    pmin(7)= 0;
    pmax(7)= param(1,7)*2+5;
    pinit = pmin+rand(1,7).*(pmax-pmin);
    [X,Y]=meshgrid(x,y);
    
    dp = ones(1,7)*0.01;
    dp(4) = 0;
    dp(5) = 0;
    

    
    for i = 1:Nsim
        
        simz = SimulateData(x,y,param,c);
        Ntot(i) = sum(simz(:));
        %
        %     h3 = figure;
        %     imagesc(simz)
        
        nonzero_z = simz;
        nonzero_z(simz==0)=1;
        sigz = sqrt(nonzero_z);
        weight = 1./sigz;
%         weight = ones(size(z,1),size(z,2));
        
        totsimz = simz+totsimz;
        pmin(1,6) = 0;
        pmax(6) = max(simz(:))+10;
        cmx = sum(X(:).*simz(:))/sum(simz(:));
        cmy = sum(Y(:).*simz(:))/sum(simz(:));
        cm(i,:) = [cmx,cmy];
        pinit(1:2) = cm(i,:);
        pinit(6) = max(simz(:))-5;  
        pinit(5) = 0;
        pinit(3:4) = param(3:4);
        
        [pfit(i,:),X2(i),sigp,sigy,corr,Rsq,cvg_hst, converged] = lm2(@JointGaussianModel,pinit,x,y,simz,weight,dp,pmin,pmax,c);
        
    end
    %matlabpool close
    for j = 1:Nsim
        xrms(j) = sqrt(sum((pfit(j,1:2)-param(1,1:2)).^2));
    end
    
    save(['xtest' num2str(k,'%.2d') '.mat'],'param','x','y','z','Nsim','pfit','Ntot','cm','xrms','c','weight','pinit','pmin','pmax','totsimz','X2');
    
    ClearGlobalVar;
end


toc
%%
%%
%
% h1 = figure;
% surf(z);
%
% h2 = figure;
% filteredz = bpass(z,1,6);
% surf(filteredz)
%
% h3 = figure;
% surf(simz)
%
% %%
% h4 = figure;
% filtered = bpass(simz,1,6);
% surf(filtered)
%
%
% %%
% placefigure(h1,[2,2,1,1]);
% placefigure(h2,[2,2,1,2]);
% placefigure(h3,[2,2,2,1]);
% placefigure(h4,[2,2,2,2]);


%%
