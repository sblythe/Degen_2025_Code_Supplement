function cellmask = getCellMask(nucmax, embryoMask)

if ~exist('embryoMask')
    embryoMask = zeros(size(nucmax(:,:,1)));
end

for t = 1:size(nucmax, 3)
    cellmask(:,:,t) = bwmorph(nucmax(:,:,t), 'thicken', 8); %n used to be Inf
end
cellmask = cellmask .* embryoMask;

% select cells to keep

