function Make_Mask_TotGeneric(StName,area_cuts,level_fact)
% Not for redox images, just totally generic intensity stacks.
% Find circles using the thresh, blur, thresh again. Then use active
% contours to get precise boundaries.

% % clear all;
% % StName = 'C:\Users\Tim\Documents\Academic - Research\Data\test\IntenStk.tif';
% numeggs = [1 1];
% circ_cut = 1.5;
% level_fact = 0.5;

if ~exist('area_cuts') area_cuts = [100 50000]; end;
if ~exist('level_fact') level_fact = .4; end;

ProcDisp = 0;
close all;
path = UpOneDir(StName);
st = tiffread2(StName);
[a,b] = mkdir([path 'ROIs_check']);

clear Nmasks Fmasks Masks EggVals
imh = figure;
set(gcf,'PaperPositionMode', 'auto')



for i = 1:length(st)
    
    %         if ProcDisp
    %             % If you want to see intermediate image processing steps
    %             imh = figure('units','normalized','position',[.1 .1 .85 .8]);
    %             subplot(2,2,1); imshow(NADim,[])
    %             set(gca,'position',[.02 .52 .45 .45])
    %             subplot(2,2,2); imshow(gim,[]);
    %             set(gca,'position',[.52 .52 .45 .45])
    %             subplot(2,2,3); imshow(mask,[])
    %             set(gca,'position',[.02 .02 .45 .45])
    %             subplot(2,2,4);
    %             pause(1)
    %         else
    %             imh = figure;
    %         end
    
    im = st(i).data;
    xdim = size(im,2); ydim = size(im,1);
    if ~exist('feat_diam') feat_diam = xdim; end;
    % Some frames are dark or don't have much in them. Distinguish on
    % them based on mean intensity, and also based on ratio of mean to
    % std. If there is there is nothing in the frame, we should get
    % std ~ sqrt(mean). std will be higher if there is heterogeneity
    % Make 1.2 the cutoff
    if mean(mean(im))<0.05| (std(double(reshape(im,size(im,1)*size(im,2),1)))/sqrt(mean(mean(im)))<1.2)
        Masks{i}.NL = []; Masks{i}.FL = [];
        Masks{i}.NLper = []; Masks{i}.FLper = [];
        imshow(im,[min(min(im)) max(max(im))*.4],'Border','tight'); hold on;
        set(gcf,'PaperPositionMode', 'auto')
        text(xdim/2,ydim/2,'No mask found','color','red','HorizontalAlignment','center','fontsize',25)
        set(gcf,'position',[200 200 xdim*.6 ydim*.6]);
        if ~ProcDisp
            saveas(imh,[path 'ROIs_check\ROI_im' num2str(i,'%03i') '.png'],'png');
        end
        continue;
    end
    
    [gim mask singlemask maskper num] = EllMask_blur_fillholes(im,area_cuts,level_fact);
    
    
    if isempty(mask)
        mask{1} = 0;
    end
    if isempty(find(mask{1}))
        Masks{i} = [];
        imshow(im,[min(min(im)) max(max(im))*.4],'Border','tight'); hold on;
        set(gcf,'PaperPositionMode', 'auto')
        text(xdim/2,ydim/2,'No mask found','color','red','HorizontalAlignment','center','fontsize',25)
        set(gcf,'position',[200 200 xdim*.6 ydim*.6]);
        if ~ProcDisp
            saveas(imh,[path 'ROIs_check\ROI_im' num2str(i,'%03i') '.png'],'png');        
        end
    else
        imshow(im,[min(min(im)) max(max(im))*.4],'Border','tight'); hold on;
        set(gcf,'PaperPositionMode', 'auto')
        [y,x] = find(bwperim(singlemask));
        plot(x,y,'b.','markersize',3);
        
        %     set(gca,'position',[.52 .02 .45 .45]) % for multi-plot
        hold off;
        if ProcDisp
            pause(1)
        else
            set(gcf,'position',[200 200 xdim*.6 ydim*.6]);
            saveas(imh,[path 'ROIs_check\ROI_im' num2str(i,'%03i') '.png'],'png');
            pause(.01)
        end
        Masks{i} = singlemask; 
        
    end
end
save([path 'Masks.mat'],'Masks');

