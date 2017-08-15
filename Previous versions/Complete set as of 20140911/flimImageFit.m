function [A,tau1,f,tau2,Chisq,counts] = flimImageFit(flimimage,time,irf,time_irf,binning,thres,fitsetting,fitmethod,nexpo,fitstart,fitend,noisefrom,noiseto,prior)

% [A,tau1,f,tau2,Chisq] = flimImageFit(flimimage,time,irf,time_irf,binning,thres,fitsetting,fitmethod,nexpo,fitstart,fitend,noisefrom,noiseto,prior)
% 
% flimimage : flim image with time axis is in the first dimension
% time : time axis of FLIM curve
% irf: IRF
% time_irf: time axis of IRF curve
% binning: binning factor
% thres: threshold of photon counts above which fitting is performed
% fitsetting : 7x5 matrix containing fitting setting parameter (pinit,
% fix,pmin,pmax for shift, A, tau1, f, tau2, f2, E2
% fitmethod: 1 if LS, 3 if Bayes
% nexpo: number of exponential 
% fitstart, fitend: indices specifying the fitting region in FLIM curve
% noisefrom, noiseto: indices specifying the region where you estimate the
% constance background level
% prior: used for bayesian analysis in some cases.

fitvar = 2;

%binning
flimimage = downsamp3d(flimimage,[1,binning,binning]);

[tsize,ysize,xsize] = size(flimimage);

A = zeros(ysize,xsize,2);
tau1 = zeros(ysize,xsize,2);
f = zeros(ysize,xsize,2);
tau2 = zeros(ysize,xsize,2);
Chisq = zeros(ysize,xsize,1);
counts = zeros(ysize,xsize,1);

decay_struct.time = time;
decay_struct.irf = irf;
decay_struct.time_irf = time_irf;

for y = 1:ysize
    for x= 1:xsize
        counts(y,x) = sum(flimimage(:,y,x),1);
        if counts(y,x) > thres            
            decay_struct.decay = flimimage(:,y,x);
            fitted_decay_struct = ...
                DecayFLIMFit(decay_struct,fitsetting,fitmethod,nexpo,...
                fitvar,fitstart,fitend,noisefrom,noiseto,prior);
            fit_result = fitted_decay_struct.fit_result;
            A(y,x,1) = fit_result(2,1);
            A(y,x,2) = fit_result(2,2);
            tau1(y,x,1) = fit_result(3,1);
            tau1(y,x,2) = fit_result(3,2);
            f(y,x,1) = fit_result(4,1);
            f(y,x,2) = fit_result(4,2);
            tau2(y,x,1) = fit_result(5,1);
            tau2(y,x,2) = fit_result(5,2);
            
            Chisq(y,x) = fitted_decay_struct.Chi_sq;
            
        end
    end
end

clear decay_struct;