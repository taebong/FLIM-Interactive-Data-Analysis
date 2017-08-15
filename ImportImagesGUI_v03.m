function varargout = ImportImagesGUI_v03(varargin)
% IMPORTIMAGESGUI_V03 MATLAB code for ImportImagesGUI_v03.fig
%      IMPORTIMAGESGUI_V03 by itself, creates a new IMPORTIMAGESGUI_V03 or raises the
%      existing singleton*.
%
%      H = IMPORTIMAGESGUI_V03 returns the handle to a new IMPORTIMAGESGUI_V03 or the handle to
%      the existing singleton*.
%
%      IMPORTIMAGESGUI_V03('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in IMPORTIMAGESGUI_V03.M with the given input arguments.
%
%      IMPORTIMAGESGUI_V03('Property','Value',...) creates a new IMPORTIMAGESGUI_V03 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ImportImagesGUI_v03_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ImportImagesGUI_v03_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ImportImagesGUI_v03

% Last Modified by GUIDE v2.5 24-Jul-2015 11:26:28

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @ImportImagesGUI_v03_OpeningFcn, ...
    'gui_OutputFcn',  @ImportImagesGUI_v03_OutputFcn, ...
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

% --- Executes just before ImportImagesGUI_v03 is made visible.
function ImportImagesGUI_v03_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ImportImagesGUI_v03 (see VARARGIN)

dontOpen = false;
mainGuiInput = find(strcmp(varargin, 'MainGui'));
if (isempty(mainGuiInput)) ...
        || (length(varargin) <= mainGuiInput) ...
        || (~ishandle(varargin{mainGuiInput+1}))
    dontOpen = true;
else
    % Remember the handle, and adjust our position
    handles.MainGui = varargin{mainGuiInput+1};
end

handles.output = 'Cancel';
handles.uManager = false;
handles.sortinfo = -1;

% Update handles structure
guidata(hObject, handles);

% Insert custom Title and Text if specified by the user
% Hint: when choosing keywords, be sure they are not easily confused
% with existing figure properties.  See the output of set(figure) for
% a list of figure properties.
if(nargin > 3)
    for index = 1:2:(nargin-3),
        if nargin-3==index, break, end
        switch lower(varargin{index})
            case 'title'
                set(hObject, 'Name', varargin{index+1});
            case 'string'
                set(handles.text1, 'String', varargin{index+1});
        end
    end
end

% Determine the position of the dialog - centered on the callback figure
% if available, else, centered on the screen
FigPos=get(0,'DefaultFigurePosition');
OldUnits = get(hObject, 'Units');
set(hObject, 'Units', 'pixels');
OldPos = get(hObject,'Position');
FigWidth = OldPos(3);
FigHeight = OldPos(4);
if isempty(gcbf)
    ScreenUnits=get(0,'Units');
    set(0,'Units','pixels');
    ScreenSize=get(0,'ScreenSize');
    set(0,'Units',ScreenUnits);
    
    FigPos(1)=1/2*(ScreenSize(3)-FigWidth);
    FigPos(2)=2/3*(ScreenSize(4)-FigHeight);
else
    GCBFOldUnits = get(gcbf,'Units');
    set(gcbf,'Units','pixels');
    GCBFPos = get(gcbf,'Position');
    set(gcbf,'Units',GCBFOldUnits);
    FigPos(1:2) = [(GCBFPos(1) + GCBFPos(3) / 2) - FigWidth / 2, ...
        (GCBFPos(2) + GCBFPos(4) / 2) - FigHeight / 2];
end
FigPos(3:4)=[FigWidth FigHeight];
set(hObject, 'Position', FigPos);
set(hObject, 'Units', OldUnits);
% 
% % Make the GUI modal
% set(handles.figure1,'WindowStyle','modal')

% UIWAIT makes ImportImagesGUI_v03 wait for user response (see UIRESUME)
%uiwait(handles.figure1);

% --- Outputs from this function are returned to the command line.
function varargout = ImportImagesGUI_v03_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in StartImport_pushbutton.
function StartImport_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to StartImport_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

importop = 2;

if handles.uManager
    sortinfo = handles.sortinfo;
    selected = get(handles.Positions_listbox,'Value');
    posid = str2num(get(handles.Positions_listbox,'String'));
    posid = posid(selected);
    choice = questdlg(['Would you like to import Pos ' regexprep(num2str(posid'),'\s*',',') '?'],'uManager','Yes','No, manually select files','Cancel','Cancel');
    drawnow; pause(0.05);
    pathname = handles.pathname;
    
    switch choice
        case 'Yes'
            importop = 1;
        case 'No, manually select files'
            importop = 2;
        case 'Cancel'
            return
    end
end

if ishandle(handles.MainGui)
    hMainGui = guidata(handles.MainGui);
else
    errordlg('Improper call of MainGuihandle')
    return
end


if importop == 2
    [name pathname filterindex] = uigetfile3('*.sdt;*.mat','MultiSelect','on','mode','data');
    drawnow; pause(0.05);
elseif importop == 1
    Dsdt = dir([pathname '*.sdt']);
    posL = length(posid);
    
    sdtnums = cellfun(@str2double,regexp({Dsdt.name},'_c(\d)*','tokens','once'));
        
    sdtnames = {Dsdt.name};
    sdtnames = sdtnames(:);
    
    Nfile = 0;
    name = [];

    for i = 1:posL
        name = [name;sdtnames(ismember(sdtnums,sortinfo.sdtID(sortinfo.PosID==posid(i))))];
        Nfile = Nfile+length(name);
    end
%     for i = 1:posL
%         ind = sortinfo.PosID == posid(i);
%         
%         commonL = min(sdtL,length(ind));
%         sdtL =  commonL;
%         Dsdt = Dsdt(1:commonL);
%         ind = ind(1:commonL);
%         
%         Nfile = Nfile + sum(ind);
%         
%         if sum(ind) == 0
%             continue;
%         end
%         
%         name = [name,{Dsdt(ind).name}];
%     end
end

if pathname == 0
    return
end

if iscell(name)
    filename = name;
else
    filename = cell(1,1);
    filename{1} = name;
end

ext = filename{1}(end-2:end);
%filename = sort(filename);

%     %Current slider value
%     slider_value = get(handles.ImageSelection_slider,'Value');

if strcmp(ext,'sdt')
    %Number of newly loaded images
    NumOfNewImages = length(filename);
elseif strcmp(ext,'mat')
    newImageStruct = [];
    for i = 1:length(filename)
        temp = load([pathname,filename{i}]);
        newImageStruct = [newImageStruct;temp.image_struct];
    end
    %Number of newly loaded images
    NumOfNewImages = length(newImageStruct);
else
    errordlg('Incompatible file format')
    return
end

%Number of previously opened images
NumOfPrevImages = hMainGui.NumOfImages;
%Total number of loaded images
NumOfImages = NumOfNewImages+NumOfPrevImages;

timestamp = zeros(NumOfNewImages,1);

if strcmp(ext,'sdt')
    %Image structure that contains all the information about the newly
    %opened images
    image_struct = cell(NumOfNewImages,1);
    
    importM1 = get(handles.ImportM1_togglebutton,'value');
    importM2 = get(handles.ImportM2_togglebutton,'value');
    %Two photon image block
    %whether or not you want dual color images
    dualcolor = importM1 && importM2;
    if dualcolor == 0
        if importM1
            block=1; %1:M1, 2:M2
        elseif importM2
            block=2; %1:M1, 2:M2
        end
    end
    if get(handles.M1FLIM_radiobutton,'Value')
        flimblock = 1;
    else
        flimblock = 2;
    end
    
    axes(hMainGui.Image_axes);
    for i = 1:NumOfNewImages
        %load sdt file
        sdt = bh_readsetup([pathname filename{i}]);
        
        if dualcolor == 0
            ch = bh_getdatablock_yoo(sdt,block);
            %            img = zeros(size(ch,2),size(ch,3),3);
            %            img(:,:,block) = double(squeeze(sum(ch,1)));
            img = double(squeeze(sum(ch,1)));
            flim = double(ch);
        else
            ch = bh_getdatablock_yoo(sdt,1);
            img = zeros(size(ch,2),size(ch,3),3);
            img(:,:,1) = double(squeeze(sum(ch,1)));
            ch2 = bh_getdatablock_yoo(sdt,2);
            img(:,:,2) = double(squeeze(sum(ch2,1)));
            if flimblock == 1
                flim = double(ch);
            else
                flim = double(ch2);
            end
        end
        
        %time/channel = range/(gain*ADCresolution)
        dt = getdtfromsdt(sdt);
        timestamp(i) = datenum([sdt.Date,' ',sdt.Time]);
        
        if dualcolor == 1
            normimg = img;
            normimg(:,:,1) = normimg(:,:,1)/max(max(normimg(:,:,1)));
            normimg(:,:,2) = normimg(:,:,2)/max(max(normimg(:,:,2)));
            image_handle = imagesc(normimg);
        else
            image_handle = imagesc(img);
            colormap(gray);
            colorbar;
        end
        
        hold on
        img_size = size(img);
        axis([0.5,img_size(2)+0.5,0.5,img_size(1)+0.5]);

        %       colorbar;
        set(gca,'FontSize',12,'XTick',[],'YTick',[]);
        caxis auto;
        set(image_handle,'Visible','off');
        
        image_struct{i}.dualcolor = dualcolor;
        image_struct{i}.flimblock = flimblock;
        
        %Update image structure
        image_struct{i}.image = img;
        %image plot handle
        image_struct{i}.image_handle = image_handle;
        
        image_struct{i}.filename = filename{i};
        image_struct{i}.pathname = pathname;
        image_struct{i}.dt = dt;
        %1 if pixel selected, 0 if not
        image_struct{i}.selected_pixel = zeros(size(img,1),size(img,2));
        %Handles for plot showing selected pixels
        image_struct{i}.selected_pixel_handle = [];
        %FLIM Data
        image_struct{i}.flim = flim;
        %Fluorescence decay data extracted from selected pixels
        image_struct{i}.decay = zeros(size(flim,1),1);
        %Handles for fluorescence decay data plot
        image_struct{i}.decay_handle = [];
        %Four verices of rectangular active region
        image_struct{i}.active_region = ones(size(img,1),size(img,2));
        %Handles for active region
        image_struct{i}.active_region_handle = [];
        %Image acquisition setting
        image_struct{i}.setting = sdt;
        %timestamp
        image_struct{i}.timestamp = timestamp(i);
        
        fclose('all');
        
        fprintf(['Loading (' num2str(i) ' out of ' num2str(NumOfNewImages) ')\n'])
    end
   

elseif strcmp(ext,'mat')
    
    filename = cell(NumOfNewImages,1);
    image_struct = newImageStruct;
    
    axes(hMainGui.Image_axes);
    for i = 1:NumOfNewImages
        image_handle = imagesc(image_struct{i}.image);
        if image_struct{i}.dualcolor == 0
            colormap gray;
            colorbar;
        end
        hold on
        
        set(gca,'FontSize',12);
        caxis auto;
        set(image_handle,'Visible','off');
        
        img = image_struct{i}.image;
        flim = image_struct{i}.flim;
        
        image_struct{i}.image_handle = image_handle;
        %1 if pixel selected, 0 if not
        image_struct{i}.selected_pixel = zeros(size(img,1),size(img,2));
        %Handles for plot showing selected pixels
        image_struct{i}.selected_pixel_handle = [];
        %Fluorescence decay data extracted from selected pixels
        image_struct{i}.decay = zeros(size(flim,1),1);
        %Handles for fluorescence decay data plot
        image_struct{i}.decay_handle = [];
        %Four verices of rectangular active region
        image_struct{i}.active_region = ones(size(img,1),size(img,2));
        %Handles for active region
        image_struct{i}.active_region_handle = [];
        
        filename{i} = image_struct{i}.filename;
    end
    
    if image_struct{1}.dualcolor
        importM1 = 1;
        importM2 = 1;
    else
        switch image_struct{1}.flimblock
            case 1
                importM1 = 1;
                importM2 = 0;
            case 2
                importM1 = 0;
                importM2 = 1;
        end
    end
end

% %sort based on the timestamp
% [~,ind] = sort(timestamp);
% image_struct = image_struct(ind);
% filename = filename(ind);

%show the first image newly opened
set(image_struct{1}.image_handle,'Visible','on');

%hide all decay curve
set(image_struct{1}.decay_handle,'Visible','off');

%Show filename
if NumOfPrevImages == 0
    set(hMainGui.Filename_popupmenu,'String',filename);
    set(hMainGui.FileName_listbox,'String',filename);
else
    names = get(hMainGui.Filename_popupmenu,'String');
    set(hMainGui.Filename_popupmenu,'String',[names;filename']);
    set(hMainGui.Filename_popupmenu,'Value',NumOfPrevImages+1);
    set(hMainGui.FileName_listbox,'String',[names;filename']);
    set(hMainGui.FileName_listbox,'Value',NumOfPrevImages+1);
end


%update the handles
%image select slider
set(hMainGui.ImageSelection_slider,'Min',1);
set(hMainGui.ImageSelection_slider,'Max',max(NumOfImages,2));
set(hMainGui.ImageSelection_slider,'Value',NumOfPrevImages+1);
set(hMainGui.ImageSelection_slider,'SliderStep',[1,1]/(max(NumOfImages,2)-1))
if NumOfImages>1
    set(hMainGui.ImageSelection_slider,'Visible','on');
end

% update image select popupmenu
set(hMainGui.Filename_popupmenu,'Min',1);
set(hMainGui.Filename_popupmenu,'Max',max(NumOfImages,2));
set(hMainGui.Filename_popupmenu,'Value',NumOfPrevImages+1);

set(hMainGui.FileName_listbox,'Value',NumOfPrevImages+1);

%image structure
hMainGui.image_struct = [hMainGui.image_struct;image_struct];
clear image_struct;
%Total Number of images loaded
hMainGui.NumOfImages = NumOfImages;

hMainGui.previous_value = NumOfPrevImages+1;

%Enable decay save
set(hMainGui.SaveDecay_pushbutton,'Enable','on')

guidata(handles.MainGui,hMainGui);

Switch_pushbuttons(hMainGui,'on','image');

set(hMainGui.ShowM1_togglebutton,'Value',importM1)
set(hMainGui.ShowM2_togglebutton,'Value',importM2)

handles.output = get(hObject,'String');

% Update handles structure
guidata(hObject, handles);

delete(handles.figure1);

% --- Executes on button press in Cancel_pushbutton.
function Cancel_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to Cancel_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.output = get(hObject,'String');

% Update handles structure
guidata(hObject, handles);

delete(handles.figure1);


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% if isequal(get(hObject, 'waitstatus'), 'waiting')
%     % The GUI is still in UIWAIT, us UIRESUME
%     uiresume(hObject);
% else
%     % The GUI is no longer waiting, just close it
%     delete(hObject);
% end
delete(hObject);

% --- Executes on key press over figure1 with no controls selected.
function figure1_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Check for "enter" or "escape"
if isequal(get(hObject,'CurrentKey'),'escape')
    % User said no by hitting escape
    handles.output = 'No';
    
    % Update handles structure
    guidata(hObject, handles);
    
    uiresume(handles.figure1);
end

if isequal(get(hObject,'CurrentKey'),'return')
    uiresume(handles.figure1);
end


% --- Executes on button press in ImportM1_togglebutton.
function ImportM1_togglebutton_Callback(hObject, eventdata, handles)
% hObject    handle to ImportM1_togglebutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ImportM1_togglebutton


% --- Executes on button press in ImportM2_togglebutton.
function ImportM2_togglebutton_Callback(hObject, eventdata, handles)
% hObject    handle to ImportM2_togglebutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ImportM2_togglebutton


% --- Executes on button press in uManager_pushbutton.
function uManager_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to uManager_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
load('dataDir.mat')
pathname = uigetdir(lastUsedDir,'Select folder containing sdt data files with uMan folder');
drawnow; pause(0.05);

if pathname == 0
    return;
end

pathname = [pathname '\'];

addpath MultiDAcq

renamebool = get(handles.Rename_checkbox,'Value');
if renamebool
    sortinfo = MultiD_sdt_rename(pathname,1);
else
    sortinfo = MultiD_sdt_sort_TY(pathname);
end

if ~istable(sortinfo)
    errordlg('invalid folder or uMan folder not exist')
    return;
end

posid = unique(sortinfo.PosID);

handles.uManager = true;
handles.sortinfo = sortinfo;
handles.pathname = pathname;

lastUsedDir = pathname;
save('dataDir.mat','lastUsedDir');

set(handles.Positions_listbox,'String',num2str(posid));
set(handles.Positions_listbox,'Max',length(posid))
set(handles.Positions_listbox,'Min',1)

guidata(hObject,handles);



% --- Executes on selection change in Positions_listbox.
function Positions_listbox_Callback(hObject, eventdata, handles)
% hObject    handle to Positions_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns Positions_listbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Positions_listbox



% --- Executes during object creation, after setting all properties.
function Positions_listbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Positions_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Rename_checkbox.
function Rename_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to Rename_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Rename_checkbox
