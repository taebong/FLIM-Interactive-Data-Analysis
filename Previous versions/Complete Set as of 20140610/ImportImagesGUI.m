function varargout = ImportImagesGUI(varargin)
% IMPORTIMAGESGUI MATLAB code for ImportImagesGUI.fig
%      IMPORTIMAGESGUI by itself, creates a new IMPORTIMAGESGUI or raises the
%      existing singleton*.
%
%      H = IMPORTIMAGESGUI returns the handle to a new IMPORTIMAGESGUI or the handle to
%      the existing singleton*.
%
%      IMPORTIMAGESGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in IMPORTIMAGESGUI.M with the given input arguments.
%
%      IMPORTIMAGESGUI('Property','Value',...) creates a new IMPORTIMAGESGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ImportImagesGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ImportImagesGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ImportImagesGUI

% Last Modified by GUIDE v2.5 09-Mar-2014 18:25:47

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ImportImagesGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @ImportImagesGUI_OutputFcn, ...
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

% --- Executes just before ImportImagesGUI is made visible.
function ImportImagesGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ImportImagesGUI (see VARARGIN)

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

% Make the GUI modal
set(handles.figure1,'WindowStyle','modal')

% UIWAIT makes ImportImagesGUI wait for user response (see UIRESUME)
%uiwait(handles.figure1);

% --- Outputs from this function are returned to the command line.
function varargout = ImportImagesGUI_OutputFcn(hObject, eventdata, handles)
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


if ishandle(handles.MainGui)
    hMainGui = guidata(handles.MainGui);
else
    errordlg('Improper call of MainGuihandle')
    return
end

[name pathname filterindex] = uigetfile2('*.sdt','MultiSelect','on');

if iscell(name) | name~=0
    if iscell(name)
        filename = name;
    else
        filename = cell(1,1);
        filename{1} = name;
    end
    
    filename = sort(filename);
    
    %     %Current slider value
    %     slider_value = get(handles.ImageSelection_slider,'Value');
    %Number of newly loaded images
    NumOfNewImages = length(filename);
    %Number of previously opened images
    NumOfPrevImages = hMainGui.NumOfImages;
    %Total number of loaded images
    NumOfImages = NumOfNewImages+NumOfPrevImages;
    
    %Image structure that contains all the information about the newly
    %opened images
    image_struct = cell(NumOfNewImages,1);
    
    %Two photon image block
    %whether or not you want dual color images
    dualcolor = get(handles.ImportM1_togglebutton,'value') && get(handles.ImportM2_togglebutton,'value');
    if dualcolor == 0
        if get(handles.ImportM1_togglebutton,'value')
            block=1; %1:M1, 2:M2
        elseif get(handles.ImportM2_togglebutton,'value')
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
            ch = bh_getdatablock(sdt,block);
            img = zeros(size(ch,2),size(ch,3),3);
            img(:,:,block) = double(squeeze(sum(ch,1)));
            flim = double(ch);
        else
            ch = bh_getdatablock(sdt,1);
            img = zeros(size(ch,2),size(ch,3),3);          
            img(:,:,1) = double(squeeze(sum(ch,1)));
            ch2 = bh_getdatablock(sdt,2);
            img(:,:,2) = double(squeeze(sum(ch2,1)));
            if flimblock == 1
                flim = double(ch);
            else
                flim = double(ch2);
            end
        end
        
        %time/channel = range/(gain*ADCresolution)
        range = sdt.SP_TAC_R*10^9;
        gain = double(sdt.SP_TAC_G);
        resol = double(sdt.SP_ADC_RE);
        dt = range/(gain*resol);
        
        normimg = img;
        normimg(:,:,1) = normimg(:,:,1)/max(max(normimg(:,:,1)));
        normimg(:,:,2) = normimg(:,:,2)/max(max(normimg(:,:,2)));
        image_handle = imagesc(normimg);
        
        hold on 
        axis image;
%         img_size = size(img);
%         if img_size(1)>1 && img_size(2)>1
%             axis([1,img_size(2),1,img_size(1)]);
%         end
%       colorbar;
        set(gca,'FontSize',15);
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
        image_struct{i}.active_region = [];
        %Handles for active region
        image_struct{i}.active_region_handle = [];
        
        fprintf(['Loading (' num2str(i) ' out of ' num2str(NumOfNewImages) ')\n'])
    end
    
    
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
    %Total Number of images loaded
    hMainGui.NumOfImages = NumOfImages;
    
    hMainGui.previous_value = NumOfPrevImages+1;
    set(hMainGui.text9,'String','Ready!')
    
    %Enable decay save
    set(hMainGui.SaveDecay_pushbutton,'Enable','on')

    guidata(handles.MainGui,hMainGui);

    Switch_pushbuttons(hMainGui,'on','image')

end


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

if isequal(get(hObject, 'waitstatus'), 'waiting')
    % The GUI is still in UIWAIT, us UIRESUME
    uiresume(hObject);
else
    % The GUI is no longer waiting, just close it
    delete(hObject);
end


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
