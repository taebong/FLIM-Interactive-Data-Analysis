function outputhandles = updateSelectedPixel(handles,selected)
image_struct = handles.image_struct;
Nselected = length(selected);

for i = 1:Nselected
    selected_pixel = handles.image_struct{selected(i)}.selected_pixel;
    selected_pixel_handle = handles.image_struct{selected(i)}.selected_pixel_handle;
    flim = handles.image_struct{selected(i)}.flim;
    decay = handles.image_struct{selected(i)}.decay;
    decay_handle = handles.image_struct{selected(i)}.decay_handle;
    active_region = handles.image_struct{selected(i)}.active_region;
    img = handles.image_struct{selected(i)}.image;
    dt = handles.image_struct{selected(i)}.dt;
    
    update_gui_new(handles,0,1)
    
    %time axis
    time = (1:length(decay))'*dt;

    set(handles.MainGui,'CurrentAxes',handles.Image_axes);
    
    [js,is] = find(selected_pixel.*active_region);
    decay = zeros(size(decay));
    for ind = 1:length(is)
        decay = decay+flim(:,js(ind),is(ind));
    end
    
    
    if ishandle(selected_pixel_handle)
        delete(selected_pixel_handle)
    end
    
    [yy,xx] = find(selected_pixel==1);
    selected_pixel_handle = plot(xx(:),yy(:),'ws','MarkerSize',5); %mark the point
    set(selected_pixel_handle,'Visible','off');
    
    set(handles.MainGui,'CurrentAxes',handles.Decay_axes);
    if ishandle(decay_handle)
        delete(decay_handle);
    end
    
    decay_handle = semilogy(time,decay,'or');
    set(decay_handle,'Visible','off');
    hold on;
        
    %update handles
    image_struct{selected(i)}.selected_pixel_handle = selected_pixel_handle;
    image_struct{selected(i)}.decay = decay;
    image_struct{selected(i)}.decay_handle = decay_handle;
    
end

sliderval = get(handles.ImageSelection_slider,'Value');
%update total photon counts
set(handles.TotalCount_text,'String',num2str(sum(image_struct{sliderval}.decay)))
%update total number of selected pixel
set(handles.NumOfSelectedPixel_text,'String',num2str(sum(sum(image_struct{sliderval}.selected_pixel.*image_struct{sliderval}.active_region))))

set(handles.MainGui,'CurrentAxes',handles.Image_axes);
set(image_struct{sliderval}.selected_pixel_handle,'Visible','on');
set(handles.MainGui,'CurrentAxes',handles.Decay_axes);
set(image_struct{sliderval}.decay_handle,'Visible','on');

handles.image_struct = image_struct;

outputhandles = handles;
