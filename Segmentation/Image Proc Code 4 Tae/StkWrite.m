function StkWrite(img, filename, nameappend)
% wr_img(img, filename): write a struct array
% to a 3D image file in uncompressed tif format
% nameappend should be a string to append to the filename of the original
% file.  If you want to create a shorter stack, for example, you could
% enter the string, '_short', and a new file would be created with the name
% 'filename_short'

filename = filename(1:(strfind(filename, '.tif')-1));

if nargin ~= 3
    nameappend='';
else
    nameappend = ['_' nameappend];
end

wr_mode = 'overwrite';
for i=1:size(img,2)
   imwrite(img(i).data,[filename nameappend '.tif'], 'tif', 'Compression',...
'none','WriteMode', wr_mode);
   wr_mode = 'append';
end