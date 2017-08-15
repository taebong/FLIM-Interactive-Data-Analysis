function marquardt_compute_fn_instr(delta_t,data,fit_start,fit_end,instr,...
    noise,sig,param,paramfree,nparam,yfit,dy)

Globals_marquardt;

ndata = length(data);
if (alambda < 0)
    if((pfnvals_len)<ndata)
        
        if pfnvals_len
            pfnvals = [];
            pdy_dparam_pure = [];
        end