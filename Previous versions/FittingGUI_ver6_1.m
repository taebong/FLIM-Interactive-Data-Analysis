function varargout = FittingGUI_ver6_1(varargin)
% FITTINGGUI_VER6_1 MATLAB code for FittingGUI_ver6_1.fig
%      FITTINGGUI_VER6_1, by itself, creates a new FITTINGGUI_VER6_1 or raises the existing
%      singleton*.
%
%      H = FITTINGGUI_VER6_1 returns the handle to a new FITTINGGUI_VER6_1 or the handle to
%      the existing singleton*.
%
%      FITTINGGUI_VER6_1('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FITTINGGUI_VER6_1.M with the given input arguments.
%
%      FITTINGGUI_VER6_1('Property','Value',...) creates a new FITTINGGUI_VER6_1 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before FittingGUI_ver6_1_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to FittingGUI_ver6_1_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help FittingGUI_ver6_1

% Last Modified by GUIDE v2.5 19-Feb-2015 16:33:30

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @FittingGUI_ver6_1_OpeningFcn, ...
    'gui_OutputFcn',  @FittingGUI_ver6_1_OutputFcn, ...
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


% --- Executes just before FittingGUI_ver6_1 is made visible.
function FittingGUI_ver6_1_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to FittingGUI_ver6_1 (see VARARGIN)

% Choose default command line output for FittingGUI_ver6_1

addpath CONVNFFT_Folder

set(0,'CurrentFigure',handles.FittingGui);

handles.output = hObject;
load('FitResultTemplate.mat');
handles.FitResultTemplate = FitResultTemplate;

if isfield(handles,'NumOfDecays') == 1
    NumOfDecays = handles.NumOfDecays;
else
    NumOfDecays = 0;
end

if isfield(handles,'decay_struct') == 1
    decay_struct = handles.decay_struct;
else
    decay_struct = [];
end

mainGuiInput = find(strcmp(varargin, 'inputdecaystruct'));
guiOpenMode = find(strcmp(varargin,'mode'));
if (isempty(mainGuiInput)) ...
        || (length(varargin) <= mainGuiInput)
    new_decay_struct = [];

    NewNumOfDecays = 0;
    mode = 'New';
else
    % Remember the handle, and adjust our position
    new_decay_struct = varargin{mainGuiInput+1};
    mode = varargin{guiOpenMode+1};
    
    NewNumOfDecays = length(new_decay_struct);
    
    for i = 1:NewNumOfDecays
        new_decay_struct{i} = DecayStructInitializer(new_decay_struct{i});
    end
    
    NumOfDecays = NumOfDecays + NewNumOfDecays;
    decay_struct = [decay_struct;new_decay_struct];
end
set(handles.FittingGui,'CurrentAxes',handles.Decay_axes)
set(gca,'YScale','log')

if strcmp(mode,'New')
    % decayxlim = xlim;
    ylim([1E-1,inf])
    ylabel('count')
    hold on;
    
    fit_start_x = str2double(get(handles.FitStart_edit,'String'));
    fit_end_x = str2double(get(handles.FitEnd_edit,'String'));
    noise_region_from = str2double(get(handles.NoiseRegionfrom_edit,'String'));
    noise_region_to = str2double(get(handles.NoiseRegionto_edit,'String'));
    
    handles.start_line = line([fit_start_x;fit_start_x],[1;1E3],'Color','g');
    handles.end_line = line([fit_end_x;fit_end_x],[1;1E3],'Color','g');
    handles.noise_line1 = line([noise_region_from;noise_region_from],[1;1E3],'Color','y');
    handles.noise_line2 = line([noise_region_to;noise_region_to],[1;1E3],'Color','y');
    
    
    set(handles.FittingGui,'CurrentAxes',handles.Residual_axes)
    % xlim(decayxlim)
    ylim([-6,6])
    line([0;15],[0;0],'Color','k');
    hold on
    xlabel('time (ns)')
    
    set(handles.FittingGui,'CurrentAxes',handles.ResidualHist_axes)
    xlim([-6,6])
    xlabel('Weighted Residual')
    ylabel('Freq')
    
    if ~isempty(decay_struct)
        set(handles.TotalCount_text,'String',num2str(sum(decay_struct{1}.decay),'%10.4e'))
        set(handles.FitResult_table,'Data',decay_struct{1}.fit_result);
    end
    
    fitvar = get(handles.FitVar_popupmenu,'Value');
    nexpo = get(handles.NumOfExpo_popupmenu,'Value');
    
    if nexpo == 1
        txt = '1expo: A*f*exp(-t/tau1)+(1-A)';
    elseif nexpo == 2
        if fitvar == 1
            txt = '2expo: A*f*exp(-t/tau1)+A*(1-f)*exp(-t/(tau1*E))+(1-A)';
        elseif fitvar == 2
            txt = '2expo: A*f*exp(-t/tau1)+A*(1-f)*exp(-t/tau2)+(1-A)';
        end
    elseif nexpo == 3
        txt = '3expo: A*f*exp(-t/tau1)+A*(1-f)*f2*exp(-t/(tau1*E))+A*(1-f)*(1-f2).*exp(-t/(tau1*E2))+(1-A)';
    end
    
    set(handles.FitModel_text,'String',txt);
end

if NumOfDecays == 0
    names = cell(1,1);
    names{1} = ' ';
else
    newnames = cell(NewNumOfDecays,1);
    names = get(handles.Decay_listbox,'String');
    
    for i = 1:NewNumOfDecays
        newnames{i} = new_decay_struct{i}.name;
    end
    
    if strcmp(mode,'New')
        names = newnames;
    else
        names = [names;newnames];
    end
end
set(handles.Decay_listbox,'String',names,'Value',1)

handles.decay_struct = decay_struct;
handles.NumOfDecays = NumOfDecays;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes FittingGUI_ver6_1 wait for user response (see UIRESUME)
% uiwait(handles.FittingGui);


% --- Outputs from this function are returned to the command line.
function varargout = FittingGUI_ver6_1_OutputFcn(hObject, eventdata, handles)
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
showvalue = get(handles.ShowIRF_checkbox,'Value');
noirf = 0;

if NumOfDecays == 0
    return;
end

decay_handle = -99*ones(NumOfDecays,1);
fit_handle = -99*ones(NumOfDecays,1);
residual_handle = -99*ones(NumOfDecays,1);
irf_handle = -99*ones(NumOfDecays,1);
for i = 1:NumOfDecays
    decay_handle(i) = decay_struct{i}.decay_handle;
    fit_handle(i) = decay_struct{i}.fit_handle;
    residual_handle(i) = decay_struct{i}.residual_handle;
     if isfield(decay_struct{i},'irf') ...
        irf_handle(i) = decay_struct{i}.irf_handle;
    end
end
    
set(handles.FittingGui,'CurrentAxes',handles.Decay_axes)
set(findobj([decay_handle(ishandle(decay_handle));...
    fit_handle(ishandle(fit_handle));irf_handle(ishandle(irf_handle))],...
    '-depth',0,'Visible','on'),'Visible','off');

set(handles.FittingGui,'CurrentAxes',handles.Residual_axes)
set(findobj(residual_handle(ishandle(residual_handle)),'-depth',0,'Visible','on'),'Visible','off');

color = hsv(length(selected));

total_count = 0;

for i = 1:length(selected)
    set(handles.FittingGui,'CurrentAxes',handles.Decay_axes)
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
    XL = xlim;
    
    set(handles.FittingGui,'CurrentAxes',handles.Residual_axes)
    xlim(XL);
    if ishandle(residual_handle(selected(i)))   
        set(residual_handle(selected(i)),'Visible','on')
        residual = decay_struct{selected(i)}.residual;
        set(handles.FittingGui,'CurrentAxes',handles.ResidualHist_axes)
        histogram(residual,-6:6)
    elseif decay_struct{selected(i)}.fitting_method ~= 0
        residual = decay_struct{selected(i)}.residual;
        residual_handle(selected(i)) = plot(time,residual,'r');
        decay_struct{selected(i)}.residual_handle = residual_handle(selected(i));
        
        set(handles.FittingGui,'CurrentAxes',handles.ResidualHist_axes)
        histogram(residual,-6:6)
    end
    
    M = size(decay_struct{selected(i)}.fit_result);
    if prod(M == [7,5])==0
        temp = handles.FitResultTemplate;
        temp(1:M(1),1:M(2)) = decay_struct{selected(i)}.fit_result;
        decay_struct{selected(i)}.fit_result = temp;
    end
    
    total_count = total_count+sum(decay);
    
    if isfield(decay_struct{selected(i)},'irf')==0 ...
            || isempty(decay_struct{selected(i)}.irf)
        noirf = 1;
    end
end

if length(selected) == 1
    decay_struct{selected}.decay_handle = decay_handle(selected);
    decay_struct{selected}.fit_handle = fit_handle(selected);
    decay_struct{selected}.residual_handle = residual_handle(selected);
end
    
set(handles.TotalCount_text,'String',num2str(total_count,'%10.4e'));

if noirf
    set(handles.NoIRF_text,'Visible','on');
else
    set(handles.NoIRF_text,'Visible','off');
end

if showvalue == 1
    if isfield(decay_struct{selected(1)},'irf') ...
            && isempty(decay_struct{selected(1)}.irf)==0 ...
            && ishandle(decay_struct{selected(1)}.irf_handle)
        set(decay_struct{selected(1)}.irf_handle,'Visible','on');
    end
end


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
        
        new_decay_struct{i}.fit_result = handles.FitResultTemplate;

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


set(handles.FittingGui,'CurrentAxes',handles.Decay_axes)
for i = 1:length(selected)
    ds = decay_struct{selected(i)};
    if ishandle(ds.decay_handle)
        delete(ds.decay_handle);
    end
    if ishandle(ds.fit_handle)
        delete(ds.fit_handle);
    end
end

set(handles.FittingGui,'CurrentAxes',handles.Residual_axes)
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

set(handles.FittingGui,'CurrentAxes',handles.Decay_axes)
set(findobj([decay_handle(ishandle(decay_handle));fit_handle(ishandle(fit_handle))],'-depth',0,'Visible','on'),'Visible','off');

set(handles.FittingGui,'CurrentAxes',handles.Residual_axes)
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
grouped_decay.fit_result = handles.FitResultTemplate;

grouped_decay.Chi_sq = 0;
grouped_decay.fitting_method = 0;

set(handles.FittingGui,'CurrentAxes',handles.Decay_axes)
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



% --- Executes on button press in GroupZ_pushbutton.
function GroupZ_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to GroupZ_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
decay_struct = handles.decay_struct;
selected = get(handles.Decay_listbox,'Value');
NumOfDecays = handles.NumOfDecays;

[~,~,~,hh,mm,ss] = datevec(get(handles.WithinTime_edit,'String'));
withintimesec = hh*3600+mm*60+ss;

timearr = zeros(length(selected),1);
for i = 1:length(selected)
    [~,~,~,hh,mm,ss]= datevec(decay_struct{selected(i)}.setting.Time);
    timearr(i) = hh*3600+mm*60+ss;
end

[timearr,ind] = sort(timearr);
difftime = diff(timearr);
%boundary between two groups
bdind = difftime>withintimesec;

NumNewDecays = sum(bdind)+1;
groupedDecay = cell(NumNewDecays,1);
newname = cell(NumNewDecays,1);

groupind = 1;
batchname = decay_struct{selected(1)}.name(1:2);
time = decay_struct{selected(1)}.time;

TempDecayStruct.time = time;
TempDecayStruct.fit_handle = -99;
TempDecayStruct.residual_handle = -99;
TempDecayStruct.fit_result = handles.FitResultTemplate;
TempDecayStruct.Chi_sq = 0;
TempDecayStruct.fitting_method = 0;

decay = decay_struct{selected(1)}.decay;
groupedDecay{groupind} = TempDecayStruct;
groupedDecay{groupind}.setting = decay_struct{selected(1)}.setting;
newname{groupind} = [batchname, '_timegroup',num2str(groupind,'%03d')];
groupedDecay{groupind}.name = newname{groupind};

set(handles.FittingGui,'CurrentAxes',handles.Decay_axes)
for i = 2:length(selected);
    if bdind(i-1)==1  
        groupedDecay{groupind}.decay = decay;
        groupedDecay{groupind}.decay_handle = semilogy(time,decay,'ro');
        set(groupedDecay{groupind}.decay_handle,'Visible','off')
        
        decay = decay_struct{selected(i)}.decay;
        groupind = groupind + 1;
        groupedDecay{groupind} = TempDecayStruct;
        groupedDecay{groupind}.setting = decay_struct{selected(i)}.setting;
        newname{groupind} = [batchname, '_timegroup',num2str(groupind,'%03d')];
        groupedDecay{groupind}.name = newname{groupind};
        
    else
        decay = decay+decay_struct{selected(i)}.decay;
    end
end

groupedDecay{groupind}.decay = decay;
groupedDecay{groupind}.decay_handle = semilogy(time,decay,'ro');
set(groupedDecay{groupind}.decay_handle,'Visible','off')


decay_handle = -99*ones(NumOfDecays,1);
fit_handle = -99*ones(NumOfDecays,1);
residual_handle = -99*ones(NumOfDecays,1);
for i = 1:NumOfDecays
    decay_handle(i) = decay_struct{i}.decay_handle;
    fit_handle(i) = decay_struct{i}.fit_handle;
    residual_handle(i) = decay_struct{i}.residual_handle;
end

set(handles.FittingGui,'CurrentAxes',handles.Decay_axes)
set(findobj([decay_handle(ishandle(decay_handle));fit_handle(ishandle(fit_handle))],'-depth',0,'Visible','on'),'Visible','off');

set(handles.FittingGui,'CurrentAxes',handles.Residual_axes)
set(findobj(residual_handle(ishandle(residual_handle)),'-depth',0,'Visible','on'),'Visible','off');

set(groupedDecay{1}.decay_handle,'Visible','on')
decay_struct = [decay_struct;groupedDecay];

set(handles.Decay_listbox,'Max',NumOfDecays+NumNewDecays+1,'Value',NumOfDecays+1);
NumOfDecays = NumOfDecays+NumNewDecays;

decay_names = get(handles.Decay_listbox,'String');
decay_names = [decay_names;newname];
set(handles.Decay_listbox,'String',decay_names);

set(handles.TotalCount_text,'String',num2str(sum(groupedDecay{1}.decay),'%10.4e'));

handles.decay_struct = decay_struct;
handles.NumOfDecays = NumOfDecays;

guidata(hObject,handles)



% --- Executes on button press in AutoSet_pushbutton.
function AutoSet_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to AutoSet_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
decay_struct = handles.decay_struct;
selected = get(handles.Decay_listbox,'Value');

if isempty(decay_struct)
    errordlg('Load Decays first');
    return
end

currentdecay = decay_struct{selected(1)}.decay;
currenttime = decay_struct{selected(1)}.time;
fit_start_x = currenttime(min(find(currentdecay>0)))+0.1;
fit_end_x = currenttime(max(find(currentdecay>0)))-0.1;
noise_region_from = currenttime(find(currentdecay == max(currentdecay)))-1;
noise_region_to = currenttime(find(currentdecay == max(currentdecay)))-0.5;

set(handles.FitStart_edit,'String',num2str(fit_start_x));
set(handles.FitEnd_edit,'String',num2str(fit_end_x));
set(handles.NoiseRegionfrom_edit,'String',num2str(noise_region_from));
set(handles.NoiseRegionto_edit,'String',num2str(noise_region_to));

set(handles.FittingGui,'CurrentAxes',handles.Decay_axes)
delete(handles.start_line)
delete(handles.end_line)
delete(handles.noise_line1)
delete(handles.noise_line2)

handles.start_line = line([fit_start_x;fit_start_x],[1;1E3],'Color','g');
handles.end_line = line([fit_end_x;fit_end_x],[1;1E3],'Color','g');
handles.noise_line1 = line([noise_region_from;noise_region_from],[1;1E3],'Color','y');
handles.noise_line2 = line([noise_region_to;noise_region_to],[1;1E3],'Color','y');

guidata(hObject,handles)

function FitStart_edit_Callback(hObject, eventdata, handles)
% hObject    handle to FitStart_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of FitStart_edit as text
%        str2double(get(hObject,'String')) returns contents of FitStart_edit as a double

start_line = handles.start_line;

set(handles.FittingGui,'CurrentAxes',handles.Decay_axes)
XL = xlim;

x = str2num(get(hObject,'String'));

if x<=XL(2) && x>=XL(1) && x<str2num(get(handles.FitEnd_edit,'String'))
    
        set(handles.FittingGui,'CurrentAxes',handles.Decay_axes)
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

set(handles.FittingGui,'CurrentAxes',handles.Decay_axes)
XL = xlim;

x = str2num(get(hObject,'String'));

if x<=XL(2) && x>=XL(1) && x>str2num(get(handles.FitStart_edit,'String'))
        set(handles.FittingGui,'CurrentAxes',handles.Decay_axes)
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

set(handles.FittingGui,'CurrentAxes',handles.Decay_axes)
XL = xlim;

x = str2num(get(hObject,'String'));

if x<=XL(2) && x>=XL(1) && x<str2num(get(handles.NoiseRegionto_edit,'String'))
        set(handles.FittingGui,'CurrentAxes',handles.Decay_axes)
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

set(handles.FittingGui,'CurrentAxes',handles.Decay_axes)
XL = xlim;

x = str2num(get(hObject,'String'));

if x<=XL(2) && x>=XL(1) && x>str2num(get(handles.NoiseRegionfrom_edit,'String'))
        set(handles.FittingGui,'CurrentAxes',handles.Decay_axes)
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



% --- Executes on selection change in FitVar_popupmenu.
function FitVar_popupmenu_Callback(hObject, eventdata, handles)
% hObject    handle to FitVar_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns FitVar_popupmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from FitVar_popupmenu
fitvar = get(hObject,'value');
nexpo = get(handles.NumOfExpo_popupmenu,'value');
currentrowname = get(handles.FitResult_table,'rowname');
newrowname = currentrowname;


if fitvar == 1
    newrowname{5} = 'E';
    set(handles.FitResult_table,'rowname',newrowname);
elseif fitvar == 2
    newrowname{5} = 'tau2';
    set(handles.FitResult_table,'rowname',newrowname);    
end

if nexpo == 1
    txt = '1expo: A*f*exp(-t/tau1)+(1-A)';
elseif nexpo == 2
    if fitvar == 1 
        txt = '2expo: A*f*exp(-t/tau1)+A*(1-f)*exp(-t/(tau1*E))+(1-A)';
    elseif fitvar == 2
        txt = '2expo: A*f*exp(-t/tau1)+A*(1-f)*exp(-t/tau2)+(1-A)';
    end
elseif nexpo == 3
    txt = '3expo: A*f*exp(-t/tau1)+A*(1-f)*f2*exp(-t/(tau1*E))+A*(1-f)*(1-f2).*exp(-t/(tau1*E2))+(1-A)';
end

set(handles.FitModel_text,'String',txt);

% --- Executes on button press in Fit_pushbutton.
function Fit_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to Fit_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA) 
selected = get(handles.Decay_listbox,'Value');
fitting_method = get(handles.FittingMethod_popupmenu,'Value');
fitvar = get(handles.FitVar_popupmenu,'Value');

%whether or not save the data to Temp Saved Result folder
tempsave = get(handles.TempSave_checkbox,'Value');

decay_struct = handles.decay_struct;
NumOfDecays = handles.NumOfDecays;

for j = selected
    if isfield(decay_struct{j},'irf') == 0 || isempty(decay_struct{j}.irf)
        errordlg('No IRF assigned for one of the decays selected for fitting. Load IRF first');
        return
    end
end

decay_handle = -99*ones(NumOfDecays,1);
fit_handle = -99*ones(NumOfDecays,1);
residual_handle = -99*ones(NumOfDecays,1);
for i = 1:NumOfDecays
    decay_handle(i) = decay_struct{i}.decay_handle;
    fit_handle(i) = decay_struct{i}.fit_handle;
    residual_handle(i) = decay_struct{i}.residual_handle;
end

%hide previous data
set(handles.FittingGui,'CurrentAxes',handles.Decay_axes)
set(findobj([decay_handle(ishandle(decay_handle));fit_handle(ishandle(fit_handle))],...
    '-depth',0,'Visible','on'),'Visible','off');
set(handles.FittingGui,'CurrentAxes',handles.Residual_axes)
set(findobj(residual_handle(ishandle(residual_handle)),'-depth',0,'Visible','on'),'Visible','off')

time = decay_struct{selected(1)}.time;

%parameters needed for fitting
dt = time(2)-time(1);

fit_start = round(str2num(get(handles.FitStart_edit,'String'))/dt);
fit_end = round(str2num(get(handles.FitEnd_edit,'String'))/dt);
noise_region_from = round(str2num(get(handles.NoiseRegionfrom_edit,'String'))/dt);
noise_region_to = round(str2num(get(handles.NoiseRegionto_edit,'String'))/dt);

nexpo = get(handles.NumOfExpo_popupmenu,'Value');
prior = get(handles.Prior_popupmenu,'Value');

for j = selected
    decay_struct{j} = DecayFLIMFit(decay_struct{j},...
        fitting_method,nexpo,fitvar,fit_start,fit_end,noise_region_from,noise_region_to,prior);
    
    % show data
    set(handles.FittingGui,'CurrentAxes',handles.Decay_axes)

    time = decay_struct{j}.time;
    decay = decay_struct{j}.decay;
    irf = decay_struct{j}.irf;
    time_irf = decay_struct{j}.time_irf;
    residual = decay_struct{j}.residual;

    if ishandle(decay_handle(j))
        delete(decay_handle(j))
    end
    decay_struct{j}.decay_handle = semilogy(time,decay,'ro');
    hold on
    
    pfit = decay_struct{j}.fit_result(1:(nexpo*2+1),1);
%     if fitting_method == 2
%         psampled = decay_struct{i}.post;
%         dp = decay_struct{i}.dp;
%         pmin = decay_struct{j}.fit_result(1:(nexpo*2+1),4);
%         pmax = decay_struct{j}.fit_result(1:(nexpo*2+1),5);
%     elseif fitting_method == 3
%         margpost = decay_struct{i}.marg_post;
%     end
%     sigmap = decay_struct{j}.fit_result(1:(nexpo*2+1),2);
%     Chisq = decay_struct{j}.Chi_sq;
    
    counts = sum(decay(fit_start:fit_end));
    if isfield(decay_struct{j},'refcurve')
        refcurve = decay_struct{j}.refcurve;
    else
        refcurve = ones(length(irf),1);
    end
    y_hat = lm_decay_model(time,pfit,[nexpo,counts,fit_start,fit_end,fitvar],time_irf,irf,refcurve);
    y_hat = y_hat(fit_start:fit_end);
    
    if ishandle(fit_handle(j))
        delete(fit_handle(j))
    end
    decay_struct{j}.fit_handle = semilogy(time(fit_start:fit_end),y_hat,'-k');
    
    set(handles.FittingGui,'CurrentAxes',handles.Residual_axes)
    
    if ishandle(residual_handle(j))
        delete(residual_handle(j))
    end
    decay_struct{j}.residual_handle = plot(time,residual,'r');
    
    decay_struct{j}.fit_region = [fit_start, fit_end];
    decay_strcut{j}.noise_region = [noise_region_from,noise_region_to];
    
    set(handles.FittingGui,'CurrentAxes',handles.ResidualHist_axes)
    histogram(residual,-6:6)
    
    if tempsave
        S = datestr(now,'yyyymmddTHHMM');
        pathname = ['temp_saved_fit_result/' S];
        save_fit_result(pathname,decay_struct{j});
    end
end

fit_result = decay_struct{selected(1)}.fit_result;
Chi_sq = decay_struct{selected(1)}.Chi_sq;

set(handles.FitResult_table,'Data',fit_result)
set(handles.ChiSquared_text,'String',num2str(Chi_sq))

handles.decay_struct = decay_struct;

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
pmin = decay_struct.fit_result(:,4);
pmax = decay_struct.fit_result(:,5);

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
elseif fitting_method ==2
    figure;
    
    psampled = decay_struct.post;
    dp = decay_struct.dp;
    for i = 1:N_param
        subplot(N_param+1,1,i)
        histogram(psampled(i,:),'BinMethod','sturges','BinLimits',[pmin(i),pmax(i)],'BinWidth',dp(i));
        switch i
            case 1
                xlabel('shift');
            case 2
                xlabel('A');
            case 3
                xlabel('tau');
            case 4
                xlabel('f');
            case 5
                xlabel('E');
        end
    end

    if nexpo == 2
        meantau = psampled(3,:).*psampled(4,:)+psampled(3,:).*psampled(5,:).*(1-psampled(4,:));
        subplot(N_param+1,1,6);
        histogram(meantau,'BinMethod','sturges','BinLimits',[min(meantau),max(meantau)]);
    end
    
elseif fitting_method ==3
    figure;
    
    p_vec = decay_struct.p_vec;
    marg_post = decay_struct.marg_post;
    post = decay_struct.post;
    
    for i = 1:N_param
        subplot(N_param,1,i)
        plot(p_vec{i},marg_post{i},'linewidth',3);
        switch i
            case 1
                xlabel('shift');
            case 2
                xlabel('A');
            case 3
                xlabel('/tau');
            case 4
                xlabel('f');
            case 5
                xlabel('E');
        end
    end
    
%     if nexpo == 2
%         [pmat,subsc] = ParamMatrix(p_vec);
%         
%         linpost = zeros(size(pmat,2),1);
%         for k = 1:size(pmat,2);
%             linpost(k) = post(subsc(1,k),subsc(2,k),subsc(3,k),subsc(4,k),subsc(5,k));
%         end
%         
%         
%         sampleind = randsample(size(pmat,2),10000,true,linpost);
%         
%         psampled = pmat(:,sampleind);
%         
%         meantau = psampled(3,:).*psampled(4,:)+psampled(3,:).*psampled(5,:).*(1-psampled(4,:));
%         subplot(N_param+1,1,6);
%         histogram(meantau,'BinMethod','sturges','BinLimits',[min(meantau),max(meantau)]);
%     end
    
    
   x = 1; 

end


% --- Executes on button press in ShowSummary_pushbutton.
function ShowSummary_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to ShowSummary_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

selected = handles.Decay_listbox.Value;
decay_structs = handles.decay_struct;

Nselected = length(selected);

default = ~decay_structs{selected(1)}.fit_result(:,3);

pind = paramCheckboxDlg(default);
if pind == -99
   return; 
end

Nshow = length(pind);

param = zeros(Nshow,Nselected);
dparam = zeros(Nshow,Nselected);

pmode = zeros(Nshow,Nselected);
pquant_up = zeros(Nshow,Nselected);
pquant_down = zeros(Nshow,Nselected);
alpha = 0.9; %credibility level

for ind = 1:Nselected
    i = selected(ind);
   decay_struct = postModeUpdate(decay_structs{i},alpha);
   fit_result = decay_struct.fit_result;
   
   param(:,ind) = fit_result(pind,1);
   dparam(:,ind) = fit_result(pind,2);
   
   if decay_struct.fitting_method == 2 | decay_struct.fitting_method == 3
       map = decay_struct.pmode;
       pmode(:,ind) = map(pind,1);
       pquant_up(:,ind) = map(pind,2);
       pquant_down(:,ind) = map(pind,3);
   end   
end

figure
for i = 1:Nshow
    subplot(Nshow,1,i); errorbar(param(i,:),dparam(i,:),'ro');
    if decay_struct.fitting_method == 2 | decay_struct.fitting_method == 3 
        hold on
        errorbar(1:Nselected,pmode(i,:),pmode(i,:)-pquant_down(i,:),pquant_up(i,:)-pmode(i,:),'bx');
        legend('Mean','Mode');
    end
    switch pind(i)
        case 1
            ylabel('shift','FontSize',12);
        case 2
            ylabel('A','FontSize',12);
        case 3
            ylabel('tau','FontSize',12);
        case 4
            ylabel('f','FontSize',12);
        case 5
            ylabel('E','FontSize',12);
        case 6
            ylabel('f2','FontSize',12);
        case 7
            ylabel('E2','FontSize',12);
%         case 8 
%             ylabel('mean(tau)','FontSize',12);
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

analysisDir = pathname;

save('analysisDir.mat','analysisDir');




% --- Executes on button press in LoadIRF_pushputton.
function LoadIRF_pushputton_Callback(hObject, eventdata, handles)
% hObject    handle to LoadIRF_pushputton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[name pathname filterindex] = uigetfile('IRF/*.mat');
if name == 0 
    return;
end

decay_struct = handles.decay_struct;
selected = get(handles.Decay_listbox,'Value');
showvalue = get(handles.ShowIRF_checkbox,'Value');

loaded_irf = load([pathname name]);
time = loaded_irf.time;
irf = loaded_irf.decay;
irf = irf/max(irf)*1E3;

for i = 1:length(selected)
    decay_struct{selected(i)}.irf = irf;
    decay_struct{selected(i)}.time_irf = time;
    decay_struct{selected(i)}.irfname = name;
        
    set(handles.FittingGui,'CurrentAxes',handles.Decay_axes);
    if isfield(decay_struct{selected(i)},'irf_handle')...
            && ishandle(decay_struct{selected(i)}.irf_handle)
        delete(decay_struct{selected(i)}.irf_handle);
    end
        
    irf_handle = semilogy(time,irf,'g');
    
    set(irf_handle,'Visible','off');
    decay_struct{selected(i)}.irf_handle = irf_handle;
end

if showvalue == 1
    set(decay_struct{selected(1)}.irf_handle,'Visible','on');
end

handles.decay_struct = decay_struct;
set(handles.NoIRF_text,'Visible','off')

guidata(hObject,handles);


% --- Executes on button press in ShowIRF_checkbox.
function ShowIRF_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to ShowIRF_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ShowIRF_checkbox
showvalue = get(hObject,'Value');
selected = get(handles.Decay_listbox,'Value');
decay_struct = handles.decay_struct{selected(1)};

if isfield(decay_struct,'irf') ...
        && isempty(decay_struct.irf)==0;
    if ishandle(decay_struct.irf_handle)
        if showvalue == 1
            set(decay_struct.irf_handle,'Visible','on');
        else
            set(decay_struct.irf_handle,'Visible','off');
        end
    else
        set(handles.FittingGui,'CurrentAxes',handles.Decay_axes)
        irf = decay_struct.irf;
        time_irf = decay_struct.time_irf;
        decay_struct.irf_handle = semilogy(time_irf,irf,'g');
        
        if showvalue == 1
            set(decay_struct.irf_handle,'Visible','on');
        else
            set(decay_struct.irf_handle,'Visible','off');
        end
    end
end

    handles.decay_struct{selected(1)} = decay_struct;

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
row = eventdata.Indices(1);
column = eventdata.Indices(2);

for i = selected
   handles.decay_struct{i}.fit_result(row,column) = eventdata.NewData;
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

fitvar = get(handles.FitVar_popupmenu,'value');
nexpo = get(handles.NumOfExpo_popupmenu,'value');

if nexpo == 1
    txt = '1expo: A*f*exp(-t/tau1)+(1-A)';
elseif nexpo == 2
    if fitvar == 1 
        txt = '2expo: A*f*exp(-t/tau1)+A*(1-f)*exp(-t/(tau1*E))+(1-A)';
    elseif fitvar == 2
        txt = '2expo: A*f*exp(-t/tau1)+A*(1-f)*exp(-t/tau2)+(1-A)';
    end
elseif nexpo == 3
    txt = '3expo: A*f*exp(-t/tau1)+A*(1-f)*f2*exp(-t/(tau1*E))+A*(1-f)*(1-f2).*exp(-t/(tau1*E2))+(1-A)';
end

set(handles.FitModel_text,'String',txt)

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

% --- Executes during object creation, after setting all properties.
function FitVar_popupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FitVar_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function FitModel_text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FitModel_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called




% --- Executes on button press in ShowRefCurve_checkbox.
function ShowRefCurve_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to ShowRefCurve_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ShowRefCurve_checkbox
showvalue = get(hObject,'Value');
selected = get(handles.Decay_listbox,'Value');
decay_struct = handles.decay_struct{selected(1)};

if isfield(decay_struct,'refcurve') ...
        && isempty(decay_struct.refcurve)==0;
    if ishandle(decay_struct.refcurve_handle)
        if showvalue == 1
            set(decay_struct.refcurve_handle,'Visible','on');
        else
            set(decay_struct.refcurve_handle,'Visible','off');
        end
    else
        set(handles.FittingGui,'CurrentAxes',handles.Decay_axes)
        refcurve = decay_struct.refcurve;
        if isfield(decay_struct,'time_irf')
            time_irf = decay_struct.time_irf;
        else
            errordlg('Load IRF first')
            return;
        end
        decay_struct.refcurve_handle = semilogy(time_irf,refcurve,'g');
        
        if showvalue == 1
            set(decay_struct.refcurve_handle,'Visible','on');
        else
            set(decay_struct.refcurve_handle,'Visible','off');
        end
    end
end

handles.decay_struct{selected(1)} = decay_struct;

guidata(hObject,handles)


% --- Executes on button press in LoadRefCurve_pushbutton.
function LoadRefCurve_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to LoadRefCurve_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[name pathname ~] = uigetfile('ReferenceCurve/*.mat');
if name == 0 
    return;
end

decay_struct = handles.decay_struct;
selected = get(handles.Decay_listbox,'Value');
showvalue = get(handles.ShowRefCurve_checkbox,'Value');

loaded_refcurve = load([pathname name]);
refcurve = loaded_refcurve.decay;
refcurve = refcurve/max(refcurve)*1E3;

if isfield(decay_struct{selected(1)},'time_irf')
    time = decay_struct{selected(1)}.time_irf;
else
    errordlg('Open IRF first')
    return;
end

for i = 1:length(selected)
    decay_struct{selected(i)}.refcurve = refcurve;
    decay_struct{selected(i)}.refcurvename = name;
        
    set(handles.FittingGui,'CurrentAxes',handles.Decay_axes);
    if isfield(decay_struct{selected(i)},'refcurve_handle')...
            && ishandle(decay_struct{selected(i)}.refcurve_handle)
        delete(decay_struct{selected(i)}.refcurve_handle);
    end
        
    refcurve_handle = semilogy(time,refcurve,'b');
    
    set(refcurve_handle,'Visible','off');
    decay_struct{selected(i)}.refcurve_handle = refcurve_handle;
end

if showvalue == 1
    set(decay_struct{selected(1)}.refcurve_handle,'Visible','on');
end

handles.decay_struct = decay_struct;

guidata(hObject,handles);


% --- Executes on button press in SortRename_pushbutton.
function SortRename_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to SortRename_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
selected = get(handles.Decay_listbox,'Value');
decay_struct = handles.decay_struct;

%change decay_struct from cell array to array for convenience
decay_struct = cell2mat(decay_struct);

pathname = unique({decay_struct(selected).pathname});

if length(pathname)>1
   errordlg('At least one of the decay constructed from the data set in different folder.')
end

addpath MultiDAcq

sortinfo = MultiD_sdt_sort(pathname{1},0);
if istable(sortinfo)==0 & sortinfo == -1 %uManager folder doesn't exist in the path
   prompt = 'No folder containing uManager files doesn''t exist. If you want to sort by defining the number of z sections, enter the number and hit okay.';
   answer = inputdlg(prompt,'No uManager folder',2,'4');
   Nz = round(str2double(answer{1}));
   
   % to be added  
end




