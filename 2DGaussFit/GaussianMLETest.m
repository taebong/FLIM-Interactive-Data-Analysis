clear all

mux_true = [10;15];
muy_true = [10;15];
sigx_true = [1.5;1.5];
sigy_true = [1.5;1.5];
theta_true = [0;0];
A_true = [30;35];
bg_true = 3;

N = length(mux_true);

x = 5:20;
y = 5:20;

c = [20,0,1,N];

ConstructGlobalVar(x,y,c);

p_true = [mux_true;muy_true;sigx_true;sigy_true;theta_true;A_true;bg_true];

z = JointGaussianModel_v01(x,y,p_true,c);

simimage = poissrnd(z);

mux_init = mux_true+rand(N,1);
muy_init = muy_true+rand(N,1);
sigx_init = sigx_true+rand(N,1);
sigy_init = sigy_true+rand(N,1);
theta_init = theta_true;
A_init = A_true+rand(N,1)*3;
bg_init = bg_true+rand*3;

mask = generateCircularMask(x,y,mux_init,muy_init,[4;4]);

%%
tic
[mux,muy,sigx,sigy,theta,A,bg,converged] = GaussianMixture2DLMMLE(simimage,x,y,mux_init,muy_init,sigx_init,sigy_init,theta_init,A_init,bg_init,c,mask);
mletime = toc;

%%
pinit = [mux_init(:);muy_init(:);sigx_init(:);sigy_init;theta_init(:);A_init(:);bg_init];
pmin = p_true;
pmax = p_true;
pmin(1:4) = p_true(1:4)-1;
pmax(1:4) = p_true(1:4)+1;
pmin(5:8) = p_true(5:8)-1;
pmax(5:8) = p_true(5:8)+1;
pmax(9:10) = pi;
pmin(11:12) = 0.5*p_true(11:12);
pmax(11:12) = 1.5*p_true(11:12);
pmin(13) = 0;
pmax(13) = 10;

%%
tic
[pfit_LS,~,sigma_p] = lm2_v01(@JointGaussianModel_v01,pinit,x,y,simimage,ones(size(simimage)),0.001,pmin,pmax,c);
lstime = toc;

ClearGlobalVar;

%%
close all
figure
subplot(1,3,1), imagesc(simimage)
axis image
colorbar

fitparam = [mux;muy;sigx;sigy;theta;A;bg];
zfit = JointGaussianModel_v01(x,y,fitparam,c);
subplot(1,3,2), imagesc(zfit);
axis image
caxis([0,40]);
colorbar
MLEmudiscrep = sqrt(sum((fitparam(1:4)-p_true(1:4)).^2));

%%
zfitLS = JointGaussianModel_v01(x,y,pfit_LS,c);
subplot(1,3,3), imagesc(zfitLS);
axis image
caxis([0,40]);
colorbar
LSmudiscrep = sqrt(sum((pfit_LS(1:4)-p_true(1:4)).^2));
