function [bm,subsc] = ParamMatrix(p)

% p has to be cell array of parameter vectors

N = length(p);
len = zeros(N,1);

for i = 1:N
    len(i) = length(p{i});
end

Nsubs = prod(len);

cc = ['['];

for i = 1:N
    cc = [cc sprintf('subsc(%01d,:) ',i)];
end

cc = [cc(1:end-1),']'];


evalc([cc ' = ind2sub([' num2str(len') '],1:' num2str(Nsubs) ')']);

bm = zeros(N,Nsubs);

for k = 1:N;
    for i = 1:Nsubs
        bm(k,i) = p{k}(subsc(k,i));
    end
end

