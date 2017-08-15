function varargout = SegmentationGUI(varargin)
% SEGMENTATIONGUI MATLAB code for SegmentationGUI.fig
%      SEGMENTATIONGUI, by itself, creates a new SEGMENTATIONGUI or raises the existing
%      singleton*.
%
%      H = SEGMENTATIONGUI returns the handle to a new SEGMENTATIONGUI or the handle to
%      the existing singleton*.
%
%      SEGMENTATIONGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SEGMENTATIONGUI.M with the given input arguments.
%
%      SEGMENTATIONGUI('Property','Value',...) creates a new SEGMENTATIONGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before SegmentationGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to SegmentationGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help SegmentationGUI

% Last Modified by GUIDE v2.5 21-Aug-2014 08:45:40

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @SegmentationGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @SegmentationGUI_OutputFcn, ...
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


% --- Executes just before SegmentationGUI is made visible.
function SegmentationGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to SegmentationGUI (see VARARGIN)

% Choose default command line output for SegmentationGUI
handles.output = hObject;

MainGui = varargin{1};
MainGuihandles = varargin{2};
imagestack = varargin{3};
MainGuiSelected = varargin{4};
Nimages = length(imagestack);
imageHandleStack = zeros(Nimages,1);
maskperHandleStack = ones(Nimages,1)*-99;

set(handles.SegmentationFig,'CurrentAxes',handles.Image_axes);
for i = 1:Nimages
    imageHandleStack(i) = imagesc(imagestack{i});
    colormap gray;
    axis image;
    hold on
    colorbar
end
set(imageHandleStack(2:end),'Visible','off');

handles.imagestack = imagestack;
handles.Nimages = Nimages;
handles.imageHandleStack = imageHandleStack;
handles.MainGuihandles = MainGuihandles;
handles.MainGuiSelected = MainGuiSelected;
handles.maskperHandleStack = maskperHandleStack;
handles.MainGui = MainGui;

set(handles.ImageSelection_slider,'Value',1,'Min',1,'Max',Nimages,'SliderStep',[1,1]/Nimages);


% Update handles structure
guidata(hObject, handles);

% UIWAIT makes SegmentationGUI wait for user response (see UIRESUME)
% uiwait(handles.SegmentationFig);


% --- Outputs from this function are returned to the command line.
function varargout = SegmentationGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on slider movement.
function ImageSelection_slider_Callback(hObject, eventdata, handles)
% hObject    handle to ImageSelection_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
selected = round(get(hObject,'Value'));
set(hObject,'Value',selected);
imagestack = handles.imagestack;
Nimages = handles.Nimages;
imageHandleStack = handles.imageHandleStack;
maskperHandleStack = handles.maskperHandleStack;

set(handles.SegmentationFig,'CurrentAxes',handles.Image_axes)
set(imageHandleStack(ishandle(imageHandleStack)),'Visible','off');
set(imageHandleStack(selected),'Visible','on');

set(maskperHandleStack(ishandle(maskperHandleStack)),'Visible','off');
if ishandle(maskperHandleStack(selected))
    set(maskperHandleStack(selected),'Visible','on');
end

guidata(hObject,handles);



% --- Executes during object creation, after setting all properties.
function ImageSelection_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ImageSelection_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function MinArea_edit_Callback(hObject, eventdata, handles)
% hObject    handle to MinArea_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MinArea_edit as text
%        str2double(get(hObject,'String')) returns contents of MinArea_edit as a double


% --- Executes during object creation, after setting all properties.
function MinArea_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MinArea_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function MaxArea_edit_Callback(hObject, eventdata, handles)
% hObject    handle to MaxArea_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MaxArea_edit as text
%        str2double(get(hObject,'String')) returns contents of MaxArea_edit as a double


% --- Executes during object creation, after setting all properties.
function MaxArea_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MaxArea_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function LevelFactor_edit_Callback(hObject, eventdata, handles)
% hObject    handle to LevelFactor_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of LevelFactor_edit as text
%        str2double(get(hObject,'String')) returns contents of LevelFactor_edit as a double


% --- Executes during object creation, after setting all properties.
function LevelFactor_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to LevelFactor_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in ShowResult_pushbutton.
function ShowResult_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to ShowResult_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Nimages = handles.Nimages;
imagestack = handles.imagestack;
selected = get(handles.ImageSelection_slider,'Value');

maskperHandleStack = handles.maskperHandleStack;


area_cuts = [str2double(get(handles.MinArea_edit,'String')),...
    str2double(get(handles.MaxArea_edit,'String'))];
level_fact = str2double(get(handles.LevelFactor_edit,'String'));

mask = cell(Nimages,1);
maskper = cell(Nimages,1);

set(handles.SegmentationFig,'CurrentAxes',handles.Image_axes);
for i = 1:Nimages
   [gim,~,mask{i},maskper{i},num] = ...
       EllMask_blur_fillholes(imagestack{i},area_cuts,level_fact);
   [y,x] = find(maskper{i});
   if ishandle(maskperHandleStack(i))
       delete(maskperHandleStack(i));
   end
   
   if isempty(x)
       display(['Couldn''t find segmentation for Image ',num2str(i)]);
   else
       maskperHandleStack(i) = plot(x,y,'.r','LineWidth',1);
       set(maskperHandleStack(i),'Visible','off');
   end
end

set(maskperHandleStack(selected),'Visible','on');


handles.maskper = maskper;
handles.mask = mask;
handles.maskperHandleStack = maskperHandleStack;

guidata(hObject,handles);


% --- Executes on button press in ApplyMask_pushbutton.
function ApplyMask_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to ApplyMask_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
MainGuihandles = handles.MainGuihandles;
MainGuiSelected = handles.MainGuiSelected;
mask = handles.mask;
maskper = handles.maskper;
Nimages = handles.Nimages;
imagestack = handles.imagestack;

image_struct = MainGuihandles.image_struct;

for i = 1:Nimages
    selected_pixel = mask{i}';
    image_struct{MainGuiSelected(i)}.selected_pixel = selected_pixel;
    image_struct{MainGuiSelected(i)}.maskper = maskper{i};
    
        
    %time axis
    time = (1:length(image_struct{MainGuiSelected(i)}.decay))...
        *image_struct{MainGuiSelected(i)}.dt;
    
    active_region = image_struct{MainGuiSelected(i)}.active_region;
    
    img = imagestack{i};
    if isempty(active_region)
        active_region = [1,1;size(img,2),1;size(img,1),size(img,2);1,size(img,2)];
    end
    
    lower_lim = min(active_region,[],1);
    higher_lim = max(active_region,[],1);
    x_min = lower_lim(1);
    y_min = lower_lim(2);
    x_max = higher_lim(1);
    y_max = higher_lim(2);
    
    selected_pixel_handle = image_struct{MainGuiSelected(i)}.selected_pixel_handle;

    axes(MainGuihandles.Image_axes)
    if ishandle(selected_pixel_handle)
        delete(selected_pixel_handle)
    end
    [xx,yy] = find(selected_pixel==1);
    selected_pixel_handle = plot(xx,yy,'ws','MarkerSize',5);
    set(selected_pixel_handle,'Visible','off');
    image_struct{MainGuiSelected(i)}.selected_pixel_handle = selected_pixel_handle;
    
    flim = image_struct{MainGuiSelected(i)}.flim;
    decay_data = image_struct{MainGuiSelected(i)}.decay;
    decay_handle = image_struct{MainGuiSelected(i)}.decay_handle;
    
    for j = 1:length(time);
        decay_data(j) = sum(sum(squeeze(flim(j,y_min:y_max,x_min:x_max)).*selected_pixel(x_min:x_max,y_min:y_max)'));
    end
    
    axes(MainGuihandles.Decay_axes)
    if ishandle(decay_handle);
        delete(decay_handle)
    end
    
    decay_handle = semilogy(time,decay_data,'.');
    hold on;
    set(decay_handle,'Visible','off')
    image_struct{MainGuiSelected(i)}.decay = decay_data;
    image_struct{MainGuiSelected(i)}.decay_handle = decay_handle;
   
end

%update handles
MainGuihandles.image_struct = image_struct;
    
current = get(MainGuihandles.ImageSelection_slider,'Value');

axes(MainGuihandles.Image_axes)
set(MainGuihandles.image_struct{current}.selected_pixel_handle,'Visible','on')

axes(MainGuihandles.Decay_axes)
set(MainGuihandles.image_struct{current}.decay_handle,'Visible','on')

guidata(handles.MainGui,MainGuihandles)
