function varargout = PhasorPlot(varargin)
% PHASORPLOT MATLAB code for PhasorPlot.fig
%      PHASORPLOT, by itself, creates a new PHASORPLOT or raises the existing
%      singleton*.
%
%      H = PHASORPLOT returns the handle to a new PHASORPLOT or the handle to
%      the existing singleton*.
%
%      PHASORPLOT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PHASORPLOT.M with the given input arguments.
%
%      PHASORPLOT('Property','Value',...) creates a new PHASORPLOT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before PhasorPlot_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to PhasorPlot_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help PhasorPlot

% Last Modified by GUIDE v2.5 28-Feb-2013 10:23:07

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @PhasorPlot_OpeningFcn, ...
                   'gui_OutputFcn',  @PhasorPlot_OutputFcn, ...
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


% --- Executes just before PhasorPlot is made visible.
function PhasorPlot_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to PhasorPlot (see VARARGIN)

% Choose default command line output for PhasorPlot
handles.output = hObject;
load('decay_to_phasor');

fit_start = 1;
fit_end = 256;

NumOfDecays = length(decay_struct);

w=2*pi*freq; 

ref = ref(fit_start:fit_end);

%calculate ref phasor 
Gn_ref=0; 
Sn_ref=0; 
area_ref=0; 
for bin = 1:length(ref)-1 
    Gn_ref = Gn_ref + ref(bin).*cos(w*dt.*(bin-.5))*dt; 
    Sn_ref = Sn_ref + ref(bin).*sin(w*dt.*(bin-.5))*dt; 
    area_ref = area_ref + (ref(bin) +ref(bin+1)).*dt./2;
end

G_ref = Gn_ref./area_ref; 
S_ref = Sn_ref./area_ref; 

%calculate phase and modulation corrections 
M_ref = (1 + (w*ref_tau).^2).^(-0.5); 
ph_ref = atan(w*ref_tau);

M_cor = sqrt(G_ref.^2+S_ref.^2)./M_ref; 
ph_cor = -atan2(S_ref,G_ref)+ph_ref; 

G = zeros(NumOfDecays,1);
S = zeros(NumOfDecays,1);
%group variable
group = cell(NumOfDecays,1);
%shown or hidden
shown = ones(NumOfDecays,1);

%Plot universal circle
axes(handles.Phasor_axes)
cla;
theta = 0:0.01:pi;
plot(0.5+0.5*cos(theta),0.5*sin(theta),'k');
axis([0 1 0 1]);
axis square;
hold on;
xlabel('G')
ylabel('S')

for decay_sel = 1:NumOfDecays
    decay = decay_struct{decay_sel}.decay;
    decay = decay(fit_start:fit_end);
    
    %calculate data phasor
    Gn=0; Sn=0; area=0;
    for bin = 1:length(decay)-1
        Gn = Gn + decay(bin).*cos(w*dt.*(bin-.5))*dt;
        Sn = Sn + decay(bin).*sin(w*dt.*(bin-.5))*dt;
        area = area + (decay(bin) +decay(bin+1)).*dt./2;
    end
    
    Gdec = Gn./area;
    Sdec = Sn./area;
    G(decay_sel) = (Gdec.*cos(ph_cor) - Sdec.*sin(ph_cor))./M_cor;
    S(decay_sel) = (Gdec.*sin(ph_cor) + Sdec.*cos(ph_cor))./M_cor;
    
    %group variable
    group{decay_sel} = 'Ungrouped';
end

%Plot phasor point
h = gscatter(G,S,group);
%set(h,'DefaultLineMarkerSize',10);

handles.G = G;
handles.S = S;
handles.NumOfDecays = NumOfDecays;
handles.decay_struct = decay_struct;
handles.phasorhandle = h;
handles.shown = shown;

%grouping variable
handles.group = group; 

set(handles.Decay_listbox,'Min',1)
set(handles.Decay_listbox,'Max',NumOfDecays+2)

names = cell(NumOfDecays,1);

for i = 1:NumOfDecays
   names{i} = decay_struct{i}.name;
end

set(handles.Decay_listbox,'String',names)

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes PhasorPlot wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = PhasorPlot_OutputFcn(hObject, eventdata, handles) 
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





% --- Executes on button press in GroupPoints_pushbutton.
function GroupPoints_pushbutton_Callback(hObject, ~, handles)
% hObject    handle to GroupPoints_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
selected = get(handles.Decay_listbox,'Value');
group = handles.group;
G = handles.G;
S = handles.S;
shown = handles.shown;
h = handles.phasorhandle;

for i = selected
    group{i} = get(handles.GroupName_edit,'String');
end

axes(handles.Phasor_axes)
delete(h);
h = gscatter(G(shown==1),S(shown==1),group(shown==1));

handles.group = group;
handles.phasorhandle = h;

guidata(hObject,handles)

% --- Executes on button press in HideSelected_pushbutton.
function HideSelected_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to HideSelected_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

selected = get(handles.Decay_listbox,'Value');
group = handles.group;
G = handles.G;
S = handles.S;
shown = handles.shown;
h = handles.phasorhandle;

shown(selected) = 0;

axes(handles.Phasor_axes)
delete(h);
h = gscatter(G(shown==1),S(shown==1),group(shown==1));

handles.shown = shown;
handles.phasorhandle = h;

guidata(hObject,handles)


% --- Executes on button press in ShowSelected_pushbutton.
function ShowSelected_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to ShowSelected_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

selected = get(handles.Decay_listbox,'Value');
group = handles.group;
G = handles.G;
S = handles.S;
shown = handles.shown;
h = handles.phasorhandle;

shown(selected) = 1;

axes(handles.Phasor_axes)
delete(h);
h = gscatter(G(shown==1),S(shown==1),group(shown==1));

handles.shown = shown;
handles.phasorhandle = h;

guidata(hObject,handles)


% --- Executes on button press in DrawLine_pushbutton.
function DrawLine_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to DrawLine_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[x,y]=ginput(2);
axes(handles.Phasor_axes)
line(x,y,'Color','y','LineWidth',2);


% --- Executes on button press in SavePlot_pushbutton.
function SavePlot_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to SavePlot_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
selected = get(handles.Decay_listbox,'Value');
group = handles.group;
G = handles.G;
S = handles.S;
shown = handles.shown;

f1 = figure; % Open a new figure with handle f1
theta = 0:0.01:pi;
plot(0.5+0.5*cos(theta),0.5*sin(theta),'k');
axis([0 1 0 1]);
axis square;
hold on;
xlabel('G')
ylabel('S')
gscatter(G(shown==1),S(shown==1),group(shown==1));





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
