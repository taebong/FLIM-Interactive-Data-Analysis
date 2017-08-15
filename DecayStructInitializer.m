function outputdecaystruct = DecayStructInitializer(inputdecaystruct)

outputdecaystruct = checkDecayStruct(inputdecaystruct);
load('FitResultTemplate.mat')

default_fit_result = FitResultTemplate;

outputdecaystruct.decay_handle = -99;
outputdecaystruct.fit_handle = -99;
outputdecaystruct.residual_handle = -99;
outputdecaystruct.irf_handle = -99;
outputdecaystruct.refcurve_handle = -99;

if isfield(outputdecaystruct,'residual') == 0
    outputdecaystruct.residual = [];
end

if isfield(outputdecaystruct,'filename') == 0 || isempty(outputdecaystruct.filename)
    outputdecaystruct.filename = 'NA';
end

if isfield(outputdecaystruct,'pathname') == 0 || isempty(outputdecaystruct.pathname)
    outputdecaystruct.pathname = 'NA';
end

if isfield(outputdecaystruct,'fit_result') == 0 || isempty(outputdecaystruct.fit_result)
    outputdecaystruct.fit_result = default_fit_result;
end

if isfield(outputdecaystruct,'Chi_sq') == 0 || isempty(outputdecaystruct.Chi_sq) 
    outputdecaystruct.Chi_sq = 0;
end

if isfield(outputdecaystruct,'fit_region') == 0 || isempty(outputdecaystruct.fit_region)
    outputdecaystruct.fit_region = [0,0];
end

if isfield(outputdecaystruct,'noise_region') == 0 || isempty(outputdecaystruct.noise_region)
    outputdecaystruct.noise_region = [0,0];
end


if isfield(outputdecaystruct,'fitting_method')==0 || ...
        isempty(outputdecaystruct.fitting_method) || outputdecaystruct.fitting_method==0
    outputdecaystruct.residual = [];
    outputdecaystruct.fit_result = default_fit_result;
    outputdecaystruct.Chi_sq = 0;
    outputdecaystruct.fit_region = [0,0];
    outputdecaystruct.noise_region = [0,0];
    outputdecaystruct.fitvar = 0;
    outputdecaystruct.nexpo = 0;
end

if isfield(outputdecaystruct,'flimblock') == 0 || isempty(outputdecaystruct.flimblock)
    outputdecaystruct.flimblock = 0;
end

if isfield(outputdecaystruct,'laserT') == 0 || isempty(outputdecaystruct.laserT)
    if isfield(outputdecaystruct,'setting') && ~isempty(outputdecaystruct.setting)
        sdt = outputdecaystruct.setting;
        if isfield(outputdecaystruct,'flimblock') && outputdecaystruct.flimblock~=0;
            flimblock = outputdecaystruct.flimblock;
        else
            flimblock = 1;
        end
        measdesc = bh_getmeasdesc(sdt,flimblock);
        laserT = mean([1/measdesc.min_sync_rate,1/measdesc.max_sync_rate])*10^9;
        outputdecaystruct.laserT = laserT;
    else
        outputdecaystruct.laserT = 12.5;  %default
    end
end