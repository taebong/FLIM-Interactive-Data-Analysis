function varargout = KinetochoreSelectionTool_ver6_3(varargin)
% KINETOCHORESELECTIONTOOL_VER6_3 MATLAB code for KinetochoreSelectionTool_ver6_3.fig
%      KINETOCHORESELECTIONTOOL_VER6_3, by itself, creates a new KINETOCHORESELECTIONTOOL_VER6_3 or raises the existing
%      singleton*.
%
%      H = KINETOCHORESELECTIONTOOL_VER6_3 returns the handle to a new KINETOCHORESELECTIONTOOL_VER6_3 or the handle to
%      the existing singleton*.
%
%      KINETOCHORESELECTIONTOOL_VER6_3('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in KINETOCHORESELECTIONTOOL_VER6_3.M with the given input arguments.
%
%      KINETOCHORESELECTIONTOOL_VER6_3('Property','Value',...) creates a new KINETOCHORESELECTIONTOOL_VER6_3 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before KinetochoreSelectionTool_ver6_3_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to KinetochoreSelectionTool_ver6_3_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help KinetochoreSelectionTool_ver6_3
% Last Modified by GUIDE v2.5 18-Aug-2015 12:34:34

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @KinetochoreSelectionTool_ver6_3_OpeningFcn, ...
    'gui_OutputFcn',  @KinetochoreSelectionTool_ver6_3_OutputFcn, ...
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
function varargout = KinetochoreSelectionTool_ver6_3_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



% --- Executes just before KinetochoreSelectionTool_ver6_3 is made visible.
function KinetochoreSelectionTool_ver6_3_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to KinetochoreSelectionTool_ver6_3 (see VARARGIN)

% Choose default command line output for KinetochoreSelectionTool_ver6_3
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes KinetochoreSelectionTool_ver6_3 wait for user response (see UIRESUME)
% uiwait(handles.KinetochoreSelectionGui);

addpath tracking_Kilfoil


dontOpen = false;
mainGuiInput = find(strcmp(varargin, 'MainGui'));
if (isempty(mainGuiInput)) ...
        || (length(varargin) <= mainGuiInput) ...
        || (~ishandle(varargin{mainGuiInput+1}))
    dontOpen = true;
else
    set(0,'currentfigure',handles.KinetochoreSelectionGui)
    % Remember the handle, and adjust our position
    handles.MainGui = varargin{mainGuiInput+1};
    
    hMainGui = getappdata(0,'hMainGui');
    FOI = getappdata(hMainGui,'FOI');
%    N_frame = getappdata(hMainGui,'N_frame');

    pixsize = getappdata(hMainGui,'pixsize');
    
    Nframe = length(FOI);
    
    frame = cell(Nframe,1);
    
    fr0time = timesdt(FOI{1}.setting,'vector');
    
    for i = 1:Nframe
        frame{i}.image = FOI{i}.image;
        frame{i}.filename = FOI{i}.filename;
        frame{i}.dt = FOI{i}.dt;
        frame{i}.flim = FOI{i}.flim;
        frame{i}.setting = FOI{i}.setting;
        frame{i}.time = etime(timesdt(frame{i}.setting,'vector'),fr0time);
        
        img_size = [size(frame{i}.image,1),size(frame{i}.image,2)];
        
        frame{i}.image_handle = zeros(2,1);
        
        set(handles.KinetochoreSelectionGui,'CurrentAxes',handles.Image_axes);
        frame{i}.image_handle(1) = imagesc(frame{i}.image(:,:,1));
        colormap(gray)
        axis([1,img_size(2),1,img_size(1)]);    colorbar;    set(gca,'FontSize',15);
        set(gca,'XTickLabel',[],'YTickLabel',[]);

        caxis auto;
        hold on;
        set(frame{i}.image_handle(1),'Visible','off');
        
        %Add real time
        frame{i}.time_handle = text(0.1*img_size(2),0.1*img_size(1),[num2str(frame{i}.time),' sec'],'fontsize',12,...
            'Color','y','Clipping','on');
        set(frame{i}.time_handle,'Visible','off');
        
        sz = size(frame{i}.image);
        if length(sz)<3
            frame{i}.image(1:sz(1),1:sz(2),2) = zeros(sz(1),sz(2));
        end
        
        set(handles.KinetochoreSelectionGui,'CurrentAxes',handles.Image2_axes);
        frame{i}.image_handle(2) = imagesc(frame{i}.image(:,:,2));
        colormap(gray)
        axis([1,img_size(2),1,img_size(1)]);    colorbar;    set(gca,'FontSize',15);
        set(gca,'XTickLabel',[],'YTickLabel',[]);

        caxis auto;
        hold on;
        set(frame{i}.image_handle(2),'Visible','off');

        set(frame{i}.image_handle,'ButtonDownFcn',@ImageClickCallback);
        
        frame{i}.selected_pixel{i} = zeros(size(FOI{i}.selected_pixel,2),size(FOI{i}.selected_pixel,1));
        
        %id of kinetochore structures in a frame
        frame{i}.kin_id = [];
        %selected pixel plot handle and text handle of each kinetochore in a frame
        
        %circle showing detected kinetochores
        frame{i}.kincircle_handle = [];       
        frame{i}.text_handle=[];
 
        frame{i}.frame_id = i;
    end
    
    %    set(handles.KinetochoreSelectionGui,'CurrentAxes',handles.Image_axes);
    handles.KinetochoreSelectionGui.CurrentAxes = handles.Image_axes;
    
    %Add scale bar
    scalebar_handle = zeros(2,1);
    %in micrometer
    barsize = 2;
    scalebar_handle(1) = line([0.9*img_size(2)-round(barsize/pixsize),0.9*img_size(2)],...
        [0.9*img_size(1),0.9*img_size(1)],'LineWidth',2,'Color','Yellow');
    scalebar_handle(2) = text(0.9*img_size(2)-round(barsize/pixsize),0.9*img_size(1)-5,...
        [num2str(barsize), '{\mu}', 'm'],'Color','yellow','fontsize',12,'Clipping','on');
    
    
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
    handles.ROI = ones(img_size(1),img_size(2));
    handles.ROI_handle = [];
    handles.spaxis_handle = [];
    handles.spaxis = [];
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
    handles.kinpair = [];
    
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


function ImageClickCallback (objectHandle , eventData)
handles = guidata(objectHandle.Parent.Parent);
framenum = handles.FrameSelection_slider.Value;
editmodestr = get(handles.EditMode_uibuttongroup.SelectedObject,'String');

switch editmodestr
    case 'Kinetochore'
        editmode = 1;
    case 'Kinetochore Pair'
        editmode = 2;
end

axesHandle  = get(objectHandle,'Parent');

axesId = 1;
if axesHandle == handles.Image2_axes
    axesId = 2;
end
coord = get(axesHandle,'CurrentPoint'); 
coord = coord(1,1:2);

if isfield(handles,'kin') == 0 | isempty(handles.kin)
    return
else
    kin = handles.kin;
    kinpair = handles.kinpair;
end
if editmode == 2 & isfield(handles,'kinpair') == 0 | isempty(handles.kinpair)
    return
end

frame = handles.frame;


%x, y coordinates averaged over the channels. If only one channel is
%available, take the only available value as the averaged value.
avgx = arrayfun(@(A) sum((A.locsource==-1).*A.x.*(A.x>0)+(A.locsource>=0).*A.mux.*(A.mux>0))./sum((A.locsource==-1).*(A.x>0)+(A.locsource>=0).*(A.mux>0)),kin);
avgy = arrayfun(@(A) sum((A.locsource==-1).*A.y.*(A.y>0)+(A.locsource>=0).*A.muy.*(A.muy>0))./sum((A.locsource==-1).*(A.y>0)+(A.locsource>=0).*(A.muy>0)),kin);
avgx(isnan(avgx))=0;
avgy(isnan(avgy))=0;

if eventData.Button == 3 & editmode == 1
    kinids = frame{framenum}.kin_id;
    distance = sqrt((avgx(kinids,framenum)-coord(1)).^2+...
        (avgy(kinids,framenum)-coord(2)).^2);
%     distance = distance(axesId,:);
    [~,ind] = min(distance);
    selected_kin = kinids(ind);
    prompt = ['What do you want to do with kin' num2str(selected_kin)];
    button = questdlg(prompt,'Choose one option','Change ID','Delete','Cancel','Cancel');
elseif eventData.Button == 3 & editmode == 2
    kinpairids = find([kinpair(:,framenum).kinpairstate]);
    kinids = [kinpair(kinpairids,framenum).kinids];
    kinlocx = reshape(avgx(kinids(:),framenum),[size(kinids,1),size(kinids,2)]);
    kinlocy = reshape(avgy(kinids(:),framenum),[size(kinids,1),size(kinids,2)]);
    %the coordinates of the middle point of kinetochore pairs
    xc = mean(kinlocx,1);
    yc = mean(kinlocy,1);
    distance = sqrt((xc-coord(1)).^2+(yc-coord(2)).^2);
    [~,ind] = min(distance);
    selected_kinpair = kinpairids(ind);
    prompt = ['What do you want to do with kinetochore pair ' num2str(selected_kinpair)];
    button = questdlg(prompt,'Choose one option','Change ID','Delete','Cancel','Cancel');
else
    return;
end


if editmode ==1
    
    switch button
        case 'Change ID'
            nopass = 1;
            while nopass
                answer = inputdlg('Enter new ID');
                if isempty(answer)
                    return
                end
                newid = round(str2num(answer{1}));
                
                allframe = 1:length(frame);
                
                if newid > size(kin,1) || newid < 1
                    button2 = questdlg('Entered ID doesn''t exist. Do you want to assign new ID?');
                    switch button2
                        case 'Yes'
                            newid = size(kin,1)+1;
                            kin(end+1,:) = initializeKinStruct(1,length(frame));
                            nopass = 0;
                        case 'No'
                            return;
                        case 'Cancel'
                            return;
                    end
                elseif kin(newid,framenum).kinstate == 1
                    button3 = questdlg('Entered ID is alread taken by another kinetochore in the same frame. Do you want to delete the other one?');
                    switch button3
                        case 'Yes'
                            nopass = 0;
                            tempind = find(frame{framenum}.kin_id == newid);
                            frame{framenum}.kin_id(tempind) = [];
                            if sum(ishandle(frame{framenum}.text_handle(tempind,:)))
                                delete(frame{framenum}.text_handle(tempind,ishandle(frame{framenum}.text_handle(tempind,:))))
                            end
                            frame{framenum}.text_handle(tempind,:) = [];
                            if sum(ishandle(frame{framenum}.kincircle_handle(tempind,:)))
                                delete(frame{framenum}.kincircle_handle(tempind,ishandle(frame{framenum}.kincircle_handle(tempind,:))))
                            end
                            frame{framenum}.kincircle_handle(tempind,:) = [];
                        case 'No'
                            return;
                        case 'Cancel'
                            return;
                    end
                elseif sum([kin(newid,allframe(allframe~=framenum)).kinstate] == 1)>0
                    existframes = allframe([kin(newid,allframe(allframe~=framenum)).kinstate] == 1);
                    button4 = questdlg(strcat('Entered ID is alread taken by another kinetochore in frames ',...
                        num2str(existframes,'%d,'), '. Do you still want to proceed or use different ID?'),'Entered ID taken','Proceed','Different ID','Cancel','Cancel');
                    switch button4
                        case 'Proceed'
                            nopass = 0;
                        case 'Different ID'
                        case 'Cancel'
                            return;
                    end
                end
            end
            kin(newid,framenum) = kin(selected_kin,framenum);
            kin(selected_kin,framenum) = initializeKinStruct(1,1);
            
            idx = find(frame{framenum}.kin_id == selected_kin);
            frame{framenum}.kin_id(idx) = newid;
            set(frame{framenum}.text_handle(idx,ishandle(frame{framenum}.text_handle(idx,:))),'String',num2str(newid))
            
        case 'Delete'
            idx = find(frame{framenum}.kin_id == selected_kin);
            
            button5 = questdlg('Delete only the one in the current frame? Or in all frames','Options','Only this frame','All frames','Cancel','Cancel');
            
            switch button5
                case 'Only this frame'
                    kin(selected_kin,framenum) = initializeKinStruct(1,1);
                    
                    %remove rejected kinetochores in current frame
                    frame{framenum}.kin_id(idx) = [];
                    if sum(ishandle(frame{framenum}.text_handle(idx,:)))
                        delete(frame{framenum}.text_handle(idx,ishandle(frame{framenum}.text_handle(idx,:))))
                    end
                    frame{framenum}.text_handle(idx,:) = [];
                    if sum(ishandle(frame{framenum}.kincircle_handle(idx,:)))
                        delete(frame{framenum}.kincircle_handle(idx,ishandle(frame{framenum}.kincircle_handle(idx,:))))
                    end
                    frame{framenum}.kincircle_handle(idx,:) = [];
                case 'All frames'
                    frame_num = find([kin(selected_kin,:).kinstate]==1);
                    for j = 1:length(frame_num)
                        idx = find(frame{frame_num(j)}.kin_id == selected_kin);
                        
                        %remove rejected kinetochores in current frame
                        frame{frame_num(j)}.kin_id(idx) = [];
                        if sum(ishandle(frame{frame_num(j)}.text_handle(idx,:)))
                            delete(frame{frame_num(j)}.text_handle(idx,ishandle(frame{frame_num(j)}.text_handle(idx,:))))
                        end
                        frame{frame_num(j)}.text_handle(idx,:) = [];
                        if sum(ishandle(frame{frame_num(j)}.kincircle_handle(idx,:)))
                            delete(frame{frame_num(j)}.kincircle_handle(idx,ishandle(frame{frame_num(j)}.kincircle_handle(idx,:))))
                        end
                        frame{frame_num(j)}.kincircle_handle(idx,:) = [];
                    end
                    
                    %reset corresponding kinetochore structures
                    kin(selected_kin,:) = initializeKinStruct(1,length(frame));
                    
                case 'Cancel'
                    return
            end
            
        case 'Cancel'
            return;
    end
    
elseif editmode == 2
    switch button
        case 'Change ID'
            nopass = 1;
            while nopass
                answer = inputdlg('Enter new ID');
                if isempty(answer)
                    return
                end
                newid = round(str2num(answer{1}));
                
                allframe = 1:length(frame);
                
                if newid > size(kinpair,1) || newid < 1
                    button2 = questdlg('Entered ID doesn''t exist. Do you want to assign new ID?');
                    switch button2
                        case 'Yes'
                            newid = size(kinpair,1)+1;
                            kinpair(end+1,:) = initializeKinPair(1,length(frame));
                            nopass = 0;
                        case 'No'
                            return;
                        case 'Cancel'
                            return;
                    end
                elseif kinpair(newid,framenum).kinpairstate == 1
                    button3 = questdlg('Entered ID is alread taken by another pair in the same frame. Do you want to delete the other one?');
                    switch button3
                        case 'Yes'
                            nopass = 0;
                            kinpair_handle = kinpair(newid,framenum).kinpair_handle;
                            kinpairtext_handle = kinpair(newid,framenum).kinpairtext_handle;
                            
                            delete(kinpair_handle(ishandle(kinpair_handle)));
                            delete(kinpairtext_handle(ishandle(kinpairtext_handle)));
                            
                        case 'No'
                            return;
                        case 'Cancel'
                            return;
                    end
                elseif sum([kinpair(newid,allframe(allframe~=framenum)).kinpairstate] == 1)>0
                    existframes = allframe([kinpair(newid,allframe(allframe~=framenum)).kinpairstate] == 1);
                    button4 = questdlg(strcat('Entered ID is alread taken by another kinetochore in frames ',...
                        num2str(existframes,'%d,'), '. Do you still want to proceed or use different ID?'),'Entered ID taken','Proceed','Different ID','Cancel','Cancel');
                    switch button4
                        case 'Proceed'
                            nopass = 0;
                        case 'Different ID'
                        case 'Cancel'
                            return;
                    end
                end
            end
            kinpair(newid,framenum) = kinpair(selected_kinpair,framenum);
            kinpair(selected_kinpair,framenum) = initializeKinPair(1,1);
            
        case 'Delete'
            button5 = questdlg('Delete only the one in the current frame? Or in all frames','Options','Only this frame','All frames','Cancel','Cancel');
            
            switch button5
                case 'Only this frame'
                    kinpair_handle = kinpair(selected_kinpair,framenum).kinpair_handle;
                    kinpairtext_handle = kinpair(selected_kinpair,framenum).kinpairtext_handle;
                    delete(kinpair_handle(ishandle(kinpair_handle)));
                    delete(kinpairtext_handle(ishandle(kinpairtext_handle)));
                    
                    kinpair(selected_kinpair,framenum) = initializeKinPair(1,1);
                    
                case 'All frames'
                    contents = cellstr(get(handles.KPair_listbox,'String'));
                    selected = get(handles.KPair_listbox,'Value');
                    Nframe = size(kinpair,2);

                    pairids = zeros(length(contents),1);
                    %pair id selected
                    for i = 1:length(contents)
                        len = strfind(contents{i},':')-1;
                        pairids(i) = str2double(contents{i}(1:len));
                    end
                    
                    kinpair_handle = [kinpair(selected_kinpair,:).kinpair_handle];
                    kinpairtext_handle = [kinpair(selected_kinpair,:).kinpairtext_handle];
                    delete(kinpair_handle(ishandle(kinpair_handle)));
                    delete(kinpairtext_handle(ishandle(kinpairtext_handle)));
                    
                    kinpair(selected_kinpair,:) = initializeKinPair(length(selected),Nframe);
                    
                    newcontents = contents;
                    newcontents(pairids==selected_kinpair) = [];
                    set(handles.KPair_listbox,'Value',1);
                    set(handles.KPair_listbox,'String',newcontents);
                    
                    kinpair = DrawKinPair(handles,kinpair);
                    
                case 'Cancel'
                    return
            end
            
        case 'Cancel'
            return;
    end
end


% handles.location = location;
handles.kin = kin;
handles.kinpair = kinpair;
% handles.kinstate = kinstate;
handles.frame = frame;

handles = updateKinetochoreListbox(handles);

guidata(handles.KinetochoreSelectionGui,handles);


function updatedhandles = updateKinetochoreListbox(handles)
kin = handles.kin;
frame = handles.frame;

Nkin = size(kin,1);
Nframe = length(frame);

kinstate = reshape([kin.kinstate],[Nkin,Nframe]);

%check whether kinetochore exist in any frame;
kinstatefr = sum(kinstate,2);
ghostkin = find(kinstatefr==0);
existkin = find(kinstatefr>0);

contents = cellstr(get(handles.Kinetochore_listbox,'String'));
%get rid of kinetochores that doesn't exist in any frame from the list
contents(ismember(str2double(contents),ghostkin)) = [];
%add kinetochores that exist in some frames but are not in the list
tobeadded = cellstr(num2str(existkin(ismember(existkin,str2double(contents))==0)));
contents = [contents;tobeadded];
contents(strcmp(contents,''))=[];
set(handles.Kinetochore_listbox,'String',cellstr(num2str(sort(str2double(contents)))));


set(handles.Kinetochore_listbox,'Value',1);
set(handles.Kinetochore_listbox,'String',contents);

updatedhandles = handles;


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
kinpair = handles.kinpair;
ROI = handles.ROI;
showkin = get(handles.ShowKinID_checkbox,'Value');
showpair = get(handles.ShowKinPair_checkbox,'Value');

if isempty(kin)
    kintoshow = [];
else
    kintoshow = transpose(find([kin(:,selected).kinstate]==1));
    kintoshow = repmat(kintoshow,[1,2]);
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

if showkin
    if isempty(frame{selected}.kin_id) == 0
        set(frame{selected}.kincircle_handle(ishandle(frame{selected}.kincircle_handle) & kintoshow),'Visible','on')
        set(frame{selected}.text_handle(ishandle(frame{selected}.text_handle) & kintoshow),'Visible','on')
    end
end

%Update Kinpair
if isempty(kinpair) == 0
    kinpair_handle = [kinpair.kinpair_handle];
    set(kinpair_handle(ishandle(kinpair_handle)),'Visible','off');
end
if showpair
    if isempty(kinpair) == 0
        kinpair_handle = [kinpair(:,selected).kinpair_handle];
        set(kinpair_handle(ishandle(kinpair_handle)),'Visible','on');
    end
end
    
if get(handles.AutoscaleROI_checkbox,'value')
    img = frame{selected}.image;
    for ch = 1:2
        img_ROI = img(:,:,ch).*ROI;
        
        if ishandle(frame{selected}.image_handle(ch))
            if ch == 1
                set(handles.KinetochoreSelectionGui,'CurrentAxes',handles.Image_axes);
            elseif ch ==2
                set(handles.KinetochoreSelectionGui,'CurrentAxes',handles.Image2_axes);
            end
            caxis([0 max(img_ROI(:))]);
        end
    end
else
    for ch = 1:2
        if ishandle(frame{selected}.image_handle(ch))
            if ch == 1
                set(handles.KinetochoreSelectionGui,'CurrentAxes',handles.Image_axes);
            elseif ch ==2
                set(handles.KinetochoreSelectionGui,'CurrentAxes',handles.Image2_axes);
            end
            caxis auto
        end
    end
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

if prod(ROI(:))
    buttonname = questdlg('ROI not set up. Do you want to set ROI to entire image?','Region of Interest');
    if strcmp(buttonname,'Cancel') 
        return;
    elseif strcmp(buttonname,'No')
        if ch1
            set(handles.KinetochoreSelectionGui,'CurrentAxes',handles.Image_axes);
            [ROI,xi,yi] = roipoly();
        elseif ch2
            set(handles.KinetochoreSelectionGui,'CurrentAxes',handles.Image2_axes);
            [ROI,xi,yi] = roipoly();
        end
        
        if ishandle(ROI_handle)
            delete(ROI_handle);
        end
        
        set(handles.KinetochoreSelectionGui,'CurrentAxes',handles.Image_axes);
        ROI_handle1 = drawPolygon([xi,yi],'w','LineWidth',2);
        set(handles.KinetochoreSelectionGui,'CurrentAxes',handles.Image2_axes);
        ROI_handle2 = drawPolygon([xi,yi],'w','LineWidth',2);
        
        ROI_handle = [ROI_handle1;ROI_handle2];
    end
end



img_ROI = img.*repmat(ROI,[1,1,size(img,3)]);

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
ch12thres = str2double(get(handles.Ch12thres_edit,'String'));

maxdisp = str2double(get(handles.MaxDisplacement_edit,'String'));
goodenough = str2double(get(handles.GoodEnough_edit,'String'));
memory = str2double(get(handles.Memory_edit,'String'));

frame = handles.frame;
Nframe = length(frame);
ROI = handles.ROI;
ROI_handle = handles.ROI_handle;
ch1 = get(handles.Ch1_checkbox,'Value');
ch2 = get(handles.Ch2_checkbox,'Value');

img_size = size(frame{1}.image);

framearr = cell2mat(frame);
time = [framearr.time];

if prod(ROI(:))
    buttonname = questdlg('ROI not set up. Do you want to set ROI to entire image?','Region of Interest');
    if strcmp(buttonname,'Cancel') 
        return;
    elseif strcmp(buttonname,'No')
        if ch1
            set(handles.KinetochoreSelectionGui,'CurrentAxes',handles.Image_axes);
            [ROI,xi,yi] = roipoly();
        elseif ch2
            set(handles.KinetochoreSelectionGui,'CurrentAxes',handles.Image2_axes);
            [ROI,xi,yi] = roipoly();
        end
        
        if ishandle(ROI_handle)
            delete(ROI_handle);
        end
        
        set(handles.KinetochoreSelectionGui,'CurrentAxes',handles.Image_axes);
        ROI_handle1 = drawPolygon([xi,yi],'w','LineWidth',2);
        set(handles.KinetochoreSelectionGui,'CurrentAxes',handles.Image2_axes);
        ROI_handle2 = drawPolygon([xi,yi],'w','LineWidth',2);
        
        ROI_handle = [ROI_handle1;ROI_handle2];
    end
end

handles.ROI = ROI;
handles.ROI_handle = ROI_handle;

%remove all kinetochore pairs
kinpair = handles.kinpair;
if isempty(kinpair) == 0
    kinpair_handle = [kinpair.kinpair_handle];
    kinpairtext_handle = [kinpair.kinpairtext_handle];
    delete(kinpair_handle(ishandle(kinpair_handle)))
    delete(kinpairtext_handle(ishandle(kinpairtext_handle)))
end
kinpair = [];

tic

if ch1
    d=0;
    
    for i = 1:Nframe
        img = handles.frame{i}.image;
        img_ROI = img(:,:,1).*ROI;
        
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
    
else
    MT1 = [];
end

if ch2
    d = 0;
    
    for i = 1:Nframe
        img = handles.frame{i}.image;
        img_ROI = img(:,:,2).*ROI;
        
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
        idx = find(MT1(:,6)==MT2(i,6) & sqrt((MT1(:,1)-MT2(i,1)).^2+(MT1(:,2)-MT2(i,2)).^2)<ch12thres);
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

% kinetochore structure (N kinetochoresXN frames structure array)
% fields:
%   locsource: source of location info, -1 if CM, 0 if nonconverged Gauss fit, 1 if
%   converged Gauss fit
%   x, y: x and y position. 2x1 array
%   radius: radius of selection coverage. 2x1 array
kin = initializeKinStruct(Nkin,Nframe);
for i = 1:Nkin
    ind = res(:,8,1)==i;
    kinframe = res(ind,6,1);
    kinres = res(ind,:,:);
    for j = 1:length(kinframe)
        kin(i,kinframe(j)).time = kinres(j,7,1);
        kin(i,kinframe(j)).selected_pixel = zeros(img_size(1),img_size(2));
        kin(i,kinframe(j)).kinstate = 1;
%         kin(i,kinframe(j)).locsource = squeeze((kinres(j,1,:)==0)*-99+(kinres(j,1,:)~=0)*-1);
        kin(i,kinframe(j)).locsource = [-1;-1];
        kin(i,kinframe(j)).x = squeeze(kinres(j,1,:));
        kin(i,kinframe(j)).y = squeeze(kinres(j,2,:));
        kin(i,kinframe(j)).Rg = sqrt(squeeze(kinres(j,4,:)));
    end
end

%frame structure
for i = 1:Nframe
    ind = res(:,6,1)==i;
    frame{i}.kincircle_handle = -99*ones(sum(ind),2);
    frame{i}.text_handle = -99*ones(sum(ind),2);
    frame{i}.kin_id = res(ind,8,1);
end

% %arrays containing information about whether or not kinetochore is accepted as a good kinetochore or not
% kinstate = zeros(size(res,1),3);
% %col1: kin id
% kinstate(:,1) = res(:,8,1);
% %col2: frame num
% kinstate(:,2) = res(:,6,1);
% %col3: 1 if this kinetochore is accepted, 0 if rejected
% kinstate(:,3) = 1;

% %save location info
% location = zeros(size(res,1),6,2);
% %col1: kinid, col2: frame num
% location(:,1,:) = res(:,8,:);
% location(:,2,:) = res(:,6,:);
% %col3: source of location info, -1 if CM, 0 if nonconverged Gauss fit, 1 if
% %converged Gauss fit, -99 if not available
% location(:,3,:) = (res(:,1,:)==0)*-99+(res(:,1,:)~=0)*-1;
% %col4,5: x and y coordinates
% location(:,4:5,:) = res(:,1:2,:);
% %col6: radius of selection coverage
% location(:,6,:) = sqrt(res(:,4,:))*coverage;

[frame,kin] = DrawKinCircle_updated(handles,frame,kin);

set(handles.Kinetochore_listbox,'String',num2str((1:max(res(:,8,1)))'))
set(handles.Kinetochore_listbox,'Max',max(res(:,8,1)));

handles.frame = frame;
handles.kin = kin;
handles.kinpair = kinpair;

handles.spaxis = [];
if ishandle(handles.spaxis_handle)
    delete(handles.spaxis_handle)
end

set(handles.KPair_listbox,'value',1);
set(handles.KPair_listbox,'String','');

disp(['The program ran for ' num2str(toc/60) ' minutes'])

for i =1:Nframe
    set(frame{i}.image_handle,'ButtonDownFcn',@ImageClickCallback);     
end

guidata(hObject,handles);


function [outframe,outkin] = DrawKinCircle_updated(handles,inframe,inkin)


%the number of circles to be updated
Nkin = size(inkin,1);
Nframe = size(inframe,1);
flimblock = handles.flimblock;
Ncircle = Nkin*Nframe*2;
coverage = str2double(get(handles.Coverage_edit,'String'));
showkin = get(handles.ShowKinID_checkbox,'Value');

img_size = size(inframe{1}.image);
[X,Y] = meshgrid(1:img_size(1),1:img_size(2));
for i = 1:Nkin
    for j = 1:Nframe
        check = 0;
        for ch = 1:2
            kinstate = inkin(i,j).kinstate;
            if kinstate == 0 
                check = check+1;
                continue;
            end
            kinid = i;
            fr = j;
            source = inkin(i,j).locsource(ch);
            
            if source == -1   %from center of mass
                color = 'g';
                cenx = inkin(i,j).x(ch);
                ceny = inkin(i,j).y(ch);
                Rcover = inkin(i,j).Rg(ch)*coverage;
            elseif source == 0
                color = 'r';
            elseif source == 1
                color = 'b';
                
            end
            
            if source == 0 | source ==1  % from Gauss fit
                cenx = inkin(i,j).mux(ch);
                ceny = inkin(i,j).muy(ch);
                ra = inkin(i,j).sigx(ch)*coverage;
                rb = inkin(i,j).sigy(ch)*coverage;
                theta = inkin(i,j).theta;
            end
            
            if cenx == 0
                check = check+1;    
                continue;        
            end
            
            ind = inframe{fr}.kin_id == kinid;
            
            if ch == 1
                set(handles.KinetochoreSelectionGui,'CurrentAxes',handles.Image_axes)
            elseif ch == 2
                set(handles.KinetochoreSelectionGui,'CurrentAxes',handles.Image2_axes)
            end
            
            if isempty(ind) == 0 & sum(ind) == 1
                kincircle_handle = inframe{fr}.kincircle_handle(ind,ch);
                if ishandle(kincircle_handle)
                    delete(kincircle_handle)
                end
                text_handle = inframe{fr}.text_handle(ind,ch);
                if ishandle(text_handle)
                    delete(text_handle)
                end
            elseif isempty(ind) | sum(ind) == 0
                error('kinetochore id vector is empty or not found')
            elseif sum(ind) > 1
                error('Multiple indentical kinetochore ids were detected in the same frame, same channel');
            end
            
            if source == -1
                %(Re)draw kinetochore circles
                kincircle_handle = DrawCircle(cenx,ceny,Rcover,color);
            else
                %Draw ellipse
                kincircle_handle = ellipse(ra,rb,theta,cenx,ceny,color);
                set(kincircle_handle,'LineWidth',1.5);
            end
            text_handle = text(cenx-2,ceny-2,num2str(kinid),'Clipping','on');
            set(kincircle_handle,'Visible','off')
            set(text_handle,'Visible','off','FontSize',12,'Color','y','FontWeight','bold','HorizontalAlignment','right')
            
            inframe{fr}.kincircle_handle(ind,ch) = kincircle_handle;
            inframe{fr}.text_handle(ind,ch) = text_handle;
            
            %(Re)make selected pixel matrices in kin structure
            if ch == flimblock
                cenx = inkin(i,j).x(ch);
                ceny = inkin(i,j).y(ch);
                if cenx>0
                    inkin(kinid,fr).selected_pixel(:,:) =...
                        ((X-cenx).^2+(Y-ceny).^2<=Rcover^2);
                end
            end
            check = check+1;
            
            Nchecked = ((i-1)*Nframe+j-1)*2+ch;
            if Nchecked>Ncircle/10 & Nchecked<Ncircle/10+1
                disp('10% done')
                drawnow
            elseif Nchecked>2*Ncircle/10 & Nchecked<2*Ncircle/10+1
                disp('20% done')
                drawnow
            elseif Nchecked>3*Ncircle/10 & Nchecked<3*Ncircle/10+1
                disp('30% done')
                drawnow
            elseif Nchecked>4*Ncircle/10 & Nchecked<4*Ncircle/10+1
                disp('40% done')
                drawnow
            elseif Nchecked>5*Ncircle/10 & Nchecked<5*Ncircle/10+1
                disp('50% done')
                drawnow
            elseif Nchecked>6*Ncircle/10 & Nchecked<6*Ncircle/10+1
                disp('60% done')
                drawnow
            elseif Nchecked>7*Ncircle/10 & Nchecked<7*Ncircle/10+1
                disp('70% done')
                drawnow
            elseif Nchecked>8*Ncircle/10 & Nchecked<8*Ncircle/10+1
                disp('80% done')
                drawnow
            elseif Nchecked>9*Ncircle/10 & Nchecked<9*Ncircle/10+1
                disp('90% done')
                drawnow
            end
        end
        
        if check == 0
            error('this kinetochore cannot be found in any frame?')
            return;
        end
        
        
    end
end

frame = inframe;
selected = get(handles.FrameSelection_slider,'Value');
if showkin
    set(frame{selected}.kincircle_handle(ishandle(frame{selected}.kincircle_handle)),'Visible','on')
    set(frame{selected}.text_handle(ishandle(frame{selected}.text_handle)),'Visible','on')
end
set(frame{selected}.kincircle_handle(ishandle(frame{selected}.kincircle_handle)),'ButtonDownFcn',@ImageClickCallback)
set(frame{selected}.text_handle(ishandle(frame{selected}.text_handle)),'ButtonDownFcn',@ImageClickCallback)

outframe = inframe;
outkin = inkin;


function kinstruct = initializeKinStruct(a,b)
kinstruct = struct('time',cell(a,b),'selected_pixel',cell(a,b),...
    'kinstate',0,'locsource',[-99;-99],...
    'x',[0;0],'y',[0;0],'Rg',[0;0],'mux',[0;0],'muy',[0;0],'sigx',[0;0],...
    'sigy',[0;0],'theta',[0;0],'A',[0;0],'bg',[0;0],'converged',[0;0]);



% --- Executes on button press in StartGaussFit_pushbutton.
function StartGaussFit_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to StartGaussFit_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

addpath 2DGaussFit

frame = handles.frame;
kin = handles.kin;
GaussPreffered = get(handles.GaussPreffered_checkbox,'Value');
includenonconverged = get(handles.IncludeNonconverged_checkbox,'Value');
plotGaussfit = get(handles.PlotGaussFitResult_checkbox,'value');
bglevel = str2double(get(handles.BackgroundLevel_edit,'String'));
ch1 = get(handles.Ch1_checkbox,'Value');
ch2 = get(handles.Ch2_checkbox,'Value');

Nframe = length(frame);
Nkin = size(kin,1);

%threshold of distance between two kinetochores below which those kinetochores are considered connected
% if connect_thres = a, the threshold is a*(radius_1+radius_2)
connect_thres = 1.5;

resol = 20;
%whether or not you want to force sigx = sigy
couplesig = 0;

hplot = -99;
Ntot = sum(sum([kin.x]>0));
disp([num2str(Ntot), ' kinetochores to be fit..']);

Nconverged = 0;
tic
for fr = 1:Nframe
    for ch = 1:2
        if ch == 1 && ch1==0
                continue;
            elseif ch == 2 && ch2==0
                continue;
        end
        
        image = frame{fr}.image(:,:,ch);
                
        %coordinates of kinetochores
        x = [kin(:,fr).x];
        y = [kin(:,fr).y];
        
        x = x(ch,:);
        y = y(ch,:);
        
        %radius of kinetochores
        Rg = [kin(:,fr).Rg];
        radius = Rg(ch,:)*1.5;
        
        %map showing the existance of pairs
        existvec = x>0;
        existmap = bsxfun(@and,existvec.',existvec);
        existmap(1:Nkin+1:end) = 0;
        
        
        %calculate pairwise distance
        D = pdist([x',y']);
        distmap = squareform(D);
        
        distthres = connect_thres*bsxfun(@plus,radius.',radius);
        
        connectivity = (distmap<=distthres).*existmap;
        connectivity = triu(connectivity);
        
        [i,j] = find(connectivity);
        
        connected_pairs = [i,j];
        available_kin = find(existvec);
        
        Navail = length(available_kin);
        
        while Navail > 0
            kinToFit = available_kin(1);
            if kinToFit == 16;
                blah = 1;
            end
            
            %find connected kinetochores and add them to kinToFit
            check = 1;
            while check
                idx = ismember(connected_pairs,kinToFit);
                if sum(idx(:)) == 0
                    check = 0;
                else
                    [rows,cols] = find(idx);
%                     kinToFit = [kinToFit;connected_pairs(rows,mod(cols,2)+1)];
                    kinToFit = [kinToFit;sum(connected_pairs(rows,:).*~idx(rows,:),2)];
                    connected_pairs(rows,:) = [];
                end
            end
            
            available_kin(ismember(available_kin,kinToFit)) = [];
            Navail = length(available_kin);
            
            NkinToFit = length(kinToFit);
            %initial guess of gaussian fitting
            [xinit,yinit,sigxinit,sigyinit] = constructParamVector(kin(kinToFit,fr),ch);
            
            Rg = [kin(kinToFit,fr).Rg];
            radius = Rg(ch,:)*1.5;
            radius = radius(:);
            xlin = min(floor(xinit-2.5*radius)):max(ceil(xinit+2.5*radius));
            ylin = min(floor(yinit-2.5*radius)):max(ceil(yinit+2.5*radius));
            
            thetainit = zeros(NkinToFit,1);
            Ainit = zeros(NkinToFit,1);
            for i = 1:NkinToFit
                Ainit(i) = image(round(yinit(i)),round(xinit(i)))-bglevel;
            end
           
            mask = generateCircularMask(xlin,ylin,xinit,yinit,2.5*radius);
            
            c = [resol,couplesig,1,NkinToFit];
            
            ConstructGlobalVar(xlin,ylin,c);
            
            disp(['Fitting for Kinetochores ' num2str(kinToFit','%d, ') 'in frame ' num2str(fr) '...']);
            [mux,muy,sigx,sigy,theta,A,bg,converged] = ...
                GaussianMixture2DLMMLE(image(ylin,xlin),xlin,ylin,xinit,yinit,...
                sigxinit,sigyinit,thetainit,Ainit,bglevel,c,mask);
%             mux = zeros(NkinToFit,1);
%             muy = mux;
%             sigx = mux;
%             sigy = mux;
%             theta = mux;
%             A = mux;
%             bg = 0;
%             converged = 1;
            
            if converged
                Nconverged = Nconverged+NkinToFit;
            end
            
            for i = 1:NkinToFit
                kin(kinToFit(i),fr).mux(ch) = mux(i);
                kin(kinToFit(i),fr).muy(ch) = muy(i);
                kin(kinToFit(i),fr).sigx(ch) = sigx(i);
                kin(kinToFit(i),fr).sigy(ch) = sigy(i);
                kin(kinToFit(i),fr).theta(ch) = theta(i);
                kin(kinToFit(i),fr).A(ch) = A(i);
                kin(kinToFit(i),fr).bg(ch) = bg;
                kin(kinToFit(i),fr).converged(ch) = converged;
            end
            
            if plotGaussfit == 1
                if ishandle(hplot)
                    close(hplot)
                end
                
                %plot the result
                hplot = figure;
                pfit = [mux;muy;sigx;sigy;theta;A;bg];
                zfit = JointGaussianModel_v01(xlin,ylin,pfit,c);
                maskedimage = image(ylin,xlin).*mask;
                maskedzfit = zfit.*mask;
                subplot(1,2,1), imagesc(maskedimage)
                axis image;
                text(mean(x),min(y)-1.5,['# photons=',num2str(sum(maskedimage(:))/NkinToFit)],'HorizontalAlignment','center');
                
                subplot(1,2,2), imagesc(zfit.*mask)
                axis image;
                
                text(mean(x),min(y)-2,['# photons=',num2str(sum(maskedzfit(:)))],'HorizontalAlignment','center');
                drawnow
            end
            
            ClearGlobalVar;
        end
        
        
    end
end
toc

disp(['2D Gauss fit has been performed on ', num2str(Ntot)]); 
disp([num2str(Nconverged),' out of ', num2str(Ntot), ' Gauss fits have been converged.']);

if ishandle(hplot)
    close(hplot)
end

if GaussPreffered == 1
    for fr = 1:Nframe
        for kinid = 1:Nkin
            for ch = 1:2
                if kin(kinid,fr).mux(ch)==0
                    continue;
                elseif kin(kinid,fr).converged(ch) == 0 && includenonconverged
                    kin(kinid,fr).locsource(ch) = 0;
                elseif kin(kinid,fr).converged(ch) == 0 && includenonconverged == 0
                    kin(kinid,fr).locsource(ch) = -1;
                elseif kin(kinid,fr).converged(ch) == 1
                    kin(kinid,fr).locsource(ch) = 1;
                end
            end
        end
    end
end


[frame,kin] = DrawKinCircle_updated(handles,frame,kin);    

% set(frame{selected}.kincircle_handle(ishandle(frame{selected}.kincircle_handle)),'Visible','on')
% set(frame{selected}.text_handle(ishandle(frame{selected}.text_handle)),'Visible','on')
% set(frame{selected}.kincircle_handle(ishandle(frame{selected}.kincircle_handle)),'ButtonDownFcn',@ImageClickCallback)
% set(frame{selected}.text_handle(ishandle(frame{selected}.text_handle)),'ButtonDownFcn',@ImageClickCallback)

handles.frame = frame;
handles.kin = kin;

guidata(hObject,handles)


function [mux,muy,sigx,sigy] = constructParamVector(kin,ch)
% [mux,muy,sigx,sigy] = constructParamVector(kin,ch)
% construct initial guess parameter vector from kinetochore structure in given channel ch.
% kin should be a vector of kinetochore structure
% the length of each param vector should be length(kin)
Nkin = length(kin);

mux = [kin.x];
mux = mux(ch,:);
mux = mux(:);

muy = [kin.y];
muy = muy(ch,:);
muy = muy(:);

sigx = [kin.Rg];
sigx = sigx(ch,:);
sigx = sigx(:);
sigy = sigx;



% --- Executes on button press in GaussPreffered_checkbox.
function GaussPreffered_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to GaussPreffered_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of GaussPreffered_checkbox
GaussPreffered = get(hObject,'Value');
frame = handles.frame;
kin = handles.kin;
includenonconverged = get(handles.IncludeNonconverged_checkbox,'Value');
selected = get(handles.FrameSelection_slider,'Value');
Nframe = length(frame);
Nkin = size(kin,1);

if GaussPreffered == 1
    for fr = 1:Nframe
        for kinid = 1:Nkin
            for ch = 1:2
                if kin(kinid,fr).mux(ch)==0
                    continue;
                elseif kin(kinid,fr).converged(ch) == 0 && includenonconverged
                    kin(kinid,fr).locsource(ch) = 0;
                elseif kin(kinid,fr).converged(ch) == 0 && includenonconverged == 0
                    kin(kinid,fr).locsource(ch) = -1;
                elseif kin(kinid,fr).converged(ch) == 1
                    kin(kinid,fr).locsource(ch) = 1;
                end
            end
        end
    end
elseif GaussPreffered == 0
    for fr = 1:Nframe
        for kinid = 1:Nkin
            kin(kinid,fr).locsource = [-1;-1];
        end
    end 
end

[frame,kin] = DrawKinCircle_updated(handles,frame,kin);

set(frame{selected}.kincircle_handle(ishandle(frame{selected}.kincircle_handle)),'Visible','on')
set(frame{selected}.text_handle(ishandle(frame{selected}.text_handle)),'Visible','on')
set(frame{selected}.kincircle_handle(ishandle(frame{selected}.kincircle_handle)),'ButtonDownFcn',@ImageClickCallback)
set(frame{selected}.text_handle(ishandle(frame{selected}.text_handle)),'ButtonDownFcn',@ImageClickCallback)


handles.frame = frame;
handles.kin = kin;

guidata(hObject,handles)



% --- Executes on button press in IncludeNonconverged_checkbox.
function IncludeNonconverged_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to IncludeNonconverged_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of IncludeNonconverged_checkbox

includenonconverged = get(hObject,'Value');
frame = handles.frame;
kin = handles.kin;
GaussPreffered = get(handles.GaussPreffered_checkbox,'Value');
selected = get(handles.FrameSelection_slider,'Value');
Nframe = length(frame);
Nkin = size(kin,1);

if GaussPreffered == 1
    for fr = 1:Nframe
        for kinid = 1:Nkin
            for ch = 1:2
                if kin(kinid,fr).mux(ch)==0
                    continue;
                elseif kin(kinid,fr).converged(ch) == 0 & includenonconverged
                    kin(kinid,fr).locsource(ch) = 0;
                elseif kin(kinid,fr).converged(ch) == 0 & includenonconverged == 0
                    kin(kinid,fr).locsource(ch) = -1;
                elseif kin(kinid,fr).converged(ch) == 1
                    kin(kinid,fr).locsource(ch) = 1;
                end
            end
        end
    end
elseif GaussPreffered == 0
    %do nothing
    return;
end

[frame,kin] = DrawKinCircle_updated(handles,frame,kin);

set(frame{selected}.kincircle_handle(ishandle(frame{selected}.kincircle_handle)),'Visible','on')
set(frame{selected}.text_handle(ishandle(frame{selected}.text_handle)),'Visible','on')
set(frame{selected}.kincircle_handle(ishandle(frame{selected}.kincircle_handle)),'ButtonDownFcn',@ImageClickCallback)
set(frame{selected}.text_handle(ishandle(frame{selected}.text_handle)),'ButtonDownFcn',@ImageClickCallback)

handles.frame = frame;
handles.kin = kin;

guidata(hObject,handles)


%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% --- Executes on button press in CombineKinetochores_pushbutton.
function CombineKinetochores_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to CombineKinetochores_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
contents = cellstr(get(handles.Kinetochore_listbox,'String'));
kinselected = str2double(contents(get(handles.Kinetochore_listbox,'Value')));
frame = handles.frame;
kin = handles.kin;

Nkinselected = length(kinselected);
Nframe = length(frame);
if Nkinselected < 2
    return
end

kinstate = reshape([kin(kinselected,:).kinstate],[Nkinselected,Nframe]);
%check the overlap
if sum(prod(kinstate))>0
    errordlg(['Selected kinetochores appear in the same frame:',num2str(find(prod(kinstate)),'%d,')])
    return
end

%representative kinetochore. Every other kinetochore will be regarded as
%the same kinetochores as this one
repkin = min(kinselected);

for i = 1:Nframe
    kinid = kinselected(kinstate(:,i)==1);
    if isempty(kinid)
        continue;
    end
    if kinid == repkin
        continue;
    end
    kin(repkin,i) = kin(kinid,i);
    idx = find(frame{i}.kin_id==kinid);
    frame{i}.kin_id(idx) = repkin;
    set(frame{i}.text_handle(idx,ishandle(frame{i}.text_handle(idx,:))),'String',num2str(repkin))
end

kin(kinselected(kinselected~=repkin),:) = initializeKinStruct(Nkinselected-1,Nframe);

contents(ismember(str2double(contents),kinselected(2:end)))=[];
set(handles.Kinetochore_listbox,'String',contents)
set(handles.Kinetochore_listbox,'Value',1)

handles.kin = kin;
handles.frame = frame;

guidata(hObject,handles)




% --- Executes on button press in RemoveSelected_pushbutton.
function RemoveSelected_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to RemoveSelected_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
contents = cellstr(get(handles.Kinetochore_listbox,'String'));
kin_selected = str2double(contents(get(handles.Kinetochore_listbox,'Value')));
frame = handles.frame;
kin = handles.kin;

N_rm = length(kin_selected);

for k = 1:N_rm
    frame_num = find([kin(kin_selected(k),:).kinstate]==1);
    for j = 1:length(frame_num)
        idx = find(frame{frame_num(j)}.kin_id == kin_selected(k));
        
        %remove rejected kinetochores in current frame
        frame{frame_num(j)}.kin_id(idx) = [];
        if sum(ishandle(frame{frame_num(j)}.text_handle(idx,:)))
            delete(frame{frame_num(j)}.text_handle(idx,ishandle(frame{frame_num(j)}.text_handle(idx,:))))
        end
        frame{frame_num(j)}.text_handle(idx,:) = [];
        if sum(ishandle(frame{frame_num(j)}.kincircle_handle(idx,:)))
            delete(frame{frame_num(j)}.kincircle_handle(idx,ishandle(frame{frame_num(j)}.kincircle_handle(idx,:))))
        end
        frame{frame_num(j)}.kincircle_handle(idx,:) = [];
    end
    
    %reset corresponding kinetochore structures
    kin(kin_selected(k),:) = initializeKinStruct(1,length(frame));
end

handles.frame = frame;
handles.kin = kin;

handles = updateKinetochoreListbox(handles);

guidata(hObject,handles)


% --- Executes on button press in SaveToBase_pushbutton.
function SaveToBase_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to SaveToBase_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

name = fieldnames(handles);

[s,ok]=listdlg('PromptString','Choose variables to save to base workspace:',...
    'Name','Variable Selection','SelectionMode','multiple','ListString',name);

if (ok == 0) || isempty(s)
    return
end

for i = s
    assignin('base',name{i},eval(['handles.' name{i}]))
end


% --- Executes on button press in SetROI_pushbutton.
function SetROI_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to SetROI_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

ROI = handles.ROI;
ROI_handle = handles.ROI_handle;
frame = handles.frame;
selected = get(handles.FrameSelection_slider,'Value');
ch1 = get(handles.Ch1_checkbox,'Value');
ch2 = get(handles.Ch2_checkbox,'Value');

if ishandle(ROI_handle)
    delete(ROI_handle)
end

% uiwait(handles.KinetochoreSelectionGui)
if ch1
    set(handles.KinetochoreSelectionGui,'CurrentAxes',handles.Image_axes);
    [ROI,xi,yi] = roipoly();
elseif ch2
    set(handles.KinetochoreSelectionGui,'CurrentAxes',handles.Image2_axes);
    [ROI,xi,yi] = roipoly();
end
% uiresume(handles.KinetochoreSelectionGui)
    
set(handles.KinetochoreSelectionGui,'CurrentAxes',handles.Image_axes);
ROI_handle1 = drawPolygon([xi,yi],'w','LineWidth',2);
set(handles.KinetochoreSelectionGui,'CurrentAxes',handles.Image2_axes);
ROI_handle2 = drawPolygon([xi,yi],'w','LineWidth',2);

ROI_handle = [ROI_handle1;ROI_handle2];

if get(handles.AutoscaleROI_checkbox,'value')
    img = frame{selected}.image;
    for ch = 1:2
        img_ROI = img(:,:,ch).*ROI;
        
        if ishandle(frame{selected}.image_handle(ch))
            if ch == 1
                set(handles.KinetochoreSelectionGui,'CurrentAxes',handles.Image_axes);
            elseif ch ==2
                set(handles.KinetochoreSelectionGui,'CurrentAxes',handles.Image2_axes);
            end
            caxis([0 max(img_ROI(:))]);
        end
    end
else
    for ch = 1:2
        if ishandle(frame{selected}.image_handle(ch))
            if ch == 1
                set(handles.KinetochoreSelectionGui,'CurrentAxes',handles.Image_axes);
            elseif ch ==2
                set(handles.KinetochoreSelectionGui,'CurrentAxes',handles.Image2_axes);
            end
            caxis auto;
        end
    end
end

handles.ROI = ROI;
handles.ROI_handle = ROI_handle;

guidata(hObject,handles);



% --- Executes on button press in AutoscaleROI_checkbox.
function AutoscaleROI_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to AutoscaleROI_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of AutoscaleROI_checkbox

ROI = handles.ROI;
frame = handles.frame;
selected = get(handles.FrameSelection_slider,'Value');

img = frame{selected}.image;
if get(hObject,'value')
    for ch = 1:2
        img_ROI = img(:,:,ch).*ROI;
        
        if ishandle(frame{selected}.image_handle(ch))
            if ch == 1
                set(handles.KinetochoreSelectionGui,'CurrentAxes',handles.Image_axes);
            elseif ch ==2
                set(handles.KinetochoreSelectionGui,'CurrentAxes',handles.Image2_axes);
            end
            caxis([0 max(img_ROI(:))]);
        end
    end
else
    for ch = 1:2
        if ishandle(frame{selected}.image_handle(ch))
            if ch == 1
                set(handles.KinetochoreSelectionGui,'CurrentAxes',handles.Image_axes);
            elseif ch ==2
                set(handles.KinetochoreSelectionGui,'CurrentAxes',handles.Image2_axes);
            end
            caxis auto;
        end
    end
end



% --- Executes on button press in ReturnSelection_pushbutton.
function ReturnSelection_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to ReturnSelection_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
FOI = handles.FOI;
frame = handles.frame;
Nframe = length(frame);
kin = handles.kin;

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

for fr = 1:Nframe
    
    selected_pixel = zeros(img_size(1),img_size(2));
    kinid = frame{fr}.kin_id;
    
    for k = 1:length(kinid)
        selected_pixel = selected_pixel | kin(kinid(k),fr).selected_pixel;
    end
    
    MainGuihandles.image_struct{selected(fr)}.selected_pixel = selected_pixel;
end


for i = selected
    
    image_struct = MainGuihandles.image_struct{i};
    img = image_struct.image;
    active_region = image_struct.active_region;
    
    %time axis
    time = (1:length(image_struct.decay))*image_struct.dt;
    
    selected_pixel = image_struct.selected_pixel;
    selected_pixel_handle = image_struct.selected_pixel_handle;
    [yy,xx] = find(selected_pixel==1);
    
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
        decay_data(j) = sum(sum(squeeze(flim(j,:,:)).*selected_pixel.*active_region));
    end
    
    axes(MainGuihandles.Decay_axes)
    if ishandle(decay_handle);
        delete(decay_handle)
    end
    
    decay_handle = semilogy(time,decay_data,'or');
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

figname = 'FittingGUI_ver8_2';
hfig = CheckOpenState(figname);
if hfig ~= -99
    choice = questdlg([figname ' is currently open. Pressing "New" will delete the data previously in ',figname,' and open new one.'],'!Already opened!','New','Append','Cancel','Cancel');
    if strcmp(choice,'New')==1
        close(hfig);
    elseif strcmp(choice,'Append')==1
    else
        return;
    end
else
    choice = 'New';
end



contents = cellstr(get(handles.Kinetochore_listbox,'String'));
kin_selected = str2double(contents(get(handles.Kinetochore_listbox,'Value')));

frame = handles.frame;
kin = handles.kin;

Nkinselected = length(kin_selected);
Nframe = length(frame);

decay_struct = [];

for k = 1:Nkinselected
    for fr = 1:Nframe
        if kin(kin_selected(k),fr).kinstate == 0
            continue;
        end
        kinidstr = num2str(kin_selected(k),'%03d');
        frstr = num2str(fr,'%03d');
        name = ['kin',kinidstr,'_fr',frstr];
        filename = frame{fr}.filename;
        
        selected_pixel = kin(kin_selected(k),fr).selected_pixel(:,:);
        
        flim = frame{fr}.flim;
        dt = frame{fr}.dt;
        %time axis
        time = (1:length(flim(:,1,1)))'*dt;
        
        decay = zeros(length(time),1);
        for i = 1:length(time)
            decay(i) = sum(sum(squeeze(flim(i,:,:)).*selected_pixel));
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

eval([figname,'(''inputdecaystruct'',decay_struct,''mode'',choice)'])


%%
%%%%%%%%%%%%%%%%%%%%%% Kinetochore Pair Finding

% --- Executes on button press in SpindleAxis_pushbutton.
function SpindleAxis_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to SpindleAxis_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


kin = handles.kin;
frame = handles.frame;
spaxis_handle = handles.spaxis_handle;
ch1 = get(handles.Ch1_checkbox,'Value');
ch2 = get(handles.Ch2_checkbox,'Value');

Nkin = length(kin);

if Nkin == 0
    errordlg('Find Kinetochores first')
    return;
end

spaxis.x = 0;
spaxis.y = 0;

if ch1
    set(handles.KinetochoreSelectionGui,'CurrentAxes',handles.Image_axes)
else
    set(handles.KinetochoreSelectionGui,'CurrentAxes',handles.Image2_axes)
end

h = imline;
vert = wait(h);
delete(h);

spaxis.x = vert(2,1)-vert(1,1);
spaxis.y = vert(2,2)-vert(1,2);

        
%normalize
normconst = sqrt(spaxis.x^2+spaxis.y^2);
spaxis.x = spaxis.x/normconst;
spaxis.y = spaxis.y/normconst;

XL = xlim;
YL = ylim;
R = sqrt(XL(2)^2+YL(2)^2);

delete(spaxis_handle(ishandle(spaxis_handle)))

spaxis_handle = [-99,-99];
set(handles.KinetochoreSelectionGui,'CurrentAxes',handles.Image_axes)
spaxis_handle(1) = line([mean(XL)-R*spaxis.x;mean(XL)+R*spaxis.x],[mean(YL)-R*spaxis.y;mean(YL)+R*spaxis.y]);
set(handles.KinetochoreSelectionGui,'CurrentAxes',handles.Image2_axes)
spaxis_handle(2) = line([mean(XL)-R*spaxis.x;mean(XL)+R*spaxis.x],[mean(YL)-R*spaxis.y;mean(YL)+R*spaxis.y]);

set(spaxis_handle,'Color','b','LineWidth',2,'Visible','off')
if get(handles.ShowSpindleAxis_checkbox,'Value')
    set(spaxis_handle,'Visible','on')
end

handles.spaxis = spaxis;
handles.kin = kin;
handles.spaxis_handle = spaxis_handle;

guidata(hObject,handles);


% --- Executes on button press in ShowSpindleAxis_checkbox.
function ShowSpindleAxis_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to ShowSpindleAxis_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ShowSpindleAxis_checkbox
spaxis_handle = handles.spaxis_handle;

if ishandle(spaxis_handle)
    set(handles.KinetochoreSelectionGui,'CurrentAxes',handles.Image_axes);
    if get(hObject,'Value')
        set(spaxis_handle,'Visible','on');
    else
        set(spaxis_handle,'Visible','off');
    end
end

guidata(hObject,handles)




% --- Executes on button press in FindKPairs_pushbutton.
function FindKPairs_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to FindKPairs_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Consider axial and lateral distance between two kinetochores, and
%correlation of velocities

kin = handles.kin;
frame = handles.frame;
spaxis = handles.spaxis;
kinpair = handles.kinpair;

if isempty(spaxis)
    errordlg('Find spindle axis first');
    return
end

%Erase previously drawn kinpair
if isempty(kinpair) == 0
    kinpair_handle = [kinpair.kinpair_handle];
    kinpairtext_handle = [kinpair.kinpairtext_handle];
    delete(kinpair_handle(ishandle(kinpair_handle)));
    delete(kinpairtext_handle(ishandle(kinpairtext_handle)));
end

maxaxdist = str2double(get(handles.MaxAxialDistance_edit,'String'));
minaxdist = str2double(get(handles.MinAxialDistance_edit,'String'));
maxlatdist = str2double(get(handles.MaxLateralDistance_edit,'String'));
numframecutoff = str2double(get(handles.NumFrameCutoff_edit,'String'));
vardistcutoff = str2double(get(handles.VarDistCutoff_edit,'String'));

%x, y coordinates averaged over the channels. If only one channel is
%available, take the only available value as the averaged value.
avgx = arrayfun(@(A) sum((A.locsource==-1).*A.x.*(A.x>0)+(A.locsource>=0).*A.mux.*(A.mux>0))./sum((A.locsource==-1).*(A.x>0)+(A.locsource>=0).*(A.mux>0)),kin);
avgy = arrayfun(@(A) sum((A.locsource==-1).*A.y.*(A.y>0)+(A.locsource>=0).*A.muy.*(A.muy>0))./sum((A.locsource==-1).*(A.y>0)+(A.locsource>=0).*(A.muy>0)),kin);
avgx(isnan(avgx))=0;
avgy(isnan(avgy))=0;
% 
% %intrakinetochore stretch (ch1-ch2), -99 if not available
% xch1 = arrayfun(@(A) (A.locsource(1)==-1).*A.x(1).*(A.x(1)>0)+(A.locsource(1)>=0).*A.mux(1).*(A.mux(1)>0),kin);
% xch2 = arrayfun(@(A) (A.locsource(2)==-1).*A.x(2).*(A.x(2)>0)+(A.locsource(2)>=0).*A.mux(2).*(A.mux(2)>0),kin);
% ych1 = arrayfun(@(A) (A.locsource(1)==-1).*A.y(1).*(A.y(1)>0)+(A.locsource(1)>=0).*A.muy(1).*(A.muy(1)>0),kin);
% ych2 = arrayfun(@(A) (A.locsource(2)==-1).*A.y(2).*(A.y(2)>0)+(A.locsource(2)>=0).*A.muy(2).*(A.muy(2)>0),kin);
% stretchx = (xch1-xch2).*(xch1>0 & xch2>0)-99*(xch1==0 | xch2==0);
% stretchy = (ych1-ych2).*(ych1>0 & ych2>0)-99*(ych1==0 | ych2==0);

Nkin = size(kin,1);
Nframe = size(kin,2);

%kinpair matrix: NkinpairXFrame Structure array  
Nkinpair = 0;
paired = zeros(Nkin,1);      %indicates whether or not selected kinetochore is paired.

%First cluster kinetochores based on their axial/lateral distances, number
%of frames where they are clustered together
clustered = zeros(Nkin,Nkin,Nframe);
%distance between two kinetochores
dist = zeros(Nkin,Nkin,Nframe);
bothexist = zeros(Nkin,Nkin,Nframe);
for fr = 1:Nframe
    %displacement
    dispx = bsxfun(@minus,avgx(:,fr),avgx(:,fr)');
    dispy = bsxfun(@minus,avgy(:,fr),avgy(:,fr)');
    bothexist(:,:,fr) = bsxfun(@and,avgx(:,fr)>0,avgx(:,fr)'>0);
    dist(:,:,fr) = sqrt(dispx.^2+dispy.^2);
    dist(:,:,fr) = dist(:,:,fr).*bothexist(:,:,fr);
    %axial distance
    axdist = abs(dispx*spaxis.x+dispy*spaxis.y);
    %lateral distacne
    latdist = sqrt(dispx.^2+dispy.^2-axdist.^2);
    
    clustered(:,:,fr) = (axdist<maxaxdist & axdist>minaxdist & latdist<maxlatdist);
    clustered(:,:,fr) = tril(clustered(:,:,fr));
end
clustered_allfr = (sum(clustered,3)>=numframecutoff);
[id1,id2] = find(clustered_allfr);
clustered_id = [id1,id2];

%Then measure the correlations in distance between two kinetochores and 
%exclude kinetochore clusters with the correlation below the threshold
Nclustered = size(clustered_id,1);
paired_id = [];
varkindists = [];
for i = 1:Nclustered
    kinids = clustered_id(i,:);
    kindists = dist(kinids(1),kinids(2),:);
    varkindist = var(kindists(kindists>0),1);
    if varkindist < vardistcutoff
        paired_id = [paired_id;sort(kinids)];
        varkindists = [varkindists;varkindist];
    end
end

Nkinpair = size(paired_id,1);

disp([num2str(Nkinpair) ' Kinetochores pairs are detected based on the distance and var(distance) thresholding']);
    

%make kinpair structure matrix (NkinpairXNframe)
kinpair = initializeKinPair(Nkinpair,Nframe);
for i = 1:Nkinpair
    id1 = paired_id(i,1);
    id2 = paired_id(i,2);
    existfr = squeeze(bothexist(id1,id2,:)==1);
    [kinpair(i,existfr).kinpairstate] = deal(1);
    [kinpair(i,existfr).kinids] = deal(sort([id1;id2]));
end


%for kinetochores with multiple partners, check whether the multiple
%partners appear in the same frame. If so, delete the one with larger
%distance variance. And then update kinpair matrix, kinpair
%info matrix
%Find kinetochores that are paired with more than one kinetochores
sorted = sort(paired_id(:));
dupkin = unique(sorted(diff(sorted)==0));
Ndupkin = length(dupkin);
for i = 1:Ndupkin
    idx = ismember(paired_id,dupkin(i));
    [rows,~] = find(idx);
     temp = paired_id(rows,:);
     kintocheck = temp(~idx(rows,:));
     Nkintocheck = length(kintocheck);
     
     %Does ids in kintocheck appear in the same frame?
     kinstate = reshape([kin.kinstate],[Nkin,Nframe]);
     
     [ind1,ind2] = find(~triu(ones(Nkintocheck)));
     checkpair = [kintocheck(ind1),kintocheck(ind2)];
     Ncheckpair = size(checkpair,1);
     for j = 1:Ncheckpair
         overlapfr = sum(kinstate(checkpair(j,:),:))>1;
         if sum(overlapfr) > 0
             fprintf(['Kinetochore ' num2str(dupkin(i)) ...
             ' is paired with more than one kinetochores, '...
             num2str(checkpair(j,:),'%d, ') ' that appear in the same frame.\n'...
             'The pair in the frames ' num2str(find(overlapfr),'%d, ') ' have been rejected.\n']);
         idfr1 = reshape(prod(ismember([kinpair.kinids],[dupkin(i),checkpair(j,1)]),1),[Nkinpair,Nframe]);
         idfr2 = reshape(prod(ismember([kinpair.kinids],[dupkin(i),checkpair(j,2)]),1),[Nkinpair,Nframe]);
         idfr = idfr1 | idfr2;
         idfr(:,~overlapfr) = 0;
         if sum(idfr(:))>0
             kinpair(idfr) = initializeKinPair(1,1);
         end
         end
     end
end

kinpairstate = reshape([kinpair.kinpairstate],[Nkinpair,Nframe]);
kinpair(sum(kinpairstate,2)==0,:)=[];
Nkinpair = size(kinpair,1);


%update listbox
str = cell(Nkinpair,1);
for i = 1:Nkinpair
    kinids = [kinpair(i,:).kinids];
    kinids = unique(kinids','rows')';
    kinids(:,sum(kinids)==0)=[];
    str{i} = [num2str(i), ':',num2str(kinids(1)), ' & ' num2str(kinids(2))];
end

kinpair = DrawKinPair(handles,kinpair);
handles.kinpair = kinpair;

set(handles.KPair_listbox,'String',str);

guidata(hObject,handles);


function kinpairstruct = initializeKinPair(a,b)
kinpairstruct = struct('kinpairstate',mat2cell(zeros(a,b),ones(a,1),ones(b,1)),'kinids',[0;0],'kinpair_handle',[-99;-99],'kinpairtext_handle',[-99,-99]);


function outkinpair = DrawKinPair(handles,kinpair)
ch1 = handles.Ch1_checkbox;
ch2 = handles.Ch2_checkbox;
kin = handles.kin;
Nframe = size(kin,2);
Nkinpair = size(kinpair,1);
selected = get(handles.FrameSelection_slider,'Value');
showpair = get(handles.ShowKinPair_checkbox,'Value');

for fr = 1:Nframe
    for pairid = 1:Nkinpair
        for ch = 1:2
            if ch==1 & ch1==0
                continue
            elseif ch==2 & ch2==0
                continue
            end
            kinids = kinpair(pairid,fr).kinids;
            if kinids(1) == 0
                continue
            end
            kin1 = kin(kinids(1),fr);
            kin2 = kin(kinids(2),fr);
            xc1 = kin1.x(ch)*(kin1.locsource(ch)==-1)+kin1.mux(ch)*(kin1.locsource(ch)>=0);
            yc1 = kin1.y(ch)*(kin1.locsource(ch)==-1)+kin1.muy(ch)*(kin1.locsource(ch)>=0);
            xc2 = kin2.x(ch)*(kin2.locsource(ch)==-1)+kin2.mux(ch)*(kin2.locsource(ch)>=0);
            yc2 = kin2.y(ch)*(kin2.locsource(ch)==-1)+kin2.muy(ch)*(kin2.locsource(ch)>=0);
            
            if ishandle(kinpair(pairid,fr).kinpair_handle(ch))
                delete(kinpair(pairid,fr).kinpair_handle(ch));
            end
            if ishandle(kinpair(pairid,fr).kinpairtext_handle(ch))
                delete(kinpair(pairid,fr).kinpairtext_handle(ch));
            end
            
            if ch == 1
                set(handles.KinetochoreSelectionGui,'CurrentAxes',handles.Image_axes);
            elseif ch == 2
                set(handles.KinetochoreSelectionGui,'CurrentAxes',handles.Image2_axes);
            end
            kinpair(pairid,fr).kinpair_handle(ch) = line([xc1;xc2],[yc1;yc2],'Color','b','LineWidth',1.5);
            
            set(kinpair(pairid,fr).kinpair_handle(ch),'Visible','off')
        end
    end
end

if showpair
    kinpair_handle = [kinpair(:,selected).kinpair_handle];
    set(kinpair_handle(ishandle(kinpair_handle)),'Visible','on')
end
outkinpair = kinpair;


% --- Executes on button press in RejectKPair_pushbutton.
function RejectKPair_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to RejectKPair_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
contents = cellstr(get(handles.KPair_listbox,'String'));
selected = get(handles.KPair_listbox,'Value');
kinpair = handles.kinpair;
Nframe = size(kinpair,2);

if isempty(kinpair) 
    return;
end

pairids = zeros(length(selected),1);
%pair id selected
for i = 1:length(selected)
    len = strfind(contents{selected(i)},':')-1;
    pairids(i) = str2double(contents{selected(i)}(1:len));
end

kinpair_handle = [kinpair(pairids,:).kinpair_handle];
kinpairtext_handle = [kinpair(pairids,:).kinpairtext_handle];
delete(kinpair_handle(ishandle(kinpair_handle)));
delete(kinpairtext_handle(ishandle(kinpairtext_handle)));

kinpair(pairids,:) = initializeKinPair(length(selected),Nframe);

newcontents = contents;
newcontents(selected) = [];
set(handles.KPair_listbox,'Value',1);
set(handles.KPair_listbox,'String',newcontents);

kinpair = DrawKinPair(handles,kinpair);

handles.kinpair = kinpair;

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

ans1 = str2double(answer{1});
ans2 = str2double(answer{2});
kinid1 = min(ans1,ans2);
kinid2 = max(ans1,ans2);

kinpair = handles.kinpair;
kin = handles.kin;
spaxis = handles.spaxis;
Nkinpair = size(kinpair,1);
Nframe = size(kinpair,2);

%x, y coordinates averaged over the channels. If only one channel is
%available, take the only available value as the averaged value.
avgx = arrayfun(@(A) sum((A.locsource==-1).*A.x.*(A.x>0)+(A.locsource>=0).*A.mux.*(A.mux>0))./sum((A.locsource==-1).*(A.x>0)+(A.locsource>=0).*(A.mux>0)),kin);
avgy = arrayfun(@(A) sum((A.locsource==-1).*A.y.*(A.y>0)+(A.locsource>=0).*A.muy.*(A.muy>0))./sum((A.locsource==-1).*(A.y>0)+(A.locsource>=0).*(A.muy>0)),kin);
avgx(isnan(avgx))=0;
avgy(isnan(avgy))=0;

bothexist = [kin(kinid1,:).kinstate].*[kin(kinid2,:).kinstate];

kinpair(end+1,:) = initializeKinPair(1,Nframe);

[kinpair(Nkinpair+1,find(bothexist)).kinpairstate] = deal(1);
[kinpair(Nkinpair+1,find(bothexist)).kinids] = deal([kinid1;kinid2]);

kinpair = DrawKinPair(handles,kinpair);

handles.kinpair = kinpair;
handles.kin = kin;

contents = get(handles.KPair_listbox,'String');
newcontents = [contents;cellstr([num2str(Nkinpair+1),':',num2str(kinid1),' & ',num2str(kinid2)])];

set(handles.KPair_listbox,'String',newcontents);

guidata(hObject,handles);


% --- Executes on button press in ShowPairInfo_pushbutton.
function ShowPairInfo_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to ShowPairInfo_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
kinpair = handles.kinpair;

contents = cellstr(get(handles.KPair_listbox,'String'));
selected = get(handles.KPair_listbox,'Value');

pairids = zeros(length(selected),1);
%pair id selected
for i = 1:length(selected)
    len = strfind(contents{selected(i)},':')-1;
    pairids(i) = str2double(contents{selected(i)}(1:len));
end

% disp('   KinPairID      Frame ID         kin1        kin2     interkinetochore vector')
% disp(kinpair(ismember(kinpair(:,1),pairids,'rows'),:))
% 
% disp('   KinPairID   # of Frames     var(dist)    innerprod   axial dist  lateral dist')
% disp(kinpairinfo(ismember(kinpairinfo(:,1),pairids,'rows'),:))







%%%%%%%%%%%%%%%%%%%%
%% Bayes Fit
% --- Executes on button press in BayesFit_pushbutton.
function BayesFit_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to BayesFit_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

addpath CONVNFFT_Folder
addpath FLIMFitting

if get(handles.LastUsedIRF_checkbox,'Value')
    current_irf = load('currentIRF.mat');
    irf = current_irf.decay;
    irf = irf/max(irf)*5*1E3;
    time_irf = current_irf.time;
else
    [name pathname filterindex] = uigetfile('IRF/*.mat','Choose IRF');
    
    if name == 0
        return;
    end
    
    loaded_irf = load([pathname name]);
    time = loaded_irf.time;
    decay = loaded_irf.decay;
    save('currentIRF','decay','time');
    irf = decay;
    time_irf = time;
    clear decay;
    clear time;
end



frame = handles.frame;
kin = handles.kin;
kinstate = handles.kinstate;
location = handles.location;
flimblock = handles.flimblock;

%kin IDs/frame ids of accepted kinetochores in FLIM channel
kinflim = kinstate(location(:,4,flimblock)>0 & kinstate(:,3)==1,1:2);


%Bayes Fit Setting
nexpo = 2;
prior = 1;   %Uniform
fitvar = 1;

lendecay = size(frame{1}.flim,1);

dt = frame{1}.dt;
%flim time axis
time = (1:lendecay)'*dt;

decayexample = sum(sum(frame{1}.flim,3),2);
tempind = find(decayexample>0);
fit_start = tempind(1);
fit_end = tempind(end);

kinids = unique(kinflim(:,1));
disp(['Found ' num2str(length(kinflim(:,1))) ' decays to be analyzed.']);
for i = 1:length(kinids)
    kin{kinids(i)}.decay = zeros(length(decayexample),length(kin{kinids(i)}.frame));

    %Bayes result
    %Background level (A) estimate (1st column:post mean,2nd:MAP,3rd:post std dev)
    kin{kinids(i)}.bayes.Aest = zeros(3,length(kin{kinids(i)}.frame));
    %nonFRETing fraction (F) estimate (1st column:post mean,2nd:MAP,3rd:post std dev)
    kin{kinids(i)}.bayes.Fest = zeros(3,length(kin{kinids(i)}.frame));
    
    kin{kinids(i)}.bayes.post = cell(length(kin{kinids(i)}.frame),1);
    kin{kinids(i)}.bayes.margpost = cell(length(kin{kinids(i)}.frame),1);
end

allgroupeddecay = zeros(length(decayexample),1);
for i = 1:length(kinflim)
    kinid = kinflim(i,1);
    frameid = kinflim(i,2);
    flim = frame{frameid}.flim;
    selected_pixel = kin{kinid}.selected_pixel(:,:,kin{kinid}.frame==frameid);
    for j = 1:length(decayexample)
        kin{kinid}.decay(:,kin{kinid}.frame==frameid) = sum(sum(squeeze(flim(j,:,:)).*selected_pixel));
    end
    allgroupeddecay = allgroupeddecay+kin{kinid}.decay(:,kin{kinid}.frame==frameid);
end

counts = sum(allgroupeddecay);
decay = allgroupeddecay;
nonzero_decay = decay;
nonzero_decay(decay==0)=1;
sigy = sqrt(nonzero_decay);
weight = 1./sigy(fit_start:fit_end);

p_init = [2,0.99,3.5,0.5,0.2]';
p_min = [-20,0.7,2.5,0.01,0]';
p_max = [20,1,4.3,1,0.7]';
dp = 0.001*ones(2*nexpo+1,1);
dp(1) = 1;

[pfit,Chisq,sigmap,sigmay,corr,R2,cvghst, converged] = ...
    lm(@lm_decay_model,p_init,time,decay,time_irf,irf,weight,dp,p_min,p_max,[nexpo,counts,fit_start,fit_end,fitvar],fit_start,fit_end);

% if counts > 10^4
% else
%     p_min = [-20,0.97,2.5,0.01,0]';
%     p_max = [20,1,4,1,0.4]';
%     dp = [1,0.0025,0.01,0.01,0.01]';
%     [pfit,sigmap,pvec,post,margpost,map] =...
%             bayes_fit(time,decay,dp,p_min,p_max,nexpo,prior,fit_start,fit_end,0,1);
% end

y_hat = lm_decay_model(time,pfit,[nexpo,counts,fit_start,fit_end,fitvar],time_irf,irf);
y_hat = y_hat(fit_start:fit_end);
y_dat = decay;
y_dat = y_dat(fit_start:fit_end);

weighted_residual = weight.*(y_dat-y_hat);

h = figure;
subplot(4,1,[1:3]), semilogy(time,decay,'ro');
hold on
semilogy(time(fit_start:fit_end),y_hat,'-k');
xlim([time(1);time(end)]);
subplot(4,1,4), 
plot(time(fit_start:fit_end),weighted_residual);
hold on
line([time(1);time(end)],[0;0]);
xlim([time(1);time(end)]);

choice = questdlg('Do you want to use these values of shift, tau1, tau1/tau2 for the rest of analysis?','Choose one','Yes','Enter my values','Cancel','Yes');
switch choice
    case 'Yes'
        shift = pfit(1);
        tau1 = pfit(3);
        E = pfit(5);
    case 'Enter my values'
        ans = inputdlg({'Enter shift value','Enter tau1','Enter E'});
        shift = str2double(ans{1});
        tau1 = str2double(ans{2});
        E = str2double(ans{3});
    case 'Cancel'
        return;
end

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
for i = 1:length(kinflim)
    %frames where the selected kinetochore appears
    frameid = kinflim(i,2);
    kinid = kinflim(i,1);
    idx = find(kin{kinid}.frame==frameid);
    
    decay = kin{kinid}.decay(:,idx);
    [pavg,sigmap,pvec,post,margpost,map] =...
        bayes_fit(time,decay,time_irf,irf,dp,p_min,p_max,nexpo,fitvar,prior,fit_start,fit_end,0,1);
    
    kin{kinid}.bayes.Aest(:,idx) = [pavg(2),map(2),sigmap(2)];
    kin{kinid}.bayes.Fest(:,idx) = [pavg(4),map(4),sigmap(4)];
    kin{kinid}.bayes.post{idx} = post;
    kin{kinid}.bayes.margpost{idx} = margpost;
    disp([num2str(i) ' out of ' num2str(length(kinflim)) ' have been fitted.']);
end

matlabpool close

bayessetting.pvec = pvec;

handles.bayessetting = bayessetting;
handles.kin = kin;

guidata(hObject,handles);



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


% --- Executes on button press in SaveResult_pushbutton.
function SaveResult_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to SaveResult_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[name pathname filterindex] = uiputfile2b('*.mat');

if isequal(name,0)
    return;
end

kin = handles.kin;
kinpair = handles.kinpair;
bayessetting = handles.bayessetting;
frame = handles.frame;
pixsize = handles.pixsize;
repeat = handles.repeat;
spaxis = handles.spaxis;
kinstate = handles.kinstate;
res = handles.res;
location = handles.location;
resGauss = handles.resGauss;
kinpairinfo = handles.kinpairinfo;
ROI = handles.ROI;

if name ~= 0
    save([pathname,name],'ROI','kin','kinpair','bayessetting','frame',...
        'pixsize','repeat','spaxis','kinstate','res','resGauss','location',...
        'kinpairinfo');
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

frame = handles.frame;
kin = handles.kin;

[frame,kin] = DrawKinCircle_updated(handles,frame,kin);

handles.frame = frame;
handles.kin = kin;

guidata(hObject,handles);



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
showkin = get(hObject,'Value');
frame = handles.frame;
selected = get(handles.FrameSelection_slider,'Value');

if showkin
    set(frame{selected}.kincircle_handle(ishandle(frame{selected}.kincircle_handle)),'Visible','on');
    set(frame{selected}.text_handle(ishandle(frame{selected}.kincircle_handle)),'Visible','on');
elseif showkin == 0
    set(frame{selected}.kincircle_handle(ishandle(frame{selected}.kincircle_handle)),'Visible','off');
    set(frame{selected}.text_handle(ishandle(frame{selected}.kincircle_handle)),'Visible','off');
end
    
    

% --- Executes on button press in RejectTrajOverlap_checkbox.
function RejectTrajOverlap_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to RejectTrajOverlap_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of RejectTrajOverlap_checkbox



function OverlapDistThres_edit_Callback(hObject, eventdata, handles)
% hObject    handle to OverlapDistThres_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of OverlapDistThres_edit as text
%        str2double(get(hObject,'String')) returns contents of OverlapDistThres_edit as a double


% --- Executes during object creation, after setting all properties.
function OverlapDistThres_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to OverlapDistThres_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in RejectNoGaussFit_checkbox.
function RejectNoGaussFit_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to RejectNoGaussFit_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of RejectNoGaussFit_checkbox


% --- Executes on button press in RejectNoFLIM_checkbox.
function RejectNoFLIM_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to RejectNoFLIM_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of RejectNoFLIM_checkbox


% --- Executes on button press in PlotGaussFitResult_checkbox.
function PlotGaussFitResult_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to PlotGaussFitResult_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of PlotGaussFitResult_checkbox



function VarDistCutoff_edit_Callback(hObject, eventdata, handles)
% hObject    handle to VarDistCutoff_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of VarDistCutoff_edit as text
%        str2double(get(hObject,'String')) returns contents of VarDistCutoff_edit as a double


% --- Executes during object creation, after setting all properties.
function VarDistCutoff_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to VarDistCutoff_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in LastUsedIRF_checkbox.
function LastUsedIRF_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to LastUsedIRF_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of LastUsedIRF_checkbox


% --- Executes on button press in MakeMovie_pushbutton.
function MakeMovie_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to MakeMovie_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
frame = handles.frame;
ROI = handles.ROI;
repeat = handles.repeat;
pixsize= handles.pixsize;

%batch filename
batchfname = frame{1}.filename;
batchfname = batchfname(1:(findstr(batchfname,'_c')-1));

%Example number of frame
eg_Nframe = length(frame);

prompt = {'Frame numbers (e.g. 1:2:9):', ...
    'Frame rate (frames/sec)','Pixel Size','Extension'};
dlg_title = 'Movie Maker';
num_lines = 1;
def = {['1:',num2str(eg_Nframe)],'8',num2str(pixsize),'avi'};
answer = inputdlg(prompt,dlg_title,num_lines,def);

if isempty(answer)
    return;
end

framenum = str2num(answer{1});
framerate = str2num(answer{2});
pixsize = str2double(answer{3});
ext = answer{4};

%choose save directory
[filename,pathname] = uiputfile2b([batchfname,'.',ext],'Save movie file as');
if filename == 0 
    return;
end

writerObj = VideoWriter([pathname,filename],'Uncompressed AVI');
writerObj.FrameRate = framerate;
open(writerObj)
for i = 1:length(framenum)
    img = double(frame{framenum(i)}.image);
    
    h = figure;
    normimg = img;
    for ch = 1:2
        img_ROI = img(:,:,ch).*ROI;
        maxvalue = max(img_ROI(:));
        normimg(:,:,ch) = min(1,normimg(:,:,ch)/maxvalue);
    end
        
    imagesc(normimg);
    truesize(h);
    axis off;
    axis image;
%    colormap(gray);
    hold on;
       
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


% --- Executes during object creation, after setting all properties.
function Image2_axes_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Image2_axes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate Image2_axes


% --- Executes during object creation, after setting all properties.
function Image_axes_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Image2_axes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate Image2_axes

% --- Executes on mouse press over axes background.
function Image_axes_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to Image2_axes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on mouse press over axes background.
function Image2_axes_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to Image2_axes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function BackgroundLevel_edit_Callback(hObject, eventdata, handles)
% hObject    handle to BackgroundLevel_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of BackgroundLevel_edit as text
%        str2double(get(hObject,'String')) returns contents of BackgroundLevel_edit as a double


% --- Executes during object creation, after setting all properties.
function BackgroundLevel_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to BackgroundLevel_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in RemoveROI_pushbutton.
function RemoveROI_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to RemoveROI_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ROI_handle = handles.ROI_handle;

if ishandle(ROI_handle)
    delete(ROI_handle);
end
handles.ROI_handle = [];
handles.ROI = ones(img_size(1),img_size(2));

guidata(hObject,handles);

% --- Executes on button press in MeasureDistance_pushbutton.
function MeasureDistance_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to MeasureDistance_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ch1 = get(handles.Ch1_checkbox,'Value');
ch2 = get(handles.Ch2_checkbox,'Value');

if ch1
    set(handles.KinetochoreSelectionGui,'CurrentAxes',handles.Image_axes);
elseif ch2
    set(handles.KinetochoreSelectionGui,'CurrentAxes',handles.Image2_axes);
end
hline = imline;
pos = wait(hline);
delete(hline);

dist = round(pdist(pos),2);
set(handles.Distance_text,'String',[num2str(dist) ' pixels']);


% --- Executes on button press in ShowKinPair_checkbox.
function ShowKinPair_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to ShowKinPair_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ShowKinPair_checkbox
showpair =  get(hObject,'Value');
kinpair = handles.kinpair;
selected = get(handles.FrameSelection_slider,'Value');

if isempty(kinpair)
    return;
else
    kinpair_handle = [kinpair(:,selected).kinpair_handle];
end

if showpair
    set(kinpair_handle(ishandle(kinpair_handle)),'Visible','on')
else
    set(kinpair_handle(ishandle(kinpair_handle)),'Visible','off')
end
