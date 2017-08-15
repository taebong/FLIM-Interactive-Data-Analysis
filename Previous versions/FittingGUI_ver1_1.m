function varargout = FittingGUI_ver1_1(varargin)
% FITTINGGUI_VER1_1 MATLAB code for FittingGUI_ver1_1.fig
%      FITTINGGUI_VER1_1, by itself, creates a new FITTINGGUI_VER1_1 or raises the existing
%      singleton*.
%
%      H = FITTINGGUI_VER1_1 returns the handle to a new FITTINGGUI_VER1_1 or the handle to
%      the existing singleton*.
%
%      FITTINGGUI_VER1_1('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FITTINGGUI_VER1_1.M with the given input arguments.
%
%      FITTINGGUI_VER1_1('Property','Value',...) creates a new FITTINGGUI_VER1_1 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before FittingGUI_ver1_1_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to FittingGUI_ver1_1_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help FittingGUI_ver1_1

% Last Modified by GUIDE v2.5 05-Mar-2013 15:28:48

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @FittingGUI_ver1_1_OpeningFcn, ...
    'gui_OutputFcn',  @FittingGUI_ver1_1_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before FittingGUI_ver1_1 is made visible.
function FittingGUI_ver1_1_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to FittingGUI_ver1_1 (see VARARGIN)

% Choose default command line output for FittingGUI_ver1_1
handles.output = hObject;

load('decay_to_fit.mat');

NumOfDecays = length(saved_decay);

handles.NumOfDecays = NumOfDecays;
handles.exported_decay = saved_decay;
handles.irf = irf;
handles.start_line = 0;
handles.end_line = 0;

for i = 1:NumOfDecays
   handles.exported_decay{i}.decay_handle = 0;
   handles.exported_decay{i}.fit_handle = 0;
end

set(handles.Decay_listbox,'Min',1)
set(handles.Decay_listbox,'Max',NumOfDecays+2)

names = cell(NumOfDecays,1);

for i = 1:NumOfDecays
    names{i} = saved_decay{i}.name;
end

set(handles.Decay_listbox,'String',names)

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes FittingGUI_ver1_1 wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = FittingGUI_ver1_1_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in ShowDecay_pushbutton.
function ShowDecay_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to ShowDecay_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
selected = get(handles.Decay_listbox,'Value');
decay_to_show = handles.exported_decay;
NumOfDecays = handles.NumOfDecays;

decay_handle = zeros(NumOfDecays,1);
fit_handle = zeros(NumOfDecays,1);
for i = 1:NumOfDecays
    decay_handle(i) = decay_to_show{i}.decay_handle;
    fit_handle(i) = decay_to_show{i}.fit_handle;
end
    
axes(handles.Decay_axes)
set(findobj([decay_handle;fit_handle],'-depth',0,'Visible','on'),'Visible','off');
color = hsv(length(selected));

for i = 1:length(selected)
    decay(:,i) = decay_to_show{selected(i)}.decay;
    time(:,i) = decay_to_show{selected(i)}.time;
    if decay_handle(selected(i)) ~= 0
        delete(decay_handle(selected(i)))
    end
    decay_handle(selected(i)) = semilogy(time(:,i),decay(:,i),'o','Color',color(i,:));
    decay_to_show{selected(i)}.decay_handle = decay_handle(selected(i));
    hold on
    if fit_handle(selected(i)) ~= 0
        set(fit_handle(selected(i)),'Visible','on')
    end
end

xlim([0,time(end,1)])
xlabel('time (ns)')
ylabel('count')

handles.exported_decay = decay_to_show;

guidata(hObject,handles);


% --- Executes on button press in FitStart_pushbutton.
function FitStart_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to FitStart_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

start_line = handles.start_line;

button =1;

axes(handles.Decay_axes)
XL = xlim;
YL = ylim;

x = 1; y = 1;

[x,y,button] = ginput(1);
if button == 1 && x<=XL(2) && x>=XL(1) && y<=YL(2) && y>=XL(1)
    axes(handles.Decay_axes)
    if start_line ~= 0
        delete(start_line)
    end
    start_line = line([x;x],[0,ylim(2)],'Color','y');
    hold on;
    set(handles.FitStart_edit,'String',num2str(x));
end

handles.start_line = start_line;

guidata(hObject,handles)



% --- Executes on button press in FitEnd_pushbutton.
function FitEnd_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to FitEnd_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

end_line = handles.end_line;

button =1;

axes(handles.Decay_axes)
XL = xlim;
YL = ylim;

x = 1; y = 1;

[x,y,button] = ginput(1);
if button == 1 && x<=XL(2) && x>=XL(1) && y<=YL(2) && y>=XL(1)
    axes(handles.Decay_axes)
    if end_line ~= 0
        delete(end_line)
    end
    end_line = line([x;x],[0,ylim(2)],'Color','y');
    hold on;
    set(handles.FitEnd_edit,'String',num2str(x));
end

handles.end_line = end_line;

guidata(hObject,handles)



% --- Executes on button press in Fit_pushbutton.
function Fit_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to Fit_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
selected = get(handles.Decay_listbox,'Value');

if length(selected) > 1
    errdlg('Select a single decay to fit')
else
    decay_to_fit = handles.exported_decay;
    NumOfDecays = handles.NumOfDecays;
    
    decay_handle = zeros(NumOfDecays,1);
    fit_handle = zeros(NumOfDecays,1);
    for i = 1:NumOfDecays
        decay_handle(i) = decay_to_fit{i}.decay_handle;
        fit_handle(i) = decay_to_fit{i}.fit_handle;
    end
    
    % data to fit
    decay = decay_to_fit{selected}.decay;
    time = decay_to_fit{selected}.time;
    time = time';
    
    %parameters needed for fitting
    dt = time(2)-time(1);
    fit_start = round(str2num(get(handles.FitStart_edit,'String'))/dt);
    fit_end = round(str2num(get(handles.FitEnd_edit,'String'))/dt);
    nexpo = get(handles.NumOfExpo_popupmenu,'Value');
    weight = (fit_end-fit_start+1)/sqrt(decay(fit_start:fit_end)'*decay(fit_start:fit_end));
    shift = 1;
    
    consts = [nexpo,shift];
    
    % initial guess, lower and upper bounds of parameters
    if nexpo == 1
        p_init = [max(decay),3,0.1*max(decay)]';
        p_min = [0.5*max(decay),0.05,0]';
        p_max = [1.2*max(decay),5,0.2*max(decay)]';
    elseif nexpo == 2
        p_init = [0.7*max(decay),3,0.1*max(decay),0.3*max(decay),3];
        p_min = [0.4*max(decay),0.05,0,0,0.05]';
        p_max = [1.2*max(decay),5,0.2*max(decay),0.5*max(decay),5]';
    elseif nexpo == 3
        p_init = [0.6*max(decay),3,0.1*max(decay),0.2*max(decay),3,0.2*max(decay),3];
        p_min = [0.4*max(decay),0.05,0,0,0.05,0,0.05]';
        p_max = [1.2*max(decay),5,0.2*max(decay),0.34*max(decay),5,0.34*max(decay),5]';
    end
    
    
    % show data
    axes(handles.Decay_axes)
    set(findobj([decay_handle;fit_handle],'-depth',0,'Visible','on'),'Visible','off');
    
    if decay_handle(selected) ~= 0
        delete(decay_handle(selected))
    end
    decay_handle(selected) = semilogy(time,decay,'ro');
    decay_to_fit{selected}.decay_handle = decay_handle(selected);
    hold on
    
    xlim([0,time(end,1)])
    
    [p_fit,Chi_sq,sigma_p,sigma_y,corr,R2,cvg_hst] = ...
        lm(@single_decay_model,p_init,time,decay,weight,0.001,p_min,p_max,consts,fit_start,fit_end);
    
    y_hat = single_decay_model(time,p_fit,consts);
    y_hat = y_hat(fit_start:fit_end);
    
    if fit_handle(selected) ~= 0
        delete(fit_handle(selected))
    end
    fit_handle(selected) = semilogy(time(fit_start:fit_end),y_hat,'-k');
    decay_to_fit{selected}.fit_handle = fit_handle(selected);
    
    fit_result = zeros(7,2);
    fit_result(1:(nexpo*2+1),1) = p_fit;
    fit_result(1:(nexpo*2+1),2) = sigma_p;
    
    set(handles.FitResult_table,'Data',fit_result)
    decay_to_fit{selected}.fit_result = fit_result;
    
    handles.exported_decay = decay_to_fit;
    
    guidata(hObject,handles);
end



function FitStart_edit_Callback(hObject, eventdata, handles)
% hObject    handle to FitStart_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of FitStart_edit as text
%        str2double(get(hObject,'String')) returns contents of FitStart_edit as a double


% --- Executes during object creation, after setting all properties.
function FitStart_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FitStart_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function FitEnd_edit_Callback(hObject, eventdata, handles)
% hObject    handle to FitEnd_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of FitEnd_edit as text
%        str2double(get(hObject,'String')) returns contents of FitEnd_edit as a double


% --- Executes during object creation, after setting all properties.
function FitEnd_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FitEnd_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in Decay_listbox.
function Decay_listbox_Callback(hObject, eventdata, handles)
% hObject    handle to Decay_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns Decay_listbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Decay_listbox


% --- Executes during object creation, after setting all properties.
function Decay_listbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Decay_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes on button press in ShowIRF_checkbox.
function ShowIRF_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to ShowIRF_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ShowIRF_checkbox



% --- Executes on selection change in NumOfExpo_popupmenu.
function NumOfExpo_popupmenu_Callback(hObject, eventdata, handles)
% hObject    handle to NumOfExpo_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns NumOfExpo_popupmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from NumOfExpo_popupmenu


% --- Executes during object creation, after setting all properties.
function NumOfExpo_popupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to NumOfExpo_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
