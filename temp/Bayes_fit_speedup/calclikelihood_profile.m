function lik = calclikelihood_profile(time,data,time_irf,irf,param_mat,...
    nexpo,fit_start,fit_end)

%   function lik = calclikelihood(time,data,irf,time_irf,param_mat,...
%    nexpo,fit_start,fitend)
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


dt_irf = time_irf(2)-time_irf(1);
irf = double(irf/(sum(irf)*dt_irf));

y_dat = data(fit_start:fit_end);

adc_ratio = round(length(irf)/length(time));

T = 12.58;
t = (0:dt_irf:T)';

Nsubs = size(param_mat,2);

nfft = 2^nextpow2(2*length(t)+length(irf)-1);

%Fourier Transform of IRF
Firf = fft(irf,nfft);

%Total counts between fit_start and fit_end
totcount = sum(y_dat);

shift = -999;
llik_vec = zeros(Nsubs,1);
tau1 = -999;

tic
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
 
    
    if nexpo == 1
        decay_model = param(2)*decay1+(1-param(2));
    elseif nexpo == 2
        decay_model = param(2)*param(4)*decay1...
            +param(2)*(1-param(4))*exp(-t/(param(5)*param(3)))+(1-param(2));
    end
    
    decay_model(end+1:end+length(t)) = decay_model(1:length(t));

    %Fourier Transform of model
    Fmodel = fft(decay_model,nfft);
        
    Fmodel = Fmodel.*Firf;
    
    
end
toc
    
tic
for i = 1:Nsubs
    
    
    
    convmodel = real(ifft(Fmodel))*dt_irf;
    
    

    
end
toc

tic
for i = 1:Nsubs
    
    y = convmodel(length(t)+1:length(t)+length(irf));
    y = reshape(y,round(adc_ratio),length(time));
    y = sum(y,1);
    p_model = y(fit_start:fit_end)';
    
    
end
toc
 

tic
for i = 1:Nsubs
    %model normalization (max to total counts)
    p_model = p_model/sum(p_model)*totcount;
    
    %likelihood function calculation
    %vectorized N-param-dimensional likelihood function
    llik_vec(i) = sum((y_dat).*log(p_model));

    switch i
        case 1
            disp('progress: 0%')
        case round(Nsubs/5)
            disp('progress: 20%')
        case round(2*Nsubs/5)
            disp('progress: 40%')
        case round(3*Nsubs/5)
            disp('progress: 60%')
        case round(4*Nsubs/5)
            disp('progress: 80%')
        case round(5*Nsubs/5)
            disp('progress: 100%, fine search complete')
    end
    
end
toc

lik = exp(llik_vec-max(llik_vec));

