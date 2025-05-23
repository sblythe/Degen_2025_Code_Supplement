function [filt] = objIntensityFilt(spotmask, imgmat, minInt, type)
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here

sizeT = size(spotmask, 4);
filt = zeros(size(spotmask));

for t = 1:sizeT
    stack = spotmask(:,:,:,t);
    cc = bwconncomp(stack);
    props = regionprops(cc, imgmat(:,:,:,t), 'PixelValues');
    pixelVal = {props.PixelValues};
%     pixelVal = arrayfun(@struct2cell, props);
    objTotalInt = cellfun(@sum, pixelVal);
    objMeanInt = cellfun(@mean, pixelVal);
    objMaxInt = cellfun(@max, pixelVal);
    for i = 1:cc.NumObjects
        if strcmpi(type, 'total') && objTotalInt(i) < minInt
            stack(cc.PixelIdxList{i}) = 0;
        end
        if strcmpi(type, 'max') && objMaxInt(i) < minInt
            stack(cc.PixelIdxList{i}) = 0;
        end
        if strcmpi(type, 'mean') && objMeanInt(i) < minInt
            stack(cc.PixelIdxList{i}) = 0;
        end
    end
    filt(:,:,:,t) = stack;
end

