function [est_param,resnorm,residual] = lsq_decay_fitting(time,data,tau_guess,fit_start,fit_end)
Global_var;

y = data;
f_start = fit_start;
f_end = fit_end;
t = time;

LB = [max(data)*0.7,0,0,-5];
UB = [max(data)*1.3,4,max(data)*0.3,5];

initial = [max(data),tau_guess,0,1];

options = optimset('Display','iter','Algorithm','levenberg-marquardt','TolFun',1E-8);
[est_param,resnorm,residual] = lsqnonlin(@min_func,initial,LB,UB,options);

figure
semilogy(time,single_decay_model(est_param,time,1,length(time)),'b')
hold on
semilogy(time,data,'r.')


