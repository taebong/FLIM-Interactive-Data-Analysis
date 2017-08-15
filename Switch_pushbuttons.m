function Switch_pushbuttons(handles,string,category)
% Change 'Enable' property of the pushbuttons dealing with images or decays

if strcmp(category,'decay')
    h = get(handles.DecayPanel,'Children');

%     set(handles.ExportDecay_pushbutton,'Enable',string)
%     set(handles.DeleteDecay_pushbutton,'Enable',string)
%     set(handles.ShowDecay_pushbutton,'Enable',string)
%     set(handles.ExportPhasor_pushbutton,'Enable',string)
%     set(handles.FitDecay_pushbutton,'Enable',string)
%     set(handles.SetIRF_pushbutton,'Enable',string)
%     set(handles.SetReference_pushbutton,'Enable',string)
%     set(handles.ShowImage_pushbutton,'Enable',string)
else strcmp(category,'image')
    h1 = get(handles.DataSelectionPanel,'Children');
    h2 = get(handles.BatchAnalysisPanel,'Children');
    h3 = [handles.CloseImage_pushbutton;handles.MakeMovie_pushbutton;handles.SaveSession_pushbutton];
    h4 = [handles.ShowM1_togglebutton;handles.ShowM2_togglebutton];
    h = [h1;h2;h3;h4];
    
%     set(handles.CloseImage_pushbutton,'Enable',string);
%     set(handles.PixelSelection_pushbutton,'Enable',string);
%     set(handles.DeselectAll_pushbutton,'Enable',string);
%     set(handles.SelectBetween_pushbutton,'Enable',string);
%     set(handles.SetActiveRegion_pushbutton,'Enable',string);
%     set(handles.RemoveActiveRegion_pushbutton,'Enable',string);
%     set(handles.SameActiveRegion_pushbutton,'Enable',string);
%     set(handles.SameSelectedPixel_pushbutton,'Enable',string);
%     set(handles.KinetochoreSelection_pushbutton,'Enable',string);
%     set(handles.MakeMovie_pushbutton,'Enable',string);
%     set(handles.SaveSelectedDecays_pushbutton,'Enable',string);
%     set(handles.ShowM1_togglebutton,'Enable',string);
%     set(handles.ShowM2_togglebutton,'Enable',string);
end

set(h,'Enable',string);
set(handles.DecayName_edit,'Enable','on');
set(handles.SaveDecay_pushbutton,'Enable','on');