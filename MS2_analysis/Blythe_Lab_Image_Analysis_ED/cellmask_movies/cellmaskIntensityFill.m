function intFill = cellmaskIntensityFill(trackObjInt, trLabel, myTracks, cellmask)

% 01/02/19

intFill = zeros(size(trLabel));

% match cellmask to trackmat values
trackedCellMask = zeros(size(trLabel));

for t = 1:size(trLabel, 3)
    % get cellmask centers
    thismask = cellmask(:,:,t);
    cc = bwconncomp(thismask);
    props = regionprops(cc, 'Centroid');
    cent = round(cat(1, props.Centroid));
    
    tempmask = zeros(size(thismask));
    for c = 1:cc.NumObjects
        trackIdx = trLabel(cent(c,2), cent(c,1), t);
        pixels = cc.PixelIdxList{c};
        tempmask(pixels) = trackIdx;
    end
    trackedCellMask(:,:,t) = tempmask;
end

% fill in trackedCellMask with appropriate intensity values

intFill = trackedCellMask;
intFill(trackedCellMask == 0) = NaN;
intFill(intFill > 0) = 0;
for t = 1:size(trackedCellMask, 3)
    fillStack = intFill(:,:,t);
    trackStack = trackedCellMask(:,:,t);
    for i = 1:length(myTracks)
        objPixels = find(trackStack == myTracks(i));
        fillStack(objPixels) = trackObjInt(i,t);
    end
    intFill(:,:,t) = fillStack;
end


