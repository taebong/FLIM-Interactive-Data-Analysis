function hfig = CheckOpenState(figname)

% Check whether figure with the name figname is open or not. If it's open,
% return its handle, and if not, return -99.

h = findall(0,'type','figure');
openfigname = get(h,'name');

hfig = -99;
for i = 1:size(openfigname,1)
    if strcmp(figname,openfigname(i))
        hfig = h(i);
    end
end