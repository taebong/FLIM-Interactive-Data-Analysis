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
    
    editboxes = findobj(handles.KinetochoreSelectionGui,'Type','UIControl','Style','edit');
    checkboxes = findobj(handles.KinetochoreSelectionGui,'Type','UIControl','Style','checkbox');
    allhandles = [editboxes;checkboxes];
    
    settingtags = get(allhandles,'Tag');
    editvalues = get(editboxes,'String');
    checkboxvalues = get(checkboxes,'Value');
    settingvalues = [editvalues;checkboxvalues];
    
    save([pathname,filename],'settingtags','settingvalues');
    
elseif strcmp(saveload,'Load')
    setting = load('defaultKinSetting.mat');
    
    if default == 0
        [filename,pathname,~] = uigetfile2('*.mat','Load Setting');
        
        if filename == 0
            return;
        end
        
        setting = load([pathname filename]);
    end
        
    editboxes = findobj(handles.KinetochoreSelectionGui,'Type','UIControl','Style','edit');
    checkboxes = findobj(handles.KinetochoreSelectionGui,'Type','UIControl','Style','checkbox');
    
    [editboxesTF,editboxesidx] = ismember(get(editboxes,'Tag'),setting.settingtags);
    [checkboxesTF,checkboxesidx] = ismember(get(checkboxes,'Tag'),setting.settingtags);
    
    set(editboxes(editboxesTF),{'String'},setting.settingvalues(editboxesidx(editboxesTF)));
    set(checkboxes(checkboxesTF),{'Value'},setting.settingvalues(checkboxesidx(checkboxesTF)));
    
else
    error('saveload value should be either ''Save'' or ''Load''')
end

