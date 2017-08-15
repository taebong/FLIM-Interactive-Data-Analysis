function varargout = FLIMDataAnalysisGUI_ver1_2(varargin)
% FLIMDATAANALYSISGUI_VER1_2 MATLAB code for FLIMDataAnalysisGUI_ver1_2.fig
%      FLIMDATAANALYSISGUI_VER1_2, by itself, creates a new FLIMDATAANALYSISGUI_VER1_2 or raises the existing
%      singleton*.
%
%      H = FLIMDATAANALYSISGUI_VER1_2 returns the handle to a new FLIMDATAANALYSISGUI_VER1_2 or the handle to
%      the existing singleton*.
%
%      FLIMDATAANALYSISGUI_VER1_2('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FLIMDATAANALYSISGUI_VER1_2.M with the given input arguments.
%
%      FLIMDATAANALYSISGUI_VER1_2('Property','Value',...) creates a new FLIMDATAANALYSISGUI_VER1_2 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before FLIMDataAnalysisGUI_ver1_2_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to FLIMDataAnalysisGUI_ver1_2_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help FLIMDataAnalysisGUI_ver1_2

% Last Modified by GUIDE v2.5 19-Feb-2013 17:40:03

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @FLIMDataAnalysisGUI_ver1_2_OpeningFcn, ...
    'gui_OutputFcn',  @FLIMDataAnalysisGUI_ver1_2_OutputFcn, ...
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

% --- Executes just before FLIMDataAnalysisGUI_ver1_2 is made visible.
function FLIMDataAnalysisGUI_ver1_2_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to FLIMDataAnalysisGUI_ver1_2 (see VARARGIN)

% Choose default command line output for FLIMDataAnalysisGUI_ver1_2
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% This sets up the initial plot - only do when we are invisible
% so window can get raised using FLIMDataAnalysisGUI_ver1_2.
if strcmp(get(hObject,'Visible'),'off')
    
end


% UIWAIT makes FLIMDataAnalysisGUI_ver1_2 wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = FLIMDataAnalysisGUI_ver1_2_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



% --------------------------------------------------------------------
function FileMenu_Callback(hObject, eventdata, handles)
% hObject    handle to FileMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function OpenMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to OpenMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
file = uigetfile('*.fig');
if ~isequal(file, 0)
    open(file);
end

% --------------------------------------------------------------------
function PrintMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to PrintMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
printdlg(handles.figure1)

% --------------------------------------------------------------------
function CloseMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to CloseMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
selection = questdlg(['Close ' get(handles.figure1,'Name') '?'],...
    ['Close ' get(handles.figure1,'Name') '...'],...
    'Yes','No','Yes');
if strcmp(selection,'No')
    return;
end

delete(handles.figure1)


% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

set(hObject, 'String', {'plot(rand(5))', 'plot(sin(1:0.01:25))', 'bar(1:.5:10)', 'plot(membrane)', 'surf(peaks)'});





%% Push buttons for open/close images

% Push button to open Image(s)
% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[name pathname filterindex] = uigetfile2('*.sdt','MultiSelect','on');

% This sets up the slider inactive. Slider becomes active when image data
% more than one are loaded.
set(handles.slider1,'SliderStep',[1,5]);
handles.slider_previous_value = 1;

if iscell(name) | name~=0
    if iscell(name)
        filename = name;
    else
        filename = cell(1,1);
        filename{1} = name;
    end
    
    handles.image.filename = filename;
    handles.image.pathname = pathname;
    handles.image.filterindex = filterindex;
    
    block=1; %1:2pf, 2:SHG
    NumOfImages = length(filename);
    
    
    set(handles.slider1,'Min',1);
    set(handles.slider1,'Max',max(NumOfImages,2));
    set(handles.slider1,'Value',1);
    set(handles.slider1,'SliderStep',[1,1]/(max(NumOfImages,2)-1))
    if NumOfImages>1
        set(handles.slider1,'Visible','on');
    end
    
    %Number of images loaded
    handles.image.NumOfImages = NumOfImages;
    %Image plot handles
    image_handle = zeros(NumOfImages,1);
    %x,y coordinates of pixels selected for analysis
    handles.image.selected_pixel = cell(NumOfImages,1);
    %Handles for selected pixels
    handles.image.selected_pixel_handle = cell(NumOfImages,1);
    %Handles for fluorescence decay data plot
    handles.image.decay_handle = zeros(NumOfImages,1);
    %Fluorescence decay data from selected pixels
    handles.image.decay = cell(NumOfImages,1);
    
    
    flim = cell(NumOfImages,1);
    
    axes(handles.axes1);
    cla;
    for i = 1:NumOfImages
        sdt = bh_readsetup([pathname filename{i}]);
        ch = bh_getdatablock(sdt,block);
        img{i} = uint8(squeeze(sum(ch,1)));
        flim{i} = double(ch);
        disp(['progress ' num2str(i) ' out of ' num2str(NumOfImages)])
        image_handle(i) = imagesc(img{i});
        hold on;
        set(image_handle(i),'Visible','off');
        handles.image.selected_pixel{i} = [];
        handles.image.selected_pixel_handle{i} = [];
        handles.image.decay{i} = zeros(size(flim{i},1),1);
    end
    
    %FLIM image
    handles.image.flim = flim;
    %Image plot handles
    handles.image.image_handle = image_handle;
    
    set(image_handle(1),'Visible','on');
    axis image
    colorbar;
    set(gca,'FontSize',15);
    %Show filename
    set(handles.text1,'String',filename{1});
    
    guidata(hObject,handles);
end



%% Push Buttons for Pixel Selection

% Push button to select/deselect pixel
% --- Executes on button press in pushbutton7.
function pushbutton7_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
selected_image = get(handles.slider1,'Value');
selected_pixel_handle = handles.image.selected_pixel_handle{selected_image};
flim = handles.image.flim{selected_image};
decay = handles.image.decay{selected_image};

axes(handles.axes1);

button=1;
decay_handle = 0;
if isempty(handles.image.selected_pixel{selected_image})
    xx = []; yy= [];
else
    xx = handles.image.selected_pixel{selected_image}(:,1);
    yy = handles.image.selected_pixel{selected_image}(:,2);
end
while button==1
    [x,y,button]=ginput(1);
    x = round(x); y = round(y);
    reclick = find(xx == x & yy == y);
    if isempty(reclick) && button==1;
        h = plot(x,y,'ks','MarkerFaceColor','k','MarkerSize',5); %mark the point
        selected_pixel_handle = [selected_pixel_handle;h];
        xx=[xx;x];yy=[yy;y];
        decay = decay + flim(:,y,x);
        axes(handles.axes2);
        if decay_handle ~= 0
            delete(decay_handle);
        end
        decay_handle = semilogy(decay,'.');
        hold on;
        %update total photon counts
        set(handles.text4,'String',num2str(sum(decay)))
        axes(handles.axes1);
        
    elseif button==1;
        xx(reclick) = []; yy(reclick) = [];
        delete(selected_pixel_handle(reclick));
        selected_pixel_handle(reclick) = [];
        decay = decay - flim(:,y,x);
        axes(handles.axes2);
        if decay_handle ~= 0
            delete(decay_handle);
        end
        decay_handle = semilogy(decay,'.');
        hold on;
        %update total photon counts
        set(handles.text4,'String',num2str(sum(decay)))
        axes(handles.axes1);
    end
    
end
selected_pixel = [xx,yy];
handles.image.selected_pixel{selected_image} = selected_pixel;
handles.image.selected_pixel_handle{selected_image} = selected_pixel_handle;
handles.image.film{selected_image} = flim;
handles.image.decay_handle(selected_image) = decay_handle;
handles.image.decay{selected_image} = decay;

guidata(hObject,handles);

% Push Button to deselect all pixels 
% --- Executes on button press in pushbutton8.
function pushbutton8_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
selected_image = get(handles.slider1,'Value');
selected_pixel_handle = handles.image.selected_pixel_handle{selected_image};
flim = handles.image.flim{selected_image};
decay_handle = handles.image.decay_handle(selected_image);

%initialize selected pixel and decay
delete(selected_pixel_handle);
delete(decay_handle);
handles.image.selected_pixel{selected_image} = [];
handles.image.selected_pixel_handle{selected_image} = [];
handles.image.decay{selected_image} = zeros(size(flim,1),1);
handles.image.decay_handle(selected_image) = 0;

%update total photon counts
set(handles.text4,'String',num2str(0))

guidata(hObject,handles);




%% Slider to choose image
% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
value = get(hObject,'Value');
value = round(value);
set(hObject,'Value',value);

previous_value = handles.slider_previous_value;

axes(handles.axes1);
set(handles.image.image_handle,'Visible','off');
set(handles.image.selected_pixel_handle{previous_value},'Visible','off');
set(handles.image.image_handle(value),'Visible','on');
set(handles.image.selected_pixel_handle{value},'Visible','on');

axes(handles.axes2);
set(handles.image.decay_handle,'Visible','off');
set(handles.image.decay_handle(value),'Visible','on');

%Show filename
set(handles.text1,'String',handles.image.filename{value});

%update total photon counts
set(handles.text4,'String',num2str(sum(handles.image.decay{value})))

%update slider previous value
handles.slider_previous_value = value;

guidata(hObject,handles);




% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1


% --- Executes during object creation, after setting all properties.
function text1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function axes2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axes2


% --- Executes during object creation, after setting all properties.
function text4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
set(hObject,'String',num2str(0))
