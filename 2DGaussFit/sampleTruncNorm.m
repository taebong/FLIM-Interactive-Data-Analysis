function X = sampleTruncNorm(mu,sig,range,N)
% mu, sig: mean and standard deviation of normal distribution
% range: [min,max], the range of normal dist
% N: number of sample

a = range(1);
b = range(2);

u = rand(N,1);

u_bar = u*normcdf(a,mu,sig)+(1-u)*normcdf(b,mu,sig);

X = norminv(u_bar,mu,sig);