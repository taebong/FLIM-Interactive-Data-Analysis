function y = single_decay_model(time,param,consts)
% param(1): amplitude of fluroscence decay
% param(2): lifetime of decay
% param(3): background
%
% if two expo:
% param(4) : amp of second decay
% param(5) : lifetime of second decay
% 
% if three expo:
% param(6) : amp of third decay
% param(7) : lifetime of third decay
%
% consts = [nexpo,trans]
% nexpo: number of exponentials in your model
% trans: boolean that indicates whether or not you want to set the
% transition region (where peak located) to zero

dt = time(2) - time(1);
shift = param(1);

%Laser modulation period 
T = 12.58;
t = (0+shift:dt:T+shift)';

nexpo = consts(1);
trans = consts(2);

loaded_irf = load('currentIRF.mat');
irf = loaded_irf.decay;
irf = double(irf/(sum(irf)*dt));

decay_model = param(2)*exp(-t/param(3))+param(4);
if nexpo > 1
    decay_model = decay_model + param(5)*exp(-t/param(6));
end
if nexpo > 2
    decay_model = decay_model + param(7)*exp(-t/param(8));
end
    
decay_model(end+1:end+length(t)) = decay_model(1:length(t));
decay_model(end+1:end+length(t)) = decay_model(1:length(t));

y = conv(irf,decay_model)*dt;

y = y(length(t)+1:length(t)+length(time));

if trans
    y(trans-2:trans+2) = 0;
end    

