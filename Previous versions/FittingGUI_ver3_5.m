function varargout = FittingGUI_ver3_5(varargin)
% FITTINGGUI_VER3_5 MATLAB code for FittingGUI_ver3_5.fig
%      FITTINGGUI_VER3_5, by itself, creates a new FITTINGGUI_VER3_5 or raises the existing
%      singleton*.
%
%      H = FITTINGGUI_VER3_5 returns the handle to a new FITTINGGUI_VER3_5 or the handle to
%      the existing singleton*.
%
%      FITTINGGUI_VER3_5('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FITTINGGUI_VER3_5.M with the given input arguments.
%
%      FITTINGGUI_VER3_5('Property','Value',...) creates a new FITTINGGUI_VER3_5 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before FittingGUI_ver3_5_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to FittingGUI_ver3_5_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help FittingGUI_ver3_5

% Last Modified by GUIDE v2.5 23-Feb-2014 19:31:59

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @FittingGUI_ver3_5_OpeningFcn, ...
    'gui_OutputFcn',  @FittingGUI_ver3_5_OutputFcn, ...
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


% --- Executes just before FittingGUI_ver3_5 is made visible.
function FittingGUI_ver3_5_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to FittingGUI_ver3_5 (see VARARGIN)

% Choose default command line output for FittingGUI_ver3_5

addpath CONVNFFT_Folder

handles.output = hObject;

load('decay_to_fit.mat');
current_irf = load('currentIRF.mat');
irf = current_irf.decay;
irf = irf/max(irf)*5*1E3;
time = current_irf.time;

NumOfDecays = length(decay_struct);

handles.NumOfDecays = NumOfDecays;
handles.decay_struct = decay_struct;
handles.irf = irf;
handles.irf_handle = [];
handles.time = time;

for i = 1:NumOfDecays
   handles.decay_struct{i}.decay_handle = -99;
   handles.decay_struct{i}.fit_handle = -99;
   handles.decay_struct{i}.residual_handle = -99;
   handles.decay_struct{i}.residual = [];
   
   handles.decay_struct{i}.fit_result = zeros(7,3);
   handles.decay_struct{i}.fit_result(1,1) = 0;
   handles.decay_struct{i}.fit_result(1,3) = 1;
   handles.decay_struct{i}.fit_result(:,4) = [-15;0.7;2;0.01;0.01;0.01;0.3];
   handles.decay_struct{i}.fit_result(:,5) = [15;1;4;1;0.3;1;0.8];
   
   handles.decay_struct{i}.Chi_sq = 0;
   handles.decay_struct{i}.fit_region = [0,0];
   handles.decay_struct{i}.noise_region = [0,0];
   handles.decay_struct{i}.fitting_method = 0;
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
    set(handles.figure1,'CurrentAxes',handles.Decay_axes)
    handles.decay_struct{1}.decay_handle = ...
        semilogy(handles.decay_struct{1}.time,handles.decay_struct{1}.decay,'ro');
    %xlim([0,10])
    decayxlim = xlim;
    ylim([1E-1,inf])
    ylabel('count')
    hold on;
    handles.start_line = line([fit_start_x;fit_start_x],[1;1E3],'Color','g');
    handles.end_line = line([fit_end_x;fit_end_x],[1;1E3],'Color','g');
    handles.noise_line1 = line([noise_region_from;noise_region_from],[1;1E3],'Color','y');
    handles.noise_line2 = line([noise_region_to;noise_region_to],[1;1E3],'Color','y');
end


set(handles.figure1,'CurrentAxes',handles.Residual_axes)
xlim(decayxlim)
ylim([-5,5])
line(decayxlim',[0;0],'Color','k');
hold on
xlabel('time (ns)')

set(handles.figure1,'CurrentAxes',handles.ResidualHist_axes)    
xlim([-5,5])
xlabel('Weighted Residual')
ylabel('Freq')


names = cell(NumOfDecays,1);

for i = 1:NumOfDecays
    names{i} = decay_struct{i}.name;
end

set(handles.Decay_listbox,'String',names,'Value',1)
set(handles.TotalCount_text,'String',num2str(sum(handles.decay_struct{1}.decay),'%10.4e'))
set(handles.FitResult_table,'Data',handles.decay_struct{1}.fit_result);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes FittingGUI_ver3_5 wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = FittingGUI_ver3_5_OutputFcn(hObject, eventdata, handles)
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
decay_struct = handles.decay_struct;
NumOfDecays = handles.NumOfDecays;

if NumOfDecays == 0
    return;
end

decay_handle = -99*ones(NumOfDecays,1);
fit_handle = -99*ones(NumOfDecays,1);
residual_handle = -99*ones(NumOfDecays,1);
for i = 1:NumOfDecays
    decay_handle(i) = decay_struct{i}.decay_handle;
    fit_handle(i) = decay_struct{i}.fit_handle;
    residual_handle(i) = decay_struct{i}.residual_handle;
end
    
set(handles.figure1,'CurrentAxes',handles.Decay_axes)
set(findobj([decay_handle(ishandle(decay_handle));fit_handle(ishandle(fit_handle))],...
    '-depth',0,'Visible','on'),'Visible','off');

set(handles.figure1,'CurrentAxes',handles.Residual_axes)
set(findobj(residual_handle(ishandle(residual_handle)),'-depth',0,'Visible','on'),'Visible','off');

color = hsv(length(selected));

total_count = 0;

for i = 1:length(selected)
    set(handles.figure1,'CurrentAxes',handles.Decay_axes)
    decay = decay_struct{selected(i)}.decay;
    time = decay_struct{selected(i)}.time;
    if ishandle(decay_handle(selected(i)))
        set(decay_handle(selected(i)),'Visible','on','Color',color(i,:))
    else
        decay_handle(selected(i)) = semilogy(time,decay,'o','Color',color(i,:));            
        decay_struct{selected(i)}.decay_handle = decay_handle(selected(i));
    end
    
    if ishandle(fit_handle(selected(i)))
        set(fit_handle(selected(i)),'Visible','on','Color','k')
    elseif isfield(decay_struct{selected(i)},'fitting_method')==0
        decay_struct{selected(i)}.fitting_method = 0;
    elseif decay_struct{selected(i)}.fitting_method ~= 0
        fit_region = decay_struct{selected(i)}.fit_region;
        fit = decay_struct{selected(i)}.fit;
        fit_handle(selected(i)) = semilogy(time(fit_region(1):fit_region(2)),fit,'Color','k');
        decay_struct{selected(i)}.fit_handle = fit_handle(selected(i));
    end
    
    set(handles.figure1,'CurrentAxes',handles.Residual_axes)
    if ishandle(residual_handle(selected(i)))   
        set(residual_handle(selected(i)),'Visible','on')
        residual = decay_struct{selected(i)}.residual;
        set(handles.figure1,'CurrentAxes',handles.ResidualHist_axes)
        hist(residual,-5:5)
    elseif decay_struct{selected(i)}.fitting_method ~= 0
        residual = decay_struct{selected(i)}.residual;
        residual_handle(selected(i)) = plot(time,residual);
        decay_struct{selected(i)}.residual_handle = residual_handle(selected(i));
        
        set(handles.figure1,'CurrentAxes',handles.ResidualHist_axes)
        hist(residual,-5:5)
    end
    
    M = size(decay_struct{selected(i)}.fit_result);
    if prod(M == [7,5])==0
        temp = zeros(7,3);
        temp(1,1) = 5;
        temp(1,3) = 1;
        temp(:,4) = [-15;0.7;2;0.01;0.01;0.01;0.3];
        temp(:,5) = [15;1;4;1;0.3;1;0.8];
        temp(1:M(1),1:M(2)) = decay_struct{selected(i)}.fit_result;
        decay_struct{selected(i)}.fit_result = temp;
    end
    
    total_count = total_count+sum(decay);
end

if length(selected) == 1
    decay_struct{selected}.decay_handle = decay_handle(selected);
    decay_struct{selected}.fit_handle = fit_handle(selected);
    decay_struct{selected}.residual_handle = residual_handle(selected);
end
    
set(handles.TotalCount_text,'String',num2str(total_count,'%10.4e'));

set(handles.FitResult_table,'Data',decay_struct{selected(1)}.fit_result);
set(handles.ChiSquared_text,'String',decay_struct{selected(1)}.Chi_sq);

handles.decay_struct = decay_struct;

guidata(hObject,handles);


% --- Executes on button press in LoadDecays_pushbutton.
function LoadDecays_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to LoadDecays_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[filename,pathname,filterindex] = uigetfile2('*.mat','MultiSelect','on');

if (iscell(filename) == 0) & (filename == 0)
    return;
end

if iscell(filename)
    numfile = length(filename);
else
    numfile = 1;
end
    
selected = get(hObject,'Value');
decay_struct = handles.decay_struct;
NumOfDecays = handles.NumOfDecays;
new_decay_struct = [];

if numfile == 1
    loaded = load([pathname filename]);
    temp = loaded.decay_struct;
    if iscell(temp)
        new_decay_struct = temp;
    else
        new_decay_struct = cell(1,1);
        new_decay_struct{1} = temp;
    end
else
    for i = 1:numfile
        loaded = load([pathname filename{i}]);
        temp = loaded.decay_struct;
        if iscell(temp)
            new_decay_struct = [new_decay_struct;temp];
        else
            new_decay_struct{end+1} = temp;
        end
    end
end

if NumOfDecays == 0 
    name = [];
else
    name = get(handles.Decay_listbox,'String');
end
    
NumNewDecays = length(new_decay_struct);
NumOfDecays = NumOfDecays + NumNewDecays;
newname = cell(NumNewDecays,1);

for i = 1:NumNewDecays
    newname{i} = new_decay_struct{i}.name;
    new_decay_struct{i}.decay_handle = -99;
    new_decay_struct{i}.fit_handle = -99;
    new_decay_struct{i}.residual_handle = -99;
    
    if isfield(new_decay_struct{i},'fitting_method')==0 | ...
            new_decay_struct{i}.fitting_method == 0
        new_decay_struct{i}.residual = [];
        
        new_decay_struct{i}.fit_result = zeros(7,3);
        new_decay_struct{i}.fit_result(1,1) = 5;
        new_decay_struct{i}.fit_result(1,3) = 1;
        new_decay_struct{i}.fit_result(:,4) = [-15;0.7;2;0.01;0.01;0.01;0.3];
        new_decay_struct{i}.fit_result(:,5) = [15;1;4;1;0.3;1;0.8];

        new_decay_struct{i}.Chi_sq = 0;
        new_decay_struct{i}.fit_region = [0,0];
        new_decay_struct{i}.noise_region = [0,0];
        new_decay_struct{i}.fitting_method = 0;
    end
end

new_decay_struct = new_decay_struct(:);
decay_struct = decay_struct(:);
decay_struct = [decay_struct;new_decay_struct];

name = [name;newname];
set(handles.Decay_listbox,'String',name);

handles.decay_struct = decay_struct;
handles.NumOfDecays = NumOfDecays;

guidata(hObject,handles);




% --- Executes on button press in DeleteSelected_pushbutton.
function DeleteSelected_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to DeleteSelected_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
selected = get(handles.Decay_listbox,'Value');
decay_struct = handles.decay_struct;
NumOfDecays = handles.NumOfDecays;

NumOfDecays = NumOfDecays - length(selected);


set(handles.figure1,'CurrentAxes',handles.Decay_axes)
for i = 1:length(selected)
    ds = decay_struct{selected(i)};
    if ishandle(ds.decay_handle)
        delete(ds.decay_handle);
    end
    if ishandle(ds.fit_handle)
        delete(ds.fit_handle);
    end
end

set(handles.figure1,'CurrentAxes',handles.Residual_axes)
for i = 1:length(selected)
    ds = decay_struct{selected(i)};
    if ishandle(ds.residual_handle)
        delete(ds.residual_handle);
    end
end


if NumOfDecays > 0
    decay_struct(selected) = [];
    name = get(handles.Decay_listbox,'String');
    name(selected) = [];
    value = NumOfDecays;
else
    decay_struct = [];
    name = ' ';
    value = 1;
end


set(handles.Decay_listbox,'String',name);
set(handles.Decay_listbox,'Value',value);

handles.decay_struct = decay_struct;
handles.NumOfDecays = NumOfDecays;

guidata(hObject,handles);



% --- Executes on button press in GroupDecay_pushbutton.
function GroupDecay_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to GroupDecay_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
selected = get(handles.Decay_listbox,'Value');
decay_struct = handles.decay_struct;
NumOfDecays = handles.NumOfDecays;

decay_handle = -99*ones(NumOfDecays,1);
fit_handle = -99*ones(NumOfDecays,1);
residual_handle = -99*ones(NumOfDecays,1);
for i = 1:NumOfDecays
    decay_handle(i) = decay_struct{i}.decay_handle;
    fit_handle(i) = decay_struct{i}.fit_handle;
    residual_handle(i) = decay_struct{i}.residual_handle;
end

set(handles.figure1,'CurrentAxes',handles.Decay_axes)
set(findobj([decay_handle(ishandle(decay_handle));fit_handle(ishandle(fit_handle))],'-depth',0,'Visible','on'),'Visible','off');

set(handles.figure1,'CurrentAxes',handles.Residual_axes)
set(findobj(residual_handle(ishandle(residual_handle)),'-depth',0,'Visible','on'),'Visible','off');

decay = zeros(size(decay_struct{selected(1)}.decay));
time = decay_struct{selected(1)}.time;

name = get(handles.GroupName_edit,'String');
if isempty(name);
    for i = selected
        if i == selected(1)
            name = [decay_struct{i}.name];
        else
           name = [name,'+',decay_struct{i}.name];
        end    
    end
end

for i = selected
    decay = decay+decay_struct{i}.decay;
end

grouped_decay.decay = decay;
grouped_decay.name = name;
grouped_decay.time = time;
grouped_decay.fit_handle = -99;
grouped_decay.residual_handle = -99;
grouped_decay.fit_result = zeros(7,3);
grouped_decay.fit_result(1,1) = 5;
grouped_decay.fit_result(1,3) = 1;
grouped_decay.fit_result(:,4) = [-15;0.7;2;0.01;0.01;0.01;0.3];
grouped_decay.fit_result(:,5) = [15;1;4;1;0.3;1;0.8];

grouped_decay.Chi_sq = 0;
grouped_decay.fitting_method = 0;

set(handles.figure1,'CurrentAxes',handles.Decay_axes)
grouped_decay.decay_handle = semilogy(time,decay,'ro');

decay_struct{NumOfDecays+1} = grouped_decay;

decay_names = get(handles.Decay_listbox,'String');
decay_names = [decay_names;name];
set(handles.Decay_listbox,'String',decay_names);

NumOfDecays = NumOfDecays+1;
set(handles.Decay_listbox,'Max',NumOfDecays+2,'Value',NumOfDecays);

set(handles.TotalCount_text,'String',num2str(sum(decay),'%10.4e'));

handles.decay_struct = decay_struct;
handles.NumOfDecays = NumOfDecays;

guidata(hObject,handles)


function FitStart_edit_Callback(hObject, eventdata, handles)
% hObject    handle to FitStart_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of FitStart_edit as text
%        str2double(get(hObject,'String')) returns contents of FitStart_edit as a double

start_line = handles.start_line;

set(handles.figure1,'CurrentAxes',handles.Decay_axes)
XL = xlim;

x = str2num(get(hObject,'String'));

if x<=XL(2) && x>=XL(1) && x<str2num(get(handles.FitEnd_edit,'String'))
    
        set(handles.figure1,'CurrentAxes',handles.Decay_axes)
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

set(handles.figure1,'CurrentAxes',handles.Decay_axes)
XL = xlim;

x = str2num(get(hObject,'String'));

if x<=XL(2) && x>=XL(1) && x>str2num(get(handles.FitStart_edit,'String'))
        set(handles.figure1,'CurrentAxes',handles.Decay_axes)
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

set(handles.figure1,'CurrentAxes',handles.Decay_axes)
XL = xlim;

x = str2num(get(hObject,'String'));

if x<=XL(2) && x>=XL(1) && x<str2num(get(handles.NoiseRegionto_edit,'String'))
        set(handles.figure1,'CurrentAxes',handles.Decay_axes)
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

set(handles.figure1,'CurrentAxes',handles.Decay_axes)
XL = xlim;

x = str2num(get(hObject,'String'));

if x<=XL(2) && x>=XL(1) && x>str2num(get(handles.NoiseRegionfrom_edit,'String'))
        set(handles.figure1,'CurrentAxes',handles.Decay_axes)
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
irf = handles.irf;

%whether or not save the data to Temp Saved Result folder
tempsave = get(handles.TempSave_checkbox,'Value');

decay_to_fit = handles.decay_struct;
NumOfDecays = handles.NumOfDecays;

decay_handle = -99*ones(NumOfDecays,1);
fit_handle = -99*ones(NumOfDecays,1);
residual_handle = -99*ones(NumOfDecays,1);
for i = 1:NumOfDecays
    decay_handle(i) = decay_to_fit{i}.decay_handle;
    fit_handle(i) = decay_to_fit{i}.fit_handle;
    residual_handle(i) = decay_to_fit{i}.residual_handle;
end

%hide previous data
set(handles.figure1,'CurrentAxes',handles.Decay_axes)
set(findobj([decay_handle(ishandle(decay_handle));fit_handle(ishandle(fit_handle))],...
    '-depth',0,'Visible','on'),'Visible','off');
set(handles.figure1,'CurrentAxes',handles.Residual_axes)
set(findobj(residual_handle(ishandle(residual_handle)),'-depth',0,'Visible','on'),'Visible','off')

nexpo = get(handles.NumOfExpo_popupmenu,'Value');

N_param = 2*nexpo+1;

if fitting_method == 1   % Do LS fitting
    for j = selected
        time = decay_to_fit{j}.time;
                
        %parameters needed for fitting
        dt = time(2)-time(1);
        fit_start = round(str2num(get(handles.FitStart_edit,'String'))/dt);
        fit_end = round(str2num(get(handles.FitEnd_edit,'String'))/dt);
        noise_region_from = round(str2num(get(handles.NoiseRegionfrom_edit,'String'))/dt);
        noise_region_to = round(str2num(get(handles.NoiseRegionto_edit,'String'))/dt);
        
        % data to fit
        decay = decay_to_fit{j}.decay;
        counts = sum(decay(fit_start:fit_end));

        
        %weight on residual
        %weight = (fit_end-fit_start+1)/sqrt(decay(fit_start:fit_end)'*decay(fit_start:fit_end));
        nonzero_decay = decay;
        nonzero_decay(decay==0)=1;
        sigy = sqrt(nonzero_decay);
        weight = 1./sigy(fit_start:fit_end);
        
        % rough estimate of noise in noise region
        est_noise = mean(decay(noise_region_from:noise_region_to));
        
        fit_result = decay_to_fit{j}.fit_result;
        % initial guess, lower and upper bounds of parameters
        % P(t|param) (not normalized)
        % if one expo:
        % P = param(2)*exp(-t/param(3))+(1-param(2))
        % param(2): fractional amp of expo decay
        % param(3): lifetime of the first decay
        %
        % if two expo:
        % P = param(2)*param(4)*exp(-t/param(3))+param(2)*(1-param(2))*exp(-t/param(3))+(1-param(2));
        % param(4) : fraction of the first decay
        % param(5) : lifetime of second decay
        %
        % param(1) : shift of decay model from IRF (usually ranges from -10 to 10) 
        p_min = fit_result(1:N_param,4);
        p_max = fit_result(1:N_param,5);

        if nexpo == 1
            p_init = [0,1-est_noise/max(decay),3]';
        elseif nexpo == 2
            p_init = [0,1-est_noise/max(decay),3.5,0.5,0.2]';
        else
            p_init = [0,1-est_noise/max(decay),3,0.5,0.1,0.5,0.6]';
        end

        
        % Parameters to fix
        free= ~fit_result(1:N_param,3);
        
        for i = find(free==0)
            p_init(i) = fit_result(i,1);
            p_max(i) = p_init(i)+1;
            p_min(i) = p_init(i)-1;
        end
        
        dp = zeros(N_param,1);
        dp(2:N_param) = 0.001*free(2:N_param);
        dp(1) = 1*free(1);
        
        tic
        [p_fit,Chi_sq,sigma_p,sigma_y,corr,R2,cvg_hst, converged] = ...
            lm(@lm_decay_model,p_init,time,decay,weight,dp,p_min,p_max,[nexpo,counts,fit_start,fit_end],fit_start,fit_end);
        toc
        
        % show data
        set(handles.figure1,'CurrentAxes',handles.Decay_axes)
        
        if ishandle(decay_handle(j))
            delete(decay_handle(j))
        end
        decay_handle(j) = semilogy(time,decay,'ro');
        decay_to_fit{j}.decay_handle = decay_handle(j);
        hold on
        
        y_hat = lm_decay_model(time,p_fit,[nexpo,counts,fit_start,fit_end]);
        y_hat = y_hat(fit_start:fit_end);
        
        if ishandle(fit_handle(j))
            delete(fit_handle(j))
        end
        fit_handle(j) = semilogy(time(fit_start:fit_end),y_hat,'-k');
        decay_to_fit{j}.fit = y_hat;
        decay_to_fit{j}.fit_handle = fit_handle(j);
        
        y_dat = decay;
        y_dat = y_dat(fit_start:fit_end);
        
        set(handles.figure1,'CurrentAxes',handles.Residual_axes)
        
        if ishandle(residual_handle(j))
            delete(residual_handle(j))
        end
        weighted_residual = weight.*(y_dat-y_hat);
        decay_to_fit{j}.residual = zeros(size(decay));
        decay_to_fit{j}.residual(fit_start:fit_end) = weighted_residual;
        decay_to_fit{j}.residual_handle = plot(time(fit_start:fit_end),weighted_residual);
        
        set(handles.figure1,'CurrentAxes',handles.ResidualHist_axes)
        hist(weighted_residual,-5:5)
        
        fit_result(1:7,1:2) = zeros(7,2);
        fit_result(1:(nexpo*2+1),1) = real(p_fit);
        fit_result(1:(nexpo*2+1),2) = real(sigma_p);
        
        decay_to_fit{j}.fit_result = fit_result;
        decay_to_fit{j}.Chi_sq = Chi_sq;
        decay_to_fit{j}.cvg_hst = cvg_hst;
        
        decay_to_fit{j}.fit_region = [fit_start,fit_end];
        decay_to_fit{j}.noise_region = [noise_region_from,noise_region_to];
        decay_to_fit{j}.fitting_method = fitting_method;
        decay_to_fit{j}.nexpo = nexpo;
        decay_to_fit{j}.converged = converged;

        if tempsave
            S = datestr(now,'yyyymmddTHHMM');
            pathname = ['temp_saved_fit_result/' S]; 
            save_fit_result(pathname,decay_to_fit{j});
        end
            
    end
elseif fitting_method == 3
    matlabpool;    %for parallel computing
    prior = get(handles.Prior_popupmenu,'Value');
    for j = selected
        
        time = decay_to_fit{j}.time;
        
        %parameters needed for fitting
        dt = time(2)-time(1);
        fit_start = round(str2num(get(handles.FitStart_edit,'String'))/dt);
        fit_end = round(str2num(get(handles.FitEnd_edit,'String'))/dt);
        
        % data to fit
        decay = decay_to_fit{j}.decay;
        counts = sum(decay(fit_start:fit_end));
        
        
        %weight on residual
        %weight = (fit_end-fit_start+1)/sqrt(decay(fit_start:fit_end)'*decay(fit_start:fit_end));
        nonzero_decay = decay;
        nonzero_decay(decay==0)=1;
        sigy = sqrt(nonzero_decay);
        weight = 1./sigy(fit_start:fit_end);
        
        
        fit_result = decay_to_fit{j}.fit_result;
        % initial guess, lower and upper bounds of parameters
        % P(t|param) (not normalized)
        % if one expo:
        % P = param(2)*exp(-t/param(3))+(1-param(2))
        % param(2): fractional amp of expo decay
        % param(3): lifetime of the first decay
        %
        % if two expo:
        % P = param(2)*param(4)*exp(-t/param(3))+param(2)*(1-param(4))*exp(-t/(param(5)*param(3)))+(1-param(2));
        % param(4) : fraction of the first decay
        % param(5) : 1-FRET efficiency (short/long lifetime)
        %
        % param(1) : shift of decay model from IRF (usually ranges from -10 to 10) 
        p_min = fit_result(1:N_param,4);
        p_max = fit_result(1:N_param,5);
        
        if nexpo == 1
            dp = [1,0.00025,0.01]';
        elseif nexpo == 2
            dp = [1,0.0025,0.01,0.01,0.01]';
        else
            dp = [1,0.0025,0.02,0.015,0.015,0.015,0.015]';
        end
        
        % Parameters to fix
        fixed = fit_result(1:(2*nexpo+1),3);
        p_min(fixed==1) = fit_result(fixed==1,1);
        p_max(fixed==1) = fit_result(fixed==1,1);
        
        
        tic;
        [p_fit,sigma_p,p_vec,post,marg_post] = bayes_fit(time,decay,dp,p_min,p_max,nexpo,prior,fit_start,fit_end,0,1);
        toc;
     
        
        % show data
        set(handles.figure1,'CurrentAxes',handles.Decay_axes)
        
        if ishandle(decay_handle(j))
            delete(decay_handle(j))
        end
        decay_handle(j) = semilogy(time,decay,'ro');
        decay_to_fit{j}.decay_handle = decay_handle(j);
        hold on
        
        y_hat = lm_decay_model(time,p_fit,[nexpo,counts,fit_start,fit_end]);
        y_hat = y_hat(fit_start:fit_end);
        
        if ishandle(fit_handle(j))
            delete(fit_handle(j))
        end
        fit_handle(j) = semilogy(time(fit_start:fit_end),y_hat,'-k');
        decay_to_fit{j}.fit = y_hat;
        decay_to_fit{j}.fit_handle = fit_handle(j);
        
        y_dat = decay;
        y_dat = y_dat(fit_start:fit_end);
        
        set(handles.figure1,'CurrentAxes',handles.Residual_axes)
        if ishandle(residual_handle(j))
            delete(residual_handle(j))
        end
     
        weighted_residual = weight.*(y_dat-y_hat);    
        
        decay_to_fit{j}.residual = zeros(size(decay));
        decay_to_fit{j}.residual(fit_start:fit_end) = weighted_residual;
        decay_to_fit{j}.residual_handle = plot(time(fit_start:fit_end),weighted_residual);
        
        Chi_sq = sum(weighted_residual.^2)/(fit_end-fit_start-2*nexpo-1+sum(fixed));
        
        set(handles.figure1,'CurrentAxes',handles.ResidualHist_axes)
        hist(weighted_residual,-5:5)
        
        fit_result(1:5,1:2) = zeros(5,2);
        fit_result(1:(nexpo*2+1),1) = real(p_fit);
        fit_result(1:(nexpo*2+1),2) = real(sigma_p);
        
        decay_to_fit{j}.fit_result = fit_result;
        decay_to_fit{j}.Chi_sq = Chi_sq;
        decay_to_fit{j}.marg_post = marg_post;
        decay_to_fit{j}.p_vec = p_vec;
        decay_to_fit{j}.post = post;
        
        decay_to_fit{j}.fit_region = [fit_start,fit_end];
        decay_to_fit{j}.fitting_method = fitting_method;
        decay_to_fit{j}.nexpo = nexpo;
        decay_to_fit{j}.prior = prior;
        
        if tempsave
            S = datestr(now,'yyyymmddTHHMM');
            pathname = ['temp_saved_fit_result/' S];
            save_fit_result(pathname,decay_to_fit{j});
        end
    end
    matlabpool close
end

set(handles.FitResult_table,'Data',fit_result)

set(handles.ChiSquared_text,'String',num2str(Chi_sq))

handles.decay_struct = decay_to_fit;

guidata(hObject,handles);



% --- Executes on button press in ShowFitHistory_pushbutton.
function ShowFitHistory_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to ShowFitHistory_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% ------------ plot convergence history of fit

selected = get(handles.Decay_listbox,'Value');
decay_struct = handles.decay_struct{selected};
fitting_method = decay_struct.fitting_method;
if length(selected)>1
    errordlg('Choose one decay')
    return
end
if fitting_method == 0
   errordlg('Fit first')
   return
end

nexpo = decay_struct.nexpo;

N_param = 2*nexpo+1;

if fitting_method ==1
    figure;
    
    cvg_hst = decay_struct.cvg_hst;
    
    subplot(211)
    plot( 1:length(cvg_hst(:,1)), cvg_hst(:,1:N_param), 'linewidth',4);
    xlabel('iteration number')
    ylabel('parameter values')
    
    subplot(212)
    semilogy( 1:length(cvg_hst(:,1)),[ cvg_hst(:,N_param+1) cvg_hst(:,N_param+2) ], 'linewidth',4)
    legend('\chi^2','\lambda');
    xlabel('iteration number')
    ylabel('\chi^2 and \lambda')
elseif fitting_method ==3
    figure;
    
    p_vec = decay_struct.p_vec;
    marg_post = decay_struct.marg_post;
    post = decay_struct.post;
    
    for i = 1:N_param
        subplot(N_param,1,i)
        plot(p_vec{i},marg_post{i},'linewidth',3);
    end

end


% --- Executes on button press in SaveResult_pushbutton.
function SaveResult_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to SaveResult_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
load('analysisDir.mat');
selected = get(handles.Decay_listbox,'Value');
decay_struct = handles.decay_struct;

pathname = uigetdir(analysisDir,'Choose a folder to save results');
if pathname ~=0
    for i = selected
        save_fit_result(pathname,decay_struct{i});
    end
end




% --- Executes on button press in LoadIRF_pushputton.
function LoadIRF_pushputton_Callback(hObject, eventdata, handles)
% hObject    handle to LoadIRF_pushputton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[name pathname filterindex] = uigetfile('IRF/*.mat');
if name == 0 
    return;
end

loaded_irf = load([pathname name]);
time = loaded_irf.time;
irf = loaded_irf.decay;
decay = irf;
save('currentIRF','decay','time');
irf = irf/max(irf)*1E3;
handles.irf = irf;
handles.time = time;

guidata(hObject,handles);


% --- Executes on button press in ShowIRF_checkbox.
function ShowIRF_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to ShowIRF_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ShowIRF_checkbox
showvalue = get(hObject,'Value');
irf = handles.irf;
time = handles.time;
irf_handle = handles.irf_handle;
set(handles.figure1,'CurrentAxes',handles.Decay_axes);
if showvalue == 1;
    if ishandle(irf_handle)==1
        delete(irf_handle)
    end
    irf_handle = semilogy(time,irf,'g');
else
    if ishandle(irf_handle)==1
        delete(irf_handle)
    end
    irf_handle = [];
end
%ylim([1E-1,inf])

handles.irf_handle = irf_handle;
guidata(hObject,handles)


% --- Executes when entered data in editable cell(s) in FitResult_table.
function FitResult_table_CellEditCallback(hObject, eventdata, handles)
% hObject    handle to FitResult_table (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)
selected = get(handles.Decay_listbox,'Value');
fit_result = get(hObject,'Data');

for i = selected
   handles.decay_struct{i}.fit_result(:,3:end) = fit_result(:,3:end);
   handles.decay_struct{i}.fit_result(:,1) = ...
       fit_result(:,1).*fit_result(:,3)+handles.decay_struct{i}.fit_result(:,1).*(~fit_result(:,3));
end
guidata(hObject,handles)

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


% --- Executes on selection change in Prior_popupmenu.
function Prior_popupmenu_Callback(hObject, eventdata, handles)
% hObject    handle to Prior_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns Prior_popupmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Prior_popupmenu


% --- Executes during object creation, after setting all properties.
function Prior_popupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Prior_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in TempSave_checkbox.
function TempSave_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to TempSave_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of TempSave_checkbox


% --- Executes on button press in SaveToBase_pushbutton.
function SaveToBase_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to SaveToBase_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

name = fieldnames(handles);

[s,ok]=listdlg('PromptString','Choose variables to save to base workspace:',...
    'Name','Variable Selection','SelectionMode','multiple','ListString',name);

if (ok == 0) || isempty(s)
    return
end

for i = s
    assignin('base',name{i},eval(['handles.' name{i}]))
end


% --- Executes during object creation, after setting all properties.
function FitResult_table_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FitResult_table (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
