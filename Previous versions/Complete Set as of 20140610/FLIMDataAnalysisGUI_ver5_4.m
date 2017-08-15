

function varargout = FLIMDataAnalysisGUI_ver5_4(varargin)
% FLIMDATAANALYSISGUI_VER5_4 MATLAB code for FLIMDataAnalysisGUI_ver5_4.fig
%      FLIMDATAANALYSISGUI_VER5_4, by itself, creates a new FLIMDATAANALYSISGUI_VER5_4 or raises the existing
%      singleton*.
%
%      H = FLIMDATAANALYSISGUI_VER5_4 returns the handle to a new FLIMDATAANALYSISGUI_VER5_4 or the handle to
%      the existing singleton*.
%
%      FLIMDATAANALYSISGUI_VER5_4('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FLIMDATAANALYSISGUI_VER5_4.M with the given input arguments.
%
%      FLIMDATAANALYSISGUI_VER5_4('Property','Value',...) creates a new FLIMDATAANALYSISGUI_VER5_4 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before FLIMDataAnalysisGUI_ver5_4_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to FLIMDataAnalysisGUI_ver  5_4_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES5

% Edit the above text to modify the response to help FLIMDataAnalysisGUI_ver5_4

% Last Modified by GUIDE v2.5 09-Mar-2014 17:43:44

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @FLIMDataAnalysisGUI_ver5_4_OpeningFcn, ...
    'gui_OutputFcn',  @FLIMDataAnalysisGUI_ver5_4_OutputFcn, ...
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

% --- Executes just before FLIMDataAnalysisGUI_ver5_4 is made visible.
function FLIMDataAnalysisGUI_ver5_4_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to FLIMDataAnalysisGUI_ver5_4 (see VARARGIN)

% Choose default command line output for FLIMDataAnalysisGUI_ver5_4
handles.output = hObject;

%Initialize handles
handles.NumOfImages = 0;
handles.image_struct = [];
handles.previous_value = 1;
handles.NumOfSavedDecays = 0;
handles.saved_decay = [];

addpath bh;

% Update handles structure
guidata(hObject, handles);


% This sets up the initial plot - only do when we are invisible
% so window can get raised using FLIMDataAnalysisGUI_ver5_4.
if strcmp(get(hObject,'Visible'),'off')
    
end

% UIWAIT makes FLIMDataAnalysisGUI_ver5_4 wait for user response (see UIRESUME)
% uiwait(handles.MainGui);


% --- Outputs from this function are returned to the command line.
function varargout = FLIMDataAnalysisGUI_ver5_4_OutputFcn(hObject, eventdata, handles)
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
printdlg(handles.MainGui)

% --------------------------------------------------------------------
function CloseMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to CloseMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
selection = questdlg(['Close ' get(handles.MainGui,'Name') '?'],...
    ['Close ' get(handles.MainGui,'Name') '...'],...
    'Yes','No','Yes');
if strcmp(selection,'No')
    return;
end

delete(handles.MainGui)


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
set(hObject, 'String', 'Open Images');
set(hObject, 'Value', 1);
set(hObject, 'Max', 100);
set(hObject, 'Min', 1);

guidata(hObject,handles)



% --- Executes during object creation, after setting all properties.
function FileName_listbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FileName_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

set(hObject, 'Value', 1);
set(hObject, 'Max', 1000);
set(hObject, 'Min', 1);

guidata(hObject,handles)


%% Push buttons for open/close images

% Push button to open Image(s)
% --- Executes on button press in OpenImage_pushbutton.
function OpenImage_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to OpenImage_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

figname = 'ImportImagesGUI';

eval([figname,'(''MainGui'',handles.MainGui)']);

guidata(hObject,handles);



% Pushbutton to close image
% --- Executes on button press in CloseImage_pushbutton.
function CloseImage_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to CloseImage_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

selected = get(handles.FileName_listbox,'Value');
NumOfImages = handles.NumOfImages;
image_struct = handles.image_struct;
switch NumOfImages
    case 0
        
    case length(selected)
        for i = selected
            set(handles.MainGui,'CurrentAxes',handles.Image_axes)
            if ishandle(image_struct{i}.image_handle)
                delete(image_struct{i}.image_handle);
            end
            if ishandle(image_struct{i}.selected_pixel_handle)
                delete(image_struct{i}.selected_pixel_handle);
            end
            
            set(handles.MainGui,'CurrentAxes',handles.Decay_axes)
            if ishandle(image_struct{i}.decay_handle)
                delete(image_struct{i}.decay_handle);
            end  
        end
        
            image_struct = [];
            NumOfImages = 0;
            
            %update filename
            set(handles.Filename_popupmenu,'String',{'Open Images'})
            set(handles.FileName_listbox,'String',{' '})
            %update count
            set(handles.TotalCount_text,'String',num2str(0));
            
            %Disable decay save
            set(handles.SaveDecay_pushbutton,'Enable','off')
            
            Switch_pushbuttons(handles,'off','image')

    otherwise
        for i = selected
            %delete what's related to the current image shown on the axes
            set(handles.MainGui,'CurrentAxes',handles.Image_axes)
            if ishandle(image_struct{i}.image_handle)
                delete(image_struct{i}.image_handle);
            end
            if ishandle(image_struct{i}.selected_pixel_handle)
                delete(image_struct{i}.selected_pixel_handle);
            end
            
            set(handles.MainGui,'CurrentAxes',handles.Decay_axes)
            if ishandle(image_struct{i}.decay_handle)
                delete(image_struct{i}.decay_handle);
            end
            
            image_struct(i) = [];
            
        end
        
        %update filename popupmenu entry
        set(handles.Filename_popupmenu,'Value',1);
        set(handles.FileName_listbox,'Value',1);
        names = get(handles.Filename_popupmenu,'String');
        names(selected) = [];
        set(handles.Filename_popupmenu,'String',names);
        set(handles.FileName_listbox,'String',names);
        
        NumOfImages = NumOfImages-length(selected);
        
        %next image automatically shown
        selected = min(selected(end),NumOfImages);
        
        set(handles.MainGui,'CurrentAxes',handles.Image_axes)
        set(image_struct{selected}.image_handle,'Visible','on');
        set(image_struct{selected}.selected_pixel_handle,'Visible','on');
        
        set(handles.MainGui,'CurrentAxes',handles.Decay_axes);
        set(image_struct{selected}.decay_handle,'Visible','on');
        
        %update filename
        set(handles.Filename_popupmenu,'Value',selected);
        set(handles.FileName_listbox,'Value',selected);
        
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

% update image select popupmenu
set(handles.Filename_popupmenu,'Min',1);
set(handles.Filename_popupmenu,'Max',max(NumOfImages,2));
set(handles.Filename_popupmenu,'Value',max(NumOfImages,1));

set(handles.FileName_listbox,'Value',max(NumOfImages,1));


%update handles

%image structure
handles.image_struct = image_struct;
%Total Number of images loaded
handles.NumOfImages = NumOfImages;

handles.previous_value = selected;

guidata(hObject,handles);


% --- Executes on button press in MakeMovie_pushbutton.
function MakeMovie_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to MakeMovie_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

selected = get(handles.ImageSelection_slider,'Value');
image_struct = handles.image_struct;

%Example batch filename
eg_fname = image_struct{selected}.filename;
eg_fname = eg_fname(1:(findstr(eg_fname,'_c')-1));
namelen = length(eg_fname);

%Example number of frame
namelist = get(handles.FileName_listbox,'String');
TF = strncmp(namelist,eg_fname,namelen);
eg_Nframe = sum(TF)+(sum(TF)==0)*10;

%Example repeat time
ind = findstr(eg_fname,'repeat');
tempind = findstr(eg_fname,'sec');
tempind = tempind(tempind>ind);
if isempty(tempind) == 0 
    ind2 = tempind(1);
else
    ind2 =[];
end
if (isempty(ind) && isempty(ind2)) == 0 
    eg_repeat = eg_fname((ind+6):(ind2-1));
else
    eg_repeat = 15;
end


prompt = {'Batch file name:','Frame numbers (e.g. 1:2:9):', ...
    'Frame rate (frames/sec)','Repeat time (sec)','Magnification (e.g. 60)'...
    'Zoom Factor','Extension (e.g. tif,avi,etc)','Pixel Size (optional)'};
dlg_title = 'Movie Maker';
num_lines = 1;
def = {eg_fname,['1:',num2str(eg_Nframe)],'8',num2str(eg_repeat)...
    ,'40','32','avi',''};
answer = inputdlg(prompt,dlg_title,num_lines,def);

if isempty(answer)
    return;
end

batchfname = answer{1};
framenum = str2num(answer{2});
framerate = str2num(answer{3});
repeat = str2num(answer{4});
mag = str2num(answer{5});
zm = str2num(answer{6});
if zm<0 | zm>32
    errordlg('Zoom Factor must be between 1 and 32')
end
ext = answer{7};
pixsize = answer{8};

%choose save directory
[filename,pathname] = uiputfile([batchfname,'.',ext],'Save movie file as');
if filename == 0 
    return;
end

filtered=0;

writerObj = VideoWriter([pathname,filename],'Uncompressed AVI');
writerObj.FrameRate = framerate;
open(writerObj)
for i = framenum
    numdig = findstr(namelist{1},'.sdt')-findstr(namelist{1},'_c')-2;
    typestr = ['%0',num2str(numdig),'d'];
    fname = [batchfname,'_c',num2str(i,typestr),'.sdt'];
    ind = find(strcmp(namelist,fname)==1);

    if isempty(ind)
        errordlg('image not found, check frame number')
        return;
    end
    img = double(image_struct{ind}.image);
    
    h = figure;
    normimg = img;
    normimg(:,:,1) = normimg(:,:,1)/max(max(normimg(:,:,1)));
    normimg(:,:,2) = normimg(:,:,2)/max(max(normimg(:,:,2)));
    
    if filtered == 1
        normimg(:,:,1) = bpass(normimg(:,:,1),1,4);
        normimg(:,:,2) = bpass(normimg(:,:,2),1,4);
    end
        
    imagesc(normimg);
    truesize(h);
    axis off;
    axis image;
%    colormap(gray);
    hold on;
    
    if i == framenum(1);
        % field of view is 440um for 1x zoom, 40x objective
        if isempty(pixsize)
            pixsize = 440*40/mag/zm/size(img,1);
        end
    end
   
    %Add scale bar
    %in micrometer
    barsize = 2;
    line([0.9*size(img,2)-round(barsize/pixsize),0.9*size(img,2)],...
        [0.9*size(img,1),0.9*size(img,1)],'LineWidth',2,'Color','Yellow')
    text(0.9*size(img,2)-round(barsize/pixsize),0.9*size(img,1)-6,...
        [num2str(barsize), '{\mu}', 'm'],'Color','yellow','fontsize',6)
    %Add real time
    text(0.1*size(img,2),0.1*size(img,1),[num2str((i-1)*repeat),' sec'],'fontsize',6,...
    'Color','y')

    hold off;
    
    F = getframe;
    
    warning('off', 'Images:initSize:adjustingMag');
    writeVideo(writerObj,F);
    
    close(h);
end

close(writerObj)

 

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
active_region = handles.image_struct{selected}.active_region;
img = handles.image_struct{selected}.image;
dt = handles.image_struct{selected}.dt;

if isempty(active_region) && (size(img,2) > 1) && (size(img,1)>1)
    active_region = [1,1;size(img,2),1;size(img,1),size(img,2);1,size(img,2)];
    
    lower_lim = min(active_region,[],1);
    higher_lim = max(active_region,[],1);
    x_min = lower_lim(1);
    y_min = lower_lim(2);
    x_max = higher_lim(1);
    y_max = higher_lim(2);
elseif isempty(active_region) && (size(img,2)*size(img,1) == 1)
    x_min = 1;     y_min = 1;
    x_max = 1;     y_max = 1;
else
    lower_lim = min(active_region,[],1);
    higher_lim = max(active_region,[],1);
    x_min = lower_lim(1);
    y_min = lower_lim(2);
    x_max = higher_lim(1);
    y_max = higher_lim(2);
end



update_gui(handles,0,1)

%time axis
time = (1:length(decay))'*dt;

button=1;

set(handles.MainGui,'CurrentAxes',handles.Image_axes);


while button==1
    [x,y,button]=ginput(1);
    x = round(x); y = round(y);
    
    set(handles.MainGui,'CurrentAxes',handles.Image_axes);
    if (button ==1) & (x>=x_min) & (x<=x_max) & (y>=y_min) & (y<=y_max)
        selected_pixel(x,y) = ~selected_pixel(x,y);
        
        [xx,yy] = find(selected_pixel==1);
        
        if selected_pixel(x,y)
            decay = decay + flim(:,y,x);
        else
            decay = decay - flim(:,y,x);
        end
        
        if ishandle(selected_pixel_handle)
            delete(selected_pixel_handle)
        end
        selected_pixel_handle = plot(xx,yy,'ws','MarkerSize',5); %mark the point
        
        set(handles.MainGui,'CurrentAxes',handles.Decay_axes);
        if ishandle(decay_handle)
            delete(decay_handle);
        end
        decay_handle = semilogy(time,decay,'.');
        hold on;
        %update total photon counts
        set(handles.TotalCount_text,'String',num2str(sum(decay)))
        %update total number of selected pixel
        set(handles.NumOfSelectedPixel_text,'String',num2str(sum(sum(selected_pixel(x_min:x_max,y_min:y_max)))))
    end
end

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
selected_pixel = handles.image_struct{selected}.selected_pixel;
selected_pixel_handle = handles.image_struct{selected}.selected_pixel_handle;
decay = handles.image_struct{selected}.decay;
decay_handle = handles.image_struct{selected}.decay_handle;
flim = handles.image_struct{selected}.flim;
img = handles.image_struct{selected}.image;
active_region = handles.image_struct{selected}.active_region;
dt = handles.image_struct{selected}.dt;


%time axis
time = (1:length(decay))'*dt;

update_gui(handles,0,1)

if isempty(active_region)
    set(handles.MainGui,'CurrentAxes',handles.Image_axes);
    
    %initialize selected pixel and decay
    if ishandle(selected_pixel_handle)
        delete(selected_pixel_handle)
    end
    selected_pixel = zeros(size(selected_pixel));
    selected_pixel_handle = [];
    decay = zeros(size(decay));
    
    active_region = [1,1;size(img,2),1;size(img,1),size(img,2);1,size(img,2)];
    lower_lim = min(active_region,[],1);
    higher_lim = max(active_region,[],1);
    x_min = lower_lim(1);
    y_min = lower_lim(2);
    x_max = higher_lim(1);
    y_max = higher_lim(2);
    
else
    lower_lim = min(active_region,[],1);
    higher_lim = max(active_region,[],1);
    x_min = lower_lim(1);
    y_min = lower_lim(2);
    x_max = higher_lim(1);
    y_max = higher_lim(2);
    
    reshapedselectedpix = repmat(reshape(selected_pixel',[1,size(selected_pixel')]),[length(decay),1,1]);
    decay = decay - sum(sum(reshapedselectedpix(:,y_min:y_max,x_min:x_max).*flim(:,y_min:y_max,x_min:x_max),2),3);

    selected_pixel(x_min:x_max,y_min:y_max) = zeros(x_max-x_min+1,y_max-y_min+1);
    
    set(handles.MainGui,'CurrentAxes',handles.Image_axes);
    
    if ishandle(selected_pixel_handle)
        delete(selected_pixel_handle)
    end
    
    [xx,yy] = find(selected_pixel==1);
    selected_pixel_handle = plot(xx(:),yy(:),'ws','MarkerFaceColor','w','MarkerSize',5); %mark the point
end

set(handles.MainGui,'CurrentAxes',handles.Decay_axes);
if ishandle(decay_handle)
    delete(decay_handle);
end
decay_handle = semilogy(time,decay,'.');


%update handles
handles.image_struct{selected}.selected_pixel = selected_pixel;
handles.image_struct{selected}.selected_pixel_handle = selected_pixel_handle;
handles.image_struct{selected}.decay = decay;
handles.image_struct{selected}.decay_handle = decay_handle;

%update total photon counts
set(handles.TotalCount_text,'String',num2str(sum(decay)))
%update total number of selected pixel
set(handles.NumOfSelectedPixel_text,'String',num2str(sum(sum(selected_pixel(x_min:x_max,y_min:y_max)))))

guidata(hObject,handles);


% --- Executes on button press in SelectBetween_pushbutton.
function SelectBetween_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to SelectBetween_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%currently selected image
selected = get(handles.ImageSelection_slider,'Value');
img = handles.image_struct{selected}.image;
selected_pixel = handles.image_struct{selected}.selected_pixel;
selected_pixel_handle = handles.image_struct{selected}.selected_pixel_handle;
flim = handles.image_struct{selected}.flim;
decay = handles.image_struct{selected}.decay;
decay_handle = handles.image_struct{selected}.decay_handle;
above_number = str2num(get(handles.SelectAbove_edit,'String'));
below_number = str2num(get(handles.SelectBelow_edit,'String'));
active_region = handles.image_struct{selected}.active_region;
dt = handles.image_struct{selected}.dt;

if isempty(active_region)
    active_region = [1,1;size(img,2),1;size(img,1),size(img,2);1,size(img,2)];
end

lower_lim = min(active_region,[],1);
higher_lim = max(active_region,[],1);
x_min = lower_lim(1);
y_min = lower_lim(2);
x_max = higher_lim(1);
y_max = higher_lim(2);

update_gui(handles,0,1)

%time axis
time = (1:length(decay))'*dt;

Mind = squeeze(sum(flim,1))>above_number & squeeze(sum(flim,1))<below_number;

set(handles.MainGui,'CurrentAxes',handles.Image_axes);

selected_pixel(x_min:x_max,y_min:y_max)=...
    Mind(y_min:y_max,x_min:x_max)';
reshapedselectedpix = repmat(reshape(selected_pixel',[1,size(selected_pixel')]),[length(decay),1,1]);
decay = decay + sum(sum(reshapedselectedpix.*flim,2),3);



if ishandle(selected_pixel_handle)
    delete(selected_pixel_handle)
end

[xx,yy] = find(selected_pixel==1);
selected_pixel_handle = plot(xx(:),yy(:),'ws','MarkerFaceColor','r','MarkerSize',5); %mark the point

set(handles.MainGui,'CurrentAxes',handles.Decay_axes);
if ishandle(decay_handle)
    delete(decay_handle);
end

decay_handle = semilogy(time,decay,'.');
hold on;

%update total photon counts
set(handles.TotalCount_text,'String',num2str(sum(decay)))
%update total number of selected pixel
set(handles.NumOfSelectedPixel_text,'String',num2str(sum(sum(selected_pixel(x_min:x_max,y_min:y_max)))))

%update handles
handles.image_struct{selected}.selected_pixel = selected_pixel;
handles.image_struct{selected}.selected_pixel_handle = selected_pixel_handle;
handles.image_struct{selected}.decay = decay;
handles.image_struct{selected}.decay_handle = decay_handle;

guidata(hObject,handles);


% --- Executes on button press in SetActiveRegion_pushbutton.
function SetActiveRegion_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to SetActiveRegion_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%currently selected image
selected = get(handles.ImageSelection_slider,'Value');
selected_pixel = handles.image_struct{selected}.selected_pixel;
selected_pixel_handle = handles.image_struct{selected}.selected_pixel_handle;
flim = handles.image_struct{selected}.flim;
decay = handles.image_struct{selected}.decay;
decay_handle = handles.image_struct{selected}.decay_handle;
active_region = handles.image_struct{selected}.active_region;
active_region_handle = handles.image_struct{selected}.active_region_handle;
dt = handles.image_struct{selected}.dt;

update_gui(handles,0,1)

%time axis
time = (1:length(decay))'*dt;

button=1;

% Pick two vertices to define rectangular active region
vert = zeros(4,2);

[x,y,button]=ginput(1);
if button == 1
    x = round(x); y = round(y);
    
    vert(1,1) = x;
    vert(1,2) = y;
    vert(2,2) = y;
    vert(4,1) = x;
    
    
    [x,y,button]=ginput(1);
    x = round(x); y = round(y);
    
    vert(3,1) = x;
    vert(3,2) = y;
    vert(2,1) = x;
    vert(4,2) = y;
    
    active_region = vert;
    
    set(handles.MainGui,'CurrentAxes',handles.Image_axes);
    if isempty(active_region_handle) == 0
        delete(active_region_handle)
    end
    active_region_handle = line([vert(:,1);vert(1,1)],[vert(:,2);vert(1,2)],'LineWidth',2,'Color','w');
    
    lower_lim = min(active_region,[],1);
    higher_lim = max(active_region,[],1);
    x_min = lower_lim(1);
    y_min = lower_lim(2);
    x_max = higher_lim(1);
    y_max = higher_lim(2);
    
    reshapedselectedpix = repmat(reshape(selected_pixel',[1,size(selected_pixel')]),[length(decay),1,1]);
    decay = sum(sum(reshapedselectedpix(:,y_min:y_max,x_min:x_max).*flim(:,y_min:y_max,x_min:x_max),2),3);

    
    set(handles.MainGui,'CurrentAxes',handles.Decay_axes);
    if ishandle(decay_handle);
        delete(decay_handle)
    end
    decay_handle = semilogy(time,decay,'.');
    hold on;
    
    %update total counts
    set(handles.TotalCount_text,'String',num2str(sum(decay)))
    %update total number of selected pixel
    set(handles.NumOfSelectedPixel_text,'String',num2str(sum(sum(selected_pixel(x_min:x_max,y_min:y_max)))))
    
    %update handles
    handles.image_struct{selected}.active_region = active_region;
    handles.image_struct{selected}.active_region_handle = active_region_handle;
    handles.image_struct{selected}.decay = decay;
    handles.image_struct{selected}.decay_handle = decay_handle;
    
    guidata(hObject,handles);
end


% --- Executes on button press in RemoveActiveRegion_pushbutton.
function RemoveActiveRegion_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to RemoveActiveRegion_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
selected = get(handles.ImageSelection_slider,'Value');
selected_pixel = handles.image_struct{selected}.selected_pixel;
selected_pixel_handle = handles.image_struct{selected}.selected_pixel_handle;
flim = handles.image_struct{selected}.flim;
decay = handles.image_struct{selected}.decay;
decay_handle = handles.image_struct{selected}.decay_handle;
dt = handles.image_struct{selected}.dt;

%time axis
time = (1:length(decay))'*dt;

active_region = handles.image_struct{selected}.active_region;
active_region_handle = handles.image_struct{selected}.active_region_handle;

if isempty(active_region) ==0
    
    active_region = [];
    
    set(handles.MainGui,'CurrentAxes',handles.Image_axes);
    delete(active_region_handle);
    active_region_handle = [];
    
    reshapedselectedpix = repmat(reshape(selected_pixel',[1,size(selected_pixel')]),[length(decay),1,1]);
%    decay = sum(sum(reshapedselectedpix(:,y_min:y_max,x_min:x_max).*flim(:,y_min:y_max,x_min:x_max),2),3);
    decay = sum(sum(reshapedselectedpix.*flim,2),3);

    
    set(handles.MainGui,'CurrentAxes',handles.Decay_axes);
    if ishandle(decay_handle);
        delete(decay_handle)
    end
    decay_handle = semilogy(time,decay,'.');
    hold on;
    set(handles.TotalCount_text,'String',num2str(sum(decay)))
    
    handles.image_struct{selected}.active_region = active_region;
    handles.image_struct{selected}.active_region_handle = active_region_handle;
    handles.image_struct{selected}.decay_handle = decay_handle;
    handles.image_struct{selected}.decay = decay;
    
    %update total counts
    set(handles.TotalCount_text,'String',num2str(sum(decay)))
    %update total number of selected pixel
    set(handles.NumOfSelectedPixel_text,'String',num2str(sum(sum(selected_pixel))))
    
    guidata(hObject,handles);
    
end


% --- Executes on button press in SameActiveRegion_pushbutton.
function SameActiveRegion_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to SameActiveRegion_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
current = get(handles.ImageSelection_slider,'Value');
selected = get(handles.FileName_listbox,'Value');
current_decay = handles.image_struct{current}.decay;
current_active_region = handles.image_struct{current}.active_region;
vert = current_active_region;

if isempty(current_active_region)==0
    lower_lim = min(current_active_region,[],1);
    higher_lim = max(current_active_region,[],1);
    x_min = lower_lim(1);
    y_min = lower_lim(2);
    x_max = higher_lim(1);
    y_max = higher_lim(2);
    
    
    for i = selected(selected~=current)
        
        %time axis
        dt = handles.image_struct{i}.dt;
        time = (1:length(current_decay))'*dt;
        
        set(handles.MainGui,'CurrentAxes',handles.Image_axes);
        active_region_handle = line([vert(:,1);vert(1,1)],[vert(:,2);vert(1,2)],'LineWidth',2,'Color','w');
        set(active_region_handle,'Visible','off');
        
        flim = handles.image_struct{i}.flim;
        decay_data = handles.image_struct{i}.decay;
        selected_pixel = handles.image_struct{i}.selected_pixel;
        decay_handle = handles.image_struct{i}.decay_handle;
        
        reshapedselectedpix = repmat(reshape(selected_pixel',[1,size(selected_pixel')]),[length(decay_data),1,1]);
        decay_data = sum(sum(reshapedselectedpix(:,y_min:y_max,x_min:x_max).*flim(:,y_min:y_max,x_min:x_max),2),3);

        
        set(handles.MainGui,'CurrentAxes',handles.Decay_axes);
        if ishandle(decay_handle);
            delete(decay_handle)
        end
        decay_handle = semilogy(time,decay_data,'.');
        hold on;
        set(decay_handle,'Visible','off')
        
        %update handles
        handles.image_struct{i}.active_region = current_active_region;
        handles.image_struct{i}.active_region_handle = active_region_handle;
        handles.image_struct{i}.decay = decay_data;
        handles.image_struct{i}.decay_handle = decay_handle;
        
    end
end

guidata(hObject,handles);

% --- Executes on button press in SameSelectedPixel_pushbutton.
function SameSelectedPixel_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to SameSelectedPixel_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
selected = get(handles.FileName_listbox,'Value');
current = get(handles.ImageSelection_slider,'Value');
current_selectd_pix = handles.image_struct{current}.selected_pixel;
current_decay = handles.image_struct{current}.decay;

for i = selected(selected~=current)
    %time axis
    dt = handles.image_struct{i}.dt;
    time = (1:length(current_decay))'*dt;
    
    active_region = handles.image_struct{i}.active_region;
    img = handles.image_struct{i}.image;
    
    if isempty(active_region)
        active_region = [1,1;size(img,2),1;size(img,1),size(img,2);1,size(img,2)];
    end
    
    lower_lim = min(active_region,[],1);
    higher_lim = max(active_region,[],1);
    x_min = lower_lim(1);
    y_min = lower_lim(2);
    x_max = higher_lim(1);
    y_max = higher_lim(2);
    
    selected_pixel = current_selectd_pix;
    [xx,yy] = find(selected_pixel==1);
    
    set(handles.MainGui,'CurrentAxes',handles.Image_axes);
    selected_pixel_handle = plot(xx,yy,'ws','MarkerSize',5);
    set(selected_pixel_handle,'Visible','off');
    
    flim = handles.image_struct{i}.flim;
    decay_data = handles.image_struct{i}.decay;
    decay_handle = handles.image_struct{i}.decay_handle;
    
    reshapedselectedpix = repmat(reshape(selected_pixel',[1,size(selected_pixel')]),[length(decay_data),1,1]);
    decay_data = sum(sum(reshapedselectedpix(:,y_min:y_max,x_min:x_max).*flim(:,y_min:y_max,x_min:x_max),2),3);

    
    set(handles.MainGui,'CurrentAxes',handles.Decay_axes);
    if ishandle(decay_handle);
        delete(decay_handle)
    end

    
    decay_handle = semilogy(time,decay_data,'.');
    hold on;
    set(decay_handle,'Visible','off')
    
    
    %update handles
    handles.image_struct{i}.selected_pixel = selected_pixel;
    handles.image_struct{i}.selected_pixel_handle = selected_pixel_handle;
    handles.image_struct{i}.decay = decay_data;
    handles.image_struct{i}.decay_handle = decay_handle;
end
guidata(hObject,handles);



% --- Executes on button press in KinetochoreSelection_pushbutton.
function KinetochoreSelection_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to KinetochoreSelection_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


figname = 'KinetochoreSelectionTool_ver4_5';
hfig = CheckOpenState(figname);
if hfig ~= -99
    choice = questdlg([figname ' is currently open. Pressing "Yes" will delete the data previously in ',figname,' and open new one.'],'!Already opened!');
    if strcmp(choice,'Yes')==0
        return;
    else
        close(hfig)
    end
end

selected = get(handles.FileName_listbox,'Value');

image_struct = handles.image_struct;

if isempty(image_struct)
    errordlg('Open and choose image first')
    return;
end

N_frame = length(selected);

%Frames of interst
FOI = cell(length(selected),1);
for j = 1:length(selected)
    FOI{j} = image_struct{selected(j)};
end



%batch filename
eg_fname = image_struct{selected(1)}.filename;
eg_fname = eg_fname(1:(end-8));

%Example repeat time
ind = findstr(eg_fname,'repeat');
tempind = findstr(eg_fname,'sec');
ind2 = tempind(tempind>ind);
if (isempty(ind) & isempty(ind2)) == 0 
    eg_repeat = eg_fname((ind+6):(ind2-1));
else
    eg_repeat = 15;
end


prompt = {'Repeat time (sec)','Magnification (e.g. 60)'...
    'Zoom Factor','Pixel Size (optional)'};
dlg_title = 'Kinetochore Analysis';
num_lines = 1;
def = {num2str(eg_repeat),'40','32',''};
answer = inputdlg(prompt,dlg_title,num_lines,def);

if isempty(answer)
    return;
end

repeat = str2double(answer{1});
mag = str2double(answer{2});
zm = str2double(answer{3});
pixsize = answer{4};

% field of view is 440um for 1x zoom, 40x objective
if isempty(pixsize) || isNaN(pixsize)
    pixsize = 440*40/mag/zm/size(FOI{1}.image,1);
else
    pixsize = str2double(pixsize);
end



setappdata(0  , 'hMainGui'    , gcf);
setappdata(gcf, 'N_frame', N_frame);
setappdata(gcf, 'FOI', FOI);
setappdata(gcf, 'selected',selected);
setappdata(gcf, 'pixsize', pixsize);
setappdata(gcf, 'repeat', repeat);

eval([figname,'(''MainGui'',handles.MainGui)'])


% --- Executes on button press in SaveSelectedDecays_pushbutton.
function SaveSelectedDecays_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to SaveSelectedDecays_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

selected = get(handles.ImageSelection_slider,'Value');
image_struct = handles.image_struct;
saved_decay = handles.saved_decay;
NumOfSavedDecays = handles.NumOfSavedDecays;    

%Example batch filename
eg_fname = image_struct{selected}.filename;
eg_fname = eg_fname(1:(end-8));
namelen = length(eg_fname);

%Example number of frame
namelist = get(handles.FileName_listbox,'String');
TF = strncmp(namelist,eg_fname,namelen);
eg_Nframe = sum(TF)+(sum(TF)==0)*10;


prompt = {'Image batch file name:','Frame numbers (e.g. 1:2:9):',...
    'Decay batch name:'};
dlg_title = 'Batch Decay Save';
num_lines = 1;
def = {eg_fname,['1:',num2str(eg_Nframe)],eg_fname(1:2)};
answer = inputdlg(prompt,dlg_title,num_lines,def);

if isempty(answer)
    return;
end

batchfname = answer{1};
framenum = str2num(answer{2});
decaybatchname = answer{3};

for i = framenum
    fname = [batchfname,'_c',num2str(i,'%02d'),'.sdt'];
%    fname = [batchfname,'_c',num2str(i),'.sdt'];
    ind = find(strcmp(namelist,fname)==1);
    if isempty(ind)
        errordlg('image not found, check frame number')
        return;
    end
    img = image_struct{ind}.image;
    decay = image_struct{ind}.decay;
    filename = image_struct{ind}.filename;
    selected_pixel = image_struct{ind}.selected_pixel;
    dt = image_struct{ind}.dt;
    
    decay_name = [decaybatchname, '_c', num2str(i,'%02d')];
    
    if NumOfSavedDecays == 0;
        set(handles.SavedDecay_listbox,'String',{decay_name})
        %Enable pushbuttons
        Switch_pushbuttons(handles,'on','decay')
    else
        names = get(handles.SavedDecay_listbox,'String');
        set(handles.SavedDecay_listbox,'String',[names;{decay_name}])
    end
    
    decay_to_save = cell(1,1);
    decay_to_save{1}.decay = decay;
    decay_to_save{1}.name = decay_name;
    decay_to_save{1}.filename = filename;
    decay_to_save{1}.image = img;
    decay_to_save{1}.selected_pixel = selected_pixel;
    
    NumOfSavedDecays = NumOfSavedDecays + 1;
    
    %time axis
    time = (1:length(decay))'*dt;
    
    decay_to_save{1}.time = time;
    
    set(handles.MainGui,'CurrentAxes',handles.Decay_axes)
    decay_handle = semilogy(time,decay,'.');
    set(decay_handle,'Visible','off');
    
    decay_to_save{1}.decay_handle = decay_handle;
    
    saved_decay = [saved_decay;decay_to_save];
    
end

handles.saved_decay = saved_decay;
handles.NumOfSavedDecays = NumOfSavedDecays;

set(handles.SavedDecay_listbox,'Min',1)
set(handles.SavedDecay_listbox,'Max',NumOfSavedDecays+2)

set(handles.SavedDecay_listbox, 'Value', NumOfSavedDecays);


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

NumOfImages = handles.NumOfImages;

if NumOfImages>0
    value = get(hObject,'Value');
    set(handles.ImageSelection_slider,'Value',value);
    
    update_gui(handles,1,1);
    
    
    %update slider previous value
    handles.previous_value = value;
    
end

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





%% Decay handling
% --- Executes on button press in SaveDecay_pushbutton.
function SaveDecay_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to SaveDecay_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
selected = get(handles.Filename_popupmenu,'Value');
NumOfSavedDecays = handles.NumOfSavedDecays;
filename = handles.image_struct{selected}.filename;
decay = handles.image_struct{selected}.decay;
decay_name = get(handles.DecayName_edit,'String');
saved_decay = handles.saved_decay;
img = handles.image_struct{selected}.image;
selected_pixel = handles.image_struct{selected}.selected_pixel;
dt = handles.image_struct{selected}.dt;

if isempty(decay_name)
    decay_name = {['decay' num2str(NumOfSavedDecays+1)]};
end

if NumOfSavedDecays == 0;
    set(handles.SavedDecay_listbox,'String',{decay_name})
    %Enable pushbuttons
    Switch_pushbuttons(handles,'on','decay')
else
    names = get(handles.SavedDecay_listbox,'String');
    set(handles.SavedDecay_listbox,'String',[names;{decay_name}])
end

decay_to_save = cell(1,1);
decay_to_save{1}.decay = decay;
decay_to_save{1}.name = decay_name;
decay_to_save{1}.filename = filename;
decay_to_save{1}.image = img;
decay_to_save{1}.selected_pixel = selected_pixel;

NumOfSavedDecays = NumOfSavedDecays + 1;

%time axis
time = (1:length(decay))'*dt;

decay_to_save{1}.time = time;

set(handles.MainGui,'CurrentAxes',handles.Decay_axes)
decay_handle = semilogy(time,decay,'.');
set(decay_handle,'Visible','off');

decay_to_save{1}.decay_handle = decay_handle;

saved_decay = [saved_decay;decay_to_save];

handles.saved_decay = saved_decay;
handles.NumOfSavedDecays = NumOfSavedDecays;

set(handles.SavedDecay_listbox,'Min',1)
set(handles.SavedDecay_listbox,'Max',NumOfSavedDecays+2)

set(handles.SavedDecay_listbox, 'Value', NumOfSavedDecays);

guidata(hObject,handles)



% --- Executes on button press in DeleteDecay_pushbutton.
function DeleteDecay_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to DeleteDecay_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
decay_sel =  get(handles.SavedDecay_listbox,'Value');
NumOfSavedDecays = handles.NumOfSavedDecays;

set(handles.MainGui,'CurrentAxes',handles.Decay_axes)

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
    Switch_pushbuttons(handles,'off','decay')
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
    
    save('reference_decay','decay','decay_struct');
end

% --- Executes on button press in SetIRF_pushbutton.
function SetIRF_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to SetIRF_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



decay_sel = get(handles.SavedDecay_listbox,'Value');


prompt = {'Peak region (from)','Peak region (to)',...
    'Constant Background region (from)','Constant Background region (to)'};
dlg_title = 'Save IRF setting';
num_lines = 1;
def = {'1.5','3','7','9'};
answer = inputdlg(prompt,dlg_title,num_lines,def);

if isempty(answer)
    return;
end

peakfrom = str2num(answer{1});
peakto = str2num(answer{2});
backgrfrom = str2num(answer{3});
backgrto = str2num(answer{4});

[name pathname filterindex] = uiputfile('IRF/*.mat');

if length(decay_sel) > 1
    errordlg('Select a single decay')
else
    decay = handles.saved_decay{decay_sel}.decay;
    time = handles.saved_decay{decay_sel}.time;
    decay_struct = handles.saved_decay{decay_sel};
    
    backgr = mean(decay(time>backgrfrom & time<backgrto));
    decay(time<peakfrom | time>peakto) = 0;
    decay(time>=peakfrom & time<=peakto) =...
        max(decay(time>=peakfrom & time<=peakto) - backgr,0);
    
    
    save(['IRF/' name],'decay','time','decay_struct');
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
    
    decay_struct = saved_decay(decay_sel);
    
    save([pathname name],'decay_struct')
end


% --- Executes on button press in ImportDecay_pushbutton.
function ImportDecay_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to ImportDecay_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[name pathname filterindex] = uigetfile2('*.mat');
if name ~= 0
    load([pathname name]);
    imported_decay = decay_struct;
    saved_decay = handles.saved_decay;
    NumOfSavedDecays = handles.NumOfSavedDecays;
    
    set(handles.MainGui,'CurrentAxes',handles.Decay_axes)
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
        Switch_pushbuttons(handles,'on','decay')
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



% --- Executes on button press in ShowImage_pushbutton.
function ShowImage_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to ShowImage_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
decay_sel = get(handles.SavedDecay_listbox,'Value');
saveornot = get(handles.SaveImage_checkbox,'Value');

if saveornot == 0
    for i = decay_sel
        decay_struct = handles.saved_decay{i};
        fnames = fieldnames(decay_struct);
        
        if sum(strcmp(fnames,'image'))==0
            errordlg([decay_struct.name, ': No corresponding image to show'])
        else
            img = double(decay_struct.image);
            selected_pixel = decay_struct.selected_pixel;
            %            [max_x,max_y] = find(img == max(max(img)));
            
            normimg = img;
            normimg(:,:,1) = normimg(:,:,1)/max(max(normimg(:,:,1)));
            normimg(:,:,2) = normimg(:,:,2)/max(max(normimg(:,:,2)));
            h = figure;
            imagesc(normimg);
%            colormap(gray);
%            axis([max_y(1)-90,max_y(1)+90,max_x(1)-90, max_x(1)+90])
            %axis([128-60,128+60,128-60,128+60])
            axis image;
            hold on;
            [xx,yy] = find(selected_pixel == 1);
            plot(xx,yy,'ws','MarkerSize',5)
            
            scrsz = get(0,'ScreenSize');
            set(h,'Position',[100 scrsz(4)/2-100 scrsz(3)/2 scrsz(4)/2])
            colorbar
            
        end
    end
else
    load('lastUsedDir.mat');
    pathname = uigetdir(lastUsedDir,'Choose a folder to save results');
    
    if pathname ~= 0
        for i = decay_sel
            decay_struct = handles.saved_decay{i};
            fnames = fieldnames(decay_struct);
            
            if sum(strcmp(fnames,'image'))==0
                errordlg([decay_struct.name, ': No corresponding image to show'])
            else
                img = decay_struct.image;
                selected_pixel = decay_struct.selected_pixel;
                %                [max_x,max_y] = find(img == max(max(img)));
                normimg = img;
                normimg(:,:,1) = normimg(:,:,1)/max(max(normimg(:,:,1)));
                normimg(:,:,2) = normimg(:,:,2)/max(max(normimg(:,:,2)));
                h = figure;
                imagesc(normimg);
%                colormap(gray);
%                axis([max_y(1)-60,max_y(1)+60,max_x(1)-60, max_x(1)+60])
                axis image;
                colorbar;
                hold on;
                [xx,yy] = find(selected_pixel == 1);
                plot(xx,yy,'ws','MarkerSize',5)
                
                scrsz = get(0,'ScreenSize');
                set(h,'Position',[100 scrsz(4)/2-100 scrsz(3)/2 scrsz(4)/2])
                
                print(h,'-dpng',[pathname,'/',decay_struct.name,'_img'])
                
                close(h);
            end
        end
    end
end

guidata(hObject,handles)

% --- Executes on button press in FitDecay_pushbutton.
function FitDecay_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to FitDecay_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

figname = 'FittingGUI_ver3_5';
hfig = CheckOpenState(figname);
if hfig ~= -99
    choice = questdlg([figname ' is currently open. Pressing "Yes" will delete the data previously in ',figname,' and open new one.'],'!Already opened!');
    if strcmp(choice,'Yes')==0
        return;
    else
        close(hfig)
    end
end

decay_sel = get(handles.SavedDecay_listbox,'Value');
decay_struct = handles.saved_decay(decay_sel);

save('decay_to_fit.mat','decay_struct');

currentFolder = pwd;
eval(figname)



% --- Executes on button press in ExportPhasor_pushbutton.
function ExportPhasor_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to ExportPhasor_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

decay_sel = get(handles.SavedDecay_listbox,'Value');
freq = str2double(get(handles.LaserRepRate_edit,'String'));
load_ref = load('reference_decay');
ref = load_ref.decay;
ref_tau = str2double(get(handles.RefTau_edit,'String'))*1E-9;
decay_struct = handles.saved_decay(decay_sel);
dt = decay_struct{1}.time(2)-decay_struct{1}.time(1);

save('decay_to_phasor.mat','dt','freq','ref','ref_tau','decay_struct');

currentFolder = pwd;
run([currentFolder '/PhasorPlot.m'])





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
function MainGui_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to MainGui (see GCBO)
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





% --- Executes during object creation, after setting all properties.
function SelectAbove_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SelectAbove_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function SelectAbove_edit_Callback(hObject, eventdata, handles)
% hObject    handle to SelectAbove_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SelectAbove_edit as text
%        str2double(get(hObject,'String')) returns contents of SelectAbove_edit as a double



% --- Executes on button press in SaveImage_checkbox.
function SaveImage_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to SaveImage_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of SaveImage_checkbox



function SelectBelow_edit_Callback(hObject, eventdata, handles)
% hObject    handle to SelectBelow_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SelectBelow_edit as text
%        str2double(get(hObject,'String')) returns contents of SelectBelow_edit as a double


% --- Executes during object creation, after setting all properties.
function SelectBelow_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SelectBelow_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in FileName_listbox.
function FileName_listbox_Callback(hObject, eventdata, handles)
% hObject    handle to FileName_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns FileName_listbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from FileName_listbox


% --- Executes when user attempts to close MainGui.
function MainGui_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to MainGui (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
delete(hObject);



