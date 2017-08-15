function y = lm_decay_model(time,param,consts)

% normalized to the number of photons
%
% param(1) : shift of decay model from IRF 
%
% if one expo:
% P = param(2)*exp(-t/param(3))+(1-param(2))
% param(2): fractional amp of expo decay
% param(3): lifetime of the first decay
%
% if two expo:
% P = param(2)*param(4)*exp(-t/param(3))+param(2)*(1-param(4))*exp(-t/param(5))+(1-param(2));
% param(4) : fraction of the first decay 
% param(5) : lifetime of second decay
% 
% consts = [nexpo, counts,fit_start,fit_end]
% nexpo: number of exponentials in your model
% counts: Total number of photons in the region of interest 

nexpo = consts(1);
counts = consts(2);
fit_start = consts(3);
fit_end = consts(4);
shift = round(param(1));

loaded_irf = load('currentIRF.mat');
irf = loaded_irf.decay;
time_irf = loaded_irf.time;
dt_irf = time_irf(2)-time_irf(1);
irf = double(irf/(sum(irf)*dt_irf));

adc_ratio = length(irf)/length(time); 

T = 12.58;
t = (0:dt_irf:T)';


if nexpo == 1
    decay_model = param(2)*exp(-t/param(3))+(1-param(2));
elseif nexpo == 2
    decay_model = param(2)*param(4)*exp(-t/param(3))...
        +param(2)*(1-param(4))*exp(-t/param(5))+(1-param(2));
end
    
decay_model(end+1:end+length(t)) = decay_model(1:length(t));
decay_model(end+1:end+length(t)) = decay_model(1:length(t));

decay_model = circshift(decay_model,shift);

y = conv(irf,decay_model)*dt_irf;

y = y(length(t)+1:length(t)+length(time_irf));

new_y = reshape(y,round(adc_ratio),length(time));
new_y = sum(new_y,1);
y = new_y';

%normalize to the number of total counts
y = y/sum(y(fit_start:fit_end))*counts;

