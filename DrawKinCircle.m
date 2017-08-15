function [outframe,outkin] = DrawKinCircle(handles,inframe,inkin,location)


%the number of circles to be updated
Ncircle = size(location,1);
flimblock = handles.flimblock;

img_size = size(inframe{1}.image);
[X,Y] = meshgrid(1:img_size(1),1:img_size(2));
for i = 1:Ncircle
    check = 0;
    for ch = 1:2
        kinid = location(i,1,ch);
        fr = location(i,2,ch);
        source = location(i,3,ch);
        cenx = location(i,4,ch);
        ceny = location(i,5,ch);
        Rcover = location(i,6,ch);
     
        if cenx == 0
            continue;
        end
        check = check+1;
        
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
            color = 'g';
        elseif source == 0
            color = 'r';
        elseif source == 1
            color = 'b';
        end
        
        %(Re)draw kinetochore circles and text
        kincircle_handle = DrawCircle(cenx,ceny,Rcover,color);
        text_handle = text(cenx-2,ceny-2,num2str(kinid),'Clipping','on');
        set(kincircle_handle,'Visible','off')
        set(text_handle,'Visible','off','FontSize',12,'Color','y','FontWeight','bold','HorizontalAlignment','right')
        
        inframe{fr}.kincircle_handle(ind,ch) = kincircle_handle;
        inframe{fr}.text_handle(ind,ch) = text_handle;
        
        %(Re)make selected pixel matrices in kin structure
        if ch == flimblock
            if cenx>0
                inkin{kinid}.selected_pixel(:,:,inkin{kinid}.frame==fr) =...
                    ((X-cenx).^2+(Y-ceny).^2<=Rcover^2);
            end
        end
    end
    
    if check == 0 
        error('this kinetochore cannot be found in any frame?')
    end
    
    if i>Ncircle/10 & i<Ncircle/10+1
        disp('10% done')
        drawnow
    elseif i>2*Ncircle/10 & i<2*Ncircle/10+1
        disp('20% done')
        drawnow
    elseif i>3*Ncircle/10 & i<3*Ncircle/10+1
        disp('30% done')
        drawnow
    elseif i>4*Ncircle/10 & i<4*Ncircle/10+1
        disp('40% done')
        drawnow
    elseif i>5*Ncircle/10 & i<5*Ncircle/10+1
        disp('50% done')
        drawnow
    elseif i>6*Ncircle/10 & i<6*Ncircle/10+1
        disp('60% done')
        drawnow
    elseif i>7*Ncircle/10 & i<7*Ncircle/10+1
        disp('70% done')
        drawnow
    elseif i>8*Ncircle/10 & i<8*Ncircle/10+1
        disp('80% done')
        drawnow
    elseif i>9*Ncircle/10 & i<9*Ncircle/10+1
        disp('90% done')
        drawnow
    end
end

outframe = inframe;
outkin = inkin;