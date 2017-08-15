clc;
clear all;

time = (1:256)*0.0391;
N = [5E2,1E3,2E3,3E3];
nexpo = 1;
param = [5,0.95,3.4];

%load irf
loaded_irf = load('currentIRF.mat');
irf = loaded_irf.decay;
time_irf = loaded_irf.time;

N_data = length(N);

decay_struct = cell(2*N_data,1);

for i = 1:N_data
   decay_struct{i}.time = time;
   decay_struct{i}.decay = simulated_data(time,param,N(i),nexpo,irf,time_irf);
   decay_struct{i}.name = ['N' num2str(N(i),'%10.0e') 'nexpo' num2str(nexpo)];
end


nexpo = 2;
param = [5,0.95,3.4,0.7,0.3];

N_data = length(N);

for i = 1:N_data
   decay_struct{N_data+i}.time = time;
   decay_struct{N_data+i}.decay = simulated_data(time,param,N(i),nexpo,irf,time_irf);
   decay_struct{N_data+i}.name = ['N' num2str(N(i),'%10.0e') 'nexpo' num2str(nexpo)];
end


save('simulated_data_set','decay_struct');