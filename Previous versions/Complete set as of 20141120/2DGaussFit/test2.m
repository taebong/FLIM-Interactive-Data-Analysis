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
xtrial = 40;

% xmintrial = 40-sigtrial*2;
% xmaxtrial = 40+sigtrial*2;
% ymintrial = 20-sigtrial*2;
% ymaxtrial = 20+sigtrial*2;

for k = 1:length(xtrial)
    GlobalVarTracking;
    c = [100,1,1];
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
    
    pfit = zeros(Nsim,5);
    Ntot = zeros(Nsim,1);
    cm = zeros(Nsim,2);
    xrms = zeros(Nsim,1);
    pvar = zeros(Nsim,1);

    %%
    %matlabpool open
    totsimz = zeros(size(z,1),size(z,2));
    
    tic
 
    [X,Y]=meshgrid(x,y);
    
    for i = 1:Nsim
        
        simz = SimulateData(x,y,param,c);
        Ntot(i) = sum(simz(:));
        %
        %     h3 = figure;
        %     imagesc(simz)
        
        
        totsimz = simz+totsimz;
        cmx = sum(X(:).*simz(:))/sum(simz(:));
        cmy = sum(Y(:).*simz(:))/sum(simz(:));
        cm(i,:) = [cmx,cmy];
        param0 = [cmx,cmy,param(1,3)-0.5+rand,sqrt(param(1,7))+3*rand,Ntot(i)];
        a = 1;
        [pfit(i,:),pvar(i)] = MLEwG(simz,param0,a,0,1);

        disp([num2str(i) ' out of ' num2str(Nsim)])
%        [pfit(i,:),X2(i),sigp,sigy,corr,Rsq,cvg_hst, converged] = lm2(@JointGaussianModel,pinit,x,y,simz,weight,dp,pmin,pmax,c);
    

    end
    %matlabpool close
    for j = 1:Nsim
        xrms(j) = sqrt(sum((pfit(j,1:2)-param(1,1:2)).^2));
    end
    
   % save(['xtest' num2str(k,'%.2d') '.mat'],'param','x','y','z','Nsim','pfit','Ntot','cm','xrms','c','weight','pinit','pmin','pmax','totsimz','X2');
    
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
