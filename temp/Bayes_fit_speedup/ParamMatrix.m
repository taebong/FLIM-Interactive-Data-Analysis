function [bm,subsc] = ParamMatrix(p)

% Optimized as of 8/4/2013

% p has to be cell array of parameter vectors


N = length(p);
len = zeros(1,N);


priority = [1;3];  %prioritize these parameter


for i = 1:N
    len(i) = length(p{i});
end

temp = (1:N)';
for j = 1:length(priority)
    temp(temp==priority(j))=[];
end

pri_ind = [priority;temp];

Nsubs = prod(len);

subsc = zeros(len);
ind = 1:Nsubs;

for i = 1:N
   subsc(pri_ind(i),:) = mod(floor((ind-1)/prod(len(pri_ind(i+1:N)))),len(pri_ind(i)))+1;
end

bm = zeros(N,Nsubs);

for k = 1:N;
    bm(k,:) = p{k}(subsc(k,:));
end






