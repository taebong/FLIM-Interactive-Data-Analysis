
function [gim masks singlemask singlemaskper num] = EllMask_blur_fillholes(im,area_cut,level_fact,circ_cut)
% Take in an image, threshold it, then blur, then thress. Sort
% blobs according to size and circularity, using moment of inertia tensor
% Return the singlemask of all circle-like structures.
% clear all;
% level_fact=1;
% area_cut = 100;
% im = imread('C:\Users\Tim\Documents\Academic - Research\Data\2014-05-09 Cumulus cells first\testNADHim1.tif');

xdim = size(im,2); ydim = size(im,1);
if ~exist('feat_diam') egg_diam = ydim/3; end
if ~exist('circ_cut') circ_cut = 10; end % Unless specified, assume amorphous shapes are OK
K = wiener2(im,[5 5]);
level = graythresh(K);
bw1 = im2bw(K,level*level_fact);
G = fspecial('gaussian',[15 15],10);
gim = imfilter(double(bw1),G,'same');

level = graythresh(gim);
bw = im2bw(gim,level*level_fact);

bw = imfill(bw,'holes'); % close all;imshowt(bw);figure;imshowt(im)

% Do and erode to separate touching eggs:
bwe = bw; %imerode(bw,strel('disk',5));
tic
bwe = bw;
prevMatches = 0;
eri = 1;
while prevMatches<10
    bwe = imerode(bwe,strel('disk',2));
    [L nums(eri)] = bwlabel(bwe);
    if eri>1
        if nums(eri)==nums(eri-1)
            prevMatches = prevMatches + 1;
        else
            prevMatches = 0;
        end
    end
    % Quick small area filter
    for i = 1:nums(eri)
        ind = find(L==i);
        if size(ind,1)<area_cut(1) 
            bwe(ind)=0;
        end
    end
    bwes{eri}=bwe;
    eri = eri + 1;
%     imshow(L)
%     pause(.2)
end
% Use first frame that got a stable num of eggs
bwe = bwes{max([eri-prevMatches-1,1])};
% If all blobs eroded (blank bwe), just use first erosion and hope for the
% best
if isempty(find(bwe))
    bwe = imerode(bw,strel('disk',5));
end

% p = bwperim(bwe);
% imshowt(im); hold on;
% [y,x] = find(p);
% plot(x,y,'.r')

% Find connected clusters of pixels and perimeters
[L, num] = bwlabel(bwe);
% Find perimeter of pixel clusters
bwper = bwperim(bwe);
masks={};
singlemask = zeros(ydim,xdim);
singlemaskper = zeros(ydim,xdim);
for i = 1:num
    % For each blob, filter for size and anisotropy, then make a cell with
    % all blobs and another with the corresponding perimeters
    temp = zeros(ydim,xdim);
    temp(find(L==i)) = 1;
    Lt = temp;
    % If any cluseters are touching the boundary, filling holes messes up.
    % Compensate by attaching those vertices and filling holes again.
    % Left side:
    Lt = FillEdgeHoles(Lt);
    
    [y,x] = find(Lt);
    cx(i,1) = mean(x); % Keep track of all cx's to sort left/right at end
    cx(i,2) = i;
    cy = mean(y);
    I = [[sum((y-cy).^2) ...
        -sum((x-cx(i,1)).*(y-cy))];...
        [-sum((x-cx(i,1)).*(y-cy)) ...
        sum((y-cy).^2)]];
    eigvals = eigs(I);
    eigratio = eigvals(1)/eigvals(2);
    circularity = abs(1-eigratio);
    %     imshow(Lt);
    %     circularity
    % Filter:
    if circularity<circ_cut & size(x,1)>area_cut(1)& size(x,1)<area_cut(2)
        Lper = bwlabel(bwperim(Lt));
        [yper,xper] = find(Lper);
        singlemask = singlemask + temp;
        masks{i} = Lt;
    else
        masks{i} = [];
    end
end
% Reindex and sort by x CoM postion, from left-to-right
if exist('cx')
    cx(cellfun('isempty',masks),:)=[];
    cx = sortrows(cx,1);
    cx(cx(:,2)>size(masks,2),:)=[];
    masks = masks(cx(:,2));
    num = size(masks,2);
    singlemaskper = bwperim(singlemask);
    % disp('')
end







