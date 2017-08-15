function M=downsamp3d(M,bindims)
%DOWNSAMP2D - simple tool for 3D downsampling
%
% M=downsamp3d(M,bindims)
%
%in:
%
% M: a matrix
% bindims: a vector [p,q,r] specifying pxqxr downsampling
%
%out:
%
% M: the downsized matrix

p=bindims(1); q=bindims(2); r=bindims(3);
[m,n,l]=size(M); %M is the original matrix

m = m-rem(m,p);
n = n-rem(n,q);
l = l-rem(l,r);

M = M(1:m,1:n,1:l);

M=sum( reshape(M,[p,m/p,n,l]) ,1 );
M=squeeze(M); 

M=sum( reshape(M,[m/p,q,n/q,l]) ,2);
M=squeeze(M); 

M=sum( reshape(M,[m/p,n/q,r,l/r]) ,3);
M=squeeze(M); 