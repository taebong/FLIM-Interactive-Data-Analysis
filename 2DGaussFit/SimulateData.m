function simz = SimulateData(x,y,param,c)
% 
% x = XY{1};
% y = XY{2};
z = JointGaussianModel(x,y,param,c);

N = round(sum(z(:)));
%zp = randp(z(:),1,N);
%zp = hist(zp,length(x)*length(y));
zp = mnrnd(N,z(:)/sum(z(:)));
simz = reshape(zp,[length(y),length(x)]);
