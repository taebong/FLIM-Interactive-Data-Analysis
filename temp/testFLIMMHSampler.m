close all

%test FLIMMHSampler

nexpo = 2;
Nparam = nexpo*2+1;
pmin = decay_struct.fit_result(1:Nparam,4);
pmax = decay_struct.fit_result(1:Nparam,5);
pmin(1) = -2;
pmax(1) = -2;
% pmax(3) = 3.986;
% pmin(3) = pmax(3);
% pmax(5) = 0.2256;
% pmin(5) = 0.2256;


fitvar = 1;
fit_start = decay_struct.fit_region(1);
fit_end = decay_struct.fit_region(2);

Nsample = 5000;

tic
psampled = FLIMMHSampler(decay_struct,pmin,pmax,nexpo,fitvar,fit_start,fit_end,Nsample);
toc

%%
mean(psampled,2)
std(psampled,0,2)
decay_struct.fit_result

%%
burnmore = 1;
figure
dp = [1,0.001,0.01,0.01,0.01]';
for i = 2:5
    subplot(4,1,i-1)
    [ncount,xi] = hist(psampled(i,burnmore:end),pmin(i):dp(i):pmax(i));
    bar(xi,ncount/sum(ncount))
    hold on
    plot(decay_struct.p_vec{i},decay_struct.marg_post{i},'-r');
end

figure
for i = 2:5
    subplot(4,1,i-1)
    plot(psampled(i,:));
end
