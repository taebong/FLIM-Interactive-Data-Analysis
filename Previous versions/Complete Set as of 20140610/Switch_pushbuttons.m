function Switch_pushbuttons(handles,string,category)
% Change 'Enable' property of the pushbuttons dealing with images or decays

if strcmp(category,'decay')
    set(handles.ExportDecay_pushbutton,'Enable',string)
    set(handles.DeleteDecay_pushbutton,'Enable',string)
    set(handles.ShowDecay_pushbutton,'Enable',string)
    set(handles.ExportPhasor_pushbutton,'Enable',string)
    set(handles.FitDecay_pushbutton,'Enable',string)
    set(handles.SetIRF_pushbutton,'Enable',string)
    set(handles.SetReference_pushbutton,'Enable',string)
    set(handles.ShowImage_pushbutton,'Enable',string)
else strcmp(category,'image')
    set(handles.CloseImage_pushbutton,'Enable',string);
    set(handles.PixelSelection_pushbutton,'Enable',string);
    set(handles.DeselectAll_pushbutton,'Enable',string);
    set(handles.SelectBetween_pushbutton,'Enable',string);
    set(handles.SetActiveRegion_pushbutton,'Enable',string);
    set(handles.RemoveActiveRegion_pushbutton,'Enable',string);
    set(handles.SameActiveRegion_pushbutton,'Enable',string);
    set(handles.SameSelectedPixel_pushbutton,'Enable',string);
    set(handles.KinetochoreSelection_pushbutton,'Enable',string);
    set(handles.MakeMovie_pushbutton,'Enable',string);
    set(handles.SaveSelectedDecays_pushbutton,'Enable',string);
    set(handles.ShowM1_togglebutton,'Enable',string);
    set(handles.ShowM2_togglebutton,'Enable',string);
end