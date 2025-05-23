function mcpCellFill = cellFillUntracked(mcpmat, mcpmask, cellmask)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

% find min/max spot intensity
allint = [];
mcpsum = squeeze(sum(mcpmat, 3));
spotmax = squeeze(max(mcpmask, [], 3));
for t = 1:size(mcpmask,4)
    cc = bwconncomp(spotmax(:,:,t));
    img = mcpsum(:,:,t);
    spotint = [];
    for i = 1:cc.NumObjects
        pixels = cc.PixelIdxList{i};
        X = img(pixels);
        spotint(i) = sum(X(:));
    end
    allint = cat(2, allint, spotint);
end

maxSpot = max(allint);
minSpot = min(allint);

spotintnorm = (allint - minSpot) ./ (maxSpot - minSpot);

% color cells
mcpCellFill = zeros(size(cellmask));
j = 1;
for t = 1:size(mcpmask,4)
    cc = bwconncomp(spotmax(:,:,t));
    cellLabel = bwlabel(cellmask(:,:,t));
    frame = zeros(size(cellLabel));
    for i = 1:cc.NumObjects
        pixels = cc.PixelIdxList{i};
        idx = cellLabel(pixels);
        idx(idx == 0) = [];
        cellIdx = mode(idx);
        frame(cellLabel == cellIdx) = spotintnorm(j);
        j = j+1;
    end
    mcpCellFill(:,:,t) = frame;
end
        




end

