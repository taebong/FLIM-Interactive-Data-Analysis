

function root = UpOneDir(base)
% Outputs the directory one level up from the one entered.

if base(end)~='\'
    base = [base '\'];
end

Slashes = find(base=='\');

root = base(1:Slashes(end-1));
