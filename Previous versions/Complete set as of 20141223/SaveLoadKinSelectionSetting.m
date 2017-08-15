function SaveLoadKinSelectionSetting(handles,saveload,default)
%  SaveLoadKinSelectionSetting(handles,saveload,default)

if strcmp(saveload,'Save') 
    if default == 1
        filename = 'defaultKinSetting.mat';
        pathname = [pwd '/'];
    elseif default == 0
        [filename,pathname,filterbox] = uiputfile2('*.mat','Save Setting');
    else
        error('default parameter should be either 0 or 1');
    end
    
    ch1 = get(handles.Ch1_checkbox,'Value');
    ch2 = get(handles.Ch2_checkbox,'Value');
    
    featsize = str2double(get(handles.FeatureSize_edit,'String'));
    barint = str2double(get(handles.MinIntegratedIntensity_edit,'String'));
    barrg = str2double(get(handles.MaxRgSquared_edit,'String'));
    barcc = str2double(get(handles.MaxEccentricity_edit,'String'));
    IdivRg = str2double(get(handles.MinIdivRg_edit,'String'));
    masscut = str2double(get(handles.Masscut_edit,'String'));
    Imin = str2double(get(handles.MinLocalImax_edit,'String'));
    field = str2double(get(handles.Field_edit,'String'));
    maxdisp = str2double(get(handles.MaxDisplacement_edit,'String'));
    goodenough = str2double(get(handles.GoodEnough_edit,'String'));
    memory = str2double(get(handles.Memory_edit,'String'));
    coverage = str2double(get(handles.Coverage_edit,'String'));
    ch1ch2dist = str2double(get(handles.Ch12thres_edit,'String'));
    
    save([pathname,filename],'ch1','ch2','featsize','barint','barrg','barcc','IdivRg',...
    'masscut','Imin','field','maxdisp','goodenough','memory','coverage','ch1ch2dist');
    
elseif strcmp(saveload,'Load')
    defsetting = load('defaultKinSetting.mat');
    setting = [];
    paramnames = fieldnames(defsetting);
    TF = zeros(length(paramnames),1);

    if default == 0
        [filename,pathname,filterbox] = uigetfile2('*.mat','Load Setting');
        
        if filename == 0
            return;
        end
        
        setting = load([pathname filename]);
        TF = isfield(setting,paramnames);
    end
    
    param = zeros(length(TF),1);
    for i = 1:length(TF)
        if TF(i) == 0
            setting = setfield(setting,paramnames{i},getfield(defsetting,paramnames{i}));
        end
    end
        
    set(handles.Ch1_checkbox,'Value',setting.ch1);
    set(handles.Ch2_checkbox,'Value',setting.ch2);
    set(handles.FeatureSize_edit,'String',num2str(setting.featsize));
    set(handles.MinIntegratedIntensity_edit,'String',num2str(setting.barint));
    set(handles.MaxRgSquared_edit,'String',num2str(setting.barrg));
    set(handles.MaxEccentricity_edit,'String',num2str(setting.barcc));
    set(handles.MinIdivRg_edit,'String',num2str(setting.IdivRg));
    set(handles.Masscut_edit,'String',num2str(setting.masscut));
    set(handles.MinLocalImax_edit,'String',num2str(setting.Imin));
    set(handles.Field_edit,'String',num2str(setting.field));
    set(handles.MaxDisplacement_edit,'String',num2str(setting.maxdisp));
    set(handles.GoodEnough_edit,'String',num2str(setting.goodenough));
    set(handles.Memory_edit,'String',num2str(setting.memory));
    set(handles.Coverage_edit,'String',num2str(setting.coverage));
    set(handles.Ch12thres_edit,'String',num2str(setting.ch1ch2dist));
else
    error('saveload value should be either ''Save'' or ''Load''')
end

