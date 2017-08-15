function Y = mycircshift(X,shift)

% Faster than built-in circshift function
% X should be vector;

n = length(X);

ind = mod((1:n)+n-shift-1,n)+1;

Y = X(ind);
