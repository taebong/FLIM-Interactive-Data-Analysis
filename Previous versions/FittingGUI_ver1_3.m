function varargout = FittingGUI_ver1_3(varargin)
% FITTINGGUI_VER1_3 MATLAB code for FittingGUI_ver1_3.fig
%      FITTINGGUI_VER1_3, by itself, creates a new FITTINGGUI_VER1_3 or raises the existing
%      singleton*.
%
%      H = FITTINGGUI_VER1_3 returns the handle to a new FITTINGGUI_VER1_3 or the handle to
%      the existing singleton*.
%
%      FITTINGGUI_VER1_3('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FITTINGGUI_VER1_3.M with the given input arguments.
%
%      FITTINGGUI_VER1_3('Property','Value',...) creates a new FITTINGGUI_VER1_3 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before FittingGUI_ver1_3_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to FittingGUI_ver1_3_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help FittingGUI_ver1_3

% Last Modified by GUIDE v2.5 06-Mar-2013 18:46:21

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @FittingGUI_ver1_3_OpeningFcn, ...
    'gui_OutputFcn',  @FittingGUI_ver1_3_OutputFcn, ...
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


% --- Executes just before FittingGUI_ver1_3 is made visible.
function FittingGUI_ver1_3_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to FittingGUI_ver1_3 (see VARARGIN)

% Choose default command line output for FittingGUI_ver1_3
handles.output = hObject;

load('decay_to_fit.mat');

NumOfDecays = length(saved_decay);

handles.NumOfDecays = NumOfDecays;
handles.exported_decay = saved_decay;
handles.irf = irf;


for i = 1:NumOfDecays
   handles.exported_decay{i}.decay_handle = 0;
   handles.exported_decay{i}.fit_handle = 0;
   handles.exported_decay{i}.residual_handle = 0;
   handles.exported_decay{i}.residual = [];
   handles.exported_decay{i}.fit_result = zeros(7,3);
   handles.exported_decay{i}.Chi_sq = 0;
   handles.exported_decay{i}.fit_region = [0,0];
   handles.exported_decay{i}.noise_region = [0,0];
   handles.exported_decay{i}.fitting_method = 0;
end


fit_start_x = str2num(get(handles.FitStart_edit,'String'));
fit_end_x = str2num(get(handles.FitEnd_edit,'String'));
noise_region_from = str2num(get(handles.NoiseRegionfrom_edit,'String'));
noise_region_to = str2num(get(handles.NoiseRegionto_edit,'String'));

if fit_start_x>fit_end_x
    errordlg('Fit Start should be less than Fit End')
elseif noise_region_from>noise_region_to
    errordlg('Invalid noise region: noise-region-from value should be less than noise-region-to value')
else
    axes(handles.Decay_axes)
    xlim([0,10])
    ylabel('count')
    handles.exported_decay{1}.decay_handle = ...
        semilogy(handles.exported_decay{1}.time',handles.exported_decay{1}.decay,'ro');
    hold on;
    handles.start_line = line([fit_start_x;fit_start_x],[1;10^3],'Color','g');
    handles.end_line = line([fit_end_x;fit_end_x],[1;10^3],'Color','g');
    handles.noise_line1 = line([noise_region_from;noise_region_from],[1;10^3],'Color','y');
    handles.noise_line2 = line([noise_region_to;noise_region_to],[1;10^3],'Color','y');
end


axes(handles.Residual_axes)
xlim([0,10])
ylim([-5,5])
line([0;10],[0;0],'Color','k');
hold on
xlabel('time (ns)')

axes(handles.ResidualHist_axes)    
xlim([-5,5])
xlabel('Weighted Residual')
ylabel('Freq')

set(handles.Decay_listbox,'Min',1)
set(handles.Decay_listbox,'Max',NumOfDecays+2)

names = cell(NumOfDecays,1);

for i = 1:NumOfDecays
    names{i} = saved_decay{i}.name;
end

set(handles.Decay_listbox,'String',names,'Value',1)
set(handles.TotalCount_text,'String',num2str(sum(handles.exported_decay{1}.decay)))
set(handles.FitResult_table,'Data',zeros(7,3));

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes FittingGUI_ver1_3 wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = FittingGUI_ver1_3_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



% --- Executes on selection change in Decay_listbox.
function Decay_listbox_Callback(hObject, eventdata, handles)
% hObject    handle to Decay_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns Decay_listbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Decay_listbox
selected = get(hObject,'Value');
decay_to_show = handles.exported_decay;
NumOfDecays = handles.NumOfDecays;

decay_handle = zeros(NumOfDecays,1);
fit_handle = zeros(NumOfDecays,1);
residual_handle = zeros(NumOfDecays,1);
for i = 1:NumOfDecays
    decay_handle(i) = decay_to_show{i}.decay_handle;
    fit_handle(i) = decay_to_show{i}.fit_handle;
    residual_handle(i) = decay_to_show{i}.residual_handle;
end
    
axes(handles.Decay_axes)
set(findobj([decay_handle;fit_handle],'-depth',0,'Visible','on'),'Visible','off');

axes(handles.Residual_axes)
set(findobj(residual_handle,'-depth',0,'Visible','on'),'Visible','off');

color = hsv(length(selected));

for i = 1:length(selected)
    axes(handles.Decay_axes)
    decay(:,i) = decay_to_show{selected(i)}.decay;
    time(:,i) = decay_to_show{selected(i)}.time;
    if decay_handle(selected(i)) ~= 0
        delete(decay_handle(selected(i)))
    end
    decay_handle(selected(i)) = semilogy(time(:,i),decay(:,i),'o','Color',color(i,:));
    decay_to_show{selected(i)}.decay_handle = decay_handle(selected(i));
    if fit_handle(selected(i)) ~= 0
        set(fit_handle(selected(i)),'Visible','on')
    end
    
    axes(handles.Residual_axes)
    if residual_handle(selected(i)) ~= 0
        set(residual_handle(selected(i)),'Visible','on')
    end
end

set(handles.TotalCount_text,'String',sum(sum(decay(:,1))));
set(handles.FitResult_table,'Data',decay_to_show{selected(1)}.fit_result);
set(handles.ChiSquared_text,'String',decay_to_show{selected(1)}.Chi_sq);

handles.exported_decay = decay_to_show;

guidata(hObject,handles);



% --- Executes on button press in GroupDecay_pushbutton.
function GroupDecay_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to GroupDecay_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
selected = get(handles.Decay_listbox,'Value');
exported_decay = handles.exported_decay;
NumOfDecays = handles.NumOfDecays;

decay_handle = zeros(NumOfDecays,1);
fit_handle = zeros(NumOfDecays,1);
residual_handle = zeros(NumOfDecays,1);
for i = 1:NumOfDecays
    decay_handle(i) = exported_decay{i}.decay_handle;
    fit_handle(i) = exported_decay{i}.fit_handle;
    residual_handle(i) = exported_decay{i}.residual_handle;
end

axes(handles.Decay_axes)
set(findobj([decay_handle(decay_handle~=0);fit_handle(fit_handle~=0)],'-depth',0,'Visible','on'),'Visible','off');

axes(handles.Residual_axes)
set(findobj(residual_handle(residual_handle~=0),'-depth',0,'Visible','on'),'Visible','off');

decay = zeros(size(exported_decay{selected(1)}.decay));
time = exported_decay{selected(1)}.time;

name = get(handles.GroupName_edit,'String');
if isempty(name);
    for i = selected
        if i == selected(1)
            name = [exported_decay{i}.name];
        else
           name = [name,'+',exported_decay{i}.name];
        end    
    end
end

for i = selected
    decay = decay+exported_decay{i}.decay;
end

grouped_decay.decay = decay;
grouped_decay.name = name;
grouped_decay.time = time;
grouped_decay.fit_handle = 0;
grouped_decay.residual_handle = 0;
grouped_decay.fit_result = zeros(7,3);
grouped_decay.Chi_sq = 0;

axes(handles.Decay_axes)
grouped_decay.decay_handle = semilogy(time,decay,'ro');

exported_decay{NumOfDecays+1} = grouped_decay;

decay_names = get(handles.Decay_listbox,'String');
decay_names = [decay_names;name];
set(handles.Decay_listbox,'String',decay_names);

NumOfDecays = NumOfDecays+1;
set(handles.Decay_listbox,'Max',NumOfDecays+2,'Value',NumOfDecays);

set(handles.TotalCount_text,'String',sum(decay));

handles.exported_decay = exported_decay;
handles.NumOfDecays = NumOfDecays;

guidata(hObject,handles)


function FitStart_edit_Callback(hObject, eventdata, handles)
% hObject    handle to FitStart_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of FitStart_edit as text
%        str2double(get(hObject,'String')) returns contents of FitStart_edit as a double

start_line = handles.start_line;

axes(handles.Decay_axes)
XL = xlim;

x = str2num(get(hObject,'String'));

if x<=XL(2) && x>=XL(1) && x<str2num(get(handles.FitEnd_edit,'String'))
    
        axes(handles.Decay_axes)
        if start_line ~= 0
            delete(start_line)
        end
        start_line = line([x;x],[1;10^3],'Color','g');
        hold on;
elseif x>str2num(get(handles.FitEnd_edit,'String'))
    errordlg('Fit End should be greater than Fit Start')
else
    errordlg('Fit Start should be contained in the time range')
end

handles.start_line = start_line;

guidata(hObject,handles)



function FitEnd_edit_Callback(hObject, eventdata, handles)
% hObject    handle to FitEnd_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of FitEnd_edit as text
%        str2double(get(hObject,'String')) returns contents of FitEnd_edit as a double
end_line = handles.end_line;

axes(handles.Decay_axes)
XL = xlim;

x = str2num(get(hObject,'String'));

if x<=XL(2) && x>=XL(1) && x>str2num(get(handles.FitStart_edit,'String'))
        axes(handles.Decay_axes)
        if end_line ~= 0
            delete(end_line)
        end
        end_line = line([x;x],[1;10^3],'Color','g');
        hold on;
elseif x<str2num(get(handles.FitStart_edit,'String'))
    errordlg('Fit End should be greater than Fit Start')
else
    errordlg('Fit End should be contained in the time range')
end

handles.end_line = end_line;

guidata(hObject,handles)




function NoiseRegionfrom_edit_Callback(hObject, eventdata, handles)
% hObject    handle to NoiseRegionfrom_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of NoiseRegionfrom_edit as text
%        str2double(get(hObject,'String')) returns contents of NoiseRegionfrom_edit as a double
noise_line1 = handles.noise_line1;

axes(handles.Decay_axes)
XL = xlim;

x = str2num(get(hObject,'String'));

if x<=XL(2) && x>=XL(1) && x<str2num(get(handles.NoiseRegionto_edit,'String'))
        axes(handles.Decay_axes)
        if noise_line1 ~= 0
            delete(noise_line1)
        end
        noise_line1 = line([x;x],[1;10^3],'Color','y');
        hold on;
elseif x>str2num(get(handles.NoiseRegionto_edit,'String'))
    errordlg('Noise-region-to value should be greater than noise-region_from value')
else
    errordlg('Noise_region should be contained in the time range')
end

handles.noise_line1 = noise_line1;

guidata(hObject,handles)



function NoiseRegionto_edit_Callback(hObject, eventdata, handles)
% hObject    handle to NoiseRegionto_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of NoiseRegionto_edit as text
%        str2double(get(hObject,'String')) returns contents of NoiseRegionto_edit as a double
noise_line2 = handles.noise_line2;

axes(handles.Decay_axes)
XL = xlim;

x = str2num(get(hObject,'String'));

if x<=XL(2) && x>=XL(1) && x>str2num(get(handles.NoiseRegionfrom_edit,'String'))
        axes(handles.Decay_axes)
        if noise_line2 ~= 0
            delete(noise_line2)
        end
        noise_line2 = line([x;x],[1;10^3],'Color','y');
        hold on;
elseif x<str2num(get(handles.NoiseRegionfrom_edit,'String'))
    errordlg('Noise-region-to value should be greater than noise-region_from value')
else
    errordlg('Noise_region should be contained in the time range')
end

handles.noise_line2 = noise_line2;

guidata(hObject,handles)



% --- Executes on button press in Fit_pushbutton.
function Fit_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to Fit_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
selected = get(handles.Decay_listbox,'Value');
fitting_method = get(handles.FittingMethod_popupmenu,'Value');

if length(selected) > 1
    errordlg('Select a single decay to fit','Fit Error')
elseif fitting_method == 1   % Do LS fitting
    decay_to_fit = handles.exported_decay;
    NumOfDecays = handles.NumOfDecays;
    
    decay_handle = zeros(NumOfDecays,1);
    fit_handle = zeros(NumOfDecays,1);
    residual_handle = zeros(NumOfDecays,1);
    for i = 1:NumOfDecays
        decay_handle(i) = decay_to_fit{i}.decay_handle;
        fit_handle(i) = decay_to_fit{i}.fit_handle;
        residual_handle(i) = decay_to_fit{i}.residual_handle;
    end
    
    %hide previous data
    axes(handles.Decay_axes)
    set(findobj([decay_handle;fit_handle],'-depth',0,'Visible','on'),'Visible','off');
    axes(handles.Residual_axes)
    set(findobj(residual_handle,'-depth',0,'Visible','on'),'Visible','off')
    
    % data to fit
    decay = decay_to_fit{selected}.decay;
    time = decay_to_fit{selected}.time;
    time = time';
    
    %parameters needed for fitting
    dt = time(2)-time(1);
    fit_start = round(str2num(get(handles.FitStart_edit,'String'))/dt);
    fit_end = round(str2num(get(handles.FitEnd_edit,'String'))/dt);
    noise_region_from = round(str2num(get(handles.NoiseRegionfrom_edit,'String'))/dt);
    noise_region_to = round(str2num(get(handles.NoiseRegionto_edit,'String'))/dt);
    nexpo = get(handles.NumOfExpo_popupmenu,'Value');
    shift = 1;
    
    %weight on residual
    %weight = (fit_end-fit_start+1)/sqrt(decay(fit_start:fit_end)'*decay(fit_start:fit_end));
    nonzero_decay = decay;
    nonzero_decay(find(decay==0))=1;
    sigy = sqrt(nonzero_decay);
    weight = 1./sigy(fit_start:fit_end);
    
    consts = [nexpo,shift];
    
    % rough estimate of noise in noise region
    est_noise = mean(decay(noise_region_from:noise_region_to));
    
    % initial guess, lower and upper bounds of parameters
    if nexpo == 1
        p_init = [max(decay),3,est_noise]';
        p_min = [0.5*max(decay),0.05,0.01]';
        p_max = [1.2*max(decay),5,1.5*est_noise+5]';
    elseif nexpo == 2
        p_init = [0.7*max(decay),3,est_noise,0.3*max(decay),3];
        p_min = [0.5*max(decay),0.05,0.01,1,0.05]';
        p_max = [1.2*max(decay),5,1.5*est_noise+5,0.5*max(decay),5]';
    elseif nexpo == 3
        p_init = [0.6*max(decay),3,est_noise,0.2*max(decay),3,0.2*max(decay),3];
        p_min = [0.34*max(decay),0.05,0,0,0.05,0,0.05]';
        p_max = [1.2*max(decay),5,1.5*est_noise+5,0.34*max(decay),5,0.34*max(decay),5]';
    end
    
    % Parameters to fix
    fit_result = get(handles.FitResult_table,'Data');
    free = ~fit_result(1:(2*nexpo+1),3);
    
    for i = find(free==0)
        p_init(i) = fit_result(i,1);
        p_max(i) = p_init(i)+1;
        p_min(i) = p_init(i)-1;
    end
    
    % show data
    axes(handles.Decay_axes)
    
    if decay_handle(selected) ~= 0
        delete(decay_handle(selected))
    end
    decay_handle(selected) = semilogy(time,decay,'ro');
    decay_to_fit{selected}.decay_handle = decay_handle(selected);
    hold on
    
    [p_fit,Chi_sq,sigma_p,sigma_y,corr,R2,cvg_hst] = ...
        lm(@single_decay_model,p_init,time,decay,weight,0.001*free,p_min,p_max,consts,fit_start,fit_end);
    
    y_hat = single_decay_model(time,p_fit,consts);
    y_hat = y_hat(fit_start:fit_end);
    
    if fit_handle(selected) ~= 0
        delete(fit_handle(selected))
    end
    fit_handle(selected) = semilogy(time(fit_start:fit_end),y_hat,'-k');
    decay_to_fit{selected}.fit = y_hat;
    decay_to_fit{selected}.fit_handle = fit_handle(selected);
    
    axes(handles.Residual_axes)
    weighted_residual = weight.*(decay(fit_start:fit_end)-y_hat);
    decay_to_fit{selected}.residual = zeros(size(decay)); 
    decay_to_fit{selected}.residual(fit_start:fit_end) = weighted_residual;
    decay_to_fit{selected}.residual_handle = plot(time(fit_start:fit_end),weighted_residual);
    
    axes(handles.ResidualHist_axes)
    hist(weighted_residual,-5:5)
    
    fit_result(1:(nexpo*2+1),1) = real(p_fit);
    fit_result(1:(nexpo*2+1),2) = real(sigma_p);
    
    set(handles.FitResult_table,'Data',fit_result)
    decay_to_fit{selected}.fit_result = fit_result;
    decay_to_fit{selected}.Chi_sq = Chi_sq;
    
    decay_to_fit{selected}.fit_region = [fit_start,fit_end];
    decay_to_fit{selected}.noise_region = [noise_region_from,noise_region_to];
    decay_to_fit{selected}.fitting_method = fitting_method;
    
    set(handles.ChiSquared_text,'String',num2str(Chi_sq))
    
    handles.exported_decay = decay_to_fit;
    
    guidata(hObject,handles);
end




% --- Executes on button press in SaveResult_pushbutton.
function SaveResult_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to SaveResult_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
load('lastUsedDir.mat');
selected = get(handles.Decay_listbox,'Value');
exported_decay = handles.exported_decay;

pathname = uigetdir(lastUsedDir,'Choose a folder to save results');
if pathname ~=0
    for i = selected
        fitting_method = exported_decay{i}.fitting_method;
        
        if fitting_method == 0
            errordlg('Fit before save result');
        else
            if fitting_method == 1
                method = 'LS';
            elseif fitting_method == 2
                method = 'MLE';
            else
                method = 'Bayes';
            end
            
            name = exported_decay{i}.name;
            time = exported_decay{i}.time;
            decay = exported_decay{i}.decay;
            fit_region = exported_decay{i}.fit_region;
            fit = exported_decay{i}.fit;
            residual = exported_decay{i}.residual;
            fit_result =  exported_decay{i}.fit_result;
            Chi_sq = exported_decay{i}.Chi_sq;
            
            h(1) = figure;
            subplot(4,1,(1:3)');
            semilogy(time,decay,'ro')
            hold on;
            semilogy(time(fit_region(1):fit_region(2)),fit,'k');
            xlim([time(1),time(end)]);
            ylabel('count')
            legend('Decay',[method, ' Fit'])
            
            subplot(4,1,4);
            plot(time,residual);
            xlim([time(1),time(end)]);
            ylim([-5,5]);
            xlabel('time (ns)');
     
            saveas(h(1),[pathname, '/', date, '_' name, '_', method, '_Fit.fig'])            
            close(h(1));
            
            
            h(2) = figure;
            hist(residual,-5:5)
            xlabel('Weighted Residual')
            ylabel('Freq')
            
            saveas(h(2),[pathname, '/', date, '_', name, '_', method, '_Fit_Residual.fig'])
            close(h(2))
            
            p_result = cell(8,4);
            p_result(2:8,1) = {'A1';'tau1';'C';'A2';'tau2';'A3';'tau3'};
            p_result(1,2:4) = {'Fit','sigma','Fix'};
            
            p_result(2:8,2:4) = num2cell(fit_result);
            xlswrite([pathname, '/', date, '_', method, '_Fit_Result.xls'],p_result,name,'B2');
            
            p_otherinfo = {'Total Count',sum(decay);'Reduced Chi-Sq',Chi_sq};
            xlswrite([pathname, '/', date, '_', method, '_Fit_Result.xls'],p_otherinfo,name,'G3');
            
        end
    end
end    



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



% --- Executes during object creation, after setting all properties.
function NoiseRegionfrom_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to NoiseRegionfrom_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes during object creation, after setting all properties.
function NoiseRegionto_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to NoiseRegionto_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function text13_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on selection change in FittingMethod_popupmenu.
function FittingMethod_popupmenu_Callback(hObject, eventdata, handles)
% hObject    handle to FittingMethod_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns FittingMethod_popupmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from FittingMethod_popupmenu


% --- Executes during object creation, after setting all properties.
function FittingMethod_popupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FittingMethod_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function GroupName_edit_Callback(hObject, eventdata, handles)
% hObject    handle to GroupName_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of GroupName_edit as text
%        str2double(get(hObject,'String')) returns contents of GroupName_edit as a double


% --- Executes during object creation, after setting all properties.
function GroupName_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to GroupName_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

