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

% Last Modified by GUIDE v2.5 25-Nov-2014 11:10:24

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
    axis square;
    hold on
    colorbar
end
set(imageHandleStack(2:end),'Visible','off');

handles.mask = cell(Nimages,1);
handles.maskper = cell(Nimages,1);
handles.imagestack = imagestack;
handles.Nimages = Nimages;
handles.imageHandleStack = imageHandleStack;
handles.MainGuihandles = MainGuihandles;
handles.MainGuiSelected = MainGuiSelected;
handles.maskperHandleStack = maskperHandleStack;
handles.MainGui = MainGui;
handles.ROI = [];
handles.ROI_handle = [];

set(handles.ImageSelection_slider,'Value',1,'Min',1,'Max',Nimages,...
    'SliderStep',[1,1]/(max(Nimages,2)-1));


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
if selected > hObject.Max
    selected = hObejct.Max;
elseif selected < hObject.Min
    selected = hObject.Min;
end
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
ROI = handles.ROI;

mask = handles.mask;
maskperHandleStack = handles.maskperHandleStack;
maskper = handles.maskper;

area_cuts = [str2double(get(handles.MinArea_edit,'String')),...
    str2double(get(handles.MaxArea_edit,'String'))];
level_fact = str2double(get(handles.LevelFactor_edit,'String'));

set(handles.SegmentationFig,'CurrentAxes',handles.Image_axes);

if isempty(ROI) == 0
   lowlim = min(ROI,[],1);
   highlim = max(ROI,[],1);
   xmin = lowlim(1);
   ymin = lowlim(2);
   xmax = highlim(1);
   ymax = highlim(2);
else
    xmin = 1;
    ymin = 1;
    xmax = size(imagestack{1},2);
    ymax = size(imagestack{1},1);
end

if get(handles.ApplyAllFrames_checkbox,'Value')
    for i = 1:Nimages
        image = imagestack{i}(ymin:ymax,xmin:xmax);
        [gim,~,mask{i},maskper{i},num] = ...
            EllMask_blur_fillholes(image,area_cuts,level_fact);
        [y,x] = find(maskper{i});
        if ishandle(maskperHandleStack(i))
            delete(maskperHandleStack(i));
        end
        
        if isempty(x)
            display(['Couldn''t find segmentation for Image ',num2str(i)]);
        else
            y = y+ymin;
            x = x+xmin;
            zeromat = zeros(size(imagestack{i}));
            zeromat(ymin:ymax,xmin:xmax) = mask{i};
            mask{i} = zeromat;
            
            zeromat = zeros(size(imagestack{i}));
            zeromat(ymin:ymax,xmin:xmax) = maskper{i};
            maskper{i} = zeromat;
            
            maskperHandleStack(i) = plot(x,y,'.r','LineWidth',1);
            set(maskperHandleStack(i),'Visible','off');
        end
    end
else
    i = selected;
    image = imagestack{i}(ymin:ymax,xmin:xmax);
    [gim,~,mask{i},maskper{i},num] = ...
        EllMask_blur_fillholes(image,area_cuts,level_fact);
    [y,x] = find(maskper{i});
    if ishandle(maskperHandleStack(i))
        delete(maskperHandleStack(i));
    end
    
    if isempty(x)
        display(['Couldn''t find segmentation for Image ',num2str(i)]);
    else
        y = y+ymin;
        x = x+xmin;
        zeromat = zeros(size(imagestack{i}));
        zeromat(ymin:ymax,xmin:xmax) = mask{i};
        mask{i} = zeromat;
        
        zeromat = zeros(size(imagestack{i}));
        zeromat(ymin:ymax,xmin:xmax) = maskper{i};
        maskper{i} = zeromat;
        
        maskperHandleStack(i) = plot(x,y,'.r','LineWidth',1);
        set(maskperHandleStack(i),'Visible','off');
    end
end

if ishandle(maskperHandleStack(selected))
    set(maskperHandleStack(selected),'Visible','on');
end

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
set(0,'CurrentFigure',handles.MainGui);

for i = 1:Nimages
    selected_pixel = mask{i};
    image_struct{MainGuiSelected(i)}.selected_pixel = selected_pixel;
    image_struct{MainGuiSelected(i)}.maskper = maskper{i};
        
    active_region = image_struct{MainGuiSelected(i)}.active_region;
    
    img = imagestack{i};
    if isempty(active_region) ==0        
        active_region = ones(size(img,1),size(img,2));
        image_struct{MainGuiSelected(i)}.active_region = active_region;
        if ishandle(image_struct{MainGuiSelected(i)}.active_region_handle)
            delete(image_struct{MainGuiSelected(i)}.active_region_handle)
        end
    end
end

%update handles
MainGuihandles.image_struct = image_struct;

MainGuihandles = updateSelectedPixel(MainGuihandles,MainGuiSelected);

guidata(handles.MainGui,MainGuihandles)


% --- Executes on button press in SetROI_pushbutton.
function SetROI_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to SetROI_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%currently selected image
img = handles.imagestack{1};
ROI = handles.ROI;
ROI_handle = handles.ROI_handle;
size_img = size(img);

button=1;

% Pick two vertices to define rectangular active region
vert = zeros(4,2);

[x,y,button]=ginput(1);
if button == 1
    x = min(max(1,round(x)),size_img(2)); y = min(max(1,round(y)),size_img(1));
    
    vert(1,1) = x;
    vert(1,2) = y;
    vert(2,2) = y;
    vert(4,1) = x;
    
    
    [x,y,button]=ginput(1);
    x = min(max(1,round(x)),size_img(2)); y = min(max(1,round(y)),size_img(1));
    
    vert(3,1) = x;
    vert(3,2) = y;
    vert(2,1) = x;
    vert(4,2) = y;
    
    ROI = vert;
    
    set(handles.SegmentationFig,'CurrentAxes',handles.Image_axes);
    if isempty(ROI_handle) == 0 & ishandle(ROI_handle);
        delete(ROI_handle)
    end
    ROI_handle = line([vert(:,1);vert(1,1)],[vert(:,2);vert(1,2)],'LineWidth',2,'Color','w');
     
    %update handles
    handles.ROI = ROI;
    handles.ROI_handle = ROI_handle;

    guidata(hObject,handles);
end

% --- Executes on button press in ApplyAllFrames_checkbox.
function ApplyAllFrames_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to ApplyAllFrames_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ApplyAllFrames_checkbox
