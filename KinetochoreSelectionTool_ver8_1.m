function varargout = KinetochoreSelectionTool_ver8_1(varargin)
% KINETOCHORESELECTIONTOOL_VER8_1 MATLAB code for KinetochoreSelectionTool_ver8_1.fig
%      KINETOCHORESELECTIONTOOL_VER8_1, by itself, creates a new KINETOCHORESELECTIONTOOL_VER8_1 or raises the existing
%      singleton*.
%
%      H = KINETOCHORESELECTIONTOOL_VER8_1 returns the handle to a new KINETOCHORESELECTIONTOOL_VER8_1 or the handle to
%      the existing singleton*.
%
%      KINETOCHORESELECTIONTOOL_VER8_1('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in KINETOCHORESELECTIONTOOL_VER8_1.M with the given input arguments.
%
%      KINETOCHORESELECTIONTOOL_VER8_1('Property','Value',...) creates a new KINETOCHORESELECTIONTOOL_VER8_1 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before KinetochoreSelectionTool_ver8_1_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to KinetochoreSelectionTool_ver8_1_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help KinetochoreSelectionTool_ver8_1
% Last Modified by GUIDE v2.5 13-Mar-2016 18:05:18

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @KinetochoreSelectionTool_ver8_1_OpeningFcn, ...
    'gui_OutputFcn',  @KinetochoreSelectionTool_ver8_1_OutputFcn, ...
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
function varargout = KinetochoreSelectionTool_ver8_1_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



% --- Executes just before KinetochoreSelectionTool_ver8_1 is made visible.
function KinetochoreSelectionTool_ver8_1_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to KinetochoreSelectionTool_ver8_1 (see VARARGIN)

% Choose default command line output for KinetochoreSelectionTool_ver8_1
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes KinetochoreSelectionTool_ver8_1 wait for user response (see UIRESUME)
% uiwait(handles.KinetochoreSelectionGui);

addpath tracking_Kilfoil
addpath bh

if isempty(varargin)
    disp('Not opened from MainGui');
else
    set(0,'currentfigure',handles.KinetochoreSelectionGui)
    
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
        frame{i}.pathname = FOI{i}.pathname;
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
        
        %circle showing detected kinetochores
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
        %default
        handles.flimblock = 2;
    end
    
    %all kinetochore structures
    handles.kin = [];
    handles.kinpair = [];

    %for cell movement correction
    handles.tforms = [];
    
    set(handles.FrameNumber_text,'String',['1 out of ' num2str(Nframe)]);

end

% Use default setting for kinetochore selection setting
SaveLoadKinSelectionSetting(handles,'Load',1);

% Update handles structure
guidata(hObject, handles);



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

if isempty(handles.kin)
    return
else
    kin = handles.kin;
    kinpair = handles.kinpair;
end
if editmode == 2 & isempty(handles.kinpair)
    return
end

Nframe = size(kin,2);

%x, y coordinates averaged over the channels. If only one channel is
%available, take the only available value as the averaged value.
avgx = arrayfun(@(A) sum((A.locsource==-1).*A.x.*(A.x>0)+(A.locsource>=0).*A.mux.*(A.mux>0))./sum((A.locsource==-1).*(A.x>0)+(A.locsource>=0).*(A.mux>0)),kin);
avgy = arrayfun(@(A) sum((A.locsource==-1).*A.y.*(A.y>0)+(A.locsource>=0).*A.muy.*(A.muy>0))./sum((A.locsource==-1).*(A.y>0)+(A.locsource>=0).*(A.muy>0)),kin);
avgx(isnan(avgx))=0;
avgy(isnan(avgy))=0;

if eventData.Button == 3 & editmode == 1
    kinstate = [kin(:,framenum).kinstate];
    kinids = find(kinstate);
    distance = sqrt((avgx(kinids,framenum)-coord(1)).^2+...
        (avgy(kinids,framenum)-coord(2)).^2);
%     distance = distance(axesId,:);
    [~,ind] = min(distance);
    selected_kin = kinids(ind);
    prompt = ['What do you want to do with kin' num2str(selected_kin)];
    button = questdlg(prompt,'Choose one option','Change ID','Delete','Cancel','Cancel');
    drawnow; pause(0.05);
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
    drawnow; pause(0.05);
else
    return;
end


if editmode ==1
    switch button
        case 'Change ID'
            nopass = 1;
            
            while nopass
                answer = inputdlg('Enter new ID');
                drawnow; pause(0.05);
                if isempty(answer)
                    return
                end
                newid = round(str2num(answer{1}));
                
                allframe = 1:Nframe;
                
                if newid > size(kin,1) || newid < 1
                    button2 = questdlg('Entered ID doesn''t exist. Do you want to assign new ID?',...
                        'Choose one option','Yes, change this','Yes, change this and after','Cancel','Cancel');
                    drawnow; pause(0.05);
                    switch button2
                        case 'Yes, change this'
                            newid = size(kin,1)+1;
                            kin(end+1,:) = initializeKinStruct(1,Nframe);
                            nopass = 0;
                        case 'Yes, change this and after'
                            nopass = 0;
                            newid = size(kin,1)+1;
                            kin(end+1,:) = initializeKinStruct(1,Nframe);
                            framenum = framenum:Nframe;
                        case 'Cancel'
                            return;
                    end
                elseif kin(newid,framenum).kinstate == 1
                    button3 = questdlg('Entered ID is alread taken by another kinetochore in the same frame. Do you want to delete the other one?',...
                        'Choose one option','Yes, change this','Yes, change this and after','Cancel','Cancel');
                    drawnow; pause(0.05);
                    switch button3
                        case 'Yes, change this'
                            [kin,kinpair] = rejectKinetochore(kin,kinpair,newid,framenum);
                            nopass = 0;
                        case 'Yes, change this and after'
                            nopass = 0;
                            framenum = framenum:Nframe;
                        case 'Cancel'
                            return;
                    end
                elseif sum([kin(newid,allframe(allframe~=framenum)).kinstate] == 1)>0
                    existframes = allframe([kin(newid,allframe(allframe~=framenum)).kinstate] == 1);
                    button4 = questdlg(strcat('Entered ID is alread taken by another kinetochore in frames ',...
                        num2str(existframes,'%d,'), '. Do you still want to proceed or use different ID?'),'Entered ID taken',...
                        'Yes, change this','Yes, change this and after','Cancel','Cancel');
                    drawnow; pause(0.05);
                    switch button4
                        case 'Yes, change this'
                            nopass = 0;
                        case 'Yes, change this and after'
                            nopass = 0;
                            framenum = framenum:Nframe;
                        case 'Cancel'
                            return;
                    end
                end
            end
            kin(newid,framenum) = kin(selected_kin,framenum);
            kin(selected_kin,framenum) = initializeKinStruct(1,length(framenum));
            
            htext = [kin(newid,framenum).text_handle];
            set(htext(ishandle(htext)),'String',num2str(newid));
%            set(kin(newid,framenum).text_handle(ishandle(kin(newid,framenum).text_handle)),'String',num2str(newid))
            
            if isempty(kinpair) == 0
                %kin ids that are in pair
                pairedkin = [kinpair(:,framenum).kinids];
            
                idx1 = pairedkin(1,:)==selected_kin;
                idx2 = pairedkin(2,:)==selected_kin;
                if sum(idx1)
                    kinpair(find(idx1),framenum).kinids(1) = newid;
                end
                if sum(idx2)
                    kinpair(find(idx2),framenum).kinids(2) = newid;
                end
            end
            
        case 'Delete'
            button5 = questdlg('Delete only the one in the current frame? Or in all frames','Options','Only this frame','This frame and after','Cancel','Cancel');
            drawnow; pause(0.05);
            
            switch button5
                case 'Only this frame'
                    frametodelete = framenum;
                case 'This frame and after'
                    temp = zeros(1,Nframe);
                    temp(framenum:end) = 1;
                    frametodelete = find([kin(selected_kin,:).kinstate]==1 & temp);
                case 'Cancel'
                    return
            end
            [kin,kinpair] = rejectKinetochore(kin,kinpair,selected_kin,frametodelete);
            kin(selected_kin,frametodelete) = initializeKinStruct(1,length(frametodelete));
        case 'Cancel'
            return;
    end
    
elseif editmode == 2
    switch button
        case 'Change ID'
            nopass = 1;
            while nopass
                answer = inputdlg('Enter new ID');
                drawnow; pause(0.05);
                if isempty(answer)
                    return
                end
                newid = round(str2num(answer{1}));
                
                allframe = 1:Nframe;
                
                if newid > size(kinpair,1) || newid < 1
                    button2 = questdlg('Entered ID doesn''t exist. Do you want to assign new ID?');
                    drawnow; pause(0.05);
                    switch button2
                        case 'Yes'
                            newid = size(kinpair,1)+1;
                            kinpair(end+1,:) = initializeKinPair(1,Nframe);
                            nopass = 0;
                        case 'No'
                            return;
                        case 'Cancel'
                            return;
                    end
                elseif kinpair(newid,framenum).kinpairstate == 1
                    button3 = questdlg('Entered ID is alread taken by another pair in the same frame. Do you want to delete the other one?');
                    drawnow; pause(0.05);
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
                        num2str(existframes,'%d,'), '. Do you still want to proceed or use different ID?'),'Entered ID taken','Yes, change this''Yes, change this and after','Cancel','Cancel');
                    drawnow; pause(0.05);
                    switch button4
                        case 'Yes, change this'
                            nopass = 0;
                        case 'Yes, change this and after'
                            nopass = 0;
                            framenum = framenum:Nframe;
                        case 'Cancel'
                            return;
                    end
                end
            end
            kinpair(newid,framenum) = kinpair(selected_kinpair,framenum);
            kinpair(selected_kinpair,framenum) = initializeKinPair(1,length(framenum));
            
        case 'Delete'
            button5 = questdlg('Delete only the one in the current frame? Or in all frames','Options','Only this frame','All frames','Cancel','Cancel');
            drawnow; pause(0.05);
            
            switch button5
                case 'Only this frame'
                    kinpair_handle = kinpair(selected_kinpair,framenum).kinpair_handle;
                    kinpairtext_handle = kinpair(selected_kinpair,framenum).kinpairtext_handle;
                    delete(kinpair_handle(ishandle(kinpair_handle)));
                    delete(kinpairtext_handle(ishandle(kinpairtext_handle)));
                    
                    kinpair(selected_kinpair,framenum) = initializeKinPair(1,1);
                    
                case 'All frames'  
                    kinpair_handle = [kinpair(selected_kinpair,:).kinpair_handle];
                    kinpairtext_handle = [kinpair(selected_kinpair,:).kinpairtext_handle];
                    delete(kinpair_handle(ishandle(kinpair_handle)));
                    delete(kinpairtext_handle(ishandle(kinpairtext_handle)));
                    
                    kinpair(selected_kinpair,:) = initializeKinPair(1,Nframe);
                    
                    kinpair = DrawKinPair(handles,kinpair);
                    
                case 'Cancel'
                    return
            end
            
        case 'Cancel'
            return;
    end
end


handles.kin = kin;
handles.kinpair = kinpair;

handles = updateKinetochoreListbox(handles);
handles = updateKPairListbox(handles);

guidata(handles.KinetochoreSelectionGui,handles);


function updatedhandles = updateKinetochoreListbox(handles)
kin = handles.kin;
frame = handles.frame;

if isempty(kin)
    updatedhandles = handles;
    return;
end

Nkin = size(kin,1);
Nframe = length(frame);

kinstate = reshape([kin.kinstate],[Nkin,Nframe]);

%check whether kinetochore exist in any frame;
kinstatefr = sum(kinstate,2);
existkin = find(kinstatefr>0);

set(handles.Kinetochore_listbox,'String',cellstr(num2str(sort(existkin))),'Value',1,'Max',Nkin,'Min',1);

updatedhandles = handles;


function updatedhandles = updateKPairListbox(handles)
kinpair = handles.kinpair;

if isempty(kinpair)
    updatedhandles = handles;
    return;
end

Nkinpair = size(kinpair,1);
Nframe = size(kinpair,2);

kinpairstate = reshape([kinpair.kinpairstate],[Nkinpair,Nframe]);

kinpairstatefr = sum(kinpairstate,2);
existkinpair = find(kinpairstatefr);

contents = cell(length(existkinpair),1);
for i = 1:length(existkinpair)
    pairid = existkinpair(i);
    kinpairstatei = [kinpair(pairid,:).kinpairstate];
    kinids = unique([kinpair(pairid,find(kinpairstatei)).kinids]','rows');
    kinids(sum(kinids,2)==0,:) = [];
    kinids = kinids';
    Nidpair = size(kinids,2);
    namestr = sprintf('%d:%d & %d',pairid,kinids(1:2));
    if Nidpair>1
        loop = 1;
        while loop < Nidpair
            namestr = [namestr,sprintf(';%d & %d',kinids(2*loop+1:2*(loop+1)))];
            loop = loop+1;
        end
    end
    contents{i} = namestr;
end

set(handles.KPair_listbox,'String',contents,'Value',1,'Max',Nkinpair,'Min',1);

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
Nkin = size(kin,1);
kinpair = handles.kinpair;
ROI = handles.ROI;
showkin = get(handles.ShowKinID_checkbox,'Value');
showpair = get(handles.ShowKinPair_checkbox,'Value');

set(frame{preselected}.image_handle,'Visible','off')
set(frame{preselected}.time_handle,'Visible','off')
set(frame{selected}.image_handle,'Visible','on');
if get(handles.ShowTime_checkbox,'Value')
    set(frame{selected}.time_handle,'Visible','on','ButtonDownFcn',@ImageClickCallback);
end

if isempty(kin) == 0
    kincircle_handle = [kin.kincircle_handle];
    text_handle = [kin.text_handle];
    set(kincircle_handle(ishandle(kincircle_handle)),'Visible','off')
    set(text_handle(ishandle(text_handle)),'Visible','off')
end

if showkin
    if isempty(kin) == 0
        kinstate = [kin(:,selected).kinstate];
        kincircle_handle = [kin(find(kinstate),selected).kincircle_handle];
        text_handle = [kin(find(kinstate),selected).text_handle];
        set(kincircle_handle(ishandle(kincircle_handle)),'Visible','on','ButtonDownFcn',@ImageClickCallback)
        set(text_handle(ishandle(text_handle)),'Visible','on','ButtonDownFcn',@ImageClickCallback)
    end
end

%Update Kinpair
if isempty(kinpair) == 0
    kinpair_handle = [kinpair.kinpair_handle];
    set(kinpair_handle(ishandle(kinpair_handle)),'Visible','off');
end
if showpair
    if isempty(kinpair) == 0
        kinpairstate = [kinpair(:,selected).kinpairstate];
        kinpair_handle = [kinpair(find(kinpairstate),selected).kinpair_handle];
        set(kinpair_handle(ishandle(kinpair_handle)),'Visible','on','ButtonDownFcn',@ImageClickCallback);
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

ch1 = get(handles.Ch1_checkbox,'Value');
ch2 = get(handles.Ch2_checkbox,'Value');

if prod(ROI(:))
    buttonname = questdlg('ROI not set up. Do you want to set ROI to entire image?','Region of Interest');
    drawnow; pause(0.05);
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

correctmove = get(handles.CorrectCellMovement_checkbox,'Value');
if correctmove & isempty(handles.tforms)
    %for cell movement correction
    img_size = size(frame{1}.image);
    RA = imref2d(img_size,[1,img_size(2)],[1,img_size(1)]);
    [optimizer,metric] = imregconfig('multimodal');
    tforms = cell(Nframe,1);
    tforms{1} = affine2d;
    for t = 2:Nframe
        tforms{t} = imregtform(frame{t}.image(:,:,1),frame{t-1}.image(:,:,1),'rigid',optimizer,metric);
        tforms{t}.T = tforms{t-1}.T*tforms{t}.T;
    end
    handles.tforms = tforms;
end


if prod(ROI(:))
    buttonname = questdlg('ROI not set up. Do you want to set ROI to entire image?','Region of Interest');
    drawnow; pause(0.05);
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

%remove all kinetochores
kin = handles.kin;
if isempty(kin) == 0
    kincircle_handle = [kin.kincircle_handle];
    text_handle = [kin.text_handle];
    delete(kincircle_handle(ishandle(kincircle_handle)))
    delete(text_handle(ishandle(text_handle)))
end
kin = [];

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
    end
else
    MT2 = [];
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
    
    %if you want to correct for the movement of cell
    correctmove = get(handles.CorrectCellMovement_checkbox,'Value');
    if correctmove
        tforms = handles.tforms;
        corrMT = avgMT;
        for i = 1:size(corrMT,1)
            newx = [corrMT(i,1:2),1]*tforms{corrMT(i,8)}.T;
            corrMT(i,1:2) = newx(1:2); 
        end
        tempres=trackmemkin(corrMT, maxdisp, dim, goodenough, memory);
        for i = 1:size(tempres,1)
            newx = [tempres(i,1:2),1]/tforms{tempres(i,8)}.T;
            tempres(i,1:2) = newx(1:2);
        end
    else
        tempres=trackmemkin(avgMT, maxdisp, dim, goodenough, memory);
    end
    
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
        kin(i,kinframe(j)).locsource = [-1;-1];
        kin(i,kinframe(j)).x = squeeze(kinres(j,1,:));
        kin(i,kinframe(j)).y = squeeze(kinres(j,2,:));
        kin(i,kinframe(j)).Rg = sqrt(squeeze(kinres(j,4,:)));
        kin(i,kinframe(j)).kincircle_handle = [-99;-99];
        kin(i,kinframe(j)).text_handle = [-99;-99];
    end
end

kin = DrawKinCircle_updated(handles,kin);

handles.frame = frame;
handles.kin = kin;
handles.kinpair = kinpair;

handles = updateKinetochoreListbox(handles);

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


function outkin = DrawKinCircle_updated(handles,inkin)


%the number of circles to be updated
Nkin = size(inkin,1);
Nframe = size(inkin,2);
Ncircle = Nkin*Nframe*2;
coverage = str2double(get(handles.Coverage_edit,'String'));
showkin = get(handles.ShowKinID_checkbox,'Value');

frame = handles.frame;
img = frame{1}.image;
[X,Y] = meshgrid(1:size(img,1),1:size(img,2));

if Nkin == 0 
    outkin = inkin;
    return;
end
for kinid = 1:Nkin
    for fr = 1:Nframe
        check = 0;
        for ch = 1:2
            kinstate = inkin(kinid,fr).kinstate;
            if kinstate == 0 
                continue;
            end
            source = inkin(kinid,fr).locsource(ch);
            x = inkin(kinid,fr).x(ch);
            y = inkin(kinid,fr).y(ch);
            mux = inkin(kinid,fr).mux(ch);
            muy = inkin(kinid,fr).muy(ch);
            Rg = inkin(kinid,fr).Rg(ch);
            sigx = inkin(kinid,fr).sigx(ch);
            sigy = inkin(kinid,fr).sigy(ch);
            theta = inkin(kinid,fr).theta(ch);
            
            if source == -1   %from center of mass
                color = 'g';
            elseif source == 0
                color = 'r';
            elseif source == 1
                color = 'b';                
            end
            
            cenx = (source==-1 & x>0)*x+(source>=0 & mux>0)*mux;
            ceny = (source==-1 & y>0)*y+(source>=0 & muy>0)*muy;
            Ra = ((source==-1 & Rg>0)*Rg+(source>=0 & sigx>0)*sigx*sqrt(2))*coverage;
            Rb = ((source==-1 & Rg>0)*Rg+(source>=0 & sigy>0)*sigy*sqrt(2))*coverage;
            
            if cenx == 0
                continue;        
            end
            
            if ch == 1
                set(handles.KinetochoreSelectionGui,'CurrentAxes',handles.Image_axes)
            elseif ch == 2
                set(handles.KinetochoreSelectionGui,'CurrentAxes',handles.Image2_axes)
            end
            
            kincircle_handle = inkin(kinid,fr).kincircle_handle(ch);
            if ishandle(kincircle_handle)
                delete(kincircle_handle)
            end
            text_handle = inkin(kinid,fr).text_handle(ch);
            if ishandle(text_handle)
                delete(text_handle)
            end
            
            
            %(Re)draw kinetochore circles/ellipse
            kincircle_handle = ellipse(Ra,Rb,-theta,cenx,ceny,color);
            set(kincircle_handle,'LineWidth',1.3);
            
            text_handle = text(cenx-2,ceny-2,num2str(kinid),'Clipping','on');
            set(kincircle_handle,'Visible','off','ButtonDownFcn',@ImageClickCallback)
            set(text_handle,'Visible','off','FontSize',12,'Color','y','FontWeight','bold',...
                'ButtonDownFcn',@ImageClickCallback,'HorizontalAlignment','right')
            
            inkin(kinid,fr).kincircle_handle(ch) = kincircle_handle;
            inkin(kinid,fr).text_handle(ch) = text_handle;

            check = check+1;
            
            Nchecked = ((kinid-1)*Nframe+fr-1)*2+ch;
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
    end
end

inkin = updateSelectedPixel(handles,inkin);

selected = get(handles.FrameSelection_slider,'Value');
if showkin
    kinstate = [inkin(:,selected).kinstate];
    kincircle_handle = [inkin(find(kinstate),selected).kincircle_handle];
    text_handle = [inkin(find(kinstate),selected).text_handle];
    set(kincircle_handle(ishandle(kincircle_handle)),'Visible','on')
    set(text_handle(ishandle(text_handle)),'Visible','on')
end

outkin = inkin;


function kinstruct = initializeKinStruct(a,b)
kinstruct = struct('time',cell(a,b),'selected_pixel',cell(a,b),...
    'kinstate',0,'locsource',[-99;-99],...
    'x',[0;0],'y',[0;0],'Rg',[0;0],'mux',[0;0],'muy',[0;0],'sigx',[0;0],...
    'sigy',[0;0],'theta',[0;0],'A',[0;0],'bg',[0;0],'converged',[0;0],'kincircle_handle',[-99;-99],'text_handle',[-99;-99]);



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

coverage = str2double(get(handles.Coverage_edit,'String'));

resol = 20;
%whether or not you want to force sigx = sigy
couplesig = 0;

hplot = -99;
Ntot = sum(sum([kin.x]>0));
disp([num2str(Ntot), ' kinetochores to be fit..']);

Nconverged = 0;
stop = 0;
tic
for fr = 1:Nframe
    for ch = 1:2
        if ch == 1 & ch1==0
            continue;
        elseif ch == 2 & ch2==0
            continue;
        end
        
        image = frame{fr}.image(:,:,ch);
        
        kinstate = [kin(:,fr).kinstate];
        
        %coordinates of kinetochores
        x = [kin(:,fr).x];
        y = [kin(:,fr).y];
        
        x = x(ch,:);
        y = y(ch,:);
        
        %radius of kinetochores
        Rg = [kin(:,fr).Rg];
        radius = Rg(ch,:)*coverage;
        
        %map showing the existance of pairs
        existvec = (x>0) & (kinstate);
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
                    kinToFit(kinToFit==0) = [];
                    connected_pairs(rows,:) = [];
                end
            end
            
            available_kin(ismember(available_kin,kinToFit)) = [];
            Navail = length(available_kin);
            
            NkinToFit = length(kinToFit);

            %initial guess of gaussian fitting
            [xinit,yinit,sigxinit,sigyinit] = constructParamVector(kin(kinToFit,fr),ch);
            
            Rg = [kin(kinToFit,fr).Rg];
            radius = Rg(ch,:)*coverage;
            radius = radius(:);
            xlin = max(min(floor(xinit-2.5*radius)),1):min(max(ceil(xinit+2.5*radius)),size(image,2));
            ylin = max(min(floor(yinit-2.5*radius)),1):min(max(ceil(yinit+2.5*radius)),size(image,1));
            
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
% 
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
                if kin(kinid,fr).x(ch)==0
                    continue;
                elseif kin(kinid,fr).mux(ch)==0
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


kin = DrawKinCircle_updated(handles,kin);    

handles.frame = frame;
handles.kin = kin;

S = datestr(now,'yyyymmddTHHMM');
savedir = 'temp_saved_kin_result/';
ex = exist(savedir,'dir');
if ex == 0
    mkdir(savedir);
end
fname = [S,'tempSavedKinetochoreSelectionSession.mat'];

saveKinetochoreSession([savedir,fname],handles);

guidata(hObject,handles)


function [mux,muy,sigx,sigy] = constructParamVector(kin,ch)
% [mux,muy,sigx,sigy] = constructParamVector(kin,ch)
% construct initial guess parameter vector from kinetochore structure in given channel ch.
% kin should be a vector of kinetochore structure
% the length of each param vector should be length(kin)
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
kin = handles.kin;
includenonconverged = get(handles.IncludeNonconverged_checkbox,'Value');
Nframe = size(kin,2);
Nkin = size(kin,1);

if GaussPreffered == 1
    for fr = 1:Nframe
        for kinid = 1:Nkin
            for ch = 1:2
                if kin(kinid,fr).x(ch)==0
                    continue;
                elseif kin(kinid,fr).mux(ch)==0
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

kin = DrawKinCircle_updated(handles,kin);

handles.kin = kin;

guidata(hObject,handles)



% --- Executes on button press in IncludeNonconverged_checkbox.
function IncludeNonconverged_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to IncludeNonconverged_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of IncludeNonconverged_checkbox

includenonconverged = get(hObject,'Value');
kin = handles.kin;
GaussPreffered = get(handles.GaussPreffered_checkbox,'Value');
Nframe = size(kin,2);
Nkin = size(kin,1);

if GaussPreffered == 1
    for fr = 1:Nframe
        for kinid = 1:Nkin
            for ch = 1:2
                if kin(kinid,fr).x(ch)==0
                    continue;
                elseif kin(kinid,fr).mux(ch)==0
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
    %do nothing
    return;
end

kin = DrawKinCircle_updated(handles,kin);

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
kinpair = handles.kinpair;

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
    text_handle = kin(repkin,i).text_handle;
    set(text_handle(ishandle(text_handle)),'String',num2str(repkin))
end

for i = 2:Nkinselected
    kinid = kinselected(i);
    [kin,kinpair] = rejectKinetochore(kin,kinpair,kinid,1:Nframe);
end

kin(kinselected(kinselected~=repkin),:) = initializeKinStruct(Nkinselected-1,Nframe);

contents(ismember(str2double(contents),kinselected(2:end)))=[];
set(handles.Kinetochore_listbox,'String',contents)
set(handles.Kinetochore_listbox,'Value',1)

handles.kin = kin;
handles.frame = frame;
handles.kinpair = kinpair;

handles = updateKinetochoreListbox(handles);
handles = updateKPairListbox(handles);

guidata(hObject,handles)




% --- Executes on button press in RemoveSelected_pushbutton.
function RemoveSelected_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to RemoveSelected_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
contents = cellstr(get(handles.Kinetochore_listbox,'String'));
kin_selected = str2double(contents(get(handles.Kinetochore_listbox,'Value')));
kin = handles.kin;
kinpair = handles.kinpair;
Nframe = size(kin,2);

N_rm = length(kin_selected);

for k = 1:N_rm
    [kin,kinpair] = rejectKinetochore(kin,kinpair,kin_selected(k),1:Nframe);
    
    %reset corresponding kinetochore structures
    kin(kin_selected(k),:) = initializeKinStruct(1,Nframe);
end

handles.kin = kin;
handles.kinpair = kinpair;

handles = updateKinetochoreListbox(handles);
handles = updateKPairListbox(handles);

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
frame = handles.frame;
Nframe = length(frame);
kin = handles.kin;
Nkin = size(kin,1);

if ishandle(handles.hMainGui)
    hMainGui = handles.hMainGui;
elseif isempty(findall(0,'Tag','MainGui')) == 0
    hMainGui = findall(0,'Tag','MainGui');
else
    errordlg('MainGuihandle not available')
    return
end
MainGuihandles = guidata(hMainGui);

%pathname check
image_struct = MainGuihandles.image_struct;
image_struct = cell2mat(image_struct);
framemat = cell2mat(frame);
pathnameMainGui = {image_struct.pathname}';
filenameMainGui = {image_struct.filename}';
filenameKinGui = {framemat.filename};
if isfield(frame{1},'pathname')
    pathnameKinGui = {framemat.pathname};
    if sum(ismember(unique(pathnameMainGui),unique(pathnameKinGui))) == 0
        disp('pathnames of data in MainGui and KinetochoreSelectionGui don''t match')
        return;
    end
    fullnameMainGui = strcat(pathnameMainGui,filenameMainGui);
    fullnameKinGui = strcat(pathnameKinGui,filenameKinGui);
else
    fullnameMainGui = filenameMainGui;
    fullnameKinGui = filenameKinGui;
end

[~,selected] = ismember(fullnameKinGui,fullnameMainGui);

current = get(MainGuihandles.ImageSelection_slider,'Value');

    
img_size = size(frame{1}.image);

kin = updateSelectedPixel(handles,kin);

for fr = 1:Nframe
    kinstate = [kin(:,fr).kinstate];
    selected_pixel = zeros(img_size(2),img_size(1));
    
    for kinid = 1:Nkin
        if kinstate(kinid)
            selected_pixel = selected_pixel | kin(kinid,fr).selected_pixel;
        end
    end
    
    MainGuihandles.image_struct{selected(fr)}.selected_pixel = selected_pixel;
end


for i = selected
    
    image_struct = MainGuihandles.image_struct{i};
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

guidata(hMainGui,MainGuihandles)

axes(MainGuihandles.Image_axes)
set(MainGuihandles.image_struct{current}.selected_pixel_handle,'Visible','on')

axes(MainGuihandles.Decay_axes)
set(MainGuihandles.image_struct{current}.decay_handle,'Visible','on')

set(MainGuihandles.TotalCount_text,'String',num2str(sum(MainGuihandles.image_struct{current}.decay)))


function outkin = updateSelectedPixel(handles,kin)
if isempty(kin)
    outkin = kin;
    return;
end
%update selected pixels
frame = handles.frame;
Nkin = size(kin,1);
Nframe = size(kin,2);
img = frame{1}.image;
[X,Y] = meshgrid(1:size(img,1),1:size(img,2));
coverage = str2double(get(handles.Coverage_edit,'String'));
flimblock = handles.flimblock;
ch1 = get(handles.Ch1_checkbox,'Value');
ch2 = get(handles.Ch2_checkbox,'Value');

if ch1 & ch2 
    ch = flimblock;
elseif ch1
    ch = 1;
elseif ch2
    ch = 2;
end
for kinid = 1:Nkin
    for fr = 1:Nframe
        %ch = flimblock;
        kinstate = kin(kinid,fr).kinstate;
        if kinstate == 0
            continue;
        end
        source = kin(kinid,fr).locsource(ch);
        x = kin(kinid,fr).x(ch);
        y = kin(kinid,fr).y(ch);
        mux = kin(kinid,fr).mux(ch);
        muy = kin(kinid,fr).muy(ch);
        Rg = kin(kinid,fr).Rg(ch);
        sigx = kin(kinid,fr).sigx(ch);
        sigy = kin(kinid,fr).sigy(ch);
        theta = kin(kinid,fr).theta(ch);
        
        cenx = (source==-1 & x>0)*x+(source>=0 & mux>0)*mux;
        ceny = (source==-1 & y>0)*y+(source>=0 & muy>0)*muy;
        Ra = ((source==-1 & Rg>0)*Rg+(source>=0 & sigx>0)*sigx*sqrt(2))*coverage;
        Rb = ((source==-1 & Rg>0)*Rg+(source>=0 & sigy>0)*sigy*sqrt(2))*coverage;
        
        if cenx == 0
            continue;
        end
        
        %update selected_pixel
        Xp = (X-cenx)*cos(theta)-(Y-ceny)*sin(theta);
        Yp = (X-cenx)*sin(theta)+(Y-ceny)*cos(theta);
        kin(kinid,fr).selected_pixel = Xp.^2/Ra^2+Yp.^2/Rb^2<=1;
    end
end
outkin = kin;


% --- Executes on button press in LifetimeAnalysis_pushbutton.
function LifetimeAnalysis_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to LifetimeAnalysis_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

figname = 'FittingGUI_ver9_2';
hfig = CheckOpenState(figname);
if hfig ~= -99
    choice = questdlg([figname ' is currently open. Pressing "New" will delete the data previously in ',figname,' and open new one.'],'!Already opened!','New','Append','Cancel','Cancel');
    drawnow; pause(0.05);
    if strcmp(choice,'New')==1
        close(hfig);
    elseif strcmp(choice,'Append')==1
    else
        return;
    end
else
    choice = 'New';
end

answer = inputdlg('Enter Prefix','Prefix',1,{''});
drawnow; pause(0.05);

if isempty(answer)
    return;
end
prefix = answer{1};

contents = cellstr(get(handles.Kinetochore_listbox,'String'));
kin_selected = str2double(contents(get(handles.Kinetochore_listbox,'Value')));

frame = handles.frame;
kin = handles.kin;
kin = updateSelectedPixel(handles,kin);

Nkinselected = length(kin_selected);
Nframe = length(frame);

decay_struct = [];
tic
for k = 1:Nkinselected
    for fr = 1:Nframe
        if kin(kin_selected(k),fr).kinstate == 0
            continue;
        end
        kinidstr = num2str(kin_selected(k),'%03d');
        frstr = num2str(fr,'%03d');
        name = [prefix 'kin',kinidstr,'fr',frstr];
        filename = frame{fr}.filename;
        setting = frame{fr}.setting;
        
        selected_pixel = kin(kin_selected(k),fr).selected_pixel(:,:);
        
        flim = frame{fr}.flim;
        dt = frame{fr}.dt;
        %time axis
        time = (1:length(flim(:,1,1)))'*dt;
        
        decay = zeros(length(time),1);
        for i = 1:length(time)
            temp = flim(i,:,:);
            decay(i) = sum(temp(:).*selected_pixel(:));
%            decay(i) = sum(sum(squeeze(flim(i,:,:)).*selected_pixel));
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
        new_struct{1}.setting = setting;
        decay_struct = [decay_struct;new_struct];
    end
end
handles.kin = kin;
toc
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

if isempty(vert)
    return;
end

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
spaxis = handles.spaxis;
kinpair = handles.kinpair;

Nkin = size(kin,1);
Nframe = size(kin,2);

if isempty(spaxis)
    errordlg('Find spindle axis first');
    return
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

kinstate = [kin.kinstate];
kinstate = reshape(kinstate,[Nkin,Nframe]);

avgx = avgx.*kinstate;
avgy = avgy.*kinstate;
% 
% %intrakinetochore stretch (ch1-ch2), -99 if not available
% xch1 = arrayfun(@(A) (A.locsource(1)==-1).*A.x(1).*(A.x(1)>0)+(A.locsource(1)>=0).*A.mux(1).*(A.mux(1)>0),kin);
% xch2 = arrayfun(@(A) (A.locsource(2)==-1).*A.x(2).*(A.x(2)>0)+(A.locsource(2)>=0).*A.mux(2).*(A.mux(2)>0),kin);
% ych1 = arrayfun(@(A) (A.locsource(1)==-1).*A.y(1).*(A.y(1)>0)+(A.locsource(1)>=0).*A.muy(1).*(A.muy(1)>0),kin);
% ych2 = arrayfun(@(A) (A.locsource(2)==-1).*A.y(2).*(A.y(2)>0)+(A.locsource(2)>=0).*A.muy(2).*(A.muy(2)>0),kin);
% stretchx = (xch1-xch2).*(xch1>0 & xch2>0)-99*(xch1==0 | xch2==0);
% stretchy = (ych1-ych2).*(ych1>0 & ych2>0)-99*(ych1==0 | ych2==0);


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
    bothexist(:,:,fr) = bsxfun(@and,kinstate(:,fr)>0,kinstate(:,fr)'>0);
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
    
%Erase previously drawn kinpair
if isempty(kinpair) == 0
    kinpair_handle = [kinpair.kinpair_handle];
    kinpairtext_handle = [kinpair.kinpairtext_handle];
    delete(kinpair_handle(ishandle(kinpair_handle)));
    delete(kinpairtext_handle(ishandle(kinpairtext_handle)));
end

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


function outkinpair = DrawKinPair(handles,kinpair,kin)
ch1 = handles.Ch1_checkbox;
ch2 = handles.Ch2_checkbox;
if nargin < 3
    kin = handles.kin;
end
if isempty(kinpair)
    outkinpair = kinpair;
    return;
end
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
            kinpairstate = kinpair(pairid,fr).kinpairstate;
            
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
            if kinpairstate == 0 
                continue
            end
            
            if ch == 1
                set(handles.KinetochoreSelectionGui,'CurrentAxes',handles.Image_axes);
            elseif ch == 2
                set(handles.KinetochoreSelectionGui,'CurrentAxes',handles.Image2_axes);
            end
            kinpair(pairid,fr).kinpair_handle(ch) = line([xc1;xc2],[yc1;yc2],'Color','b','LineWidth',1.5);
            
            set(kinpair(pairid,fr).kinpair_handle(ch),'Visible','off','ButtonDownFcn',@ImageClickCallback)
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
drawnow; pause(0.05);

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


% --- Executes on button press in SaveSession_pushbutton.
function SaveSession_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to SaveSession_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[name pathname filterindex] = uiputfile3('*.mat','mode','analysis');
drawnow; pause(0.05);

if isequal(name,0)
    return;
end

if name ~= 0
    saveKinetochoreSession([pathname,name],handles);
end


function saveKinetochoreSession(fname,handles)
kin = handles.kin;
kinpair = handles.kinpair;
frame = handles.frame;
pixsize = handles.pixsize;
spaxis = handles.spaxis;
ROI = handles.ROI;
flimblock = handles.flimblock;

editboxes = findobj(handles.KinetochoreSelectionGui,'Type','UIControl','Style','edit');
checkboxes = findobj(handles.KinetochoreSelectionGui,'Type','UIControl','Style','checkbox');
allhandles = [editboxes;checkboxes];

settingtags = get(allhandles,'Tag');
editvalues = get(editboxes,'String');
checkboxvalues = get(checkboxes,'Value');
settingvalues = [editvalues;checkboxvalues];

if fname ~= 0
    save(fname,'ROI','kin','kinpair','frame','spaxis','pixsize','settingtags','settingvalues','flimblock');
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

kin = handles.kin;

kin = DrawKinCircle_updated(handles,kin);

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
kin = handles.kin;
selected = get(handles.FrameSelection_slider,'Value');

if showkin
    str = 'on';
elseif showkin == 0
    str = 'off';
end
if isempty(kin) == 0
    kinstate = [kin(:,selected).kinstate];
    kincircle_handle = [kin(find(kinstate),selected).kincircle_handle];
    text_handle = [kin(find(kinstate),selected).text_handle];
    set(kincircle_handle(ishandle(kincircle_handle)),'Visible',str)
    set(text_handle(ishandle(text_handle)),'Visible',str)
end
    

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




% --- Executes on button press in MakeMovie_pushbutton.
function MakeMovie_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to MakeMovie_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
frame = handles.frame;
ROI = handles.ROI;
pixsize= handles.pixsize;
kin = handles.kin;
kinpair = handles.kinpair;
coverage = str2double(get(handles.Coverage_edit,'String'));
showkin = get(handles.ShowKinID_checkbox,'Value');
showpair = get(handles.ShowKinPair_checkbox,'Value');
Nkin = size(kin,1);
Nkinpair = size(kinpair,1);

%Example number of frame
eg_Nframe = length(frame);

prompt = {'Frame numbers (e.g. 1:2:9):', ...
    'Frame rate (frames/sec)','Pixel Size'};
dlg_title = 'Movie Maker';
num_lines = 1;
def = {['1:',num2str(eg_Nframe)],'4',num2str(pixsize)};
answer = inputdlg(prompt,dlg_title,num_lines,def);
drawnow; pause(0.05);

if isempty(answer)
    return;
end

framenum = str2num(answer{1});
framerate = str2num(answer{2});
pixsize = str2double(answer{3});

%choose save directory
[filename,pathname] = uiputfile3('*.avi','Save movie file as','mode','analysis');
drawnow; pause(0.05);
if filename == 0 
    return;
end

writerObj = VideoWriter([pathname,filename],'Uncompressed AVI');
writerObj.FrameRate = framerate;
open(writerObj)
h = figure;
set(h,'Position',[100,100,600,600]);
axis off;
axis image;

for i = 1:length(framenum)
    fr = framenum(i);
    img = double(frame{fr}.image);
    
    normimg = zeros(size(img,1),size(img,2),3);
    for ch = 1:2
        img_ROI = img(:,:,ch).*ROI;
        maxvalue = max(img_ROI(:));
        if maxvalue == 0
            normimg(:,:,ch) = 0;
        else
            normimg(:,:,ch) = min(1,img(:,:,ch)/maxvalue);
        end
    end
    
    imagesc(normimg);
    hold on;
    
    %Add scale bar
    %in micrometer
    barsize = 2;
    line([0.9*size(img,2)-round(barsize/pixsize),0.9*size(img,2)],...
        [0.9*size(img,1),0.9*size(img,1)],'LineWidth',2,'Color','Yellow')
    text(0.9*size(img,2)-round(barsize/pixsize),0.9*size(img,1)-6,...
        [num2str(barsize), '{\mu}', 'm'],'Color','yellow','fontsize',10)
    %Add real time
    text(0.1*size(img,2),0.1*size(img,1),[num2str(frame{i}.time),' sec'],'fontsize',10,...
        'Color','y')
    
    %Update kinetochores    
    if showkin
        for kinid = 1:Nkin
            for ch = 1:2
                kinstate = kin(kinid,fr).kinstate;
                if kinstate == 0
                    continue;
                end
                source = kin(kinid,fr).locsource(ch);
                x = kin(kinid,fr).x(ch);
                y = kin(kinid,fr).y(ch);
                mux = kin(kinid,fr).mux(ch);
                muy = kin(kinid,fr).muy(ch);
                Rg = kin(kinid,fr).Rg(ch);
                sigx = kin(kinid,fr).sigx(ch);
                sigy = kin(kinid,fr).sigy(ch);
                theta = kin(kinid,fr).theta(ch);
                
                if source == -1   %from center of mass
                    color = 'g';
                elseif source == 0
                    color = 'r';
                elseif source == 1
                    color = 'b';
                end
                
                cenx = (source==-1)*x+(source>=0)*mux;
                ceny = (source==-1)*y+(source>=0)*muy;
                Ra = ((source==-1)*Rg+(source>=0)*sigx*sqrt(2))*coverage;
                Rb = ((source==-1)*Rg+(source>=0)*sigy*sqrt(2))*coverage;
                
                if cenx == 0
                    continue;
                end
                
                %(Re)draw kinetochore circles/ellipse
                kincircle_handle = ellipse(Ra,Rb,-theta,cenx,ceny,color);
                set(kincircle_handle,'LineWidth',1.3);
                text_handle = text(cenx-2,ceny-2,num2str(kinid),'Clipping','on');
                set(text_handle,'FontSize',12,'Color','y','FontWeight','bold','HorizontalAlignment','right')
            end
        end
    end
    
    if showpair
        for pairid = 1:Nkinpair
            for ch = 1:2
                kinids = kinpair(pairid,fr).kinids;
                kinpairstate = kinpair(pairid,fr).kinpairstate;
                
                if kinids(1) == 0
                    continue
                end
                kin1 = kin(kinids(1),fr);
                kin2 = kin(kinids(2),fr);
                xc1 = kin1.x(ch)*(kin1.locsource(ch)==-1)+kin1.mux(ch)*(kin1.locsource(ch)>=0);
                yc1 = kin1.y(ch)*(kin1.locsource(ch)==-1)+kin1.muy(ch)*(kin1.locsource(ch)>=0);
                xc2 = kin2.x(ch)*(kin2.locsource(ch)==-1)+kin2.mux(ch)*(kin2.locsource(ch)>=0);
                yc2 = kin2.y(ch)*(kin2.locsource(ch)==-1)+kin2.muy(ch)*(kin2.locsource(ch)>=0);
                
                if kinpairstate == 0
                    continue
                end
                line([xc1;xc2],[yc1;yc2],'Color','b','LineWidth',1.5);
            end
        end
    end
    
    hold off;
    
    F = getframe;
    
    warning('off', 'Images:initSize:adjustingMag');
    writeVideo(writerObj,F);
    
    ax = gca;
    delete(ax.Children)
end

close(h)
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
frame = handles.frame;
img = frame{1}.image;
img_size = size(img);

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


% --- Executes on button press in SelectPaired_pushbutton.
function SelectPaired_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to SelectPaired_pushbutton (see GCBO)
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
pairedkin = [kinpair(pairids,:).kinids];
kinpairstate = [kinpair(pairids,:).kinpairstate];

pairedkin = pairedkin(:,find(kinpairstate));
pairedkin = unique(pairedkin);
pairedkin(pairedkin==0) = [];

kinlist = str2double(cellstr(get(handles.Kinetochore_listbox,'String')));
selectedkin = find(ismember(kinlist,pairedkin));
set(handles.Kinetochore_listbox,'Value',selectedkin);


% --- Executes on button press in LoadSession_pushbutton.
function LoadSession_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to LoadSession_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

choice = questdlg('Loading new session will close the current session. Do you want to proceed?','Loading new session',...
    'Yes','No','Cancel','Cancel');
drawnow; pause(0.05);

switch choice
    case 'Yes'
    case 'No'
        return;
    case 'Cancel'
        return;
end

[fname,pthname,~] = uigetfile3('*.mat','mode','analysis');
drawnow; pause(0.05);
if pthname == 0
    return;
end
loaded = load([pthname,fname]);
kin = loaded.kin;
kinpair = loaded.kinpair;
frame = loaded.frame;
if isfield(loaded,'pixsize')==0
    pixsize = 0.1074; %default value, when 40x obj, 128x128 image size, and 32x zoom are used 
else
    pixsize = loaded.pixsize;
end
spaxis = loaded.spaxis;
ROI = loaded.ROI;
if isfield(loaded,'flimblock')==0
    flimblock = 2;
else
    flimblock = loaded.flimblock;
end

Nframe = length(frame);

for i = 1:Nframe    
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
handles.hMainGui = -99;
handles.frame = frame;
handles.ROI = ROI;
handles.ROI_handle = [];
handles.spaxis_handle = [];
handles.spaxis = spaxis;
handles.pixsize = pixsize;
handles.scalebar_handle = scalebar_handle;
handles.preselected = 1;
handles.flimblock = flimblock;

kin = DrawKinCircle_updated(handles,kin);
kinpair = DrawKinPair(handles,kinpair,kin);

%all kinetochore structures
handles.kin = kin;
handles.kinpair = kinpair;

set(handles.FrameNumber_text,'String',['1 out of ' num2str(Nframe)]);

% Load setting for kinetochore selection setting
SaveLoadKinSelectionSetting(handles,'Load',1);

if isfield(loaded,'settingtags')
    editboxes = findobj(handles.KinetochoreSelectionGui,'Type','UIControl','Style','edit');
    checkboxes = findobj(handles.KinetochoreSelectionGui,'Type','UIControl','Style','checkbox');
    [editboxesTF,editboxesidx] = ismember(get(editboxes,'Tag'),loaded.settingtags);
    [checkboxesTF,checkboxesidx] = ismember(get(checkboxes,'Tag'),loaded.settingtags);
    
    set(editboxes(editboxesTF),{'String'},loaded.settingvalues(editboxesidx));
    set(checkboxes(checkboxesTF),{'Value'},loaded.settingvalues(checkboxesidx));
end

handles = updateKinetochoreListbox(handles);
handles = updateKPairListbox(handles);

% Update handles structure
guidata(hObject, handles);


function EllipticityCutoff_edit_Callback(hObject, eventdata, handles)
% hObject    handle to EllipticityCutoff_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EllipticityCutoff_edit as text
%        str2double(get(hObject,'String')) returns contents of EllipticityCutoff_edit as a double
kin = handles.kin;
kinpair = handles.kinpair;

[kin,kinpair] = rejectKinetochoreUsingCriteria(handles,kin,kinpair);

handles.kin = kin;
handles.kinpair = kinpair;

handles = updateKinetochoreListbox(handles);
handles = updateKPairListbox(handles);
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function EllipticityCutoff_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EllipticityCutoff_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in RejectEllipticity_checkbox.
function RejectEllipticity_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to RejectEllipticity_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of RejectEllipticity_checkbox
kin = handles.kin;
kinpair = handles.kinpair;

[kin,kinpair] = rejectKinetochoreUsingCriteria(handles,kin,kinpair);

handles.kin = kin;
handles.kinpair = kinpair;

handles = updateKinetochoreListbox(handles);
handles = updateKPairListbox(handles);
guidata(hObject,handles);



% --- Executes on button press in RejectTrajOverlap_checkbox.
function RejectTrajOverlap_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to RejectTrajOverlap_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of RejectTrajOverlap_checkbox
kin = handles.kin;
kinpair = handles.kinpair;

[kin,kinpair] = rejectKinetochoreUsingCriteria(handles,kin,kinpair);

handles.kin = kin;
handles.kinpair = kinpair;

handles = updateKinetochoreListbox(handles);
handles = updateKPairListbox(handles);
guidata(hObject,handles);


function OverlapDistThres_edit_Callback(hObject, eventdata, handles)
% hObject    handle to OverlapDistThres_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of OverlapDistThres_edit as text
%        str2double(get(hObject,'String')) returns contents of OverlapDistThres_edit as a double
kin = handles.kin;
kinpair = handles.kinpair;

[kin,kinpair] = rejectKinetochoreUsingCriteria(handles,kin,kinpair);

handles.kin = kin;
handles.kinpair = kinpair;

handles = updateKinetochoreListbox(handles);
handles = updateKPairListbox(handles);
guidata(hObject,handles);


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
kin = handles.kin;
kinpair = handles.kinpair;

[kin,kinpair] = rejectKinetochoreUsingCriteria(handles,kin,kinpair);

handles.kin = kin;
handles.kinpair = kinpair;

handles = updateKinetochoreListbox(handles);
handles = updateKPairListbox(handles);
guidata(hObject,handles);

% --- Executes on button press in RejectNoFLIM_checkbox.
function RejectNoFLIM_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to RejectNoFLIM_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of RejectNoFLIM_checkbox
kin = handles.kin;
kinpair = handles.kinpair;

[kin,kinpair] = rejectKinetochoreUsingCriteria(handles,kin,kinpair);

handles.kin = kin;
handles.kinpair = kinpair;

handles = updateKinetochoreListbox(handles);
handles = updateKPairListbox(handles);
guidata(hObject,handles);

% --- Executes on button press in RejectRadius_checkbox.
function RejectRadius_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to RejectRadius_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of RejectRadius_checkbox
kin = handles.kin;
kinpair = handles.kinpair;

[kin,kinpair] = rejectKinetochoreUsingCriteria(handles,kin,kinpair);

handles.kin = kin;
handles.kinpair = kinpair;

handles = updateKinetochoreListbox(handles);
handles = updateKPairListbox(handles);
guidata(hObject,handles);


function RadiusCutoff_edit_Callback(hObject, eventdata, handles)
% hObject    handle to RadiusCutoff_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of RadiusCutoff_edit as text
%        str2double(get(hObject,'String')) returns contents of RadiusCutoff_edit as a double
kin = handles.kin;
kinpair = handles.kinpair;

[kin,kinpair] = rejectKinetochoreUsingCriteria(handles,kin,kinpair);

handles.kin = kin;
handles.kinpair = kinpair;

handles = updateKinetochoreListbox(handles);
handles = updateKPairListbox(handles);
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function RadiusCutoff_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to RadiusCutoff_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function [outkin,outkinpair] = rejectKinetochoreUsingCriteria(handles,kin,kinpair)
rejectoverlap = get(handles.RejectTrajOverlap_checkbox,'Value');
rejectnogauss = get(handles.RejectNoGaussFit_checkbox,'Value');
rejectnoflim = get(handles.RejectNoFLIM_checkbox,'Value');
rejectellipse = get(handles.RejectEllipticity_checkbox,'Value');
rejectradius = get(handles.RejectRadius_checkbox,'Value');
overlapthres = str2double(get(handles.OverlapDistThres_edit,'String'));
ellipcutoff = str2double(get(handles.EllipticityCutoff_edit,'String'));
radiuscutoff = str2double(get(handles.RadiusCutoff_edit,'String'));

ch1 = get(handles.Ch1_checkbox,'Value');
ch2 = get(handles.Ch2_checkbox,'Value');
flimblock = handles.flimblock;
frame = handles.frame;
coverage = str2double(get(handles.Coverage_edit,'String'));

Nkin = size(kin,1);
Nframe = size(kin,2);

if isempty(kin)
    outkin = kin;
    outkinpair = kinpair;
    return;
end

kintoaccept = [];
kintoreject = [];


for fr = 1:Nframe
    %coordinates of kinetochores
    x = [kin(:,fr).x];
    y = [kin(:,fr).y];
    mux = [kin(:,fr).mux];
    muy = [kin(:,fr).muy];
    
    %radius of kinetochores
    Rg = [kin(:,fr).Rg];
    sigx = [kin(:,fr).sigx];
    sigy = [kin(:,fr).sigy];
    locsource = [kin(:,fr).locsource];
    
    availablekin = (find(sum(locsource~=-99,1)>0))';
    
    kintoreject_fr = [];
    for ch = 1:2
        if ch ==1 & ch1 == 0
            continue;
        elseif ch == 2 & ch2== 0
            continue;
        end
        
        image = frame{fr}.image(:,:,ch);
        
        radius = ((locsource(ch,:)==-1).*Rg(ch,:)+(locsource(ch,:)>=0).*(sigx(ch,:)+sigy(ch,:))*sqrt(2)/2)*coverage;
        
        cenx = (locsource(ch,:)==-1).*x(ch,:)+(locsource(ch,:)>=0).*mux(ch,:);
        ceny = (locsource(ch,:)==-1).*y(ch,:)+(locsource(ch,:)>=0).*muy(ch,:);
        
        %calculate pairwise distance
        D = pdist([cenx',ceny']);
        distmap = squareform(D);
        
        distthres = overlapthres*bsxfun(@plus,radius.',radius);
        
        if rejectoverlap
            %reject kinetochores connected
            existvec = locsource(ch,:)~=-99;
            existmap = bsxfun(@and,existvec.',existvec);
            existmap(1:Nkin+1:end) = 0;
            
            
            connectivity = (distmap<=distthres).*existmap;
            connectivity = triu(connectivity);
            
            [rejid1,rejid2] = find(connectivity);
            
            tobeadded = unique([rejid1;rejid2]);
            kintoreject_fr = [kintoreject_fr;tobeadded(:)];
        end
        
        if rejectellipse
            %ellipticity
            a = max(sigx(ch,:),sigy(ch,:));
            c = min(sigx(ch,:),sigy(ch,:));
            ellip = sqrt((a.^2-c.^2)./a.^2);
            
            tobeadded = find((locsource(ch,:)>-1) & ellip>ellipcutoff);
            kintoreject_fr = [kintoreject_fr;tobeadded(:)];
        end
        
        if rejectradius
            %radius
            Ra = ((locsource(ch,:)==-1).*Rg(ch,:)+(locsource(ch,:)>=0).*sigx(ch,:)*sqrt(2))*coverage;
            Rb = ((locsource(ch,:)==-1).*Rg(ch,:)+(locsource(ch,:)>=0).*sigy(ch,:)*sqrt(2))*coverage;
            
            radius = (Ra+Rb)/2;
            
            tobeadded = find(radius>radiuscutoff);
            kintoreject_fr = [kintoreject_fr;tobeadded(:)];
        end
    end
    
    if rejectnogauss
        tobeadded = find(sum(locsource==-1)>0);
        kintoreject_fr = [kintoreject_fr;tobeadded(:)];
    end
        
    if rejectnoflim
        tobeadded = find(sum(locsource~=-99)>0 & locsource(flimblock,:)==-99);
        kintoreject_fr = [kintoreject_fr;tobeadded];
    end
    
    if isempty(kintoreject_fr)==0
        kintoreject_fr = unique(kintoreject_fr);
        kintoreject_fr(:,2) = fr; 
        kintoreject = [kintoreject;kintoreject_fr];
    end
    
    if isempty(kintoreject_fr)
        kintoaccept_fr = availablekin;
    else
        kintoaccept_fr = availablekin(~ismember(availablekin,kintoreject_fr(:,1)));
    end
    kintoaccept_fr(:,2) = fr;
    kintoaccept = [kintoaccept;kintoaccept_fr];
end

Nkintoreject = size(kintoreject,1);
Nkintoaccept = size(kintoaccept,1);

for i = 1:Nkintoreject
    [kin,kinpair] = rejectKinetochore(kin,kinpair,kintoreject(i,1),kintoreject(i,2));
end


for i = 1:Nkintoaccept
    [kin,kinpair] = acceptKinetochore(kin,kinpair,kintoaccept(i,1),kintoaccept(i,2),handles);
end

outkin = kin;
outkinpair = kinpair;


function [outkin,outkinpair] = rejectKinetochore(kin,kinpair,kinid,frameid)
Nframeid = length(frameid);

if isempty(kin) | isempty(kinid) | isempty(frameid)
    outkin = kin;
    outkinpair = kinpair;
    return;
end

for j = 1:Nframeid
    fr = frameid(j);
    
    kincircle_handle = kin(kinid,fr).kincircle_handle;
    text_handle = kin(kinid,fr).text_handle;
    
    set(kincircle_handle(ishandle(kincircle_handle)),'Visible','off');
    set(text_handle(ishandle(text_handle)),'Visible','off');
    
    if isempty(kinpair) == 0
        pairedkin = [kinpair(:,fr).kinids];
        
        %reject the kinpair with the deleted kin id in
        %this frame
        idx = sum(ismember(pairedkin,kinid),1)>0;
        if sum(idx)
            kinpair(find(idx),fr).kinpairstate = 0;
            
            kinpair_handle = kinpair(find(idx),fr).kinpair_handle;
            kinpairtext_handle = kinpair(find(idx),fr).kinpairtext_handle;
            set(kinpair_handle(ishandle(kinpair_handle)),'Visible','off')
            set(kinpairtext_handle(ishandle(kinpairtext_handle)),'Visible','off');
        end
        
    end
    
    kin(kinid,fr).kinstate = 0;
end

outkin = kin;
outkinpair = kinpair;


function [outkin,outkinpair] = acceptKinetochore(kin,kinpair,kinid,frameid,handles)
Nframeid = length(frameid);
selected = get(handles.FrameSelection_slider,'Value');

if isempty(kin) | isempty(kinid) | isempty(frameid)
    outkin = kin;
    outkinpair = kinpair;
    return;
end

for j = 1:Nframeid
    fr = frameid(j);
    
    kincircle_handle = kin(kinid,fr).kincircle_handle;
    text_handle = kin(kinid,fr).text_handle;
    
    if fr == selected
        set(kincircle_handle(ishandle(kincircle_handle)),'Visible','on');
        set(text_handle(ishandle(text_handle)),'Visible','on');
    end
    
    kin(kinid,fr).kinstate = 1;
    if isempty(kinpair) == 0
        pairedkin = [kinpair(:,fr).kinids];
        kinstate = [kin(:,fr).kinstate];
        
        %reject the kinpair with the deleted kin id in
        %this frame
        idx = sum(ismember(pairedkin,kinid),1)>0;
        pairid = find(idx);
        if sum(idx)
            bothexist = bsxfun(@and, kinstate',kinstate);
            
            for i = 1:length(pairid)
                if prod(pairedkin(:,pairid(i)))>0
                    if bothexist(pairedkin(1,pairid(i)),pairedkin(2,pairid(i)))
                        kinpair(pairid(i),fr).kinpairstate = 1;
                    end
                end
            end
            
            if fr == selected
                kinpair_handle = kinpair(find(idx),fr).kinpair_handle;
                kinpairtext_handle = kinpair(find(idx),fr).kinpairtext_handle;
                set(kinpair_handle(ishandle(kinpair_handle)),'Visible','on')
                set(kinpairtext_handle(ishandle(kinpairtext_handle)),'Visible','on');
            end
        end
        
    end
end


outkin = kin;
outkinpair = kinpair;


% --- Executes during object creation, after setting all properties.
function RejectTrajOverlap_checkbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to RejectTrajOverlap_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% --- Executes during object creation, after setting all properties.
function RejectNoGaussFit_checkbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to RejectNoGaussFit_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% --- Executes during object creation, after setting all properties.
function RejectNoFLIM_checkbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to RejectNoFLIM_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% --- Executes during object creation, after setting all properties.
function RejectEllipticity_checkbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to RejectEllipticity_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% --- Executes during object creation, after setting all properties.
function RejectRadius_checkbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to RejectRadius_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in CorrectCellMovement_checkbox.
function CorrectCellMovement_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to CorrectCellMovement_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of CorrectCellMovement_checkbox
