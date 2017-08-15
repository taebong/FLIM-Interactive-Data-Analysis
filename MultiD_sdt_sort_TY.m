function sortinfo = MultiD_sdt_sort_TY(path)

if path(end)~='\'; path = [path '\']; end;

D = dir([path 'uMan_*']);

if isempty(D) %uManager folder doesn't exist
    sortinfo = -1;
    return;
end

uManpath = [path D(1).name '\'];
Dsdt = dir([path '*.sdt']);
sdtL = length(Dsdt);
DMan = dir(uManpath); DMan(1:2)=[]; DMan(~[DMan.isdir])=[];

sdts = [];

for i =1:sdtL
    sdts = [sdts;bh_readsetup([path,Dsdt(i).name])];
end

tstamps_sdt = timesdt(sdts);
tstamp1_sdt = min(tstamps_sdt);

sdtnums = cellfun(@str2double,regexp({sdts.filename},'_c(\d)*','tokens','once'));

DManfiles = [];
uManPos = [];

for posnum = 1:max([length(DMan),1])
    % Assume at least 1 position. If no pos specified, assume only 1 pos and
    % tiffs are in uManpath.
    if isempty(DMan)
        DManfiles = dir([uManpath '\*.tif']);
        uManPos = repmat(0,length(DManfiles));
    else
        % Get subdirectories
        dd = dir([uManpath DMan(posnum).name '\*.tif']);
        DManfiles = [DManfiles;dd];
        uManPos = [uManPos;repmat(str2double(DMan(posnum).name(4:end)),length(dd),1)];
    end
end

DManfilenames = {DManfiles.name};
removeind = ~cellfun(@isempty,strfind(DManfilenames,'_off_'));

DManfiles(removeind) = [];
DManfilenames(removeind) = [];
uManPos(removeind) = [];

tstamps_uman = [DManfiles.datenum];
tstamps_uman = tstamps_uman(:);

maxdiff = 1.5/3600/24; %1.5sec
nameinds = [];
for i = 1:sdtL
    if isempty(tstamps_uman)
        break;
    end
    [mindiff,ind] = min(abs(tstamps_uman-tstamps_sdt(i)));
    if mindiff > maxdiff
        continue
    end
    dashes = strfind(DManfilenames{ind},'_');
    t = str2double(DManfilenames{ind}(dashes(1)+1:dashes(2)-1));
    chan = DManfilenames{ind}(dashes(2)+1:dashes(3)-1);
    tiffstr = strfind(DManfilenames{ind},'.tif');
    z = str2double(DManfilenames{ind}(tiffstr-3:tiffstr-1));
    nameinds = [nameinds;{sdtnums(i),uManPos(ind),t,chan,tstamps_sdt(i)}];
    tstamps_uman(ind) = [];
    DManfilenames(ind) = [];
    uManPos(ind) = [];
    DManfiles(ind) = [];
end

nameinds = sortrows(nameinds,5);
sortinfo = cell2table(nameinds(:,[1,2,3,4,5]));
sortinfo.Properties.VariableNames = {'sdtID','PosID','timepoint','z','timestamp'};



