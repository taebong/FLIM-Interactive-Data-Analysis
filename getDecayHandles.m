function [decay_handle,fit_handle,residual_handle,irf_handle,refcurve_handle] = getDecayHandles(decay_struct)

NumOfDecays = length(decay_struct);

decay_handle = -99*ones(NumOfDecays,1);
fit_handle = -99*ones(NumOfDecays,1);
residual_handle = -99*ones(NumOfDecays,1);
irf_handle = -99*ones(NumOfDecays,1);
refcurve_handle = -99*ones(NumOfDecays,1);
for i = 1:NumOfDecays
    decay_handle(i) = decay_struct{i}.decay_handle;
    fit_handle(i) = decay_struct{i}.fit_handle;
    residual_handle(i) = decay_struct{i}.residual_handle;
    irf_handle(i) = decay_struct{i}.irf_handle;
    refcurve_handle(i) = decay_struct{i}.refcurve_handle;
end