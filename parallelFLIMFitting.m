Nworkers = 2;
pool = parpool(Nworkers);

addpath FLIMFitting/
addpath bh/
%addpath CONVNFFT_Folder
%addAttachedFiles(pool,'/CONVNFFT_Folder/inplaceprod.mexw64')
%addAttachedFiles(pool,'/CONVNFFT_Folder/inplaceprod.c')

irfname = 'IRF/IRF_20160302 nocondensor ex865 m2 em425 singlepoint_backgr_subtracted.mat';
dstructname = 'testinput.mat';
outputname = 'FLIMupdatedDecayStruct.mat';

fitmethod = 3;  %3 for grid sampling
nexpo = 2;
fitvar = 1; %1 for E, 2 for tau2
fitstart = 12;
fitend = 245;
noisefrom = 47; %not important for bayes 
noiseto = 57;
prior = 1;  %1 for uniform
Nsample = 0;   %don't need for Grid Sampling
Nburn = 0;   %don't need for Grid Sampling

tau1 = 3.87;
E = 0.15;

%loading irf
loaded = load(irfname);
irf = loaded.decay;
time_irf = loaded.time;

%loading input decay_struct
loaded = load(dstructname);
decay_struct = loaded.decay_struct;

Ndstructs = length(decay_struct);
for i = 1:Ndstructs
    decay_struct{i}.laserT = 12.4686;
    decay_struct{i} = DecayStructInitializer(decay_struct{i});
    decay_struct{i}.time_irf = time_irf;
    decay_struct{i}.irf = irf;
    decay_struct{i}.flimblock = 2;
    
    name = decay_struct{i}.name;
    cnum = str2double(name(1:2));
    
    fitsetting = decay_struct{i}.fit_result;
    
    fitsetting(3,1) = tau1;
    fitsetting(5,1) = E;
    fitsetting(1,3) = 1;
    fitsetting(3,3) = 1;
    fitsetting(5,3) = 1;
    if ismember(cnum,[1,2])
        fitsetting(1,1) = -4;
    elseif ismember(cnum,[3,4,6,7,8,9,10])
        fitsetting(1,1) = -6;
    elseif ismember(cnum,[5,11])
        fitsetting(1,1) = -5;
    end
    decay_struct{i}.fit_result = fitsetting;
end


disp('Fit Starts')

parfor j = 1:Ndstructs
    decay_struct{j} = DecayFLIMFit(decay_struct{j},...
        fitmethod,nexpo,fitvar,fitstart,fitend,noisefrom,noiseto,prior,Nsample,Nburn);
    
    time = decay_struct{j}.time;
    decay = decay_struct{j}.decay;
    irf = decay_struct{j}.irf;
    time_irf = decay_struct{j}.time_irf;
    residual = decay_struct{j}.residual;
    pfit = decay_struct{j}.fit_result(1:(nexpo*2+1),1);
    
    counts = sum(decay(fitstart:fitend));
    if isfield(decay_struct{j},'refcurve')==0 || isempty(decay_struct{j}.refcurve)
        refcurve = ones(length(irf),1);
    else
        refcurve = decay_struct{j}.refcurve;
    end
    decay_struct{j}.fit_region = [fitstart, fitend];
    decay_struct{j}.noise_region = [noisefrom,noiseto];
    
end

save(outputname,'decay_struct','-v7.3');

delete(pool);