function value = marquardt_step_instr(delta_t,data,fit_start,fit_end,instr,...
    noise,sig,param,paramfree,nparam,yfit,dy)

Globals_marquardt;

%define local var by global var
mfit = pmfit;
ochisq = pochisq;
ndata = length(data);
ninstr = length(instr);

if (nparam>MAXFIT)
    return -10;
elseif (xincr <= 0)
    return -11;
elseif fit_start<0 || fit_start > fit_end || fit_end>ndata
    return -12;
end

if (alambda < 0)
    for j=1:nparam
        mfit = mfit+1;
    end
    
    if 
end
