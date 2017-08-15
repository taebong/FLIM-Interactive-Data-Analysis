close all

% Atrue = [20;35;25];
% mutrue = [35,40;78,100;40,38];
% sigtrue = [1.5,1.6;1.7,1.5;1.5,1.5];
% rhotrue = [0.1;0.2;0];

Atrue = [30;35];
mutrue = [5,5;9,9];
sigtrue = [1.5,1.5;1.7,1.7];
rhotrue = [0;0];
bgtrue = 3;
imgsize = [15,15];

Nsubgrid = 10;
xlin = linspace(0,imgsize(2),Nsubgrid*imgsize(2))+0.5;
ylin = linspace(0,imgsize(1),Nsubgrid*imgsize(1))+0.5;
[X,Y] = meshgrid(xlin,ylin);

% simulated image
prob = GaussianMixtureModel2D(Atrue,mutrue,sigtrue,rhotrue,bgtrue,X,Y,Nsubgrid);
simimage = poissrnd(prob);

%%
figure
imagesc(simimage)
colormap gray
axis image
colorbar


%%
A_init = Atrue+randn(size(Atrue))*3;
% mu_init = mutrue+rand(size(mutrue))-0.5;
mu_init = mutrue+1;
sig_init = sigtrue+rand(size(sigtrue))-0.5;
rho_init = rhotrue;
bg_init = bgtrue+1;

[A,mu,sig,rho,bg] = ...
    GaussianMixture2DMH(simimage,A_init,mu_init,sig_init,rho_init,bg_init,X,Y,Nsubgrid);

%%
pinit = [mu_init(:,1),mu_init(:,2),sig_init(:,1),sig_init(:,2),0,A_init,0];
pmax(:,1:2) = pinit(1:2)+2;
pmin(:,1:2) = pinit(1:2)-2;
pmax(:,3:4) = sig_init(1)*2;
pmin(:,3:4) = 0.1*sig_init(1);
pmax(:,5) = 0;
pmin(:,5) = 0;
pmax(:,6) = 2*pinit(6);
pmin(:,6) = 0.4*pinit(6);
pmax(7) = 0.5*A_init;
pmin(7) = 0;
c = [20,1,1];
x = 1:15;
y = 1:15;
ConstructGlobalVar(x,y,c);
weight = ones(size(simimage));
dp = ones(1,7)*0.01;
dp(4) = 0;
dp(5) = 0;
[pfit,X2,sigp,sigy,corr,Rsq,cvg_hst, converged] = lm2(@JointGaussianModel,pinit,1:15,1:15,simimage,weight,dp,pmin,pmax,c);


%%
close all

A1 = cellfun(@(x) x(1),A(1:end));
mu1x = cellfun(@(x) x(1),mu(1:end));
mu1y = cellfun(@(x) x(1,2),mu(1:end));
sig1 = cellfun(@(x) x(1),sig(1:end));
rho1 = cellfun(@(x) x(1),rho(1:end));
bg1 = cellfun(@(x) x(1), bg(1:end));

A2 = cellfun(@(x) x(2),A(1:end));
mu2x = cellfun(@(x) x(2,1),mu(1:end));
mu2y = cellfun(@(x) x(2,2),mu(1:end));
sig2 = cellfun(@(x) x(2,1),sig(1:end));
rho2 = cellfun(@(x) x(2),rho(1:end));


figure
subplot(6,1,1), plot(A1)
subplot(6,1,2), plot(mu1x)
subplot(6,1,3), plot(mu1y)
subplot(6,1,4), plot(sig1)
subplot(6,1,5), plot(rho1)
subplot(6,1,6), plot(bg1)
%histogram(mu1x)

figure
subplot(5,1,1), plot(A2)
subplot(5,1,2), plot(mu2x)
subplot(5,1,3), plot(mu2y)
subplot(5,1,4), plot(sig2)
subplot(5,1,5), plot(rho2)
