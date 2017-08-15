[fname, pthname] = uigetfile2('*.h5','MultiSelect','on');

if iscell(fname)
    Nfile = length(fname);
else
    Nfile = 1;
end

mask = cell(Nfile,1);

for i = 1:Nfile
    pred = h5read([pthname,fname{i}],'/volume/prediction');
    mask{i} = squeeze(pred(2,:,:)>0.5);
end