function marquardt(delta_t,data,ndata,fit_start,fit_end,instr,ninstr,noise,fig,param,paramfree,nparam)

mfit = 0;
for i=1:nparam
   if paramfree(i)
       mfit = mfit+1;
   end
end
    
alambda = -1;

