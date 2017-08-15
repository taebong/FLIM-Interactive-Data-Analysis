function varargout = FLIMDataAnalysisGUI(varargin)
% FLIMDATAANALYSISGUI MATLAB code for FLIMDataAnalysisGUI.fig
%      FLIMDATAANALYSISGUI, by itself, creates a new FLIMDATAANALYSISGUI or raises the existing
%      singleton*.
%
%      H = FLIMDATAANALYSISGUI returns the handle to a new FLIMDATAANALYSISGUI or the handle to
%      the existing singleton*.
%
%      FLIMDATAANALYSISGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FLIMDATAANALYSISGUI.M with the given input arguments.
%
%      FLIMDATAANALYSISGUI('Property','Value',...) creates a new FLIMDATAANALYSISGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before FLIMDataAnalysisGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to FLIMDataAnalysisGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help FLIMDataAnalysisGUI

% Last Modified by GUIDE v2.5 18-Feb-2013 11:24:19

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @FLIMDataAnalysisGUI_OpeningFcn, ...
    'gui_OutputFcn',  @FLIMDataAnalysisGUI_OutputFcn, ...
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

% --- Executes just before FLIMDataAnalysisGUI is made visible.
function FLIMDataAnalysisGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to FLIMDataAnalysisGUI (see VARARGIN)

% Choose default command line output for FLIMDataAnalysisGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% This sets up the initial plot - only do when we are invisible
% so window can get raised using FLIMDataAnalysisGUI.
if strcmp(get(hObject,'Visible'),'off')
    
end

% This sets up the slider inactive. Slider becomes active when image data
% more than two are loaded.
set(handles.slider1,'Enable','off','SliderStep',[1,5]);

% UIWAIT makes FLIMDataAnalysisGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = FLIMDataAnalysisGUI_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
axes(handles.axes1);
cla;




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


% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[name pathname filterindex] = uigetfile('G:\Needleman Lab\FLIM\*.sdt','MultiSelect','on');

if name == 0
    
else
    if iscell(name)
        filename = name;
    else
        filename = cell(1,1);
        filename{1} = name;
    end
    
    handles.image.filename = filename;
    handles.image.pathname = pathname;
    handles.image.filterindex = filterindex;
    
    %Show filename
    set(handles.text1,'String',filename{1});
    
    block=1; %1:2pf, 2:SHG
    NumOfImages = length(filename);
    
    if NumOfImages > 1
        set(handles.slider1,'Enable','on','Min',1,'Max',NumOfImages,'Value',1)
    end
        
    %Number of images loaded
    handles.image.NumOfImages = NumOfImages;
    %Image plot handles
    image_handle = zeros(1:NumOfImages,1);
    %x,y coordinates of pixels selected for analysis 
    handles.image.selected_pixel = cell(NumOfImages,1);
    %Handles for selected pixels
    handles.image.selected_pixel_handle = cell(NumOfImages,1);
    
    
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
        set(image_handle(i),'Visible','off');
        handles.image.selected_pixel{i} = [];
        handles.image.selected_pixel_handle{i} = [];
    end
    
    %FLIM image
    handles.image.flim = flim;
    %Image plot handles
    handles.image.image_handle = image_handle;

    set(image_handle(1),'Visible','on');
    axis image
    colorbar;
    set(gca,'FontSize',15);
    
    guidata(hObject,handles);
    
end



% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


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



% --- Executes on button press in pushbutton7.
function pushbutton7_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
selected_image = get(handles.slider1,'Value');
selected_pixel_handle = handles.image.selected_pixel_handle{selected_image};
axes(handles.axes1);
hold on;
button=1;
if isempty(handles.image.selected_pixel{selected_image})
    xx = []; yy= [];
else 
    [xx,yy] = handles.image.selected_pixel{selected_image};
end
while button==1
    [x,y,button]=ginput(1);
    x = round(x); y = round(y);
    reclick = find(xx == x & yy == y);
    if isempty(reclick)
        h = plot(x,y,'ks','MarkerFaceColor','k','MarkerSize',5); %mark the point
        selected_pixel_handle = [selected_pixel_handle;h];
        if button==1
            xx=[xx;x];yy=[yy;y];
        end
    else
        xx(reclick) = []; yy(reclick) = [];
        delete(selected_pixel_handle(reclick));
        selected_pixel_handle(reclick) = [];
    end
end
selected_pixel{get(handles.slider1,'Value')} = [xx,yy];
handles.image.selected_pixel = selected_pixel;
handles.image.selected_pixel_handle = selected_pixel_handle;
selected_pixel(:,:)
selected_pixel_handle
guidata(hObject,handles);
