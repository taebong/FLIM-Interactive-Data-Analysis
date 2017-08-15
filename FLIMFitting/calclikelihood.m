function lik = calclikelihood(time,data,time_irf,irf,param_mat,...
    nexpo,fitvar,fit_start,fit_end,refcurve,laserT)

%   lik = calclikelihood(time,data,time_irf,irf,param_mat,...
%    nexpo,fitvar,fit_start,fit_end,refcurve,laserT)
%
%   Calculates likelihood function for fluorescence decay model based on
%   IRF and data given.
%
%   time: time vector in data (row vector)
%   data: decay data  (row vector, should be in the same size as time vector)
%   irf: irf vector  (row vector)
%   time_irf: irf time vector (row vector, should be in the same size as
%   irf vector)
%   param_mat: (Number of parameter)x(Number of grids in likelihood
%   function) matrix, contains trial parameters in each grid.
%   nexpo:  Number of exponential
%   fit_start, fit_end : time channels defining the time channels of your interest
%  refcurve = reference curve to correct for ripple. length should be the
% same as irf, default is a vector of one
%  laserT = laser rep period in nanosec

if nargin<11
    laserT = 12.5;
end

dt_irf = time_irf(2)-time_irf(1);
irf = double(irf);
irf = irf/(sum(irf)*dt_irf);

y_dat = data(fit_start:fit_end);

adc_ratio = round(length(irf)/length(time));

t = (0:dt_irf:laserT)';

% lengths
Nt = length(t);
Nirf = length(irf);
Ndata = length(data);

Nsubs = size(param_mat,2);

nfft = 2^nextpow2(2*length(t)+length(irf)-1);

%Total counts between fit_start and fit_end
totcount = sum(y_dat);

llik_vec = zeros(Nsubs,1);

tau1 = -999;
shift = -999;
    
for i = 1:Nsubs

    param = param_mat(:,i);
    
    if shift ~= round(param(1))
        shift = round(param(1));
        Firf = fft(mycircshift(irf,shift),nfft);
    end
    
    if tau1 ~= param(3)
        tau1 = param(3);
        decay1 = exp(-t/tau1);
    end
    
    switch nexpo
        case 1
            param(4) = 1;
            param(6) = 1;
            decay2 = 0;
            decay3 = 0;
        case 2
            param(6) = 1;
            if fitvar == 1
                tau2 = param(5)*param(3);
            elseif fitvar == 2
                tau2 = param(5);
            end
            decay2 = exp(-t/tau2);
            decay3 = 0;
        case 3
            if fitvar == 1
                tau2 = param(5)*param(3);
                tau3 = param(7)*param(3);
            elseif fitvar == 2
                tau2 = param(5);
                tau3 = param(7);
            end
            decay2 = exp(-t/tau2);
            decay3 = exp(-t/tau3);
    end
    
    decay_model = param(2)*param(4)*decay1...
        +param(2)*(1-param(4))*param(6)*decay2...
        +param(2)*(1-param(4))*(1-param(6))*decay3...
        +(1-param(2));
    decay_model(end+1:end+Nt) = decay_model(1:Nt);
    
    %Fourier Transform of model
    Fmodel = fft(decay_model,nfft);
    
    Fmodel = Fmodel.*Firf;
    
    convmodel = real(ifft(Fmodel));
    
    convmodel = convmodel(Nt+1:Nt+Nirf);
    
    %correct for ripple using refcurve
    convmodel = convmodel.*refcurve;
    
    convmodel = reshape(convmodel,round(adc_ratio),Ndata);
    convmodel = sum(convmodel,1);
    p_model = convmodel(fit_start:fit_end)';
    
    %model normalization (max to total counts)
    p_model = p_model/sum(p_model)*totcount;
    
    %likelihood function calculation
    %vectorized N-param-dimensional likelihood function
    llik_vec(i) = sum((y_dat).*log(p_model));
    
end



lik = exp(llik_vec-max(llik_vec));

