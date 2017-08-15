function sortinfo = MultiD_sdt_rename(path,backup)
% Using uManager, multi-D acquisitions can be taken with any of the
% following dimensions: [Pos,t,channel,z]
% When saving B&H sdt's from the ttl trigger from the z piezo, sdt files
% are saved in one big series. You also save the uManager demo cam images
% in the same folder as the multi-D acquisition (use 4x4 binning to reduce
% image size).
% This program uses the uManager structure and image time stamps to sort
% and rename the sdt's for further analysis.

% clear all; path = 'C:\Users\Tim\Documents\Academic - Research\Data\2014-04-30 MultiD Cemb\S1';

% Version:
% -Just switched to using uMan to trigger B&H with a DAQ card
% because z piezo was inconsistent. Filenames are different, using a
% different channel for each z position. Change the reading scheme in this
% function, but keep the previous sdt-writing scheme so I don't have to
% change the subsequent programs.
% read:   'img_000000000_FAD_z0_on_000.tif'
% write:  'cXXX_PosX_tXX_zX'

%Modified by Tae Yeon Yoo 


if path(end)~='\'; path = [path '\']; end;
if nargin < 2
    copybool = 0;
end

slashes = strfind(path,'\');
Run = path(slashes (end-1)+1:end-1);
%sdtpath = [path 'sorted_sdts\'];
D = dir([path 'uMan_*']);

if isempty(D) %uManager folder doesn't exist
    sortinfo = -1;
    return;
end

uManpath = [path D(1).name '\'];
Dsdt = dir([path '*.sdt']);
sdtL = size(Dsdt,1);
%[a,b] = mkdir(sdtpath);
DMan = dir(uManpath); DMan(1:2)=[]; DMan(~[DMan.isdir])=[];

% Make an list, 'nameinds' that keeps track of the exact file correspondence
% [sdt# , uManfile-Pos , uManfile-t , uManfile-chan , uManfile-z]
nameinds = {};

%tstamp1_sdt = Dsdt(1).datenum;
% for i = 1:length(Dsdt)
%     tstamps_sdt(i) = Dsdt(i).datenum;
% end
sdt = [];

for i =1:length(Dsdt)
    sdt = [sdt;bh_readsetup([path,Dsdt(i).name])];
end
tstamps_sdt = timesdt(sdt);
tstamp1_sdt = tstamps_sdt(1);


for posnum = 1:max([length(DMan),1])
    % Assume at least 1 position. If no pos specified, assume only 1 pos and
    % tiffs are in uManpath.
    if isempty(DMan)
        DManfiles{1} = dir([uManpath '\*.tif']);
        DManmeta{1} = dir([uManpath '\metadata.txt']);
        uManPosNum = 0;
    else
        % Get subdirectories
        DManfiles{posnum} = dir([uManpath DMan(posnum).name '\*.tif']);
        DManmeta{posnum} = dir([uManpath DMan(posnum).name '\metadata.txt']);
    end
    if isempty(strfind([DManfiles{1}.name],'_z0_'))
        DAQbool = 0;
    else
        DAQbool = 1;
    end
    % Get rid of 'waiting' files used for laser wavelength switching
    remove = [];
    for k = 1:length(DManfiles{posnum})
        if ~isempty(strfind(DManfiles{posnum}(k).name,'wait'))|~isempty(strfind(DManfiles{posnum}(k).name,'_off_'))
            remove = [remove k];
        end
    end
    DManfiles{posnum}(remove)=[];
    
    % Find earliest non-waiting uMan file
    earliestuManind = find([DManfiles{1}(:).datenum] == min([DManfiles{1}(:).datenum]));
    tstampoffset = min([DManfiles{1}(:).datenum])-tstamp1_sdt;
end

for posnum = 1:max([length(DMan),1])
    prevSdtInd = -1;
    for i = 1:min([size(Dsdt,1),length(DManfiles{posnum})])
        clear tstamps_uMan
        if i ==160
            disp('')
        end
        
        file = DManfiles{posnum}(i).name;
        % DAQ trigger used, channels will have '_z0_'
        dashes = strfind(file,'_');
        t = str2num(file(dashes(1)+1:dashes(2)-1));
        chan = file(dashes(2)+1:dashes(3)-1);
        tiffstr = strfind(file,'.tif');
%         if DAQbool
            z = str2num(file(tiffstr-3:tiffstr-1));
%         else
%             z = str2num(file(dashes(3)+1:end-4));
%         end
        tstamps_uMan(i) = DManfiles{posnum}(i).datenum;
        % Using time stamps find the corresponding sdt file, which is
        % the file closest in time to current uMan file.
        % sdt should save shortly before uMan file does.
        diffs = tstamps_sdt-tstamps_uMan(i)+tstampoffset;
        negdiffs = find(diffs<0);
        smallestdiffs = find(abs(diffs)==min(abs(diffs)));
        SdtMatchingInd = smallestdiffs;
        
        % Every once and while, you get two StdMatchingInd's, so take
        % the first one (earlier)
        SdtMatchingInd = SdtMatchingInd(1);
        % Sometimes delays happen because B&H takes too long to save. Sometimes
        % skip a frame. If that happens, two uMan files will get
        % matched with one sdt.
        % Solution: find the uMan that the sdt is closer to, flag the other
        % frame to be exluded from the rest of analysis.
        dups = find([nameinds{:,1}]==SdtMatchingInd);
            
        % Add the frame to the name index. Include the uMan timestamp
        % in case of duplicates, but delete that column at the end
        % Use Columns 7 and 8 (timestamps and nscans) as the flag column.
        % This keeps sdt, z, t, and tiff correspondences, but timestamp
        % won't be needed.
        if ~isempty(DMan) uManPosNum = str2num(DMan(posnum).name(4:end)); end
        %nameinds = [nameinds; {SdtMatchingInd,uManPosNum,t,chan,z,-1,tstamps_uMan(i),[]}];
        nameinds = [nameinds; {SdtMatchingInd,uManPosNum,t,chan,z,-1,tstamps_sdt(SdtMatchingInd),[]}];
        if ~isempty(dups)
            diff1 = abs(tstamps_sdt(SdtMatchingInd)-nameinds{dups,7});
            diff2 = abs(tstamps_sdt(SdtMatchingInd)-tstamps_uMan(i));
            if diff1<diff2
                nameinds(end,[7 8])=num2cell(-1); % Flag the row just added, ie, current frame
            else
                nameinds(dups,[7 8])=num2cell(-1); % Flag other duplicate
            end
        end
    end
end

nameinds = sortrows(nameinds,1);
zname = unique(nameinds(:,4));

sortinfo = cell2table(nameinds(:,[1,2,3,4,7]));
sortinfo.Properties.VariableNames = {'sdtID','PosID','timepoint','z','timestamp'};

if backup
   mkdir([path 'sdtbackup\']); 
end

Nunsorted = 0;
for i = 1:sdtL
    oldname = [path Dsdt(i).name];
    if sortinfo.timepoint(i) == -1
        Nunsorted = Nunsorted + 1;
        newname = [path 'unsorted' num2str(Nunsorted,'%02d') '.sdt'];
    else
        newname = char(strcat(path,num2str(sortinfo.sdtID(i),'c%03d_'),...
            num2str(sortinfo.PosID(i),'Pos%01d_'),...
            num2str(sortinfo.timepoint(i),'t%02d_'),sortinfo.z(i),'.sdt'));    
    end
    
    if backup
        orig = [path Dsdt(i).name];
        dest = [path 'sdtbackup\' Dsdt(i).name];
        copyfile(orig,dest);
    end
    
    movefile(oldname,newname);
end

