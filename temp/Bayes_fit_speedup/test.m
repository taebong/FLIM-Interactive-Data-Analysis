clear all;

% new bayes fit test

addpath CONVNFFT_Folder

load('sample.mat')
time = decay_struct{1}.time;
decay = decay_struct{1}.decay;



%load irf
loaded_irf = load('currentIRF.mat');
irf = loaded_irf.decay;
time_irf = loaded_irf.time;

nexpo = 1;
fit_start = 15;
fit_end = 240;
prior = 1;

if nexpo == 1
    p_min = [10,0.90,3]';
    p_max = [10,1,4.5]';
    dp = [1,0.0025,0.01]';
elseif nexpo == 2
    p_min = [10,0.96,3.57,0.2,0.01]';
    p_max = [10,1,3.57,1,0.3]';
    dp = [1,0.005,0.01,0.01,0.01]';
else
    errordlg('not available yet')
    return
end
tic
[p_fit1,sigma_p,p_vec,post,marg_post] = bayes_fit_v1(time,decay,dp,p_min,p_max,nexpo,prior,fit_start,fit_end);
toc


% load('pmat.mat')
% lik = calclikelihood_profile(time,decay,irf,time_irf,pmat,nexpo,fit_start,fit_end);
% 


% tic
% [p_fit2,sigma_p,p_vec,post,marg_post] = bayes_fit(@bayes_decay_model,time,decay,dp,p_min,p_max,nexpo,prior,fit_start,fit_end);
% toc


% 
% 
%%
%load irf
% loaded_irf = load('currentIRF.mat');
% irf = loaded_irf.decay;
% time_irf = loaded_irf.time;
% 
% 
% param = p_max;
% 
% dt_irf = time_irf(2)-time_irf(1);
% irf = double(irf/(sum(irf)*dt_irf));
% 
% adc_ratio = length(irf)/length(time); 
% 
% T = 12.58;
% t = (0:dt_irf:T)';
% 
% shift = round(param(1));
% 
% if nexpo == 1
%     decay_model = param(2)*exp(-t/param(3))+(1-param(2));
% elseif nexpo == 2
%     decay_model = param(2)*param(4)*exp(-t/param(3))...
%         +param(2)*(1-param(4))*exp(-t/(param(5)*param(3)))+(1-param(2));
% end
% 
% decay_model(end+1:end+length(t)) = decay_model(1:length(t));
% %decay_model(end+1:end+length(t)) = decay_model(1:length(t));
% 
% decay_model1 = circshift(decay_model,shift);
% decay_model2 = mycircshift(decay_model,shift);
% 
% %convnfft is about 3 times faster than conv
%     y = convnfft(irf,decay_model1)*dt_irf;
%     y = y(length(t)+1:length(t)+length(time_irf));
% 
% nfft = 2^nextpow2(2*length(t)+length(irf));
% %y = conv(irf,decay_model)*dt_irf;
%     Firf = fft(irf,nfft);
%     Fmodel = fft(decay_model2,nfft);
%     Fmodel = Fmodel.*Firf;
%     y1 = real(ifft(Fmodel))*dt_irf;
%     
%     y1 = y1(length(t)+1:length(t)+length(time_irf));
% 
% 


%%
% 
% X = 1:100;
% tic 
% for i=1:10000
%     Y = mycircshift(X,10);
% end
% toc
% 
% tic
% for i=1:10000
%     Y = circshift(X,10);
% end
% toc


%%
% %% fft test

loop = 10^4;
N = 2^nextpow2(15000);
X = rand(N,1);
Y = fft(X);


tic
for i =1:loop
    X1 = real(ifft(Y));
end
toc

tic
for i = 1:loop
    X2 = real(conj(fft(conj(Y))))/length(Y);
end
toc





