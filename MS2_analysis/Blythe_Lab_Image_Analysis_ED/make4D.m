function xyzt = make4D(data, meta)
% this function will take a 4D dataset arranged in a cell array and convert
% it to a standard 4D matrix using the information in the OME metadata
% object. You need to first split channels and feed each channel to this
% function one at a time. 
temp = cat(3, data{:});
xyzt = reshape(temp,[meta.SizeY, meta.SizeX, meta.SizeZ, meta.SizeT]);
