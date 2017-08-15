function varargout = KinetochoreSelectionTool_ver2_1(varargin)
% KINETOCHORESELECTIONTOOL_VER2_1 MATLAB code for KinetochoreSelectionTool_ver2_1.fig
%      KINETOCHORESELECTIONTOOL_VER2_1, by itself, creates a new KINETOCHORESELECTIONTOOL_VER2_1 or raises the existing
%      singleton*.
%
%      H = KINETOCHORESELECTIONTOOL_VER2_1 returns the handle to a new KINETOCHORESELECTIONTOOL_VER2_1 or the handle to
%      the existing singleton*.
%
%      KINETOCHORESELECTIONTOOL_VER2_1('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in KINETOCHORESELECTIONTOOL_VER2_1.M with the given input arguments.
%
%      KINETOCHORESELECTIONTOOL_VER2_1('Property','Value',...) creates a new KINETOCHORESELECTIONTOOL_VER2_1 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before KinetochoreSelectionTool_ver2_1_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to KinetochoreSelectionTool_ver2_1_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help KinetochoreSelectionTool_ver2_1

% Last Modified by GUIDE v2.5 04-Sep-2013 11:37:22

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @KinetochoreSelectionTool_ver2_1_OpeningFcn, ...
    'gui_OutputFcn',  @KinetochoreSelectionTool_ver2_1_OutputFcn, ...
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


% --- Executes just before KinetochoreSelectionTool_ver2_1 is made visible.
function KinetochoreSelectionTool_ver2_1_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to KinetochoreSelectionTool_ver2_1 (see VARARGIN)

% Choose default command line output for KinetochoreSelectionTool_ver2_1
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes KinetochoreSelectionTool_ver2_1 wait for user response (see UIRESUME)
% uiwait(handles.KinetochoreSelectionGui);

addpath tracking_Kilfoil


dontOpen = false;
mainGuiInput = find(strcmp(varargin, 'MainGui'));
if (isempty(mainGuiInput)) ...
        || (length(varargin) <= mainGuiInput) ...
        || (~ishandle(varargin{mainGuiInput+1}))
    dontOpen = true;
else
    % Remember the handle, and adjust our position
    handles.MainGui = varargin{mainGuiInput+1};
    
    hMainGui = getappdata(0,'hMainGui');
    FOI = getappdata(hMainGui,'FOI');
    N_frame = getappdata(hMainGui,'N_frame');
    repeat = getappdata(hMainGui,'repeat');
    pixsize = getappdata(hMainGui,'pixsize');
    
    frame = cell(N_frame,1);
    
    
    axes(handles.Image_axes);
    for i = 1:N_frame
        frame{i}.image = FOI{i}.image;
        frame{i}.image_handle = imagesc(frame{i}.image);
        frame{i}.filename = FOI{i}.filename;
        frame{i}.dt = FOI{i}.dt;
        frame{i}.flim = FOI{i}.flim;
        
        colormap(gray)
        img_size = size(frame{i}.image);
        axis([1,img_size(2),1,img_size(1)]);    colorbar;    set(gca,'FontSize',15);
        caxis auto;
        hold on;
        set(frame{i}.image_handle,'Visible','off');
        
        frame{i}.selected_pixel{i} = zeros(size(FOI{i}.selected_pixel));
        
        %id of kinetochore structures in a frame
        frame{i}.kin_id = [];
        frame{i}.N_kin = 0;
        %selected pixel plot handle and text handle of each kinetochore in a frame
        frame{i}.selected_pixel_handle = [];
        frame{i}.text_handle=[];
    end
    
    %Add scale bar
    scalebar_handle = zeros(2,1);
    %in micrometer
    barsize = 2;
    scalebar_handle(1) = line([0.9*img_size(2)-round(barsize/pixsize),0.9*img_size(2)],...
        [0.9*img_size(1),0.9*img_size(1)],'LineWidth',2,'Color','Yellow');
    scalebar_handle(2) = text(0.9*img_size(2)-round(barsize/pixsize),0.9*img_size(1)-5,...
        [num2str(barsize), '{\mu}', 'm'],'Color','yellow','fontsize',12);
    
    %Add real time
    time_handle = text(0.1*img_size(2),0.1*img_size(1),[num2str((i-1)*repeat),' sec'],'fontsize',12,...
        'Color','y');
    
    
    if get(handles.Scalebar_checkbox,'Value')
        set(scalebar_handle,'Visible','on');
    else
        set(scalebar_handle,'Visible','off');
    end
    
    if get(handles.ShowTime_checkbox,'Value')
        set(time_handle,'Visible','on');
    else
        set(time_handle,'Visible','off');
    end

    
    %image select slider
    set(handles.FrameSelection_slider,'Min',1);
    set(handles.FrameSelection_slider,'Max',max(N_frame,2));
    set(handles.FrameSelection_slider,'Value',1);
    set(handles.FrameSelection_slider,'SliderStep',[1,1]/(max(N_frame,2)-1))
    if N_frame>1
        set(handles.FrameSelection_slider,'Visible','on');
    else
        set(handles.FrameSelection_slider,'Visible','off');
    end
    set(frame{1}.image_handle,'Visible','on');
    
    %update the handles
    handles.hMainGui = hMainGui;
    handles.FOI = FOI;
    handles.N_frame = N_frame;
    handles.frame = frame;
    handles.ROI = [];
    handles.ROI_handle = [];
    handles.spaxis_handle = [];
    handles.spaxis = [];
    handles.kinpair = [];
    handles.repeat = repeat;
    handles.pixsize = pixsize;
    handles.scalebar_handle = scalebar_handle;
    handles.time_handle = time_handle;
    
    %all kinetochore structures
    handles.kin = [];
    
    set(handles.FrameNumber_text,'String',['1 out of ' num2str(N_frame)]);
    
end

% Update handles structure
guidata(hObject, handles);

if dontOpen
    disp('-----------------------------------------------------');
    disp('Improper input arguments. Pass a property value pair')
    disp('whose name is "MainGui" and value is the handle')
    disp('to the changeme_main figure');
    disp('-----------------------------------------------------');
else
    %   uiwait(hObject);
end




% --- Outputs from this function are returned to the command line.
function varargout = KinetochoreSelectionTool_ver2_1_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in Kinetochore_listbox.
function Kinetochore_listbox_Callback(hObject, eventdata, handles)
% hObject    handle to Kinetochore_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns Kinetochore_listbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Kinetochore_listbox


% --- Executes during object creation, after setting all properties.
function Kinetochore_listbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Kinetochore_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function FeatureSize_edit_Callback(hObject, eventdata, handles)
% hObject    handle to FeatureSize_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of FeatureSize_edit as text
%        str2double(get(hObject,'String')) returns contents of FeatureSize_edit as a double


% --- Executes during object creation, after setting all properties.
function FeatureSize_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FeatureSize_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function MinIntegratedIntensity_edit_Callback(hObject, eventdata, handles)
% hObject    handle to MinIntegratedIntensity_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MinIntegratedIntensity_edit as text
%        str2double(get(hObject,'String')) returns contents of MinIntegratedIntensity_edit as a double


% --- Executes during object creation, after setting all properties.
function MinIntegratedIntensity_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MinIntegratedIntensity_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function MaxRgSquared_edit_Callback(hObject, eventdata, handles)
% hObject    handle to MaxRgSquared_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MaxRgSquared_edit as text
%        str2double(get(hObject,'String')) returns contents of MaxRgSquared_edit as a double


% --- Executes during object creation, after setting all properties.
function MaxRgSquared_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MaxRgSquared_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function MaxEccentricity_edit_Callback(hObject, eventdata, handles)
% hObject    handle to MaxEccentricity_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MaxEccentricity_edit as text
%        str2double(get(hObject,'String')) returns contents of MaxEccentricity_edit as a double


% --- Executes during object creation, after setting all properties.
function MaxEccentricity_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MaxEccentricity_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function MinIdivRg_edit_Callback(hObject, eventdata, handles)
% hObject    handle to MinIdivRg_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MinIdivRg_edit as text
%        str2double(get(hObject,'String')) returns contents of MinIdivRg_edit as a double


% --- Executes during object creation, after setting all properties.
function MinIdivRg_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MinIdivRg_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function MinLocalImax_edit_Callback(hObject, eventdata, handles)
% hObject    handle to MinLocalImax_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MinLocalImax_edit as text
%        str2double(get(hObject,'String')) returns contents of MinLocalImax_edit as a double


% --- Executes during object creation, after setting all properties.
function MinLocalImax_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MinLocalImax_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Masscut_edit_Callback(hObject, eventdata, handles)
% hObject    handle to Masscut_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Masscut_edit as text
%        str2double(get(hObject,'String')) returns contents of Masscut_edit as a double


% --- Executes during object creation, after setting all properties.
function Masscut_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Masscut_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Field_edit_Callback(hObject, eventdata, handles)
% hObject    handle to Field_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Field_edit as text
%        str2double(get(hObject,'String')) returns contents of Field_edit as a double


% --- Executes during object creation, after setting all properties.
function Field_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Field_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function FramePeriod_edit_Callback(hObject, eventdata, handles)
% hObject    handle to FramePeriod_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of FramePeriod_edit as text
%        str2double(get(hObject,'String')) returns contents of FramePeriod_edit as a double


% --- Executes during object creation, after setting all properties.
function FramePeriod_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FramePeriod_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in TestSetting_pushbutton.
function TestSetting_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to TestSetting_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
featsize = str2double(get(handles.FeatureSize_edit,'String'));
barint = str2double(get(handles.MinIntegratedIntensity_edit,'String'));
barrg = str2double(get(handles.MaxRgSquared_edit,'String'));
barcc = str2double(get(handles.MaxEccentricity_edit,'String'));
IdivRg = str2double(get(handles.MinIdivRg_edit,'String'));
masscut = str2double(get(handles.Masscut_edit,'String'));
Imin = str2double(get(handles.MinLocalImax_edit,'String'));
field = str2double(get(handles.Field_edit,'String'));

selected = get(handles.FrameSelection_slider,'Value');
img = handles.frame{selected}.image;
ROI = handles.ROI;

if isempty(ROI)
    errordlg('Set ROI first')
    return
end

img_ROI = img(min(ROI(:,2)):max(ROI(:,2)),min(ROI(:,1)):max(ROI(:,1)));

d=0;
MT=[];
Mrej=[];


M = feature2D(img_ROI,1,featsize,masscut,Imin,field);

if M == -1
    errordlg('Failed to find local minimum. Try different setting')
    return
end

a = length(M(:,1));

M2=M;
for i=1:a
    if ((M(i,5)>barcc))
        Mrej=[Mrej; M(i,:)];
        M(i,1:5)=0;
        %          end
        
    elseif ((M(i,4)>barrg))
        Mrej=[Mrej; M(i,:)];
        M(i,1:5)=0;
        %          end
        
    elseif ((M(i,3)<barint))
        Mrej=[Mrej; M(i,:)];
        M(i,1:5)=0;
    elseif((M(i,3)/M(i,4)<IdivRg))
        Mrej=[Mrej; M(i,:)];
        M(i,1:5)=0;
    end
end

%    Deleting the zero rows

M=M(M(:,1)~=0,:);

a = length(M(:,1));

MT(d+1:a+d, 1:5)=M(1:a,1:5);

figure;
imagesc(img_ROI),colormap(gray);
hold on

% Making a circle the size of the feature around each feature.

theta = 0:0.001:2*pi;
for c = 1:length(M(:,1))
    cx = M(c,1) + featsize*cos(theta)*2;
    cy = M(c,2) + featsize*sin(theta)*2;
    plot(cx,cy,'g-','linewidth',1.5)
end
if( ~isempty(Mrej)>0 )
    plot( Mrej(:,1), Mrej(:,2), 'r.' );
end

axis image;

format short g
disp(M)
disp(['Kept : ' num2str(size(M,1))])
disp(Mrej)
disp(['Minimum Intensity : ' num2str(min(M(:,3)))])
disp(['Maximum Rg : ' num2str(max(M(:,4)))])
disp(['Maximum Eccentricity : ' num2str(max(M(:,5)))])



% --- Executes on slider movement.
function FrameSelection_slider_Callback(hObject, eventdata, handles)
% hObject    handle to FrameSelection_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

selected = round(get(hObject,'Value'));
set(hObject,'Value',selected);
frame = handles.frame;
N_frame = handles.N_frame;
kin = handles.kin;

axes(handles.Image_axes);
for i = 1:N_frame
    set(frame{i}.image_handle,'Visible','off')
    
    if frame{i}.N_kin > 0
        set(frame{i}.selected_pixel_handle,'Visible','off')
        set(frame{i}.text_handle,'Visible','off')
    end
end

set(frame{selected}.image_handle,'Visible','on');
if frame{selected}.N_kin > 0
    set(frame{selected}.selected_pixel_handle,'Visible','on')
    set(frame{selected}.text_handle,'Visible','on')
end

set(handles.FrameNumber_text,'String',[num2str(selected) ' out of ' num2str(N_frame)]);

guidata(hObject,handles)


% --- Executes during object creation, after setting all properties.
function FrameSelection_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FrameSelection_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in FindKinetochore_pushbutton.
function FindKinetochore_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to FindKinetochore_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
featsize = str2double(get(handles.FeatureSize_edit,'String'));
barint = str2double(get(handles.MinIntegratedIntensity_edit,'String'));
barrg = str2double(get(handles.MaxRgSquared_edit,'String'));
barcc = str2double(get(handles.MaxEccentricity_edit,'String'));
IdivRg = str2double(get(handles.MinIdivRg_edit,'String'));
masscut = str2double(get(handles.Masscut_edit,'String'));
Imin = str2double(get(handles.MinLocalImax_edit,'String'));
field = str2double(get(handles.Field_edit,'String'));

maxdisp = str2double(get(handles.MaxDisplacement_edit,'String'));
goodenough = str2double(get(handles.GoodEnough_edit,'String'));
coverage = str2double(get(handles.Coverage_edit,'String'));

selected = get(handles.FrameSelection_slider,'Value');
N_frame = handles.N_frame;
ROI = handles.ROI;

if isempty(ROI)
    errordlg('Set ROI first')
    return
end

period = handles.repeat;
frame = handles.frame;
img_size = size(frame{1}.image);

time = (0:(N_frame-1))'*period;

tic,

d=0;


axes(handles.Image_axes)

for i = 1:N_frame
    img = handles.frame{i}.image;
    img_ROI = img(min(ROI(:,2)):max(ROI(:,2)),min(ROI(:,1)):max(ROI(:,1)));
    
    M = feature2D(img_ROI,1,featsize,masscut,Imin,field);
    
    if mod(i,50) == 0
        disp(['Frame ' num2str(i)])
    end
    
    [a,b]=size(M);
    
    if( b == 5 )
        %Rejection process
        M(M(:,5)>barcc,1:5)=0;
        M(M(:,4)>barrg,1:5)=0;
        M(M(:,3)<barint,1:5)=0;
        M(M(:,3)./M(:,4)<IdivRg,1:5)=0;
        
        M=M(M(:,1)~=0,:);
        
        a = length(M(:,1));
        
        MT(d+1:a+d, 1:5)=M(1:a,1:5);
        MT(d+1:a+d, 6)=i;
        MT(d+1:a+d, 7)=time(i);
        d = length(MT(:,1));
        disp([num2str(a) ' features kept.'])
    end
    clear img;
    clear R;
    clear M;
    clear pic;
    clear X;
    clear t;
    clear j;
    
    %remove all previous selection
    if isempty(frame{i}.kin_id) == 0
        if ishandle(frame{i}.selected_pixel_handle)
            delete(frame{i}.selected_pixel_handle)
        end
        if ishandle(frame{i}.text_handle)
            delete(frame{i}.text_handle)
        end
        frame{i}.selected_pixel_handle = [];
        frame{i}.text_handle = [];
    end
    frame{i}.selected_pixel = zeros(img_size);
    frame{i}.N_kin = 0;
    frame{i}.kin_id = [];
end

MT(:,1) = MT(:,1)+min(ROI(:,1))-1;
MT(:,2) = MT(:,2)+min(ROI(:,2))-1;

if N_frame==1
    sz = size(MT);
    res = zeros(sz(1),sz(2)+1);
    res(:,1:7) = MT;
    res(:,8) = (1:sz(1))';
else
    res=trackmem( MT, maxdisp, 2, goodenough, 0);
end


%Total Number of kinetochore trajectories
N_kin_tot = max(res(:,8));

% kinetochore structure
kin = cell(N_kin_tot,1);
for i = 1:N_kin_tot
    ind = res(:,8)==i;
    kin{i}.id = i;
    kin{i}.frame = res(ind,6);
    kin{i}.time = res(ind,7);
    kin{i}.cen_x = res(ind,1);
    kin{i}.cen_y = res(ind,2);
    kin{i}.Rg = res(ind,4);
    temp = [img_size,length(kin{i}.frame)];
    kin{i}.selected_pixel = zeros(temp);
end

for i = 1:length(res(:,1))
    id = res(i,8);
    frame_num = res(i,6);
    cen_x = res(i,1);
    cen_y = res(i,2);
    Rg = sqrt(res(i,4));
    R_cover = coverage*Rg;
    idx = find(kin{id}.frame==frame_num);
    
    x_min = round(cen_x-R_cover);
    x_max = round(cen_x+R_cover);
    y_min = round(cen_y-R_cover);
    y_max = round(cen_y+R_cover);
    
    for x = x_min:x_max
        for y = y_min:y_max
            if (x-cen_x)^2+(y-cen_y)^2<=R_cover
                kin{id}.selected_pixel(x,y,idx) = 1;
            end
        end
    end
    
    frame{frame_num}.N_kin = frame{frame_num}.N_kin+1;
    frame{frame_num}.kin_id = [frame{frame_num}.kin_id;id];
    frame{frame_num}.selected_pixel = ...
        frame{frame_num}.selected_pixel|kin{id}.selected_pixel(:,:,idx);
    
    [xx,yy] = find(kin{id}.selected_pixel(:,:,idx) == 1);
    selected_pixel_handle = plot(xx,yy,'rs','MarkerFaceColor','r','MarkerSize',3);
    text_handle = text(cen_x-2,cen_y-2,num2str(id));
    frame{frame_num}.selected_pixel_handle =...
        [frame{frame_num}.selected_pixel_handle;selected_pixel_handle];
    frame{frame_num}.text_handle = ...
        [frame{frame_num}.text_handle;text_handle];
    set(selected_pixel_handle,'Visible','off')
    set(text_handle,'Visible','off','FontSize',12,'Color','y','FontWeight','bold','HorizontalAlignment','right')
end

set(frame{selected}.selected_pixel_handle,'Visible','on')
set(frame{selected}.text_handle,'Visible','on')

set(handles.Kinetochore_listbox,'String',num2str((1:max(res(:,8)))'))
set(handles.Kinetochore_listbox,'Max',max(res(:,8)));

res
handles.res = res;
handles.frame = frame;
handles.kin = kin;

disp(['The program ran for ' num2str(toc/60) ' minutes'])

guidata(hObject,handles);



% --- Executes on button press in RemoveSelected_pushbutton.
function RemoveSelected_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to RemoveSelected_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
contents = cellstr(get(handles.Kinetochore_listbox,'String'));
kin_selected = str2double(contents(get(handles.Kinetochore_listbox,'Value')));
frame = handles.frame;
kin = handles.kin;
img_size = size(frame{1}.image);

N_rm = length(kin_selected);

axes(handles.Image_axes)
for k = 1:N_rm
    frame_num = kin{kin_selected(k)}.frame;
    for j = 1:length(frame_num)
        idx = find(frame{frame_num(j)}.kin_id == kin_selected(k));
        if ishandle(frame{frame_num(j)}.selected_pixel_handle(idx))
            delete(frame{frame_num(j)}.selected_pixel_handle(idx))
        end
        if ishandle(frame{frame_num(j)}.text_handle(idx))
            delete(frame{frame_num(j)}.text_handle(idx))
        end
        
        selected_pixel = zeros(img_size);
        
        rem_kin = frame{frame_num(j)}.kin_id(frame{frame_num(j)}.kin_id~=kin_selected(k));
        for l = 1:length(rem_kin);
            selected_pixel = selected_pixel |...
                kin{rem_kin(l)}.selected_pixel(:,:,find(kin{rem_kin(l)}.frame==frame_num(j)));
        end
        frame{frame_num(j)}.selected_pixel = selected_pixel;
        
        frame{frame_num(j)}.kin_id(idx) = [];
        frame{frame_num(j)}.selected_pixel_handle(idx) = [];
        frame{frame_num(j)}.text_handle(idx) = [];
        
    end
end

handles.frame = frame;
handles.kin = kin;

contents(get(handles.Kinetochore_listbox,'Value')) = [];
set(handles.Kinetochore_listbox,'Value',1);
set(handles.Kinetochore_listbox,'String',contents)


guidata(hObject,handles)


% --- Executes on button press in SetROI_pushbutton.
function SetROI_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to SetROI_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

ROI = handles.ROI;
ROI_handle = handles.ROI_handle;

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
    
    ROI = vert;
    
    axes(handles.Image_axes);
    if isempty(ROI_handle) == 0
        delete(ROI_handle)
    end
    ROI_handle = line([vert(:,1);vert(1,1)],[vert(:,2);vert(1,2)],'LineWidth',2,'Color','w');
end

handles.ROI = ROI;
handles.ROI_handle = ROI_handle;

guidata(hObject,handles);



function Coverage_edit_Callback(hObject, eventdata, handles)
% hObject    handle to Coverage_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Coverage_edit as text
%        str2double(get(hObject,'String')) returns contents of Coverage_edit as a double


% --- Executes during object creation, after setting all properties.
function Coverage_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Coverage_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function MaxDisplacement_edit_Callback(hObject, eventdata, handles)
% hObject    handle to MaxDisplacement_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MaxDisplacement_edit as text
%        str2double(get(hObject,'String')) returns contents of MaxDisplacement_edit as a double


% --- Executes during object creation, after setting all properties.
function MaxDisplacement_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MaxDisplacement_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function GoodEnough_edit_Callback(hObject, eventdata, handles)
% hObject    handle to GoodEnough_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of GoodEnough_edit as text
%        str2double(get(hObject,'String')) returns contents of GoodEnough_edit as a double


% --- Executes during object creation, after setting all properties.
function GoodEnough_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to GoodEnough_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in ReturnSelection_pushbutton.
function ReturnSelection_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to ReturnSelection_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
FOI = handles.FOI;
N_frame = handles.N_frame;
frame = handles.frame;

if ishandle(handles.MainGui)
    MainGuihandles = guidata(handles.MainGui);
else
    errordlg('Improper call of MainGuihandle')
    return
end

hMainGui = getappdata(0, 'hMainGui');
selected = getappdata(hMainGui,'selected');
current = get(MainGuihandles.ImageSelection_slider,'Value');



for i = 1:N_frame
    MainGuihandles.image_struct{selected(i)}.selected_pixel = frame{i}.selected_pixel;
end


for i = selected
    
    image_struct = MainGuihandles.image_struct{i};
    img = image_struct.image;
    active_region = image_struct.active_region;
    
    %time axis
    time = (1:length(image_struct.decay))*image_struct.dt;
    
    if isempty(active_region)
        active_region = [1,1;size(img,2),1;size(img,1),size(img,2);1,size(img,2)];
    end
    
    lower_lim = min(active_region,[],1);
    higher_lim = max(active_region,[],1);
    x_min = lower_lim(1);
    y_min = lower_lim(2);
    x_max = higher_lim(1);
    y_max = higher_lim(2);
    
    selected_pixel = image_struct.selected_pixel;
    selected_pixel_handle = image_struct.selected_pixel_handle;
    [xx,yy] = find(selected_pixel==1);
    
    axes(MainGuihandles.Image_axes)
    if ishandle(selected_pixel_handle)
        delete(selected_pixel_handle)
    end
    selected_pixel_handle = plot(xx,yy,'rs','MarkerFaceColor','r','MarkerSize',5);
    set(selected_pixel_handle,'Visible','off');
    image_struct.selected_pixel_handle = selected_pixel_handle;
    
    flim = image_struct.flim;
    decay_data = image_struct.decay;
    decay_handle = image_struct.decay_handle;
    
    for j = 1:length(time);
        decay_data(j) = sum(sum(squeeze(flim(j,y_min:y_max,x_min:x_max)).*selected_pixel(x_min:x_max,y_min:y_max)'));
    end
    
    axes(MainGuihandles.Decay_axes);
    if ishandle(decay_handle);
        delete(decay_handle)
    end
    
    decay_handle = semilogy(time,decay_data,'.');
    hold on;
    set(decay_handle,'Visible','off')
    image_struct.decay = decay_data;
    image_struct.decay_handle = decay_handle;
    
    
    %update handles
    MainGuihandles.image_struct{i} = image_struct;
    
end

guidata(handles.MainGui,MainGuihandles)

axes(MainGuihandles.Image_axes)
set(MainGuihandles.image_struct{current}.selected_pixel_handle,'Visible','on')

axes(MainGuihandles.Decay_axes)
set(MainGuihandles.image_struct{current}.decay_handle,'Visible','on')

set(MainGuihandles.TotalCount_text,'String',num2str(sum(MainGuihandles.image_struct{current}.decay)))


% --- Executes on button press in LifetimeAnalysis_pushbutton.
function LifetimeAnalysis_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to LifetimeAnalysis_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
figname = 'FittingGUI_ver3_4';

hfig = CheckOpenState(figname);
if hfig ~= -99
    choice = questdlg([figname ' is currently open. Pressing "Yes" will delete the data previously in ',figname,' and open new one.'],'!Already opened!');
    if strcmp(choice,'Yes')==0
        return;
    else
        close(hfig)
    end
end

contents = cellstr(get(handles.Kinetochore_listbox,'String'));
kin_selected = str2double(contents(get(handles.Kinetochore_listbox,'Value')));

frame = handles.frame;
kin = handles.kin;


N_rm = length(kin_selected);

decay_struct = [];

for k = 1:N_rm
    frame_num = kin{kin_selected(k)}.frame;
    
    for j = 1:length(frame_num)
        kinnum = num2str(kin_selected(k),'%03d');
        frnum = num2str(frame_num(j),'%03d');
        name = ['kin',kinnum,'_fr',frnum];
        filename = frame{frame_num(j)}.filename;
        
        selected_pixel = kin{kin_selected(k)}.selected_pixel(:,:,j);
        
        flim = frame{frame_num(j)}.flim;
        dt = frame{frame_num(j)}.dt;
        %time axis
        time = (1:length(flim(:,1,1)))'*dt;
        
        decay = zeros(length(time),1);
        for i = 1:length(time)
            decay(i) = sum(sum(squeeze(flim(i,:,:)).*selected_pixel'));
        end
        
        new_struct = cell(1,1);
        new_struct{1}.name = name;
        new_struct{1}.filename = filename;
        new_struct{1}.decay = decay;
        new_struct{1}.selected_pixel = selected_pixel;
        new_struct{1}.time = time;
        decay_struct = [decay_struct;new_struct];
    end
end

save('decay_to_fit.mat','decay_struct');
eval(figname)


% --- Executes on button press in SaveSetting_pushbutton.
function SaveSetting_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to SaveSetting_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
featsize = str2double(get(handles.FeatureSize_edit,'String'));
barint = str2double(get(handles.MinIntegratedIntensity_edit,'String'));
barrg = str2double(get(handles.MaxRgSquared_edit,'String'));
barcc = str2double(get(handles.MaxEccentricity_edit,'String'));
IdivRg = str2double(get(handles.MinIdivRg_edit,'String'));
masscut = str2double(get(handles.Masscut_edit,'String'));
Imin = str2double(get(handles.MinLocalImax_edit,'String'));
field = str2double(get(handles.Field_edit,'String'));
maxdisp = str2double(get(handles.MaxDisplacement_edit,'String'));
goodenough = str2double(get(handles.GoodEnough_edit,'String'));
coverage = str2double(get(handles.Coverage_edit,'String'));
period = str2double(get(handles.FramePeriod_edit,'String'));

[filename,pathname,filterbox] = uiputfile2('*.mat','Save Setting');

if filename == 0
    return
end

save([pathname,filename],'featsize','barint','barrg','barcc','IdivRg',...
    'masscut','Imin','field','maxdisp','goodenough','coverage','period');


% --- Executes on button press in LoadSetting_pushbutton.
function LoadSetting_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to LoadSetting_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[filename,pathname,filterbox] = uigetfile2('*.mat','Load Setting');

if filename == 0
    return
end

setting = load([pathname filename]);

TF = isfield(setting,{'featsize','barint','barrg','barcc','IdivRg',...
    'masscut','Imin','field','maxdisp','goodenough','coverage','period'});
if sum(TF) < 12
    errordlg('invalid setting')
    return;
end



set(handles.FeatureSize_edit,'String',num2str(setting.featsize));
set(handles.MinIntegratedIntensity_edit,'String',num2str(setting.barint));
set(handles.MaxRgSquared_edit,'String',num2str(setting.barrg));
set(handles.MaxEccentricity_edit,'String',num2str(setting.barcc));
set(handles.MinIdivRg_edit,'String',num2str(setting.IdivRg));
set(handles.Masscut_edit,'String',num2str(setting.masscut));
set(handles.MinLocalImax_edit,'String',num2str(setting.Imin));
set(handles.Field_edit,'String',num2str(setting.field));
set(handles.MaxDisplacement_edit,'String',num2str(setting.maxdisp));
set(handles.GoodEnough_edit,'String',num2str(setting.goodenough));
set(handles.Coverage_edit,'String',num2str(setting.coverage));
set(handles.FramePeriod_edit,'String',num2str(setting.period));

guidata(hObject,handles)


% --- Executes on button press in ImportFitting_pushbutton.
function ImportFitting_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to ImportFitting_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in ColorKinetochore_pushbutton.
function ColorKinetochore_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to ColorKinetochore_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in SpindleAxis_pushbutton.
function SpindleAxis_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to SpindleAxis_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

kin = handles.kin;
frame = handles.frame;
N_frame = handles.N_frame;
spaxis_handle = handles.spaxis_handle;

Nkin = length(kin);

if Nkin == 0
    errordlg('Find Kinetochores first')
    return;
end

spaxis.x = 0;
spaxis.y = 0;

% approximate spindle axis, 0 if x, 1 if y, decided by finding in which direction the
% distribution of kinetochores is wider
xstd = zeros(N_frame,1);
ystd = zeros(N_frame,1);
for i = 1:N_frame
    xstd(i) = diststd(sum(frame{i}.selected_pixel,2));
    ystd(i) = diststd(sum(frame{i}.selected_pixel,1));
end
xory = mean(xstd) >  mean(ystd);

for i = 1:Nkin
    if length(kin{i}.frame) < 2
        kin{i}.vel = [];
    else
        kin{i}.vel.x = kin{i}.cen_x(2:end)-kin{i}.cen_x(1:end-1);
        kin{i}.vel.y = kin{i}.cen_y(2:end)-kin{i}.cen_y(1:end-1);
        
        if xory
            spaxis.x = spaxis.x - sum(kin{i}.vel.x(kin{i}.vel.y<0))...
                + sum(kin{i}.vel.x(kin{i}.vel.y>=0));
            spaxis.y = spaxis.y + sum(abs(kin{i}.vel.y));
        else
            spaxis.y = spaxis.y - sum(kin{i}.vel.y(kin{i}.vel.x<0))...
                + sum(kin{i}.vel.y(kin{i}.vel.x>=0));
            spaxis.x = spaxis.x + sum(abs(kin{i}.vel.x));
        end
    end
end

%normalize
normconst = sqrt(spaxis.x^2+spaxis.y^2);
spaxis.x = spaxis.x/normconst;
spaxis.y = spaxis.y/normconst;

axes(handles.Image_axes)
XL = xlim;
YL = ylim;
R = sqrt(XL(2)^2+YL(2)^2);
if ishandle(spaxis_handle)
    delete(spaxis_handle)
end
spaxis_handle = line([mean(XL)-R*spaxis.x;mean(XL)+R*spaxis.x],[mean(YL)-R*spaxis.y;mean(YL)+R*spaxis.y]);
set(spaxis_handle,'Color','b','LineWidth',2,'Visible','off')
if get(handles.ShowSpindleAxis_checkbox,'Value')
    set(spaxis_handle,'Visible','on')
end

handles.spaxis = spaxis;
handles.kin = kin;
handles.spaxis_handle = spaxis_handle;

guidata(hObject,handles);

function stddev = diststd(dist)

dist = dist(:);
len = length(dist);

distmean = sum(dist.*(1:len)')/sum(dist);
stddev = sum(dist.*((1:len)'.^2))/sum(dist)-distmean^2;


% --- Executes on button press in FindKPairs_pushbutton.
function FindKPairs_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to FindKPairs_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Consider axial and lateral distance between two kinetochores, and
%correlation of velocities

kin = handles.kin;
spaxis = handles.spaxis;


maxaxdist = str2double(get(handles.MaxAxialDistance_edit,'String'));
minaxdist = str2double(get(handles.MinAxialDistance_edit,'String'));
maxlatdist = str2double(get(handles.MaxLateralDistance_edit,'String'));
velcorrcutoff = str2double(get(handles.VelCorrCutoff_edit,'String'));
numframecutoff = str2double(get(handles.NumFrameCutoff_edit,'String'));

Nkin = length(kin);

kinpair = [];
Nkinpair = 0;
paired = zeros(Nkin,1);      %indicates whether or not selected kinetochore is paired.

%initialize
for i = 1:Nkin
    %pairid = partnerid = [] if kinetochore is not paired

    kin{i}.pairid = [];
    kin{i}.partnerid = [];
end

for i = 1:Nkin-1
    
    candidate = zeros(Nkin,1);
    for j = i+1:Nkin
        %check whether the number of frames in which two kinetochores
        %selected show together is more than 'numframecutoff'
        
        numframe = sum(ismember(kin{i}.frame,kin{j}.frame));
        
        if numframe<numframecutoff
            continue;
        end
        
        idxi = find(ismember(kin{i}.frame,kin{j}.frame)==1);
        idxj = find(ismember(kin{j}.frame,kin{i}.frame)==1);
        
        %displacement
        disp = [kin{j}.cen_x(idxj)-kin{i}.cen_x(idxi),kin{j}.cen_y(idxj)-kin{i}.cen_y(idxi)];
        %mean displacement
        meandisp = mean(disp,1);
        
        %mean axial distance
        axdist = abs(dot(meandisp,[spaxis.x,spaxis.y]));
        %mean lateral distance
        latdist = sqrt(sum(meandisp.^2)-axdist^2);
        
        if axdist>minaxdist && axdist<maxaxdist && latdist<maxlatdist
            %check mean cosine similarity of the velocity vectors of
            %two kinetochores being examined
            
            %remember, the length of velocity vector is
            %(number of frames)-1
            %so you have to make sure you are not attempting to access
            %vel(number of frames)
            if idxi(end)==length(kin{i}.frame) || idxj(end)==length(kin{j}.frame)
                len=numframe-1;
            else
                len=numframe;
            end
            
            %normalized displacement vector
            normdisp = zeros(size(disp));
            normdisp(:,1) = disp(:,1)./(disp(:,1).^2+disp(:,2).^2);
            normdisp(:,2) = disp(:,2)./(disp(:,1).^2+disp(:,2).^2);
            
            %velocity components parallel to the displacement vector
            vi = sum([kin{i}.vel.x(idxi(1:len)).*normdisp(1:len,1),kin{i}.vel.y(idxi(1:len)).*normdisp(1:len,2)],2);
            vj = sum([kin{j}.vel.x(idxj(1:len)).*normdisp(1:len,1),kin{j}.vel.y(idxj(1:len)).*normdisp(1:len,2)],2);
            
            velcorr = corr(vi,vj);
            
            if velcorr > velcorrcutoff
                candidate(j) = velcorr;
            end
        end
    end
    
    if sum(candidate)>0     %if there is any candidate
        [m,pairidx] = max(candidate);
        Nkinpair = Nkinpair+1;
        newpair = cell(1);
        newpair{1}.kinid = [i,pairidx];
        paired(i) = paired(i)+1;
        paired(pairidx) = paired(pairidx)+1;
        
        kin{i}.pairid(end+1) = Nkinpair;
        kin{i}.partnerid(end+1) = pairidx;
        kin{pairidx}.pairid(end+1) = Nkinpair;
        kin{pairidx}.partnerid(end+1) = i;
        
        newpair{1}.pairid = Nkinpair;
        newpair{1}.velcorr = m;
        newpair{1}.rejected = 0;
        newpair{1}.frame = kin{i}.frame(idxi);
        newpair{1}.distance = sqrt(disp(:,1).^2+disp(:,2).^2);
        kinpair = [kinpair;newpair];
    end
end

%for kinetochores with multiple partners, check whether the multiple
%partners appear in the same frame. If so, delete the one with smaller
%velocity correlation
for i = 1:Nkin
    if paired(i)>1
        for j = 1:paired(i)-1
            if kinpair{kin{i}.pairid(j)}.rejected
                continue;
            end
            
            for k =j+1:paired(i)
                if kinpair{kin{i}.pairid(k)}.rejected
                    continue;
                end
                
                if sum(ismember(kin{kin{i}.partnerid(j)}.frame,kin{kin{i}.partnerid(k)}.frame))
                    if kinpair{kin{i}.pairid(j)}.velcorr > kinpair{kin{i}.pairid(k)}.velcorr
                        kinpair{kin{i}.pairid(k)}.rejected = 1;
                    else
                        kinpair{kin{i}.pairid(j)}.rejected = 1;
                    end
                    
                end
            end
        end
    end
end

newNkinpair = Nkinpair;
for i = 1:Nkinpair
    if kinpair{i}.rejected
        kinid1 = kinpair{i}.kinid(1);
        remind1 = find(kin{kinid1}.pairid==i);
        kin{kinid1}.pairid(remind1) = [];
        kin{kinid1}.partnerid(remind1) = [];
        
        kinid2 = kinpair{i}.kinid(2);
        remind2 = find(kin{kinid2}.pairid==i);
        kin{kinid2}.pairid(remind2) = [];
        kin{kinid2}.partnerid(remind2) = [];
        
        newNkinpair = newNkinpair - 1;
    end
end

Nkinpair = newNkinpair;
handles.kinpair = kinpair;
handles.kin = kin;
handles.Nkinpair = Nkinpair;

%update listbox
str = cell(Nkinpair,1);
j = 1;
for i = 1:length(kinpair)
    if kinpair{i}.rejected == 0
        str{j} = [num2str(kinpair{i}.pairid), ':', num2str(kinpair{i}.kinid(1)), ' & ' num2str(kinpair{i}.kinid(2))];
        j = j+1;
    end
end
set(handles.KPair_listbox,'String',str);
    
guidata(hObject,handles);

% --- Executes on button press in ShowSpindleAxis_checkbox.
function ShowSpindleAxis_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to ShowSpindleAxis_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ShowSpindleAxis_checkbox
spaxis_handle = handles.spaxis_handle;

if isempty(spaxis_handle)==0
    axes(handles.Image_axes);
    if get(hObject,'Value')
        set(spaxis_handle,'Visible','on');
    else
        set(spaxis_handle,'Visible','off');
    end
end

guidata(hObject,handles)

% --- Executes on selection change in KPair_listbox.
function KPair_listbox_Callback(hObject, eventdata, handles)
% hObject    handle to KPair_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns KPair_listbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from KPair_listbox


% --- Executes during object creation, after setting all properties.
function KPair_listbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to KPair_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function MinAxialDistance_edit_Callback(hObject, eventdata, handles)
% hObject    handle to MinAxialDistance_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MinAxialDistance_edit as text
%        str2double(get(hObject,'String')) returns contents of MinAxialDistance_edit as a double


% --- Executes during object creation, after setting all properties.
function MinAxialDistance_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MinAxialDistance_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function MaxAxialDistance_edit_Callback(hObject, eventdata, handles)
% hObject    handle to MaxAxialDistance_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MaxAxialDistance_edit as text
%        str2double(get(hObject,'String')) returns contents of MaxAxialDistance_edit as a double


% --- Executes during object creation, after setting all properties.
function MaxAxialDistance_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MaxAxialDistance_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function MaxLateralDistance_edit_Callback(hObject, eventdata, handles)
% hObject    handle to MaxLateralDistance_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MaxLateralDistance_edit as text
%        str2double(get(hObject,'String')) returns contents of MaxLateralDistance_edit as a double


% --- Executes during object creation, after setting all properties.
function MaxLateralDistance_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MaxLateralDistance_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function VelCorrCutoff_edit_Callback(hObject, eventdata, handles)
% hObject    handle to VelCorrCutoff_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of VelCorrCutoff_edit as text
%        str2double(get(hObject,'String')) returns contents of VelCorrCutoff_edit as a double


% --- Executes during object creation, after setting all properties.
function VelCorrCutoff_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to VelCorrCutoff_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function NumFrameCutoff_edit_Callback(hObject, eventdata, handles)
% hObject    handle to NumFrameCutoff_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of NumFrameCutoff_edit as text
%        str2double(get(hObject,'String')) returns contents of NumFrameCutoff_edit as a double


% --- Executes during object creation, after setting all properties.
function NumFrameCutoff_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to NumFrameCutoff_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in BayesFit_pushbutton.
function BayesFit_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to BayesFit_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

addpath CONVNFFT_Folder

[name pathname filterindex] = uigetfile('IRF/*.mat','Choose IRF');

if name == 0 
    return;
end

nexpo = 2;
fitting_method = 3;

loaded_irf = load([pathname name]);
time_irf = loaded_irf.time;
irf = loaded_irf.decay;

shift = num2str(get(handles.Shift_edit,'String'));
tau1 = num2str(get(handles.Tau1_edit,'String'));
E = num2str(get(handles.Tau2Tau1Ratio_edit,'String'));

frame = handles.frame;
kin = handles.kin;
kinpair = handles.kinpair;

contents = cellstr(get(handles.KPair_listbox,'String'));
selected = get(handles.KPair_listbox,'Value');

pair_selected = zeros(length(selected),1);
%pair id selected
for i = 1:length(selected)
    len = strfind(contents{selected(i)},':')-1;
    pair_selected(i) = str2double(contents{selected(i)}(1:len));
end

%kinetochores in the pairs selected (kinetochores of interest)
koi = [];
for i = pair_selected
    koi = [koi,kinpair{i}.kinid];
end
koi = unique(koi);  %kinetochore ids of kinetochores that will be analyzed

for i = koi
    %frames where the selected kinetochore appears
    framenum = kin{i}.frame;
    for j = framenum
        flim = frame{j}.flim;
%        decay = flim(:,selected
    end
    
end


function Shift_edit_Callback(hObject, eventdata, handles)
% hObject    handle to Shift_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Shift_edit as text
%        str2double(get(hObject,'String')) returns contents of Shift_edit as a double


% --- Executes during object creation, after setting all properties.
function Shift_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Shift_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Tau1_edit_Callback(hObject, eventdata, handles)
% hObject    handle to Tau1_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Tau1_edit as text
%        str2double(get(hObject,'String')) returns contents of Tau1_edit as a double


% --- Executes during object creation, after setting all properties.
function Tau1_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Tau1_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Tau2Tau1Ratio_edit_Callback(hObject, eventdata, handles)
% hObject    handle to Tau2Tau1Ratio_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Tau2Tau1Ratio_edit as text
%        str2double(get(hObject,'String')) returns contents of Tau2Tau1Ratio_edit as a double


% --- Executes during object creation, after setting all properties.
function Tau2Tau1Ratio_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Tau2Tau1Ratio_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in RejectKPair_pushbutton.
function RejectKPair_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to RejectKPair_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
contents = cellstr(get(handles.KPair_listbox,'String'));
selected = get(handles.KPair_listbox,'Value');

pair_selected = zeros(length(selected),1);
%pair id selected
for i = 1:length(selected)
    len = strfind(contents{selected(i)},':')-1;
    pair_selected(i) = str2double(contents{selected(i)}(1:len));
end

kinpair = handles.kinpair;
kin = handles.kin;
Nkinpair = handles.Nkinpair;

for i = 1:length(selected)
    pairid = pair_selected(i);
    kinpair{pairid}.rejected = 1;
    
    kinid1 = kinpair{pairid}.kinid(1);
    remind1 = find(kin{kinid1}.pairid==pairid);
    kin{kinid1}.pairid(remind1) = [];
    kin{kinid1}.partnerid(remind1) = [];
    
    kinid2 = kinpair{pairid}.kinid(2);
    remind2 = find(kin{kinid2}.pairid==pairid);
    kin{kinid2}.pairid(remind2) = [];
    kin{kinid2}.partnerid(remind2) = [];
    
    Nkinpair = Nkinpair - 1;
end

newcontents = contents;
newcontents(selected) = [];
set(handles.KPair_listbox,'String',newcontents);

handles.kin = kin;
handles.kinpair = kinpair;
handles.Nkinpair = Nkinpair;

guidata(hObject,handles);

% --- Executes on button press in AddKPair_pushbutton.
function AddKPair_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to AddKPair_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

prompt = {'Kinetochore ID 1:','Kinetochore ID 2:'};
dlg_title = 'Add a new kinetochore pair';
num_lines = 1;
def = {'',''};
answer = inputdlg(prompt,dlg_title,num_lines,def);

if isempty(answer)
    return;
end

kinid1 = str2double(answer{1});
kinid2 = str2double(answer{2});

kinpair = handles.kinpair;
kin = handles.kin;
Nkinpair = handles.Nkinpair;


pairid = length(kinpair)+1;

newkinpair = cell(1);
newkinpair{1}.kinid = [kinid1, kinid2];
newkinpair{1}.pairid = pairid;

idx1 = find(ismember(kin{kinid1}.frame,kin{kinid2}.frame)==1);
idx2 = find(ismember(kin{kinid2}.frame,kin{kinid1}.frame)==1);
numframe = length(idx1);

%displacement
disp = [kin{kinid2}.cen_x(idx2)-kin{kinid1}.cen_x(idx1),kin{kinid2}.cen_y(idx2)-kin{kinid1}.cen_y(idx1)];
%mean displacement
meandisp = mean(disp,1);

if idx1(end)==length(kin{kinid1}.frame) || idx2(end)==length(kin{kinid2}.frame)
    len=numframe-1;
else
    len=numframe;
end

%normalized displacement vector
normdisp = zeros(size(disp));
normdisp(:,1) = disp(:,1)./(disp(:,1).^2+disp(:,2).^2);
normdisp(:,2) = disp(:,2)./(disp(:,1).^2+disp(:,2).^2);

%velocity components parallel to the displacement vector
v1 = sum([kin{kinid1}.vel.x(idx1(1:len)).*normdisp(1:len,1),kin{kinid1}.vel.y(idx1(1:len)).*normdisp(1:len,2)],2);
v2 = sum([kin{kinid2}.vel.x(idx2(1:len)).*normdisp(1:len,1),kin{kinid2}.vel.y(idx2(1:len)).*normdisp(1:len,2)],2);

velcorr = corr(v1,v2);

newkinpair{1}.velcorr = velcorr;
newkinpair{1}.rejected = 0;
newkinpair{1}.frame = kin{kinid1}.frame(idx1);
newkinpair{1}.distance = sqrt(disp(:,1).^2+disp(:,2).^2);

kinpair = [kinpair;newkinpair];


kin{kinid1}.pairid(end+1) = pairid;
kin{kinid2}.pairid(end+1) = pairid;
kin{kinid1}.partnerid(end+1) = kinid2;
kin{kinid2}.partnerid(end+1) = kinid1;

Nkinpair = Nkinpair+1;


handles.kinpair = kinpair;
handles.kin = kin;
handles.Nkinpair = Nkinpair;


contents = get(handles.KPair_listbox,'String');
newcontents = [contents;cellstr([num2str(pairid),':',num2str(kinid1),' & ',num2str(kinid2)])];

set(handles.KPair_listbox,'String',newcontents);

guidata(hObject,handles);


% --- Executes on button press in HighlightPair_pushbutton.
function HighlightPair_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to HighlightPair_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function FitStart_edit_Callback(hObject, eventdata, handles)
% hObject    handle to FitStart_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of FitStart_edit as text
%        str2double(get(hObject,'String')) returns contents of FitStart_edit as a double


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



function FitEnd_edit_Callback(hObject, eventdata, handles)
% hObject    handle to FitEnd_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of FitEnd_edit as text
%        str2double(get(hObject,'String')) returns contents of FitEnd_edit as a double


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


% --- Executes on button press in Scalebar_checkbox.
function Scalebar_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to Scalebar_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Scalebar_checkbox
scalebar_handle = handles.scalebar_handle;

axes(handles.Image_axes);
if get(hObject,'Value')
    set(scalebar_handle,'Visible','on');
else
    set(scalebar_handle,'Visible','off');
end

guidata(hObject,handles);

% --- Executes on button press in ShowTime_checkbox.
function ShowTime_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to ShowTime_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ShowTime_checkbox
time_handle = handles.time_handle;

axes(handles.Image_axes);
if get(hObject,'Value')
    set(time_handle,'Visible','on');
else
    set(time_handle,'Visible','off');
end

guidata(hObject,handles);


% --- Executes on button press in ShowPairInfo_pushbutton.
function ShowPairInfo_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to ShowPairInfo_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in ShowKinetochoreInfo_pushbutton.
function ShowKinetochoreInfo_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to ShowKinetochoreInfo_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)