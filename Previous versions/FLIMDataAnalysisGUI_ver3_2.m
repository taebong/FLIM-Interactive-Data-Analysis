function varargout = FLIMDataAnalysisGUI_ver3_2(varargin)
% FLIMDATAANALYSISGUI_VER3_2 MATLAB code for FLIMDataAnalysisGUI_ver3_2.fig
%      FLIMDATAANALYSISGUI_VER3_2, by itself, creates a new FLIMDATAANALYSISGUI_VER3_2 or raises the existing
%      singleton*.
%
%      H = FLIMDATAANALYSISGUI_VER3_2 returns the handle to a new FLIMDATAANALYSISGUI_VER3_2 or the handle to
%      the existing singleton*.
%
%      FLIMDATAANALYSISGUI_VER3_2('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FLIMDATAANALYSISGUI_VER3_2.M with the given input arguments.
%
%      FLIMDATAANALYSISGUI_VER3_2('Property','Value',...) creates a new FLIMDATAANALYSISGUI_VER3_2 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before FLIMDataAnalysisGUI_ver3_2_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to FLIMDataAnalysisGUI_ver3_2_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help FLIMDataAnalysisGUI_ver3_2

% Last Modified by GUIDE v2.5 23-Feb-2013 22:27:01

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @FLIMDataAnalysisGUI_ver3_2_OpeningFcn, ...
    'gui_OutputFcn',  @FLIMDataAnalysisGUI_ver3_2_OutputFcn, ...
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

% --- Executes just before FLIMDataAnalysisGUI_ver3_2 is made visible.
function FLIMDataAnalysisGUI_ver3_2_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to FLIMDataAnalysisGUI_ver3_2 (see VARARGIN)

% Choose default command line output for FLIMDataAnalysisGUI_ver3_2
handles.output = hObject;

%Initialize handles
handles.NumOfImages = 0;
handles.image_struct = [];
handles.previous_value = 1;
handles.NumOfSavedDecays = 0;
handles.saved_decay = [];

% Update handles structure
guidata(hObject, handles);

% This sets up the initial plot - only do when we are invisible
% so window can get raised using FLIMDataAnalysisGUI_ver3_2.
if strcmp(get(hObject,'Visible'),'off')
    
end


% UIWAIT makes FLIMDataAnalysisGUI_ver3_2 wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = FLIMDataAnalysisGUI_ver3_2_OutputFcn(hObject, eventdata, handles)
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
function Filename_popupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Filename_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

set(hObject, 'String', {''});


%% Push buttons for open/close images

% Push button to open Image(s)
% --- Executes on button press in OpenImage_pushbutton.
function OpenImage_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to OpenImage_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[name pathname filterindex] = uigetfile2('*.sdt','MultiSelect','on');

if iscell(name) | name~=0
    if iscell(name)
        filename = name;
    else
        filename = cell(1,1);
        filename{1} = name;
    end
    
    %     %Current slider value
    %     slider_value = get(handles.ImageSelection_slider,'Value');
    %Number of newly loaded images
    NumOfNewImages = length(filename);
    %Number of previously opened images
    NumOfPrevImages = handles.NumOfImages;
    %Total number of loaded images
    NumOfImages = NumOfNewImages+NumOfPrevImages;
    
    %Image structure that contains all the information about the newly
    %opened images
    image_struct = cell(NumOfNewImages,1);
    
    %Two photon image block
    block=1; %1:2pf, 2:SHG
    
    axes(handles.Image_axes);
    for i = 1:NumOfNewImages
        %load sdt file
        sdt = bh_readsetup([pathname filename{i}]);
        ch = bh_getdatablock(sdt,block);
        img = uint8(squeeze(sum(ch,1)));
        flim = double(ch);
        
        image_handle = imagesc(img);
        axis image;    colorbar;    set(gca,'FontSize',15);
        hold on;
        set(image_handle,'Visible','off');
        
        %Update image structure
        image_struct{i}.filename = filename{i};
        image_struct{i}.pathname = pathname;
        %image plot handle
        image_struct{i}.image_handle = image_handle;
        %x,y coordinates of pixels selected for analysis
        image_struct{i}.selected_pixel = [];
        %Handles for plot showing selected pixels
        image_struct{i}.selected_pixel_handle = [];
        %FLIM Data
        image_struct{i}.flim = flim;
        %Fluorescence decay data extracted from selected pixels
        image_struct{i}.decay = zeros(size(flim,1),1);
        %Handles for fluorescence decay data plot
        image_struct{i}.decay_handle = [];
        
        set(handles.text9,'String',['Loading (' num2str(i) ' out of ' num2str(NumOfNewImages) ')'])
        drawnow()
    end
    
    
    %show the first image newly opened
    set(image_struct{1}.image_handle,'Visible','on');
    
    %hide all decay curve
    set(image_struct{1}.decay_handle,'Visible','off');
    
    %Show filename
    if NumOfPrevImages == 0 
        set(handles.Filename_popupmenu,'String',filename);
    else
        names = get(handles.Filename_popupmenu,'String');
        set(handles.Filename_popupmenu,'String',[names;filename']);
        set(handles.Filename_popupmenu,'Value',NumOfPrevImages+1);
    end
        
    %update the handles
    %image select slider
    set(handles.ImageSelection_slider,'Min',1);
    set(handles.ImageSelection_slider,'Max',max(NumOfImages,2));
    set(handles.ImageSelection_slider,'Value',NumOfPrevImages+1);
    set(handles.ImageSelection_slider,'SliderStep',[1,1]/(max(NumOfImages,2)-1))
    if NumOfImages>1
        set(handles.ImageSelection_slider,'Visible','on');
    end
    
    %image structure
    handles.image_struct = [handles.image_struct;image_struct];
    %Total Number of images loaded
    handles.NumOfImages = NumOfImages;
    
    handles.previous_value = NumOfPrevImages+1;
    set(handles.text9,'String','Ready!')
    
    %Enable decay save
    set(handles.SaveDecay_pushbutton,'Enable','on')
    
    guidata(hObject,handles);
end

% Push Button to close image
% --- Executes on button press in CloseImage_pushbutton.
function CloseImage_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to CloseImage_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

selected = get(handles.ImageSelection_slider,'Value');
NumOfImages = handles.NumOfImages;
image_struct = handles.image_struct;
switch NumOfImages
    case 0
        
    case 1
        axes(handles.Image_axes);
        cla;
        axes(handles.Decay_axes);
        cla;
        image_struct = [];
        NumOfImages = 0;
        
        %update filename
        set(handles.Filename_popupmenu,'String',{' '})
        %update count
        set(handles.TotalCount_text,'String',num2str(0));
     
        %Disable decay save
        set(handles.SaveDecay_pushbutton,'Enable','off')
        
    otherwise
        %delete what's related to the current image shown on the axes
        axes(handles.Image_axes)
        delete(image_struct{selected}.image_handle);
        delete(image_struct{selected}.selected_pixel_handle);
        axes(handles.Decay_axes)
        delete(image_struct{selected}.decay_handle);
        
        image_struct(selected) = [];
        
        %update filename popupmenu entry
        names = get(handles.Filename_popupmenu,'String');
        names(selected) = [];
        set(handles.Filename_popupmenu,'String',names);
        
        NumOfImages = NumOfImages-1;
        
        %next image automatically shown
        selected = min(selected,NumOfImages);
        
        axes(handles.Image_axes)
        set(image_struct{selected}.image_handle,'Visible','on');
        set(image_struct{selected}.selected_pixel_handle,'Visible','on');
            
        axes(handles.Decay_axes);
        set(image_struct{selected}.decay_handle,'Visible','on');
           
        %update filename
        set(handles.Filename_popupmenu,'Value',selected);
        
        %update photon counts
        set(handles.TotalCount_text,'String',num2str(sum(image_struct{selected}.decay)))

end

% update image select slider
set(handles.ImageSelection_slider,'Min',1);
set(handles.ImageSelection_slider,'Max',max(NumOfImages,2));
set(handles.ImageSelection_slider,'Value',max(NumOfImages,1));
set(handles.ImageSelection_slider,'SliderStep',[1,1]/(max(NumOfImages,2)-1))
if NumOfImages>1
    set(handles.ImageSelection_slider,'Visible','on');
else
    set(handles.ImageSelection_slider,'Visible','off');
end

%update handles

%image structure
handles.image_struct = image_struct;
%Total Number of images loaded
handles.NumOfImages = NumOfImages;

handles.previous_value = selected;

guidata(hObject,handles);


%% Push Buttons for Pixel Selection

% Push button to select/deselect pixel
% --- Executes on button press in PixelSelection_pushbutton.
function PixelSelection_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to PixelSelection_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%currently selected image
selected = get(handles.ImageSelection_slider,'Value');
selected_pixel = handles.image_struct{selected}.selected_pixel;
selected_pixel_handle = handles.image_struct{selected}.selected_pixel_handle;
flim = handles.image_struct{selected}.flim;
decay = handles.image_struct{selected}.decay;
decay_handle = handles.image_struct{selected}.decay_handle;

update_gui(handles,0,1)

%time axis
dt = str2double(get(handles.dt_edit,'String'));
time = (1:length(decay))*dt;

if isempty(selected_pixel)
    xx = []; yy= [];
else
    xx = selected_pixel(:,1);
    yy = selected_pixel(:,2);
end

button=1;

while button==1
    [x,y,button]=ginput(1);
    x = round(x); y = round(y);
    %whether or not pixel already has been selected
    reclick = find(xx == x & yy == y);
    
    axes(handles.Image_axes);
    if isempty(reclick) && button==1;
        h = plot(x,y,'ks','MarkerFaceColor','k','MarkerSize',5); %mark the point
        selected_pixel_handle = [selected_pixel_handle;h];
        xx=[xx;x];yy=[yy;y];
        decay = decay + flim(:,y,x);
        axes(handles.Decay_axes);
        if isempty(decay_handle)==0
            delete(decay_handle);
        end
        decay_handle = semilogy(time,decay,'.');
        hold on;
        %update total photon counts
        set(handles.TotalCount_text,'String',num2str(sum(decay)))
    elseif button==1;
        xx(reclick) = []; yy(reclick) = [];
        delete(selected_pixel_handle(reclick));
        selected_pixel_handle(reclick) = [];
        decay = decay - flim(:,y,x);
        axes(handles.Decay_axes);
        if isempty(decay_handle)==0
            delete(decay_handle);
        end
        decay_handle = semilogy(time,decay,'.');
        hold on;
        %update total photon counts
        set(handles.TotalCount_text,'String',num2str(sum(decay)))
    end
    
end
selected_pixel = [xx,yy];

%update handles
handles.image_struct{selected}.selected_pixel = selected_pixel;
handles.image_struct{selected}.selected_pixel_handle = selected_pixel_handle;
handles.image_struct{selected}.decay = decay;
handles.image_struct{selected}.decay_handle = decay_handle;

guidata(hObject,handles);

% Push Button to deselect all pixels
% --- Executes on button press in DeselectAll_pushbutton.
function DeselectAll_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to DeselectAll_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%currently selected image
selected = get(handles.ImageSelection_slider,'Value');
selected_pixel_handle = handles.image_struct{selected}.selected_pixel_handle;
decay = handles.image_struct{selected}.decay;
decay_handle = handles.image_struct{selected}.decay_handle;
flim = handles.image_struct{selected}.flim;

update_gui(handles,0,1)

%time axis
dt = str2double(get(handles.dt_edit,'String'));
time = (1:length(decay))*dt;

%initialize selected pixel and decay
delete(selected_pixel_handle);
handles.image_struct{selected}.selected_pixel = [];
handles.image_struct{selected}.selected_pixel_handle = [];
handles.image_struct{selected}.decay = zeros(size(flim,1),1);

axes(handles.Decay_axes);
if isempty(decay_handle) == 0;
    delete(decay_handle);
end
decay_handle = semilogy(time,decay,'.');
handles.image_struct{selected}.decay_handle = decay_handle;

%update total photon counts
set(handles.TotalCount_text,'String',num2str(0))

guidata(hObject,handles);




%% Image Selection
% --- Executes on slider movement.
function ImageSelection_slider_Callback(hObject, eventdata, handles)
% hObject    handle to ImageSelection_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
value = get(hObject,'Value');
value = round(value);
set(hObject,'Value',value);

previous_value = handles.previous_value;

% axes(handles.Image_axes);
% set(handles.image_struct{previous_value}.image_handle,'Visible','off');
% set(handles.image_struct{previous_value}.selected_pixel_handle,'Visible','off');
% set(handles.image_struct{value}.image_handle,'Visible','on');
% set(handles.image_struct{value}.selected_pixel_handle,'Visible','on');
% 
% axes(handles.Decay_axes);
% set(handles.image_struct{previous_value}.decay_handle,'Visible','off');
% set(handles.image_struct{value}.decay_handle,'Visible','on');
% 
% %Show filename
% set(handles.Filename_popupmenu,'Value',value);
% 
% %update total photon counts
% set(handles.TotalCount_text,'String',num2str(sum(handles.image_struct{value}.decay)))

update_gui(handles,1,1);

%update slider previous value
handles.previous_value = value;

guidata(hObject,handles);


% --- Executes on selection change in Filename_popupmenu.
function Filename_popupmenu_Callback(hObject, eventdata, handles)
% hObject    handle to Filename_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns Filename_popupmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Filename_popupmenu

value = get(hObject,'Value');
set(handles.ImageSelection_slider,'Value',value);

% previous_value = handles.previous_value;
% 
% axes(handles.Image_axes);
% set(handles.image_struct{previous_value}.image_handle,'Visible','off');
% set(handles.image_struct{previous_value}.selected_pixel_handle,'Visible','off');
% set(handles.image_struct{value}.image_handle,'Visible','on');
% set(handles.image_struct{value}.selected_pixel_handle,'Visible','on');
% 
% axes(handles.Decay_axes);
% set(handles.image_struct{previous_value}.decay_handle,'Visible','off');
% set(handles.image_struct{value}.decay_handle,'Visible','on');
% 
% %update total photon counts
% set(handles.TotalCount_text,'String',num2str(sum(handles.image_struct{value}.decay)))
% 

update_gui(handles,1,1);


%update slider previous value
handles.previous_value = value;

guidata(hObject,handles);




%% Data Export


% --------------------------------------------------------------------
function ExportCurrentImage_Callback(hObject, eventdata, handles)
% hObject    handle to ExportCurrentImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[name pathname filterindex] = uiputfile2('*.mat');
if name ~= 0
    selected = get(handles.Filename_popupmenu,'Value');
    image_struct = handles.image_struct{selected};
    save([pathname name],'image_struct')
end


% --- Executes on button press in SaveDecay_pushbutton.
function SaveDecay_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to SaveDecay_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
selected = get(handles.Filename_popupmenu,'Value');
NumOfSavedDecays = handles.NumOfSavedDecays;
decay = handles.image_struct{selected}.decay;
filename = handles.image_struct{selected}.filename;
decay_name = get(handles.DecayName_edit,'String');
saved_decay = handles.saved_decay;

if isempty(decay_name)
    decay_name = {['decay' num2str(NumOfSavedDecays+1)]};
end

if NumOfSavedDecays == 0;
    set(handles.SavedDecay_listbox,'String',decay_name)
    %Enable pushbuttons
    Switch_pushbuttons(handles,'on')
else
    names = get(handles.SavedDecay_listbox,'String');
    set(handles.SavedDecay_listbox,'String',[names;decay_name])
end

decay_to_save = cell(1,1);
decay_to_save{1}.decay = decay;
decay_to_save{1}.name = decay_name;
decay_to_save{1}.filename = filename;

NumOfSavedDecays = NumOfSavedDecays + 1;

%time axis
dt = str2double(get(handles.dt_edit,'String'));
time = (1:length(decay))*dt;

decay_to_save{1}.time = time;

axes(handles.Decay_axes)
decay_handle = semilogy(time,decay,'.');
set(decay_handle,'Visible','off');

decay_to_save{1}.decay_handle = decay_handle; 

saved_decay = [saved_decay;decay_to_save];

handles.saved_decay = saved_decay;
handles.NumOfSavedDecays = NumOfSavedDecays;

set(handles.SavedDecay_listbox,'Min',1)
set(handles.SavedDecay_listbox,'Max',max(2,NumOfSavedDecays))

set(handles.SavedDecay_listbox, 'Value', NumOfSavedDecays);

guidata(hObject,handles)



% --- Executes on button press in DeleteDecay_pushbutton.
function DeleteDecay_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to DeleteDecay_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
decay_sel =  get(handles.SavedDecay_listbox,'Value');
NumOfSavedDecays = handles.NumOfSavedDecays;

axes(handles.Decay_axes)

for i = decay_sel;
    delete(handles.saved_decay{i}.decay_handle)
end
    
saved_decay = handles.saved_decay;
saved_decay(decay_sel) = [];
handles.saved_decay = saved_decay;

names = get(handles.SavedDecay_listbox,'String');
names(decay_sel) = [];

NumOfSavedDecays = NumOfSavedDecays - length(decay_sel);

if NumOfSavedDecays == 0
    set(handles.SavedDecay_listbox,'String',' ');
    Switch_pushbuttons(handles,'off')
else
    set(handles.SavedDecay_listbox,'String',names);
end

set(handles.SavedDecay_listbox,'Min',1)
set(handles.SavedDecay_listbox,'Max',NumOfSavedDecays+2)

set(handles.SavedDecay_listbox, 'Value', max(NumOfSavedDecays,1));

handles.NumOfSavedDecays = NumOfSavedDecays;

guidata(hObject,handles)


% --- Executes on button press in ShowDecay_pushbutton.
function ShowDecay_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to ShowDecay_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
decay_sel =  get(handles.SavedDecay_listbox,'Value');

if length(decay_sel) > 1
    errordlg('Select a single decay')
else
    decay = handles.saved_decay{decay_sel}.decay;
    decay_handle = handles.saved_decay{decay_sel}.decay_handle;
    
    update_gui(handles,0,1,decay,decay_handle)
end

guidata(hObject,handles)


% --- Executes on button press in SetReference_pushbutton.
function SetReference_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to SetReference_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
decay_sel = get(handles.SavedDecay_listbox,'Value');

if length(decay_sel) > 1
    errordlg('Select a single decay')
else
    decay = handles.saved_decay{decay_sel}.decay;

    save('reference_decay','decay');
end

% --- Executes on button press in SetIRF_pushbutton.
function SetIRF_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to SetIRF_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
decay_sel = get(handles.SavedDecay_listbox,'Value');

if length(decay_sel) > 1
    errordlg('Select a single decay')
else
    decay = handles.saved_decay{decay_sel}.decay;

    save('IRF','decay');
end


% --- Executes on button press in ExportDecay_pushbutton.
function ExportDecay_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to ExportDecay_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[name pathname filterindex] = uiputfile2('*.mat');
if name ~= 0
    decay_sel = get(handles.SavedDecay_listbox,'Value');
    saved_decay = handles.saved_decay;

    decay_to_export = saved_decay(decay_sel);

    save([pathname name],'decay_to_export')
end


% --- Executes on button press in ImportDecay_pushbutton.
function ImportDecay_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to ImportDecay_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[name pathname filterindex] = uigetfile2('*.mat');
if name ~= 0
    loaded_mat = load([pathname name]);
    imported_decay = loaded_mat.decay_to_export;
    saved_decay = handles.saved_decay;
    NumOfSavedDecays = handles.NumOfSavedDecays;
    
    axes(handles.Decay_axes)
    for i = 1:length(imported_decay)
        time = imported_decay{i}.time;
        decay_handle = semilogy(time,imported_decay{i}.decay,'.');
        hold on;
        set(decay_handle,'Visible','off')
        imported_decay{i}.decay_handle = decay_handle;
    end 
    
    saved_decay = [saved_decay;imported_decay];
    
    imported_decay_name = cell(length(imported_decay),1);
    for i = 1:length(imported_decay)
        imported_decay_name(i) = {imported_decay{i}.name};
    end
    
    if NumOfSavedDecays == 0;
        set(handles.SavedDecay_listbox,'String',imported_decay_name)
        %Enable pushbuttons
        Switch_pushbuttons(handles,'on')
    else
        names = get(handles.SavedDecay_listbox,'String');
        set(handles.SavedDecay_listbox,'String',[names;imported_decay_name])
    end
    
    NumOfSavedDecays = NumOfSavedDecays + length(imported_decay);
    
    handles.saved_decay = saved_decay;
    handles.NumOfSavedDecays = NumOfSavedDecays;
    
    set(handles.SavedDecay_listbox,'Min',1)
    set(handles.SavedDecay_listbox,'Max',max(2,NumOfSavedDecays))
    
    set(handles.SavedDecay_listbox, 'Value', NumOfSavedDecays);
    
    guidata(hObject,handles);
end


% --- Executes on button press in ExportPhasor_pushbutton.
function ExportPhasor_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to ExportPhasor_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

decay_sel = get(handles.SavedDecay_listbox,'Value');
dt = str2double(get(handles.dt_edit,'String'))*1E-9;
freq = str2double(get(handles.LaserRepRate_edit,'String'));
load_ref = load('reference_decay');
ref = load_ref.decay;
ref_tau = str2double(get(handles.RefTau_edit,'String'))*1E-9;
saved_decay = handles.saved_decay;

figure
for i = decay_sel
    decay = saved_decay{i}.decay;
    [G,S] = plottcspcphasor(decay,ref,ref_tau,freq,dt);
end





%%
% --- Executes during object creation, after setting all properties.
function ImageSelection_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ImageSelection_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes during object creation, after setting all properties.
function Image_axes_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Image_axes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate Image_axes


% --- Executes during object creation, after setting all properties.
function Decay_axes_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Decay_axes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate Decay_axes


% --- Executes during object creation, after setting all properties.
function TotalCount_text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TotalCount_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
set(hObject,'String',num2str(0))



function dt_edit_Callback(hObject, eventdata, handles)
% hObject    handle to dt_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of dt_edit as text
%        str2double(get(hObject,'String')) returns contents of dt_edit as a double


% --- Executes during object creation, after setting all properties.
function dt_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dt_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function LaserRepRate_edit_Callback(hObject, eventdata, handles)
% hObject    handle to LaserRepRate_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of LaserRepRate_edit as text
%        str2double(get(hObject,'String')) returns contents of LaserRepRate_edit as a double


% --- Executes during object creation, after setting all properties.
function LaserRepRate_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to LaserRepRate_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes during object creation, after setting all properties.
function text9_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on selection change in SavedDecay_popupmenu.
function SavedDecay_popupmenu_Callback(hObject, eventdata, handles)
% hObject    handle to SavedDecay_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns SavedDecay_popupmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from SavedDecay_popupmenu


% --- Executes during object creation, after setting all properties.
function SavedDecay_popupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SavedDecay_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject,'String',' ');

guidata(hObject,handles);






function DecayName_edit_Callback(hObject, eventdata, handles)
% hObject    handle to DecayName_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of DecayName_edit as text
%        str2double(get(hObject,'String')) returns contents of DecayName_edit as a double


% --- Executes during object creation, after setting all properties.
function DecayName_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to DecayName_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





% --- Executes during object creation, after setting all properties.
function SaveDecay_pushbutton_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SaveDecay_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
set(hObject,'Enable','off')
guidata(hObject,handles)


% --- Executes during object creation, after setting all properties.
function ExportDecay_pushbutton_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ExportDecay_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
set(hObject,'Enable','off')
guidata(hObject,handles)


% --- Executes on mouse press over figure background.
function figure1_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --- Executes during object creation, after setting all properties.
function ShowDecay_pushbutton_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ShowDecay_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
set(hObject,'Enable','off')
guidata(hObject,handles)


% --- Executes on selection change in SavedDecay_listbox.
function SavedDecay_listbox_Callback(hObject, eventdata, handles)
% hObject    handle to SavedDecay_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns SavedDecay_listbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from SavedDecay_listbox


% --- Executes during object creation, after setting all properties.
function SavedDecay_listbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SavedDecay_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject,'String',' ');

guidata(hObject,handles);


% --- Executes on button press in FitDecay_pushbutton.
function FitDecay_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to FitDecay_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes when uipanel2 is resized.
function uipanel2_ResizeFcn(hObject, eventdata, handles)
% hObject    handle to uipanel2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function RefTau_edit_Callback(hObject, eventdata, handles)
% hObject    handle to RefTau_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of RefTau_edit as text
%        str2double(get(hObject,'String')) returns contents of RefTau_edit as a double


% --- Executes during object creation, after setting all properties.
function RefTau_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to RefTau_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
