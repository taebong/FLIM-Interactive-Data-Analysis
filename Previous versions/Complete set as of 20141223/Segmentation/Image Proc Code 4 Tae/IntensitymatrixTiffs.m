% This routine uses the bh routines to read in .sdt files in a given
% folder, then converts them to intensity images and resaves them in a
% sub-folder.

% NOTE: If you want to bring back the output for each image go to 'BH_BLOCK_INFO'
% and uncomment 'disp( sprintf('%d: %s', i, data.mode));'
% NOTE: Sometimes a frame spontaneously fails. File permissions or
% something. Inconsistent and difficult to troubleshoot, so I
% just skip the frame and go to the next one.


function TotalInts = IntensitymatrixTiffs(path,WrVal,Ch2Bool)
% To read files into Matlab you need to read the setup parameters
% first:
%
% setupdata = readsetup(filename);
%
% In your case, the data is in the first datablock. Thus you can
% read the image data by
%
% data = bh_getdatablock(setupdata, 1)
%
% This returns a 3D matrix (t,x,y).
%
% For more complicated datafiles or to extract more information
% from the files the functions bh_blockinfo and bh_getmeasdesc
% can also be useful.
% INPUTS:
% WrVal: 0-> don't write tiffs, just calculate intensity
%        1-> write tiffs in sub folders called 'Ch1', 'Ch2'
%        2-> write tiffs to stacks in the same folder

%path of the data
if (isdir(path)&path(end)~='\') path = [path '\']; end
if ~exist('WrVal') WrVal = 1; end
if ~exist('Ch2Bool') Ch2Bool = 0; end
data=dir([path '\*.sdt']);
block_1=1;
block_2=2;
%read data\

if WrVal==1
    [a1,b1] = mkdir([path '\Ch1']);
    if Ch2Bool [a1,b1] = mkdir([path '\Ch2']); end;
end

Dtiffs = dir([path '\Ch1\*.tif']);
if length(Dtiffs)>0
    %FIX THIS
    ind = length(Dtiffs);
else
    ind = 1;
end

Ch1failed  = [];
Ch2failed  = [];

% If directory was partially converted, quickly load the previously
% converted tiffs just to calculate the total intensities
if ind>1
    for i=1:ind-1
        ch_1 = imread([path '\Ch1\' Dtiffs(i).name]);
        if Ch2Bool
            ch_2 = imread([path '\Ch2\' Dtiffs(i).name]);
            TotalInts(i) = sum(sum(ch_1))+sum(sum(ch_2));
        else
            TotalInts(i) = sum(sum(ch_1));
        end
    end
end


for i=ind:length(data)
    
    sdt = bh_readsetup([path data(i).name]);
    try
        ch_1 = bh_getdatablock(sdt,block_1);
        ch_1 = squeeze(sum(ch_1,1));
        
        if WrVal==1            
            filepath1=[path '\Ch1\' data(i).name(1:end-3) 'tif'];
            % imwrite(uint8(round(ch_1./max(max(ch_1)).*255)),filepath1,'tiff','Compression','none');
            imwrite(uint8(ch_1),filepath1,'tiff','Compression','none');
        elseif WrVal==2
            StkCh1(i).data=uint8(ch_1);
        end
    catch
        disp(['Im' num2str(i) 'Ch1 failed to save.'])
        Ch1failed = [Ch1failed i];
    end
    
    if Ch2Bool
        try
            ch_2 = bh_getdatablock(sdt,block_2);
            ch_2 = squeeze(sum(ch_2,1));
            if WrVal==1                
                filepath2=[path '\Ch2\' data(i).name(1:end-3) 'tif'];
                % imwrite(uint8(round(ch_2./max(max(ch_2)).*255)),filepath2,'tiff','Compression','none');
                imwrite(uint8(ch_2),filepath2,'tiff','Compression','none');
            elseif WrVal==2
                StkCh2(i).data=uint8(ch_2);
            end
            TotalInts(i) = sum(sum(ch_1))+sum(sum(ch_2));
            Ch1Ints(i) = sum(sum(ch_1));
            Ch2Ints(i) = sum(sum(ch_2));
        catch
            disp(['Im' num2str(i) 'Ch2 failed to save.'])
            Ch2failed = [Ch2failed i];
        end
    else
        TotalInts(i) = sum(sum(ch_1));
    end
    
    if ~isempty(Ch1failed)
        disp(['Frames ' num2str(Ch1failed) ' failed']);
    end
    if ~isempty(Ch2failed)
        disp(['Frames ' num2str(Ch2failed) ' failed']);
    end
end

if WrVal==2
    StkWrite(StkCh1,[path 'IntenStk.tif'])
    if Ch2Bool
        StkWrite(StkCh2,[path 'IntenStk.tif'])
    end
end

if isdir(path)
    save([path '\TotalIntensities.mat'],'TotalInts');
    IntP = figure;
    if exist('Ch1Ints')
        plot(Ch1Ints,'b');
        hold on; plot(Ch2Ints,'r')
    end
    plot(TotalInts,'o-')
    legend('Ch1','Ch2','Tot','location','best')
    set(gca,'FontSize',13)
    ylabel('Total Intensity','FontSize',14)
    slashes = strfind(path,'\');
    saveas(gcf,[path path(slashes(end-1)+1:end-1) '_Ints.fig'])
%     close(IntP)
end;




fopen('all'); % List all open files
fclose('all'); % Close all open files

