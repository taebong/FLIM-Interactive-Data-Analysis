function varargout = KinetochoreSelectionTool_ver4_2(varargin)
% KINETOCHORESELECTIONTOOL_VER4_2 MATLAB code for KinetochoreSelectionTool_ver4_2.fig
%      KINETOCHORESELECTIONTOOL_VER4_2, by itself, creates a new KINETOCHORESELECTIONTOOL_VER4_2 or raises the existing
%      singleton*.
%
%      H = KINETOCHORESELECTIONTOOL_VER4_2 returns the handle to a new KINETOCHORESELECTIONTOOL_VER4_2 or the handle to
%      the existing singleton*.
%
%      KINETOCHORESELECTIONTOOL_VER4_2('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in KINETOCHORESELECTIONTOOL_VER4_2.M with the given input arguments.
%
%      KINETOCHORESELECTIONTOOL_VER4_2('Property','Value',...) creates a new KINETOCHORESELECTIONTOOL_VER4_2 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before KinetochoreSelectionTool_ver4_2_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to KinetochoreSelectionTool_ver4_2_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help KinetochoreSelectionTool_ver4_2
% Last Modified by GUIDE v2.5 07-May-2014 18:33:36

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @KinetochoreSelectionTool_ver4_2_OpeningFcn, ...
    'gui_OutputFcn',  @KinetochoreSelectionTool_ver4_2_OutputFcn, ...
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


% --- Outputs from this function are returned to the command line.
function varargout = KinetochoreSelectionTool_ver4_2_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



% --- Executes just before KinetochoreSelectionTool_ver4_2 is made visible.
function KinetochoreSelectionTool_ver4_2_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to KinetochoreSelectionTool_ver4_2 (see VARARGIN)

% Choose default command line output for KinetochoreSelectionTool_ver4_2
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes KinetochoreSelectionTool_ver4_2 wait for user response (see UIRESUME)
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
%    N_frame = getappdata(hMainGui,'N_frame');
    repeat = getappdata(hMainGui,'repeat');
    pixsize = getappdata(hMainGui,'pixsize');
    
    Nframe = length(FOI);
    
    frame = cell(Nframe,1);
    
    for i = 1:Nframe
        frame{i}.image = FOI{i}.image;
        frame{i}.filename = FOI{i}.filename;
        frame{i}.dt = FOI{i}.dt;
        frame{i}.flim = FOI{i}.flim;
        
        img_size = [size(frame{i}.image,1),size(frame{i}.image,2)];
        
        frame{i}.image_handle = zeros(2,1);
        
        set(handles.KinetochoreSelectionGui,'CurrentAxes',handles.Image_axes);
        frame{i}.image_handle(1) = imagesc(frame{i}.image(:,:,1));
        colormap(gray)
        axis([1,img_size(2),1,img_size(1)]);    colorbar;    set(gca,'FontSize',15);
        caxis auto;
        hold on;
        set(frame{i}.image_handle(1),'Visible','off');
        
        %Add real time
        frame{i}.time_handle = text(0.1*img_size(2),0.1*img_size(1),[num2str((i-1)*repeat),' sec'],'fontsize',12,...
            'Color','y');
        set(frame{i}.time_handle,'Visible','off');
        
        
        set(handles.KinetochoreSelectionGui,'CurrentAxes',handles.Image2_axes);
        frame{i}.image_handle(2) = imagesc(frame{i}.image(:,:,2));
        colormap(gray)
        axis([1,img_size(2),1,img_size(1)]);    colorbar;    set(gca,'FontSize',15);
        caxis auto;
        hold on;
        set(frame{i}.image_handle(2),'Visible','off');
        
        %frame{i}.selected_pixel{i} = zeros(size(FOI{i}.selected_pixel,2),size(FOI{i}.selected_pixel,1));
        
        %id of kinetochore structures in a frame
        frame{i}.kin_id = [];
        %selected pixel plot handle and text handle of each kinetochore in a frame
        
        %circle showing detected kinetochores
        frame{i}.kincircle_handle = [];       
        frame{i}.text_handle=[];
 
        frame{i}.frame_id = i;
    end
    
    set(handles.KinetochoreSelectionGui,'CurrentAxes',handles.Image_axes);
    %Add scale bar
    scalebar_handle = zeros(2,1);
    %in micrometer
    barsize = 2;
    scalebar_handle(1) = line([0.9*img_size(2)-round(barsize/pixsize),0.9*img_size(2)],...
        [0.9*img_size(1),0.9*img_size(1)],'LineWidth',2,'Color','Yellow');
    scalebar_handle(2) = text(0.9*img_size(2)-round(barsize/pixsize),0.9*img_size(1)-5,...
        [num2str(barsize), '{\mu}', 'm'],'Color','yellow','fontsize',12);
    
    
    if get(handles.Scalebar_checkbox,'Value')
        set(scalebar_handle,'Visible','on');
    else
        set(scalebar_handle,'Visible','off');
    end
    
    
    
    %image select slider
    set(handles.FrameSelection_slider,'Min',1);
    set(handles.FrameSelection_slider,'Max',max(Nframe,2));
    set(handles.FrameSelection_slider,'Value',1);
    set(handles.FrameSelection_slider,'SliderStep',[1,1]/(max(Nframe,2)-1))
    if Nframe>1
        set(handles.FrameSelection_slider,'Visible','on');
    else
        set(handles.FrameSelection_slider,'Visible','off');
    end
    set(frame{1}.image_handle,'Visible','on');
    
    if get(handles.ShowTime_checkbox,'Value')
        set(frame{1}.time_handle,'Visible','on');
    else
        set(frame{1}.time_handle,'Visible','off');
    end
    
    %update the handles
    handles.hMainGui = hMainGui;
    handles.FOI = FOI;
    handles.frame = frame;
    handles.ROI = [];
    handles.ROI_handle = [];
    handles.spaxis_handle = [];
    handles.spaxis = [];
    handles.kinpair = [];
    handles.repeat = repeat;
    handles.pixsize = pixsize;
    handles.scalebar_handle = scalebar_handle;
    handles.preselected = 1;
    if prod(isfield(FOI{1},{'flimblock'}))
        handles.flimblock = FOI{1}.flimblock;
    else
        %defualt
        handles.flimblock = 1;
    end
        
    %all kinetochore structures
    handles.kin = [];
    handles.res = [];
    handles.resGauss = [];
    handles.kinstate = [];
    handles.location = [];
    
    set(handles.FrameNumber_text,'String',['1 out of ' num2str(Nframe)]);
    
end

% Use default setting for kinetochore selection setting
SaveLoadKinSelectionSetting(handles,'Load',1);

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


% --- Executes during object creation, after setting all properties.
function FrameSelection_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FrameSelection_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



% --- Executes on slider movement.
function FrameSelection_slider_Callback(hObject, eventdata, handles)
% hObject    handle to FrameSelection_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

selected = round(get(hObject,'Value'));
set(hObject,'Value',selected);
preselected = handles.preselected;
frame = handles.frame;
Nframe = length(frame);
kin = handles.kin;
kinstate = handles.kinstate;

kintoshow = zeros(length(frame{selected}.kin_id),2);

for i = 1:length(frame{selected}.kin_id)
    kintoshow(i,1) = kinstate(kinstate(:,1)==frame{selected}.kin_id(i) & kinstate(:,2)==selected,3)==1;
    kintoshow(i,2) = kintoshow(i,1);
end

set(frame{preselected}.image_handle,'Visible','off')
set(frame{preselected}.time_handle,'Visible','off')
set(frame{selected}.image_handle,'Visible','on');
if get(handles.ShowTime_checkbox,'Value')
    set(frame{selected}.time_handle,'Visible','on');
end

if isempty(frame{preselected}.kin_id) == 0 
    set(frame{preselected}.kincircle_handle(ishandle(frame{preselected}.kincircle_handle)),'Visible','off')
    set(frame{preselected}.text_handle(ishandle(frame{preselected}.text_handle)),'Visible','off')
end

if isempty(frame{selected}.kin_id) == 0
    set(frame{selected}.kincircle_handle(ishandle(frame{selected}.kincircle_handle) & kintoshow),'Visible','on')
    set(frame{selected}.text_handle(ishandle(frame{selected}.text_handle) & kintoshow),'Visible','on')
end


set(handles.FrameNumber_text,'String',[num2str(selected) ' out of ' num2str(Nframe)]);
handles.preselected = selected;

guidata(hObject,handles)



%% Kinetochore Detection
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% --- Executes on button press in SaveSetting_pushbutton.
function SaveSetting_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to SaveSetting_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
SaveLoadKinSelectionSetting(handles,'Save',0);

% --- Executes on button press in LoadSetting_pushbutton.
function LoadSetting_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to LoadSetting_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
SaveLoadKinSelectionSetting(handles,'Load',0);

% --- Executes on button press in SetDefault_pushbutton.
function SetDefault_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to SetDefault_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
SaveLoadKinSelectionSetting(handles,'Save',1);

% --- Executes on button press in LoadDefaultSetting_pushbutton.
function LoadDefaultSetting_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to LoadDefaultSetting_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
SaveLoadKinSelectionSetting(handles,'Load',1);


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
ROI_handle = handles.ROI_handle;
flimblock = handles.flimblock;

ch1 = get(handles.Ch1_checkbox,'Value');
ch2 = get(handles.Ch2_checkbox,'Value');

if isempty(ROI)
    buttonname = questdlg('ROI not set up. Do you want to set ROI to entire image?','Region of Interest');
    if strcmp(buttonname,'Cancel') || strcmp(buttonname,'No')
        return;
    elseif strcmp(buttonname,'Yes')
        vert(1,1) = 1;
        vert(1,2) = 1;
        vert(2,2) = 1;
        vert(4,1) = 1;
        vert(3,1) = size(img,2);
        vert(3,2) = size(img,1);
        vert(2,1) = size(img,2);
        vert(4,2) = size(img,1);
        
        ROI = vert;
        
        set(handles.KinetochoreSelectionGui,'CurrentAxes',handles.Image_axes);
        if isempty(ROI_handle) == 0
            delete(ROI_handle)
        end
        ROI_handle = zeros(2,1);
        ROI_handle(1) = line([vert(:,1);vert(1,1)],[vert(:,2);vert(1,2)],'LineWidth',2,'Color','w');
        set(handles.KinetochoreSelectionGui,'CurrentAxes',handles.Image2_axes);
        ROI_handle(2) = line([vert(:,1);vert(1,1)],[vert(:,2);vert(1,2)],'LineWidth',2,'Color','w');
    end
end

img_ROI = img(min(ROI(:,2)):max(ROI(:,2)),min(ROI(:,1)):max(ROI(:,1)),:);

handles.ROI = ROI;
handles.ROI_handle = ROI_handle;

d=0;
MTch1=[];
Mrejch1=[];
MTch2=[];
Mrejch2=[];

if ch1
    Mch1 = feature2D(img_ROI(:,:,1),1,featsize,masscut,Imin,field);
    fimg1 = bpass(img_ROI(:,:,1),1,featsize);
    
    if isempty(Mch1) | (Mch1 == -1) 
        errordlg('Ch1: Failed to find local minimum. Try different setting')
        return
    end
    
    a = length(Mch1(:,1));
    
    for i=1:a
        if ((Mch1(i,5)>barcc))
            Mrejch1=[Mrejch1; Mch1(i,:)];
            Mch1(i,1:5)=0;
        elseif ((Mch1(i,4)>barrg))
            Mrejch1=[Mrejch1; Mch1(i,:)];
            Mch1(i,1:5)=0;
        elseif ((Mch1(i,3)<barint))
            Mrejch1=[Mrejch1; Mch1(i,:)];
            Mch1(i,1:5)=0;
        elseif((Mch1(i,3)/Mch1(i,4)<IdivRg))
            Mrejch1=[Mrejch1; Mch1(i,:)];
            Mch1(i,1:5)=0;
        end
    end
    
    %    Deleting the zero rows
    Mch1=Mch1(Mch1(:,1)~=0,:);
    a = length(Mch1(:,1));
    MTch1(d+1:a+d, 1:5)=Mch1(1:a,1:5);
    
    
    figure;
    imagesc(fimg1),colormap(gray);
    hold on
    
    % Making a circle the size of the feature around each feature.
    h = DrawCircle(MTch1(:,1),MTch1(:,2),sqrt(MTch1(:,4)));
    
    if( ~isempty(Mrejch1)>0 )
        plot( Mrejch1(:,1), Mrejch1(:,2), 'r.' );
    end
    
    axis image;
    
    format short g
    disp(Mch1)
    disp(['Kept : ' num2str(size(Mch1,1))])
    disp(Mrejch1)
    disp(['Minimum Intensity : ' num2str(min(Mch1(:,3)))])
    disp(['Maximum Rg : ' num2str(max(Mch1(:,4)))])
    disp(['Maximum Eccentricity : ' num2str(max(Mch1(:,5)))])
    
end

if ch2
    Mch2 = feature2D(img_ROI(:,:,2),1,featsize,masscut,Imin,field);
    fimg2 = bpass(img_ROI(:,:,2),1,featsize);
    
    if isempty(Mch2) | (Mch2 == -1) 
        errordlg('Ch2: Failed to find local minimum. Try different setting')
        return
    end
    
    b = length(Mch2(:,1));
    
    for i=1:b
        if ((Mch2(i,5)>barcc))
            Mrejch2=[Mrejch2; Mch2(i,:)];
            Mch2(i,1:5)=0;
            %          end
            
        elseif ((Mch2(i,4)>barrg))
            Mrejch2=[Mrejch2; Mch2(i,:)];
            Mch2(i,1:5)=0;
            %          end
            
        elseif ((Mch2(i,3)<barint))
            Mrejch2=[Mrejch2; Mch2(i,:)];
            Mch2(i,1:5)=0;
        elseif((Mch2(i,3)/Mch2(i,4)<IdivRg))
            Mrejch2=[Mrejch2; Mch2(i,:)];
            Mch2(i,1:5)=0;
        end
    end
    
    %    Deleting the zero rows
    Mch2=Mch2(Mch2(:,1)~=0,:);
    
    b = length(Mch2(:,1));
    MTch2(d+1:b+d, 1:5)=Mch2(1:b,1:5);
    
    
    figure;
    imagesc(fimg2),colormap(gray);
    hold on
    
    % Making a circle the size of the feature around each feature.
    h = DrawCircle(MTch2(:,1),MTch2(:,2),sqrt(MTch2(:,4)));
    
    if( ~isempty(Mrejch2)>0 )
        plot( Mrejch2(:,1), Mrejch2(:,2), 'r.' );
    end
    
    axis image;
    
    format short g
    disp(Mch2)
    disp(['Kept : ' num2str(size(Mch2,1))])
    disp(Mrejch2)
    disp(['Minimum Intensity : ' num2str(min(Mch2(:,3)))])
    disp(['Maximum Rg : ' num2str(max(Mch2(:,4)))])
    disp(['Maximum Eccentricity : ' num2str(max(Mch2(:,5)))])
end

if ch1&&ch2
    MT = [];
    for i = 1:length(MTch2(:,1))
        thres = str2double(get(handles.Ch12thres_edit,'String'));
        ind = find((MTch1(:,1)-MTch2(i,1)).^2+(MTch1(:,2)-MTch2(i,2)).^2<thres);
        if isempty(ind) == 0
            temp = [MTch1(ind,[1,2,4]),MTch2(i,[1,2,4])];
            MT = [MT;temp];
        end
    end
    
    disp(MT)
    
    figure;
    normimg = zeros(size(img_ROI,1),size(img_ROI,2),3);
    normimg(:,:,1) = fimg1/max(fimg1(:));
    normimg(:,:,2) = fimg2/max(fimg2(:));
    image(normimg);
    hold on
    
    % Making a circle the size of the feature around each feature.
    h1 = DrawCircle(MT(:,1),MT(:,2),2);
    h2 = DrawCircle(MT(:,4),MT(:,5),2);
    
    set(h1,'Color','r')
    set(h2,'Color','b')
    
    axis image;
end

guidata(hObject,handles);



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
memory = str2double(get(handles.Memory_edit,'String'));
coverage = str2double(get(handles.Coverage_edit,'String'));

selected = get(handles.FrameSelection_slider,'Value');
frame = handles.frame;
Nframe = length(frame);
ROI = handles.ROI;
ROI_handle = handles.ROI_handle;
flimblock = handles.flimblock;
ch1 = get(handles.Ch1_checkbox,'Value');
ch2 = get(handles.Ch2_checkbox,'Value');

period = handles.repeat;
img_size = size(frame{1}.image);

time = (0:(Nframe-1))'*period;

if isempty(ROI)
    buttonname = questdlg('ROI not set up. Do you want to set ROI to entire image?','Region of Interest');
    if strcmp(buttonname,'Cancel') || strcmp(buttonname,'No')
        return;
    elseif strcmp(buttonname,'Yes')
        vert(1,1) = 1;
        vert(1,2) = 1;
        vert(2,2) = 1;
        vert(4,1) = 1;
        vert(3,1) = img_size(2);
        vert(3,2) = img_size(1);
        vert(2,1) = img_size(2);
        vert(4,2) = img_size(1);
        
        ROI = vert;
        
        set(handles.KinetochoreSelectionGui,'CurrentAxes',handles.Image_axes);
        if isempty(ROI_handle) == 0
            delete(ROI_handle)
        end
        ROI_handle = zeros(2,1);
        ROI_handle(1) = line([vert(:,1);vert(1,1)],[vert(:,2);vert(1,2)],'LineWidth',2,'Color','w');
        set(handles.KinetochoreSelectionGui,'CurrentAxes',handles.Image2_axes);
        ROI_handle(2) = line([vert(:,1);vert(1,1)],[vert(:,2);vert(1,2)],'LineWidth',2,'Color','w');
    end
end

handles.ROI = ROI;
handles.ROI_handle = ROI_handle;


tic

if ch1
    d=0;
    
    for i = 1:Nframe
        img = handles.frame{i}.image;
        img_ROI = img(min(ROI(:,2)):max(ROI(:,2)),min(ROI(:,1)):max(ROI(:,1)),1);
        
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
            
            MT1(d+1:a+d, 1:5)=M(1:a,1:5);
            MT1(d+1:a+d, 6)=i;
            MT1(d+1:a+d, 7)=time(i);
            d = length(MT1(:,1));
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
            delete(frame{i}.kincircle_handle(ishandle(frame{i}.kincircle_handle(:,1)),1))
            delete(frame{i}.text_handle(ishandle(frame{i}.text_handle(:,1)),1))
        end
    end
    
    MT1(:,1) = MT1(:,1)+min(ROI(:,1))-1;
    MT1(:,2) = MT1(:,2)+min(ROI(:,2))-1;
else
    MT1 = [];
end

if ch2
    d = 0;
    
    for i = 1:Nframe
        img = handles.frame{i}.image;
        img_ROI = img(min(ROI(:,2)):max(ROI(:,2)),min(ROI(:,1)):max(ROI(:,1)),2);
        
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
            
            MT2(d+1:a+d, 1:5)=M(1:a,1:5);
            MT2(d+1:a+d, 6)=i;
            MT2(d+1:a+d, 7)=time(i);
            d = length(MT2(:,1));
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
            delete(frame{i}.kincircle_handle(ishandle(frame{i}.kincircle_handle(:,2)),2))
            delete(frame{i}.text_handle(ishandle(frame{i}.text_handle(:,2)),2))
        end
    end
    MT2(:,1) = MT2(:,1)+min(ROI(:,1))-1;
    MT2(:,2) = MT2(:,2)+min(ROI(:,2))-1;
else
    MT2 = [];
end

for i =1:Nframe
    frame{i}.kincircle_handle = [];
    frame{i}.text_handle = [];
    frame{i}.kin_id = [];
end


%Matching kinetochores in two channel.
if ch1&&ch2
    tempMT = [];    %temporary storage for nonmatched kinetochore feature
    m = 1;
    n = 1;
    %Matching across the channels
    for i = 1:length(MT2(:,1))
        thres = 1;
        idx = find(MT1(:,6)==MT2(i,6) & sqrt((MT1(:,1)-MT2(i,1)).^2+(MT1(:,2)-MT2(i,2)).^2)<thres);
        if isempty(idx)
            tempMT(n,:,2) = MT2(i,:);
            tempMT(n,:,1) = 0;
            tempMT(n,6:7,1) = MT2(i,6:7);
            n = n+1;
        elseif length(idx) == 1
            MT(m,:,1) = MT1(idx,:);
            MT(m,:,2) = MT2(i,:);
            MT1(idx,:) = [];
            m = m+1;
        else
           errordlg('Ambiguous matching between channels. Try with smaller threshold'); 
        end
    end
    if isempty(MT1) == 0
        tempMT(n:n+length(MT1(:,1))-1,:,1) = MT1;
        tempMT(n:n+length(MT1(:,1))-1,:,2) = 0;
        tempMT(n:n+length(MT1(:,1))-1,6:7,2) = MT1(:,6:7);
    end
    MT = [MT;tempMT];
    [sortedT,I] = sort(MT(:,7,1));
    MT = MT(I,:,:);
else
    if ch1
        MT(:,:,1) = MT1;
        MT(:,:,2) = 0;
        MT(:,6:7,2) = MT1(:,6:7);
    end
    if ch2
        MT(:,:,2) = MT2;
        MT(:,:,1) = 0;
        MT(:,6:7,1) = MT2(:,6:7);
    end
end


if Nframe==1
    res = MT;
    res(:,8,1) = (1:size(res,1))';
    res(:,8,2) = (1:size(res,1))';
else
    avgMT = zeros(size(MT,1),size(MT,2));
    avgMT(MT(:,1,1)==0,:) = MT(MT(:,1,1)==0,:,2);
    avgMT(MT(:,1,2)==0,:) = MT(MT(:,1,2)==0,:,1);
    avgMT(MT(:,1,1).*MT(:,1,2)~=0,:) = mean(MT(MT(:,1,1).*MT(:,1,2)~=0,:,:),3);
    
    %add temporary kinetochore id to fourth column
    %add angle of intrakinetochore vector from x-axis to third column
    %the angle ranges from 0 to pi, and set angle = -10 if one channel data is missing. 
    avgMT(:,5:9) = avgMT(:,3:7);
    avgMT(:,4) = (1:length(avgMT(:,1)))';
    avgMT(:,3) = (MT(:,1,1).*MT(:,1,2)==0)*(-10)+...
        (MT(:,1,1).*MT(:,1,2) ~= 0).*...
        acos((MT(:,1,2)-MT(:,1,1))./sqrt(sum((MT(:,1:2,2)-MT(:,1:2,1)).^2,2)));
    dim = 2; %set dim=3 if you want to take intrakinetochore stretch into account for kinetochore tracking. For high frame rate, this is not really necessary.
    tempres=trackmemkin(avgMT, maxdisp, dim, goodenough, memory); 
    
    ind = tempres(:,4);
    res(:,1:7,:)=MT(ind,:,:);
    res(:,8,1)=tempres(:,10);
    res(:,8,2)=tempres(:,10);
end

%Total Number of kinetochore trajectories
Nkin = max(res(:,8,1));

% kinetochore structure
kin = cell(Nkin,1);
for i = 1:Nkin
    ind = res(:,8,1)==i;
    kin{i}.id = i;
    kin{i}.frame = res(ind,6,1);
    kin{i}.time = res(ind,7,1);
    kin{i}.selected_pixel = zeros(img_size(2),img_size(1),length(kin{i}.frame));
end

%frame structure
for i = 1:Nframe
    ind = res(:,6,1)==i;
    frame{i}.kincircle_handle = -99*ones(sum(ind),2);
    frame{i}.text_handle = -99*ones(sum(ind),2);
    frame{i}.kin_id = res(ind,8,1);
end

%arrays containing information about whether or not kinetochore is accepted as a good kinetochore or not
kinstate = zeros(size(res,1),3);
%col1: kin id
kinstate(:,1) = res(:,8,1);
%col2: frame num
kinstate(:,2) = res(:,6,1);
%col3: 1 if this kinetochore is accepted, 0 if rejected
kinstate(:,3) = 1;

%save location info
location = zeros(size(res,1),6,2);
%col1: kinid, col2: frame num
location(:,1,:) = res(:,8,:);
location(:,2,:) = res(:,6,:);
%col3: source of location info, -1 if CM, 0 if nonconverged Gauss fit, 1 if
%converged Gauss fit, -99 if not available
location(:,3,:) = (res(:,1,:)==0)*-99+(res(:,1,:)~=0)*-1;
%col4,5: x and y coordinates
location(:,4:5,:) = res(:,1:2,:);
%col6: radius of selection coverage
location(:,6,:) = sqrt(res(:,4,:))*coverage;

[frame,kin] = DrawKinCircle(handles,frame,kin,location);

set(frame{selected}.kincircle_handle(ishandle(frame{selected}.kincircle_handle)),'Visible','on')
set(frame{selected}.text_handle(ishandle(frame{selected}.text_handle)),'Visible','on')

set(handles.Kinetochore_listbox,'String',num2str((1:max(res(:,8,1)))'))
set(handles.Kinetochore_listbox,'Max',max(res(:,8,1)));

res
handles.res = res;
handles.frame = frame;
handles.kin = kin;
handles.kinstate = kinstate;
handles.resGauss = [];
handles.location = location;

disp(['The program ran for ' num2str(toc/60) ' minutes'])

guidata(hObject,handles);

% --- Executes on button press in StartGaussFit_pushbutton.
function StartGaussFit_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to StartGaussFit_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

addpath 2DGaussFit

selected = get(handles.FrameSelection_slider,'Value');
res = handles.res;
frame = handles.frame;
kin = handles.kin;
kinstate = handles.kinstate;
location = handles.location;
GaussPreffered = get(handles.GaussPreffered_checkbox,'Value');
includenonconverged = get(handles.IncludeNonconverged_checkbox,'Value');
massthres = str2double(get(handles.GaussMassThres_edit,'String'));

plotGaussfit = 0;

c = [20,1,1];
widratio = 1.7;
dp = ones(1,7)*0.01;
dp(4) = 0;
dp(5) = 0;

resGauss = zeros(size(res,1),19,2);
resGauss(:,17:19,:) = res(:,6:8,:);
resGauss(:,16,:) = -99; %means Gauss result is not available

Ntot = 0;
NGausstot = 0;
Nconverged = 0;

h = -99;
Nframe = length(frame);

tic
for fr = 1:Nframe
    kininfr = frame{fr}.kin_id;
    image = frame{fr}.image;
    
    for k = 1:length(kininfr)
        %kinstate and res information of given kinetochore in a given frame 
        kinstateind = find(kinstate(:,1)==kininfr(k) & kinstate(:,2)==fr);
        resind = find(res(:,8,1)==kininfr(k) & res(:,6,1)==fr);
        kinkstate = kinstate(kinstateind,:);
        resk = squeeze(res(resind,:,:));
        
        %if kinetochore has been rejected, don't waste your time on doing
        %gauss fit!
        if kinkstate(3) == 0
            continue;
        end
        
        for ch = 1:2
            cmx = resk(1,ch);
            cmy = resk(2,ch);
            
            if cmx == 0 %this kinetochore is not detected in this channel
                continue;
            else
                Ntot = Ntot+1;
                
                %construct a square region in which 2D gaussian fit is
                %performed
                Rg = sqrt(resk(4,ch));
                wid = round(widratio*Rg);
                
                xmin = max(round(cmx)-wid,1);
                xmax = min(round(cmx)+wid,size(image,2));
                ymin = max(round(cmy)-wid,1);
                ymax = min(round(cmy)+wid,size(image,1));
                
                x = xmin:xmax;
                y = ymin:ymax;
                
                ConstructGlobalVar(x,y,c);
                
                z = double(image(y,x,ch));
                
                if sum(z(:))<massthres
                    continue;
                end
                
                pinit = [cmx,cmy,0.5*Rg,0.5*Rg,0,max(z(:))-min(z(:)),min(z(:))];
                pmax(1:2) = pinit(1:2)+2;
                pmin(1:2) = pinit(1:2)-2;
                pmax(3:4) = Rg;
                pmin(3:4) = 0.1*Rg;
                pmax(5) = 0;
                pmin(5) = 0;
                pmax(6) = 2*pinit(6);
                pmin(6) = 0.4*pinit(6);
                pmax(7) = 0.5*max(z(:));
                pmin(7) = 0;
                
                weight = ones(size(z,1),size(z,2));
                
                [pfit,X2,sigp,sigy,corr,Rsq,cvg_hst, converged] = lm2(@JointGaussianModel,pinit,x,y,z,weight,dp,pmin,pmax,c);
                
                if c(2) == 1
                    pfit(4) = pfit(3);
                end
                
                if plotGaussfit == 1
                    if ishandle(h)
                        close(h)
                    end
                    
                    %plot the result
                    h = figure;
                    zfit = JointGaussianModel(x,y,pfit,c);
                    subplot(1,2,1), imagesc(x,y,z)
                    axis image;
                    text(mean(x),min(y)-1.5,['# photons=',num2str(sum(z(:)))],'HorizontalAlignment','center');
                    
                    subplot(1,2,2), imagesc(x,y,zfit)
                    axis image;
                    
                    fitstring=sprintf('%.2f,',pfit');
                    stdfit = sprintf('+-%.2f,',sigp');
                    
                    text(mean(x),max(y)+2.5,'x,y,sigx,sigy,theta,h,bg','HorizontalAlignment','center');
                    text(mean(x),max(y)+3.5,fitstring,'HorizontalAlignment','center');
                    text(mean(x),max(y)+4.5,stdfit,'HorizontalAlignment','center');
                    text(mean(x),min(y)-2,['# photons=',num2str(sum(zfit(:)))],'HorizontalAlignment','center');
                    drawnow
                end
                
                resGaussk = [pfit',real(sigp'),X2,converged];
                resGauss(resind,1:16,ch) = resGaussk;
                
                NGausstot = NGausstot+1;
                if converged
                    Nconverged = Nconverged+1;
                end
            end
        end
    end    
end

disp(['2D Gauss fit has been performed on ', num2str(NGausstot), ' kinetochores out of ', num2str(Ntot)]); 
disp([num2str(Nconverged),' out of ', num2str(NGausstot), ' Gauss fits have been converged.']);

if ishandle(h)
    close(h)
end

if GaussPreffered == 1
    convergedind = squeeze(resGauss(:,16,:)==1);
    nonconvergedind = squeeze(resGauss(:,16,:)==0);
    
    for ch = 1:2
        %update source
        location(convergedind(:,ch),3,ch) = 1;
        %update location
        location(convergedind(:,ch),4:5,ch) = resGauss(convergedind(:,ch),1:2,ch);
    end
    
    if includenonconverged
        for ch = 1:2
            %update source
            location(nonconvergedind(:,ch),3,ch) = 0;
            %update location
            location(nonconvergedind(:,ch),4:5,ch) = resGauss(nonconvergedind(:,ch),1:2,ch);
        end
    end
    
    updateind = or(or(convergedind(:,1),convergedind(:,2)),or(nonconvergedind(:,1),nonconvergedind(:,2)));
    [frame,kin] = DrawKinCircle(handles,frame,kin,location(updateind,:,:));
    
    set(frame{selected}.kincircle_handle(ishandle(frame{selected}.kincircle_handle)),'Visible','on')
    set(frame{selected}.text_handle(ishandle(frame{selected}.text_handle)),'Visible','on')

end
toc

handles.resGauss = resGauss;
handles.frame = frame;
handles.kin = kin;
handles.location = location;

guidata(hObject,handles)



% --- Executes on button press in GaussPreffered_checkbox.
function GaussPreffered_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to GaussPreffered_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of GaussPreffered_checkbox
GaussPreffered = get(hObject,'Value');
resGauss = handles.resGauss;
location = handles.location;
frame = handles.frame;
kin = handles.kin;
res = handles.res;
coverage = str2double(get(handles.Coverage_edit,'String'));
includenonconverged = get(handles.IncludeNonconverged_checkbox,'Value');
selected = get(handles.FrameSelection_slider,'Value');


if GaussPreffered == 1
    if isempty(resGauss)
        return;
    end
    convergedind = squeeze(resGauss(:,16,:)==1);
    nonconvergedind = squeeze(resGauss(:,16,:)==0);
    
    updateind = or(convergedind(:,1),convergedind(:,2));
    
    for ch = 1:2
        %update source
        location(convergedind(:,ch),3,ch) = 1;
        %update location
        location(convergedind(:,ch),4:5,ch) = resGauss(convergedind(:,ch),1:2,ch);
    end
    
    if includenonconverged
        for ch = 1:2
            %update source
            location(nonconvergedind(:,ch),3,ch) = 0;
            %update location
            location(nonconvergedind(:,ch),4:5,ch) = resGauss(nonconvergedind(:,ch),1:2,ch);
        end
        updateind = or(or(convergedind(:,1),convergedind(:,2)),or(nonconvergedind(:,1),nonconvergedind(:,2)));
    end
    
elseif GaussPreffered == 0
    temp = squeeze(location(:,3,:) == 1|location(:,3,:) == 0);
    updateind = or(temp(:,1),temp(:,2));
    
    %col3: source of location info, -1 if CM, 0 if nonconverged Gauss fit, 1 if
    %converged Gauss fit, -99 if not available
    location(:,3,:) = (res(:,1,:)==0)*-99+(res(:,1,:)~=0)*-1;
    %col4,5: x and y coordinates
    location(:,4:5,:) = res(:,1:2,:);
    %col6: radius of selection coverage
    location(:,6,:) = sqrt(res(:,4,:))*coverage;
end

[frame,kin] = DrawKinCircle(handles,frame,kin,location(updateind,:,:));

set(frame{selected}.kincircle_handle(ishandle(frame{selected}.kincircle_handle)),'Visible','on')
set(frame{selected}.text_handle(ishandle(frame{selected}.text_handle)),'Visible','on')

handles.frame = frame;
handles.kin = kin;
handles.location = location;

guidata(hObject,handles)


% --- Executes on button press in IncludeNonconverged_checkbox.
function IncludeNonconverged_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to IncludeNonconverged_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of IncludeNonconverged_checkbox

includenonconverged = get(hObject,'Value');
resGauss = handles.resGauss;
location = handles.location;
frame = handles.frame;
kin = handles.kin;
res = handles.res;
GaussPreffered = get(handles.IncludeNonconverged_checkbox,'Value');
selected = get(handles.FrameSelection_slider,'Value');


if GaussPreffered == 1
    if isempty(resGauss)
        return;
    end
    convergedind = squeeze(resGauss(:,16,:)==1);
    nonconvergedind = squeeze(resGauss(:,16,:)==0);
    
    updateind = or(convergedind(:,1),convergedind(:,2));
    
    for ch = 1:2
        %update source
        location(convergedind(:,ch),3,ch) = 1;
        %update location
        location(convergedind(:,ch),4:5,ch) = resGauss(convergedind(:,ch),1:2,ch);
    end
    
    if includenonconverged
        for ch = 1:2
            %update source
            location(nonconvergedind(:,ch),3,ch) = 0;
            %update location
            location(nonconvergedind(:,ch),4:5,ch) = resGauss(nonconvergedind(:,ch),1:2,ch);
        end
        updateind = or(or(convergedind(:,1),convergedind(:,2)),or(nonconvergedind(:,1),nonconvergedind(:,2)));
    end
    
elseif GaussPreffered == 0
    return;
end

[frame,kin] = DrawKinCircle(handles,frame,kin,location(updateind,:,:));

set(frame{selected}.kincircle_handle(ishandle(frame{selected}.kincircle_handle)),'Visible','on')
set(frame{selected}.text_handle(ishandle(frame{selected}.text_handle)),'Visible','on')

handles.frame = frame;
handles.kin = kin;
handles.location = location;

guidata(hObject,handles)


%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in RemoveSelected_pushbutton.
function RemoveSelected_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to RemoveSelected_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
contents = cellstr(get(handles.Kinetochore_listbox,'String'));
kin_selected = str2double(contents(get(handles.Kinetochore_listbox,'Value')));
frame = handles.frame;
kin = handles.kin;
kinstate = handles.kinstate;
img_size = size(frame{1}.image);
frame_selected = get(handles.FrameSelection_slider,'Value');

N_rm = length(kin_selected);

for k = 1:N_rm
    frame_num = kin{kin_selected(k)}.frame;
    for j = 1:length(frame_num)
        idx = find(frame{frame_num(j)}.kin_id == kin_selected(k));
        
        %set "accept or reject" parameter in kinstate matrix to 0 (which means rejected)
        kinstate(kinstate(:,1)==kin_selected(k) & kinstate(:,2)==frame_num(j),3)=0;
        
        %hide rejected kinetochores in current frame
        set(frame{frame_num(j)}.kincircle_handle(idx,ishandle(frame{frame_num(j)}.kincircle_handle(idx,:))),'Visible','off')
        set(frame{frame_num(j)}.text_handle(idx,ishandle(frame{frame_num(j)}.text_handle(idx,:))),'Visible','off')
        
        %exclude rejected kinetochores out of selected pixels region
        selected_pixel = zeros(img_size(2),img_size(1));
        
        rem_kin = frame{frame_num(j)}.kin_id(frame{frame_num(j)}.kin_id~=kin_selected(k));
        for l = 1:length(rem_kin);
            selected_pixel = selected_pixel |...
                kin{rem_kin(l)}.selected_pixel(:,:,find(kin{rem_kin(l)}.frame==frame_num(j)));
        end
        frame{frame_num(j)}.selected_pixel = selected_pixel;        
    end
end

handles.frame = frame;
handles.kin = kin;
handles.kinstate = kinstate;

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

    set(handles.KinetochoreSelectionGui,'CurrentAxes',handles.Image_axes);
    if isempty(ROI_handle) == 0
        delete(ROI_handle)
    end
    ROI_handle = zeros(2,1);
    ROI_handle(1) = line([vert(:,1);vert(1,1)],[vert(:,2);vert(1,2)],'LineWidth',2,'Color','w');
    set(handles.KinetochoreSelectionGui,'CurrentAxes',handles.Image2_axes);
    ROI_handle(2) = line([vert(:,1);vert(1,1)],[vert(:,2);vert(1,2)],'LineWidth',2,'Color','w');
end

handles.ROI = ROI;
handles.ROI_handle = ROI_handle;

guidata(hObject,handles);





% --- Executes on button press in ReturnSelection_pushbutton.
function ReturnSelection_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to ReturnSelection_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
FOI = handles.FOI;
frame = handles.frame;
Nframe = length(frame);
kin = handles.kin;
%Gausspreferred = handles.

if ishandle(handles.MainGui)
    MainGuihandles = guidata(handles.MainGui);
else
    errordlg('Improper call of MainGuihandle')
    return
end

hMainGui = getappdata(0, 'hMainGui');
selected = getappdata(hMainGui,'selected');
current = get(MainGuihandles.ImageSelection_slider,'Value');

img_size = size(frame{1}.image);
[Y,X] = meshgrid(1:img_size(1),1:img_size(2));

x_min = floor(cen_x-R_cover);
    x_max = ceil(cen_x+R_cover);
    y_min = floor(cen_y-R_cover);
    y_max = ceil(cen_y+R_cover);
   
    if cen_x(flimblock)>0
        kin{id}.selected_pixel(:,:,idx) = ((X-cen_x(flimblock)).^2+(Y-cen_y(flimblock)).^2<=R_cover(flimblock)^2);
    end 

for i = 1:Nframe
    cen_x
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
    selected_pixel_handle = plot(xx,yy,'ws','MarkerSize',5);
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
        
        if sum(decay) == 0
            continue;
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


% --- Executes on button press in SpindleAxis_pushbutton.
function SpindleAxis_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to SpindleAxis_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

kin = handles.kin;
frame = handles.frame;
N_frame = handles.N_frame;
spaxis_handle = handles.spaxis_handle;
img_size = size(frame{1}.image);

Nkin = length(kin);

if Nkin == 0
    errordlg('Find Kinetochores first')
    return;
end

spaxis.x = 0;
spaxis.y = 0;



if get(handles.AutoAxis_checkbox,'Value')
    for i = 1:Nkin
        if length(kin{i}.frame) < 2
            kin{i}.vel = [];
        else
            kin{i}.vel.x = kin{i}.cen_x(2:end)-kin{i}.cen_x(1:end-1);
            kin{i}.vel.y = kin{i}.cen_y(2:end)-kin{i}.cen_y(1:end-1);
            
            spaxis.x = spaxis.x - sum(kin{i}.vel.x(abs(kin{i}.vel.x)>=abs(kin{i}.vel.y) & kin{i}.vel.x<0))...
                - sum(kin{i}.vel.x(abs(kin{i}.vel.x)<abs(kin{i}.vel.y) & kin{i}.vel.y<0))...
                + sum(kin{i}.vel.x(abs(kin{i}.vel.x)>=abs(kin{i}.vel.y) & kin{i}.vel.x>=0))...
                + sum(kin{i}.vel.x(abs(kin{i}.vel.x)<abs(kin{i}.vel.y) & kin{i}.vel.y>=0));
            spaxis.y = spaxis.y - sum(kin{i}.vel.y(abs(kin{i}.vel.y)>=abs(kin{i}.vel.x) & kin{i}.vel.y<0))...
                - sum(kin{i}.vel.y(abs(kin{i}.vel.y)<abs(kin{i}.vel.x) & kin{i}.vel.x<0))...
                + sum(kin{i}.vel.y(abs(kin{i}.vel.y)>=abs(kin{i}.vel.x) & kin{i}.vel.y>=0))...
                + sum(kin{i}.vel.y(abs(kin{i}.vel.y)<abs(kin{i}.vel.x) & kin{i}.vel.x>=0));
            
        end
    end
    
else
    % Pick two points to define spindle axis
    vert = zeros(2,2);
    
    [x,y,button]=ginput(1);
    if button == 1
        x = round(x); y = round(y);
        
        vert(1,1) = x;
        vert(1,2) = y;
        
        [x,y,button]=ginput(1);
        x = round(x); y = round(y);
        
        vert(2,1) = x;
        vert(2,2) = y;
        
        spaxis.x = vert(2,1)-vert(1,1);
        spaxis.y = vert(2,2)-vert(1,2);
    else
        return;
    end
end

%normalize
normconst = sqrt(spaxis.x^2+spaxis.y^2);
spaxis.x = spaxis.x/normconst;
spaxis.y = spaxis.y/normconst;

set(handles.KinetochoreSelectionGui,'CurrentAxes',handles.Image_axes)
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
        
        cen_xi = (kin{i}.cen_x(idxj,1).*(kin{i}.cen_x(idxj,1)>0)+kin{i}.cen_x(idxj,2).*(kin{i}.cen_x(idxj,2)>0))...
            ./(kin{i}.cen_x(idxj,1)>0 + kin{i}.cen_x(idxj,2)>0);
        cen_xj = (kin{j}.cen_x(idxj,1).*(kin{j}.cen_x(idxj,1)>0)+kin{j}.cen_x(idxj,2).*(kin{j}.cen_x(idxj,2)>0))...
            ./(kin{j}.cen_x(idxj,1)>0 + kin{j}.cen_x(idxj,2)>0);
        cen_yi = (kin{i}.cen_y(idxj,1).*(kin{i}.cen_y(idxj,1)>0)+kin{i}.cen_y(idxj,2).*(kin{i}.cen_y(idxj,2)>0))...
            ./(kin{i}.cen_y(idxj,1)>0 + kin{i}.cen_y(idxj,2)>0);
        cen_yj = (kin{j}.cen_y(idxj,1).*(kin{j}.cen_y(idxj,1)>0)+kin{j}.cen_y(idxj,2).*(kin{j}.cen_y(idxj,2)>0))...
            ./(kin{j}.cen_y(idxj,1)>0 + kin{j}.cen_y(idxj,2)>0);
        %displacement
        disp = [cen_xj-cen_xi,cen_yj-cen_yi];
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
        
        idxi = find(ismember(kin{i}.frame,kin{pairidx}.frame)==1);
        idxpair = find(ismember(kin{pairidx}.frame,kin{i}.frame)==1);
        
        %displacement
        disp = [kin{pairidx}.cen_x(idxpair)-kin{i}.cen_x(idxi),kin{pairidx}.cen_y(idxpair)-kin{i}.cen_y(idxi)];
        
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

%leading marker: the sign of dot(velocity,spindle axis) when the
%kinetochore is leading
for i = 1:length(kinpair)
    if kinpair{i}.rejected == 0
        kinid1 = kinpair{i}.kinid(1);
        kinid2 = kinpair{i}.kinid(2);
        
        idx1 = find(ismember(kin{kinid1}.frame,kin{kinid2}.frame)==1);
        idx2 = find(ismember(kin{kinid2}.frame,kin{kinid1}.frame)==1);
        
        %mean displacement vector from kinid1 to 2
        disp12 = mean([kin{kinid2}.cen_x(idx2)-kin{kinid1}.cen_x(idx1),...
            kin{kinid2}.cen_y(idx2)-kin{kinid1}.cen_y(idx1)],1);
        
        kin{kinid1}.leadmarker = -sign(dot(disp12,[spaxis.x,spaxis.y]));
        kin{kinid2}.leadmarker = sign(dot(disp12,[spaxis.x,spaxis.y]));
    end
end

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
    set(handles.KinetochoreSelectionGui,'CurrentAxes',handles.Image_axes);
    if get(hObject,'Value')
        set(spaxis_handle,'Visible','on');
    else
        set(spaxis_handle,'Visible','off');
    end
end

guidata(hObject,handles)



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


frame = handles.frame;
kin = handles.kin;


target ='kin';
switch target
    case 'pair'
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
        for i = 1:length(pair_selected)
            koi = [koi,kinpair{pair_selected(i)}.kinid];
        end
        koi = unique(koi);  %kinetochore ids of kinetochores that will be analyzed
    case 'kin'
        contents = cellstr(get(handles.Kinetochore_listbox,'String'));
        koi = str2double(contents(get(handles.Kinetochore_listbox,'Value'))); 
end


%Bayes Fit Setting

nexpo = 2;
prior = 1;   %Uniform

loaded_irf = load([pathname name]);
time = loaded_irf.time;
decay = loaded_irf.decay;
save('currentIRF','decay','time');
irf = decay;
time_irf = time;
clear decay;
clear time;


lendecay = size(frame{1}.flim,1);

dt = frame{1}.dt;
%flim time axis
time = (1:lendecay)'*dt;

shift = str2double(get(handles.Shift_edit,'String'));
tau1 = str2double(get(handles.Tau1_edit,'String'));
E = str2double(get(handles.Tau2Tau1Ratio_edit,'String'));
fit_start = round(str2double(get(handles.FitStart_edit,'String'))/dt);
fit_end = round(str2double(get(handles.FitEnd_edit,'String'))/dt);

p_min = [shift,0.2,tau1,0.01,E]';
p_max = [shift,1,tau1,1,E]';
dp = [1,0.0025,0.01,0.01,0.01]';


%Bayes setting
bayessetting.shift = shift;
bayessetting.tau1 = tau1;
bayessetting.E = E;
bayessetting.fit_start = fit_start;
bayessetting.fit_end = fit_end;
bayessetting.p_min = p_min;
bayessetting.p_max = p_max;
bayessetting.dp = dp;
bayessetting.prior = prior;


matlabpool;
for i = 1:length(koi)
    %frames where the selected kinetochore appears
    framenum = kin{koi(i)}.frame;
    kin{koi(i)}.decay = zeros(lendecay,length(framenum));
    
    %Bayes result
    %Background level (A) estimate (1st column:post mean,2nd:MAP,3rd:post std dev)
    kin{koi(i)}.bayes.Aest = zeros(3,length(framenum));
    %nonFRETing fraction (F) estimate (1st column:post mean,2nd:MAP,3rd:post std dev)
    kin{koi(i)}.bayes.Fest = zeros(3,length(framenum));
    
    kin{koi(i)}.bayes.post = cell(length(framenum),1);
    kin{koi(i)}.bayes.margpost = cell(length(framenum),1);
    
    for j = 1:length(framenum)
        flim = frame{framenum(j)}.flim;
        
        selected_pixel = kin{koi(i)}.selected_pixel(:,:,j);
        
        reshapedselectedpix = repmat(reshape(selected_pixel',[1,size(selected_pixel')]),[size(flim,1),1,1]);
        kin{koi(i)}.decay(:,j) = sum(sum(reshapedselectedpix.*flim,2),3);
        
        [pavg,sigmap,pvec,post,margpost,map] =...
            bayes_fit(time,kin{koi(i)}.decay(:,j),dp,p_min,p_max,nexpo,prior,fit_start,fit_end,0,1);
        
        kin{koi(i)}.bayes.Aest(:,j) = [pavg(2),map(2),sigmap(2)];
        kin{koi(i)}.bayes.Fest(:,j) = [pavg(4),map(4),sigmap(4)];
        kin{koi(i)}.bayes.post{j} = post;
        kin{koi(i)}.bayes.margpost{j} = margpost;
    end
    
end

matlabpool close

bayessetting.p_vec = pvec;

handles.bayessetting = bayessetting;
handles.kin = kin;

guidata(hObject,handles);




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
set(handles.KPair_listbox,'Value',1);
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
spaxis = handles.spaxis;

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



%mean displacement vector from kinid1 to 2
kin{kinid1}.leadmarker = -sign(dot(meandisp,[spaxis.x,spaxis.y]));
kin{kinid2}.leadmarker = sign(dot(meandisp,[spaxis.x,spaxis.y]));



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

set(handles.KinetochoreSelectionGui,'CurrentAxes',handles.Image_axes);
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
frame = handles.frame;
selected = get(handles.FrameSelection_slider,'Value');

set(handles.KinetochoreSelectionGui,'CurrentAxes',handles.Image_axes);
if get(hObject,'Value')
    set(frame{selected}.time_handle,'Visible','on');
else
    set(frame{selected}.time_handle,'Visible','off');
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


% --- Executes on button press in SaveResult_pushbutton.
function SaveResult_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to SaveResult_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[name pathname filterindex] = uiputfile2('*.mat');

kin = handles.kin;
kinpair = handles.kinpair;
bayessetting = handles.bayessetting;
frame = handles.frame;
pixsize = handles.pixsize;
repeat = handles.repeat;
spaxis = handles.spaxis;
kinstate = handles.kinstate;
res = handles.res;

if name ~= 0
    save([pathname,name],'kin','kinpair','bayessetting','frame','pixsize','repeat','spaxis','kinstate','res');
end


% --- Executes on button press in AutoAxis_checkbox.
function AutoAxis_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to AutoAxis_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of AutoAxis_checkbox



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





% --- Executes on button press in Ch1_checkbox.
function Ch1_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to Ch1_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Ch1_checkbox


% --- Executes on button press in Ch2_checkbox.
function Ch2_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to Ch2_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Ch2_checkbox



function Ch12thres_edit_Callback(hObject, eventdata, handles)
% hObject    handle to Ch12thres_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Ch12thres_edit as text
%        str2double(get(hObject,'String')) returns contents of Ch12thres_edit as a double


% --- Executes during object creation, after setting all properties.
function Ch12thres_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Ch12thres_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


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

function Memory_edit_Callback(hObject, eventdata, handles)
% hObject    handle to Memory_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Memory_edit as text
%        str2double(get(hObject,'String')) returns contents of Memory_edit as a double


% --- Executes during object creation, after setting all properties.
function Memory_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Memory_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function GaussMassThres_edit_Callback(hObject, eventdata, handles)
% hObject    handle to GaussMassThres_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of GaussMassThres_edit as text
%        str2double(get(hObject,'String')) returns contents of GaussMassThres_edit as a double


% --- Executes during object creation, after setting all properties.
function GaussMassThres_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to GaussMassThres_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in ShowKinID_checkbox.
function ShowKinID_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to ShowKinID_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ShowKinID_checkbox

