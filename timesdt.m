function tp = timesdt(sdt,option)

% tp = timesdt(sdt,option)
% extract time information from sdt flim setup
% sdt can be an array or cell array of structure. tp is array of timepoint
% option can be 'string' (datestr format),'vector' (datevec format),'num'
% (datenum format)

if nargin < 2
    option = 'num'; %default
end

if iscell(sdt)
    sdt = cell2mat(sdt);
end

timestr = strcat({sdt.Date}',{' '},{sdt.Time}');

switch option
    case 'string'
        tp = timestr;
    case 'vector'
        tp = datevec(timestr);
    case 'num'
        tp = datenum(timestr);
end


