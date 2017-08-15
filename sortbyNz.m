function sortinfo = sortbyNz(sdt,Nz,repeat,Npos)

%to be edited for multi position acquisition.

if nargin < 4
    Npos = 1;
end

Nsdt = length(sdt);
if iscell(sdt)
    sdt = cell2mat(sdt);
end

tstamp = timesdt(sdt,'vector');

tid = 0;
zid = 0;
cid = 1;
firstfr = 1;

sdtID = zeros(Nsdt,1);
timepoint = zeros(Nsdt,1);
z = cell(Nsdt,1);
timestamp = timesdt(sdt,'num');

n = 1;
while n<=Nsdt 
    telapsed = etime(tstamp(n,:),tstamp(firstfr,:));
    if telapsed >= repeat-0.1 || zid == Nz;
        zid = 0;
        tid = tid+1;
        firstfr = n;
    end
    sdtID(n) = cid;
    timepoint(n) = tid;
    z{n} = num2str(zid,'z%d');
    
    zid = zid+1;
    cid = cid+1;
    n = n+1;
end


PosID = zeros(Nsdt,1);

sortinfo = table(sdtID,PosID,timepoint,z,timestamp);