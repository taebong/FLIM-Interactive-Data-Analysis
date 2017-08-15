function update_gui(handles,image_update,decay_update,decay,decay_handle)

%update_gui(handles,image_update,decay_update,decay,decay_handle)
%
%update Image_axes, Decay_axes, TotalCount_text based on the currently
%selected image (figured out from the value of slider)
%
%image_update and decay_update: booleans indicating whether to update
%image and decay, respectively. If they are both 0, do nothing.
%decay, decay_handle (optional): update decay with these inputs. They are
%required simultaneously.

if nargin ~= 3 && nargin ~=5
   error('update_gui: wrong number of inputs. decay and decay_handles required simultaneously') 

elseif image_update|decay_update
    selected = get(handles.ImageSelection_slider,'Value');
    image_struct = handles.image_struct;
    saved_decay = handles.saved_decay;
    NumOfImages = handles.NumOfImages;
    NumOfSavedDecays = handles.NumOfSavedDecays;
    
    if image_update
        %axes(handles.Image_axes);
        set(handles.MainGui,'CurrentAxes',handles.Image_axes)
        %hide all images
        for i = 1:NumOfImages
            set(image_struct{i}.image_handle,'Visible','off')
            set(image_struct{i}.selected_pixel_handle,'Visible','off')
            set(image_struct{i}.active_region_handle,'Visible','off')
        end

        %show selected image
        set(image_struct{selected}.image_handle,'Visible','on')
        set(image_struct{selected}.selected_pixel_handle,'Visible','on')
        set(image_struct{selected}.active_region_handle,'Visible','on')
        img_size = size(image_struct{selected}.image);
        axis([0.5,img_size(2)+0.5,0.5,img_size(1)+0.5]);
           
        end
        caxis auto;
        
        active_region = image_struct{selected}.active_region;
        img = image_struct{selected}.image;
        
        if isempty(active_region)
            active_region = [1,1;size(img,2),1;size(img,2),size(img,1);1,size(img,1)];
        end
        
        lower_lim = min(active_region,[],1);
        higher_lim = max(active_region,[],1);
        x_min = lower_lim(1);
        y_min = lower_lim(2);
        x_max = higher_lim(1);
        y_max = higher_lim(2);
        
        %Show filename
        set(handles.Filename_popupmenu,'Value',selected);
        set(handles.FileName_listbox,'Value',selected);
        %update total number of selected pixel
        set(handles.NumOfSelectedPixel_text,'String',num2str(sum(sum(image_struct{selected}.selected_pixel(x_min:x_max,y_min:y_max)))))
        %update timestamp
        tstr = image_struct{selected}.setting.Time;
        [~,~,~,H,MN,S] = datevec(tstr);
        timestr = [num2str(H,'%02d'),':',num2str(MN,'%02d'),':',num2str(S,'%02d')];
        set(handles.TimeStamp_text,'String',timestr);
    end
    
    if decay_update
        if nargin == 5
            selected_decay = decay;
            selected_decay_handle = decay_handle;
        elseif nargin == 3
            selected_decay = image_struct{selected}.decay;
            selected_decay_handle = image_struct{selected}.decay_handle;
        end
        
        set(handles.MainGui,'CurrentAxes',handles.Decay_axes)
        %hide all decays
        for i = 1:NumOfImages
            if ishandle(image_struct{i}.decay_handle)
                set(image_struct{i}.decay_handle,'Visible','off')
            end
        end
        if NumOfSavedDecays > 0 
            for i = 1:NumOfSavedDecays
                if ishandle(saved_decay{i}.decay_handle)
                    set(saved_decay{i}.decay_handle,'Visible','off')
                end
            end
        end
        
        %show selected decay
        set(selected_decay_handle,'Visible','on')
        
        %update Total counts
        total_counts = sum(selected_decay);
        set(handles.TotalCount_text,'String',num2str(total_counts))
    end
end


